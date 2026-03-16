# 每日早8点AI动态洞察定时任务

**任务名称**: daily-ai-news-8am  
**执行时间**: 每日早8:00  
**Cron表达式**: `0 8 * * *`  
**创建时间**: 2026-03-16  
**版本**: 1.0

---

## 任务说明

每日早8点自动生成AI动态洞察报告，洞察过去24小时内全球AI领域的最新动态，并将报告以DOC和PDF格式发送到QQ邮箱。

---

## 数据来源

### 权威资讯来源清单

| 来源类型 | 具体来源 |
|----------|----------|
| **学术论文** | arXiv (cs.AI, cs.CL, cs.CV, cs.LG) |
| **中文科技媒体** | 量子位 (qbitai.com)、机器之心 (jiqizhixin.com) |
| **国际科技媒体** | MIT Technology Review、VentureBeat、TechCrunch |
| **论文聚合** | Paper Digest |

### 重点AI公司（14家）

**国际公司**: OpenAI、Google、Meta、NVIDIA、Microsoft、Anthropic  
**中国公司**: 阿里巴巴、字节跳动、腾讯、DeepSeek、智谱AI、MiniMax、百度、华为

### 洞察关键词

- AI模型发布
- 大语言模型
- 多模态模型
- 推理模型
- 视频生成
- 算力卡/GPU
- 数据存储
- AI Agent/智能体

---

## 报告内容

1. **今日AI热点概览** - 重大发布、技术突破
2. **重点公司动态** - 14家AI公司最新动态
3. **技术趋势分析** - 模型发展、基础设施、应用层
4. **关键数据点** - 新模型发布数、技术突破数等
5. **明日关注** - 基于趋势的建议关注项

---

## 输出文件

```
output/daily-ai-news/{日期}/
├── AI动态洞察报告_{日期}.md    # Markdown原始格式
├── AI动态洞察报告_{日期}.docx  # Word文档格式
├── AI动态洞察报告_{日期}.pdf   # PDF格式
└── ai-news-generation.log      # 生成日志
```

---

## 邮件通知

- **收件人**: 273477656@qq.com
- **主题**: AI动态洞察报告 - {日期}
- **附件**: MD + DOC + PDF 三份报告

---

## 执行脚本

```bash
/root/.openclaw/workspace/scripts/daily-ai-news-8am.sh
```

---

## 依赖配置

| 配置项 | 值 |
|--------|-----|
| **TAVILY_API_KEY** | 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 |
| **OPENAI_API_KEY** | sk-sp-1dfcd6127bfc4033b85aa78f2ed6a995 |
| **OPENAI_BASE_URL** | https://coding.dashscope.aliyuncs.com/v1 |
| **QQ邮箱** | 273477656@qq.com |
| **SMTP服务器** | smtp.qq.com:465 |

---

## 定时任务设置

### 方式1: 使用 cron

```bash
# 编辑 crontab
crontab -e

# 添加任务
0 8 * * * /root/.openclaw/workspace/scripts/daily-ai-news-8am.sh >> /root/.openclaw/workspace/logs/daily-ai-news.log 2>&1
```

---

## 验证命令

```bash
# 手动执行任务
/root/.openclaw/workspace/scripts/daily-ai-news-8am.sh

# 检查输出目录
ls -la /root/.openclaw/workspace/output/daily-ai-news/$(date +%Y-%m-%d)/

# 检查日志
tail -f /root/.openclaw/workspace/logs/daily-ai-news.log
```

---

## 任务状态

| 检查项 | 状态 |
|--------|------|
| 脚本创建 | ✅ 已创建 |
| 执行权限 | ✅ 已设置 |
| API配置 | ✅ 已配置 |
| 邮件配置 | ✅ 已配置 |
| 输出目录 | ✅ 已创建 |
| 定时任务 | ⏳ 待配置 |

---

*本任务配置由系统自动生成*
