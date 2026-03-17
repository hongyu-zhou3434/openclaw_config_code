#!/bin/bash
# 每日AI技术洞察报告生成脚本
# 执行时间: 每日早6:00
# 功能: 全网检索AI公司动态、模型发布、技术趋势，生成洞察报告

set -e

# 配置
WORKSPACE="/root/.openclaw/workspace"
OUTPUT_DIR="$WORKSPACE/output/daily-insights/$(date +%Y-%m-%d)"
LOG_FILE="$OUTPUT_DIR/insight-generation.log"
DATE_STR=$(date +%Y%m%d)
DATE_CN=$(date +%Y年%m月%d日)

# API配置
export TAVILY_API_KEY="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"
export OPENAI_API_KEY="sk-sp-1dfcd6127bfc4033b85aa78f2ed6a995"
export OPENAI_BASE_URL="https://coding.dashscope.aliyuncs.com/v1"
export SUMMARIZE_MODEL="kimi-k2.5"

# QQ邮箱配置
QQ_EMAIL="273477656@qq.com"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

echo "=== 每日AI技术洞察报告生成 ===" | tee "$LOG_FILE"
echo "日期: $DATE_CN" | tee -a "$LOG_FILE"
echo "时间: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 目标公司列表
COMPANIES=(
    "字节跳动:豆包,Seedance,Seed:高"
    "阿里巴巴:通义千问,Qwen:高"
    "腾讯:混元,Hunyuan:高"
    "智谱AI:GLM,ChatGLM:高"
    "DeepSeek:DeepSeek-V3,R1:高"
    "Google:Gemini,TPU:高"
    "NVIDIA:H100,B200,CUDA:高"
    "MiniMax:海螺AI,星野:高"
)

# 洞察范围关键词
INSIGHT_AREAS=(
    "大语言模型:LLM,大模型,GPT,Claude,Gemini"
    "推理模型:o1,R1,推理,思维链"
    "多模态模型:多模态,视觉,视频生成,Sora,Seedance"
    "算力卡:GPU,H100,B200,TPU,算力"
    "数据存储:HBM,显存,存储,NVLink"
    "数据加速:FlashAttention,量化,推理优化"
    "Agent:智能体,Agent,AutoGPT"
)

