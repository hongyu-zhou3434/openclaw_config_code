# 脚本工具集 - 任务执行优化方案

## 📋 解决的问题

针对之前任务执行中的配置缺陷，本工具集提供以下改进：

| 原问题 | 解决方案 |
|--------|----------|
| 进度同步缺失 | 实时进度输出和日志记录 |
| 超时处理困难 | 同步执行 + 实时反馈 |
| 无执行日志 | 完整的日志文件和状态追踪 |
| 状态检查困难 | 状态文件 + 监控工具 |

---

## 🛠️ 工具清单

### 1. batch_md_to_pdf.py - Markdown批量转PDF

**功能**: 批量将Markdown文件转换为PDF，带实时进度显示

**用法**:
```bash
python3 batch_md_to_pdf.py file1.md file2.md file3.md

# 指定输出目录
python3 batch_md_to_pdf.py *.md --output-dir /path/to/output
```

**特点**:
- ✅ 实时显示转换进度
- ✅ 每个文件显示大小
- ✅ 汇总统计（成功/失败）
- ✅ 详细结果表格

---

### 2. send_email_with_progress.py - 带进度邮件发送

**功能**: 发送邮件并显示每个步骤的进度

**用法**:
```bash
python3 send_email_with_progress.py \
  --to "recipient@example.com" \
  --subject "邮件主题" \
  --body "邮件正文" \
  --attachments file1.pdf file2.pdf
```

**特点**:
- ✅ 5个步骤清晰展示
- ✅ 附件逐个显示大小
- ✅ SMTP连接状态可见
- ✅ 发送完成汇总

---

### 3. daily_report_pipeline.sh - 统一流水线

**功能**: 整合转换和发送的完整流程

**用法**:
```bash
./daily_report_pipeline.sh
```

**特点**:
- ✅ 依赖自动检查
- ✅ 彩色输出
- ✅ 完整流程封装
- ✅ 执行耗时统计

---

### 4. task_monitor.py - 任务监控工具

**功能**: 实时监控任务执行状态

**用法**:
```bash
# 运行命令并监控
python3 task_monitor.py run --task "pdf转换" --cmd "python3 batch_md_to_pdf.py *.md"

# 查看任务状态
python3 task_monitor.py status --task "pdf转换"

# 列出所有活动任务
python3 task_monitor.py list
```

**特点**:
- ✅ 实时日志输出
- ✅ 状态持久化存储
- ✅ 多任务管理
- ✅ 执行时间统计

---

## 📊 使用示例

### 场景1: 手动执行今日报告转换和发送

```bash
# 方法1: 使用统一流水线（推荐）
./daily_report_pipeline.sh

# 方法2: 分步执行
python3 batch_md_to_pdf.py /root/.openclaw/workspace/output/daily-insights/2026-03-16/*.md

python3 send_email_with_progress.py \
  --to "273477656@qq.com" \
  --subject "📊 每日AI技术洞察报告" \
  --body "详见附件" \
  --attachments /root/.openclaw/workspace/output/daily-insights/2026-03-16/*.pdf
```

### 场景2: 监控长时间任务

```bash
# 启动监控模式执行
python3 task_monitor.py run \
  --task "批量PDF转换" \
  --cmd "python3 batch_md_to_pdf.py *.md"

# 在另一个终端查看状态
python3 task_monitor.py status --task "批量PDF转换"
```

---

## 🔧 配置优化总结

### 之前的执行方式（有缺陷）
```bash
# 问题：后台执行，无法实时看到进度
exec(command, background=True)
process(action="poll", timeout=60000)  # 需要轮询
```

### 现在的执行方式（优化后）
```bash
# 方案1: 同步执行 + 实时输出
python3 batch_md_to_pdf.py *.md
# 每个文件转换完成立即显示结果

# 方案2: 监控模式
python3 task_monitor.py run --task "名称" --cmd "命令"
# 实时日志 + 状态文件

# 方案3: 统一流水线
./daily_report_pipeline.sh
# 完整的彩色输出和统计
```

---

## 📈 改进效果

| 指标 | 改进前 | 改进后 |
|------|--------|--------|
| 进度可见性 | ❌ 需要轮询 | ✅ 实时输出 |
| 执行日志 | ❌ 无 | ✅ 完整日志 |
| 状态追踪 | ❌ 困难 | ✅ 状态文件 |
| 错误反馈 | ❌ 延迟 | ✅ 即时 |
| 用户体验 | ❌ 等待焦虑 | ✅ 清晰可见 |

---

## 📝 维护说明

- 所有脚本位于: `/root/.openclaw/workspace/scripts/`
- 日志文件位置: `/tmp/task_*.log`
- 状态文件位置: `/tmp/task_*.status`
- 建议定期清理: `rm /tmp/task_*.{log,status}`
