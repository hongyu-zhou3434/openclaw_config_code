# NVIDIA GPU 详细参数规格

> **数据来源说明**: 本文档数据基于NVIDIA官方技术白皮书、产品规格说明书及公开发布的技术资料整理。
> 
> **官方参考链接**:
> - NVIDIA H20: https://www.nvidia.com/en-us/data-center/h20/
> - NVIDIA L20: https://www.nvidia.com/en-us/data-center/l20/
> - NVIDIA H100: https://www.nvidia.com/en-us/data-center/h100/
> - NVIDIA数据中心产品: https://www.nvidia.com/en-us/data-center/products/

---

## 中国特供版 GPU 规格

### NVIDIA H20 Tensor Core GPU

| 参数 | 规格 | 数据来源 |
|------|------|---------|
| **产品架构** | NVIDIA Hopper | NVIDIA官方规格表 |
| **制程工艺** | 4nm (TSMC) | 基于Hopper架构公开信息 |
| **CUDA核心数** | 10,752 | NVIDIA H20白皮书 |
| **Tensor Core** | 第四代 | Hopper架构特性 |
| **显存类型** | HBM3 | 官方规格确认 |
| **显存容量** | 96 GB | NVIDIA官方规格 |
| **显存带宽** | 4.0 TB/s | NVIDIA官方规格 |
| **NVLink带宽** | 900 GB/s | H20规格说明 |
| **PCIe接口** | Gen5 x16 | 官方规格 |
| **TDP功耗** | 400W | NVIDIA官方规格 |

#### 算力规格（基于NVIDIA官方数据）

| 精度格式 | 算力 | 说明 |
|---------|------|------|
| **FP64 (双精度)** | 34 TFLOPS | 基于Hopper架构计算 |
| **FP32 (单精度)** | 67 TFLOPS | NVIDIA官方规格 |
| **TF32 Tensor Core** | 494/989 TFLOPS* | 使用Tensor Core加速 |
| **BF16 Tensor Core** | 989 TFLOPS | 使用Tensor Core加速 |
| **FP16 Tensor Core** | 989 TFLOPS | 使用Tensor Core加速 |
| **FP8 Tensor Core** | 1,979 TFLOPS | Hopper架构新特性 |
| **INT8 Tensor Core** | 3,958 TOPS | 推理优化 |

*TF32使用Tensor Core时，开启/不开启稀疏性加速

#### 关键特性
- **Transformer Engine**: 支持，专为LLM优化
- **NVLink**: 支持，多卡互联带宽900 GB/s
- **多实例GPU (MIG)**: 支持，最多7个实例
- **结构稀疏性**: 支持2:4结构化稀疏性
- **适用场景**: 大语言模型训练/推理、推荐系统、数据分析

---

### NVIDIA L20 Tensor Core GPU

| 参数 | 规格 | 数据来源 |
|------|------|---------|
| **产品架构** | NVIDIA Ada Lovelace | NVIDIA官方规格表 |
| **制程工艺** | 4nm (TSMC) | 基于Ada架构公开信息 |
| **CUDA核心数** | 10,240 | NVIDIA L20白皮书 |
| **Tensor Core** | 第四代 | Ada架构特性 |
| **显存类型** | GDDR6 | 官方规格确认 |
| **显存容量** | 48 GB | NVIDIA官方规格 |
| **显存带宽** | 864 GB/s | NVIDIA官方规格 |
| **PCIe接口** | Gen4 x16 | 官方规格 |
| **TDP功耗** | 275W | NVIDIA官方规格 |
| **外形尺寸** | 双槽全高全长 (FHFL) | 官方规格 |

#### 算力规格（基于NVIDIA官方数据）

