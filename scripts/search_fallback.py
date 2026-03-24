#!/usr/bin/env python3
"""
搜索回退工具 - Tavily失败时回退到DuckDuckGo
"""

import sys
import subprocess
import json
import re
import urllib.request
import urllib.parse
import ssl

def search_tavily(query):
    """使用Tavily搜索"""
    try:
        result = subprocess.run(
            ['node', '/root/.openclaw/workspace/skills/tavily-search/scripts/search.mjs', query],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            output = result.stdout.strip()
            # 检查结果是否有效（不是错误信息）
            if output and 'exceeds your plan' not in output and 'Error:' not in output:
                return {'success': True, 'source': 'tavily', 'results': output}
        
        # Tavily失败
        return {'success': False, 'error': result.stderr or result.stdout}
    except Exception as e:
        return {'success': False, 'error': str(e)}

def search_duckduckgo(query):
    """使用DuckDuckGo Lite搜索"""
    try:
        # 构建URL
        encoded_query = urllib.parse.quote_plus(query)
        url = f"https://lite.duckduckgo.com/lite/?q={encoded_query}"
        
        # 创建请求
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        
        req = urllib.request.Request(url, headers=headers)
        
        with urllib.request.urlopen(req, context=ctx, timeout=15) as response:
            html = response.read().decode('utf-8', errors='ignore')
        
        # 解析结果
        results = []
        
        # 尝试提取结果链接和标题
        # DuckDuckGo Lite 的结果在 class="result-link" 的 <a> 标签中
        link_pattern = r'<a[^>]*class="result-link"[^>]*href="([^"]+)"[^>]*>([^<]*)</a>'
        links = re.findall(link_pattern, html, re.IGNORECASE)
        
        for url, title in links[:5]:
            if url and not url.startswith('javascript:'):
                # 处理相对URL
                if url.startswith('//'):
                    url = 'https:' + url
                elif url.startswith('/'):
                    url = 'https://lite.duckduckgo.com' + url
                results.append(f"- [{title or 'Link'}]({url})")
        
        # 如果没找到结果，尝试其他模式
        if not results:
            # 尝试提取任何链接
            all_links = re.findall(r'href="(https?://[^"]+)"[^>]*>([^<]{10,})</a>', html)
            for url, title in all_links[:5]:
                if 'duckduckgo.com' not in url and 'javascript:' not in url:
                    results.append(f"- [{title.strip()}]({url})")
        
        if results:
            return {'success': True, 'source': 'duckduckgo', 'results': '\n'.join(results)}
        else:
            return {'success': False, 'error': 'No results found in DDG response'}
            
    except Exception as e:
        return {'success': False, 'error': str(e)}

def main():
    if len(sys.argv) < 2:
        print("Usage: search_fallback.py <query>", file=sys.stderr)
        sys.exit(1)
    
    query = ' '.join(sys.argv[1:])
    
    # 首先尝试Tavily
    tavily_result = search_tavily(query)
    
    if tavily_result['success']:
        print(tavily_result['results'])
        sys.exit(0)
    
    # Tavily失败，回退到DuckDuckGo
    print(f"<!-- Tavily failed: {tavily_result.get('error', 'Unknown error')} -->", file=sys.stderr)
    print("<!-- Falling back to DuckDuckGo... -->", file=sys.stderr)
    
    ddg_result = search_duckduckgo(query)
    
    if ddg_result['success']:
        print(ddg_result['results'])
        sys.exit(0)
    else:
        print(f"<!-- DuckDuckGo also failed: {ddg_result.get('error', 'Unknown error')} -->", file=sys.stderr)
        print("暂无相关数据")
        sys.exit(1)

if __name__ == '__main__':
    main()
