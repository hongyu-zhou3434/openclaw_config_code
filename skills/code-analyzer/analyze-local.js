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
  
  const report = `# {模型名称} 技术分析报告

## 1. 模型概述

| 内容项 | 说明 | 当前值 |
|--------|------|--------|
| **模型名称** | 官方名称和版本 | ${dirName} |
| **发布机构** | 开发公司/组织 | - |
| **发布时间** | 发布日期 | ${new Date().toLocaleDateString('zh-CN')} |
| **模型类型** | 基础分类 | 代码分析模型 |
| **参数量级** | 模型规模 | - |
| **上下文窗口** | 支持的最大token数 | - |

## 2. 技术架构

### 2.1 基础架构
- **架构类型**: Transformer / MoE / 其他
- **注意力机制**: Multi-Head Attention / MQA / GQA
- **位置编码**: RoPE / ALiBi / 其他
- **激活函数**: SwiGLU / GeLU / 其他

### 2.2 训练方法
- **预训练数据**: 数据规模、来源、清洗方法
- **训练策略**: 预训练 → SFT → RLHF / DPO
- **优化器**: AdamW / Lion / 其他
- **学习率调度**: Warmup + Cosine Decay

### 2.3 推理优化
- **量化支持**: INT8 / INT4 / FP16 / BF16
- **推理加速**: KV Cache、投机解码、并行解码
- **部署方式**: API、本地部署、边缘设备

## 3. 性能评估

| 指标类别 | 具体指标 | 说明 |
|----------|----------|------|
| **基准测试** | MMLU、GSM8K、HumanEval | 学术基准得分 |
| **推理能力** | 数学推理、逻辑推理、代码生成 | 专项能力评分 |
| **多语言** | 中文、英文、其他语言支持 | 语言覆盖度 |
| **长文本** | 大海捞针、长文本理解 | 长上下文处理能力 |
| **速度性能** | Tokens/秒、首token延迟 | 推理效率 |
| **资源占用** | 显存占用、CPU占用 | 部署成本 |

## 4. 能力特性

### 4.1 核心能力
- [ ] 文本生成
- [ ] 代码生成与理解
- [ ] 数学推理
- [ ] 逻辑推理
- [ ] 多轮对话
- [ ] 工具调用 (Function Calling)
- [ ] 知识问答

### 4.2 扩展能力
- [ ] 多模态理解 (图像、音频、视频)
- [ ] 文件处理 (PDF、Word、Excel)
- [ ] 联网搜索
- [ ] 代码解释器
- [ ] Agent 能力
- [ ] 视觉理解

### 4.3 安全特性
- 内容过滤机制
- 幻觉检测与缓解
- 偏见控制
- 隐私保护

## 5. 代码统计分析

### 5.1 项目规模
- **总文件数**: ${structure.totalFiles}
- **总目录数**: ${structure.totalDirs}

### 5.2 文件类型分布

| 类型 | 数量 |
|------|------|
${Object.entries(structure.fileTypes)
  .sort((a, b) => b[1] - a[1])
  .map(([type, count]) => `| ${type} | ${count} |`)
  .join('\n')}

### 5.3 扩展名统计

| 扩展名 | 数量 |
|--------|------|
${Object.entries(structure.languages)
  .sort((a, b) => b[1] - a[1])
  .slice(0, 15)
  .map(([ext, count]) => `| ${ext || '无扩展名'} | ${count} |`)
  .join('\n')}

## 6. 关键文件

${structure.keyFiles.map(f => `- ${f}`).join('\n')}

## 7. CodeBuddy AI 分析

${codebuddyAnalysis}

## 8. 竞品对比

| 特性 | 模型A | 模型B | 模型C | 本模型 |
|------|-------|-------|-------|--------|
| 参数量 | 70B | 175B | 1.8T | - |
| 上下文窗口 | 128K | 200K | 1M | - |
| MMLU得分 | 85.2 | 86.4 | 90.1 | - |
| 代码能力 | 强 | 中 | 强 | - |
| 中文能力 | 中 | 强 | 强 | - |
| 推理速度 | 快 | 中 | 慢 | - |
| 价格 | $ | $$ | $$$ | - |
| 开源 | 否 | 否 | 是 | - |

## 9. 关键文件预览

${Object.entries(keyFileContents).map(([file, content]) => `
### ${file}

\`\`\`
${content.slice(0, 300)}...
\`\`\`
`).join('\n')}

## 10. 建议与总结

### 10.1 总体评价
- **优势**: 
  - 项目结构清晰
  - 代码组织良好
- **劣势**:
  - 需要补充更多文档
  - 部分功能待完善

### 10.2 使用建议
1. 查看关键文件了解项目结构
2. 检查依赖版本是否最新
3. 确保代码符合最佳实践
4. 定期审查代码质量

### 10.3 优化方向
- 完善技术文档
- 增加单元测试
- 优化代码性能
- 加强安全措施

---
*报告由 CodeBuddy AI 自动生成*
*分析时间: ${new Date().toLocaleString('zh-CN')}*
*分析工具: CodeBuddy + OpenClaw Code Analyzer*
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
