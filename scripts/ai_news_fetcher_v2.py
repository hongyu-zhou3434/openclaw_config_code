#!/usr/bin/env python3
"""
AI新闻获取器 V2 - 增强版
支持多数据源、智能分类、内容摘要
"""

import json
import urllib.request
import urllib.parse
import ssl
import sys
import os
from datetime import datetime, timedelta
import hashlib
from collections import defaultdict

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
    'douyin': 'https://60s.viki.moe/v2/douyin',
}

# 数据源emoji
SOURCE_EMOJI = {
    'weibo': '🔥',
    'zhihu': '💡',
    'baidu': '🔍',
    'bilibili': '📺',
    'toutiao': '📰',
    'douyin': '🎵',
}

# AI相关关键词分类
AI_CATEGORIES = {
    '大模型': ['大模型', 'LLM', 'ChatGPT', 'GPT-4', 'GPT-5', 'Claude', 'Gemini', '文心一言', '通义千问', '豆包', '混元', '盘古', 'MiLM', 'ChatGLM', 'GLM', 'abab'],
    '多模态': ['多模态', 'Sora', 'DALL-E', 'Midjourney', '视频生成', '图像生成', '语音合成'],
    '算力芯片': ['GPU', '芯片', '算力', 'NVIDIA', '英伟达', '昇腾', '半导体', '黄仁勋'],
    '智能体': ['Agent', '智能体', 'AI Agent', 'AutoGPT', 'Copilot'],
    '机器人': ['机器人', 'Robot', '宇树', '波士顿动力', '特斯拉机器人', 'Optimus'],
    '自动驾驶': ['自动驾驶', '无人驾驶', 'FSD', '特斯拉自动驾驶', '百度Apollo'],
}

# 公司关键词映射（扩展版）
COMPANY_KEYWORDS = {
    'OpenAI': ['OpenAI', 'ChatGPT', 'GPT-4', 'GPT-5', 'DALL-E', 'Sora', 'Sam Altman', '奥特曼'],
    'Google': ['Google', '谷歌', 'Gemini', 'Bard', 'DeepMind', 'Alphabet', '皮查伊'],
    'Meta': ['Meta', 'Facebook', 'Llama', '扎克伯格', '元宇宙', 'Meta AI'],
    'NVIDIA': ['NVIDIA', '英伟达', '黄仁勋', 'GPU', '显卡', '算力', 'H100', 'A100', 'RTX'],
    'Microsoft': ['Microsoft', '微软', 'Copilot', 'Azure', 'OpenAI', '纳德拉', 'Windows AI'],
    'Anthropic': ['Anthropic', 'Claude', 'Claude 3', 'Claude 4'],
    '阿里巴巴': ['阿里', 'Alibaba', '通义千问', 'Qwen', '达摩院', '阿里云', '张勇', '吴泳铭'],
    '字节跳动': ['字节', 'ByteDance', '豆包', '云雀', '抖音', 'TikTok', '剪映', 'CapCut'],
    '腾讯': ['腾讯', 'Tencent', '混元', '元宝', '微信AI', 'QQ AI', '马化腾'],
    'DeepSeek': ['DeepSeek', '深度求索', 'DeepSeek-V3', 'DeepSeek-R1'],
    '智谱AI': ['智谱', 'ChatGLM', 'GLM', '智源', '智谱AI', 'GLM-4'],
    'MiniMax': ['MiniMax', 'abab', '海螺AI', 'MiniMax-01'],
    '百度': ['百度', 'Baidu', '文心一言', 'ERNIE', '飞桨', 'Paddle', '李彦宏'],
    '华为': ['华为', 'Huawei', '盘古', '昇腾', 'MindSpore', '鸿蒙', '任正非', '余承东'],
    '小米': ['小米', 'Xiaomi', 'MiLM', '小爱同学', '雷军', 'SU7'],
}

