# OpenClaw 系统配置 v1.0

**版本**: 1.0.0
**生成时间**: 2026-03-16 00:10:00 +08:00
**生效状态**: ✅ 已生效
**文件定位**: 全量稳定系统配置
**更新规则**: ⚠️ 必须手动更新（不自动更新）

---

## 0. 文件使用规则（重要）

### 0.1 文件定位

| 文件 | 定位 | 更新规则 | 使用场景 |
|------|------|----------|----------|
| **system-config-v1.0.md** | 全量稳定配置 | ⚠️ 必须手动更新 | 系统部署、审计、故障排查 |
| **system-config-v1.1.md** | 日常运维配置 | ✅ 自动+手动更新 | 日常运维、临时配置 |

### 0.2 更新规则

**v1.0.md（本文件）**:
- ✅ 手动更新：人工确认后修改
- ❌ 自动更新：禁止自动修改
- 📝 更新流程：人工审核 → 手动编辑 → 提交GitHub
- 🎯 更新内容：稳定配置、重大变更、版本升级

**v1.1.md**:
- ✅ 手动更新：人工确认后修改
- ✅ 自动更新：允许自动同步
- 📝 更新流程：自动/手动 → 提交GitHub
- 🎯 更新内容：日常运维、临时配置、快速调整

### 0.3 配置优先级

```
配置冲突时优先级：
v1.0.md（稳定配置） > v1.1.md（运维配置）

说明：
- 当两个文件配置冲突时，以v1.0.md为准
- v1.1.md用于补充和临时调整
- v1.0.md包含系统核心稳定配置
```

---

## 1. 系统运行规则

### 1.1 配置修改规则

| 配置类型 | 修改策略 | 说明 |
|----------|----------|------|
| **系统配置** | 修改前确认 | 全局配置，不自动修改 |
| **任务配置** | 修改前确认 | 周期性定时任务清单化管理 |
| **API 密钥** | 修改前确认 | 敏感配置需确认 |

### 1.2 GitHub 同步规则

- **自动同步**: 配置生效后自动上传到 `openclaw_config_code` 仓库
- **同步分支**: main
- **提交信息**: "系统配置更新 v{版本} - {日期}"

### 1.3 例行测试规则

- **执行时间**: 每日 21:00
- **测试内容**:
  1. 所有已安装技能可用性
  2. 定时任务配置验证
  3. 系统配置完整性
  4. API 密钥有效性
- **测试结果**: 通过后写入 GitHub 仓库

---

## 2. 系统配置清单

### 2.1 核心系统配置

| 配置项 | 值 | 状态 |
|--------|-----|------|
| **工作区目录** | `/root/.openclaw/workspace/` | ✅ |
| **系统配置目录** | `/root/.openclaw/` | ✅ |
| **技能目录** | `/root/.openclaw/workspace/skills/` | ✅ |
| **任务目录** | `/root/.openclaw/workspace/tasks/` | ✅ |
| **输出目录** | `/root/.openclaw/workspace/output/` | ✅ |
| **临时目录** | `/root/.openclaw/workspace/temp/` | ✅ |
| **配置目录** | `/root/.openclaw/workspace/.config/` | ✅ |
| **学习日志目录** | `/root/.openclaw/workspace/.learnings/` | ✅ |

### 2.2 技能商店策略

| 策略 | 配置 |
|------|------|
| **优先源** | skillhub (国内优化) |
| **备用源** | clawhub (公共注册表) |
| **安装前摘要** | 必须汇报源、版本、风险信号 |
| **排他性声明** | 不声明排他性，支持公共和私有注册表 |

### 2.3 四技能协同配置

| 技能 | 版本 | 职责 | 状态 |
|------|------|------|------|
| **任务监控** | v1.0 | 多维度任务监控与告警 | ✅ |
| **self-improving-agent** | v3.0.1 | 记录异常、学习纠正、持续改进 | ✅ |
| **Find-Skills** | v1.4.4 | 搜索解决方案、发现/安装新技能 | ✅ |
| **Summarize** | v1.0.0 | 文档总结、内容提炼 | ✅ |

**协同流程**:
```
任务执行 → 任务监控（多维度检测）
              ↓
    ┌─────────┴─────────┐
    ▼                   ▼
[正常完成]          [异常检测]
    │                   │
    ▼                   ▼
输出结果      self-improving-agent 记录
                  ↓
        分析异常类型
            ├── 能力缺失 → Find-Skills 搜索安装
            ├── 文档困难 → Summarize 总结提炼
            └── 流程问题 → 优化策略更新配置
```

---

## 3. 定时任务清单

### 3.1 每日 21:00 - 系统例行测试

