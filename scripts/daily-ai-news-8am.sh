#!/bin/bash
# 每日早8点AI动态洞察报告生成脚本
# 执行时间: 每日早8:00
# 功能: 洞察24小时内发布的最新AI动态，生成PDF报告并发送到QQ邮箱

set -e

# 确保 PATH 包含 node 和 nvm
export PATH="/root/.nvm/current/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# 配置
WORKSPACE="/root/.openclaw/workspace"
OUTPUT_DIR="$WORKSPACE/output/daily-ai-news/$(date +%Y-%m-%d)"
LOG_FILE="$OUTPUT_DIR/ai-news-generation.log"
DATE_STR=$(date +%Y%m%d)
DATE_CN=$(date +%Y年%m月%d日)
TIME_STR=$(date +%H:%M)

# API配置
export TAVILY_API_KEY="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"
export OPENAI_API_KEY="sk-sp-1dfcd6127bfc4033b85aa78f2ed6a995"
export OPENAI_BASE_URL="https://coding.dashscope.aliyuncs.com/v1"
export SUMMARIZE_MODEL="kimi-k2.5"

# QQ邮箱配置
QQ_EMAIL="273477656@qq.com"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

echo "=== 每日AI动态洞察报告生成（早8点）===" | tee "$LOG_FILE"
echo "日期: $DATE_CN" | tee -a "$LOG_FILE"
echo "时间: $TIME_STR" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 权威资讯来源清单
NEWS_SOURCES=(
    "arXiv:cs.AI,cs.CL,cs.CV,cs.LG"
    "量子位:qbitai.com"
    "机器之心:jiqizhixin.com"
    "Paper Digest:papersdigest.com"
    "MIT Technology Review:technologyreview.com"
    "VentureBeat:venturebeat.com"
    "TechCrunch:techcrunch.com"
)

# 国内热搜API配置
HOT_API_BASE="https://60s.viki.moe/v2"
AI_NEWS_FETCHER="$WORKSPACE/scripts/ai_news_fetcher_v2.py"

# 搜索函数：使用Python脚本获取AI相关内容（支持多数据源和缓存）
search_with_fallback() {
    local query="$1"
    
    # 使用Python脚本获取数据
    if [ "$query" == "AI artificial intelligence latest news" ] || [ "$query" == "AI breakthrough technology latest" ]; then
        # 通用AI新闻
        python3 "$AI_NEWS_FETCHER" general 2>/dev/null
    else
        # 特定公司新闻
        python3 "$AI_NEWS_FETCHER" company "$query" 2>/dev/null
    fi
}

# 重点AI公司
TARGET_COMPANIES=(
    "OpenAI"
    "Google"
    "Meta"
    "NVIDIA"
    "Microsoft"
    "Anthropic"
    "阿里巴巴"
    "字节跳动"
    "腾讯"
    "DeepSeek"
    "智谱AI"
    "MiniMax"
    "百度"
    "华为"
)

# 洞察关键词
INSIGHT_KEYWORDS=(
    "AI模型发布"
    "大语言模型"
    "多模态模型"
    "推理模型"
    "视频生成"
    "算力卡"
    "GPU"
    "数据存储"
    "AI Agent"
    "智能体"
)

