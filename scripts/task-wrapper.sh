#!/bin/bash
# 任务执行包装器
# 自动捕获任务执行结果并发送通知

set -e

# 配置
TASK_NOTIFICATION_POLICY="/root/.openclaw/workspace/config/task-notification-policy.json"
LOG_DIR="/root/.openclaw/workspace/logs"
NOTIFICATION_SCRIPT="/root/.openclaw/workspace/scripts/send-task-notification.sh"

# 确保日志目录存在
mkdir -p "$LOG_DIR"

# 参数检查
if [ $# -lt 1 ]; then
    echo "用法: $0 <任务名称> [命令...]"
    echo "示例: $0 'Wan2.1代码分析' python3 analyze.py"
    exit 1
fi

TASK_NAME="$1"
shift
TASK_COMMAND="$@"

# 生成任务ID
TASK_ID="task_$(date +%Y%m%d_%H%M%S)_$$"
LOG_FILE="$LOG_DIR/${TASK_ID}.log"

# 记录开始时间
START_TIME=$(date +%s)
START_TIME_FORMATTED=$(date '+%Y-%m-%d %H:%M:%S')

echo "═══════════════════════════════════════════════════════════"
echo "📋 任务开始: $TASK_NAME"
echo "🕐 开始时间: $START_TIME_FORMATTED"
echo "📝 任务ID: $TASK_ID"
echo "═══════════════════════════════════════════════════════════"

# 执行命令并捕获输出
EXIT_CODE=0
if [ -n "$TASK_COMMAND" ]; then
    echo "执行命令: $TASK_COMMAND"
    echo ""
    
    # 执行命令并记录日志
    if eval "$TASK_COMMAND" 2>&1 | tee "$LOG_FILE"; then
        EXIT_CODE=0
    else
        EXIT_CODE=${PIPESTATUS[0]}
    fi
else
    echo "警告: 未提供执行命令"
    EXIT_CODE=1
fi

# 记录结束时间
END_TIME=$(date +%s)
END_TIME_FORMATTED=$(date '+%Y-%m-%d %H:%M:%S')
DURATION=$((END_TIME - START_TIME))
DURATION_FORMATTED="$(printf '%02d:%02d:%02d' $((DURATION/3600)) $((DURATION%3600/60)) $((DURATION%60)))"

# 判断任务状态
if [ $EXIT_CODE -eq 0 ]; then
    TASK_STATUS="success"
    STATUS_ICON="✅"
    STATUS_TEXT="成功"
elif [ $EXIT_CODE -eq 124 ] || [ $EXIT_CODE -eq 137 ]; then
    TASK_STATUS="timeout"
    STATUS_ICON="⏱️"
    STATUS_TEXT="超时"
elif [ $EXIT_CODE -eq 126 ] || [ $EXIT_CODE -eq 127 ]; then
    TASK_STATUS="failed"
    STATUS_ICON="❌"
    STATUS_TEXT="命令未找到"
else
    TASK_STATUS="failed"
    STATUS_ICON="❌"
    STATUS_TEXT="失败"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "$STATUS_ICON 任务结束: $TASK_NAME"
echo "📊 执行状态: $STATUS_TEXT (退出码: $EXIT_CODE)"
echo "🕐 结束时间: $END_TIME_FORMATTED"
echo "⏱️  执行时长: $DURATION_FORMATTED"
echo "📝 日志文件: $LOG_FILE"
echo "═══════════════════════════════════════════════════════════"

# 准备通知内容
NOTIFICATION_TITLE="$STATUS_ICON 任务执行结果: $TASK_NAME"
NOTIFICATION_CONTENT="任务名称: $TASK_NAME
执行状态: $STATUS_TEXT
退出码: $EXIT_CODE
开始时间: $START_TIME_FORMATTED
结束时间: $END_TIME_FORMATTED
执行时长: $DURATION_FORMATTED
任务ID: $TASK_ID"

# 如果有错误，添加错误信息
if [ $EXIT_CODE -ne 0 ] && [ -f "$LOG_FILE" ]; then
    ERROR_PREVIEW=$(tail -20 "$LOG_FILE" | grep -E "(error|Error|ERROR|failed|Failed|FAIL)" | head -5)
    if [ -n "$ERROR_PREVIEW" ]; then
        NOTIFICATION_CONTENT="$NOTIFICATION_CONTENT

错误预览:
$error_PREVIEW"
    fi
fi

# 发送通知
echo ""
echo "📤 发送任务通知..."
if [ -f "$NOTIFICATION_SCRIPT" ]; then
    bash "$NOTIFICATION_SCRIPT" \
        --task-name "$TASK_NAME" \
        --task-status "$TASK_STATUS" \
        --title "$NOTIFICATION_TITLE" \
        --content "$NOTIFICATION_CONTENT" \
        --log-file "$LOG_FILE" \
        --duration "$DURATION" \
        2>/dev/null || echo "通知发送失败，但任务已完成"
else
    # 直接调用企业微信消息
    echo "发送企业微信消息..."
    mcporter call wecom-msg.send_message \
        --args "{\"chat_type\":1,\"chatid\":\"ZhouHongYu\",\"msgtype\":\"text\",\"text\":{\"content\":\"$NOTIFICATION_TITLE\n\n$NOTIFICATION_CONTENT\"}}" \
        --output json 2>/dev/null || echo "通知发送失败"
fi

# 返回原始退出码
exit $EXIT_CODE
