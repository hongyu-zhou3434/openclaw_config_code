#!/bin/bash
# 系统配置自动通知脚本
# 功能: 向QQ邮箱发送系统配置更新通知

set -e

WORKSPACE="/root/.openclaw/workspace"
EMAIL_SCRIPT="$WORKSPACE/skills/smtp-sender/email_sender.py"
CONFIG_FILE="$WORKSPACE/skills/smtp-sender/smtp-config.json"

# 检查配置
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: SMTP配置不存在: $CONFIG_FILE"
    exit 1
fi

# 读取配置（简单检查）
if grep -q "your_qq_number@qq.com" "$CONFIG_FILE"; then
    echo "Error: 请先配置QQ邮箱地址和授权码"
    echo "配置文件: $CONFIG_FILE"
    exit 1
fi

# 获取系统信息
DATE_STR=$(date +%Y年%m月%d日)
TIME_STR=$(date +%H:%M:%S)
HOSTNAME=$(hostname)

# 生成邮件内容
SUBJECT="OpenClaw系统配置更新通知 - $DATE_STR"
BODY="OpenClaw系统配置已更新

更新时间: $DATE_STR $TIME_STR
服务器: $HOSTNAME

本次更新内容:
- 系统配置已同步到GitHub
- 技能状态已更新
- 定时任务已配置

详细信息请查看附件或GitHub仓库。

---
本邮件由OpenClaw系统自动发送"

# 发送邮件（基础版本，不带附件）
python3 "$EMAIL_SCRIPT" \
    --to "$1" \
    --subject "$SUBJECT" \
    --body "$BODY" \
    2>&1

echo "✓ 邮件发送完成"