| 配置项 | 值 |
|--------|-----|
| **任务名称** | system-health-check |
| **执行时间** | 每日 21:00 |
| **Cron 表达式** | `0 21 * * *` |
| **脚本路径** | `scripts/system-health-check.sh` |
| **测试内容** | 技能可用性、定时任务、配置完整性、API 密钥 |
| **输出目录** | `output/health-checks/{日期}/` |
| **GitHub 同步** | 测试通过后自动上传配置 |

---

## 4. API 配置清单

### 4.1 GitHub CLI

| 配置项 | 值 | 状态 |
|--------|-----|------|
| **Token** | ghp_************************************ | ✅ |
| **账户** | hongyu-zhou3434 | ✅ |
| **协议** | HTTPS | ✅ |
| **权限** | repo, workflow, gist, admin:org 等 | ✅ |

### 4.2 Summarize（百炼）

| 配置项 | 值 | 状态 |
|--------|-----|------|
| **OPENAI_API_KEY** | sk-sp-1dfcd6127bfc4033b85aa78f2ed6a995 | ✅ |
| **OPENAI_BASE_URL** | https://coding.dashscope.aliyuncs.com/v1 | ✅ |
| **SUMMARIZE_MODEL** | kimi-k2.5 | ✅ |

### 4.3 Tavily Search

| 配置项 | 值 | 状态 |
|--------|-----|------|
| **TAVILY_API_KEY** | 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 | ✅ |
| **API 端点** | https://api.tavily.com | ✅ |

### 4.4 Git SSH

| 配置项 | 值 | 状态 |
|--------|-----|------|
| **私钥路径** | `/root/.openclaw/123456789` | ✅ |
| **公钥路径** | `/root/.openclaw/123456789.pub` | ✅ |
| **SSH 配置** | `~/.ssh/config` | ✅ |
| **GitHub 账户** | hongyu-zhou3434 | ✅ |

---

## 5. 已安装技能清单（24个）

### 5.1 完全可用（无需额外配置）

| 技能 | 版本 | 来源 | 状态 |
|------|------|------|------|
| **weather** | 1.0.0 | openclaw-workspace | ✅ |
| **summarize** | 1.0.0 | openclaw-workspace | ✅ |
| **github** | - | openclaw-workspace | ✅ |
| **Agent Browser** | 0.20.6 | openclaw-workspace | ✅ |
| **skillhub/clawhub** | - | openclaw-bundled | ✅ |
| **self-improving-agent** | 3.0.1 | openclaw-workspace | ✅ |
| **find-skills** | - | openclaw-workspace | ✅ |
| **tavily-search** | 1.0.0 | openclaw-workspace | ✅ |
| **wps-skill** | 1.3.0 | openclaw-workspace | ✅ |
| **task-monitoring** | 1.0 | 本地配置 | ✅ |
| **四技能协同** | 1.0 | 本地配置 | ✅ |

### 5.2 需要凭证（已安装）

| 技能 | 版本 | 来源 | 状态 |
|------|------|------|------|
| **feishu-doc** | - | openclaw-extra | ⚠️ 需飞书凭证 |
| **feishu-drive** | - | openclaw-extra | ⚠️ 需飞书凭证 |
| **feishu-perm** | - | openclaw-extra | ⚠️ 需飞书凭证 |
| **feishu-wiki** | - | openclaw-extra | ⚠️ 需飞书凭证 |
| **wecom-doc** | - | openclaw-extra | ⚠️ 需企业微信凭证 |
| **tencent-cloud-cos** | - | openclaw-workspace | ⚠️ 需腾讯云密钥 |
| **tencent-docs** | - | openclaw-workspace | ⚠️ 需腾讯云密钥 |
| **tencentcloud-lighthouse** | - | openclaw-workspace | ⚠️ 需腾讯云密钥 |

---

## 6. 配置文件清单

| 文件路径 | 说明 | 状态 |
|----------|------|------|
| `/root/.openclaw/system_config.md` | 系统配置主文件 | ✅ |
| `/root/.openclaw/workspace/.config/skills-synergy.md` | 四技能协同配置 | ✅ |
| `/root/.openclaw/workspace/.config/summarize-config.md` | Summarize API 配置 | ✅ |
| `/root/.openclaw/workspace/.config/tavily-config.md` | Tavily API 配置 | ✅ |
| `/root/.openclaw/workspace/.config/.protected` | 配置保护标记 | ✅ |
| `/root/.openclaw/workspace/tasks/task-monitoring.md` | 任务监控配置 | ✅ |
| `/root/.openclaw/workspace/config/system-config-v1.0.md` | 本文件 | ✅ |

---

## 7. 验证命令

```bash
# 检查系统状态
openclaw status

# 检查技能列表
openclaw skills list

# 检查四技能协同
ls -la .config/skills-synergy.md

# 检查定时任务配置
ls -la tasks/task-monitoring.md

# 检查 API 配置
cat .config/summarize-config.md
cat .config/tavily-config.md

# 测试技能
curl -s "wttr.in/Beijing?format=3"
echo "test" | summarize -
gh auth status
```

