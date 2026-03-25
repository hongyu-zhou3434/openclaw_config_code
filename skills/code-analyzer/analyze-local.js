#!/usr/bin/env node
/**
 * 本地代码分析工具
 * 使用 CodeBuddy 分析本地代码目录
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// 配置
const CONFIG = {
  reportDir: '/root/.openclaw/workspace/skills/code-analyzer/reports'
};

// 确保目录存在
function ensureDir(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

// 分析目录结构
function analyzeStructure(dir) {
  console.log('🔍 分析目录结构...');
  
  const structure = {
    totalFiles: 0,
    totalDirs: 0,
    languages: {},
    keyFiles: [],
    fileTypes: {}
  };
  
  function scan(currentDir, depth = 0) {
    if (depth > 4) return;
    
    try {
      const items = fs.readdirSync(currentDir);
      
      for (const item of items) {
        if (item.startsWith('.') || item === 'node_modules' || item === 'dist' || item === 'build') continue;
        
        const fullPath = path.join(currentDir, item);
        const stat = fs.statSync(fullPath);
        
        if (stat.isDirectory()) {
          structure.totalDirs++;
          scan(fullPath, depth + 1);
        } else {
          structure.totalFiles++;
          const ext = path.extname(item).toLowerCase();
          structure.languages[ext] = (structure.languages[ext] || 0) + 1;
          
          // 文件类型分类
          if (['.js', '.ts', '.jsx', '.tsx'].includes(ext)) {
            structure.fileTypes['JavaScript/TypeScript'] = (structure.fileTypes['JavaScript/TypeScript'] || 0) + 1;
          } else if (['.py'].includes(ext)) {
            structure.fileTypes['Python'] = (structure.fileTypes['Python'] || 0) + 1;
          } else if (['.md'].includes(ext)) {
            structure.fileTypes['Markdown'] = (structure.fileTypes['Markdown'] || 0) + 1;
          } else if (['.json'].includes(ext)) {
            structure.fileTypes['JSON'] = (structure.fileTypes['JSON'] || 0) + 1;
          } else {
            structure.fileTypes['Other'] = (structure.fileTypes['Other'] || 0) + 1;
          }
          
          // 识别关键文件
          if (['package.json', 'requirements.txt', 'Cargo.toml', 'pom.xml', 'Dockerfile', 'README.md', 'SKILL.md', 'index.js', 'main.py', 'app.py'].includes(item)) {
            structure.keyFiles.push(path.relative(dir, fullPath));
          }
        }
      }
    } catch (e) {}
  }
  
  scan(dir);
  return structure;
}

// 读取关键文件内容
function readKeyFiles(dir, keyFiles) {
  const contents = {};
  
  for (const file of keyFiles.slice(0, 5)) {
    try {
      const fullPath = path.join(dir, file);
      if (fs.existsSync(fullPath)) {
        const content = fs.readFileSync(fullPath, 'utf8');
        contents[file] = content.slice(0, 1000); // 限制长度
      }
    } catch (e) {}
  }
  
  return contents;
}

// 使用 CodeBuddy 分析
function analyzeWithCodeBuddy(dir, structure, keyFileContents) {
  console.log('🤖 使用 CodeBuddy 分析代码架构...');
  
  // 构建分析提示
  let prompt = `请分析以下代码项目的架构和技术特点：\n\n`;
  prompt += `项目路径: ${dir}\n`;
  prompt += `文件统计: ${structure.totalFiles} 个文件, ${structure.totalDirs} 个目录\n\n`;
  
  prompt += `文件类型分布:\n`;
  for (const [type, count] of Object.entries(structure.fileTypes)) {
    prompt += `- ${type}: ${count}\n`;
  }
  
  prompt += `\n关键文件:\n`;
  for (const file of structure.keyFiles.slice(0, 10)) {
    prompt += `- ${file}\n`;
  }
  
  // 添加关键文件内容
  for (const [file, content] of Object.entries(keyFileContents)) {
    prompt += `\n--- ${file} ---\n${content.slice(0, 500)}\n`;
  }
  
  prompt += `\n\n请提供以下分析:\n`;
  prompt += `1. 项目类型和用途\n`;
  prompt += `2. 技术栈分析\n`;
  prompt += `3. 架构特点\n`;
  prompt += `4. 关键组件识别\n`;
  prompt += `5. 代码质量建议\n`;
  
  // 调用 CodeBuddy
  try {
    const result = execSync(`echo "${prompt.replace(/"/g, '\\"')}" | codebuddy -`, {
      encoding: 'utf8',
      timeout: 60000
    });
    return result;
  } catch (e) {
    return 'CodeBuddy 分析需要交互式环境，已跳过详细分析。';
  }
}

// 生成报告
function generateReport(targetDir, structure, keyFileContents, codebuddyAnalysis) {
  console.log('📝 生成技术分析报告...');
  
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const dirName = path.basename(targetDir);
  const reportFile = path.join(CONFIG.reportDir, `${dirName}-analysis-${timestamp}.md`);
  const pdfFile = path.join(CONFIG.reportDir, `${dirName}-analysis-${timestamp}.pdf`);
  
  ensureDir(CONFIG.reportDir);
  
  const report = `# 开源大模型代码技术分析报告（极简专业版・仅核心技术）

**适用**: LLaMA、Qwen、GLM、Mistral、DeepSeek 等开源大模型

---

## 1. 模型整体概述

| 项目 | 内容 |
|------|------|
| **模型名称** | ${dirName} |
| **模型规模** | 待分析 |
| **架构类型** | Dense / MOE / DiT |
| **基座类型** | Decoder-only / Encoder-Decoder |
| **发布来源** | GitHub: ${targetDir} |
| **核心特性** | 待分析 |

---

## 2. 模型架构分析

### 2.1 整体架构范式
- **架构类型判定**:
  - [ ] Dense: 标准稠密 Transformer
  - [ ] MOE: 混合专家架构
  - [ ] DiT: 基于 DiT 的序列建模架构

### 2.2 网络宏观结构
- **层数**: 待分析
- **注意力层 + FFN 层布局**: 待分析
- **归一化位置**: Pre-LN / Post-LN / RMSNorm
- **激活函数**: SwiGLU / ReGLU / GELU

### 2.3 与标准 Transformer 差异点
- 待分析

---

## 3. 模型关键技术分析

### 3.1 注意力机制
- [ ] MLA (Multi-Head Latent Attention)
- [ ] GQA (Grouped Query Attention)
- [ ] MQA (Multi-Query Attention)
- [ ] Full Attention
- [ ] Linear Attention / FlashAttention

### 3.2 位置编码
- [ ] RoPE (Rotary Position Embedding)
- [ ] ALiBi (Attention with Linear Biases)
- [ ] Absolute Position Embedding
- [ ] NoPE (No Position Embedding)

### 3.3 前馈网络
- [ ] SwiGLU
- [ ] ReGLU
- [ ] GELU

### 3.4 其他核心技术
- [ ] MTP (Multi-Token Prediction)
- [ ] 共享权重
- [ ] 动态路由 (MOE)
- [ ] 序列并行

### 3.5 关键技术作用总结
- 待分析

---

## 4. 模型参数量分析

### 4.1 基础参数量
| 项目 | 数值 |
|------|------|
| **总参数量** | 待分析 |
| **注意力层参数量** | 待分析 |
| **FFN / MOE 层参数量** | 待分析 |
| **词嵌入 / 输出层参数量** | 待分析 |

### 4.2 MOE 模型参数（如适用）
| 项目 | 数值 |
|------|------|
| **总专家数** | 待分析 |
| **激活参数量** | 待分析 |
| **路由模块参数量** | 待分析 |

### 4.3 参数量分布特点
- 待分析

### 4.4 内存占用预估
- 待分析

---

## 5. 模型关键算法分析

### 5.1 核心算法
- **注意力计算算法**: 待分析
- **前向传播算法**: 待分析
- **MOE 路由算法**: 待分析 (如使用)
- **长文本支持算法**: 待分析
- **梯度 / 训练相关算法**: 待分析
- **推理优化算法**: 待分析

---

## 6. 模型调用流程分析

### 6.1 整体流程
\`\`\`
输入 → 嵌入 → 层堆叠 → 归一化 → 语言建模输出
\`\`\`

### 6.2 详细流程
1. **输入处理**: 待分析
2. **模型初始化**: 待分析
3. **前向推理流程**: 待分析
4. **输出映射**: 待分析
5. **生成式解码流程**: 待分析

---

## 7. 模型关键算子分析

### 7.1 核心计算算子
| 算子类型 | 具体实现 |
|----------|----------|
| **矩阵乘** | GEMM |
| **注意力算子** | FlashAttention / AttentionWithBias |
| **归一化算子** | RMSNorm / LayerNorm |
| **激活算子** | SiLU / GELU |
| **路由算子 (MOE)** | TopK Gating |

### 7.2 算子性能瓶颈
- 待分析

### 7.3 算子硬件适配性
- 待分析

---

## 8. 模型原生支持的切分与调度测试分析

### 8.1 原生支持并行策略
- [ ] TP (Tensor Parallelism) 张量并行
- [ ] PP (Pipeline Parallelism) 流水线并行
- [ ] DP (Data Parallelism) 数据并行
- [ ] EP (Expert Parallelism) MOE专家并行

### 8.2 模型切分方式
- 待分析

### 8.3 多卡调度逻辑
- 待分析

### 8.4 分布式推理支持
- 待分析

### 8.5 实测稳定性 / 性能结论
- 待分析

---

## 9. 代码统计分析

### 9.1 项目规模
- **总文件数**: ${structure.totalFiles}
- **总目录数**: ${structure.totalDirs}

### 9.2 文件类型分布

| 类型 | 数量 |
|------|------|
${Object.entries(structure.fileTypes)
  .sort((a, b) => b[1] - a[1])
  .map(([type, count]) => `| ${type} | ${count} |`)
  .join('\n')}

### 9.3 关键文件

${structure.keyFiles.map(f => `- ${f}`).join('\n')}

---

## 10. 关键代码预览

${Object.entries(keyFileContents).map(([file, content]) => `
### ${file}

\`\`\`
${content.slice(0, 300)}...
\`\`\`
`).join('\n')}

---

## 11. AI 深度分析

${codebuddyAnalysis}

---

## 12. 总结与建议

### 12.1 核心发现
- 待分析

### 12.2 技术优势
- 待分析

### 12.3 优化建议
1. 完善技术文档
2. 增加代码注释
3. 优化模型结构
4. 提升推理效率

---

*报告由 CodeBuddy AI 自动生成*
*分析时间: ${new Date().toLocaleString('zh-CN')}*
*分析工具: CodeBuddy + OpenClaw Code Analyzer*
*模板版本: 极简专业版 v3.0.0*
`;

  fs.writeFileSync(reportFile, report);
  console.log(`✅ Markdown 报告已生成: ${reportFile}`);
  
  // 生成 PDF 报告（使用 wps-skill）
  console.log('📄 正在使用 wps-skill 生成 PDF 报告...');
  try {
    const { execSync } = require('child_process');
    execSync(`node "${path.join(__dirname, 'convert-to-pdf.js')}" "${reportFile}" "${pdfFile}"`, {
      timeout: 120000,
      stdio: 'inherit'
    });
    console.log(`✅ PDF 报告已生成: ${pdfFile}`);
    console.log('💡 使用 wps-skill 生成，符合系统策略配置');
  } catch (e) {
    console.log('⚠️  PDF 生成失败，仅保留 Markdown 报告');
    console.log('💡 请检查 wps-skill 是否已正确安装');
  }
  
  return { markdown: reportFile, pdf: pdfFile };
}

// 主函数
async function main() {
  const args = process.argv.slice(2);
  
  if (args.length < 1) {
    console.log('用法: node analyze-local.js <目录路径>');
    console.log('示例: node analyze-local.js /path/to/project');
    process.exit(1);
  }
  
  const targetDir = path.resolve(args[0]);
  
  if (!fs.existsSync(targetDir)) {
    console.error(`❌ 目录不存在: ${targetDir}`);
    process.exit(1);
  }
  
  console.log('🔍 本地代码分析工具启动');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`目标目录: ${targetDir}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  
  try {
    // 1. 分析结构
    const structure = analyzeStructure(targetDir);
    
    // 2. 读取关键文件
    const keyFileContents = readKeyFiles(targetDir, structure.keyFiles);
    
    // 3. CodeBuddy 分析
    const codebuddyAnalysis = analyzeWithCodeBuddy(targetDir, structure, keyFileContents);
    
    // 4. 生成报告
    const reportFile = generateReport(targetDir, structure, keyFileContents, codebuddyAnalysis);
    
    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('✅ 分析完成！');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`\n📄 报告位置: ${reportFile}`);
    
    // 显示报告内容
    console.log('\n📋 报告预览:\n');
    console.log(fs.readFileSync(reportFile, 'utf8').slice(0, 2000));
    console.log('\n... (完整报告请查看文件)');
    
  } catch (error) {
    console.error('❌ 分析失败:', error.message);
    process.exit(1);
  }
}

main();
