#!/usr/bin/env python3
"""
国内AI媒体资讯获取器
支持：量子位、机器之心、新智元等专业AI媒体
"""

import json
import urllib.request
import urllib.parse
import ssl
import sys
import os
import re
from datetime import datetime

# 禁用SSL验证
ssl._create_default_context = ssl._create_unverified_context

# 国内AI媒体配置
AI_MEDIA_SOURCES = {
    '量子位': {
        'url': 'https://www.qbitai.com/',
        'api': 'https://www.qbitai.com/wp-json/wp/v2/posts?per_page=10',
        'keywords': ['AI', '人工智能', '大模型', 'ChatGPT', 'OpenAI', '百度', '阿里', '腾讯', '字节', '华为'],
        'emoji': '⚛️'
    },
    '机器之心': {
        'url': 'https://www.jiqizhixin.com/',
        'api': 'https://www.jiqizhixin.com/api/articles?page=1&per_page=10',
        'keywords': ['AI', '人工智能', '深度学习', '机器学习', '神经网络', '论文', '算法'],
        'emoji': '🤖'
    },
    '新智元': {
        'url': 'https://www.aimark.cn/',
        'api': None,  # 需要网页抓取
        'keywords': ['AI', '人工智能', '大模型', 'AIGC', 'ChatGPT'],
        'emoji': '🧠'
    },
    '36氪AI': {
        'url': 'https://36kr.com/',
        'api': 'https://36kr.com/api/newsflash?per_page=20',
        'keywords': ['AI', '人工智能', '大模型', '融资', ' startup'],
        'emoji': '💼'
    },
    'InfoQ': {
        'url': 'https://www.infoq.cn/',
        'api': 'https://www.infoq.cn/public/v1/article/getList?size=20&type=1',
        'keywords': ['AI', '人工智能', '大模型', '架构', '技术'],
        'emoji': '📚'
    },
    '雷锋网AI': {
        'url': 'https://www.leiphone.com/',
        'api': 'https://www.leiphone.com/wp-json/wp/v2/posts?categories=11&per_page=10',
        'keywords': ['AI', '人工智能', '大模型', '自动驾驶', '机器人', '芯片'],
        'emoji': '🔋'
    },
    '智东西': {
        'url': 'https://www.zhidx.com/',
        'api': 'https://www.zhidx.com/wp-json/wp/v2/posts?categories=1&per_page=10',
        'keywords': ['AI', '人工智能', '芯片', '自动驾驶', '智能终端', '物联网'],
        'emoji': '💡'
    },
    'AI科技评论': {
        'url': 'https://www.jiqizhixin.com/column/AI-Research',
        'api': 'https://www.jiqizhixin.com/api/articles?category=AI-Research&per_page=10',
        'keywords': ['AI', '论文', '学术', '研究', '顶会', 'NeurIPS', 'ICML', 'CVPR'],
        'emoji': '🎓'
    },
    'AI前线': {
        'url': 'https://www.infoq.cn/topic/AI',
        'api': 'https://www.infoq.cn/public/v1/article/getList?size=20&type=1&topic=AI',
        'keywords': ['AI', '人工智能', '落地', '实践', '企业', '应用'],
        'emoji': '🚀'
    },
    'TechWeb AI': {
        'url': 'https://www.techweb.com.cn/ai/',
        'api': 'https://www.techweb.com.cn/api/article/list?catid=100&num=10',
        'keywords': ['AI', '人工智能', '互联网', '科技', '产品'],
        'emoji': '🌐'
    }
}

