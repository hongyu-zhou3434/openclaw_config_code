#!/bin/bash
# 发送任务执行结果通知

# 参数解析
TASK_NAME=""
TASK_STATUS=""
TITLE=""
CONTENT=""
LOG_FILE=""
DURATION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --task-name)
            TASK_NAME="$2"
            shift 2
            ;;
        --task-status)
            TASK_STATUS="$2"
            shift 2
            ;;
        --title)
            TITLE="$2"
            shift 2
            ;;
        --content)
            CONTENT="$2"
            shift 2
            ;;
        --log-file)
            LOG_FILE="$2"
            shift 2
            ;;
        --duration)
            DURATION="$2"
            shift 2
            ;;
        *)
            echo "未知参数: $1"
            shift
            ;;
    esac
done

# 检查必要参数
if [ -z "$TITLE" ] || [ -z "$CONTENT" ]; then
    echo "错误: 缺少必要参数"
    exit 1
fi

# 发送企业微信消息
echo "📤 发送企业微信消息通知..."

# 构建消息内容（Markdown格式）
MESSAGE="📋 任务执行结果通知

$TITLE

━━━━━━━━━━━━━━━━━━━━━

$CONTENT

━━━━━━━━━━━━━━━━━━━━━

⏱️ 通知时间: $(date '+%Y-%m-%d %H:%M:%S')"

# 使用 mcporter 发送企业微信消息
mcporter call wecom-msg.send_message \
    --args "{\"chat_type\":1,\"chatid\":\"ZhouHongYu\",\"msgtype\":\"text\",\"text\":{\"content\":\"$MESSAGE\"}}" \
    --output json 2>/dev/null

WECHAT_RESULT=$?

if [ $WECHAT_RESULT -eq 0 ]; then
    echo "✅ 企业微信消息发送成功"
else
    echo "⚠️ 企业微信消息发送失败"
fi

# 如果任务失败或超时，同时发送邮件
if [ "$TASK_STATUS" == "failed" ] || [ "$TASK_STATUS" == "timeout" ]; then
    echo "📧 发送邮件通知..."
    
    EMAIL_SUBJECT="$TITLE"
    EMAIL_BODY="$CONTENT

━━━━━━━━━━━━━━━━━━━━━
详细日志请查看附件。"
    
    # 发送邮件（如果有日志文件）
    if [ -f "$LOG_FILE" ]; then
        python3 /root/.openclaw/workspace/skills/smtp-sender/email_sender.py \
            --to "273477656@qq.com" \
            --subject "$EMAIL_SUBJECT" \
            --body "$EMAIL_BODY" \
            --attachments "$LOG_FILE" \
            2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "✅ 邮件发送成功"
        else
            echo "⚠️ 邮件发送失败"
        fi
    else
        echo "⚠️ 日志文件不存在，跳过邮件发送"
    fi
fi

echo "✅ 通知发送完成"
