#!/bin/bash
# OpenClaw 统一文档转换工具
# 封装 wps-skill，提供标准接口

set -e

# 配置
WORKSPACE="/root/.openclaw/workspace"
WPS_SKILL="$WORKSPACE/skills/wps-skill"
CONVERTER_SCRIPT="$WPS_SKILL/scripts/main.py"

# 用法提示
usage() {
    echo "用法: $0 <命令> [选项]"
    echo ""
    echo "命令:"
    echo "  md-to-docx    Markdown转Word"
    echo "  md-to-pdf     Markdown转PDF"
    echo "  md-to-xlsx    Markdown转Excel"
    echo "  md-to-pptx    Markdown转PPT"
    echo "  docx-to-md    Word转Markdown"
    echo "  docx-to-pdf   Word转PDF"
    echo "  batch-md      批量Markdown转换"
    echo ""
    echo "选项:"
    echo "  --input, -i    输入文件"
    echo "  --output, -o   输出文件"
    echo "  --dir, -d      输入目录（批量模式）"
    echo "  --format, -f   输出格式（批量模式）"
    echo ""
    echo "示例:"
    echo "  $0 md-to-docx -i report.md -o report.docx"
    echo "  $0 batch-md -d ./reports -f pdf"
    echo ""
}

# 检查依赖
check_deps() {
    if [ ! -f "$CONVERTER_SCRIPT" ]; then
        echo "错误: wps-skill未安装或脚本不存在"
        echo "路径: $CONVERTER_SCRIPT"
        exit 1
    fi
    
    if ! command -v python3 &> /dev/null; then
        echo "错误: Python3未安装"
        exit 1
    fi
}

# Markdown转Word
md_to_docx() {
    local input_file="$1"
    local output_file="$2"
    
    echo "转换: $input_file → $output_file"
    
    if [ ! -f "$input_file" ]; then
        echo "错误: 输入文件不存在: $input_file"
        return 1
    fi
    
    cd "$(dirname "$input_file")"
    python3 "$CONVERTER_SCRIPT" md_to_docx \
        "file=$(basename "$input_file")" \
        "output=$(basename "$output_file")" \
        2>&1
    
    if [ -f "$output_file" ]; then
        echo "✅ 转换成功: $output_file"
        return 0
    else
        echo "❌ 转换失败"
        return 1
    fi
}

# Markdown转PDF（通过Word中转）
md_to_pdf() {
    local input_file="$1"
    local output_file="$2"
    local temp_docx="${input_file%.md}.docx"
    
    echo "转换: $input_file → $output_file"
    
    # 先转Word
    if ! md_to_docx "$input_file" "$temp_docx"; then
        return 1
    fi
    
    # 再转PDF（如果wps-skill支持）
    # 否则使用LibreOffice或weasyprint
    if command -v soffice &> /dev/null; then
        soffice --headless --convert-to pdf --outdir "$(dirname "$output_file")" "$temp_docx" 2>/dev/null
    elif command -v libreoffice &> /dev/null; then
        libreoffice --headless --convert-to pdf --outdir "$(dirname "$output_file")" "$temp_docx" 2>/dev/null
    else
        # 使用weasyprint作为备选
        python3 -c "
from weasyprint import HTML, CSS
import markdown
with open('$input_file') as f:
    html = markdown.markdown(f.read(), extensions=['tables', 'fenced_code'])
HTML(string=html).write_pdf('$output_file')
" 2>/dev/null && echo "✅ 使用weasyprint转换成功"
    fi
    
    if [ -f "$output_file" ]; then
        echo "✅ 转换成功: $output_file"
        # 清理临时文件
        rm -f "$temp_docx"
        return 0
    else
        echo "⚠️ PDF转换失败，保留Word文件: $temp_docx"
        return 1
    fi
}

# Markdown转Excel
md_to_xlsx() {
    local input_file="$1"
    local output_file="$2"
    
    echo "转换: $input_file → $output_file"
    
    if [ ! -f "$input_file" ]; then
        echo "错误: 输入文件不存在: $input_file"
        return 1
    fi
    
    cd "$(dirname "$input_file")"
    python3 "$CONVERTER_SCRIPT" md_to_xlsx \
        "file=$(basename "$input_file")" \
        "output=$(basename "$output_file")" \
        2>&1
    
    if [ -f "$output_file" ]; then
        echo "✅ 转换成功: $output_file"
        return 0
    else
        echo "❌ 转换失败"
        return 1
    fi
}

