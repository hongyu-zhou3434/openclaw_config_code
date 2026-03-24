---
name: code-analyzer
description: 代码分析工具。使用 CodeBuddy 自动分析代码架构、模型结构、模型参数，并生成 PDF 格式技术分析报告。
metadata:
  {
    "openclaw":
      {
        "emoji": "🔍",
        "always": true,
        "requires":
          {
            "bins": ["codebuddy", "node"],
          },
      },
  }
---

# 代码分析工具 (CodeBuddy)

使用腾讯 CodeBuddy 国内版工具自动分析代码，生成 **PDF 格式**技术分析报告。

## 安装 CodeBuddy

```bash
npm install -g @tencent-ai/codebuddy-code
```

## 安装 PDF 生成依赖（可选）

```bash
# 进入 skill 目录
cd /root/.openclaw/workspace/skills/code-analyzer

# 安装 puppeteer（用于生成 PDF）
npm install puppeteer
```

## 功能

1. **本地代码分析** - 分析本地项目目录
2. **代码统计** - 文件数量、语言分布
3. **架构分析** - 识别项目结构和技术栈
4. **生成报告** - **PDF 格式**技术分析报告（同时生成 Markdown）

## 使用方法

### 分析本地项目

```bash
node /root/.openclaw/workspace/skills/code-analyzer/analyze-local.js <目录路径>
```

**示例：**
```bash
# 分析 wecom-calendar 项目
node /root/.openclaw/workspace/skills/code-analyzer/analyze-local.js \
  /root/.openclaw/workspace/skills/wecom-calendar

# 分析任意项目
node /root/.openclaw/workspace/skills/code-analyzer/analyze-local.js \
  /path/to/your/project
```

### 将 Markdown 转换为 PDF

```bash
node /root/.openclaw/workspace/skills/code-analyzer/generate-pdf.js \
  <markdown文件> [输出pdf文件]
```

**示例：**
```bash
node /root/.openclaw/workspace/skills/code-analyzer/generate-pdf.js \
  report.md report.pdf
```

## 报告格式

### 生成的文件

| 格式 | 文件扩展名 | 说明 |
|------|-----------|------|
| **PDF** | `.pdf` | 专业排版，适合打印和分享 |
| **Markdown** | `.md` | 原始格式，便于编辑 |
| **HTML** | `.html` | 中间格式，可在浏览器查看 |

### 报告内容

- **项目信息** - 分析目录和时间
- **代码统计** - 文件数、目录数
- **技术栈分析** - 编程语言分布
- **关键文件** - 识别重要文件
- **架构分析** - CodeBuddy AI 分析
- **代码建议** - 质量改进建议
- **文件预览** - 关键文件内容预览

### PDF 报告特点

- ✅ 专业排版设计
- ✅ 支持中文显示
- ✅ 表格美化
- ✅ 代码高亮
- ✅ 页眉页脚
- ✅ 适合打印和分享

## 报告位置

生成的报告保存在：
```
/root/.openclaw/workspace/skills/code-analyzer/reports/
├── {project-name}-analysis-{timestamp}.pdf  ← PDF 报告
├── {project-name}-analysis-{timestamp}.md   ← Markdown 报告
└── {project-name}-analysis-{timestamp}.html ← HTML 预览
```

## 工具列表

| 工具 | 功能 | 输出格式 |
|------|------|----------|
| `analyze-local.js` | 本地代码分析 | PDF + MD + HTML |
| `analyze.js` | GitHub 代码分析 | MD |
| `generate-pdf.js` | Markdown 转 PDF | PDF |

## 注意事项

- 云端 AI 分析需要 CodeBuddy 登录
- PDF 生成需要安装 puppeteer（可选）
- 大项目分析可能需要较长时间
- PDF 生成失败时会保留 Markdown 报告

## 示例报告

运行分析后将生成类似以下内容的 PDF 报告：

```
┌─────────────────────────────────────┐
│     技术分析报告                      │
│     Code Analysis Report              │
│                                      │
│  分析目录: /path/to/project          │
│  分析时间: 2026/3/24 13:44:10        │
└─────────────────────────────────────┘

代码统计
─────────
总文件数: 28
总目录数: 1

技术栈分析
───────────
JavaScript/TypeScript: 15 个文件
Markdown: 2 个文件
JSON: 1 个文件

关键文件
─────────
- README.md
- package.json
- index.js
...
```
