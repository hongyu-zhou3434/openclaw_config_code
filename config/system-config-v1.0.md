# OpenClaw 系统配置 v1.0

**版本**: 1.0.0
**生成时间**: 2026-03-16 00:10:00 +08:00
**生效状态**: ✅ 已生效

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


| 1.0.2 | 2026-03-16 | 添加system-health-check（21:00）定时任务到crontab |