# Markdown转PPT
md_to_pptx() {
    local input_file="$1"
    local output_file="$2"
    
    echo "转换: $input_file → $output_file"
    
    if [ ! -f "$input_file" ]; then
        echo "错误: 输入文件不存在: $input_file"
        return 1
    fi
    
    cd "$(dirname "$input_file")"
    python3 "$CONVERTER_SCRIPT" md_to_pptx \
        "file=$(basename "$input_file")" \
        "output=$(basename "$output_file")" \
        2>&1
    
    if [ -f "$output_file" ]; then
        echo "✅ 转换成功: $output_file"
        return 0
    else
        echo "❌ 转换失败"
        return 1
    fi
}

# Word转Markdown
docx_to_md() {
    local input_file="$1"
    local output_file="$2"
    
    echo "转换: $input_file → $output_file"
    
    if [ ! -f "$input_file" ]; then
        echo "错误: 输入文件不存在: $input_file"
        return 1
    fi
    
    cd "$(dirname "$input_file")"
    python3 "$CONVERTER_SCRIPT" docx_to_md \
        "file=$(basename "$input_file")" \
        "output=$(basename "$output_file")" \
        2>&1
    
    if [ -f "$output_file" ]; then
        echo "✅ 转换成功: $output_file"
        return 0
    else
        echo "❌ 转换失败"
        return 1
    fi
}

# 批量转换Markdown
batch_convert() {
    local input_dir="$1"
    local output_format="$2"
    
    echo "批量转换: $input_dir → $output_format"
    
    if [ ! -d "$input_dir" ]; then
        echo "错误: 输入目录不存在: $input_dir"
        return 1
    fi
    
    local count=0
    local success=0
    local failed=0
    
    for md_file in "$input_dir"/*.md; do
        [ -f "$md_file" ] || continue
        
        count=$((count + 1))
        local basename=$(basename "$md_file" .md)
        local output_file="$input_dir/${basename}.${output_format}"
        
        echo "[$count] $(basename "$md_file")..."
        
        case "$output_format" in
            docx)
                if md_to_docx "$md_file" "$output_file"; then
                    success=$((success + 1))
                else
                    failed=$((failed + 1))
                fi
                ;;
            pdf)
                if md_to_pdf "$md_file" "$output_file"; then
                    success=$((success + 1))
                else
                    failed=$((failed + 1))
                fi
                ;;
            xlsx)
                if md_to_xlsx "$md_file" "$output_file"; then
                    success=$((success + 1))
                else
                    failed=$((failed + 1))
                fi
                ;;
            pptx)
                if md_to_pptx "$md_file" "$output_file"; then
                    success=$((success + 1))
                else
                    failed=$((failed + 1))
                fi
                ;;
            *)
                echo "不支持的格式: $output_format"
                return 1
                ;;
        esac
    done
    
    echo ""
    echo "批量转换完成:"
    echo "  总计: $count"
    echo "  成功: $success"
    echo "  失败: $failed"
}

# 主逻辑
main() {
    if [ $# -lt 1 ]; then
        usage
        exit 1
    fi
    
    check_deps
    
    local command="$1"
    shift
    
    case "$command" in
        md-to-docx)
            local input_file=""
            local output_file=""
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    -i|--input) input_file="$2"; shift 2 ;;
                    -o|--output) output_file="$2"; shift 2 ;;
                    *) echo "未知选项: $1"; usage; exit 1 ;;
                esac
            done
            [ -z "$input_file" ] && { echo "缺少输入文件"; usage; exit 1; }
            [ -z "$output_file" ] && output_file="${input_file%.md}.docx"
            md_to_docx "$input_file" "$output_file"
            ;;
        md-to-pdf)
            local input_file=""
            local output_file=""
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    -i|--input) input_file="$2"; shift 2 ;;
                    -o|--output) output_file="$2"; shift 2 ;;
                    *) echo