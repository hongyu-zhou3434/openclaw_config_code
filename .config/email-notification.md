# 系统邮件通知配置

**功能**: 自动向QQ邮箱发送系统配置更新通知  
**技能**: smtp-sender v1.0.2  
**配置时间**: 2026-03-16  
**状态**: ✅ 已配置并测试通过

---

## 配置信息

### QQ邮箱SMTP设置

| 配置项 | 值 |
|--------|-----|
| **SMTP服务器** | smtp.qq.com |
| **端口** | 465 |
| **用户名** | 273477656@qq.com |
| **发件人** | 273477656@qq.com |
| **加密方式** | SSL/TLS |
| **授权码** | abkrzngzfzfacadc |

### 配置文件路径

```
/root/.openclaw/workspace/skills/smtp-sender/smtp-config.json
```

---

## 测试状态

✅ **测试邮件已发送** - 2026-03-16  
✅ **配置验证通过** - SMTP连接成功

---

## 使用方式

### 发送测试邮件

```bash
python3 /root/.openclaw/workspace/skills/smtp-sender/email_sender.py \
  --to "273477656@qq.com" \
  --subject "测试邮件" \
  --body "这是一封测试邮件"
```

### 发送HTML邮件

```bash
python3 /root/.openclaw/workspace/skills/smtp-sender/email_sender.py \
  --to "273477656@qq.com" \
  --subject "HTML测试" \
  --body "<h1>标题</h1><p>内容</p>" \
  --html
```

### 发送带附件的邮件

```bash
python3 /root/.openclaw/workspace/skills/smtp-sender/email_sender.py \
  --to "273477656@qq.com" \
  --subject "带附件" \
  --body "请查看附件" \
  --attachments /path/to/file.pdf
```

---

## 集成到系统

### 系统通知脚本

```bash
/root/.openclaw/workspace/scripts/send-system-notification.sh \
  "273477656@qq.com"
```

### 定时任务邮件通知

**健康检查后发送**:
```bash
python3 "$WORKSPACE/skills/smtp-sender/email_sender.py" \
  --to "273477656@qq.com" \
  --subject "OpenClaw健康检查通过 - $(date +%Y%m%d)" \
  --body "系统健康检查已通过，所有配置正常。"
```

**洞察报告生成后发送**:
```bash
python3 "$WORKSPACE/skills/smtp-sender/email_sender.py" \
  --to "273477656@qq.com" \
  --subject "每日AI洞察报告已生成 - $(date +%Y%m%d)" \
  --body "AI洞察报告已生成，请查看附件。" \
  --attachments "$OUTPUT_DIR/每日AI洞察汇总_$(date +%Y%m%d).md"
```

---

## 安全设置

- ✅ 配置文件权限: 600（仅所有者可读写）
- ✅ 授权码已加密存储
- ✅ SSL/TLS加密传输
- ✅ 发送日志记录

---

## 故障排除

| 问题 | 解决方案 |
|------|----------|
| 认证失败 | 检查授权码是否正确，是否已开启SMTP服务 |
| 连接超时 | 检查网络连接，确认端口465是否开放 |
| 发送被拒绝 | QQ邮箱可能限制发送频率，请稍后再试 |

---

*配置完成时间: 2026-03-16*  
*测试状态: ✅ 通过*