# 生成洞察报告
generate_insight_report() {
    local company_name="$1"
    local company_products="$2"
    local priority="$3"
    
    echo "【生成报告】$company_name ($priority优先级)" | tee -a "$LOG_FILE"
    
    # 输出文件
    local output_md="$OUTPUT_DIR/${company_name}AI洞察报告_${DATE_STR}.md"
    local output_txt="$OUTPUT_DIR/${company_name}AI洞察报告_${DATE_STR}.txt"
    
    # 开始生成报告
    cat > "$output_md" << EOF
# ${company_name} AI技术洞察报告

**报告日期**: ${DATE_CN}  
**生成时间**: $(date +"%H:%M:%S")  
**数据来源**: Tavily Search, 企业博客, 新闻媒体  
**洞察范围**: 模型发布、技术动态、产品更新

---

## 一、公司概况

**公司名称**: ${company_name}  
**主要产品**: ${company_products}  
**检索优先级**: ${priority}

---

## 二、最新动态检索

### 2.1 产品/模型发布

EOF

    # 使用Tavily搜索最新动态
    echo "  搜索: ${company_name} AI 模型 发布..." | tee -a "$LOG_FILE"
    
    local search_result
    search_result=$(TAVILY_API_KEY="$TAVILY_API_KEY" node "$WORKSPACE/skills/tavily-search/scripts/search.mjs" "${company_name} AI 模型 发布" 2>&1) || {
        echo "  ! 搜索出错: $search_result" | tee -a "$LOG_FILE"
        search_result="搜索失败，请检查API配置"
    }
    
    # 检查搜索结果是否有效
    if [ -z "$search_result" ] || [[ "$search_result" == *"Missing TAVILY_API_KEY"* ]]; then
        echo "  ! API密钥无效或未设置" | tee -a "$LOG_FILE"
        search_result="**搜索失败**: API配置错误"
    fi
    
    # 提取关键信息并写入报告
    echo "$search_result" >> "$output_md"
    
    cat >> "$output_md" << EOF

### 2.2 技术突破

EOF

    # 搜索技术相关
    echo "  搜索: ${company_name} 技术突破..." | tee -a "$LOG_FILE"
    search_result=$(TAVILY_API_KEY="$TAVILY_API_KEY" node "$WORKSPACE/skills/tavily-search/scripts/search.mjs" "${company_name} 技术突破" 2>&1) || {
        echo "  ! 搜索出错" | tee -a "$LOG_FILE"
        search_result="搜索失败"
    }
    
    if [ -z "$search_result" ] || [[ "$search_result" == *"Missing TAVILY_API_KEY"* ]]; then
        search_result="**搜索失败**: API配置错误"
    fi
    
    echo "$search_result" >> "$output_md"
    
    cat >> "$output_md" << EOF

---

## 三、技术趋势分析

### 3.1 模型能力演进

基于检索结果分析${company_name}在以下方面的进展：

- **大语言模型**: 上下文长度、推理能力、多语言支持
- **多模态能力**: 图像理解、视频生成、跨模态交互
- **推理优化**: 思维链、深度推理、数学/代码能力

### 3.2 工程化进展

- **训练基础设施**: 算力规模、训练效率、成本控制
- **推理优化**: 量化技术、KV Cache优化、批处理策略
- **部署方案**: 云端API、边缘部署、私有化方案

---

## 四、关键技术点展开

EOF

    # 针对每个洞察范围搜索
    for area in "${INSIGHT_AREAS[@]}"; do
        IFS=':' read -r area_name area_keywords <<< "$area"
        
        echo "  分析: $area_name..." | tee -a "$LOG_FILE"
        
        cat >> "$output_md" << EOF

### 4.${area_name}

**检索关键词**: ${area_keywords}

EOF

        search_result=$(TAVILY_API_KEY="$TAVILY_API_KEY" node "$WORKSPACE/skills/tavily-search/scripts/search.mjs" "${company_name} ${area_name} ${area_keywords}" 2>&1) || {
            echo "  ! 搜索出错" | tee -a "$LOG_FILE"
            search_result="搜索失败"
        }
        
        if [ -z "$search_result" ] || [[ "$search_result" == *"Missing TAVILY_API_KEY"* ]]; then
            search_result="**搜索失败**: API配置错误"
        fi
        
        echo "$search_result" >> "$output_md"
    done
    
    cat >> "$output_md" << EOF

---

## 五、整体技术趋势判断

### 5.1 战略方向

基于${DATE_CN}的检索结果，${company_name}的AI战略呈现以下特点：

1. **技术路线**: 
2. **产品布局**: 
3. **生态建设**: 

### 5.2 竞争态势

- **vs OpenAI**: 
- **vs Google**: 
- **vs 国内竞品**: 

### 5.3 未来展望

预测${company_name}在未来3-6个月可能的技术/产品动向：

1. 
2. 
3. 

---

## 六、参考来源

- Tavily Search 检索结果
- 企业官方博客/公告
- 技术媒体（量子位、机器之心等）
- 学术论文（arXiv）

---

*本报告由 OpenClaw AI 系统自动生成*  
*报告版本: v1.0*  
*生成时间: $(date)*
EOF

    # 生成纯文本版本（简化版）
    sed 's/^# /\n=== /g; s/^## /--- /g; s/^### /   /g; s/\*\*//g; s/\*//g' "$output_md" > "$output_txt"
    
    echo "  ✓ 报告已生成: ${company_name}AI洞察报告_${DATE_STR}.md" | tee -a "$LOG_FILE"
}