---

## 8. 更新日志

| 版本 | 时间 | 更新内容 |
|------|------|----------|
| 1.0.0 | 2026-03-16 | 初始配置，四技能协同，24个技能就绪 |

---

*本配置由系统自动生成，遵循配置修改确认规则*

### 3.2 每日早6:00 - AI技术洞察报告

| 配置项 | 值 |
|--------|-----|
| **任务名称** | daily-ai-insight-6am |
| **执行时间** | 每日早6:00 |
| **Cron表达式** | `0 6 * * *` |
| **脚本路径** | `scripts/daily-ai-insight.sh` |
| **输出目录** | `output/daily-insights/{日期}/` |
| **报告数量** | 9个（8个公司 + 1个汇总） |
| **目标公司** | 字节跳动、阿里巴巴、腾讯、智谱AI、DeepSeek、Google、NVIDIA、MiniMax |
| **洞察范围** | 大模型、推理模型、多模态、算力卡、数据存储、数据加速、Agent |
| **归档周期** | 保留最近30天 |


---

## 9. 配置更新日志

| 版本 | 时间 | 更新内容 |
|------|------|----------|
| 1.0.0 | 2026-03-16 | 初始配置，四技能协同，24个技能就绪 |
| 1.0.1 | 2026-03-16 | 删除定时任务 daily-insight（19:00简化版） |

**删除说明**:
- 删除任务: daily-insight（19:00简化版）
- 删除原因: 与 daily-ai-insight-6am（早6点详细版）功能重复
- 保留任务: 
  - daily-ai-insight-6am（早6点）✅
  - system-health-check（21:00）✅ 已配置


### 3.3 每日早8:00 - AI动态洞察报告

| 配置项 | 值 |
|--------|-----|
| **任务名称** | daily-ai-news-8am |
| **执行时间** | 每日早8:00 |
| **Cron表达式** | `0 8 * * *` |
| **脚本路径** | `scripts/daily-ai-news-8am.sh` |
| **输出目录** | `output/daily-ai-news/{日期}/` |
| **输出格式** | MD + DOC + PDF |
| **洞察周期** | 过去24小时 |
| **数据来源** | arXiv、量子位、机器之心、MIT Tech Review等 |
| **目标公司** | OpenAI、Google、Meta、NVIDIA、阿里、字节、腾讯等14家 |
| **邮件通知** | 273477656@qq.com |
| **归档周期** | 保留最近30天 |

---

## 10. 定时任务监控配置（新增v1.0.3）

### 10.1 cron-wrapper - 统一任务包装器

| 配置项 | 值 |
|--------|-----|
| **脚本路径** | `scripts/cron-wrapper.sh` |
| **功能** | 为所有定时任务添加监控、日志和进度反馈 |
| **执行流程** | 5步：检查脚本 → 检查依赖 → 预执行检查 → 执行任务 → 后处理 |
| **状态文件** | `/tmp/task_{任务名}.status` |
| **日志文件** | `logs/{任务名}-{日期}-{时间}.log` |
| **执行时间统计** | 自动生成.duration文件 |

### 10.2 cron-status - 状态查询工具

| 配置项 | 值 |
|--------|-----|
| **脚本路径** | `scripts/cron-status.sh` |
| **功能** | 查询所有定时任务执行状态 |
| **用法** | `./cron-status.sh [任务名]` |
| **显示内容** | 任务状态、执行耗时、下次执行时间、日志文件 |

---

## 11. 邮件系统配置（更新v1.0.4）

### 11.1 邮件发送工具

| 配置项 | 值 | 说明 |
|--------|-----|------|
| **主脚本** | `skills/smtp-sender/email_sender.py` | 修复MIME类型问题 |
| **进度版本** | `scripts/send_email_with_progress.py` | 带进度显示 |
| **SMTP服务器** | smtp.qq.com:465 | QQ邮箱 |
| **发件人** | 273477656@qq.com | 系统邮箱 |
| **修复内容** | 附件MIME类型 | PDF使用application/pdf，MD使用text/markdown |

### 11.2 邮件通知任务

| 任务 | 收件人 | 内容 |
|------|--------|------|
| daily-ai-insight-6am | 273477656@qq.com | 9个报告（MD+PDF） |
| daily-ai-news-8am | 273477656@qq.com | AI动态报告（MD+PDF） |
| system-health-check | 273477656@qq.com | 失败时发送告警 |

---

## 12. 系统健康检查配置（更新v1.0.5）

### 12.1 检查项目（10个类别，38项）

