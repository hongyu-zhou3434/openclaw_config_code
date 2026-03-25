#!/bin/bash
# SSH 方式下载并分析 GitHub 代码

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_SSH="$1"
BRANCH="${2:-main}"

if [ -z "$REPO_SSH" ]; then
    echo "🔍 SSH 代码分析工具"
    echo ""
    echo "用法:"
    echo "  $0 <SSH地址> [分支名]"
    echo ""
    echo "示例:"
    echo "  $0 git@github.com:Wan-Video/Wan2.2.git"
    echo ""
    echo "SSH 地址格式:"
    echo "  git@github.com:用户名/仓库名.git"
    echo ""
    echo "注意: 需要先将 SSH 公钥添加到 GitHub"
    echo "      https://github.com/settings/keys"
    exit 1
fi

echo "🔍 SSH 代码分析工具"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "仓库: $REPO_SSH"
echo "分支: $BRANCH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 第1步: SSH 下载
echo ""
echo "📥 第1步: SSH 下载..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TARGET_DIR=$($SCRIPT_DIR/download-ssh.sh "$REPO_SSH" "$BRANCH" 2>&1 | grep "^✅ 下载完成" | awk '{print $NF}')

if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
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
