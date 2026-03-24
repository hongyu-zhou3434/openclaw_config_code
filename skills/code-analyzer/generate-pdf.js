#!/usr/bin/env node
/**
 * 将 Markdown 报告转换为 PDF
 * 使用 Puppeteer 生成高质量 PDF
 */

const fs = require('fs');
const path = require('path');

// 简单的 HTML 模板
function createHTML(content, title) {
  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>${title}</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 900px;
      margin: 0 auto;
      padding: 20px;
    }
    h1 {
      color: #2c3e50;
      border-bottom: 2px solid #3498db;
      padding-bottom: 10px;
    }
    h2 {
      color: #34495e;
      border-bottom: 1px solid #bdc3c7;
      padding-bottom: 8px;
      margin-top: 30px;
    }
    h3 {
      color: #555;
    }
    table {
      border-collapse: collapse;
      width: 100%;
      margin: 20px 0;
    }
    th, td {
      border: 1px solid #ddd;
      padding: 12px;
      text-align: left;
    }
    th {
      background-color: #3498db;
      color: white;
    }
    tr:nth-child(even) {
      background-color: #f2f2f2;
    }
    code {
      background-color: #f4f4f4;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: "Consolas", "Monaco", monospace;
    }
    pre {
      background-color: #f4f4f4;
      padding: 15px;
      border-radius: 5px;
      overflow-x: auto;
    }
    blockquote {
      border-left: 4px solid #3498db;
      margin: 0;
      padding-left: 20px;
      color: #666;
    }
    hr {
      border: none;
      border-top: 1px solid #ddd;
      margin: 30px 0;
    }
    .header {
      text-align: center;
      margin-bottom: 40px;
      padding-bottom: 20px;
      border-bottom: 3px solid #3498db;
    }
    .footer {
      margin-top: 50px;
      padding-top: 20px;
      border-top: 1px solid #ddd;
      text-align: center;
      color: #999;
      font-size: 12px;
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>${title}</h1>
    <p>生成时间: ${new Date().toLocaleString('zh-CN')}</p>
  </div>
  
  ${markdownToHTML(content)}
  
  <div class="footer">
    <p>由 OpenClaw CodeBuddy 代码分析工具生成</p>
    <p>© 2026 OpenClaw</p>
  </div>
</body>
</html>
  `;
}

// 简单的 Markdown 转 HTML
function markdownToHTML(markdown) {
  let html = markdown
    // 转义 HTML 特殊字符
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    
    // 代码块
    .replace(/```(\w+)?\n([\s\S]*?)```/g, '<pre><code>$2</code></pre>')
    
    // 行内代码
    .replace(/`([^`]+)`/g, '<code>$1</code>')
    
    // 标题
    .replace(/^### (.*$)/gim, '<h3>$1</h3>')
    .replace(/^## (.*$)/gim, '<h2>$1</h2>')
    .replace(/^# (.*$)/gim, '<h1>$1</h1>')
    
    // 粗体和斜体
    .replace(/\*\*\*(.*?)\*\*\*/g, '<strong><em>$1</em></strong>')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    
    // 链接
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>')
    
    // 图片
    .replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img alt="$1" src="$2">')
    
    // 引用
    .replace(/^> (.*$)/gim, '<blockquote>$1</blockquote>')
    
    // 无序列表
    .replace(/^\s*[-*+] (.*$)/gim, '<li>$1</li>')
    .replace(/(<li>.*<\/li>\n)+/g, '<ul>$&</ul>')
    .replace(/<\/ul>\n<ul>/g, '')
    
    // 有序列表
    .replace(/^\s*\d+\. (.*$)/gim, '<li>$1</li>')
    
    // 水平线
    .replace(/^---+$/gim, '<hr>')
    
    // 段落
    .replace(/\n\n/g, '</p><p>')
    .replace(/^(.+)$/gim, '<p>$1</p>')
    
    // 清理空段落
    .replace(/<p><\/p>/g, '')
    .replace(/<p>(<h[1-6]>)/g, '$1')
    .replace(/(<\/h[1-6]>)<\/p>/g, '$1')
    .replace(/<p>(<table>)/g, '$1')
    .replace(/(<\/table>)<\/p>/g, '$1')
    .replace(/<p>(<ul>)/g, '$1')
    .replace(/(<\/ul>)<\/p>/g, '$1')
    .replace(/<p>(<pre>)/g, '$1')
    .replace(/(<\/pre>)<\/p>/g, '$1')
    .replace(/<p>(<blockquote>)/g, '$1')
    .replace(/(<\/blockquote>)<\/p>/g, '$1');
  
  return html;
}

// 主函数
async function main() {
  const args = process.argv.slice(2);
  
  if (args.length < 1) {
    console.log('用法: node generate-pdf.js <markdown文件> [输出pdf文件]');
    console.log('示例: node generate-pdf.js report.md report.pdf');
    process.exit(1);
  }
  
  const markdownFile = args[0];
  const outputFile = args[1] || markdownFile.replace('.md', '.pdf');
  
  if (!fs.existsSync(markdownFile)) {
    console.error(`❌ 文件不存在: ${markdownFile}`);
    process.exit(1);
  }
  
  console.log('📄 读取 Markdown 文件...');
  const markdown = fs.readFileSync(markdownFile, 'utf8');
  const title = path.basename(markdownFile, '.md');
  
  console.log('🎨 转换为 HTML...');
  const html = createHTML(markdown, title);
  
  // 保存 HTML 文件（用于调试）
  const htmlFile = outputFile.replace('.pdf', '.html');
  fs.writeFileSync(htmlFile, html);
  console.log(`💾 HTML 已保存: ${htmlFile}`);
  
  // 检查是否有 puppeteer
  try {
    const puppeteer = require('puppeteer');
    
    console.log('🚀 启动浏览器生成 PDF...');
    const browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    
    const page = await browser.newPage();
    await page.setContent(html, { waitUntil: 'networkidle0' });
    
    console.log('📄 生成 PDF...');
    await page.pdf({
      path: outputFile,
      format: 'A4',
      printBackground: true,
      margin: {
        top: '20mm',
        right: '20mm',
        bottom: '20mm',
        left: '20mm'
      }
    });
    
    await browser.close();
    
    console.log('✅ PDF 生成成功！');
    console.log(`📁 输出文件: ${outputFile}`);
    
  } catch (error) {
    console.log('⚠️  Puppeteer 未安装，仅生成 HTML 文件');
    console.log('💡 要生成 PDF，请运行: npm install puppeteer');
    console.log(`📁 HTML 文件: ${htmlFile}`);
    console.log('💡 您可以使用浏览器打开 HTML 文件并打印为 PDF');
  }
}

main().catch(console.error);
