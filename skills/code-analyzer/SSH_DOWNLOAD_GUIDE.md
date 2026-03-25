# SSH 方式下载 GitHub 代码指南

## SSH 配置完成 ✅

### 生成的 SSH 密钥

**公钥**:
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHf3aTM/KwMHOTDbF5ykw7MOsq83/d4lI/DDCnRm3ge 273477656@qq.com
```

**状态**: ✅ 已添加到 GitHub (用户: hongyu-zhou3434)

### SSH 连接测试

```bash
$ ssh -T git@github.com
Hi hongyu-zhou3434! You've successfully authenticated...
```

✅ **SSH 连接成功！**

## SSH 下载脚本

### 1. 纯下载脚本

**文件**: `download-ssh.sh`

**使用方法**:
```bash
./download-ssh.sh git@github.com:用户名/仓库名.git [分支名]
```

**示例**:
```bash
./download-ssh.sh git@github.com:Wan-Video/Wan2.2.git
./download-ssh.sh git@github.com:Wan-Video/Wan2.2.git main
```

### 2. 下载+分析脚本

**文件**: `github-ssh-analyze.sh`

**使用方法**:
```bash
./github-ssh-analyze.sh git@github.com:用户名/仓库名.git [分支名]
```

**示例**:
```bash
./github-ssh-analyze.sh git@github.com:Wan-Video/Wan2.2.git
```

## SSH vs HTTPS 对比

| 特性 | SSH | HTTPS |
|------|-----|-------|
| **认证方式** | SSH 密钥 | 用户名/密码或 Token |
| **安全性** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **便捷性** | 配置一次，永久使用 | 每次可能需要输入密码 |
| **防火墙** | 使用 22 端口 | 使用 443 端口 |
| **代理支持** | 较差 | 较好 |

## 当前问题

### 问题现象
SSH 下载仍然遇到与 HTTPS 相同的问题：
- 仅下载 .git 目录
- 实际代码文件未下载
- 下载过程被中断

### 可能原因
1. **网络不稳定** - 连接间歇性中断
2. **仓库体积大** - Wan2.2 包含模型文件，体积较大
3. **服务器限制** - GitHub 对单IP连接数限制
4. **防火墙干扰** - 深度包检测导致连接重置

## 解决方案

### 方案1: 使用浅克隆 + 单分支

```bash
# 只下载最新提交，不下载历史
git clone --depth 1 --single-branch git@github.com:Wan-Video/Wan2.2.git

# 或者只下载特定目录（如果支持）
git clone --depth 1 --filter=blob:none git@github.com:Wan-Video/Wan2.2.git
```

### 方案2: 分批下载

```bash
# 第1步: 初始化空仓库
mkdir -p /tmp/Wan2.2
cd /tmp/Wan2.2
git init

# 第2步: 添加远程
git remote add origin git@github.com:Wan-Video/Wan2.2.git

# 第3步: 配置稀疏检出（只下载部分文件）
git config core.sparseCheckout true
echo "*.py" >> .git/info/sparse-checkout
echo "*.md" >> .git/info/sparse-checkout
echo "*.json" >> .git/info/sparse-checkout

# 第4步: 拉取代码
git pull --depth 1 origin main
```

### 方案3: 使用 Git LFS 跳过大文件

```bash
# 跳过 LFS 文件下载
GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 git@github.com:Wan-Video/Wan2.2.git
```

### 方案4: 浏览器下载 + 上传分析

1. 在浏览器中访问 https://github.com/Wan-Video/Wan2.2
2. 点击 "Code" → "Download ZIP"
3. 下载完成后上传到服务器
4. 使用 `analyze-local.js` 分析

## 推荐方案

针对当前网络环境，推荐使用以下方案：

| 优先级 | 方案 | 命令 |
|--------|------|------|
| 1 | 浅克隆 | `git clone --depth 1 git@github.com:...` |
| 2 | 稀疏检出 | 见方案2 |
| 3 | 跳过LFS | `GIT_LFS_SKIP_SMUDGE=1 git clone...` |
| 4 | 浏览器下载 | 手动下载ZIP |
| 5 | 远程分析 | `./analyze-remote.sh` |

## 测试记录

| 仓库 | SSH下载 | 结果 |
|------|---------|------|
| Hello-World | ⏳ 待测试 | - |
| Wan2.2 | ⚠️ 部分成功 | 仅.git目录 |

## 文件清单

| 文件 | 功能 |
|------|------|
| download-ssh.sh | SSH下载脚本 |
| github-ssh-analyze.sh | SSH下载+分析 |
| SSH_DOWNLOAD_GUIDE.md | 本指南 |

## 更新日志

### 2026-03-25
- ✅ 生成 SSH 密钥对 (ed25519)
- ✅ 配置 SSH 连接 GitHub
- ✅ 测试 SSH 连接成功
- ✅ 创建 download-ssh.sh
- ✅ 创建 github-ssh-analyze.sh
- ⚠️ Wan2.2 下载仍受网络影响

---
*文档由 OpenClaw AI 自动生成*
