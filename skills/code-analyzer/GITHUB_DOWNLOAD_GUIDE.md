# GitHub 代码下载完整指南

## 问题背景

由于网络环境限制，直接从 GitHub 下载代码经常遇到以下问题：
- TLS 连接错误
- 下载超时
- 仅下载 .git 目录
- 连接被重置

## 解决方案汇总

### 方案1: 多代理下载脚本 (推荐)

**文件**: `download-github.sh`

**特点**:
- 自动尝试多个代理/镜像
- 支持 5 种下载策略
- 自动验证完整性

**使用方法**:
```bash
./download-github.sh https://github.com/username/repo.git [分支名]
```

**代理列表**:
1. direct (直接连接)
2. ghproxy.com
3. mirror.ghproxy.com
4. hub.gitmirror.com
5. gh.api.99988866.xyz

### 方案2: 完整分析流程

**文件**: `github-analyze.sh`

**特点**:
- 下载 + 分析 一键完成
- 使用优化后的下载脚本
- 自动调用 analyze-local.js

**使用方法**:
```bash
./github-analyze.sh https://github.com/username/repo.git [分支名]
```

### 方案3: 远程分析模式 (无需下载)

**文件**: `analyze-remote.sh`

**特点**:
- 使用 Tavily 搜索获取信息
- 无需下载代码
- 快速生成初步报告

**使用方法**:
```bash
./analyze-remote.sh https://github.com/username/repo.git
```

### 方案4: Node.js 优化版

**文件**: `analyze-optimized.js`

**特点**:
- 网络连接检查
- 自动重试机制
- ZIP 备用方案

**使用方法**:
```bash
node analyze-optimized.js https://github.com/username/repo.git
```

### 方案5: 手动分步下载

```bash
# 第1步: 配置 Git
git config --global http.postBuffer 524288000
git config --global http.lowSpeedLimit 1000
git config --global http.lowSpeedTime 60

# 第2步: 尝试下载
mkdir -p /tmp/code-analysis
cd /tmp/code-analysis

# 尝试1: 浅克隆
git clone --depth 1 https://github.com/username/repo.git

# 尝试2: 使用代理
git clone --depth 1 https://ghproxy.com/https://github.com/username/repo.git

# 尝试3: 下载 ZIP
wget https://github.com/username/repo/archive/refs/heads/main.zip
unzip main.zip

# 第3步: 分析
cd ~/.openclaw/workspace/skills/code-analyzer
node analyze-local.js /tmp/code-analysis/repo
```

## 使用建议

| 场景 | 推荐方案 | 成功率 |
|------|---------|--------|
| 小型仓库 (<50MB) | github-analyze.sh | 高 |
| 大型仓库 (>100MB) | download-github.sh | 中 |
| 网络极差 | analyze-remote.sh | 高 |
| 需要完整控制 | 手动分步 | 高 |
| 批量下载 | analyze-optimized.js | 中 |

## 文件清单

| 文件 | 功能 | 状态 |
|------|------|------|
| download-github.sh | 多代理下载 | ✅ 推荐 |
| github-analyze.sh | 下载+分析 | ✅ 推荐 |
| analyze-remote.sh | 远程分析 | ✅ 备用 |
| analyze-optimized.js | Node优化版 | ✅ 备用 |
| analyze.js | 原始版本 | ⚠️ 旧版 |
| analyze-local.js | 本地分析 | ✅ 可用 |

## 测试记录

| 仓库 | 大小 | download-github | github-analyze | analyze-remote |
|------|------|-----------------|----------------|----------------|
| Hello-World | 极小 | ✅ 成功 | ✅ 成功 | ✅ 成功 |
| Wan2.2 | 大 | ⏳ 测试中 | ⏳ 测试中 | ✅ 成功 |

## 故障排除

### 问题1: 所有代理都失败
```bash
# 检查网络
ping github.com

# 配置系统代理
export https_proxy=http://your-proxy:port

# 然后重试
./download-github.sh <url>
```

### 问题2: 下载不完整
```bash
# 清理后重试
rm -rf /tmp/code-analysis/<repo>
./download-github.sh <url>
```

### 问题3: 需要身份验证
```bash
# 配置 Git 凭证
git config --global credential.helper cache
```

## 更新日志

### 2026-03-25
- ✅ 创建 download-github.sh (多代理下载)
- ✅ 创建 github-analyze.sh (完整流程)
- ✅ 创建 analyze-remote.sh (远程分析)
- ✅ 创建 analyze-optimized.js (Node优化)
- ✅ 创建本指南文档
- ✅ 测试 Hello-World 成功
- ⏳ Wan2.2 待测试

---
*文档由 OpenClaw AI 自动生成*
