#!/usr/bin/env python3
"""
AI内容摘要生成器
为热点新闻生成简短摘要
"""

import sys
import os

# 摘要模板库
SUMMARY_TEMPLATES = {
    '小米': {
        'keywords': ['小米', '雷军', 'SU7', '发布会', '大模型'],
        'summary': '小米在AI领域持续发力，推出自研大模型并深化智能汽车布局。'
    },
    '大模型': {
        'keywords': ['大模型', 'LLM', 'ChatGPT', '文心一言', '通义千问', '豆包'],
        'summary': '大模型技术持续迭代，国产模型能力不断提升，应用场景日益丰富。'
    },
    '机器人': {
        'keywords': ['机器人', '宇树', 'Optimus', '人形机器人'],
        'summary': '机器人技术快速发展，AI赋能下机器人智能化水平显著提升。'
    },
    '芯片': {
        'keywords': ['芯片', 'GPU', 'NVIDIA', '英伟达', '算力', '半导体'],
        'summary': 'AI芯片需求旺盛，国产芯片替代进程加速，算力基础设施建设持续推进。'
    },
    '自动驾驶': {
        'keywords': ['自动驾驶', '无人驾驶', 'FSD', '智能驾驶'],
        'summary': '自动驾驶技术不断突破，商业化落地进程加快。'
    },
    '多模态': {
        'keywords': ['多模态', 'Sora', '视频生成', '图像生成'],
        'summary': '多模态AI成为热点，文本、图像、视频生成能力持续增强。'
    },
    '智能体': {
        'keywords': ['Agent', '智能体', 'AI Agent'],
        'summary': 'AI Agent概念受关注，智能体应用场景不断拓展。'
    }
}

def generate_summary(title, hot_value=0):
    """根据标题生成摘要"""
    title_lower = title.lower()
    
    # 匹配关键词
    for category, info in SUMMARY_TEMPLATES.items():
        if any(kw in title for kw in info['keywords']):
            return info['summary']
    
    # 默认摘要
    if 'AI' in title or '人工智能' in title:
        return 'AI技术持续演进，产业应用不断深化。'
    elif '科技' in title:
        return '科技行业动态活跃，创新成果不断涌现。'
    else:
        return '该话题引发广泛关注，值得持续关注。'

def format_with_summary(item):
    """格式化条目并添加摘要"""
    title = item.get('title', '')
    link = item.get('link', '')
    hot = item.get('hot_value', 0)
    source = item.get('source', 'unknown')
    
    source_emoji = {
        'weibo': '🔥',
        'zhihu': '💡',
        'baidu': '🔍',
        'bilibili': '📺',
        'toutiao': '📰',
        'douyin': '🎵',
    }.get(source, '📌')
    
    # 格式化热度
    if hot >= 100000000:
        hot_str = f"{hot/100000000:.1f}亿"
    elif hot >= 10000:
        hot_str = f"{hot/10000:.1f}万"
    elif hot > 0:
        hot_str = str(hot)
    else:
        hot_str = ""
    
    hot_display = f" {hot_str}" if hot_str else ""
    summary = generate_summary(title, hot)
    
    return f"""**[{title}]({link})** {source_emoji}{hot_display}
> {summary}
"""

def main():
    if len(sys.argv) < 2:
        print("Usage: generate_ai_summary.py <title> [hot_value]", file=sys.stderr)
        sys.exit(1)
    
    title = sys.argv[1]
    hot = int(sys.argv[2]) if len(sys.argv) > 2 else 0
    
    item = {'title': title, 'link': '', 'hot_value': hot, 'source': 'weibo'}
    print(format_with_summary(item))

if __name__ == '__main__':
    main()