def fetch_url(url, timeout=15):
    """获取URL内容"""
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': 'application/json, text/html, */*',
            'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        }
        req = urllib.request.Request(url, headers=headers)
        
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        
        with urllib.request.urlopen(req, context=ctx, timeout=timeout) as response:
            content = response.read().decode('utf-8', errors='ignore')
            return {'success': True, 'content': content}
    except Exception as e:
        return {'success': False, 'error': str(e)}

def parse_qbitai(content):
    """解析量子位文章"""
    articles = []
    try:
        data = json.loads(content)
        for item in data:
            title = item.get('title', {}).get('rendered', '')
            link = item.get('link', '')
            date = item.get('date', '')
            excerpt = item.get('excerpt', {}).get('rendered', '')
            
            # 清理HTML标签
            title = re.sub(r'<[^>]+>', '', title)
            excerpt = re.sub(r'<[^>]+>', '', excerpt)
            
            articles.append({
                'title': title,
                'link': link,
                'date': date,
                'summary': excerpt[:100] + '...' if len(excerpt) > 100 else excerpt,
                'source': '量子位',
                'hot_value': 0
            })
    except:
        pass
    return articles

def parse_jiqizhixin(content):
    """解析机器之心文章"""
    articles = []
    try:
        data = json.loads(content)
        items = data.get('data', {}).get('articles', []) if isinstance(data, dict) else data
        for item in items:
            if isinstance(item, dict):
                title = item.get('title', '')
                link = f"https://www.jiqizhixin.com/articles/{item.get('id', '')}"
                summary = item.get('summary', '') or item.get('content', '')[:100]
                
                articles.append({
                    'title': title,
                    'link': link,
                    'date': item.get('created_at', ''),
                    'summary': summary[:100] + '...' if len(summary) > 100 else summary,
                    'source': '机器之心',
                    'hot_value': item.get('view_count', 0)
                })
    except:
        pass
    return articles

def parse_36kr(content):
    """解析36氪快讯"""
    articles = []
    try:
        data = json.loads(content)
        items = data.get('data', {}).get('items', []) if isinstance(data, dict) else []
        for item in items:
            if isinstance(item, dict):
                title = item.get('title', '')
                description = item.get('description', '')
                link = f"https://36kr.com/newsflashes/{item.get('id', '')}"
                
                # 合并标题和描述
                full_title = title
                if description and description != title:
                    full_title = f"{title} - {description[:50]}"
                
                articles.append({
                    'title': full_title,
                    'link': link,
                    'date': item.get('published_at', ''),
                    'summary': description[:100] + '...' if len(description) > 100 else description,
                    'source': '36氪AI',
                    'hot_value': 0
                })
    except:
        pass
    return articles

def parse_leiphone(content):
    """解析雷锋网文章"""
    articles = []
    try:
        data = json.loads(content)
        for item in data:
            title = item.get('title', {}).get('rendered', '')
            link = item.get('link', '')
            date = item.get('date', '')
            excerpt = item.get('excerpt', {}).get('rendered', '')
            
            # 清理HTML标签
            title = re.sub(r'<[^>]+>', '', title)
            excerpt = re.sub(r'<[^>]+>', '', excerpt)
            
            articles.append({
                'title': title,
                'link': link,
                'date': date,
                'summary': excerpt[:100] + '...' if len(excerpt) > 100 else excerpt,
                'source': '雷锋网AI',
                'hot_value': 0
            })
    except:
        pass
    return articles

def parse_zhidx(content):
    """解析智东西文章"""
    articles = []
    try:
        data = json.loads(content)
        for item in data:
            title = item.get('title', {}).get('rendered', '')
            link = item.get('link', '')
            date = item.get('date', '')
            excerpt = item.get('excerpt', {}).get('rendered', '')
            
            # 清理HTML标签
            title = re.sub(r'<[^>]+>', '', title)
            excerpt = re.sub(r'<[^>]+>', '', excerpt)
            
            articles.append({
                'title': title,
                'link': link,
                'date': date,
                'summary': excerpt[:100] + '...' if len(excerpt) > 100 else excerpt,
                'source': '智东西',
                'hot_value': 0
            })
    except:
        pass
    return articles

def parse_techweb(content):
    """解析TechWeb文章"""
    articles = []
    try:
        data = json.loads(content)
        items = data.get('data', []) if isinstance(data, dict) else data
        for item in items:
            if isinstance(item, dict):
                title = item.get('title', '')
                link = item.get('url', '')
                summary = item.get('summary', '')
                
                articles.append({
                    'title': title,
                    'link': link,
                    'date': item.get('time', ''),
                    'summary': summary[:100] + '...' if len(summary) > 100 else summary,
                    'source': 'TechWeb AI',
                    'hot_value': 0
                })
    except:
        pass
    return articles

def is_ai_related(title, keywords):
    """判断是否与AI相关"""
    title_lower = title.lower()
    return any(kw.lower() in title_lower for kw in keywords)

def fetch_all_media():
    """获取所有AI媒体资讯"""
    all_articles = []
    
    # 量子位
    result = fetch_url(AI_MEDIA_SOURCES['量子位']['api'])
    if result['success']:
        articles = parse_qbitai(result['content'])
        for article in articles:
            if is_ai_related(article['title'], AI_MEDIA_SOURCES['量子位']['keywords']):
                all_articles.append(article)
    
    # 机器之心
    result = fetch_url(AI_MEDIA_SOURCES['机器之心']['api'])
    if result['success']:
        articles = parse_jiqizhixin(result['content'])
        for article in articles:
            if is_ai_related(article['title'], AI_MEDIA_SOURCES['机器之心']['keywords']):
                all_articles.append(article)
    
    # 36氪
    result = fetch_url(AI_MEDIA_SOURCES['36氪AI']['api'])
    if result['success']:
        articles = parse_36kr(result['content'])
        for article in articles:
            if is_ai_related(article['title'], AI_MEDIA_SOURCES['36氪AI']['keywords']):
                all_articles.append(article)
    
    # 雷锋网AI
    result = fetch_url(AI_MEDIA_SOURCES['雷锋网AI']['api'])
    if result['success']:
        articles = parse_leiphone(result['content'])
        for article in articles:
            if is_ai_related(article['title'], AI_MEDIA_SOURCES['雷锋网AI']['keywords']):
                all_articles.append(article)
    
    # 智东西
    result = fetch_url(AI_MEDIA_SOURCES['智东西']['api'])
    if result['success']:
        articles = parse_zhidx(result['content'])
        for article in articles:
            if is_ai_related(article['title'], AI_MEDIA_SOURCES['智东西']['keywords']):
                all_articles.append(article)
    
    # 按日期排序
    all_articles.sort(key=lambda x: x.get('date', ''), reverse=True)
    
    return all_articles[:20]  # 返回最新的20条

def format_article(article):
    """格式化文章"""
    source = article.get('source', '')
    emoji = AI_MEDIA_SOURCES.get(source, {}).get('emoji', '📰')
    title = article.get('title', '')
    link = article.get('link', '')
    summary = article.get('summary', '')
    
    if summary:
        return f"- [{title}]({link}) {emoji}\n  > {summary}"
    else:
        return f"- [{title}]({link}) {emoji}"

def main():
    print("### 国内AI媒体精选")
    print("")
    
    articles = fetch_all_media()
    
    if articles:
        for article in articles:
            print(format_article(article))
            print("")
    else:
        print("*暂无AI媒体资讯*")

if __name__ == '__main__':
    main()