def fetch_api(url, timeout=15):
    """获取API数据"""
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        req = urllib.request.Request(url, headers=headers)
        
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        
        with urllib.request.urlopen(req, context=ctx, timeout=timeout) as response:
            return json.loads(response.read().decode('utf-8'))
    except Exception as e:
        return {'error': str(e)}

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

def is_ai_related(title):
    """判断标题是否与AI相关"""
    title_lower = title.lower()
    all_keywords = []
    for keywords in AI_CATEGORIES.values():
        all_keywords.extend(keywords)
    all_keywords.extend(['AI', '人工智能', '科技', '发布会', '新品'])
    
    return any(kw.lower() in title_lower for kw in all_keywords)

def is_company_related(title, company):
    """判断标题是否与特定公司相关"""
    if company not in COMPANY_KEYWORDS:
        return False
    keywords = COMPANY_KEYWORDS[company]
    title_lower = title.lower()
    return any(kw.lower() in title_lower for kw in keywords)

def format_hot_value(hot):
    """格式化热度值"""
    if hot >= 100000000:
        return f"{hot/100000000:.1f}亿"
    elif hot >= 10000:
        return f"{hot/10000:.1f}万"
    elif hot > 0:
        return str(hot)
    return ""

def generate_summary(title, hot_value=0):
    """根据标题生成深度AI分析"""
    import subprocess
    try:
        result = subprocess.run(
            ['python3', '/root/.openclaw/workspace/scripts/ai_news_analyzer.py', title, str(hot_value)],
            capture_output=True, text=True, timeout=10
        )
        if result.returncode == 0:
            return result.stdout.strip()
    except Exception as e:
        pass
    
    # 备用简单摘要
    return 'AI技术持续演进，产业应用不断深化。'

def format_item(item, with_summary=False):
    """格式化单个条目"""
    title = item.get('title', '')
    link = item.get('link', '')
    hot = item.get('hot_value', 0)
    source = item.get('source', 'unknown')
    
    source_emoji = SOURCE_EMOJI.get(source, '📌')
    hot_str = format_hot_value(hot)
    hot_display = f" {hot_str}" if hot_str else ""
    
    if with_summary:
        summary = generate_summary(title, hot)
        # 将摘要中的换行转换为Markdown列表格式
        summary_formatted = summary.replace('\n', '\n> ')
        return f"**[{title}]({link})** {source_emoji}{hot_display}\n\n> {summary_formatted}"
    else:
        return f"- [{title}]({link}) {source_emoji}{hot_display}"

def fetch_media_articles():
    """获取专业AI媒体文章"""
    import subprocess
    try:
        result = subprocess.run(
            ['python3', '/root/.openclaw/workspace/scripts/ai_media_fetcher.py'],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode == 0:
            return result.stdout.strip()
    except:
        pass
    return None

def get_top_ai_news(limit=10, with_summary=False):
    """获取热门AI新闻"""
    items = fetch_all_sources()
    
    # 筛选AI相关内容
    ai_items = [item for item in items if is_ai_related(item.get('title', ''))]
    
    # 去重
    seen = set()
    unique_items = []
    for item in ai_items:
        title = item.get('title', '')
        if title and title not in seen:
            seen.add(title)
            unique_items.append(item)
    
    # 按热度排序
    unique_items.sort(key=lambda x: x.get('hot_value', 0), reverse=True)
    
    return unique_items[:limit]

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

def main():
    if len(sys.argv) < 2:
        print("Usage: ai_news_fetcher_v2.py <command> [args]", file=sys.stderr)
        print("Commands:", file=sys.stderr)
        print("  general              # 获取通用AI新闻", file=sys.stderr)
        print("  company <name>       # 获取特定公司新闻", file=sys.stderr)
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == 'general':
        items = get_top_ai_news(10)
        if items:
            print("### 今日AI热点 TOP10")
            print("")
            for item in items:
                print(format_item(item, with_summary=True))
                print("")
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
