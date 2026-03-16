#!/bin/bash
# 系统例行健康检查脚本 v1.2
# 执行时间: 每日 21:00
# 更新: 2026-03-16 - 添加所有技能可用性检查

WORKSPACE="/root/.openclaw/workspace"
OUTPUT_DIR="$WORKSPACE/output/health-checks/$(date +%Y-%m-%d)"
LOG_FILE="$OUTPUT_DIR/health-check.log"

mkdir -p "$OUTPUT_DIR"

echo "=== OpenClaw 系统健康检查 v1.2 ===" | tee "$LOG_FILE"
echo "时间: $(date)" | tee -a "$LOG_FILE"
echo "版本: 1.2.0" | tee -a "$LOG_FILE"
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

if [ -f "$WORKSPACE/scripts/daily-ai-news-8am.sh" ]; then
    echo "  daily-ai-news-8am.sh存在 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  daily-ai-news-8am.sh存在 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

echo "" | tee -a "$LOG_FILE"

# 3. 技能可用性检查 - 所有已安装技能
echo "【3. 技能可用性检查】" | tee -a "$LOG_FILE"

# 定义技能检查列表
declare -A SKILLS
declare -A SKILL_CMDS

SKILLS["agent-browser"]="Agent Browser"
SKILL_CMDS["agent-browser"]="test -f $WORKSPACE/skills/agent-browser/SKILL.md"

SKILLS["find-skills"]="Find Skills"
SKILL_CMDS["find-skills"]="test -f $WORKSPACE/skills/find-skills/SKILL.md"

SKILLS["github"]="GitHub"
SKILL_CMDS["github"]="test -f $WORKSPACE/skills/github/SKILL.md"

SKILLS["obsidian"]="Obsidian"
SKILL_CMDS["obsidian"]="test -f $WORKSPACE/skills/obsidian/SKILL.md"

SKILLS["openclaw-tavily-search"]="OpenClaw Tavily Search"
SKILL_CMDS["openclaw-tavily-search"]="test -f $WORKSPACE/skills/openclaw-tavily-search/SKILL.md"

SKILLS["self-improving-agent"]="Self Improving Agent"
SKILL_CMDS["self-improving-agent"]="test -f $WORKSPACE/skills/self-improving-agent/SKILL.md"

SKILLS["smtp-sender"]="SMTP Sender"
SKILL_CMDS["smtp-sender"]="test -f $WORKSPACE/skills/smtp-sender/email_sender.py"

SKILLS["summarize"]="Summarize"
SKILL_CMDS["summarize"]="test -f $WORKSPACE/skills/summarize/SKILL.md"

SKILLS["tavily-search"]="Tavily Search"
SKILL_CMDS["tavily-search"]="test -f $WORKSPACE/skills/tavily-search/scripts/search.mjs"

SKILLS["tencentcloud-lighthouse-skill"]="Tencent Cloud Lighthouse"
SKILL_CMDS["tencentcloud-lighthouse-skill"]="test -f $WORKSPACE/skills/tencentcloud-lighthouse-skill/SKILL.md"

SKILLS["tencent-cos-skill"]="Tencent COS"
SKILL_CMDS["tencent-cos-skill"]="test -f $WORKSPACE/skills/tencent-cos-skill/SKILL.md"

SKILLS["tencent-docs"]="Tencent Docs"
SKILL_CMDS["tencent-docs"]="test -f $WORKSPACE/skills/tencent-docs/SKILL.md"

SKILLS["weather"]="Weather"
SKILL_CMDS["weather"]="test -f $WORKSPACE/skills/weather/SKILL.md"

SKILLS["wps-skill"]="WPS Skill"
SKILL_CMDS["wps-skill"]="test -f $WORKSPACE/skills/wps-skill/scripts/main.py"

# 检查每个技能
SKILL_PASSED=0
SKILL_FAILED=0

for skill_key in "${!SKILLS[@]}"; do
    skill_name="${SKILLS[$skill_key]}"
    skill_cmd="${SKILL_CMDS[$skill_key]}"
    
    if eval "$skill_cmd" > /dev/null 2>&1; then
        echo "  $skill_name ... 通过" | tee -a "$LOG_FILE"
        ((SKILL_PASSED++))
        ((PASSED++))
    else
        echo "  $skill_name ... 失败" | tee -a "$LOG_FILE"
        ((SKILL_FAILED++))
        ((FAILED++))
    fi
done

echo "" | tee -a "$LOG_FILE"
echo "  技能检查统计: 通过 $SKILL_PASSED, 失败 $SKILL_FAILED" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 4. 依赖检查
echo "【4. 依赖检查】" | tee -a "$LOG_FILE"

