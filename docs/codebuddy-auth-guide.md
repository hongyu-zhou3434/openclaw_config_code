# CodeBuddy 云端 AI 分析功能认证指南

## 认证方式说明

根据测试，CodeBuddy 支持以下认证方式：

### 方式一：交互式登录（推荐）

**适用场景：** 首次使用或个人开发环境

**步骤：**
1. 在终端运行：
   ```bash
   codebuddy /login
   ```
2. 按照提示打开浏览器完成 OAuth 授权
3. 授权成功后即可使用云端 AI 功能

**特点：**
- ✅ 最简单直接
- ✅ 支持完整功能
- ❌ 需要交互式终端
- ❌ 需要浏览器

### 方式二：API Key 认证

**适用场景：** CI/CD 环境或自动化脚本

**配置方法：**

**1. 环境变量方式**
```bash
export CODEBUDDY_API_KEY="your-api-key"
```

**2. 配置文件方式**
创建 `~/.config/codebuddy/config.json`：
```json
{
  "apiKey": "your-api-key",
  "keyName": "your-key-name"
}
```

**特点：**
- ✅ 适合自动化
- ✅ 无需交互
- ❌ 需要有效的 API Key
- ❌ 可能需要预先登录激活

### 方式三：配置文件 + 登录状态

**适用场景：** 已登录过的环境

**配置位置：**
- Linux/macOS: `~/.config/codebuddy/`
- Windows: `%APPDATA%/CodeBuddy/`

**文件：**
- `config.json` - 配置信息
- `auth.json` - 认证令牌（登录后自动生成）

## 当前配置状态

### 已配置信息

**API Key：**
- Key: `ck_fgyf8na6kagw.TFCRm758aCHsuSX8SJv8wFQQ64GcvvK8Gn9bZ5goi7s`
- Name: `openclaw`
- 状态：已配置但认证失败 (401)

**可能原因：**
1. API Key 需要先通过 `/login` 激活
2. API Key 格式不正确
3. API Key 已过期
4. 需要额外的配置步骤

## 推荐的认证流程

### 方案 A：交互式环境（推荐）

```bash
# 1. 启动 CodeBuddy
codebuddy

# 2. 在交互式界面中输入
/login

# 3. 按照提示完成浏览器授权

# 4. 验证登录状态
/whoami
```

### 方案 B：获取正确的 API Key

1. 先通过交互式登录获取访问令牌
2. 在配置目录中找到认证信息
3. 使用获取的令牌进行 API 调用

### 方案 C：使用本地分析功能

如果云端认证困难，可以使用本地代码分析功能：

```bash
# 本地代码分析（无需认证）
node /root/.openclaw/workspace/skills/code-analyzer/analyze-local.js <目录>
```

## 故障排除

### 错误：401 Authentication required

**原因：**
- 未登录或认证信息无效

**解决：**
```bash
# 方法 1：交互式登录
codebuddy /login

# 方法 2：检查 API Key 是否有效
echo $CODEBUDDY_API_KEY

# 方法 3：禁用环境变量，使用 /login
codebuddy /login
```

### 错误：Environment variable CODEBUDDY_API_KEY is set

**原因：**
- 环境变量中的 API Key 无效

**解决：**
```bash
# 方法 1：取消环境变量
unset CODEBUDDY_API_KEY

# 方法 2：禁用环境变量使用
codebuddy /login

# 方法 3：设置禁用标志
export CODEBUDDY_API_KEY_DISABLED=1
codebuddy /login
```

## 联系支持

如果以上方法都无法解决问题：

- 📧 邮箱：codebuddy@tencent.com
- 🔗 文档：https://cnb.cool/codebuddy/codebuddy-code
- 🐛 Issues：https://cnb.cool/codebuddy/codebuddy-code/-/issues

## 替代方案

如果 CodeBuddy 云端认证暂时无法完成，可以使用：

1. **本地代码分析工具**
   ```bash
   node analyze-local.js <目录>
   ```

2. **GitHub Copilot**（如果已配置）

3. **其他 AI 代码分析工具**
   - ChatGPT API
   - Claude API
   - 其他国产 AI 工具

---

**当前状态：** API Key 已配置，但需要完成交互式登录流程才能激活云端 AI 功能。
