#!/bin/bash
# 下载并分析代码脚本
# 使用分步下载确保成功率

set -e

REPO_URL="$1"
BRANCH="${2:-main}"
WORK_DIR="/tmp/code-analysis"
REPORT_DIR="/root/.openclaw/workspace/skills/code-analyzer/reports"

if [ -z "$REPO_URL" ]; then
    echo "用法: $0 <GitHub仓库URL> [分支名]"
    echo "示例: $0 https://github.com/Wan-Video/Wan2.2.git"
    exit 1
fi

REPO_NAME=$(basename "$REPO_URL" .git)
TARGET_DIR="$WORK_DIR/$REPO_NAME"

echo "🔍 代码下载与分析工具"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "仓库: $REPO_URL"
echo "分支: $BRANCH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 配置 Git
echo "🔧 配置 Git 优化..."
git config --global http.postBuffer 524288000 2>/dev/null || true
git config --global http.maxRequestBuffer 100M 2>/dev/null || true
git config --global http.lowSpeedLimit 1000 2>/dev/null || true
git config --global http.lowSpeedTime 60 2>/dev/null || true

# 清理旧目录
if [ -d "$TARGET_DIR" ]; then
    echo "🧹 清理旧目录..."
    rm -rf "$TARGET_DIR"
fi

mkdir -p "$WORK_DIR"

# 尝试下载
echo "📥 开始下载..."

# 方案1: 浅克隆
echo "🔄 方案1: Git 浅克隆..."
if git clone --depth 1 -b "$BRANCH" "$REPO_URL" "$TARGET_DIR" 2>/dev/null; then
    echo "✅ Git 克隆成功"
else
    echo "⚠️ 方案1失败，尝试方案2..."
    
    # 方案2: 尝试 master 分支
    echo "🔄 方案2: 尝试 master 分支..."
    if git clone --depth 1 -b master "$REPO_URL" "$TARGET_DIR" 2>/dev/null; then
        echo "✅ Git 克隆成功 (master分支)"
    else
        echo "⚠️ 方案2失败，尝试方案3..."
        
        # 方案3: 下载 ZIP
        echo "🔄 方案3: 下载 ZIP 包..."
        ZIP_URL="${REPO_URL%.git}/archive/refs/heads/${BRANCH}.zip"
        ZIP_FILE="$WORK_DIR/${REPO_NAME}.zip"
        
        if wget -q --timeout=120 --tries=3 "$ZIP_URL" -O "$ZIP_FILE" 2>/dev/null; then
            echo "✅ ZIP 下载成功"
            unzip -q "$ZIP_FILE" -d "$WORK_DIR"
            mv "$WORK_DIR/${REPO_NAME}-${BRANCH}" "$TARGET_DIR"
            rm -f "$ZIP_FILE"
            echo "✅ ZIP 解压完成"
        else
            echo "❌ 所有下载方案均失败"
            exit 1
        fi
    fi
fi

# 验证下载
if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ 下载目录不存在"
    exit 1
fi

FILE_COUNT=$(find "$TARGET_DIR" -type f -not -path "*/.git/*" | wc -l)
if [ "$FILE_COUNT" -eq 0 ]; then
    echo "❌ 下载目录为空"
    exit 1
fi

echo "✅ 下载验证通过，包含 $FILE_COUNT 个文件"

# 分析代码
echo ""
echo "🔍 开始分析代码..."
cd ~/.openclaw/workspace/skills/code-analyzer
node analyze-local.js "$TARGET_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 全部完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
