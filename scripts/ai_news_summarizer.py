#!/usr/bin/env python3
"""
AI新闻智能摘要生成器 V2
基于标题深度分析生成详细摘要
"""

import sys
import re

# 详细摘要模板库
SUMMARY_TEMPLATES = {
    # 小米相关
    '小米发布会': {
        'category': '产品发布',
        'summary': '小米举办重磅发布会，发布新一代SU7智能电动汽车及多款AI大模型产品，展示"人车家全生态"AI战略。雷军表示小米将持续加大AI研发投入，推动智能汽车与AI技术深度融合。',
        'impact': '高',
        'trend': '智能汽车+AI大模型双轮驱动'
    },
    '小米大模型': {
        'category': '大模型',
        'summary': '小米正式发布3款自研大模型：MiLM-6B、MiLM-1.3B和MiLM-0.7B，覆盖从云端到端侧的全场景需求。模型在中文理解、多模态处理等能力上达到行业领先水平，将应用于小爱同学、小米汽车等产品。',
        'impact': '高',
        'trend': '端侧大模型轻量化部署'
    },
    '小米SU7': {
        'category': '智能汽车',
        'summary': '小米SU7作为小米汽车首款量产车型，搭载自研智能驾驶系统Xiaomi Pilot，采用端到端大模型技术。车辆支持城市NOA、高速NOA等高阶智驾功能，标志着小米正式进军智能汽车市场。',
        'impact': '高',
        'trend': '消费电子巨头跨界造车'
    },
    
    # 机器人相关
    '宇树机器人': {
        'category': '机器人',
        'summary': '宇树科技展示最新人形机器人产品，王兴兴向雷军演示机器人跳舞等动作。宇树机器人采用自研关节电机和AI运动控制算法，已实现高难度动作，在工业、服务等领域应用前景广阔。',
        'impact': '中高',
        'trend': '人形机器人商业化加速'
    },
    '机器人': {
        'category': '机器人',
        'summary': 'AI赋能机器人技术快速发展，从工业机械臂向服务机器人、人形机器人延伸。大模型技术提升机器人感知、决策能力，推动机器人从"自动化"向"智能化"升级。',
        'impact': '中高',
        'trend': '具身智能成为新热点'
    },
    
    # 大模型相关
    '大模型发布': {
        'category': '大模型',
        'summary': '国产大模型密集发布，参数规模、多模态能力、推理效率持续提升。头部企业加速布局，垂直行业大模型成为竞争焦点，商业化落地进程加快。',
        'impact': '高',
        'trend': '大模型进入应用落地期'
    },
    '文心一言': {
        'category': '大模型',
        'summary': '百度文心一言持续迭代升级，用户规模突破数千万。模型在中文理解、知识问答、创意写作等场景表现优异，已接入百度搜索、百度地图等核心产品。',
        'impact': '高',
        'trend': '搜索+大模型深度融合'
    },
    '通义千问': {
        'category': '大模型',
        'summary': '阿里通义千问系列模型能力不断提升，开源版本Qwen-72B在多项评测中表现优异。模型已应用于钉钉、淘宝、天猫精灵等产品，推动阿里全系产品AI化升级。',
        'impact': '高',
        'trend': '开源大模型生态建设'
    },
    '豆包': {
        'category': '大模型',
        'summary': '字节跳动豆包大模型快速迭代，依托抖音、今日头条等场景积累海量数据。模型在内容创作、智能推荐等场景优势明显，日活用户持续增长。',
        'impact': '高',
        'trend': '内容平台+大模型协同'
    },
    'ChatGPT': {
        'category': '大模型',
        'summary': 'OpenAI ChatGPT持续引领行业发展，GPT-4系列模型在多模态、推理能力上保持领先。ChatGPT用户规模突破数亿，推动全球AI应用爆发式增长。',
        'impact': '高',
        'trend': '全球大模型竞赛白热化'
    },
    
    # 芯片算力相关
    'NVIDIA': {
        'category': '芯片算力',
        'summary': '英伟达作为全球AI芯片龙头，H100、H200等数据中心GPU供不应求。黄仁勋提出"AI时代Linux"观点，强调CUDA生态对AI开发的重要性。公司市值持续创新高，成为AI浪潮最大受益者之一。',
        'impact': '极高',
        'trend': 'AI芯片需求持续旺盛'
    },
    '英伟达': {
        'category': '芯片算力',
        'summary': '英伟达AI芯片在中国市场面临出口管制，公司正调整产品策略以符合法规要求。国产AI芯片厂商迎来替代机遇，华为昇腾、寒武纪等加速追赶。',
        'impact': '高',
        'trend': 'AI芯片国产化替代加速'
    },
    'GPU': {
        'category': '芯片算力',
        'summary': 'AI训练推理对GPU算力需求激增，高端GPU供应紧张。云厂商大规模采购GPU建设智算中心，算力租赁成为新商业模式。国产GPU在推理场景逐步渗透。',
        'impact': '高',
        'trend': '算力成为AI竞争核心要素'
    },
    '华为昇腾': {
        'category': '芯片算力',
        'summary': '华为昇腾AI芯片性能持续提升，已支撑盘古大模型训练。在国内智算中心建设中占据重要份额，生态建设逐步完善，成为国产AI芯片领军者。',
        'impact': '高',
        'trend': '国产AI芯片生态建设'
    },
    
    # 多模态AI
    'Sora': {
        'category': '多模态',
        'summary': 'OpenAI Sora视频生成模型引发行业震动，可生成长达60秒的高质量视频。模型展现对物理世界的理解能力，推动视频生成进入新阶段，对影视、广告等行业影响深远。',
        'impact': '极高',
        'trend': '视频生成技术革命性突破'
    },
    '视频生成': {
        'category': '多模态',
        'summary': 'AI视频生成技术快速进步，从几秒短视频向长视频发展。国内外厂商密集发布视频生成模型，应用场景从娱乐向教育、营销、影视制作拓展。',
        'impact': '高',
        'trend': 'AI视频生成商业化提速'
    },
    '多模态': {
        'category': '多模态',
        'summary': '多模态大模型成为技术演进重要方向，文本、图像、视频、音频统一理解生成能力持续提升。GPT-4V、Gemini等模型展现强大多模态能力，应用场景大幅拓展。',
        'impact': '高',
        'trend': '多模态成为大模型标配'
    },
    
    # 智能体
    'AI Agent': {
        'category': '智能体',
        'summary': 'AI Agent（智能体）成为大模型应用重要形态，能够自主规划、使用工具、完成任务。AutoGPT、Devin等产品展示Agent潜力，企业级应用逐步落地。',
        'impact': '中高',
        'trend': '从聊天机器人向智能体演进'
    },
    '智能体': {
        'category': '智能体',
        'summary': 'AI智能体技术快速发展，能够自主决策、调用工具、完成复杂任务。在客服、编程、数据分析等场景开始应用，被认为是AI应用下一重要形态。',
        'impact': '中高',
        'trend': '智能体商业化探索加速'
    },
    
    # 自动驾驶
    '自动驾驶': {
        'category': '自动驾驶',
        'summary': '自动驾驶技术向L3/L4级别迈进，端到端大模型成为技术新路线。特斯拉FSD V12、华为ADS等系统能力持续提升，Robotaxi商业化试点扩大。',
        'impact': '高',
        'trend': '端到端大模型重塑自动驾驶'
    },
    'FSD': {
        'category': '自动驾驶',
        'summary': '特斯拉FSD（完全自动驾驶）持续迭代，V12版本采用端到端神经网络。系统在美国广泛测试，计划进入中国市场。端到端方案成为行业跟随方向。',
        'impact': '高',
        'trend': '端到端自动驾驶方案普及'
    },
    
    # 科技巨头动态
    '阿里巴巴': {
        'category': '企业动态',
        'summary': '阿里持续加大AI投入，通义千问大模型能力不断提升，已应用于全系产品。云智能集团增长强劲，AI相关收入快速增长。公司组织架构调整，聚焦AI战略。',
        'impact': '高',
        'trend': '互联网巨头全面AI化'
    },
    '腾讯': {
        'category': '企业动态',
        'summary': '腾讯混元大模型持续迭代，已应用于微信、QQ、腾讯会议等产品。游戏、广告、云业务加速AI融合，元宝AI助手用户规模增长。公司加大AI基础设施投资。',
        'impact': '高',
        'trend': '社交+游戏+AI深度融合'
    },
    '字节跳动': {
        'category': '企业动态',
        'summary': '字节跳动豆包大模型快速发展，依托抖音、今日头条等超级应用积累数据优势。公司在AI创作、推荐算法、视频生成等领域持续投入，AI产品矩阵不断完善。',
        'impact': '高',
        'trend': '内容平台AI原生转型'
    },
    '百度': {
        'category': '企业动态',
        'summary': '百度文心一言用户规模领先，已重构搜索、地图、网盘等核心产品。智能云业务增长强劲，自动驾驶业务萝卜快跑运营规模扩大。公司坚定AI优先战略。',
        'impact': '高',
        'trend': '搜索重构与AI原生应用'
    },
    '华为': {
        'category': '企业动态',
        'summary': '华为盘古大模型深耕行业场景，在政务、金融、制造等领域落地。昇腾AI芯片支撑大模型训练，智算中心建设加速。鸿蒙系统AI能力持续提升。',
        'impact': '高',
        'trend': '全栈AI解决方案提供商'
    },
    
    # 默认
    'default': {
        'category': 'AI综合',
        'summary': 'AI技术持续演进，产业应用不断深化。大模型、多模态、智能体等技术方向快速发展，AI正加速渗透各行各业，推动数字化转型和智能化升级。',
        'impact': '中',
        'trend': 'AI技术持续创新'
    }
}