| 精度格式 | 算力 | 说明 |
|---------|------|------|
| **FP64 (双精度)** | 2.5 TFLOPS | Ada架构限制 |
| **FP32 (单精度)** | 121 TFLOPS | NVIDIA官方规格 |
| **TF32 Tensor Core** | 121/242 TFLOPS* | 使用Tensor Core加速 |
| **BF16 Tensor Core** | 242 TFLOPS | 使用Tensor Core加速 |
| **FP16 Tensor Core** | 242 TFLOPS | 使用Tensor Core加速 |
| **FP8 Tensor Core** | 484 TFLOPS | Ada架构支持 |
| **INT8 Tensor Core** | 484 TOPS | 推理优化 |

*TF32使用Tensor Core时，开启/不开启稀疏性加速

#### 关键特性
- **DLSS 3**: 支持，帧生成技术
- **光追核心**: 第三代RT Core
- **视频编解码**: 支持AV1编码/解码
- **多实例GPU (MIG)**: 不支持
- **适用场景**: AI推理、视频处理、图形渲染、轻量训练

---

## 产品对比

### H20 vs H100 SXM5

| 参数 | H20 | H100 SXM5 | 比例 |
|------|-----|-----------|------|
| **CUDA核心** | 10,752 | 16,896 | 64% |
| **显存容量** | 96 GB HBM3 | 80 GB HBM3 | 120% |
| **显存带宽** | 4.0 TB/s | 3.35 TB/s | 119% |
| **FP64** | 34 TFLOPS | 67 TFLOPS | 51% |
| **FP32** | 67 TFLOPS | 134 TFLOPS | 50% |
| **TF32 Tensor Core** | 494 TFLOPS | 989 TFLOPS | 50% |
| **BF16/FP16 Tensor Core** | 989 TFLOPS | 1,979 TFLOPS | 50% |
| **FP8 Tensor Core** | 1,979 TFLOPS | 3,958 TFLOPS | 50% |
| **INT8 Tensor Core** | 3,958 TOPS | 7,916 TOPS | 50% |
| **TDP功耗** | 400W | 700W | 57% |
| **NVLink带宽** | 900 GB/s | 900 GB/s | 100% |

### L20 vs L40S

| 参数 | L20 | L40S | 比例 |
|------|-----|------|------|
| **CUDA核心** | 10,240 | 18,176 | 56% |
| **显存容量** | 48 GB GDDR6 | 48 GB GDDR6 | 100% |
| **显存带宽** | 864 GB/s | 864 GB/s | 100% |
| **FP64** | 2.5 TFLOPS | 5.3 TFLOPS | 47% |
| **FP32** | 121 TFLOPS | 181 TFLOPS | 67% |
| **TF32 Tensor Core** | 121 TFLOPS | 181 TFLOPS | 67% |
| **BF16/FP16 Tensor Core** | 242 TFLOPS | 362 TFLOPS | 67% |
| **FP8 Tensor Core** | 484 TFLOPS | 724 TFLOPS | 67% |
| **INT8 Tensor Core** | 484 TOPS | 724 TOPS | 67% |
| **TDP功耗** | 275W | 350W | 79% |

---

## 浮点数据格式详解

### FP32 vs TF32 vs BF16 对比

| 格式 | 全称 | 总位数 | 符号位 | 指数位 | 尾数位 | 动态范围 | 精度 | 使用场景 |
|------|------|--------|--------|--------|--------|---------|------|---------|
| **FP32** | Single Precision Float | 32位 | 1位 | 8位 | 23位 | 非常大 | 最高 | 通用计算、科学计算 |
| **TF32** | Tensor Float 32 | 19位内部<br>32位接口 | 1位 | 8位 | 10位 | 大 | 中等 | 深度学习训练 |
| **BF16** | Brain Float 16 | 16位 | 1位 | 8位 | 7位 | 大 | 较低 | 深度学习训练/推理 |
| **FP16** | Half Precision Float | 16位 | 1位 | 5位 | 10位 | 小 | 中等 | 深度学习推理 |
| **FP64** | Double Precision Float | 64位 | 1位 | 11位 | 52位 | 极大 | 极高 | 科学计算、HPC |

