---
name: code-analyzer
description: 代码分析工具。使用 CodeBuddy 自动分析代码架构、模型结构、模型参数，并统一使用 wps-skill 生成 PDF 格式技术分析报告。
metadata:
  {
    "openclaw":
      {
        "emoji": "🔍",
        "always": true,
        "requires":
          {
            "bins": ["codebuddy", "node"],
            "skills": ["wps-skill"]
          },
      },
  }
---

# 代码分析工具 (CodeBuddy + WPS)

使用腾讯 CodeBuddy 国内版工具自动分析代码，**统一使用 wps-skill 生成 PDF 格式**技术分析报告。

## 技术架构

### 核心组件

| 组件 | 功能 | 技术栈 |
|------|------|--------|
| **analyze-local.js** | 本地代码分析引擎 | Node.js + CodeBuddy API |
| **analyze.js** | GitHub 代码分析引擎 | Node.js + CodeBuddy API |
| **pdf-generator.js** | PDF 生成器（多方案降级） | Node.js + pandoc/xelatex/wkhtmltopdf |
| **wps-skill 集成** | 专业 PDF 排版 | WPS Office API |

### 分析流程

```
┌─────────────────────────────────────────────────────────────┐
│                    代码分析流程                              │
├─────────────────────────────────────────────────────────────┤
│  1. 目录扫描                                                  │
│     ├── 递归遍历文件系统                                       │
│     ├── 识别文件类型和语言分布                                  │
│     └── 统计代码量和复杂度                                      │
│                          ↓                                    │
│  2. 结构分析                                                  │
│     ├── 识别项目架构模式                                       │
│     ├── 分析依赖关系                                          │
│     └── 提取关键文件                                          │
│                          ↓                                    │
│  3. AI 深度分析 (CodeBuddy)                                   │
│     ├── 代码质量评估                                          │
│     ├── 架构建议                                              │
│     └── 最佳实践推荐                                          │
│                          ↓                                    │
│  4. 报告生成                                                  │
│     ├── Markdown 格式整理                                      │
│     ├── wps-skill PDF 转换                                     │
│     └── 专业排版输出                                          │
└─────────────────────────────────────────────────────────────┘
```

## 依赖安装

```bash
# 安装 CodeBuddy
npm install -g @tencent-ai/codebuddy-code

# 安装 PDF 生成依赖（可选，推荐）
# 方案1: texlive-xetex (推荐，中文支持好)
sudo apt-get install texlive-xetex texlive-lang-chinese

# 方案2: wkhtmltopdf
sudo apt-get install wkhtmltopdf

# 方案3: weasyprint
pip install weasyprint

# 确保 wps-skill 已安装
# 位于: /root/.openclaw/workspace/skills/wps-skill
```

## 功能特性

### 1. 代码统计
- **文件统计**: 总文件数、目录数、代码行数
- **语言分布**: 识别编程语言和技术栈
- **复杂度分析**: 代码复杂度评估

### 2. 架构分析
- **项目结构**: 目录层级和模块划分
- **依赖分析**: 第三方依赖和内部模块关系
- **设计模式**: 识别常见设计模式应用

### 3. AI 智能分析 (CodeBuddy)
- **代码质量**: 潜在问题和改进建议
- **安全扫描**: 常见安全漏洞检测
- **性能优化**: 性能瓶颈识别
- **最佳实践**: 符合行业标准的建议

### 4. 报告生成
- **多格式输出**: Markdown、PDF
- **专业排版**: WPS Office 生成专业 PDF
- **自动降级**: 多方案 PDF 生成，确保可用性

## 使用方法

### 分析本地项目（自动生成 PDF）

```bash
node /root/.openclaw/workspace/skills/code-analyzer/analyze-local.js <目录路径>
```

**示例：**
```bash
# 分析项目
node /root/.openclaw/workspace/skills/code-analyzer/analyze-local.js \
  /path/to/your/project

# 输出位置
# /root/.openclaw/workspace/skills/code-analyzer/reports/
```

### 分析 GitHub 仓库

```bash
node /root/.openclaw/workspace/skills/code-analyzer/analyze.js <仓库URL>
```

**示例：**
```bash
node /root/.openclaw/workspace/skills/code-analyzer/analyze.js \
  https://github.com/username/repo
```

### 将 Markdown 转换为 PDF

```bash
# 使用 pdf-generator.js（自动降级方案）
node /root/.openclaw/workspace/skills/code-analyzer/pdf-generator.js \
  report.md \
  report.pdf

# 或使用 wps-skill 转换
node /root/.openclaw/workspace/skills/wps-skill/convert.js \
  --input report.md \
  --output report.pdf \
  --format pdf
```

## 报告生成流程

