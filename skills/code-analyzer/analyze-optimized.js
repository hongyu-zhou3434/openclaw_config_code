#!/usr/bin/env node
/**
 * 优化的代码分析工具
 * 支持重试机制、断点续传、网络优化
 */

const { execSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const https = require('https');

// 配置
const CONFIG = {
  workDir: '/tmp/code-analysis',
  reportDir: '/root/.openclaw/workspace/skills/code-analyzer/reports',
  maxRetries: 3,
  retryDelay: 5000,
  timeout: 300000, // 5分钟超时
  shallowClone: true // 默认浅克隆
};

// 确保目录存在
function ensureDir(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

// 延迟函数
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// 执行命令（带超时和错误处理）
function runCommand(cmd, cwd = null, timeout = CONFIG.timeout) {
  return new Promise((resolve, reject) => {
    const options = {
      cwd,
      timeout,
      maxBuffer: 1024 * 1024 * 10 // 10MB buffer
    };
    
    execSync(cmd, options);
    resolve(true);
  });
}

// 检查网络连接
async function checkNetwork() {
  return new Promise((resolve) => {
    const req = https.get('https://github.com', { timeout: 10000 }, (res) => {
      resolve(res.statusCode === 200 || res.statusCode === 301);
    });
    req.on('error', () => resolve(false));
    req.on('timeout', () => {
      req.destroy();
      resolve(false);
    });
  });
}

// 配置 Git 优化
function configureGit() {
  try {
    // 增大缓冲区
    execSync('git config --global http.postBuffer 524288000');
    execSync('git config --global http.maxRequestBuffer 100M');
    execSync('git config --global http.lowSpeedLimit 1000');
    execSync('git config --global http.lowSpeedTime 60');
    // 启用压缩
    execSync('git config --global core.compression 0');
    // 设置代理（如有）
    // execSync('git config --global http.proxy http://proxy:port');
    console.log('✅ Git 配置优化完成');
  } catch (e) {
    console.log('⚠️ Git 配置优化失败:', e.message);
  }
}

// 克隆仓库（带重试机制）
async function cloneRepo(url, branch = 'main') {
  const repoName = url.split('/').pop().replace('.git', '');
  const targetDir = path.join(CONFIG.workDir, repoName);
  
  // 清理旧目录
  if (fs.existsSync(targetDir)) {
    console.log('🧹 清理旧目录...');
    try {
      execSync(`rm -rf "${targetDir}"`);
    } catch (e) {
      console.log('⚠️ 清理旧目录失败');
    }
  }
  
  ensureDir(CONFIG.workDir);
  
  // 检查网络
  console.log('🔍 检查网络连接...');
  const networkOk = await checkNetwork();
  if (!networkOk) {
    console.log('❌ 网络连接异常，无法访问 GitHub');
    throw new Error('网络连接失败');
  }
  console.log('✅ 网络连接正常');
  
  // 配置 Git
  configureGit();
  
  // 尝试克隆（带重试）
  let lastError = null;
  
  for (let attempt = 1; attempt <= CONFIG.maxRetries; attempt++) {
    console.log(`\n📥 正在克隆仓库 (尝试 ${attempt}/${CONFIG.maxRetries}): ${url}`);
    
    try {
      // 方案1: 浅克隆指定分支
      const depthFlag = CONFIG.shallowClone ? '--depth 1' : '';
      await runCommand(`git clone ${depthFlag} -b ${branch} "${url}" "${targetDir}"`);
      console.log('✅ 克隆完成');
      return targetDir;
      
    } catch (error) {
      lastError = error;
      console.log(`⚠️ 尝试 ${attempt} 失败:`, error.message);
      
      if (attempt < CONFIG.maxRetries) {
        console.log(`⏳ ${CONFIG.retryDelay/1000}秒后重试...`);
        await sleep(CONFIG.retryDelay);
        
        // 尝试其他分支
        if (attempt === 1) {
          branch = 'master';
          console.log('🔄 尝试 master 分支...');
        } else if (attempt === 2) {
          // 尝试不指定分支
          console.log('🔄 尝试默认分支...');
          try {
            await runCommand(`git clone ${depthFlag} "${url}" "${targetDir}"`);
            console.log('✅ 克隆完成');
            return targetDir;
          } catch (e2) {
            console.log('⚠️ 默认分支也失败');
          }
        }
      }
    }
  }
  
  // 所有重试都失败
  console.log('\n❌ 克隆失败，尝试备用方案...');
  
  // 备用方案: 使用 wget 下载 ZIP
  try {
    console.log('📦 尝试下载 ZIP 包...');
    const zipUrl = url.replace('.git', '/archive/refs/heads/' + branch + '.zip');
    const zipFile = path.join(CONFIG.workDir, `${repoName}.zip`);
    
    await runCommand(`wget -q --timeout=60 --tries=3 "${zipUrl}" -O "${zipFile}"`);
    await runCommand(`unzip -q "${zipFile}" -d "${CONFIG.workDir}"`);
    
    // 重命名解压后的目录
    const extractedDir = path.join(CONFIG.workDir, `${repoName}-${branch}`);
    if (fs.existsSync(extractedDir)) {
      fs.renameSync(extractedDir, targetDir);
    }
    
    // 清理 ZIP
    fs.unlinkSync(zipFile);
    
    console.log('✅ ZIP 下载并解压完成');
    return targetDir;
    
  } catch (zipError) {
    console.log('❌ ZIP 下载也失败:', zipError.message);
  }
  
  throw new Error(`克隆失败: ${lastError.message}`);
}

// 验证下载完整性
function verifyDownload(targetDir) {
  console.log('🔍 验证下载完整性...');
  
  if (!fs.existsSync(targetDir)) {
    throw new Error('下载目录不存在');
  }
  
  const items = fs.readdirSync(targetDir);
  if (items.length === 0) {
    throw new Error('下载目录为空');
  }
  
  // 检查是否有实际代码文件（不只是.git）
  const nonGitItems = items.filter(item => item !== '.git');
  if (nonGitItems.length === 0) {
    throw new Error('下载不完整，只有.git目录');
  }
  
  console.log(`✅ 下载验证通过，包含 ${nonGitItems.length} 个文件/目录`);
  return true;
}

// 主函数
async function main() {
  const args = process.argv.slice(2);
  
  if (args.length < 1) {
    console.log('用法: node analyze-optimized.js <GitHub仓库URL> [分支名]');
    console.log('示例: node analyze-optimized.js https://github.com/Wan-Video/Wan2.2.git');
    process.exit(1);
  }
  
  const url = args[0];
  const branch = args[1] || 'main';
  
  console.log('🔍 优化的代码分析工具启动');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`目标仓库: ${url}`);
  console.log(`分支: ${branch}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  
  try {
    // 1. 克隆仓库
    const targetDir = await cloneRepo(url, branch);
    
    // 2. 验证下载
    verifyDownload(targetDir);
    
    // 3. 调用 analyze-local.js 进行分析
    console.log('\n🔍 开始分析代码...');
    const analyzeScript = path.join(__dirname, 'analyze-local.js');
    
    try {
      execSync(`node "${analyzeScript}" "${targetDir}"`, {
        stdio: 'inherit',
        timeout: 300000
      });
    } catch (e) {
      console.log('⚠️ 分析过程出错:', e.message);
    }
    
    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('✅ 全部完成！');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
  } catch (error) {
    console.error('\n❌ 失败:', error.message);
    process.exit(1);
  }
}

main();