if command -v python3 > /dev/null 2>&1; then
    echo "  Python3可用 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  Python3可用 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if command -v pip > /dev/null 2>&1; then
    echo "  pip可用 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  pip可用 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if command -v curl > /dev/null 2>&1; then
    echo "  curl可用 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  curl可用 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if command -v git > /dev/null 2>&1; then
    echo "  git可用 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  git可用 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

echo "" | tee -a "$LOG_FILE"

# 5. Python包检查
echo "【5. Python包检查】" | tee -a "$LOG_FILE"

if python3 -c 'import docx' 2>/dev/null; then
    echo "  python-docx包 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  python-docx包 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if python3 -c 'import openpyxl' 2>/dev/null; then
    echo "  openpyxl包 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  openpyxl包 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if python3 -c 'import pptx' 2>/dev/null; then
    echo "  python-pptx包 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  python-pptx包 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if python3 -c 'import markdown' 2>/dev/null; then
    echo "  markdown包 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  markdown包 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

echo "" | tee -a "$LOG_FILE"

# 6. API密钥检查
echo "【6. API密钥检查】" | tee -a "$LOG_FILE"

# 加载API密钥配置
if [ -f "$WORKSPACE/config/api-keys.sh" ]; then
    source "$WORKSPACE/config/api-keys.sh" > /dev/null 2>&1
fi

if [ -n "$TAVILY_API_KEY" ]; then
    echo "  Tavily API Key设置 ... 通过 (${TAVILY_API_KEY:0:20}...)" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  Tavily API Key设置 ... 失败 (未配置)" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if [ -n "$OPENAI_API_KEY" ]; then
    echo "  OpenAI API Key设置 ... 通过 (${OPENAI_API_KEY:0:20}...)" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  OpenAI API Key设置 ... 失败 (未配置)" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

echo "" | tee -a "$LOG_FILE"

# 7. 定时任务检查
echo "【7. 定时任务检查】" | tee -a "$LOG_FILE"

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

# 8. 网络连接检查
echo "【8. 网络连接检查】" | tee -a "$LOG_FILE"

if ssh -T git@github.com 2>&1 | grep -q 'successfully authenticated'; then
    echo "  GitHub SSH访问 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  GitHub SSH访问 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

if timeout 5 bash -c 'cat < /dev/null > /dev/tcp/smtp.qq.com/465' 2>/dev/null; then
    echo "  SMTP服务器连接 ... 通过" | tee -a "$LOG_FILE"
    ((PASSED++))
else
    echo "  SMTP服务器连接 ... 失败" | tee -a "$LOG_FILE"
    ((FAILED++))
fi

echo "" | tee -a "$LOG_FILE"

# 9. 磁盘空间检查
echo "【9. 磁盘空间检查】" | tee -a "$LOG_FILE"
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
echo "【10. 测试报告】" | tee -a "$LOG_FILE"
echo "  通过: $PASSED" | tee -a "$LOG_FILE"
echo "  失败: $FAILED" | tee -a "$LOG_FILE"
echo "  总计: $((PASSED + FAILED))" | tee -a "$LOG_FILE"
if [ $((PASSED + FAILED)) -gt 0 ]; then
    echo "  通过率: $(( PASSED * 100 / (PASSED + FAILED) ))%" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"

# GitHub同步
if [ $FAILED -eq 0 ]; then
    echo "【11. GitHub同步】" | tee -a "$LOG_FILE"
    echo "  测试全部通过，开始同步到 GitHub..." | tee -a "$LOG_FILE"
    
    cd "$WORKSPACE"
    
    # 检查是否有未提交的更改
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        git add -A 2>&1 | tee -a "$LOG_FILE"
        git commit -m "系统健康检查自动同步 - $(date +%Y-%m-%d)" 2>&1 | tee -a "$LOG_FILE" || true
        git push origin master 2>&1 | tee -a "$LOG_FILE" || echo "  ! GitHub推送可能需要手动处理" | tee -a "$LOG_FILE"
        echo "  同步完成" | tee -a "$LOG_FILE"
    else
        echo "  没有需要同步的更改" | tee -a "$LOG_FILE"
    fi
else
    echo "【11. GitHub同步】" | tee -a "$LOG_FILE"
    echo "  ! 测试有 $FAILED 项失败，跳过同步" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"
echo "=== 健康检查完成 ===" | tee -a "$LOG_FILE"
echo "退出码: $FAILED" | tee -a "$LOG_FILE"

exit $FAILED
