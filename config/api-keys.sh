#!/bin/bash
# OpenClaw API密钥配置文件
# 此文件包含所有API密钥和敏感配置
# 使用方法: source /root/.openclaw/workspace/config/api-keys.sh

# Tavily Search API Key
# 用于AI搜索和资讯检索
export TAVILY_API_KEY="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"

# OpenAI/DashScope API Key
# 用于AI模型调用
export OPENAI_API_KEY="sk-sp-1dfcd6127bfc4033b85aa78f2ed6a995"
export OPENAI_BASE_URL="https://coding.dashscope.aliyuncs.com/v1"

# SMTP配置（可选，用于邮件发送）
# export SMTP_PASSWORD="your-smtp-password"

# 其他API密钥（按需添加）
# export GITHUB_TOKEN="your-github-token"
# export TENCENT_CLOUD_SECRET_ID="your-secret-id"
# export TENCENT_CLOUD_SECRET_KEY="your-secret-key"

echo "API密钥已加载"
