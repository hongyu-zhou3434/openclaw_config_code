#!/usr/bin/env python3
"""
AI新闻获取器 - 整合多个国内数据源
支持：微博热搜、知乎热榜、百度热搜、B站热门、今日头条
"""

import json
import urllib.request
import urllib.parse
import ssl
import sys
import os
from datetime import datetime, timedelta
import hashlib

# 禁用SSL验证
ssl._create_default_context = ssl._create_unverified_context

# 缓存目录
CACHE_DIR = "/root/.openclaw/workspace/cache/ai-news"
os.makedirs(CACHE_DIR, exist_ok=True)

# API配置
APIS = {
    'weibo': 'https://60s.viki.moe/v2/weibo',
    'zhihu': 'https://60s.viki.moe/v2/zhihu',
    'baidu': 'https://60s.viki.moe/v2/baidu/hot',
    'bilibili': 'https://60s.viki.moe/v2/bili',
    'toutiao': 'https://60s.viki.moe/v2/toutiao',
}

# AI相关关键词
AI_KEYWORDS = [
    'AI', '人工智能', '大模型', 'ChatGPT', 'OpenAI', 'Claude', 'Gemini',
    '百度', '文心一言', 'ERNIE', '腾讯', '混元', '阿里', '通义千问', 'Qwen',
    '字节', '豆包', '云雀', '华为', '盘古', '小米', 'MiLM',
    'DeepSeek', '智谱', 'ChatGLM', 'GLM', 'MiniMax', 'abab',
    'NVIDIA', '英伟达', 'GPU', '算力', '芯片', '半导体',
    '机器人', '自动驾驶', '智能体', 'Agent', '多模态',
    '科技', '发布会', '新品', '模型', '训练', '推理'
]

# 公司关键词映射
COMPANY_KEYWORDS = {
    'OpenAI': ['OpenAI', 'ChatGPT', 'GPT-4', 'GPT-5', 'DALL-E', 'Sora'],
    'Google': ['Google', '谷歌', 'Gemini', 'Bard', 'DeepMind', 'Alphabet'],
    'Meta': ['Meta', 'Facebook', 'Llama', '扎克伯格'],
    'NVIDIA': ['NVIDIA', '英伟达', '黄仁勋', 'GPU', '显卡', '算力'],
    'Microsoft': ['Microsoft', '微软', 'Copilot', 'Azure', 'OpenAI'],
    'Anthropic': ['Anthropic', 'Claude'],
    '阿里巴巴': ['阿里', 'Alibaba', '通义千问', 'Qwen', '达摩院', '阿里云'],
    '字节跳动': ['字节', 'ByteDance', '豆包', '云雀', '抖音', 'TikTok'],
    '腾讯': ['腾讯', 'Tencent', '混元', '元宝', '微信AI'],
    'DeepSeek': ['DeepSeek', '深度求索'],
    '智谱AI': ['智谱', 'ChatGLM', 'GLM', '智源'],
    'MiniMax': ['MiniMax', 'abab'],
    '百度': ['百度', 'Baidu', '文心一言', 'ERNIE', '飞桨'],
    '华为': ['华为', 'Huawei', '盘古', '昇腾', 'MindSpore'],
}

def get_cache_path(api_name, query=""):
    """获取缓存文件路径"""
    date_str = datetime.now().strftime('%Y%m%d')
    query_hash = hashlib.md5(query.encode()).hexdigest()[:8] if query else "general"
    return os.path.join(CACHE_DIR, f"{api_name}_{date_str}_{query_hash}.json")

