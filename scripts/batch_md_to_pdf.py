#!/usr/bin/env python3
"""
批量Markdown转PDF工具 - 带实时进度输出
"""

import markdown
from weasyprint import HTML, CSS
import os
import sys
import argparse
from datetime import datetime

# 定义CSS样式
css_style = '''
@page {
    size: A4;
    margin: 2cm;
}
body {
    font-family: "Noto Sans CJK SC", "WenQuanYi Micro Hei", "SimHei", sans-serif;
    font-size: 11pt;
    line-height: 1.6;
}
h1 {
    font-size: 20pt;
    color: #1a1a1a;
    border-bottom: 2px solid #333;
    padding-bottom: 10px;
}
h2 {
    font-size: 16pt;
    color: #333;
    border-bottom: 1px solid #ccc;
    padding-bottom: 5px;
}
h3 {
    font-size: 13pt;
    color: #444;
}
table {
    border-collapse: collapse;
    width: 100%;
    margin: 15px 0;
}
th, td {
    border: 1px solid #ddd;
    padding: 8px;
    text-align: left;
}
th {
    background-color: #f2f2f2;
    font-weight: bold;
}
code {
    background-color: #f4f4f4;
    padding: 2px 6px;
    border-radius: 3px;
    font-family: monospace;
}
pre {
    background-color: #f4f4f4;
    padding: 10px;
    border-radius: 5px;
    overflow-x: auto;
}
hr {
    border: none;
    border-top: 1px solid #ddd;
    margin: 20px 0;
}
'''

def convert_md_to_pdf(md_file, output_dir=None):
    """转换单个Markdown文件为PDF"""
    if output_dir:
        pdf_file = os.path.join(output_dir, os.path.basename(md_file).replace('.md', '.pdf'))
    else:
        pdf_file = md_file.replace('.md', '.pdf')
    
    # 读取Markdown文件
    with open(md_file, 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    # 转换为HTML
    html_content = markdown.markdown(md_content, extensions=['tables', 'fenced_code'])
    
    # 包装成完整HTML
    full_html = f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{os.path.basename(md_file).replace(".md", "")}</title>
</head>
<body>{html_content}</body>
</html>'''
    
    # 转换为PDF
    HTML(string=full_html).write_pdf(pdf_file, stylesheets=[CSS(string=css_style)])
    
    return pdf_file

def batch_convert(files, output_dir=None):
    """批量转换，带实时进度输出"""
    total = len(files)
    success = 0
    failed = 0
    results = []
    
    print(f"\n{'='*60}")
    print(f"📄 Markdown转PDF批量转换")
    print(f"{'='*60}")
    print(f"总文件数: {total}")
    print(f"开始时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*60}\n")
    
    for i, md_file in enumerate(files, 1):
        filename = os.path.basename(md_file)
        print(f"[{i}/{total}] 正在转换: {filename}...", end=" ", flush=True)
        
        if not os.path.exists(md_file):
            print(f"❌ 文件不存在")
            failed += 1
            results.append((filename, "失败", "文件不存在"))
            continue
        
        try:
            pdf_file = convert_md_to_pdf(md_file, output_dir)
            size_kb = os.path.getsize(pdf_file) // 1024
            print(f"✅ 完成 ({size_kb}KB)")
            success += 1
            results.append((filename, "成功", f"{size_kb}KB"))
        except Exception as e:
            print(f"❌ 失败 ({str(e)[:50]})")
            failed += 1
            results.append((filename, "失败", str(e)[:50]))
    
    # 输出汇总
    print(f"\n{'='*60}")
    print(f"📊 转换完成汇总")
    print(f"{'='*60}")
    print(f"成功: {success}/{total}")
    print(f"失败: {failed}/{total}")
    print(f"结束时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*60}\n")
    
    # 详细结果表
    print("详细结果:")
    print(f"{'文件名':<40} {'状态':<8} {'大小/错误':<20}")
    print("-" * 70)
    for filename, status, info in results:
        print(f"{filename:<40} {status:<8} {info:<20}")
    
    return success, failed, results

def main():
    parser = argparse.ArgumentParser(description='批量Markdown转PDF')
    parser.add_argument('files', nargs='+', help='Markdown文件列表')
    parser.add_argument('--output-dir', '-o', help='输出目录')
    args = parser.parse_args()
    
    success, failed, _ = batch_convert(args.files, args.output_dir)
    
    # 返回状态码
    sys.exit(0 if failed == 0 else 1)

if __name__ == '__main__':
    main()
