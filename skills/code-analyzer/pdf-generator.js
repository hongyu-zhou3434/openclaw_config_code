#!/usr/bin/env node
/**
 * 可靠的 PDF 生成器
 * 支持多种生成方式，自动降级
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const https = require('https');

// 配置
const CONFIG = {
  outputDir: '/root/.openclaw/workspace/skills/code-analyzer/reports',
  tempDir: '/tmp'
};

// 确保目录存在
function ensureDir(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

// 检查命令是否存在
function commandExists(cmd) {
  try {
    execSync(`which ${cmd}`, { stdio: 'pipe' });
    return true;
  } catch {
    return false;
  }
}

// 方案 1：使用 pandoc + xelatex
function generateWithPandoc(inputFile, outputFile) {
  console.log('🔄 尝试使用 pandoc + xelatex...');
  
  if (!commandExists('xelatex')) {
    console.log('⚠️  xelatex 未安装');
    return false;
  }
  
  try {
    const cmd = `pandoc "${inputFile}" -o "${outputFile}" --pdf-engine=xelatex -V geometry:margin=2.5cm`;
    execSync(cmd, { stdio: 'inherit', timeout: 120000 });
    console.log('✅ pandoc + xelatex 生成成功！');
    return true;
  } catch (error) {
    console.log('❌ pandoc + xelatex 失败:', error.message);
    return false;
  }
}

// 方案 2：使用 wkhtmltopdf（修复版）
function generateWithWkhtmltopdf(inputFile, outputFile) {
  console.log('🔄 尝试使用 wkhtmltopdf...');
  
  if (!commandExists('wkhtmltopdf')) {
    console.log('⚠️  wkhtmltopdf 未安装');
    return false;
  }
  
  try {
    // 先转换为 HTML
    const htmlFile = inputFile.replace('.md', '.html');
    const pandocCmd = `pandoc "${inputFile}" -o "${htmlFile}" --standalone`;
    execSync(pandocCmd, { stdio: 'pipe', timeout: 30000 });
    
    // 使用 wkhtmltopdf 转换（启用本地文件访问）
    const wkCmd = `wkhtmltopdf --enable-local-file-access --page-size A4 --margin-top 20 --margin-bottom 20 --margin-left 20 --margin-right 20 "${htmlFile}" "${outputFile}"`;
    execSync(wkCmd, { stdio: 'inherit', timeout: 60000 });
    
    // 清理临时 HTML 文件
    fs.unlinkSync(htmlFile);
    
    console.log('✅ wkhtmltopdf 生成成功！');
    return true;
  } catch (error) {
    console.log('❌ wkhtmltopdf 失败:', error.message);
    return false;
  }
}

// 方案 3：使用 weasyprint
function generateWithWeasyprint(inputFile, outputFile) {
  console.log('🔄 尝试使用 weasyprint...');
  
  if (!commandExists('weasyprint')) {
    console.log('⚠️  weasyprint 未安装');
    return false;
  }
  
  try {
    const cmd = `weasyprint "${inputFile}" "${outputFile}"`;
    execSync(cmd, { stdio: 'inherit', timeout: 60000 });
    console.log('✅ weasyprint 生成成功！');
    return true;
  } catch (error) {
    console.log('❌ weasyprint 失败:', error.message);
    return false;
  }
}

// 方案 4：使用在线 API（备用）
function generateWithOnlineAPI(inputFile, outputFile) {
  console.log('🔄 尝试使用在线 API...');
  console.log('⚠️  在线 API 需要网络连接和 API key');
  return false;
}

// 主生成函数
function generatePDF(inputFile, outputFile) {
  console.log('');
  console.log('╔════════════════════════════════════════════════════════════╗');
  console.log('║              PDF 生成器（自动降级方案）                     ║');
  console.log('╚════════════════════════════════════════════════════════════╝');
  console.log('');
  console.log(`📄 输入: ${inputFile}`);
  console.log(`📄 输出: ${outputFile}`);
  console.log('');
  
  // 检查输入文件
  if (!fs.existsSync(inputFile)) {
    console.error(`❌ 输入文件不存在: ${inputFile}`);
    return false;
  }
  
  // 确保输出目录存在
  ensureDir(path.dirname(outputFile));
  
  // 尝试各种方案
  const strategies = [
    { name: 'pandoc+xelatex', fn: generateWithPandoc },
    { name: 'wkhtmltopdf', fn: generateWithWkhtmltopdf },
    { name: 'weasyprint', fn: generateWithWeasyprint },
    { name: 'online-api', fn: generateWithOnlineAPI }
  ];
  
  for (const strategy of strategies) {
    console.log(`\n📌 尝试方案: ${strategy.name}`);
    if (strategy.fn(inputFile, outputFile)) {
      console.log('\n✅ PDF 生成成功！');
      console.log(`📁 文件位置: ${outputFile}`);
      return true;
    }
  }
  
  console.log('\n❌ 所有方案均失败');
  console.log('💡 建议安装以下工具之一：');
  console.log('   1. texlive-xetex (推荐)');
  console.log('   2. weasyprint');
  console.log('   3. 配置 wps-skill PDF 功能');
  return false;
}

// 主函数
function main() {
  const args = process.argv.slice(2);
  
  if (args.length < 1) {
    console.log('用法: node pdf-generator.js <markdown文件> [输出pdf文件]');
    console.log('示例: node pdf-generator.js report.md report.pdf');
    process.exit(1);
  }
  
  const inputFile = path.resolve(args[0]);
  const outputFile = args[1] 
    ? path.resolve(args[1]) 
    : inputFile.replace('.md', '.pdf');
  
  const success = generatePDF(inputFile, outputFile);
  process.exit(success ? 0 : 1);
}

main();