```
1. 分析代码
   ├── 扫描目录结构
   ├── 统计文件和代码
   ├── 识别技术栈
   └── 提取关键文件
   ↓
2. AI 分析 (CodeBuddy)
   ├── 代码质量评估
   ├── 架构分析
   ├── 安全扫描
   └── 生成建议
   ↓
3. 生成 Markdown 报告
   ├── 项目概览
   ├── 统计信息
   ├── 技术栈分析
   ├── 架构评估
   └── 改进建议
   ↓
4. 转换为 PDF
   ├── 尝试 wps-skill
   ├── 尝试 pandoc+xelatex
   ├── 尝试 wkhtmltopdf
   └── 尝试 weasyprint
   ↓
5. 输出 PDF 报告
```

## 报告格式

### 统一使用 wps-skill 生成

| 格式 | 工具 | 说明 |
|------|------|------|
| **PDF** | wps-skill | 专业排版，适合打印和分享 |
| **Markdown** | code-analyzer | 原始格式，便于编辑 |

### 报告内容结构

```markdown
# 技术分析报告

## 1. 项目概览
- 项目名称
- 分析时间
- 代码规模

## 2. 代码统计
- 文件数量统计
- 代码行数统计
- 目录结构

## 3. 技术栈分析
- 编程语言分布
- 框架和库
- 构建工具

## 4. 架构分析
- 项目结构
- 模块划分
- 依赖关系

## 5. 代码质量评估
- 潜在问题
- 安全漏洞
- 性能瓶颈

## 6. 改进建议
- 代码优化
- 架构改进
- 最佳实践

## 7. 关键文件预览
- 重要代码片段
- 配置文件
- 文档
```

### PDF 报告特点（WPS生成）

- ✅ 专业排版设计
- ✅ 支持中文显示
- ✅ 表格美化
- ✅ 代码高亮
- ✅ 页眉页脚
- ✅ 目录导航
- ✅ 适合打印和分享
- ✅ 符合中文文档规范

## 技术实现细节

### PDF 生成策略（自动降级）

| 优先级 | 方案 | 依赖 | 特点 |
|--------|------|------|------|
| 1 | **wps-skill** | WPS Office | 最佳中文支持 |
| 2 | **pandoc+xelatex** | texlive-xetex | 学术排版 |
| 3 | **wkhtmltopdf** | wkhtmltopdf | HTML 转 PDF |
| 4 | **weasyprint** | weasyprint | Python 方案 |
| 5 | **在线 API** | 网络服务 | 备用方案 |

### 代码分析算法

```javascript
// 目录扫描算法
function analyzeStructure(dir) {
  const structure = {
    totalFiles: 0,
    totalDirs: 0,
    languages: {},
    keyFiles: [],
    fileTypes: {}
  };
  
  // 递归扫描，深度限制为 4 层
  function scan(currentDir, depth = 0) {
    if (depth > 4) return;
    
    const items = fs.readdirSync(currentDir);
    for (const item of items) {
      // 跳过隐藏文件和依赖目录
      if (item.startsWith('.') || 
          item === 'node_modules' || 
          item === 'dist' || 
          item === 'build') continue;
      
      // 统计文件类型
      const ext = path.extname(item).toLowerCase();
      structure.languages[ext] = (structure.languages[ext] || 0) + 1;
      
      // 识别关键文件
      if (isKeyFile(item)) {
        structure.keyFiles.push(item);
      }
    }
  }
  
  scan(dir);
  return structure;
}
```

### AI 分析集成

```javascript
// CodeBuddy API 调用
async function analyzeWithCodeBuddy(code, context) {
  const prompt = `
    分析以下代码：
    - 代码质量评估
    - 潜在问题识别
    - 架构建议
    - 安全漏洞检查
    - 性能优化建议
    
    代码上下文：${context}
    代码内容：${code}
  `;
  
  const result = await codebuddy.analyze(prompt);
  return parseAnalysisResult(result);
}
```

## 报告位置

生成的报告保存在：
```
/root/.openclaw/workspace/skills/code-analyzer/reports/
├── {project-name}-analysis-{timestamp}.pdf  ← PDF 报告 (WPS生成)
├── {project-name}-analysis-{timestamp}.md   ← Markdown 报告
└── {project-name}-analysis-{timestamp}.json ← 原始数据
```

## 工具列表

| 工具 | 功能 | 输入 | 输出格式 |
|------|------|------|----------|
| `analyze-local.js` | 本地代码分析 | 目录路径 | MD → PDF |
| `analyze.js` | GitHub 代码分析 | 仓库 URL | MD → PDF |
| `pdf-generator.js` | PDF 生成器 | Markdown | PDF |
| `wps-skill/convert.js` | WPS PDF 转换 | Markdown | PDF |

## 配置参数

### 环境变量

```bash
# CodeBuddy 配置
export CODEBUDDY_API_KEY="your-api-key"

# WPS 配置（可选）
export WPS_APP_ID="your-app-id"
export WPS_APP_SECRET="your-app-secret"
```

### 分析配置

