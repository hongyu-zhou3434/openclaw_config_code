#!/bin/bash
# 系统例行健康检查脚本 v1.1
# 执行时间: 每日 21:00

WORKSPACE="/root/.openclaw/workspace"
OUTPUT_DIR="$WORKSPACE/output/health-checks/$(date +%Y-%m-%d)"
LOG_FILE="$OUTPUT_DIR/health-check.log"

mkdir -p "$OUTPUT_DIR"

echo "=== OpenClaw 系统健康检查 v1.1 ===" | tee "$LOG_FILE"
echo "时间: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

PASSED=0
FAILED=0

# 1. 系统配置检查
echo "【1. 系统配置检查】" | tee -a "$LOG_FILE"

if [ -d "$WORKSPACE" ]; then
    echo "  工作区目录存在 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  工作区目录存在 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if [ -d "$WORKSPACE/config" ]; then
    echo "  配置目录存在 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  配置目录存在 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if [ -d "$WORKSPACE/skills" ]; then
    echo "  技能目录存在 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  技能目录存在 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if [ -f "$WORKSPACE/config/system-config-v1.1.md" ]; then
    echo "  系统配置v1.1存在 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  系统配置v1.1存在 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

echo "" | tee -a "$LOG_FILE"

# 2. 核心脚本检查
echo "【2. 核心脚本检查】" | tee -a "$LOG_FILE"

if [ -f "$WORKSPACE/scripts/cron-wrapper.sh" ]; then
    echo "  cron-wrapper.sh存在 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  cron-wrapper.sh存在 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if [ -f "$WORKSPACE/scripts/cron-status.sh" ]; then
    echo "  cron-status.sh存在 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  cron-status.sh存在 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if [ -f "$WORKSPACE/scripts/daily-ai-insight.sh" ]; then
    echo "  daily-ai-insight.sh存在 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  daily-ai-insight.sh存在 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

echo "" | tee -a "$LOG_FILE"

# 3. 技能可用性检查
echo "【3. 技能可用性检查】" | tee -a "$LOG_FILE"

if [ -f "$WORKSPACE/skills/wps-skill/scripts/main.py" ]; then
    echo "  wps-skill技能 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  wps-skill技能 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if [ -f "$WORKSPACE/skills/smtp-sender/email_sender.py" ]; then
    echo "  smtp-sender技能 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  smtp-sender技能 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if [ -f "$WORKSPACE/skills/tavily-search/scripts/search.mjs" ]; then
    echo "  tavily-search技能 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  tavily-search技能 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

echo "" | tee -a "$LOG_FILE"

# 4. 定时任务检查
echo "【4. 定时任务检查】" | tee -a "$LOG_FILE"

if crontab -l 2>/dev/null | grep -q 'daily-ai-insight-6am'; then
    echo "  daily-ai-insight-6am配置 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  daily-ai-insight-6am配置 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if crontab -l 2>/dev/null | grep -q 'daily-ai-news-8am'; then
    echo "  daily-ai-news-8am配置 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  daily-ai-news-8am配置 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if crontab -l 2>/dev/null | grep -q 'system-health-check-21h'; then
    echo "  system-health-check-21h配置 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  system-health-check-21h配置 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

echo "" | tee -a "$LOG_FILE"

# 5. 磁盘空间检查
echo "【5. 磁盘空间检查】" | tee -a "$LOG_FILE"
DISK_USAGE=$(df -h "$WORKSPACE" | awk 'NR==2 {print $5}' | tr -d '%')
echo "  磁盘使用率: ${DISK_USAGE}%" | tee -a "$LOG_FILE"
if [ "$DISK_USAGE" -lt 90 ]; then
    echo "  磁盘空间充足 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  磁盘空间不足 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

echo "" | tee -a "$LOG_FILE"

# 生成报告
echo "【6. 测试报告】" | tee -a "$LOG_FILE"
echo "  通过: $PASSED" | tee -a "$LOG_FILE"
echo "  失败: $FAILED" | tee -a "$LOG_FILE"
echo "  总计: $((PASSED + FAILED))" | tee -a "$LOG_FILE"
if [ $((PASSED + FAILED)) -gt 0 ]; then
    echo "  通过率: $(( PASSED * 100 / (PASSED + FAILED) ))%" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"
echo "=== 健康检查完成 ===" | tee -a "$LOG_FILE"

exit $FAILED
