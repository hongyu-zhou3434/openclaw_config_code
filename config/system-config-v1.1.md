# OpenClaw 系统配置 v1.1

**版本**: 1.1.0  
**更新日期**: 2026-03-16  
**更新内容**: 统一格式转换工具配置  
**文件定位**: 日常运维与临时配置  
**更新规则**: ✅ 自动和手动更新

---

## 0. 文件使用规则（重要）

### 0.1 文件定位

| 文件 | 定位 | 更新规则 | 使用场景 |
|------|------|----------|----------|
| **system-config-v1.0.md** | 全量稳定配置 | ⚠️ 必须手动更新 | 系统部署、审计、故障排查 |
| **system-config-v1.1.md** | 日常运维配置 | ✅ 自动+手动更新 | 日常运维、临时配置 |

### 0.2 更新规则

**v1.1.md（本文件）**:
- ✅ 手动更新：人工确认后修改
- ✅ 自动更新：允许自动同步
- 📝 更新流程：自动/手动 → 提交GitHub
- 🎯 更新内容：日常运维、临时配置、快速调整
- ⏱️ 更新频率：可随时更新

**v1.0.md**:
- ✅ 手动更新：人工确认后修改
- ❌ 自动更新：禁止自动修改
- 📝 更新流程：人工审核 → 手动编辑 → 提交GitHub
- 🎯 更新内容：稳定配置、重大变更、版本升级

### 0.3 配置优先级

```
配置冲突时优先级：
v1.0.md（稳定配置） > v1.1.md（运维配置）

说明：
- 当两个文件配置冲突时，以v1.0.md为准
- v1.1.md用于补充和临时调整
- 日常运维优先参考v1.1.md
- 系统核心配置参考v1.0.md
```

### 0.4 自动更新场景

**允许自动更新**:
- ✅ 定时任务状态更新
- ✅ 健康检查结果更新
- ✅ 临时配置调整
- ✅ 日志和状态同步
- ✅ 快速修复和补丁

**禁止自动更新**:
- ❌ 核心系统配置变更
- ❌ API密钥修改
- ❌ 定时任务增删
- ❌ 重大版本升级
- ❌ 架构性调整

---

## 📋 系统概述

OpenClaw 自动化系统配置文档，包含定时任务、技能配置、API密钥等系统级设置。

---

## 🔄 格式转换工具配置（新增）

### 标准转换工具

**所有Markdown、DOC、PDF等格式转换任务统一使用 `wps-skill` 技能。**

| 转换类型 | 推荐工具 | 备选工具 | 说明 |
|----------|----------|----------|------|
| **MD → DOCX** | wps-skill | batch_md_to_pdf.py | wps-skill优先 |
| **MD → PDF** | wps-skill | batch_md_to_pdf.py | wps-skill优先 |
| **DOCX → PDF** | wps-skill | LibreOffice | wps-skill优先 |
| **DOCX → MD** | wps-skill | pandoc | wps-skill优先 |
| **Excel ↔ MD** | wps-skill | - | wps-skill专用 |
| **PPT ↔ MD** | wps-skill | - | wps-skill专用 |

### wps-skill 配置

**技能路径**: `/root/.openclaw/workspace/skills/wps-skill/`

**配置文件**: `config.json`
```json
{
  "default_save_path": "~/Documents/WPS",
  "wps_path": "",
  "app_id": "",
  "app_secret": ""
}
```

**转换脚本**:
- `scripts/md_converter.py` - Markdown转换
- `scripts/excel_converter.py` - Excel转换
- `scripts/ppt_converter.py` - PPT转换
- `scripts/image_handler.py` - 图片处理
- `scripts/main.py` - 主入口

### 使用方式

```bash
# Markdown转Word
python3 /root/.openclaw/workspace/skills/wps-skill/scripts/main.py md_to_docx file=文档.md output=文档.docx

# Markdown转Excel
python3 /root/.openclaw/workspace/skills/wps-skill/scripts/main.py md_to_xlsx file=数据.md output=数据.xlsx

# Markdown转PPT
python3 /root/.openclaw/workspace/skills/wps-skill/scripts/main.py md_to_pptx file=汇报.md output=汇报.pptx

# Word转Markdown
python3 /root/.openclaw/workspace/skills/wps-skill/scripts/main.py docx_to_md file=文档.docx output=文档.md
```

---

## ⏰ 定时任务配置

### 任务列表

| 任务名称 | 执行时间 | 脚本路径 | 邮件发送 | 状态 |
|----------|----------|----------|----------|------|
| daily-ai-insight-6am | 06:00 | scripts/daily-ai-insight.sh | ✅ | 已配置 |
| daily-ai-news-8am | 08:00 | scripts/daily-ai-news-8am.sh | ✅ | 已修复 |
| system-health-check-21h | 21:00 | scripts/system-health-check.sh | ✅ | 已配置 |

### 监控配置

**包装器脚本**: `scripts/cron-wrapper.sh`
**状态查询**: `scripts/cron-status.sh`

---

## 📧 邮件配置

**SMTP配置**: `skills/smtp-sender/smtp-config.json`

```json
{
  "server": "smtp.qq.com",
  "port": 465,
  "username": "273477656@qq.com",
  "password": "***",
  "emailFrom": "273477656@qq.com",
  "useTLS": true
}
```

**发送工具**: `scripts/send_email_with_progress.py`

---

## 🔑 API密钥配置

### Tavily Search
- **Key**: `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`
- **用途**: AI动态搜索

### OpenAI/DashScope
- **Key**: `sk-sp-1dfcd6127bfc4033b85aa78f2ed6a995`
- **Base URL**: `https://coding.dashscope.aliyuncs.com/v1`
- **Model**: `kimi-k2.5`

---

## 📁 目录结构

```
/root/.openclaw/workspace/
├── config/
│   ├── system-config-v1.1.md      # 本文件
│   └── task-config.json           # 任务配置
├── scripts/
│   ├── daily-ai-insight.sh        # 6点任务
│   ├── daily-ai-news-8am.sh       # 8点任务
│   ├── system-health-check.sh     # 21点任务
│   ├── cron-wrapper.sh            # 任务包装器
│   ├── cron-status.sh             # 状态查询
│   ├── batch_md_to_pdf.py         # PDF转换（备选）
│   └── send_email_with_progress.py # 邮件发送
├── skills/
│   ├── wps-skill/                 # WPS格式转换（标准）
│   ├── smtp-sender/               # 邮件发送
│   └── tavily-search/             # AI搜索
├── output/
│   ├── daily-insights/            # 6点报告输出
│   ├── daily-ai-news/             # 8点报告输出
│   └── health-checks/             # 健康检查输出
└── logs/                          # 执行日志
```

---

## 📝 更新记录

### v1.1.0 (2026-03-16)
- ✅ 统一格式转换工具配置（wps-skill）
- ✅ 修复daily-ai-news-8am邮件发送问题
- ✅ 添加任务监控包装器
- ✅ 添加状态查询工具

### v1.0.0 (2026-03-15)
- ✅ 初始配置
- ✅ 3个定时任务
- ✅ API密钥配置

---

## 🔧 维护说明

### 日志清理
```bash
# 清理30天前的日志
find /root/.openclaw/workspace/logs -name "*.log" -mtime +30 -delete
```

### 状态检查
```bash
# 查看所有任务状态
/root/.openclaw/workspace/scripts/cron-status.sh

# 查看crontab
crontab -l
```

### 配置验证
```bash
# 验证JSON配置
python3 -m json.tool /root/.openclaw/workspace/config/task-config.json
```

---

**维护者**: OpenClaw AI  
**最后更新**: 2026-03-16 10:15
