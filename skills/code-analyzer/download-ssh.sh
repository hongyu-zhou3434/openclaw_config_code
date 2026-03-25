#!/bin/bash
# SSH 方式下载 GitHub 代码
# 使用 git@github.com 地址

REPO_SSH="$1"
BRANCH="${2:-main}"
WORK_DIR="/tmp/code-analysis"

if [ -z "$REPO_SSH" ]; then
    echo "🔍 SSH 代码下载工具"
    echo ""
    echo "用法:"
    echo "  $0 <SSH地址> [分支名]"
    echo ""
    echo "示例:"
    echo "  $0 git@github.com:Wan-Video/Wan2.2.git"
    echo "  $0 git@github.com:Wan-Video/Wan2.2.git main"
    echo ""
    echo "注意: 需要配置 SSH 密钥到 GitHub"
    exit 1
fi

# 提取仓库名
REPO_NAME=$(basename "$REPO_SSH" .git)
TARGET_DIR="$WORK_DIR/$REPO_NAME"

echo "🔍 SSH 代码下载工具"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "仓库: $REPO_SSH"
echo "分支: $BRANCH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查 SSH 密钥
if [ ! -f ~/.ssh/id_ed25519 ] && [ ! -f ~/.ssh/id_rsa ]; then
    echo ""
    echo "⚠️  未找到 SSH 密钥"
    echo ""
    echo "🔧 生成 SSH 密钥..."
    ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_ed25519 -N ""
    echo ""
    echo "📋 请将以下公钥添加到 GitHub:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat ~/.ssh/id_ed25519.pub
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "添加步骤:"
    echo "1. 访问 https://github.com/settings/keys"
    echo "2. 点击 'New SSH key'"
    echo "3. 粘贴上面的公钥"
    echo "4. 点击 'Add SSH key'"
    echo ""
    echo "完成后重新运行此脚本"
    exit 1
fi

# 配置 SSH
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 添加 GitHub 到 known_hosts
if ! grep -q "github.com" ~/.ssh/known_hosts 2>/dev/null; then
    echo "🔧 添加 GitHub 到 known_hosts..."
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts 2>/dev/null
fi

# 清理旧目录
if [ -d "$TARGET_DIR" ]; then
    echo "🧹 清理旧目录..."
    rm -rf "$TARGET_DIR"
fi

mkdir -p "$WORK_DIR"

echo ""
echo "📥 开始下载 (SSH方式)..."

# 尝试克隆
if git clone --depth 1 -b "$BRANCH" "$REPO_SSH" "$TARGET_DIR" 2>&1; then
    echo "✅ SSH 克隆成功"
elif git clone --depth 1 -b master "$REPO_SSH" "$TARGET_DIR" 2>&1; then
    echo "✅ SSH 克隆成功 (master分支)"
elif git clone --depth 1 "$REPO_SSH" "$TARGET_DIR" 2>&1; then
    echo "✅ SSH 克隆成功 (默认分支)"
else
    echo ""
    echo "❌ SSH 克隆失败"
    echo ""
    echo "可能原因:"
    echo "1. SSH 密钥未添加到 GitHub"
    echo "2. 仓库不存在或没有访问权限"
    echo "3. 网络连接问题"
    echo ""
    echo "💡 请检查:"
    echo "   ssh -T git@github.com"
    exit 1
fi

# 验证下载
echo ""
echo "🔍 验证下载..."
FILE_COUNT=$(find "$TARGET_DIR" -type f -not -path "*/.git/*" 2>/dev/null | wc -l)

if [ "$FILE_COUNT" -eq 0 ]; then
    echo "❌ 下载目录为空"
    exit 1
fi

echo "✅ 下载完成"
echo "   📄 文件数: $FILE_COUNT"
echo "   📁 目录: $TARGET_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SSH 下载成功!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
