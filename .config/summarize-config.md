# Summarize API 配置

## 当前配置

| 配置项 | 值 | 状态 |
|--------|-----|------|
| OPENAI_API_KEY | sk-sp-1dfcd6127bfc4033b85aa78f2ed6a995 | ✅ 有效 |
| OPENAI_BASE_URL | https://coding.dashscope.aliyuncs.com/v1 | ✅ |
| SUMMARIZE_MODEL | kimi-k2.5 | ✅ 支持 |

## 测试状态

✅ **功能正常** - 已成功总结文本

## 使用示例

```bash
# 配置环境变量
export OPENAI_API_KEY="sk-sp-1dfcd6127bfc4033b85aa78f2ed6a995"
export OPENAI_BASE_URL="https://coding.dashscope.aliyuncs.com/v1"
export SUMMARIZE_MODEL="kimi-k2.5"

# 总结文本
echo "要总结的文本" | summarize -

# 总结文件
summarize /path/to/file.txt

# JSON 输出
summarize file.txt --json
```

## 支持的模型

| 模型 | 说明 |
|------|------|
| kimi-k2.5 | ✅ 已测试可用 |
| qwen-* | ❌ 不支持 |

## 配置时间

2026-03-16 00:00:00 +08:00
