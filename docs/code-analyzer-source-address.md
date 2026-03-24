# 代码分析工具源代码存储地址

## 📁 本地存储地址

| 路径类型 | 完整路径 |
|----------|----------|
| **Skill 根目录** | `/root/.openclaw/workspace/skills/code-analyzer/` |
| **主分析脚本** | `/root/.openclaw/workspace/skills/code-analyzer/analyze-local.js` |
| **GitHub 分析脚本** | `/root/.openclaw/workspace/skills/code-analyzer/analyze.js` |
| **PDF 生成器** | `/root/.openclaw/workspace/skills/code-analyzer/pdf-generator.js` |
| **PDF 转换脚本** | `/root/.openclaw/workspace/skills/code-analyzer/convert-to-pdf.js` |
| **文档** | `/root/.openclaw/workspace/skills/code-analyzer/SKILL.md` |
| **报告目录** | `/root/.openclaw/workspace/skills/code-analyzer/reports/` |

## 🌐 GitHub 远程仓库

| 项目 | 地址 |
|------|------|
| **仓库 URL** | `https://github.com/hongyu-zhou3434/openclaw_config_code` |
| **SSH 地址** | `git@github.com:hongyu-zhou3434/openclaw_config_code.git` |
| **Skill 目录** | `https://github.com/hongyu-zhou3434/openclaw_config_code/tree/main/skills/code-analyzer` |

## 📄 源代码文件列表

| 文件名 | GitHub 地址 | 本地路径 |
|--------|-------------|----------|
| SKILL.md | [查看](https://github.com/hongyu-zhou3434/openclaw_config_code/blob/main/skills/code-analyzer/SKILL.md) | `skills/code-analyzer/SKILL.md` |
| analyze-local.js | [查看](https://github.com/hongyu-zhou3434/openclaw_config_code/blob/main/skills/code-analyzer/analyze-local.js) | `skills/code-analyzer/analyze-local.js` |
| analyze.js | [查看](https://github.com/hongyu-zhou3434/openclaw_config_code/blob/main/skills/code-analyzer/analyze.js) | `skills/code-analyzer/analyze.js` |
| pdf-generator.js | [查看](https://github.com/hongyu-zhou3434/openclaw_config_code/blob/main/skills/code-analyzer/pdf-generator.js) | `skills/code-analyzer/pdf-generator.js` |
| convert-to-pdf.js | [查看](https://github.com/hongyu-zhou3434/openclaw_config_code/blob/main/skills/code-analyzer/convert-to-pdf.js) | `skills/code-analyzer/convert-to-pdf.js` |
| generate-pdf.js | [查看](https://github.com/hongyu-zhou3434/openclaw_config_code/blob/main/skills/code-analyzer/generate-pdf.js) | `skills/code-analyzer/generate-pdf.js` |
| package.json | [查看](https://github.com/hongyu-zhou3434/openclaw_config_code/blob/main/skills/code-analyzer/package.json) | `skills/code-analyzer/package.json` |

## 🔗 快速访问链接

- **GitHub 仓库主页**: https://github.com/hongyu-zhou3434/openclaw_config_code
- **Skill 目录**: https://github.com/hongyu-zhou3434/openclaw_config_code/tree/main/skills/code-analyzer
- **最新提交**: https://github.com/hongyu-zhou3434/openclaw_config_code/commits/main

## 📊 仓库信息

| 属性 | 值 |
|------|-----|
| **仓库名称** | openclaw_config_code |
| **所有者** | hongyu-zhou3434 |
| **分支** | main |
| **最新提交** | 8a8689e |
| **提交信息** | 修复 PDF 生成问题 |

## 💻 本地克隆命令

```bash
# 克隆整个仓库
git clone https://github.com/hongyu-zhou3434/openclaw_config_code.git

# 进入 code-analyzer 目录
cd openclaw_config_code/skills/code-analyzer
```

## 📝 使用说明

### 本地使用
```bash
# 分析本地项目
node /root/.openclaw/workspace/skills/code-analyzer/analyze-local.js <目录路径>

# 生成 PDF
node /root/.openclaw/workspace/skills/code-analyzer/pdf-generator.js report.md report.pdf
```

### 从 GitHub 使用
```bash
# 克隆后使用
git clone https://github.com/hongyu-zhou3434/openclaw_config_code.git
cd openclaw_config_code/skills/code-analyzer
node analyze-local.js /path/to/project
```

---

*报告生成时间：2026-03-24*