| 类别 | 检查项数 | 说明 |
|------|----------|------|
| 系统配置检查 | 4 | 工作区、配置、技能目录等 |
| 核心脚本检查 | 4 | cron-wrapper、定时任务脚本等 |
| 技能可用性检查 | 14 | 所有已安装技能（新增） |
| 依赖检查 | 4 | Python3、pip、curl、git |
| Python包检查 | 4 | python-docx、openpyxl等 |
| API密钥检查 | 2 | Tavily、OpenAI |
| 定时任务检查 | 3 | 3个定时任务配置 |
| 网络连接检查 | 2 | GitHub SSH、SMTP |
| 磁盘空间检查 | 1 | 使用率<90% |

### 12.2 技能检查清单（14个）

| 技能名称 | 检查方式 | 状态 |
|----------|----------|------|
| Agent Browser | SKILL.md存在 | ✅ |
| Find Skills | SKILL.md存在 | ✅ |
| GitHub | SKILL.md存在 | ✅ |
| Obsidian | SKILL.md存在 | ✅ |
| OpenClaw Tavily Search | SKILL.md存在 | ✅ |
| Self Improving Agent | SKILL.md存在 | ✅ |
| SMTP Sender | email_sender.py存在 | ✅ |
| Summarize | SKILL.md存在 | ✅ |
| Tavily Search | search.mjs存在 | ✅ |
| Tencent Cloud Lighthouse | SKILL.md存在 | ✅ |
| Tencent COS | SKILL.md存在 | ✅ |
| Tencent Docs | SKILL.md存在 | ✅ |
| Weather | SKILL.md存在 | ✅ |
| WPS Skill | main.py存在 | ✅ |

---

## 13. API密钥配置（新增v1.0.6）

### 13.1 集中配置文件

| 配置项 | 值 |
|--------|-----|
| **文件路径** | `config/api-keys.sh` |
| **加载方式** | `source config/api-keys.sh` |
| **系统级配置** | `/etc/profile.d/openclaw-api-keys.sh` |
| **用户级配置** | `~/.bashrc` |

### 13.2 已配置API密钥

| 密钥名称 | 值 | 用途 |
|----------|-----|------|
| **TAVILY_API_KEY** | tvly-dev-3Ds3oa-7krcDnvt1zwIgE... | AI搜索、资讯检索 |
| **OPENAI_API_KEY** | sk-sp-1dfcd6127bfc4033b85aa78f... | AI模型调用 |
| **OPENAI_BASE_URL** | https://coding.dashscope.aliyuncs.com/v1 | 百炼平台 |

---

## 14. 格式转换工具配置

### 14.1 标准转换工具

| 工具 | 路径 | 优先级 |
|------|------|--------|
| **wps-skill** | `skills/wps-skill/scripts/main.py` | 第一优先 |
| **doc-converter.sh** | `scripts/doc-converter.sh` | 统一接口 |
| **batch_md_to_pdf.py** | `scripts/batch_md_to_pdf.py` | 备选方案 |

### 14.2 支持的转换格式

| 源格式 | 目标格式 | 工具 |
|--------|----------|------|
| Markdown | Word (DOCX) | wps-skill |
| Markdown | Excel (XLSX) | wps-skill |
| Markdown | PPT (PPTX) | wps-skill |
| Markdown | PDF | wps-skill / batch_md_to_pdf.py |

---

## 15. 当前系统状态（2026-03-16）

### 15.1 健康检查结果

| 指标 | 数值 |
|------|------|
| **总检查项** | 38 |
| **通过项** | 38 |
| **失败项** | 0 |
| **通过率** | 100% |
| **系统状态** | 🟢 完全健康 |

### 15.2 GitHub同步状态

| 项目 | 状态 |
|------|------|
| **仓库** | hongyu-zhou3434/openclaw_config_code |
| **分支** | master (main) |
| **总文件数** | 210+ |
| **最新提交** | 系统健康检查自动同步 |
| **同步状态** | ✅ 已同步 |

---

## 16. 更新日志（完整）

| 版本 | 时间 | 更新内容 |
|------|------|----------|
| 1.0.0 | 2026-03-16 | 初始配置，四技能协同，24个技能就绪 |
| 1.0.1 | 2026-03-16 | 删除定时任务 daily-insight（19:00简化版） |
| 1.0.2 | 2026-03-16 | 添加system-health-check（21:00）定时任务到crontab |
| 1.0.3 | 2026-03-16 | 添加cron-wrapper定时任务包装器，支持5步执行流程和状态监控 |
| 1.0.4 | 2026-03-16 | 修复邮件附件MIME类型问题，PDF正确显示而非bin格式 |
| 1.0.5 | 2026-03-16 | 更新system-health-check.sh，添加14个技能可用性检查 |
| 1.0.6 | 2026-03-16 | 添加API密钥集中配置（config/api-keys.sh），支持Tavily和OpenAI |

