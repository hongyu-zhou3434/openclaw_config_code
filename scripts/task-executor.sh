#!/bin/bash
# OpenClaw 统一任务执行器
# 读取配置文件执行任务，支持邮件发送

set -e

# 配置
WORKSPACE="/root/.openclaw/workspace"
CONFIG_FILE="$WORKSPACE/config/task-config.json"
TASK_NAME="$1"

# 检查参数
if [ -z "$TASK_NAME" ]; then
    echo "用法: $0 <任务名称>"
    echo "可用任务:"
    python3 -c "import json; data=json.load(open('$CONFIG_FILE')); [print(f'  - {k}') for k in data['tasks'].keys()]" 2>/dev/null || echo "  (无法读取配置)"
    exit 1
fi

# 读取配置
if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误: 配置文件不存在: $CONFIG_FILE"
    exit 1
fi

# 获取任务配置
TASK_CONFIG=$(python3 -c "
import json
import sys
try:
    with open('$CONFIG_FILE') as f:
        config = json.load(f)
    task = config['tasks'].get('$TASK_NAME')
    if task:
        print(json.dumps(task))
    else:
        sys.exit(1)
except Exception as e:
    print(f'错误: {e}', file=sys.stderr)
    sys.exit(1)
" 2>&1)

if [ $? -ne 0 ]; then
    echo "错误: 未找到任务配置: $TASK_NAME"
    exit 1
fi

# 解析配置
OUTPUT_DIR=$(echo "$TASK_CONFIG" | python3 -c "import json,sys; print(json.load(sys.stdin)['output_dir'])")
EMAIL_ENABLED=$(echo "$TASK_CONFIG" | python3 -c "import json,sys; print(json.load(sys.stdin)['email']['enabled'])")
EMAIL_RECIPIENTS=$(echo "$TASK_CONFIG" | python3 -c "import json,sys; print(','.join(json.load(sys.stdin)['email']['recipients']))")
SUBJECT_PREFIX=$(echo "$TASK_CONFIG" | python3 -c "import json,sys; print(json.load(sys.stdin)['email']['subject_prefix'])")
SEND_PDF=$(echo "$TASK_CONFIG" | python3 -c "import json,sys; print(json.load(sys.stdin)['email'].get('send_pdf','false'))")
SEND_MD=$(echo "$TASK_CONFIG" | python3 -c "import json,sys; print(json.load(sys.stdin)['email'].get('send_md','false'))")
RETENTION_DAYS=$(echo "$TASK_CONFIG" | python3 -c "import json,sys; print(json.load(sys.stdin).get('retention_days',30))")

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           OpenClaw 任务执行器                                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "任务名称: $TASK_NAME"
echo "输出目录: $OUTPUT_DIR"
echo "邮件发送: $EMAIL_ENABLED"
echo ""

# 创建输出目录
mkdir -p "$OUTPUT_DIR/$(date +%Y-%m-%d)"

# 执行任务脚本（由cron-wrapper调用）
# 这里主要是处理邮件发送逻辑

# 发送邮件函数
send_report_email() {
    local report_dir="$1"
    local date_str="$2"
    
    if [ "$EMAIL_ENABLED" != "true" ]; then
        echo "邮件发送已禁用"
        return 0
    fi
    
    echo "准备发送邮件..."
    
    # 查找报告文件
    local attachments=""
    
    if [ "$SEND_MD" = "true" ]; then
        for f in "$report_dir"/*.md; do
            [ -f "$f" ] && attachments="$attachments $f"
        done
    fi
    
    if [ "$SEND_PDF" = "true" ]; then
        for f in "$report_dir"/*.pdf; do
            [ -f "$f" ] && attachments="$attachments $f"
        done
    fi
    
    if [ -z "$attachments" ]; then
        echo "未找到附件文件"
        return 1
    fi
    
    # 发送邮件
    cd "$report_dir"
    python3 "$WORKSPACE/scripts/send_email_with_progress.py" \
        --to "$EMAIL_RECIPIENTS" \
        --subject "$SUBJECT_PREFIX - $date_str" \
        --body "您好！

$SUBJECT_PREFIX 已生成。

报告日期: $date_str
生成时间: $(date '+%H:%M:%S')

请查看附件中的报告文件。

---
本邮件由 OpenClaw AI 系统自动发送" \
        --attachments $attachments
    
    return $?
}

# 清理旧文件
cleanup_old_files() {
    echo "清理${RETENTION_DAYS}天前的旧报告..."
    find "$OUTPUT_DIR" -type d -mtime +$RETENTION_DAYS -exec rm -rf {} + 2>/dev/null || true
    echo "清理完成"
}

# 导出函数供其他脚本使用
export -f send_report_email cleanup_old_files
export WORKSPACE OUTPUT_DIR EMAIL_ENABLED EMAIL_RECIPIENTS SUBJECT_PREFIX

echo "任务执行器准备就绪"
echo ""
