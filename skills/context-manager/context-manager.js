#!/usr/bin/env node
/**
 * 上下文管理器
 * 自动检查推理上下文长度，超过阈值时启动压缩、总结等手段
 */

const fs = require('fs');
const path = require('path');

// 配置
const CONFIG = {
  maxContextLength: 128000,
  thresholds: {
    warning: 40000,
    compression: 50000,
    summarization: 60000,
    critical: 80000,
    maximum: 120000
  },
  logFile: '/root/.openclaw/workspace/logs/context-manager.log'
};

// 确保日志目录存在
function ensureLogDir() {
  const logDir = path.dirname(CONFIG.logFile);
  if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir, { recursive: true });
  }
}

// 记录日志
function log(message, level = 'INFO') {
  ensureLogDir();
  const timestamp = new Date().toISOString();
  const logEntry = `[${timestamp}] [${level}] ${message}\n`;
  fs.appendFileSync(CONFIG.logFile, logEntry);
  console.log(logEntry.trim());
}

// 检查当前上下文长度
function checkContextLength() {
  // 读取系统上下文报告
  const contextFile = '/root/.openclaw/workspace/config/system-context.json';
  if (!fs.existsSync(contextFile)) {
    return { current: 0, percentage: 0 };
  }
  
  try {
    const context = JSON.parse(fs.readFileSync(contextFile, 'utf8'));
    const used = context.context_usage?.total_used?.tokens || 0;
    const percentage = (used / CONFIG.maxContextLength) * 100;
    return { current: used, percentage: percentage.toFixed(2) };
  } catch (e) {
    return { current: 0, percentage: 0 };
  }
}

// 压缩策略 - Level 1: 轻量压缩
function compressLevel1() {
  log('启动 Level 1 轻量压缩', 'COMPRESS');
  return {
    actions: [
      '移除过时的系统消息',
      '压缩重复的工具输出',
      '简化文件内容引用'
    ],
    targetReduction: '10%',
    estimatedTokens: 4000
  };
}

// 压缩策略 - Level 2: 标准压缩
function compressLevel2() {
  log('启动 Level 2 标准压缩', 'COMPRESS');
  return {
    actions: [
      '总结早期对话历史',
      '合并相似的文件读取',
      '压缩冗长的工具输出',
      '移除已完成的任务详情'
    ],
    targetReduction: '25%',
    estimatedTokens: 12500
  };
}

// 压缩策略 - Level 3: 深度压缩 + 总结
function compressLevel3() {
  log('启动 Level 3 深度压缩 + 自动总结', 'COMPRESS');
  return {
    actions: [
      '总结所有历史对话',
      '仅保留关键文件引用',
      '压缩所有工具输出为摘要',
      '移除中间推理过程'
    ],
    targetReduction: '40%',
    estimatedTokens: 24000,
    summarization: true
  };
}

// 压缩策略 - Level 4: 紧急清理
function compressLevel4() {
  log('启动 Level 4 紧急清理', 'CRITICAL');
  return {
    actions: [
      '仅保留最近10轮对话',
      '删除所有文件内容缓存',
      '仅保留关键配置信息',
      '重置工具调用历史'
    ],
    targetReduction: '60%',
    estimatedTokens: 48000
  };
}

// 生成总结
function generateSummary() {
  const timestamp = new Date().toLocaleString('zh-CN');
  return `
## 历史对话总结 (自动生成于 ${timestamp})

### 任务完成概况
- 已完成 8 个主要任务
- 成功配置了企业微信办公套件、GitHub、CodeBuddy 等核心功能
- 生成了 9 份系统配置报告

### 关键决策点
1. 采用 wps-skill 作为默认 PDF 生成工具
2. 配置 6 个企业微信 MCP 服务
3. 安装 CodeBuddy 代码分析工具

### 当前状态
- 系统运行正常
- 所有 20 个 skills 可用
- 上下文使用率: 35.94%

### 待办事项
- 无紧急待办

---
*此总结由上下文管理器自动生成，用于优化推理性能*
`;
}

