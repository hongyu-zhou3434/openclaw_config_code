# Ollama 配置参数与操作指南

## 一、Ollama 简介

Ollama 是一个用于在本地运行大型语言模型（LLM）的开源工具，支持 macOS、Linux 和 Windows。它简化了模型的下载、配置和运行流程。

---

## 二、安装指南

### 2.1 Linux 安装

```bash
# 使用官方安装脚本
curl -fsSL https://ollama.com/install.sh | sh

# 或手动安装
sudo apt-get update
sudo apt-get install -y curl
sudo curl -L https://ollama.com/download/ollama-linux-amd64 -o /usr/local/bin/ollama
sudo chmod +x /usr/local/bin/ollama
```

### 2.2 macOS 安装

```bash
# 使用 Homebrew
brew install ollama

# 或下载安装包
# https://ollama.com/download/Ollama-darwin.zip
```

### 2.3 Windows 安装

```powershell
# 下载安装程序
# https://ollama.com/download/OllamaSetup.exe

# 或使用 Winget
winget install Ollama.Ollama
```

---

## 三、环境变量配置

### 3.1 核心环境变量

| 变量名 | 默认值 | 说明 | 示例 |
|--------|--------|------|------|
| `OLLAMA_HOST` | `127.0.0.1:11434` | API 服务监听地址 | `0.0.0.0:11434` |
| `OLLAMA_MODELS` | `~/.ollama/models` | 模型存储路径 | `/data/ollama/models` |
| `OLLAMA_KEEP_ALIVE` | `5m` | 模型保持加载时间 | `30m`, `1h` |
| `OLLAMA_NUM_PARALLEL` | `1` | 并行请求数 | `4` |
| `OLLAMA_MAX_LOADED_MODELS` | `1` | 最大加载模型数 | `2` |
| `OLLAMA_DEBUG` | - | 启用调试日志 | `1` |

### 3.2 GPU 相关配置

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `CUDA_VISIBLE_DEVICES` | 指定 CUDA 设备 | `0,1` |
| `HIP_VISIBLE_DEVICES` | AMD GPU 设备 | `0` |
| `OLLAMA_GPU_OVERHEAD` | GPU 内存预留(MB) | `512` |

### 3.3 性能优化配置

| 变量名 | 默认值 | 说明 | 示例 |
|--------|--------|------|------|
| `OLLAMA_CONTEXT_LENGTH` | 2048 | 上下文长度 | `4096`, `8192` |
| `OLLAMA_BATCH_SIZE` | 512 | 批处理大小 | `1024` |
| `OLLAMA_FLASH_ATTENTION` | - | 启用 Flash Attention | `1` |
| `OLLAMA_KV_CACHE_TYPE` | - | KV Cache 类型 | `q8_0`, `q4_0` |

### 3.4 配置示例

```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export OLLAMA_HOST=0.0.0.0:11434
export OLLAMA_MODELS=/data/ollama/models
export OLLAMA_KEEP_ALIVE=30m
export OLLAMA_NUM_PARALLEL=4
export OLLAMA_MAX_LOADED_MODELS=2
export OLLAMA_CONTEXT_LENGTH=4096

# 启动服务
ollama serve
```

---

## 四、CLI 命令参考

### 4.1 服务管理

```bash
# 启动服务（前台）
ollama serve

# 后台启动
nohup ollama serve > /var/log/ollama.log 2>&1 &

# 使用 systemd 服务
sudo systemctl start ollama
sudo systemctl stop ollama
sudo systemctl restart ollama
sudo systemctl status ollama
sudo systemctl enable ollama  # 开机自启
```

### 4.2 模型管理

```bash
# 拉取模型
ollama pull llama3.2
ollama pull qwen2.5
ollama pull deepseek-r1

# 列出本地模型
ollama list

# 删除模型
ollama rm llama3.2

# 复制模型
ollama cp llama3.2 my-llama3.2

# 查看模型信息
ollama show llama3.2
ollama show llama3.2 --modelfile
ollama show llama3.2 --parameters
ollama show llama3.2 --license
```

### 4.3 运行模型

```bash
# 交互式对话
ollama run llama3.2

# 单次提问
ollama run llama3.2 "你好，请介绍一下自己"

# 从标准输入读取
echo "你好" | ollama run llama3.2

cat prompt.txt | ollama run llama3.2

# 指定参数运行
ollama run llama3.2 --temperature 0.7 --top_p 0.9
```

### 4.4 Modelfile 操作

```bash
# 从 Modelfile 创建模型
cat > Modelfile << 'EOF'
FROM llama3.2
PARAMETER temperature 0.7
PARAMETER top_p 0.9
SYSTEM 你是一个专业的AI助手
EOF

ollama create my-model -f Modelfile

# 导出 Modelfile
ollama show llama3.2 --modelfile > Modelfile
```

