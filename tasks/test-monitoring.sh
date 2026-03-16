#!/bin/bash
# 任务监控测试脚本

set -e

echo "=== 任务监控测试开始 ==="
echo "时间: $(date)"
echo "PID: $$"
echo ""

# 测试 1: 正常执行
echo "[TEST 1] 正常执行测试..."
sleep 2
echo "✓ 正常执行完成"
echo ""

# 测试 2: 模拟进度输出
echo "[TEST 2] 进度输出测试..."
for i in {1..5}; do
    echo "  进度: $i/5"
    sleep 1
done
echo "✓ 进度输出完成"
echo ""

# 测试 3: 资源使用报告
echo "[TEST 3] 资源使用报告..."
echo "  CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
echo "  内存: $(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2}')"
echo "  磁盘: $(df -h / | awk 'NR==2{print $5}')"
echo "✓ 资源报告完成"
echo ""

# 测试 4: 输出文件创建
echo "[TEST 4] 输出文件创建..."
echo "测试结果: $(date)" > /root/.openclaw/workspace/output/test-result.txt
echo "✓ 输出文件创建完成: output/test-result.txt"
echo ""

echo "=== 任务监控测试完成 ==="
echo "退出码: 0"
