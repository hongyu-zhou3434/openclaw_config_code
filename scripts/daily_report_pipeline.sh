#!/bin/bash
# 每日AI洞察报告处理流水线
# 功能: Markdown转PDF -> 发送邮件，带完整进度反馈

set -e

# 配置
WORKSPACE="/root/.openclaw/workspace"
REPORT_DIR="${WORKSPACE}/output/daily-insights/$(date +%Y-%m-%d)"
SCRIPTS_DIR="${WORKSPACE}/scripts"
RECIPIENT="273477656@qq.com"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的信息
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    info "检查依赖..."
    
    # 检查Python
    if ! command -v python3 &> /dev/null; then
        error "Python3未安装"
        exit 1
    fi
    
    # 检查必要的Python包
    python3 -c "import markdown, weasyprint" 2>/dev/null || {
        warning "缺少Python依赖，正在安装..."
        pip install markdown weasyprint --break-system-packages -q
    }
    
    success "依赖检查通过"
}

# 查找Markdown文件
find_md_files() {
    info "查找Markdown报告文件..."
    
    if [ ! -d "$REPORT_DIR" ]; then
        error "报告目录不存在: $REPORT_DIR"
        exit 1
    fi
    
    # 查找所有Markdown文件（排除日志文件）
    md_files=$(find "$REPORT_DIR" -maxdepth 1 -name "*.md" ! -name "insight-generation.log" ! -name "daily-insight-*.log" | sort)
    
    if [ -z "$md_files" ]; then
        error "未找到Markdown报告文件"
        exit 1
    fi
    
    file_count=$(echo "$md_files" | wc -l)
    success "找到 $file_count 个Markdown文件"
    
    echo "$md_files"
}

# 批量转换为PDF
convert_to_pdf() {
    local md_files="$1"
    
    info "开始批量转换Markdown到PDF..."
    
    # 使用Python脚本进行转换
    python3 "${SCRIPTS_DIR}/batch_md_to_pdf.py" $md_files
    
    if [ $? -eq 0 ]; then
        success "PDF转换完成"
    else
        error "PDF转换失败"
        return 1
    fi
}

# 发送邮件
send_email() {
    local pdf_files="$1"
    local date_str=$(date +%Y年%m月%d日)
    
    info "准备发送邮件..."
    
    # 构建邮件正文
    body="每日AI技术洞察报告 (PDF版本)

报告日期: ${date_str}
生成时间: $(date +%H:%M:%S)

覆盖公司: 字节跳动、阿里巴巴、腾讯、智谱AI、DeepSeek、Google、NVIDIA、MiniMax

本次共生成 9份PDF报告（1份汇总 + 8份公司详细报告）

详见附件。

---
*本报告由 OpenClaw AI 系统自动生成*"

    # 发送邮件
    python3 "${SCRIPTS_DIR}/send_email_with_progress.py" \
        --to "$RECIPIENT" \
        --subject "📊 每日AI技术洞察报告(PDF版) - ${date_str}" \
        --body "$body" \
        --attachments $pdf_files
    
    if [ $? -eq 0 ]; then
        success "邮件发送完成"
    else
        error "邮件发送失败"
        return 1
    fi
}

# 主流程
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║     每日AI洞察报告处理流水线                               ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    local start_time=$(date +%s)
    
    # 步骤1: 检查依赖
    check_dependencies
    
    # 步骤2: 查找Markdown文件
    local md_files=$(find_md_files)
    
    # 步骤3: 转换为PDF
    convert_to_pdf "$md_files"
    
    # 步骤4: 查找生成的PDF文件
    local pdf_files=$(find "$REPORT_DIR" -maxdepth 1 -name "*.pdf" | sort | tr '\n' ' ')
    
    if [ -z "$pdf_files" ]; then
        error "未找到PDF文件"
        exit 1
    fi
    
    local pdf_count=$(find "$REPORT_DIR" -maxdepth 1 -name "*.pdf" | wc -l)
    info "找到 $pdf_count 个PDF文件准备发送"
    
    # 步骤5: 发送邮件
    send_email "$pdf_files"
    
    # 完成汇总
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                    ✅ 流水线执行完成                        ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║  处理文件: $pdf_count 个                                     ║"
    echo "║  收件邮箱: $RECIPIENT                              ║"
    echo "║  执行耗时: ${duration} 秒                                      ║"
    echo "║  完成时间: $(date '+%Y-%m-%d %H:%M:%S')                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
}

# 执行主流程
main "$@"