# 转换为PDF格式
convert_to_pdf() {
    echo "【转换为PDF格式】" | tee -a "$LOG_FILE"
    
    # 收集所有Markdown文件
    local md_files=()
    local summary_md="$OUTPUT_DIR/每日AI洞察汇总_${DATE_STR}.md"
    [ -f "$summary_md" ] && md_files+=("$summary_md")
    
    for company_info in "${COMPANIES[@]}"; do
        IFS=':' read -r company_name _ _ <<< "$company_info"
        local company_md="$OUTPUT_DIR/${company_name}AI洞察报告_${DATE_STR}.md"
        [ -f "$company_md" ] && md_files+=("$company_md")
    done
    
    # 批量转换为PDF
    if [ ${#md_files[@]} -gt 0 ]; then
        cd "$OUTPUT_DIR"
        python3 "$WORKSPACE/scripts/batch_md_to_pdf.py" "${md_files[@]}" 2>&1 | tee -a "$LOG_FILE"
        if [ $? -eq 0 ]; then
            echo "  ✓ PDF转换完成" | tee -a "$LOG_FILE"
        else
            echo "  ! PDF转换部分失败" | tee -a "$LOG_FILE"
        fi
    fi
}

# 发送邮件通知（带PDF附件）
send_email_notification() {
    echo "【发送邮件通知】" | tee -a "$LOG_FILE"
    
    # 构建PDF附件列表
    local attachments=""
    local summary_pdf="$OUTPUT_DIR/每日AI洞察汇总_${DATE_STR}.pdf"
    
    if [ -f "$summary_pdf" ]; then
        attachments="$summary_pdf"
    fi
    
    # 添加所有公司PDF报告
    for company_info in "${COMPANIES[@]}"; do
        IFS=':' read -r company_name _ _ <<< "$company_info"
        local company_pdf="$OUTPUT_DIR/${company_name}AI洞察报告_${DATE_STR}.pdf"
        if [ -f "$company_pdf" ]; then
            attachments="$attachments $company_pdf"
        fi
    done
    
    # 使用Python邮件发送工具
    cd "$OUTPUT_DIR"
    python3 "$WORKSPACE/scripts/send_email_with_progress.py" \
        --to "$QQ_EMAIL" \
        --subject "📊 每日AI技术洞察报告 - $DATE_CN" \
        --body "您好！

今日AI技术洞察报告已生成。

报告日期: $DATE_CN
生成时间: $(date +"%H:%M:%S")
覆盖公司: 字节跳动、阿里巴巴、腾讯、智谱AI、DeepSeek、Google、NVIDIA、MiniMax
洞察范围: 大模型、推理模型、多模态、算力卡、数据存储、数据加速、Agent

附件为PDF格式报告文件，包含汇总报告及各公司详细洞察报告。

---
本邮件由 OpenClaw AI 系统自动发送" \
        --attachments $attachments 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        echo "  ✓ 邮件发送成功" | tee -a "$LOG_FILE"
    else
        echo "  ! 邮件发送失败" | tee -a "$LOG_FILE"
    fi
}

# 生成汇总报告
generate_summary_report() {
    echo "【生成汇总报告】" | tee -a "$LOG_FILE"
    
    local summary_md="$OUTPUT_DIR/每日AI洞察汇总_${DATE_STR}.md"
    
    cat > "$summary_md" << EOF
# 每日AI技术洞察汇总报告

**报告日期**: ${DATE_CN}  
**生成时间**: $(date +"%H:%M:%S")  
**覆盖公司**: 字节跳动、阿里巴巴、腾讯、智谱AI、DeepSeek、Google、NVIDIA、MiniMax  
**洞察范围**: 大模型、推理模型、多模态、算力卡、数据存储、数据加速、Agent

---

## 一、今日热点

### 1.1 重大发布

EOF

    # 搜索今日热点
    echo "  搜索今日AI热点..." | tee -a "$LOG_FILE"
    local hot_news
    hot_news=$(TAVILY_API_KEY="$TAVILY_API_KEY" node "$WORKSPACE/skills/tavily-search/scripts/search.mjs" "AI 大模型 发布" 2>&1) || {
        echo "  ! 搜索出错" | tee -a "$LOG_FILE"
        hot_news="搜索失败"
    }
    if [ -z "$hot_news" ] || [[ "$hot_news" == *"Missing TAVILY_API_KEY"* ]]; then
        hot_news="**搜索失败**: API配置错误"
    fi
    echo "$hot_news" >> "$summary_md"
    
    cat >> "$summary_md" << EOF

### 1.2 技术突破

EOF

    hot_news=$(TAVILY_API_KEY="$TAVILY_API_KEY" node "$WORKSPACE/skills/tavily-search/scripts/search.mjs" "AI 技术突破" 2>&1) || {
        echo "  ! 搜索出错" | tee -a "$LOG_FILE"
        hot_news="搜索失败"
    }
    if [ -z "$hot_news" ] || [[ "$hot_news" == *"Missing TAVILY_API_KEY"* ]]; then
        hot_news="**搜索失败**: API配置错误"
    fi
    echo "$hot_news" >> "$summary_md"
    
    cat >> "$summary_md" << EOF

---

## 二、各公司动态摘要

| 公司 | 主要动态 | 技术亮点 | 关注等级 |
|------|----------|----------|----------|
| 字节跳动 | 待检索 | - | 高 |
| 阿里巴巴 | 待检索 | - | 高 |
| 腾讯 | 待检索 | - | 高 |
| 智谱AI | 待检索 | - | 高 |
| DeepSeek | 待检索 | - | 高 |
| Google | 待检索 | - | 高 |
| NVIDIA | 待检索 | - | 高 |
| MiniMax | 待检索 | - | 高 |

---

## 三、技术趋势总览

### 3.1 模型发展趋势

- **大语言模型**: 
- **推理模型**: 
- **多模态模型**: 

### 3.2 基础设施趋势

- **算力卡**: 
- **数据存储**: 
- **数据加速**: 

### 3.3 应用层趋势

- **Agent/智能体**: 
- **行业应用**: 

---

## 四、详细报告索引

本批次生成的详细报告：

EOF

    # 列出所有生成的报告
    for company_info in "${COMPANIES[@]}"; do
        IFS=':' read -r company_name _ _ <<< "$company_info"
        echo "- [${company_name}AI洞察报告_${DATE_STR}.md](./${company_name}AI洞察报告_${DATE_STR}.md)" >> "$summary_md"
    done
    
    cat >> "$summary_md" << EOF

---

## 五、明日关注

基于当前趋势，建议明日重点关注：

1. 
2. 
3. 

---

*本报告由 OpenClaw AI 系统自动生成*  
*报告版本: v1.0*  
*生成时间: $(date)*
EOF

    echo "  ✓ 汇总报告已生成: 每日AI洞察汇总_${DATE_STR}.md" | tee -a "$LOG_FILE"
}

# 主执行流程
echo "【开始生成洞察报告】" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 生成各公司报告
for company_info in "${COMPANIES[@]}"; do
    IFS=':' read -r company_name company_products priority <<< "$company_info"
    generate_insight_report "$company_name" "$company_products" "$priority"
    echo "" | tee -a "$LOG_FILE"
done

# 生成汇总报告
generate_summary_report

# 归档管理（保留最近30天）
echo "【归档管理】" | tee -a "$LOG_FILE"
find "$WORKSPACE/output/daily-insights" -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
echo "  ✓ 已清理30天前的旧报告" | tee -a "$LOG_FILE"

# 转换为PDF并发送邮件
echo "" | tee -a "$LOG_FILE"
convert_to_pdf
echo "" | tee -a "$LOG_FILE"
send_email_notification

# GitHub同步（可选）
if [ -d "$WORKSPACE/.git" ]; then
    echo "" | tee -a "$LOG_FILE"
    echo "【GitHub同步】" | tee -a "$LOG_FILE"
    cd "$WORKSPACE"
    git add "$OUTPUT_DIR" 2>/dev/null || true
    git commit -m "每日AI洞察报告 ${DATE_CN}" 2>/dev/null || true
    git push origin main 2>/dev/null || echo "  ! GitHub同步跳过"
fi

echo "" | tee -a "$LOG_FILE"
echo "=== 洞察报告生成完成 ===" | tee -a "$LOG_FILE"
echo "输出目录: $OUTPUT_DIR" | tee -a "$LOG_FILE"
echo "报告数量: $(ls -1 $OUTPUT_DIR/*.md 2>/dev/null | wc -l) 个" | tee -a "$LOG_FILE"
echo "邮件已发送至: $QQ_EMAIL" | tee -a "$LOG_FILE"

exit 0
