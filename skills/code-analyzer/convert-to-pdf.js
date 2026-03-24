#!/usr/bin/env node
/**
 * 使用 wps-skill 将 Markdown 转换为 PDF
 * 统一使用系统配置的 PDF 生成策略
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// 配置
const CONFIG = {
  wpsSkillPath: '/root/.openclaw/workspace/skills/wps-skill',
  defaultOutputDir: '/root/.openclaw/workspace/skills/code-analyzer/reports'
};

// 确保目录存在
function ensureDir(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

// 使用 wps-skill 转换 Markdown 到 PDF
function convertWithWPS(markdownFile, outputFile) {
  console.log('🔄 使用 wps-skill 转换 Markdown 到 PDF...');
  
  // 检查 wps-skill 是否存在
  const wpsConvertScript = path.join(CONFIG.wpsSkillPath, 'convert.js');
  if (!fs.existsSync(wpsConvertScript)) {
    console.log('⚠️  wps-skill 转换脚本不存在，尝试备用方案...');
    return convertWithPandoc(markdownFile, outputFile);
  }
  
  try {
    // 调用 wps-skill 进行转换
    const cmd = `node "${wpsConvertScript}" --input "${markdownFile}" --output "${outputFile}" --format pdf`;
    execSync(cmd, { stdio: 'inherit', timeout: 60000 });
    console.log('✅ WPS 转换成功！');
    return true;
  } catch (error) {
    console.log('⚠️  WPS 转换失败，尝试备用方案...');
    return convertWithPandoc(markdownFile, outputFile);
  }
}

// 备用方案：使用 pandoc
function convertWithPandoc(markdownFile, outputFile) {
  console.log('🔄 使用 pandoc 转换...');
  
  try {
    const cmd = `pandoc "${markdownFile}" -o "${outputFile}" --pdf-engine=xelatex -V CJKmainfont="Noto Sans CJK SC"`;
    execSync(cmd, { stdio: 'inherit', timeout: 60000 });
    console.log('✅ Pandoc 转换成功！');
    return true;
  } catch (error) {
    console.log('❌ Pandoc 转换失败');
    return false;
  }
}

// 主函数
function main() {
  const args = process.argv.slice(2);
  
  if (args.length < 1) {
    console.log('用法: node convert-to-pdf.js <markdown文件> [输出pdf文件]');
    console.log('示例: node convert-to-pdf.js report.md report.pdf');
    process.exit(1);
  }
  
  const markdownFile = path.resolve(args[0]);
  const outputFile = args[1] 
    ? path.resolve(args[1]) 
    : markdownFile.replace('.md', '.pdf');
  
  // 检查输入文件
  if (!fs.existsSync(markdownFile)) {
    console.error(`❌ 文件不存在: ${markdownFile}`);
    process.exit(1);
  }
  
  // 确保输出目录存在
  ensureDir(path.dirname(outputFile));
  
  console.log('');
  console.log('╔════════════════════════════════════════════════════════════╗');
  console.log('║         Markdown 转 PDF (使用 wps-skill)                    ║');
  console.log('╚════════════════════════════════════════════════════════════╝');
  console.log('');
  console.log(`📄 输入文件: ${markdownFile}`);
  console.log(`📄 输出文件: ${outputFile}`);
  console.log('');
  
  // 执行转换
  const success = convertWithWPS(markdownFile, outputFile);
  
  console.log('');
  if (success) {
    console.log('✅ PDF 生成成功！');
    console.log(`📁 文件位置: ${outputFile}`);
  } else {
    console.log('❌ PDF 生成失败');
    console.log('💡 请检查 wps-skill 是否已安装');
    process.exit(1);
  }
  console.log('');
}

main();