```javascript
// analyze-local.js 配置
const CONFIG = {
  reportDir: '/root/.openclaw/workspace/skills/code-analyzer/reports',
  maxFileSize: 1024 * 1024,  // 最大文件大小 1MB
  maxDepth: 4,               // 最大扫描深度
  excludeDirs: ['node_modules', 'dist', 'build', '.git'],
  excludeFiles: ['.DS_Store', 'Thumbs.db']
};
```

## 性能优化

### 大项目处理
- **分块分析**: 超过 1000 个文件时自动分块
- **异步处理**: 并行分析多个目录
- **缓存机制**: 缓存已分析文件的结果
- **超时控制**: 单个文件分析超时 30 秒

### 内存管理
- **流式读取**: 大文件使用流式读取
- **垃圾回收**: 定期清理临时数据
- **限制并发**: 控制同时处理的文件数

## 错误处理

### 常见错误及解决方案

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| PDF 生成失败 | 缺少依赖 | 安装 texlive-xetex 或 wkhtmltopdf |
| CodeBuddy 超时 | 网络问题 | 检查网络连接或重试 |
| 内存不足 | 项目太大 | 增加内存或分批分析 |
| 权限错误 | 文件权限 | 检查目录读写权限 |

## 最佳实践

### 分析前准备
1. 清理不必要的文件（node_modules, dist, build）
2. 确保代码可编译/运行
3. 更新依赖到最新版本
4. 检查敏感信息是否已移除

### 分析过程
1. 先进行小范围测试
2. 关注关键文件和模块
3. 结合 AI 建议进行优化
4. 定期重新分析跟踪改进

### 报告使用
1. 与团队分享分析结果
2. 制定改进计划
3. 跟踪改进进度
4. 建立代码质量基准

## 使用示例

### 示例 1: 分析 Node.js 项目

```bash
# 分析 Express 项目
node analyze-local.js /path/to/express-app

# 预期输出
# 📊 项目统计
# - 总文件数: 45
# - 代码行数: 3,240
# - 主要语言: JavaScript (80%), TypeScript (15%)
#
# 🏗️ 架构分析
# - 框架: Express.js
# - 数据库: MongoDB (Mongoose)
# - 认证: JWT
#
# ⚠️ 发现的问题
# - 3 个潜在安全漏洞
# - 2 个性能优化点
# - 5 个代码风格问题
```

### 示例 2: 分析 Python 项目

```bash
# 分析 Django 项目
node analyze-local.js /path/to/django-app

# 预期输出
# 📊 项目统计
# - 总文件数: 120
# - 代码行数: 8,500
# - 主要语言: Python (95%)
#
# 🏗️ 架构分析
# - 框架: Django 4.2
# - 数据库: PostgreSQL
# - 缓存: Redis
#
# ✅ 代码质量
# - 整体评分: 85/100
# - 测试覆盖率: 78%
```

### 示例 3: 生成 PDF 报告

```bash
# 生成分析报告
node analyze-local.js /path/to/project

# 输出
# ✅ Markdown 报告: reports/project-analysis-20260325.md
# ✅ PDF 报告: reports/project-analysis-20260325.pdf
# ✅ JSON 数据: reports/project-analysis-20260325.json
```

## 集成方案

### 与 CI/CD 集成

```yaml
# .github/workflows/code-analysis.yml
name: Code Analysis

on: [push, pull_request]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Code Analysis
        run: |
          node /root/.openclaw/workspace/skills/code-analyzer/analyze-local.js .
      
      - name: Upload Report
        uses: actions/upload-artifact@v3
        with:
          name: analysis-report
          path: reports/*.pdf
```

### 与定时任务集成

```bash
# 添加到 crontab
# 每周一早上 6 点分析项目
0 6 * * 1 node /root/.openclaw/workspace/skills/code-analyzer/analyze-local.js /path/to/project
```

## 更新日志

### 2026-03-25 (v2.0.0)
- ✅ 重写 SKILL.md，添加详细技术文档
- ✅ 添加技术架构说明
- ✅ 完善 PDF 生成策略文档
- ✅ 添加性能优化说明
- ✅ 添加错误处理指南
- ✅ 添加最佳实践建议
- ✅ 添加使用示例
- ✅ 添加 CI/CD 集成方案

### 2026-03-24 (v1.0.0)
- ✅ 初始版本发布
- ✅ 支持本地代码分析
- ✅ 支持 GitHub 代码分析
- ✅ 集成 CodeBuddy AI 分析
- ✅ 多方案 PDF 生成（自动降级）
- ✅ wps-skill 集成

## 相关链接

- [CodeBuddy 官网](https://codebuddy.tencent.com)
- [WPS Skill 文档](/root/.openclaw/workspace/skills/wps-skill/SKILL.md)
- [系统配置文档](/root/.openclaw/workspace/config/system-config-v1.0.md)

## 许可证

MIT License - 开源免费使用

---

**维护者**: OpenClaw AI  
**最后更新**: 2026-03-25  
**版本**: 2.0.0