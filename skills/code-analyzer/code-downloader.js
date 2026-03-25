#!/usr/bin/env node
/**
 * CodeBuddy 代码下载工具
 * 系统默认代码下载工具，支持多种下载策略
 */

const { execSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

// 配置
const CONFIG = {
  workDir: '/tmp/code-analysis',
  maxRetries: 3,
  retryDelay: 5000,
  timeout: 300000,
  strategies: ['ssh', 'https', 'mirror', 'zip']
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

// 记录日志
function log(message, type = 'info') {
  const timestamp = new Date().toISOString();
  const prefix = {
    'info': 'ℹ️',
    'success': '✅',
    'error': '❌',
    'warning': '⚠️',
    'progress': '⏳'
  }[type] || 'ℹ️';
  console.log(`${prefix} ${message}`);
}

// 执行命令
async function runCommand(cmd, cwd = null, timeout = CONFIG.timeout) {
  return new Promise((resolve, reject) => {
    try {
      const options = {
        cwd,
        timeout,
        maxBuffer: 1024 * 1024 * 50 // 50MB buffer
      };
      execSync(cmd, options);
      resolve(true);
    } catch (error) {
      reject(error);
    }
  });
}

// 策略1: SSH方式下载
async function downloadSSH(repoUrl, targetDir, branch = 'main') {
  log('尝试 SSH 方式下载...', 'progress');
  
  try {
    // 转换 HTTPS 到 SSH
    let sshUrl = repoUrl;
    if (repoUrl.startsWith('https://github.com/')) {
      const path = repoUrl.replace('https://github.com/', '');
      sshUrl = `git@github.com:${path}`;
    }
    
    await runCommand(`git clone --depth 1 -b ${branch} "${sshUrl}" "${targetDir}"`);
    log('SSH 下载成功', 'success');
    return true;
  } catch (error) {
    log(`SSH 下载失败: ${error.message}`, 'warning');
    return false;
  }
}

// 策略2: HTTPS方式下载
async function downloadHTTPS(repoUrl, targetDir, branch = 'main') {
  log('尝试 HTTPS 方式下载...', 'progress');
  
  try {
    // 配置 Git 优化
    execSync('git config --global http.postBuffer 524288000');
    execSync('git config --global http.lowSpeedLimit 1000');
    execSync('git config --global http.lowSpeedTime 60');
    
    await runCommand(`git clone --depth 1 -b ${branch} "${repoUrl}" "${targetDir}"`);
    log('HTTPS 下载成功', 'success');
    return true;
  } catch (error) {
    log(`HTTPS 下载失败: ${error.message}`, 'warning');
    return false;
  }
}

// 策略3: 镜像代理下载
async function downloadMirror(repoUrl, targetDir, branch = 'main') {
  log('尝试镜像代理下载...', 'progress');
  
  const mirrors = [
    'https://ghproxy.com/',
    'https://mirror.ghproxy.com/',
    'https://hub.gitmirror.com/'
  ];
  
  for (const mirror of mirrors) {
    try {
      const mirrorUrl = mirror + repoUrl;
      log(`尝试镜像: ${mirror}`, 'progress');
      await runCommand(`git clone --depth 1 -b ${branch} "${mirrorUrl}" "${targetDir}"`);
      log('镜像下载成功', 'success');
      return true;
    } catch (error) {
      log(`镜像 ${mirror} 失败`, 'warning');
    }
  }
  
  return false;
}

// 策略4: ZIP下载
async function downloadZIP(repoUrl, targetDir, branch = 'main') {
  log('尝试 ZIP 下载...', 'progress');
  
  try {
    const zipUrl = repoUrl.replace('.git', `/archive/refs/heads/${branch}.zip`);
    const zipFile = `${targetDir}.zip`;
    
    await runCommand(`wget -q --timeout=120 --tries=2 "${zipUrl}" -O "${zipFile}"`);
    await runCommand(`unzip -q "${zipFile}" -d "${path.dirname(targetDir)}"`);
    
    // 重命名目录
    const extractedDir = path.join(path.dirname(targetDir), `${path.basename(targetDir)}-${branch}`);
    if (fs.existsSync(extractedDir)) {
      fs.renameSync(extractedDir, targetDir);
    }
    
    // 清理 ZIP
    fs.unlinkSync(zipFile);
    log('ZIP 下载成功', 'success');
    return true;
  } catch (error) {
    log(`ZIP 下载失败: ${error.message}`, 'warning');
    return false;
  }
}

// 主下载函数
async function downloadCode(repoUrl, options = {}) {
  const {
    branch = 'main',
    targetName = null,
    strategy = 'auto' // auto, ssh, https, mirror, zip
  } = options;
  
  // 提取仓库名
  const repoName = targetName || repoUrl.split('/').pop().replace('.git', '');
  const targetDir = path.join(CONFIG.workDir, repoName);
  
  log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', 'info');
  log('CodeBuddy 代码下载工具', 'info');
  log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', 'info');
  log(`仓库: ${repoUrl}`, 'info');
  log(`分支: ${branch}`, 'info');
  log(`目标: ${targetDir}`, 'info');
  log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', 'info');
  
  // 清理旧目录
  if (fs.existsSync(targetDir)) {
    log('清理旧目录...', 'progress');
    try {
      execSync(`rm -rf "${targetDir}"`);
    } catch (e) {
      log('清理旧目录失败', 'warning');
    }
  }
  
  ensureDir(CONFIG.workDir);
  
  // 根据策略选择下载方式
  const strategies = {
    'ssh': [downloadSSH],
    'https': [downloadHTTPS],
    'mirror': [downloadMirror],
    'zip': [downloadZIP],
    'auto': [downloadSSH, downloadHTTPS, downloadMirror, downloadZIP]
  }[strategy] || [downloadSSH, downloadHTTPS, downloadMirror, downloadZIP];
  
  // 尝试各种策略
  for (let i = 0; i < strategies.length; i++) {
    const downloadFn = strategies[i];
    log(`\n尝试策略 ${i + 1}/${strategies.length}...`, 'progress');
    
    if (await downloadFn(repoUrl, targetDir, branch)) {
      // 验证下载
      if (verifyDownload(targetDir)) {
        log('\n✅ 下载完成！', 'success');
        return targetDir;
      }
    }
    
    if (i < strategies.length - 1) {
      log('等待后重试...', 'progress');
      await sleep(CONFIG.retryDelay);
    }
  }
  
  throw new Error('所有下载策略均失败');
}

// 验证下载完整性
function verifyDownload(targetDir) {
  log('验证下载完整性...', 'progress');
  
  if (!fs.existsSync(targetDir)) {
    throw new Error('下载目录不存在');
  }
  
  const items = fs.readdirSync(targetDir);
  const nonGitItems = items.filter(item => item !== '.git');
  
  if (nonGitItems.length === 0) {
    log('警告: 目录中只有.git，可能下载不完整', 'warning');
    return false;
  }
  
  const fileCount = nonGitItems.length;
  log(`验证通过: ${fileCount} 个文件/目录`, 'success');
  return true;
}

// 命令行接口
async function main() {
  const args = process.argv.slice(2);
  
  if (args.length < 1 || args[0] === '--help' || args[0] === '-h') {
    console.log(`
CodeBuddy 代码下载工具

用法:
  code-downloader <仓库URL> [选项]

选项:
  --branch, -b    指定分支 (默认: main)
  --name, -n      指定目录名
  --strategy, -s  下载策略 (auto|ssh|https|mirror|zip, 默认: auto)
  --help, -h      显示帮助

示例:
  code-downloader https://github.com/Wan-Video/Wan2.2.git
  code-downloader https://github.com/Wan-Video/Wan2.2.git -b dev
  code-downloader https://github.com/Wan-Video/Wan2.2.git -s ssh
  code-downloader git@github.com:Wan-Video/Wan2.2.git
`);
    process.exit(0);
  }
  
  const repoUrl = args[0];
  const options = {
    branch: 'main',
    strategy: 'auto'
  };
  
  // 解析参数
  for (let i = 1; i < args.length; i++) {
    const arg = args[i];
    const nextArg = args[i + 1];
    
    if ((arg === '--branch' || arg === '-b') && nextArg) {
      options.branch = nextArg;
      i++;
    } else if ((arg === '--name' || arg === '-n') && nextArg) {
      options.targetName = nextArg;
      i++;
    } else if ((arg === '--strategy' || arg === '-s') && nextArg) {
      options.strategy = nextArg;
      i++;
    }
  }
  
  try {
    const targetDir = await downloadCode(repoUrl, options);
    console.log(`\n📁 下载位置: ${targetDir}`);
    process.exit(0);
  } catch (error) {
    console.error(`\n❌ 错误: ${error.message}`);
    process.exit(1);
  }
}

// 导出模块
module.exports = { downloadCode, verifyDownload };

// 如果是直接运行
if (require.main === module) {
  main();
}