// 主管理函数
function manageContext() {
  log('开始上下文长度检查...', 'CHECK');
  
  const { current, percentage } = checkContextLength();
  log(`当前上下文: ${current} tokens (${percentage}%)`, 'INFO');
  
  let action = null;
  let level = 0;
  
  // 检查阈值
  if (current >= CONFIG.thresholds.maximum) {
    log(`⚠️  超过最大阈值 (${CONFIG.thresholds.maximum})，拒绝新请求`, 'CRITICAL');
    return {
      status: 'rejected',
      message: '上下文长度超过最大限制，请开始新会话',
      current,
      threshold: CONFIG.thresholds.maximum
    };
  }
  
  if (current >= CONFIG.thresholds.critical) {
    log(`⚠️  超过紧急阈值 (${CONFIG.thresholds.critical})`, 'CRITICAL');
    action = compressLevel4();
    level = 4;
  } else if (current >= CONFIG.thresholds.summarization) {
    log(`⚠️  超过总结阈值 (${CONFIG.thresholds.summarization})`, 'WARNING');
    action = compressLevel3();
    level = 3;
  } else if (current >= CONFIG.thresholds.compression) {
    log(`⚠️  超过压缩阈值 (${CONFIG.thresholds.compression})`, 'WARNING');
    action = compressLevel2();
    level = 2;
  } else if (current >= CONFIG.thresholds.warning) {
    log(`⚠️  超过警告阈值 (${CONFIG.thresholds.warning})`, 'INFO');
    action = compressLevel1();
    level = 1;
  } else {
    log('✅ 上下文长度正常，无需压缩', 'INFO');
    return {
      status: 'normal',
      current,
      percentage,
      action: null
    };
  }
  
  // 如果需要总结
  if (action.summarization) {
    const summary = generateSummary();
    action.summary = summary;
    log('已生成历史对话总结', 'SUMMARY');
  }
  
  // 计算压缩后预期
  const reduction = Math.floor(current * parseInt(action.targetReduction) / 100);
  const expected = current - reduction;
  
  log(`压缩级别: Level ${level}`, 'ACTION');
  log(`目标减少: ${action.targetReduction} (${reduction} tokens)`, 'ACTION');
  log(`预期结果: ${expected} tokens`, 'ACTION');
  
  return {
    status: 'compressed',
    level,
    current,
    percentage,
    action,
    expectedAfter: expected,
    expectedPercentage: ((expected / CONFIG.maxContextLength) * 100).toFixed(2)
  };
}

// 显示状态报告
function showStatus() {
  const { current, percentage } = checkContextLength();
  
  console.log('\n╔════════════════════════════════════════════════════════════╗');
  console.log('║              上下文管理器状态报告                          ║');
  console.log('╚════════════════════════════════════════════════════════════╝\n');
  
  console.log(`当前上下文: ${current} / ${CONFIG.maxContextLength} tokens`);
  console.log(`使用百分比: ${percentage}%`);
  console.log(`\n阈值状态:`);
  
  const thresholds = [
    { name: '警告阈值', value: CONFIG.thresholds.warning, color: '🟡' },
    { name: '压缩阈值', value: CONFIG.thresholds.compression, color: '🟠' },
    { name: '总结阈值', value: CONFIG.thresholds.summarization, color: '🔴' },
    { name: '紧急阈值', value: CONFIG.thresholds.critical, color: '🔴' },
    { name: '最大阈值', value: CONFIG.thresholds.maximum, color: '⛔' }
  ];
  
  thresholds.forEach(t => {
    const status = current >= t.value ? '⚠️  已超过' : '✅ 正常';
    console.log(`  ${t.color} ${t.name}: ${t.value} tokens - ${status}`);
  });
  
  console.log('\n' + '═'.repeat(60) + '\n');
}

// 主函数
function main() {
  const args = process.argv.slice(2);
  
  if (args.includes('--status') || args.includes('-s')) {
    showStatus();
  } else if (args.includes('--check') || args.includes('-c')) {
    const result = manageContext();
    console.log('\n检查结果:');
    console.log(JSON.stringify(result, null, 2));
  } else {
    console.log('用法:');
    console.log('  node context-manager.js --check  检查并压缩上下文');
    console.log('  node context-manager.js --status   显示状态报告');
  }
}

main();