---

## 五、Modelfile 语法

### 5.1 基本结构

```dockerfile
FROM llama3.2

# 参数配置
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER top_k 40
PARAMETER num_ctx 4096
PARAMETER num_predict 2048

# 系统提示词
SYSTEM """
你是一个专业的AI助手。
请用中文回答问题。
"""

# 对话模板（可选）
TEMPLATE """
{{ if .System }}<|system|>
{{ .System }}</s>
{{ end }}{{ if .Prompt }}<|user|>
{{ .Prompt }}</s>
<|assistant|>
{{ end }}{{ .Response }}</s>
"""

# 适配器（LoRA）
ADAPTER ./path/to/adapter.bin

# 许可证
LICENSE """
MIT License
"""
```

### 5.2 PARAMETER 参数详解

| 参数名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `temperature` | float | 0.8 | 采样温度，越高越随机 |
| `top_p` | float | 0.9 | 核采样阈值 |
| `top_k` | int | 40 | Top-K 采样 |
| `num_ctx` | int | 2048 | 上下文窗口大小 |
| `num_predict` | int | -1 | 最大生成token数 |
| `repeat_penalty` | float | 1.1 | 重复惩罚系数 |
| `presence_penalty` | float | 0.0 | 存在惩罚 |
| `frequency_penalty` | float | 0.0 | 频率惩罚 |
| `seed` | int | 0 | 随机种子 |
| `stop` | string | - | 停止序列 |
| `num_gpu` | int | -1 | 使用GPU层数 |
| `main_gpu` | int | 0 | 主GPU索引 |

### 5.3 消息格式

```dockerfile
MESSAGE user 你好
MESSAGE assistant 你好！有什么可以帮助你的吗？

# 多轮对话示例
MESSAGE user 什么是机器学习？
MESSAGE assistant 机器学习是...
MESSAGE user 能举个例子吗？
MESSAGE assistant 当然可以...
```

---

## 六、API 接口

### 6.1 生成 completions

```bash
# 流式响应
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "你好",
  "stream": true,
  "options": {
    "temperature": 0.7,
    "num_ctx": 4096
  }
}'

# 非流式响应
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "你好",
  "stream": false
}'
```

### 6.2 聊天对话

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2",
  "messages": [
    {"role": "system", "content": "你是助手"},
    {"role": "user", "content": "你好"}
  ],
  "stream": true
}'
```

### 6.3 嵌入向量

```bash
curl http://localhost:11434/api/embeddings -d '{
  "model": "nomic-embed-text",
  "prompt": "需要编码的文本"
}'
```

### 6.4 模型管理 API

```bash
# 列出模型
curl http://localhost:11434/api/tags

# 拉取模型
curl -X POST http://localhost:11434/api/pull -d '{
  "name": "llama3.2"
}'

# 删除模型
curl -X DELETE http://localhost:11434/api/delete -d '{
  "name": "llama3.2"
}'

# 复制模型
curl -X POST http://localhost:11434/api/copy -d '{
  "source": "llama3.2",
  "destination": "my-llama3.2"
}'
```

---

## 七、OpenAI 兼容 API

Ollama 提供与 OpenAI API 兼容的接口：

```bash
# completions
curl http://localhost:11434/v1/completions -H "Content-Type: application/json" -d '{
  "model": "llama3.2",
  "prompt": "你好",
  "max_tokens": 100
}'

# chat completions
curl http://localhost:11434/v1/chat/completions -H "Content-Type: application/json" -d '{
  "model": "llama3.2",
  "messages": [
    {"role": "user", "content": "你好"}
  ]
}'

# embeddings
curl http://localhost:11434/v1/embeddings -H "Content-Type: application/json" -d '{
  "model": "nomic-embed-text",
  "input": "需要编码的文本"
}'

# list models
curl http://localhost:11434/v1/models
```

---

## 八、常用模型推荐

### 8.1 通用对话模型

| 模型 | 大小 | 特点 | 命令 |
|------|------|------|------|
| llama3.2 | 3B/1B | Meta 最新轻量级模型 | `ollama pull llama3.2` |
| qwen2.5 | 7B/14B | 阿里通义千问，中文优秀 | `ollama pull qwen2.5` |
| deepseek-v3 | 多规格 | DeepSeek V3，推理能力强 | `ollama pull deepseek-v3` |
| mistral | 7B | 高性能小模型 | `ollama pull mistral` |
| gemma2 | 9B/27B | Google Gemma2 | `ollama pull gemma2` |

### 8.2 代码模型

| 模型 | 大小 | 特点 | 命令 |
|------|------|------|------|
| codellama | 7B/13B/34B | Meta 代码专用模型 | `ollama pull codellama` |
| deepseek-coder | 6.7B/33B | DeepSeek 代码模型 | `ollama pull deepseek-coder` |
| qwen2.5-coder | 7B/14B | 阿里代码模型 | `ollama pull qwen2.5-coder` |

### 8.3 嵌入模型

| 模型 | 大小 | 特点 | 命令 |
|------|------|------|------|
| nomic-embed-text | 137M | 通用文本嵌入 | `ollama pull nomic-embed-text` |
| mxbai-embed-large | 335M | 高质量嵌入 | `ollama pull mxbai-embed-large` |
| bge-m3 | 567M | 多语言嵌入 | `ollama pull bge-m3` |

### 8.4 视觉模型

| 模型 | 特点 | 命令 |
|------|------|------|
| llava | 多模态对话 | `ollama pull llava` |
| llava-phi3 | 轻量级视觉模型 | `ollama pull llava-phi3` |
| moondream | 小型视觉模型 | `ollama pull moondream` |

---

## 九、性能优化

### 9.1 GPU 加速

```bash
# 查看 GPU 支持
ollama ps

