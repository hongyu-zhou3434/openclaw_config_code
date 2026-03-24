---
name: context-manager
description: 上下文管理器。自动检查推理上下文长度，超过50K时自动启动压缩、总结等手段，降低单次推理的上下文长度。
metadata:
  {
    "openclaw":
      {
        "emoji": "🧠",
        "always": true,
      },
  }
---

# 上下文管理器 (Context Manager)

自动监控和管理推理上下文长度，超过阈值时自动启动压缩和总结机制。

## 功能

- **自动监控**: 实时检查上下文长度
- **智能压缩**: 多级压缩策略
- **自动总结**: 生成历史对话摘要
- **阈值告警**: 多级阈值管理

## 阈值设置

| 级别 | 阈值 | 动作 |
|------|------|------|
| **警告** | 40K tokens (31%) | 记录日志提醒 |
| **压缩** | 50K tokens (39%) | 启动标准压缩 |
| **总结** | 60K tokens (47%) | 强制总结历史 |
| **紧急** | 80K tokens (63%) | 紧急清理 |
| **最大** | 120K tokens (94%) | 拒绝新请求 |

## 压缩策略

### Level 1: 轻量压缩 (40K)
- 移除过时的系统消息
- 压缩重复的工具输出
- 简化文件内容引用
- **目标减少**: 10%

### Level 2: 标准压缩 (50K)
- 总结早期对话历史
- 合并相似的文件读取
- 压缩冗长的工具输出
- 移除已完成的任务详情
- **目标减少**: 25%

### Level 3: 深度压缩 (60K)
- 总结所有历史对话
- 仅保留关键文件引用
- 压缩所有工具输出为摘要
- 移除中间推理过程
- **目标减少**: 40%

### Level 4: 紧急清理 (80K)
- 仅保留最近10轮对话
- 删除所有文件内容缓存
- 仅保留关键配置信息
- 重置工具调用历史
- **目标减少**: 60%

## 使用方法

### 检查上下文状态

```bash
node /root/.openclaw/workspace/skills/context-manager/context-manager.js --status
```

### 执行压缩检查

```bash
node /root/.openclaw/workspace/skills/context-manager/context-manager.js --check
```

### 自动监控

系统会自动在以下时机检查：
- 每次调用前
- 每次调用后
- 每5分钟（后台检查）

## 配置

配置文件: `config/context-management-policy.json`

```json
{
  "thresholds": {
    "warning": 40000,
    "compression": 50000,
    "summarization": 60000,
    "critical": 80000,
    "maximum": 120000
  }
}
```

## 日志

日志位置: `logs/context-manager.log`

## 示例场景

### 场景1: 上下文达到 52K
- **动作**: 启动 Level 2 标准压缩
- **预期减少**: 13K tokens (25%)
- **结果**: 降至 39K tokens

### 场景2: 上下文达到 65K
- **动作**: 启动 Level 3 深度压缩 + 自动总结
- **预期减少**: 26K tokens (40%)
- **结果**: 降至 39K tokens

### 场景3: 上下文达到 85K
- **动作**: 启动 Level 4 紧急清理
- **预期减少**: 51K tokens (60%)
- **结果**: 降至 34K tokens

## 注意事项

- 压缩过程不可逆，请确保重要信息已保存
- 自动总结会保留关键决策点和当前状态
- 紧急清理会删除大部分历史信息，谨慎使用
