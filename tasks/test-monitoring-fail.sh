#!/bin/bash
# 任务监控异常测试脚本

echo "=== 异常任务监控测试 ==="
echo "时间: $(date)"
echo "PID: $$"
echo ""

# 模拟命令失败
echo "[TEST] 模拟命令失败..."
ls /nonexistent-directory 2>&1 || echo "✓ 错误已捕获，退出码: $?"
echo ""

# 模拟非零退出
echo "[TEST] 模拟非零退出..."
exit 1