# 指定 GPU 运行
CUDA_VISIBLE_DEVICES=0 ollama run llama3.2

# 多 GPU
CUDA_VISIBLE_DEVICES=0,1 ollama run llama3.2
```

### 9.2 量化配置

```dockerfile
# Modelfile 中指定量化
FROM llama3.2:q4_0    # 4-bit 量化
FROM llama3.2:q8_0    # 8-bit 量化
FROM llama3.2:fp16    # FP16 精度
```

### 9.3 内存优化

```bash
# 限制并发请求
export OLLAMA_NUM_PARALLEL=2

# 限制最大加载模型数
export OLLAMA_MAX_LOADED_MODELS=1

# 缩短模型保持时间
export OLLAMA_KEEP_ALIVE=5m
```

---

## 十、故障排查


### 10.1 常见问题

```bash
# 检查服务状态
ollama --version
curl http://localhost:11434/api/tags

# 查看日志
journalctl -u ollama -f
tail -f ~/.ollama/logs/server.log

# 检查模型文件
ls -la ~/.ollama/models/
du -sh ~/.ollama/models/*

# 清理未使用的模型
ollama list
ollama rm <model-name>
```

### 10.2 错误解决

| 错误 | 原因 | 解决 |
|------|------|------|
| `connection refused` | 服务未启动 | `ollama serve` |
| `model not found` | 模型未下载 | `ollama pull <model>` |
| `out of memory` | 显存不足 | 使用量化模型或减少并发 |
| `permission denied` | 权限问题 | 检查目录权限 |
| `port already in use` | 端口被占用 | 修改 OLLAMA_HOST |

### 10.3 调试模式

```bash
# 启用调试日志
export OLLAMA_DEBUG=1
ollama serve

# 查看详细日志
OLLAMA_DEBUG=1 ollama run llama3.2 2>&1 | tee ollama.log
```

---

## 十一、Docker 部署

### 11.1 使用 Docker

```bash
# 拉取镜像
docker pull ollama/ollama

# 运行容器
docker run -d \
  -v ollama:/root/.ollama \
  -p 11434:11434 \
  --name ollama \
  ollama/ollama

# 在容器内执行命令
docker exec -it ollama ollama pull llama3.2
docker exec -it ollama ollama run llama3.2

# GPU 支持（NVIDIA）
docker run -d \
  --gpus=all \
  -v ollama:/root/.ollama \
  -p 11434:11434 \
  --name ollama \
  ollama/ollama
```

### 11.2 Docker Compose

```yaml
version: '3.8'

services:
  ollama:
    image: ollama/ollama
    container_name: ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama-data:/root/.ollama
    environment:
      - OLLAMA_KEEP_ALIVE=30m
      - OLLAMA_NUM_PARALLEL=4
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]

volumes:
  ollama-data:
```

---

## 十二、与 OpenClaw 集成

### 12.1 配置 OpenClaw 使用 Ollama

```json
// ~/.openclaw/config.json
{
  "llm": {
    "provider": "ollama",
    "baseUrl": "http://localhost:11434",
    "model": "llama3.2",
    "options": {
      "temperature": 0.7,
      "num_ctx": 4096
    }
  }
}
```

### 12.2 环境变量配置

```bash
# 添加到 ~/.bashrc
export OPENCLAW_LLM_PROVIDER=ollama
export OPENCLAW_LLM_BASE_URL=http://localhost:11434
export OPENCLAW_LLM_MODEL=llama3.2
```

---

## 十三、参考链接

- **官方文档**: https://github.com/ollama/ollama/blob/main/docs/README.md
- **模型库**: https://ollama.com/library
- **GitHub**: https://github.com/ollama/ollama
- **Discord**: https://discord.gg/ollama

---

*文档版本: v1.0*  
*最后更新: 2026-03-18*  
*作者: OpenClaw AI*
