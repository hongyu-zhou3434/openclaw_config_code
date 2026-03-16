#!/bin/bash
# OpenClaw 定时任务统一包装器
# 功能: 为所有定时任务添加监控、日志和进度反馈

set -e

# 配置
WORKSPACE="/root/.openclaw/workspace"
SCRIPTS_DIR="$WORKSPACE/scripts"
LOGS_DIR="$WORKSPACE/logs"
TASK_NAME="$1"
TASK_SCRIPT="$2"

# 日志函数（使用emoji代替颜色）
log_info() {
    echo "[INFO] $(date '+%H:%M:%S') $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo "[SUCCESS] $(date '+%H:%M:%S') ✅ $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo "[WARNING] $(date '+%H:%M:%S') ⚠️ $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[ERROR] $(date '+%H:%M:%S') ❌ $1" | tee -a "$LOG_FILE"
}

log_step() {
    echo "[STEP $1] $(date '+%H:%M:%S') ▶ $2" | tee -a "$LOG_FILE"
}

# 检查参数
if [ -z "$TASK_NAME" ] || [ -z "$TASK_SCRIPT" ]; then
    echo "用法: $0 <任务名称> <任务脚本路径>"
    echo "示例: $0 daily-ai-insight-6am /path/to/script.sh"
    exit 1
fi

# 创建日志目录
mkdir -p "$LOGS_DIR"
LOG_FILE="$LOGS_DIR/${TASK_NAME}-$(date +%Y%m%d-%H%M%S).log"
STATUS_FILE="/tmp/task_${TASK_NAME}.status"

# 记录开始
START_TIME=$(date +%s)
echo "RUNNING" > "$STATUS_FILE"
echo "$START_TIME" > "${STATUS_FILE}.start"

cat << 'EOF' | tee -a "$LOG_FILE"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║           OpenClaw 定时任务执行监控                          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF

log_info "任务名称: $TASK_NAME"
log_info "执行脚本: $TASK_SCRIPT"
log_info "开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
log_info "日志文件: $LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 检查脚本存在
log_step "1/5" "检查任务脚本..."
if [ ! -f "$TASK_SCRIPT" ]; then
    log_error "脚本不存在: $TASK_SCRIPT"
    echo "FAILED" > "$STATUS_FILE"
    echo "$(date +%s)" > "${STATUS_FILE}.end"
    exit 1
fi
if [ ! -x "$TASK_SCRIPT" ]; then
    log_warning "脚本无执行权限，正在添加..."
    chmod +x "$TASK_SCRIPT"
fi
log_success "脚本检查通过"
echo "" | tee -a "$LOG_FILE"

# 检查依赖环境
log_step "2/5" "检查依赖环境..."
MISSING_DEPS=()

# 检查必要的命令
for cmd in python3 curl; do
    if ! command -v $cmd &> /dev/null; then
        MISSING_DEPS+=($cmd)
    fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    log_error "缺少依赖: ${MISSING_DEPS[*]}"
    echo "FAILED" > "$STATUS_FILE"
    exit 1
fi
log_success "依赖检查通过"
echo "" | tee -a "$LOG_FILE"

# 预执行检查
log_step "3/5" "预执行检查..."
DISK_USAGE=$(df -h "$WORKSPACE" | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$DISK_USAGE" -gt 90 ]; then
    log_warning "磁盘使用率超过90%: ${DISK_USAGE}%"
else
    log_info "磁盘使用率: ${DISK_USAGE}%"
fi
log_success "预检查完成"
echo "" | tee -a "$LOG_FILE"

# 执行任务
log_step "4/5" "执行任务脚本..."
echo "═══════════════════════════════════════════════════════════════" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 使用script命令记录所有输出（如果有）
if command -v script &> /dev/null; then
    script -q -c "$TASK_SCRIPT" /dev/null 2>&1 | tee -a "$LOG_FILE" || {
        EXIT_CODE=$?
        log_error "任务执行失败 (退出码: $EXIT_CODE)"
        echo "FAILED" > "$STATUS_FILE"
        echo "$(date +%s)" > "${STATUS_FILE}.end"
        echo "$EXIT_CODE" > "${STATUS_FILE}.code"
        
        # 发送失败通知
        send_failure_notification
        exit $EXIT_CODE
    }
else
    # 直接执行
    "$TASK_SCRIPT" 2>&1 | tee -a "$LOG_FILE" || {
        EXIT_CODE=$?
        log_error "任务执行失败 (退出码: $EXIT_CODE)"
        echo "FAILED" > "$STATUS_FILE"
        echo "$(date +%s)" > "${STATUS_FILE}.end"
        echo "$EXIT_CODE" > "${STATUS_FILE}.code"
        
        # 发送失败通知
        send_failure_notification
        exit $EXIT_CODE
    }
fi

echo "" | tee -a "$LOG_FILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$LOG_FILE"
log_success "任务执行完成"
echo "" | tee -a "$LOG_FILE"

# 后处理
log_step "5/5" "执行后处理..."

# 计算执行时间
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

# 更新状态
echo "COMPLETED" > "$STATUS_FILE"
echo "$END_TIME" > "${STATUS_FILE}.end"
echo "$DURATION" > "${STATUS_FILE}.duration"

# 生成执行摘要
SUMMARY_FILE="$LOGS_DIR/${TASK_NAME}-latest-summary.txt"
cat > "$SUMMARY_FILE" << EOF
任务名称: $TASK_NAME
执行时间: $(date '+%Y-%m-%d %H:%M:%S')
执行耗时: ${MINUTES}分${SECONDS}秒
执行状态: 成功
日志文件: $LOG_FILE
EOF

log_success "后处理完成"
echo "" | tee -a "$LOG_FILE"

# 输出最终汇总
cat << EOF | tee -a "$LOG_FILE"
╔══════════════════════════════════════════════════════════════╗
║                     任务执行完成                              ║
╠══════════════════════════════════════════════════════════════╣
║  任务名称: $TASK_NAME
║  执行耗时: ${MINUTES}分${SECONDS}秒
║  结束时间: $(date '+%Y-%m-%d %H:%M:%S')
║  日志文件: $LOG_FILE
╚══════════════════════════════════════════════════════════════╝
EOF

# 清理旧日志（保留30天）
find "$LOGS_DIR" -name "${TASK_NAME}-*.log" -mtime +30 -delete 2>/dev/null || true

exit 0

# 发送失败通知函数
send_failure_notification() {
    local email="273477656@qq.com"
    local subject="定时任务执行失败 - $TASK_NAME"
    local body="任务执行失败通知

任务名称: $TASK_NAME
执行时间: $(date '+%Y-%m-%d %H:%M:%S')
退出码: $EXIT_CODE
日志文件: $LOG_FILE

请检查日志了解详细错误信息。

---
OpenClaw 系统监控"

    # 如果邮件工具可用，发送通知
    if [ -f "$WORKSPACE/skills/smtp-sender/email_sender.py" ]; then
        python3 "$WORKSPACE/skills/smtp-sender/email_sender.py" \
            --to "$email" \
            --subject "$subject" \
            --body "$body" \
            --attachments "$LOG_FILE" 2>/dev/null || true
    fi
}
