#!/bin/bash
# 自动下载代码工具
# 根据提示词自动识别并调用下载

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 解析提示词中的 GitHub URL
parse_github_url() {
    local input="$1"
    
    # 匹配 GitHub URL 模式
    if [[ $input =~ https://github.com/[^/]+/[^/]+ ]]; then
        echo "${BASH_REMATCH[0]}"
    elif [[ $input =~ git@github.com:[^/]+/[^/]+ ]]; then
        echo "${BASH_REMATCH[0]}"
    fi
}

# 主函数
main() {
    local input="$*"
    
    echo "🔍 自动代码下载工具"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "输入: $input"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 解析 URL
    local url=$(parse_github_url "$input")
    
    if [ -z "$url" ]; then
        echo "❌ 未检测到 GitHub 仓库 URL"
        echo ""
        echo "支持的格式:"
        echo "  - https://github.com/username/repo.git"
        echo "  - https://github.com/username/repo"
        echo "  - git@github.com:username/repo.git"
        exit 1
    fi
    
    echo "✅ 检测到仓库: $url"
    echo ""
    
    # 调用下载工具
    "$SCRIPT_DIR/download-code" "$url"
}

# 运行
main "$@"
