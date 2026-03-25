#!/bin/bash
# GitHub 代码下载并分析 - 完整流程

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL="$1"
BRANCH="${2:-main}"

if [ -z "$REPO_URL" ]; then
    echo "🔍 GitHub 代码分析工具"
    echo ""
    echo "用法:"
    echo "  $0 <GitHub仓库URL> [分支名]"
    echo ""
    echo "示例:"
    echo "  $0 https://github.com/Wan-Video/Wan2.2.git"
    echo "  $0 https://github.com/Wan-Video/Wan2.2.git main"
    echo ""
    exit 1
fi

echo "🔍 GitHub 代码分析工具"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "仓库: $REPO_URL"
echo "分支: $BRANCH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 第1步: 下载代码
echo ""
echo "📥 第1步: 下载代码..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TARGET_DIR=$("$SCRIPT_DIR/download-github.sh" "$REPO_URL" "$BRANCH" 2>&1 | tail -1)

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ 下载失败"
    exit 1
fi

echo "✅ 代码下载完成: $TARGET_DIR"

# 第2步: 分析代码
echo ""
echo "🔍 第2步: 分析代码..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$SCRIPT_DIR"
node analyze-local.js "$TARGET_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 全部完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
