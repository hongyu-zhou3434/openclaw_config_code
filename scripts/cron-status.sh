#!/bin/bash
# 定时任务状态查询工具

WORKSPACE="/root/.openclaw/workspace"
LOGS_DIR="$WORKSPACE/logs"

show_header() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           OpenClaw 定时任务状态监控                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
}

show_task_status() {
    local task_name="$1"
    local status_file="/tmp/task_${task_name}.status"
    local start_file="${status_file}.start"
    local end_file="${status_file}.end"
    local duration_file="${status_file}.duration"
    
    echo "▶ $task_name"
    
    if [ -f "$status_file" ]; then
        local status=$(cat "$status_file" 2>/dev/null || echo "UNKNOWN")
        
        case "$status" in
            "RUNNING")
                echo "  状态: 🔄 运行中"
                if [ -f "$start_file" ]; then
                    local start_time=$(cat "$start_file")
                    local current_time=$(date +%s)
                    local elapsed=$((current_time - start_time))
                    local min=$((elapsed / 60))
                    local sec=$((elapsed % 60))
                    echo "  已运行: ${min}分${sec}秒"
                fi
                ;;
            "COMPLETED")
                echo "  状态: ✅ 已完成"
                if [ -f "$duration_file" ]; then
                    local duration=$(cat "$duration_file")
                    local min=$((duration / 60))
                    local sec=$((duration % 60))
                    echo "  执行耗时: ${min}分${sec}秒"
                fi
                ;;
            "FAILED")
                echo "  状态: ❌ 失败"
                if [ -f "${status_file}.code" ]; then
                    echo "  退出码: $(cat ${status_file}.code)"
                fi
                ;;
            *)
                echo "  状态: ⚠️ 未知"
                ;;
        esac
        
        # 显示最新日志
        local latest_log=$(ls -t "$LOGS_DIR/${task_name}"-*.log 2>/dev/null | head -1)
        if [ -n "$latest_log" ]; then
            echo "  最新日志: $(basename $latest_log)"
            echo "  日志大小: $(du -h $latest_log 2>/dev/null | cut -f1)"
        fi
    else
        echo "  状态: ⏸️ 未运行"
        echo "  下次执行: $(crontab -l 2>/dev/null | grep "$task_name" | awk '{print $1,$2}' | head -1)"
    fi
    echo ""
}

show_all_tasks() {
    show_header
    
    echo "📋 定时任务列表"
    echo "─────────────────────────────────────────────────────────────"
    echo ""
    
    # 显示crontab中的任务
    echo "Crontab 配置:"
    crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$" | nl -w2 -s'. ' | while read line; do
        echo "  $line"
    done
    echo ""
    
    # 显示各任务状态
    echo "任务执行状态:"
    echo "─────────────────────────────────────────────────────────────"
    echo ""
    
    show_task_status "daily-ai-insight-6am"
    show_task_status "daily-ai-news-8am"
    show_task_status "system-health-check-21h"
    
    # 显示日志统计
    echo "📊 日志统计:"
    echo "─────────────────────────────────────────────────────────────"
    echo ""
    
    local total_logs=$(find "$LOGS_DIR" -name "*.log" -type f 2>/dev/null | wc -l)
    local total_size=$(du -sh "$LOGS_DIR" 2>/dev/null | cut -f1)
    
    echo "  日志文件总数: $total_logs"
    echo "  日志总大小: $total_size"
    echo "  日志目录: $LOGS_DIR"
    echo ""
    
    # 显示最近执行的日志
    echo "🕐 最近执行的日志:"
    echo "─────────────────────────────────────────────────────────────"
    echo ""
    
    ls -lt "$LOGS_DIR"/*.log 2>/dev/null | head -5 | while read line; do
        echo "  $line"
    done
    echo ""
}

show_task_detail() {
    local task_name="$1"
    
    show_header
    
    echo "📄 任务详情: $task_name"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    # 显示crontab配置
    echo "Crontab 配置:"
    crontab -l 2>/dev/null | grep "$task_name" | sed 's/^/  /'
    echo ""
    
    # 显示状态
    local status_file="/tmp/task_${task_name}.status"
    if [ -f "$status_file" ]; then
        echo "执行状态:"
        cat "$status_file" | sed 's/^/  /'
        
        [ -f "${status_file}.start" ] && echo "  开始时间戳: $(cat ${status_file}.start)"
        [ -f "${status_file}.end" ] && echo "  结束时间戳: $(cat ${status_file}.end)"
        [ -f "${status_file}.duration" ] && echo "  执行时长: $(cat ${status_file}.duration)秒"
        [ -f "${status_file}.code" ] && echo "  退出码: $(cat ${status_file}.code)"
        echo ""
    fi
    
    # 显示日志
    echo "📜 执行日志:"
    local latest_log=$(ls -t "$LOGS_DIR/${task_name}"-*.log 2>/dev/null | head -1)
    if [ -n "$latest_log" ]; then
        echo "  日志文件: $latest_log"
        echo "  日志大小: $(du -h $latest_log 2>/dev/null | cut -f1)"
        echo ""
        echo "最新50行日志:"
        echo "─────────────────────────────────────────────────────────────"
        tail -50 "$latest_log" 2>/dev/null | sed 's/^/  /'
    else
        echo "  暂无日志文件"
    fi
    echo ""
}

# 主逻辑
case "$1" in
    "")
        show_all_tasks
        ;;
    "daily-ai-insight-6am"|"6am"|"6")
        show_task_detail "daily-ai-insight-6am"
        ;;
    "daily-ai-news-8am"|"8am"|"8")
        show_task_detail "daily-ai-news-8am"
        ;;
    "system-health-check-21h"|"21h"|"21"|"health")
        show_task_detail "system-health-check-21h"
        ;;
    "help"|"-h"|"--help")
        echo "用法: $0 [任务名]"
        echo ""
        echo "任务名:"
        echo "  (无)              显示所有任务状态"
        echo "  6am / 6           显示早6点AI洞察任务详情"
        echo "  8am / 8           显示早8点AI动态任务详情"
        echo "  21h / 21 / health 显示21点健康检查任务详情"
        echo "  help              显示此帮助"
        ;;
    *)
        echo "未知任务: $1"
        echo "使用 '$0 help' 查看帮助"
        exit 1
        ;;
esac
