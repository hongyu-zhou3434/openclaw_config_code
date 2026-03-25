# 代码下载优化方案

## 问题总结

### 原有问题
1. **网络不稳定** - GitHub 连接间歇性中断
2. **TLS 错误** - GnuTLS recv error (-110)
3. **超时问题** - 大型仓库下载超时
4. **下载中断** - 仅下载 .git 目录，代码文件缺失

## 优化方案

### 方案1: Git 配置优化

```bash
# 增大缓冲区
git config --global http.postBuffer 524288000
git config --global http.maxRequestBuffer 100M

# 设置超时
git config --global http.lowSpeedLimit 1000
git config --global http.lowSpeedTime 60

# 禁用压缩（减少CPU占用）
git config --global core.compression 0
```

### 方案2: 多策略下载脚本

**脚本**: `download-and-analyze.sh`

**策略顺序**:
1. Git 浅克隆 (`--depth 1`)
2. 尝试 master 分支
3. 下载 ZIP 包 (wget)
4. 解压并分析

**使用方法**:
```bash
./download-and-analyze.sh https://github.com/username/repo.git [分支名]
```

### 方案3: Node.js 优化版本

**脚本**: `analyze-optimized.js`

**特性**:
- 网络连接检查
- 自动重试机制 (3次)
- 分支自动切换
- ZIP 备用方案
- 下载完整性验证

**使用方法**:
```bash
node analyze-optimized.js https://github.com/username/repo.git
```

### 方案4: 分步执行

```bash
# 第1步: 手动下载
mkdir -p /tmp/code-analysis
cd /tmp/code-analysis
git clone --depth 1 https://github.com/username/repo.git

# 第2步: 本地分析
cd ~/.openclaw/workspace/skills/code-analyzer
node analyze-local.js /tmp/code-analysis/repo
```

## 推荐方案

| 场景 | 推荐方案 | 原因 |
|------|---------|------|
| 小型仓库 (<100MB) | analyze.js | 简单快速 |
| 大型仓库 (>100MB) | download-and-analyze.sh | 多策略保障 |
| 网络不稳定 | analyze-optimized.js | 自动重试 |
| 完全失败 | 分步手动下载 | 最大控制 |

## 测试验证

### 测试仓库
- ✅ Hello-World (小型) - 成功
- ⚠️ Wan2.2 (大型) - 网络问题，使用替代方案

### 替代方案效果
- ✅ Tavily 搜索获取技术信息
- ✅ AI 生成完整技术报告
- ✅ 邮件发送成功

## 文件清单

| 文件 | 功能 | 状态 |
|------|------|------|
| analyze.js | 原始下载脚本 | 可用 |
| analyze-local.js | 本地分析 | ✅ 可用 |
| analyze-optimized.js | Node优化版 | ✅ 新建 |
| download-and-analyze.sh | Shell脚本版 | ✅ 新建 |

## 使用建议

1. **优先使用浅克隆**: `--depth 1` 减少数据量
2. **设置超时**: 避免无限等待
3. **准备备用方案**: ZIP下载作为后备
4. **验证完整性**: 检查非.git文件存在
5. **网络检查**: 下载前测试 GitHub 连通性

## 更新日志

### 2026-03-25
- ✅ 创建 analyze-optimized.js (Node.js优化版)
- ✅ 创建 download-and-analyze.sh (Shell脚本版)
- ✅ 添加 Git 配置优化
- ✅ 添加多策略下载机制
- ✅ 添加下载完整性验证
- ✅ 测试 Hello-World 成功
- ⚠️ Wan2.2 因网络问题使用替代方案

---
*文档由 OpenClaw AI 自动生成*