def fetch_api(url, timeout=15, use_cache=True):
    """获取API数据，支持缓存"""
    cache_path = get_cache_path(url.split('/')[-1].split('?')[0])
    
    # 检查缓存
    if use_cache and os.path.exists(cache_path):
        cache_time = datetime.fromtimestamp(os.path.getmtime(cache_path))
        if datetime.now() - cache_time < timedelta(hours=1):  # 缓存1小时
            try:
                with open(cache_path, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except:
                pass
    
    # 从网络获取
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        req = urllib.request.Request(url, headers=headers)
        
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        
        with urllib.request.urlopen(req, context=ctx, timeout=timeout) as response:
            data = json.loads(response.read().decode('utf-8'))
            
            # 保存缓存
            if use_cache:
                try:
                    with open(cache_path, 'w', encoding='utf-8') as f:
                        json.dump(data, f, ensure_ascii=False)
                except:
                    pass
            
            return data
    except Exception as e:
        return {'error': str(e)}

def is_ai_related(title):
    """判断标题是否与AI相关"""
    title_lower = title.lower()
    return any(kw.lower() in title_lower for kw in AI_KEYWORDS)

def is_company_related(title, company):
    """判断标题是否与特定公司相关"""
    if company not in COMPANY_KEYWORDS:
        return False
    keywords = COMPANY_KEYWORDS[company]
    title_lower = title.lower()
    return any(kw.lower() in title_lower for kw in keywords)

def fetch_all_sources():
    """从所有数据源获取数据"""
    all_items = []
    
    for name, url in APIS.items():
        data = fetch_api(url)
        if data.get('code') == 200:
            items = data.get('data', [])
            for item in items:
                item['source'] = name
            all_items.extend(items)
    
    return all_items

def get_ai_news_general():
    """获取通用AI新闻"""
    items = fetch_all_sources()
    
    # 筛选AI相关内容
    ai_items = [item for item in items if is_ai_related(item.get('title', ''))]
    
    # 去重（基于标题）
    seen = set()
    unique_items = []
    for item in ai_items:
        title = item.get('title', '')
        if title and title not in seen:
            seen.add(title)
            unique_items.append(item)
    
    # 按热度排序
    unique_items.sort(key=lambda x: x.get('hot_value', 0), reverse=True)
    
    return unique_items[:10]

def get_company_news(company):
    """获取特定公司的新闻"""
    items = fetch_all_sources()
    
    # 筛选公司相关内容
    company_items = [item for item in items if is_company_related(item.get('title', ''), company)]
    
    # 去重
    seen = set()
    unique_items = []
    for item in company_items:
        title = item.get('title', '')
        if title and title not in seen:
            seen.add(title)
            unique_items.append(item)
    
    # 按热度排序
    unique_items.sort(key=lambda x: x.get('hot_value', 0), reverse=True)
    
    return unique_items[:5]

def format_item(item):
    """格式化单个条目"""
    title = item.get('title', '')
    link = item.get('link', '')
    hot = item.get('hot_value', 0)
    source = item.get('source', 'unknown')
    
    source_emoji = {
        'weibo': '🔥',
        'zhihu': '💡',
        'baidu': '🔍',
        'bilibili': '📺',
        'toutiao': '📰'
    }.get(source, '📌')
    
    hot_str = f" {hot/10000:.1f}万" if hot > 10000 else f" {hot}" if hot > 0 else ""
    
    return f"- [{title}]({link}) {source_emoji}{hot_str}"

def main():
    if len(sys.argv) < 2:
        print("Usage: ai_news_fetcher.py <command> [args]", file=sys.stderr)
        print("Commands:", file=sys.stderr)
        print("  general              # 获取通用AI新闻", file=sys.stderr)
        print("  company <name>       # 获取特定公司新闻", file=sys.stderr)
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == 'general':
        items = get_ai_news_general()
        if items:
            print("### 今日AI热点")
            for item in items:
                print(format_item(item))
        else:
            print("*暂无AI相关热搜数据*")
    
    elif command == 'company':
        if len(sys.argv) < 3:
            print("Error: Company name required", file=sys.stderr)
            sys.exit(1)
        
        company = sys.argv[2]
        items = get_company_news(company)
        
        if items:
            print(f"### {company} 相关动态")
            for item in items:
                print(format_item(item))
        else:
            print(f"*{company} 暂无相关热搜*")
    
    else:
        print(f"Unknown command: {command}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