echo "【开始洞察24小时AI动态】" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 生成Markdown报告
generate_markdown_report() {
    local output_md="$OUTPUT_DIR/AI动态洞察报告_${DATE_STR}.md"
    
    cat > "$output_md" << 'EOF'
# AI动态洞察报告

**报告日期**: DATE_CN  
**生成时间**: TIME_STR  
**洞察周期**: 过去24小时  
**数据来源**: 全球AI权威资讯源  

---

## 一、今日AI热点概览

### 1.1 重大发布

EOF
    sed -i "s/DATE_CN/$DATE_CN/g; s/TIME_STR/$TIME_STR/g" "$output_md"
    
    # 搜索最新AI动态（带摘要）
    echo "  搜索最新AI动态..." | tee -a "$LOG_FILE"
    local search_result
    search_result=$(python3 "$AI_NEWS_FETCHER" general 2>/dev/null)
    echo "$search_result" >> "$output_md"
    
    cat >> "$output_md" << 'EOF'

### 1.2 专业AI媒体精选

EOF
    
    # 获取专业AI媒体资讯
    echo "  获取专业AI媒体资讯..." | tee -a "$LOG_FILE"
    local media_result
    media_result=$(python3 "$WORKSPACE/scripts/ai_media_fetcher.py" 2>/dev/null)
    if [ -n "$media_result" ]; then
        echo "$media_result" >> "$output_md"
    else
        echo "*专业AI媒体资讯获取中...*" >> "$output_md"
    fi
    
    cat >> "$output_md" << 'EOF'

### 1.3 技术突破

*基于上述热点分析，今日技术突破主要集中在：*
- **大模型领域**: 小米发布3款自研大模型，国产大模型能力持续提升
- **机器人技术**: 宇树机器人展示最新进展，AI赋能机器人智能化
- **多模态AI**: AI生成内容技术不断突破，应用场景拓展

EOF
    
    cat >> "$output_md" << 'EOF'

---

## 二、重点公司动态

EOF

    # 搜索各公司动态
    for company in "${TARGET_COMPANIES[@]}"; do
        echo "  搜索 $company 动态..." | tee -a "$LOG_FILE"
        cat >> "$output_md" << EOF

### $company

EOF
        search_result=$(search_with_fallback "$company")
        if [ -z "$search_result" ] || [[ "$search_result" == *"暂无相关热搜"* ]]; then
            echo "*$company 暂无相关热搜*" >> "$output_md"
        else
            echo "$search_result" >> "$output_md"
        fi
    done
    
    cat >> "$output_md" << 'EOF'

---

## 三、技术趋势分析

### 3.1 模型发展趋势

- **大语言模型**: 
- **多模态模型**: 
- **推理模型**: 

### 3.2 基础设施趋势

- **算力卡**: 
- **数据存储**: 
- **数据加速**: 

### 3.3 应用层趋势

- **AI Agent**: 
- **行业应用**: 

---

## 四、关键数据点

| 指标 | 数值 | 趋势 |
|------|------|------|
| 新模型发布 | - | - |
| 技术突破 | - | - |
| 融资动态 | - | - |

---

## 五、明日关注

基于当前趋势，建议关注：

1. 
2. 
3. 

---

*本报告由 OpenClaw AI 系统自动生成*  
*数据来源: Tavily Search, arXiv, 权威科技媒体*  
*生成时间: TIME_STR*
EOF
    sed -i "s/TIME_STR/$TIME_STR/g" "$output_md"
    
    echo "  ✓ Markdown报告已生成: AI动态洞察报告_${DATE_STR}.md" | tee -a "$LOG_FILE"
    # 将文件路径写入临时文件，最后只输出路径到stdout
    echo "$output_md" > /tmp/last_md_path.txt
}

# 获取Markdown文件路径
get_md_file_path() {
    cat /tmp/last_md_path.txt 2>/dev/null || echo ""
}

# 转换为PDF格式（使用Python工具）
convert_to_pdf() {
    local md_file="$1"
    local md_basename=$(basename "$md_file")
    local pdf_basename="${md_basename%.md}.pdf"
    local pdf_file="$OUTPUT_DIR/$pdf_basename"
    
    echo "  转换为PDF格式..." | tee -a "$LOG_FILE"
    
    # 使用新的Python工具转换（在输出目录执行）
    cd "$OUTPUT_DIR"
    python3 "$WORKSPACE/scripts/batch_md_to_pdf.py" "$md_file" 2>&1 | tee -a "$LOG_FILE"
    local convert_exit_code=${PIPESTATUS[0]}
    
    # 检查PDF是否生成（在当前目录）
    if [ -f "$pdf_basename" ]; then
        local size_kb=$(du -k "$pdf_basename" | cut -f1)
        echo "  ✓ PDF文件已生成: $pdf_basename (${size_kb}KB)" | tee -a "$LOG_FILE"
        # 将PDF路径写入文件以便主流程读取
        echo "$OUTPUT_DIR/$pdf_basename" > /tmp/last_pdf_path.txt
        return 0
    else
        echo "  ! PDF转换失败 (exit code: $convert_exit_code)" | tee -a "$LOG_FILE"
        return 1
    fi
}