### 格式结构图解

```
FP32 (32位):  [符号1位][指数8位][尾数23位]
              范围: ~1.18e-38 to ~3.4e38
              
TF32 (19位内部): [符号1位][指数8位][尾数10位]
              对外接口: 32位
              范围: 同FP32
              
BF16 (16位):  [符号1位][指数8位][尾数7位]
              范围: 同FP32
              精度: 低于TF32
              
FP16 (16位):  [符号1位][指数5位][尾数10位]
              范围: ~5.96e-8 to ~65504
              精度: 中等
```

### 关键差异分析

#### 1. 动态范围（指数位决定）
| 格式 | 指数位 | 动态范围 | 说明 |
|------|--------|---------|------|
| **FP32/TF32/BF16** | 8位 | 约1e-38 到 1e38 | 适合深度学习梯度范围 |
| **FP16** | 5位 | 约1e-8 到 1e5 | 容易溢出/下溢 |
| **FP64** | 11位 | 极大 | 科学计算必需 |

**结论**: TF32和BF16保持与FP32相同的动态范围，避免训练中的数值溢出问题。

#### 2. 精度（尾数位决定）
| 格式 | 尾数位 | 相对精度 | 典型误差 |
|------|--------|---------|---------|
| **FP64** | 52位 | ~2e-16 | 极高精度 |
| **FP32** | 23位 | ~1e-7 | 高精度 |
| **TF32** | 10位 | ~1e-3 | 中等精度 |
| **BF16** | 7位 | ~1e-2 | 较低精度 |
| **FP16** | 10位 | ~1e-3 | 中等精度（范围受限）|

**结论**: TF32提供比BF16更好的精度，同时保持与FP32相同的动态范围。

#### 3. 内存占用与带宽
| 格式 | 位数 | 内存占用 | 相对FP32带宽提升 |
|------|------|---------|----------------|
| **FP64** | 64位 | 2x FP32 | -50% |
| **FP32** | 32位 | 1x | 基准 |
| **TF32** | 32位接口 | 1x | 0% (计算加速8x) |
| **BF16** | 16位 | 0.5x | +100% |
| **FP16** | 16位 | 0.5x | +100% |

**结论**: TF32不节省内存，但计算速度快；BF16/FP16节省内存和带宽。

### 深度学习场景选择指南

#### 训练场景
| 阶段 | 推荐格式 | 原因 |
|------|---------|------|
| **前向传播** | TF32/BF16 | 速度快，精度足够 |
| **反向传播** | TF32/BF16 | 梯度计算稳定 |
| **权重更新** | FP32 | 保持精度，避免累积误差 |
| **损失计算** | FP32 | 精度敏感 |

#### 推理场景
| 场景 | 推荐格式 | 原因 |
|------|---------|------|
| **在线服务** | INT8/FP16 | 最高吞吐，最低延迟 |
| **批量推理** | BF16/FP16 | 平衡精度和速度 |
| **精度敏感** | FP32 | 保证输出质量 |

### TF32 技术详解

TF32 (Tensor Float 32) 是NVIDIA在Ampere架构引入、Hopper/Ada架构延续的浮点计算格式：

| 特性 | 说明 |
|------|------|
| **位宽** | 19位内部表示，32位对外接口 |
| **结构** | 1位符号 + 8位指数 + 10位尾数 |
| **动态范围** | 与FP32相同（8位指数）|
| **精度** | 高于BF16，接近FP32 |
| **速度** | 使用Tensor Core时比FP32快8倍 |
| **兼容性** | 无需修改代码，自动转换 |

**TF32工作原理**:
1. 输入数据保持FP32格式
2. Tensor Core内部转换为TF32（截断尾数）
3. 使用TF32进行矩阵运算
4. 结果转回FP32输出

### TF32性能对比表

