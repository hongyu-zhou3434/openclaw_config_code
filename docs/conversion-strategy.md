# OpenClaw 文档格式转换策略

**版本**: 1.0  
**日期**: 2026-03-16  
**状态**: 生效

---

## 📋 策略概述

**所有系统内的Markdown、DOC、PDF等格式转换任务，统一使用 `wps-skill` 技能作为标准工具。**

---

## 🎯 转换工具层级

### 第一层：wps-skill（标准/优先）

**路径**: `/root/.openclaw/workspace/skills/wps-skill/`

**适用场景**:
- ✅ Markdown → Word (DOCX)
- ✅ Markdown → Excel (XLSX)
- ✅ Markdown → PPT (PPTX)
- ✅ Word → Markdown
- ✅ Word → PDF
- ✅ Excel ↔ Markdown
- ✅ PPT ↔ Markdown

**优势**:
- 专为OpenClaw系统设计
- 支持复杂格式（表格、图片、代码块）
- 中文支持良好
- 批量处理能力

**使用方式**:
```bash
# 直接调用
python3 /root/.openclaw/workspace/skills/wps-skill/scripts/main.py md_to_docx file=input.md output=output.docx

# 通过包装器
/root/.openclaw/workspace/scripts/doc-converter.sh md-to-docx -i input.md -o output.docx
```

---

### 第二层：doc-converter.sh（统一接口）

**路径**: `/root/.openclaw/workspace/scripts/doc-converter.sh`

**功能**:
- 封装 wps-skill 调用
- 提供统一命令行接口
- 自动处理依赖检查
- 支持批量转换

**使用方式**:
```bash
# Markdown转Word
./doc-converter.sh md-to-docx -i report.md -o report.docx

# Markdown转PDF
./doc-converter.sh md-to-pdf -i report.md -o report.pdf

# 批量转换
./doc-converter.sh batch-md -d ./reports -f pdf
```

---

### 第三层：备选工具（兼容/降级）

**工具**: `batch_md_to_pdf.py`

**路径**: `/root/.openclaw/workspace/scripts/batch_md_to_pdf.py`

**适用场景**:
- wps-skill 不可用
- 仅需简单Markdown转PDF
- 快速批量转换

**限制**:
- 仅支持Markdown → PDF
- 复杂格式支持有限

---

## 📊 转换矩阵

| 源格式 | 目标格式 | 首选工具 | 备选工具 | 备注 |
|--------|----------|----------|----------|------|
| Markdown | Word | wps-skill | - | 完整支持 |
| Markdown | PDF | wps-skill | batch_md_to_pdf.py | wps优先 |
| Markdown | Excel | wps-skill | - | 表格转工作表 |
| Markdown | PPT | wps-skill | - | 标题变幻灯片 |
| Word | Markdown | wps-skill | - | 完整支持 |
| Word | PDF | wps-skill | LibreOffice | wps优先 |
| Excel | Markdown | wps-skill | - | 工作表转表格 |
| PPT | Markdown | wps-skill | - | 幻灯片转文档 |

---

## 🔧 任务脚本更新要求

### 所有定时任务脚本必须遵循：

1. **使用标准工具**
   ```bash
   # 推荐方式
   python3 "$WORKSPACE/skills/wps-skill/scripts/main.py" md_to_docx file=input.md output=output.docx
   
   # 或包装器
   "$WORKSPACE/scripts/doc-converter.sh" md-to-pdf -i input.md -o output.pdf
   ```

2. **错误处理**
   ```bash
   if ! convert_using_wps_skill "$md_file" "$pdf_file"; then
       echo "wps-skill转换失败，尝试备选方案..."
       python3 "$WORKSPACE/scripts/batch_md_to_pdf.py" "$md_file"
   fi
   ```

3. **日志记录**
   ```bash
   echo "使用工具: wps-skill" | tee -a "$LOG_FILE"
   echo "转换: $input → $output" | tee -a "$LOG_FILE"
   ```

---

## 📁 配置文件

### 主配置: `config/task-config.json`

```json
{
  "conversion": {
    "tool": "wps-skill",
    "fallback": "batch_md_to_pdf.py",
    "output_format": ["pdf"]
  }
}
```

### 全局设置: `config/task-config.json` → `global_settings`

```json
{
  "conversion": {
    "primary_tool": "wps-skill",
    "primary_path": "/root/.openclaw/workspace/skills/wps-skill/scripts/main.py",
    "fallback_tool": "batch_md_to_pdf.py",
    "fallback_path": "/root/.openclaw/workspace/scripts/batch_md_to_pdf.py",
    "wrapper_script": "/root/.openclaw/workspace/scripts/doc-converter.sh"
  }
}
```

---

## ✅ 合规检查清单

### 定时任务脚本检查项

- [ ] 使用 wps-skill 作为主要转换工具
- [ ] 包含备选方案（batch_md_to_pdf.py）
- [ ] 记录转换工具使用情况到日志
- [ ] 处理转换失败的情况
- [ ] 使用统一接口（doc-converter.sh）

### 新增脚本要求

- [ ] 遵循转换策略文档
- [ ] 使用标准工具路径
- [ ] 提供清晰的错误信息
- [ ] 支持批量处理

---

## 🔄 版本历史

### v1.0 (2026-03-16)
- ✅ 制定统一转换策略
- ✅ 明确 wps-skill 为标准工具
- ✅ 定义三层工具架构
- ✅ 创建统一接口包装器
- ✅ 更新任务配置

---

## 📞 维护联系

**维护者**: OpenClaw AI  
**配置路径**: `/root/.openclaw/workspace/config/`  
**文档路径**: `/root/.openclaw/workspace/docs/`

---

**生效日期**: 2026-03-16  
**下次审查**: 2026-04-16