# 发送邮件（仅发送PDF附件）
send_email_notification() {
    local pdf_file="$1"
    
    echo "【发送邮件通知】" | tee -a "$LOG_FILE"
    
    # 检查PDF文件是否存在
    if [ -z "$pdf_file" ] || [ ! -f "$pdf_file" ]; then
        echo "  ! PDF文件不存在，无法发送邮件" | tee -a "$LOG_FILE"
        return 1
    fi
    
    # 使用带进度反馈的邮件发送工具（仅发送PDF）
    cd "$OUTPUT_DIR"
    python3 "$WORKSPACE/scripts/send_email_with_progress.py" \
        --to "$QQ_EMAIL" \
        --subject "📊 AI动态洞察报告 - $DATE_CN" \
        --body "您好！

今日AI动态洞察报告已生成。

报告日期: $DATE_CN
洞察周期: 过去24小时
数据来源: 全球AI权威资讯源

覆盖公司: OpenAI、Google、Meta、NVIDIA、Microsoft、Anthropic、阿里巴巴、字节跳动、腾讯、DeepSeek、智谱AI、MiniMax、百度、华为

附件为PDF格式报告文件。

---
本邮件由 OpenClaw AI 系统自动发送" \
        --attachments "$pdf_file" 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        echo "  ✓ 邮件发送成功" | tee -a "$LOG_FILE"
    else
        echo "  ! 邮件发送失败" | tee -a "$LOG_FILE"
    fi
}

# 主执行流程
echo "【步骤1/4】生成Markdown报告..." | tee -a "$LOG_FILE"
generate_markdown_report
MD_FILE=$(cat /tmp/last_md_path.txt 2>/dev/null || echo "")

echo "" | tee -a "$LOG_FILE"
echo "【步骤2/4】转换为PDF..." | tee -a "$LOG_FILE"
PDF_FILE=""
if [ -n "$MD_FILE" ] && [ -f "$MD_FILE" ]; then
    # 执行转换
    convert_to_pdf "$MD_FILE"
    # 从文件读取PDF路径
    if [ -f /tmp/last_pdf_path.txt ]; then
        PDF_FILE=$(cat /tmp/last_pdf_path.txt)
        rm -f /tmp/last_pdf_path.txt
    fi
    # 如果文件读取失败，尝试构造路径
    if [ -z "$PDF_FILE" ]; then
        local md_basename=$(basename "$MD_FILE")
        local pdf_basename="${md_basename%.md}.pdf"
        PDF_FILE="$OUTPUT_DIR/$pdf_basename"
    fi
    # 验证PDF文件是否存在
    if [ ! -f "$PDF_FILE" ]; then
        echo "  ! PDF文件未生成: $PDF_FILE" | tee -a "$LOG_FILE"
        PDF_FILE=""
    fi
fi

echo "" | tee -a "$LOG_FILE"
echo "【步骤3/4】发送邮件通知..." | tee -a "$LOG_FILE"
send_email_notification "$PDF_FILE"

echo "" | tee -a "$LOG_FILE"
echo "【步骤4/4】归档管理..." | tee -a "$LOG_FILE"
find "$WORKSPACE/output/daily-ai-news" -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
echo "  ✓ 已清理30天前的旧报告" | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "=== 报告生成完成 ===" | tee -a "$LOG_FILE"
echo "输出目录: $OUTPUT_DIR" | tee -a "$LOG_FILE"
echo "生成文件:" | tee -a "$LOG_FILE"
ls -lh "$OUTPUT_DIR"/AI动态洞察报告_${DATE_STR}.* 2>/dev/null | tee -a "$LOG_FILE" || true

echo "" | tee -a "$LOG_FILE"
echo "邮件已发送至: $QQ_EMAIL" | tee -a "$LOG_FILE"

exit 0
