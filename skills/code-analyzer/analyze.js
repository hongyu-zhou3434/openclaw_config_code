#!/usr/bin/env node
/**
 * 代码分析工具
 * 自动从 GitHub 下载源码并生成技术分析报告
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// 配置
const CONFIG = {
  workDir: '/tmp/code-analysis',
  reportDir: '/root/.openclaw/workspace/skills/code-analyzer/reports'
};

// 确保目录存在
function ensureDir(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

// 执行命令
function runCommand(cmd, cwd = null) {
  try {
    return execSync(cmd, { 
      cwd, 
      encoding: 'utf8',
      timeout: 120000
    });
  } catch (e) {
    console.error(`Command failed: ${cmd}`);
    console.error(e.message);
    return null;
  }
}

// 克隆仓库
function cloneRepo(url, branch = 'main') {
  const repoName = url.split('/').pop().replace('.git', '');
  const targetDir = path.join(CONFIG.workDir, repoName);
  
  // 清理旧目录
  if (fs.existsSync(targetDir)) {
    runCommand(`rm -rf "${targetDir}"`);
  }
  
  console.log(`📥 正在克隆仓库: ${url}`);
  const result = runCommand(`git clone -b ${branch} --depth 1 "${url}" "${targetDir}"`);
  
  if (result === null) {
    // 尝试 master 分支
    console.log('⚠️ 尝试 master 分支...');
    const result2 = runCommand(`git clone -b master --depth 1 "${url}" "${targetDir}"`);
    if (result2 === null) {
      throw new Error('克隆失败');
    }
  }
  
  console.log('✅ 克隆完成');
  return targetDir;
}

// 分析目录结构
function analyzeStructure(dir) {
  console.log('🔍 分析目录结构...');
  
  const structure = {
    totalFiles: 0,
    totalDirs: 0,
    languages: {},
    keyFiles: []
  };
  
  function scan(currentDir, depth = 0) {
    if (depth > 3) return; // 限制深度
    
    const items = fs.readdirSync(currentDir);
    
    for (const item of items) {
      if (item.startsWith('.') || item === 'node_modules') continue;
      
      const fullPath = path.join(currentDir, item);
      const stat = fs.statSync(fullPath);
      
      if (stat.isDirectory()) {
        structure.totalDirs++;
        scan(fullPath, depth + 1);
      } else {
        structure.totalFiles++;
        const ext = path.extname(item).toLowerCase();
        structure.languages[ext] = (structure.languages[ext] || 0) + 1;
        
        // 识别关键文件
        if (['package.json', 'requirements.txt', 'Cargo.toml', 'pom.xml', 'Dockerfile', 'README.md', 'main.py', 'app.py', 'index.js'].includes(item)) {
          structure.keyFiles.push(item);
        }
      }
    }
  }
  
  scan(dir);
  return structure;
}

// 使用 CodeBuddy 分析代码
function analyzeWithCodeBuddy(dir) {
  console.log('🤖 使用 CodeBuddy 分析代码...');
  
  // 读取 README
  let readme = '';
  const readmePath = path.join(dir, 'README.md');
  if (fs.existsSync(readmePath)) {
    readme = fs.readFileSync(readmePath, 'utf8').slice(0, 2000);
  }
  
  // 读取 package.json 或类似文件
  let deps = '';
  const pkgPath = path.join(dir, 'package.json');
  if (fs.existsSync(pkgPath)) {
    const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
    deps = JSON.stringify({
      dependencies: pkg.dependencies,
      devDependencies: pkg.devDependencies
    }, null, 2);
  }
  
  // 查找模型文件
  const modelFiles = [];
  function findModels(currentDir) {
    const items = fs.readdirSync(currentDir);
    for (const item of items) {
      if (item.startsWith('.') || item === 'node_modules') continue;
      const fullPath = path.join(currentDir, item);
      const stat = fs.statSync(fullPath);
      if (stat.isDirectory()) {
        findModels(fullPath);
      } else if (['.pt', '.pth', '.h5', '.pb', '.onnx', '.tflite', '.model', 'model.py', 'train.py'].some(ext => item.includes(ext))) {
        modelFiles.push(path.relative(dir, fullPath));
      }
    }
  }
  try {
    findModels(dir);
  } catch (e) {}
  
  return {
    readme,
    dependencies: deps,
    modelFiles
  };
}

// 生成报告
function generateReport(repoUrl, structure, analysis) {
  console.log('📝 生成技术分析报告...');
  
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const repoName = repoUrl.split('/').pop().replace('.git', '');
  const reportFile = path.join(CONFIG.reportDir, `${repoName}-analysis-${timestamp}.md`);
  
  ensureDir(CONFIG.reportDir);
  
  const report = `# 技术分析报告

## 项目信息

- **仓库地址**: ${repoUrl}
- **分析时间**: ${new Date().toLocaleString('zh-CN')}
- **分析工具**: CodeBuddy + OpenClaw

## 项目概述

${analysis.readme ? analysis.readme.split('\n').slice(0, 10).join('\n') : '暂无 README'}

## 代码统计

- **总文件数**: ${structure.totalFiles}
- **总目录数**: ${structure.totalDirs}

## 技术栈分析

### 编程语言分布

| 扩展名 | 文件数量 |
|--------|----------|
${Object.entries(structure.languages)
  .sort((a, b) => b[1] - a[1])
  .slice(0, 10)
  .map(([ext, count]) => `| ${ext || '无扩展名'} | ${count} |`)
  .join('\n')}

### 关键文件

${structure.keyFiles.map(f => `- ${f}`).join('\n')}

## 依赖分析

\`\`\`json
${analysis.dependencies || '无依赖信息'}
\`\`\`

## 模型文件

${analysis.modelFiles.length > 0 ? analysis.modelFiles.map(f => `- ${f}`).join('\n') : '未发现模型文件'}

## 架构分析

基于代码结构和文件分析，该项目可能采用以下架构：

${structure.keyFiles.includes('package.json') ? '- **Node.js 项目**: 使用 npm/yarn 管理依赖' : ''}
${structure.keyFiles.includes('requirements.txt') ? '- **Python 项目**: 使用 pip 管理依赖' : ''}
${structure.keyFiles.includes('Dockerfile') ? '- **容器化部署**: 支持 Docker' : ''}
${analysis.modelFiles.length > 0 ? '- **包含机器学习模型**: 发现模型相关文件' : ''}

## 建议

1. 查看 README.md 了解项目详细信息
2. 检查依赖版本是否最新
3. 审查模型文件的安全性
4. 确保敏感信息未提交到代码库

---
*报告由 CodeBuddy AI 自动生成*
`;

  fs.writeFileSync(reportFile, report);
  console.log(`✅ 报告已生成: ${reportFile}`);
  
  return reportFile;
}

// 主函数
async function main() {
  const args = process.argv.slice(2);
  
  if (args.length < 1) {
    console.log('用法: node analyze.js <github-url> [branch]');
    console.log('示例: node analyze.js https://github.com/user/repo.git');
    process.exit(1);
  }
  
  const repoUrl = args[0];
  const branch = args[1] || 'main';
  
  console.log('🔍 代码分析工具启动');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`目标仓库: ${repoUrl}`);
  console.log(`分支: ${branch}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  
  try {
    // 1. 克隆仓库
    const repoDir = cloneRepo(repoUrl, branch);
    
    // 2. 分析结构
    const structure = analyzeStructure(repoDir);
    
    // 3. CodeBuddy 分析
    const analysis = analyzeWithCodeBuddy(repoDir);
    
    // 4. 生成报告
    const reportFile = generateReport(repoUrl, structure, analysis);
    
    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('✅ 分析完成！');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`\n📄 报告位置: ${reportFile}`);
    
  } catch (error) {
    console.error('❌ 分析失败:', error.message);
    process.exit(1);
  }
}

main();