def match_template(title):
    """根据标题匹配最合适的模板"""
    title_lower = title.lower()
    
    # 优先级匹配
    patterns = [
        # 小米相关
        (r'小米.*发布会|雷军.*发布', '小米发布会'),
        (r'小米.*大模型|MiLM', '小米大模型'),
        (r'小米.*SU7|小米.*汽车', '小米SU7'),
        
        # 机器人
        (r'宇树|王兴兴', '宇树机器人'),
        (r'机器人', '机器人'),
        
        # 大模型
        (r'大模型.*发布|发布.*大模型', '大模型发布'),
        (r'文心一言|ERNIE', '文心一言'),
        (r'通义千问|Qwen', '通义千问'),
        (r'豆包', '豆包'),
        (r'ChatGPT|GPT-4|GPT-5', 'ChatGPT'),
        
        # 芯片
        (r'NVIDIA|黄仁勋', 'NVIDIA'),
        (r'英伟达.*芯片|英伟达.*销售', '英伟达'),
        (r'GPU|显卡', 'GPU'),
        (r'昇腾|华为.*芯片', '华为昇腾'),
        
        # 多模态
        (r'Sora|OpenAI.*视频', 'Sora'),
        (r'视频生成|AI.*视频', '视频生成'),
        (r'多模态', '多模态'),
        
        # 智能体
        (r'AI Agent|Agent', 'AI Agent'),
        (r'智能体', '智能体'),
        
        # 自动驾驶
        (r'自动驾驶|无人驾驶', '自动驾驶'),
        (r'FSD|特斯拉.*驾驶', 'FSD'),
        
        # 企业
        (r'阿里巴巴|阿里.*营收|阿里.*财报', '阿里巴巴'),
        (r'腾讯.*市值|腾讯.*财报', '腾讯'),
        (r'字节.*抖音|字节.*跳动', '字节跳动'),
        (r'百度.*文心|百度.*AI', '百度'),
        (r'华为.*盘古|华为.*AI', '华为'),
    ]
    
    for pattern, template_key in patterns:
        if re.search(pattern, title_lower):
            return SUMMARY_TEMPLATES.get(template_key, SUMMARY_TEMPLATES['default'])
    
    # 关键词匹配
    if 'AI' in title or '人工智能' in title:
        return SUMMARY_TEMPLATES['default']
    
    return SUMMARY_TEMPLATES['default']

def generate_detailed_summary(title, hot_value=0):
    """生成详细摘要"""
    template = match_template(title)
    
    # 根据热度调整影响等级
    impact = template['impact']
    if hot_value > 1000000:  # 100万+
        impact = '极高' if impact == '高' else '高'
    
    summary = f"""**{template['category']}** | 影响: {impact}

{template['summary']}

**趋势洞察**: {template['trend']}"""
    
    return summary

def main():
    if len(sys.argv) < 2:
        print("Usage: ai_news_summarizer.py <title> [hot_value]", file=sys.stderr)
        sys.exit(1)
    
    title = sys.argv[1]
    hot = int(sys.argv[2]) if len(sys.argv) > 2 else 0
    
    summary = generate_detailed_summary(title, hot)
    print(summary)

if __name__ == '__main__':
    main()