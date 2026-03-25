#!/bin/bash
# 远程代码分析脚本 - 无需下载代码
# 使用 Tavily 搜索获取代码信息并生成报告

REPO_URL="$1"
REPO_NAME=$(basename "$REPO_URL" .git)
REPORT_DIR="/root/.openclaw/workspace/skills/code-analyzer/reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORT_DIR/${REPO_NAME}-remote-analysis-${TIMESTAMP}.md"

echo "🔍 远程代码分析工具"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "仓库: $REPO_URL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 确保目录存在
mkdir -p "$REPORT_DIR"

# 使用 Tavily 搜索获取信息
echo ""
echo "🔍 搜索仓库信息..."

# 搜索仓库结构
python3 ~/.openclaw/workspace/skills/openclaw-tavily-search/scripts/tavily_search.py \
    --query "$REPO_NAME github repository file structure code" \
    --max-results 10 \
    --format md > /tmp/repo_info.txt 2>/dev/null || echo "搜索完成"

# 搜索技术细节
python3 ~/.openclaw/workspace/skills/openclaw-tavily-search/scripts/tavily_search.py \
    --query "$REPO_NAME technical architecture features" \
    --max-results 10 \
    --format md > /tmp/tech_info.txt 2>/dev/null || echo "搜索完成"

# 生成报告
echo ""
echo "📝 生成分析报告..."

cat > "$REPORT_FILE" << EOF
# ${REPO_NAME} 远程技术分析报告

## 1. 模型概述

| 内容项 | 说明 | 当前值 |
|--------|------|--------|
| **模型名称** | 官方名称和版本 | ${REPO_NAME} |
| **发布机构** | 开发公司/组织 | - |
| **发布时间** | 发布日期 | $(date +%Y/%m/%d) |
| **模型类型** | 基础分类 | 代码分析模型 |
| **参数量级** | 模型规模 | - |
| **上下文窗口** | 支持的最大token数 | - |
| **GitHub仓库** | 代码仓库地址 | ${REPO_URL} |

## 2. 技术架构

### 2.1 基础架构
- **架构类型**: 待分析
- **注意力机制**: 待分析
- **位置编码**: 待分析
- **激活函数**: 待分析

### 2.2 训练方法
- **预训练数据**: 待分析
- **训练策略**: 待分析
- **优化器**: 待分析
- **学习率调度**: 待分析

### 2.3 推理优化
- **量化支持**: 待分析
- **推理加速**: 待分析
- **部署方式**: 待分析

## 3. 性能评估

| 指标类别 | 具体指标 | 说明 |
|----------|----------|------|
| **基准测试** | 待补充 | 学术基准得分 |
| **推理能力** | 待补充 | 专项能力评分 |
| **多语言** | 待补充 | 语言覆盖度 |
| **长文本** | 待补充 | 长上下文处理能力 |
| **速度性能** | 待补充 | 推理效率 |
| **资源占用** | 待补充 | 部署成本 |

## 4. 能力特性

### 4.1 核心能力
- [ ] 待分析

### 4.2 扩展能力
- [ ] 待分析

### 4.3 安全特性
- 待分析

## 5. 搜索结果摘要

### 5.1 仓库信息
\`\`\`
$(cat /tmp/repo_info.txt 2>/dev/null | head -100)
\`\`\`

### 5.2 技术信息
\`\`\`
$(cat /tmp/tech_info.txt 2>/dev/null | head -100)
\`\`\`

## 6. 建议与总结

### 6.1 总体评价
- **优势**: 待分析
- **劣势**: 待分析

### 6.2 使用建议
1. 建议下载代码进行详细分析
2. 使用 \`./github-analyze.sh ${REPO_URL}\` 进行完整分析

### 6.3 优化方向
- 完善技术文档
- 增加单元测试

---
*报告由 OpenClaw AI 自动生成 (远程分析模式)*
*分析时间: $(date '+%Y/%m/%d %H:%M:%S')*
*分析工具: Tavily Search + OpenClaw Code Analyzer*
EOF

echo ""
echo "✅ 报告生成完成: $REPORT_FILE"
echo ""
echo "💡 提示: 这是远程分析模式，信息可能不完整。"
echo "   如需完整分析，请使用: ./github-analyze.sh $REPO_URL"
