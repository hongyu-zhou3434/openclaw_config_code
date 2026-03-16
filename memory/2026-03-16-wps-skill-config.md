# 系统配置更新：统一格式转换工具

**日期**: 2026-03-16  
**更新类型**: 系统配置  
**影响范围**: 全系统所有格式转换任务  
**状态**: ✅ 已完成

---

## 📋 更新内容

### 核心变更

**所有Markdown、DOC、PDF等格式转换任务，统一使用 `wps-skill` 技能作为标准工具。**

---

## 🛠️ 新增/更新的组件

### 1. 系统配置文档

| 文件 | 路径 | 说明 |
|------|------|------|
| system-config-v1.1.md | `config/system-config-v1.1.md` | 系统主配置文档 |
| task-config.json | `config/task-config.json` | 任务配置文件（已更新） |
| conversion-strategy.md | `docs/conversion-strategy.md` | 转换策略文档 |

### 2. 转换工具

| 工具 | 路径 | 层级 | 说明 |
|------|------|------|------|
| wps-skill | `skills/wps-skill/` | 第一层（标准） | WPS格式转换技能 |
| doc-converter.sh | `scripts/doc-converter.sh` | 第二层（接口） | 统一转换接口 |
| batch_md_to_pdf.py | `scripts/batch_md_to_pdf.py` | 第三层（备选） | 备选PDF转换 |

---

## 📊 转换工具架构

```
┌─────────────────────────────────────────────────────────────┐
│                    格式转换请求                              │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  第一层: wps-skill (标准工具)                                │
│  路径: skills/wps-skill/scripts/main.py                      │
│  功能: MD↔DOCX, MD↔XLSX, MD↔PPTX, DOCX↔PDF                  │
└─────────────────────┬───────────────────────────────────────┘
                      │ 失败
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  第二层: doc-converter.sh (统一接口)                         │
│  路径: scripts/doc-converter.sh                              │
│  功能: 封装调用、参数处理、批量转换                          │
└─────────────────────┬───────────────────────────────────────┘
                      │ 失败
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  第三层: batch_md_to_pdf.py (备选工具)                       │
│  路径: scripts/batch_md_to_pdf.py                            │
│  功能: Markdown转PDF（简单场景）                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 使用方式

### 方式1: 直接调用 wps-skill

```bash
python3 /root/.openclaw/workspace/skills/wps-skill/scripts/main.py \
  md_to_docx file=input.md output=output.docx
```

### 方式2: 使用统一接口

```bash
/root/.openclaw/workspace/scripts/doc-converter.sh \
  md-to-pdf -i input.md -o output.pdf
```

### 方式3: 批量转换

```bash
/root/.openclaw/workspace/scripts/doc-converter.sh \
  batch-md -d ./reports -f pdf
```

---

## 📁 配置文件更新

### task-config.json 新增内容

```json
{
  "conversion": {
    "tool": "wps-skill",
    "fallback": "batch_md_to_pdf.py",
    "output_format": ["pdf"]
  }
}
```

```json
{
  "global_settings": {
    "conversion": {
      "primary_tool": "wps-skill",
      "primary_path": "/root/.openclaw/workspace/skills/wps-skill/scripts/main.py",
      "fallback_tool": "batch_md_to_pdf.py",
      "fallback_path": "/root/.openclaw/workspace/scripts/batch_md_to_pdf.py",
      "wrapper_script": "/root/.openclaw/workspace/scripts/doc-converter.sh"
    }
  }
}
```

---

## ✅ 影响范围

### 已更新的任务

| 任务 | 脚本 | 转换工具 |
|------|------|----------|
| daily-ai-insight-6am | `scripts/daily-ai-insight.sh` | 需更新为wps-skill |
| daily-ai-news-8am | `scripts/daily-ai-news-8am.sh` | 需更新为wps-skill |
| system-health-check-21h | `scripts/system-health-check.sh` | 无需转换 |

### 待执行任务

- [ ] 更新 `daily-ai-insight.sh` 使用 wps-skill
- [ ] 更新 `daily-ai-news-8am.sh` 使用 wps-skill
- [ ] 测试 wps-skill 转换功能
- [ ] 验证邮件发送正常

---

## 📋 合规要求

### 所有格式转换任务必须：

1. ✅ 优先使用 wps-skill 作为转换工具
2. ✅ 包含备选方案（batch_md_to_pdf.py）
3. ✅ 记录转换工具使用情况
4. ✅ 处理转换失败的情况
5. ✅ 遵循 conversion-strategy.md 文档

---

## 📞 相关文档

- 系统配置: `config/system-config-v1.1.md`
- 任务配置: `config/task-config.json`
- 转换策略: `docs/conversion-strategy.md`
- 修复记录: `memory/2026-03-16-daily-ai-news-fix.md`

---

**配置生效时间**: 2026-03-16 10:30  
**配置维护者**: OpenClaw AI  
**下次审查**: 2026-04-16
