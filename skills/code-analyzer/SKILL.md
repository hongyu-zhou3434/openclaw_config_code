---
name: code-analyzer
description: 代码分析工具。使用 CodeBuddy 自动分析代码架构、模型结构、模型参数，并生成技术分析报告。
metadata:
  {
    "openclaw":
      {
        "emoji": "🔍",
        "always": true,
        "requires":
          {
            "bins": ["codebuddy"],
          },
      },
  }
---

# 代码分析工具 (CodeBuddy)

使用腾讯 CodeBuddy 国内版工具自动分析代码，生成技术分析报告。

## 安装 CodeBuddy

```bash
npm install -g @tencent-ai/codebuddy-code
```

## 功能

1. **本地代码分析** - 分析本地项目目录
2. **代码统计** - 文件数量、语言分布
3. **架构分析** - 识别项目结构和技术栈
4. **生成报告** - Markdown 格式技术分析报告

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

## 报告内容

- **项目信息** - 分析目录和时间
- **代码统计** - 文件数、目录数
- **技术栈分析** - 编程语言分布
- **关键文件** - 识别重要文件
- **架构分析** - CodeBuddy AI 分析
- **代码建议** - 质量改进建议

## 报告位置

生成的报告保存在：
```
/root/.openclaw/workspace/skills/code-analyzer/reports/
```

## 工具列表

| 工具 | 功能 | 用法 |
|------|------|------|
| `analyze-local.js` | 本地代码分析 | `node analyze-local.js <目录>` |
| `analyze.js` | GitHub 代码分析 | `node analyze.js <github-url>` |

## 注意事项

- CodeBuddy 详细分析需要交互式环境
- GitHub 分析需要稳定的网络连接
- 大项目分析可能需要较长时间
