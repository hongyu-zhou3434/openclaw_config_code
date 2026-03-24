#!/bin/bash
# 检查文件是否需要上传到 GitHub
# 根据系统配置的策略决定

CONFIG_FILE="/root/.openclaw/workspace/config/github-upload-policy.json"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查配置文件
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}错误: 配置文件不存在: $CONFIG_FILE${NC}"
    exit 1
fi

# 获取文件类别
check_category() {
    local file="$1"
    local filename=$(basename "$file")
    local extension="${filename##*.}"
    
    # 系统配置
    if [[ "$file" == *"config/"* ]] && [[ "$extension" == "json" ]]; then
        echo "system_config"
        return
    fi
    
    # Skill 开发
    if [[ "$file" == *"skills/"* ]]; then
        echo "skill_development"
        return
    fi
    
    # 文档
    if [[ "$file" == *"docs/"* ]] || [[ "$filename" == "README.md" ]] || [[ "$filename" == "SKILL.md" ]]; then
        echo "documentation"
        return
    fi
    
    # 代码分析报告
    if [[ "$file" == *"reports/"* ]]; then
        echo "code_analysis_report"
        return
    fi
    
    # 日志
    if [[ "$file" == *"logs/"* ]] || [[ "$extension" == "log" ]]; then
        echo "task_execution_log"
        return
    fi
    
    # 临时文件
    if [[ "$file" == "/tmp/"* ]]; then
        echo "temporary_files"
        return
    fi
    
    # 其他
    echo "other"
}

# 检查是否需要上传
should_upload() {
    local category="$1"
    
    # 使用 jq 查询策略（如果可用）
    if command -v jq &> /dev/null; then
        local upload=$(jq -r ".policy.upload_to_github.rules[] | select(.category == \"$category\") | .upload" "$CONFIG_FILE" 2>/dev/null)
        if [ "$upload" == "true" ]; then
            echo "true"
        else
            echo "false"
        fi
    else
        # 默认策略
        case "$category" in
            "system_config"|"skill_development"|"documentation")
                echo "true"
                ;;
            "code_analysis_report"|"task_execution_log"|"temporary_files"|"user_data"|"other")
                echo "false"
                ;;
            *)
                echo "false"
                ;;
        esac
    fi
}

# 主函数
main() {
    if [ $# -lt 1 ]; then
        echo "用法: $0 <文件路径>"
        echo "示例: $0 config/system-policy.json"
        exit 1
    fi
    
    local file="$1"
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              GitHub 上传策略检查                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    if [ ! -e "$file" ]; then
        echo -e "${RED}错误: 文件不存在: $file${NC}"
        exit 1
    fi
    
    echo "📄 文件: $file"
    
    # 获取类别
    local category=$(check_category "$file")
    echo "📂 类别: $category"
    
    # 检查是否需要上传
    local upload=$(should_upload "$category")
    
    echo ""
    if [ "$upload" == "true" ]; then
        echo -e "${GREEN}✅ 需要上传到 GitHub${NC}"
        echo "   原因: 系统配置/Skill开发/文档类操作"
        echo ""
        echo "💡 执行命令:"
        echo "   git add \"$file\""
        echo "   git commit -m '更新配置'"
        echo "   git push origin main"
        exit 0
    else
        echo -e "${YELLOW}⚠️  不需要上传到 GitHub${NC}"
        echo "   原因: 非系统配置类操作"
        echo "   建议: 仅本地保存或发送到邮箱"
        exit 1
    fi
}

main "$@"