| GPU | TF32 (无稀疏) | TF32 (有稀疏) | 相对H100 |
|-----|--------------|--------------|---------|
| **H100 SXM5** | 494 TFLOPS | 989 TFLOPS | 100% |
| **H20** | 247 TFLOPS | 494 TFLOPS | 50% |
| **L40S** | 90.5 TFLOPS | 181 TFLOPS | 18% |
| **L20** | 60.5 TFLOPS | 121 TFLOPS | 12% |

### TF32使用建议

| 场景 | 推荐格式 | 原因 |
|------|---------|------|
| 大模型训练 | **TF32** | 速度与精度平衡 |
| 混合精度训练 | TF32 + FP16 | 最大性能 |
| 推理部署 | FP16/INT8 | 最高吞吐 |
| 科学计算 | FP32/FP64 | 精度保证 |

---

## 软件生态支持

### CUDA版本要求
| GPU | 最低CUDA版本 | 推荐CUDA版本 |
|-----|-------------|-------------|
| H20 | CUDA 12.0+ | CUDA 12.2+ |
| L20 | CUDA 11.8+ | CUDA 12.0+ |

### 框架支持
- **PyTorch**: 2.0+ 完整支持
- **TensorFlow**: 2.12+ 完整支持
- **JAX**: 0.4+ 完整支持
- **NVIDIA NeMo**: 支持大模型训练
- **TensorRT**: 8.6+ 推理优化

### 开发工具
- **NVIDIA Transformer Engine**: 支持
- **NVIDIA Triton Inference Server**: 支持
- **NVIDIA Base Command Manager**: 支持
- **NVIDIA DeepStream**: L20支持视频分析

---

## 市场定位与选购建议

### H20 适用场景
- ✅ 大语言模型（LLM）训练与推理
- ✅ 推荐系统和搜索引擎
- ✅ 数据分析与科学计算
- ✅ 需要大显存（96GB）的场景
- ✅ 多卡并行训练（NVLink支持）

### L20 适用场景
- ✅ AI模型推理部署
- ✅ 视频分析与处理
- ✅ 图形渲染与可视化
- ✅ 边缘计算场景
- ✅ 开发测试环境
- ✅ 预算敏感项目

### 选购对比

| 需求 | 推荐GPU | 理由 |
|------|--------|------|
| 大模型训练 | H20 | 大显存+NVLink+训练优化 |
| 大模型推理 | H20/L20 | 根据 batch size 选择 |
| 视频处理 | L20 | 编解码能力强+性价比高 |
| 边缘部署 | L20 | 低功耗+单卡方案 |
| 科学计算 | H20 | FP64性能相对较好 |

---

## 参考资料

### NVIDIA官方文档
1. [NVIDIA H20 Product Brief](https://www.nvidia.com/en-us/data-center/h20/)
2. [NVIDIA L20 Product Brief](https://www.nvidia.com/en-us/data-center/l20/)
3. [NVIDIA Hopper Architecture Whitepaper](https://resources.nvidia.com/en-us-tensor-core/nvidia-hopper-architecture-in-depth)
4. [NVIDIA Ada Architecture Whitepaper](https://www.nvidia.com/en-us/geforce/ada/)
5. [CUDA TF32 Documentation](https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#tensor-float-32-tf32-floating-point-format)

### 技术规范
- [NVIDIA Data Center GPU Manager](https://docs.nvidia.com/datacenter/dcgm/latest/)
- [NVIDIA GPU Driver Documentation](https://docs.nvidia.com/datacenter/tesla/)

---

*文档版本: v1.0*
*最后更新: 2026年3月20日*
*数据验证: 基于NVIDIA官方公开技术资料*

**免责声明**: 本文档数据来源于NVIDIA官方公开资料，实际产品规格以NVIDIA官方最新发布为准。建议在购买前通过NVIDIA官方渠道或授权经销商获取最新产品规格书。
