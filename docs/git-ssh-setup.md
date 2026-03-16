# Git SSH 密钥配置指南

## 概述

本指南帮助你在 OpenClaw 环境中配置 Git SSH 密钥，以便通过 SSH 方式访问 GitHub 私有仓库。

---

## 1. 检查现有密钥

```bash
# 查看现有 SSH 密钥
ls -la ~/.ssh/

# 查找 id_ed25519 或 id_rsa 文件
```

如果存在 `id_ed25519` 或 `id_rsa` 文件，可以跳过生成步骤，直接使用现有密钥。

---

## 2. 生成新的 SSH 密钥

### 方式一：使用 Ed25519 算法（推荐）

```bash
# 生成 Ed25519 密钥对
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_ed25519

# 参数说明：
# -t ed25519    : 使用 Ed25519 算法（更安全、密钥更短）
# -C            : 注释，通常使用邮箱
# -f            : 指定密钥文件路径
```

### 方式二：使用 RSA 算法（兼容性更好）

```bash
# 生成 RSA 密钥对（4096位）
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/id_rsa
```

### 生成过程中的提示

```
Generating public/private ed25519 key pair.
Enter passphrase (empty for no passphrase): [直接回车，不设置密码]
Enter same passphrase again: [再次回车]
```

> **提示**：OpenClaw 自动化环境建议不设置密码（passphrase），避免每次使用都需要输入。

---

## 3. 配置 SSH 密钥权限

```bash
# 设置正确的文件权限
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 644 ~/.ssh/known_hosts
```

---

## 4. 添加 SSH 配置

创建或编辑 SSH 配置文件：

```bash
# 编辑 SSH 配置
cat > ~/.ssh/config << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    StrictHostKeyChecking no
EOF

# 设置权限
chmod 600 ~/.ssh/config
```

### 配置说明

| 配置项 | 说明 |
|--------|------|
| `Host` | 别名，用于匹配主机 |
| `HostName` | 实际主机地址 |
| `User` | Git 默认用户 |
| `IdentityFile` | 私钥文件路径 |
| `IdentitiesOnly` | 只使用指定的密钥 |
| `StrictHostKeyChecking no` | 自动接受主机密钥（自动化环境使用） |

---

## 5. 添加公钥到 GitHub

### 5.1 复制公钥内容

```bash
# 显示公钥内容
cat ~/.ssh/id_ed25519.pub
```

输出示例：
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDIhz2GK/XCUj4i6Q5yQJNL1MXMY0RxzPV2QrBqfHrDq your_email@example.com
```

### 5.2 在 GitHub 上添加公钥

1. 登录 GitHub 账号
2. 点击右上角头像 → **Settings**
3. 左侧菜单 → **SSH and GPG keys**
4. 点击 **New SSH key** 按钮
5. 填写信息：
   - **Title**: OpenClaw Server（或其他描述性名称）
   - **Key type**: Authentication Key
   - **Key**: 粘贴刚才复制的公钥内容
6. 点击 **Add SSH key**

### 5.3 验证添加成功

```bash
# 测试 SSH 连接
ssh -T git@github.com
```

成功提示：
```
Hi hongyu-zhou3434! You've successfully authenticated, but GitHub does not provide shell access.
```

---

## 6. 测试 Git 访问

```bash
# 测试访问仓库
git ls-remote git@github.com:hongyu-zhou3434/openclaw_config_code.git

# 克隆仓库测试
git clone git@github.com:hongyu-zhou3434/openclaw_config_code.git test-clone --depth 1
```

---

## 7. 故障排除

### 问题 1：Permission denied (publickey)

**原因**：GitHub 上没有对应的公钥，或 SSH 配置错误

**解决**：
```bash
# 检查 SSH 代理
ssh-add -l

# 如果密钥未加载，手动添加
ssh-add ~/.ssh/id_ed25519

# 验证 SSH 连接
ssh -vT git@github.com
```

### 问题 2：Host key verification failed

**原因**：GitHub 的主机密钥未添加到 known_hosts

**解决**：
```bash
# 手动添加 GitHub 主机密钥
ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
```

### 问题 3：Could not resolve hostname

**原因**：网络或 DNS 问题

**解决**：
```bash
# 检查网络连接
ping github.com

# 检查 DNS 解析
nslookup github.com
```

---

## 8. 自动化脚本

一键配置脚本（适用于 OpenClaw 环境）：

```bash
#!/bin/bash
# setup-git-ssh.sh - Git SSH 一键配置

set -e

EMAIL="${1:-openclaw@local}"
KEY_FILE="$HOME/.ssh/id_ed25519"

echo "=== Git SSH 配置脚本 ==="

# 1. 创建 .ssh 目录
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 2. 生成密钥（如果不存在）
if [ ! -f "$KEY_FILE" ]; then
    echo "生成 SSH 密钥..."
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_FILE" -N ""
else
    echo "SSH 密钥已存在: $KEY_FILE"
fi

# 3. 设置权限
chmod 600 "$KEY_FILE"
chmod 644 "$KEY_FILE.pub"

# 4. 添加 GitHub 主机密钥
if ! grep -q "github.com" ~/.ssh/known_hosts 2>/dev/null; then
    echo "添加 GitHub 主机密钥..."
    ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts 2>/dev/null
fi
chmod 644 ~/.ssh/known_hosts

# 5. 创建 SSH 配置
cat > ~/.ssh/config << EOF
Host github.com
    HostName github.com
    User git
    IdentityFile $KEY_FILE
    IdentitiesOnly yes
    StrictHostKeyChecking no
EOF
chmod 600 ~/.ssh/config

# 6. 显示公钥
echo ""
echo "=== 配置完成 ==="
echo "请将以下公钥添加到 GitHub:"
echo ""
cat "$KEY_FILE.pub"
echo ""
echo "添加地址: https://github.com/settings/keys"
```

使用方法：
```bash
# 下载并执行脚本
chmod +x setup-git-ssh.sh
./setup-git-ssh.sh your_email@example.com
```

---

## 9. 安全注意事项

1. **私钥保护**：`id_ed25519` 是私钥，**绝对不要**分享给他人或上传到公开仓库
2. **权限设置**：确保私钥文件权限为 `600`（只有所有者可读写）
3. **定期轮换**：建议定期（如每年）更换 SSH 密钥
4. **多设备管理**：每个设备使用独立的 SSH 密钥，便于单独撤销

---

## 10. 参考链接

- [GitHub SSH 文档](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [OpenSSH 手册](https://www.openssh.com/manual.html)
- [OpenClaw 系统配置](../system_config.md)

---

*文档版本: 1.0*
*最后更新: 2026-03-15*
