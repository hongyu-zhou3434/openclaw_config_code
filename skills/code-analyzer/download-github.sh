#!/bin/bash
# GitHub 代码下载脚本 - 终极优化版
# 支持多种代理和镜像方案

set -e

REPO_URL="$1"
BRANCH="${2:-main}"
WORK_DIR="/tmp/code-analysis"

if [ -z "$REPO_URL" ]; then
    echo "用法: $0 <GitHub仓库URL> [分支名]"
    echo "示例: $0 https://github.com/Wan-Video/Wan2.2.git"
    exit 1
fi

# 提取仓库名
REPO_NAME=$(basename "$REPO_URL" .git)
TARGET_DIR="$WORK_DIR/$REPO_NAME"

echo "🔍 GitHub 代码下载工具 (终极优化版)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "仓库: $REPO_URL"
echo "分支: $BRANCH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 创建工作目录
mkdir -p "$WORK_DIR"

# 清理旧目录
if [ -d "$TARGET_DIR" ]; then
    echo "🧹 清理旧目录..."
    rm -rf "$TARGET_DIR"
fi

# 定义代理和镜像列表
PROXY_LIST=(
    "direct"                    # 直接连接
    "ghproxy.com"              # 国内代理1
    "mirror.ghproxy.com"       # 国内代理2
    "hub.gitmirror.com"        # 国内镜像1
    "gh.api.99988866.xyz"      # 国内代理3
)

# 测试下载函数
download_with_proxy() {
    local proxy="$1"
    local attempt="$2"
    
    echo ""
    echo "🔄 尝试 $attempt: 使用代理 [$proxy]"
    
    local url="$REPO_URL"
    
    # 如果指定了代理，修改URL
    if [ "$proxy" != "direct" ]; then
        url="https://${proxy}/${REPO_URL#https://}"
        echo "   代理URL: $url"
    fi
    
    # 方案1: Git 浅克隆
    echo "   📦 方案1: Git 浅克隆..."
    if timeout 120 git clone --depth 1 -b "$BRANCH" "$url" "$TARGET_DIR" 2>/dev/null; then
        echo "   ✅ Git 克隆成功"
        return 0
    fi
    
    # 方案2: 尝试 master 分支
    echo "   📦 方案2: 尝试 master 分支..."
    if timeout 120 git clone --depth 1 -b master "$url" "$TARGET_DIR" 2>/dev/null; then
        echo "   ✅ Git 克隆成功 (master分支)"
        return 0
    fi
    
    # 方案3: 不指定分支
    echo "   📦 方案3: 默认分支..."
    if timeout 120 git clone --depth 1 "$url" "$TARGET_DIR" 2>/dev/null; then
        echo "   ✅ Git 克隆成功 (默认分支)"
        return 0
    fi
    
    # 方案4: 下载 ZIP (仅直接连接)
    if [ "$proxy" = "direct" ]; then
        echo "   📦 方案4: 下载 ZIP 包..."
        local zip_url="${REPO_URL%.git}/archive/refs/heads/${BRANCH}.zip"
        local zip_file="$WORK_DIR/${REPO_NAME}.zip"
        
        if timeout 120 wget -q --timeout=60 --tries=2 "$zip_url" -O "$zip_file" 2>/dev/null; then
            echo "   ✅ ZIP 下载成功"
            if unzip -q "$zip_file" -d "$WORK_DIR" 2>/dev/null; then
                mv "$WORK_DIR/${REPO_NAME}-${BRANCH}" "$TARGET_DIR"
                rm -f "$zip_file"
                echo "   ✅ ZIP 解压完成"
                return 0
            fi
        fi
    fi
    
    return 1
}

# 主下载逻辑
success=false
attempt=1

for proxy in "${PROXY_LIST[@]}"; do
    if download_with_proxy "$proxy" "$attempt"; then
        success=true
        break
    fi
    ((attempt++))
done

# 检查下载结果
if [ "$success" = false ]; then
    echo ""
    echo "❌ 所有下载方案均失败"
    echo ""
    echo "💡 建议:"
    echo "   1. 检查网络连接"
    echo "   2. 手动配置代理: export https_proxy=http://proxy:port"
    echo "   3. 使用浏览器下载 ZIP 后手动分析"
    exit 1
fi

# 验证下载完整性
echo ""
echo "🔍 验证下载完整性..."

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ 下载目录不存在"
    exit 1
fi

# 统计文件数（排除.git）
FILE_COUNT=$(find "$TARGET_DIR" -type f -not -path "*/.git/*" 2>/dev/null | wc -l)
DIR_COUNT=$(find "$TARGET_DIR" -type d -not -path "*/.git" -not -path "*/.git/*" 2>/dev/null | wc -l)

if [ "$FILE_COUNT" -eq 0 ]; then
    echo "❌ 下载目录为空（可能只有.git目录）"
    exit 1
fi

echo "✅ 下载验证通过"
echo "   📁 目录数: $DIR_COUNT"
echo "   📄 文件数: $FILE_COUNT"

# 显示目录结构
echo ""
echo "📂 目录结构:"
ls -la "$TARGET_DIR" | head -20

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 下载成功: $TARGET_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 返回目录路径
echo "$TARGET_DIR"
