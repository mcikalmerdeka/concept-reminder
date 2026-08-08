# What Precision Do LLMs Originally Come In? (FP32 vs FP16 vs BF16)

## Short Answer

Yes — modern large language models are originally trained and released in **16-bit precision**, and specifically it's almost always **BFloat16 (BF16)** today, not plain Float16 (FP16). The earlier answer you got is accurate on the core facts. Below is a fuller picture, including why BF16 won out over FP16, and how this connects to file size and quantization.

---

## The Three Formats You'll See

| Format | Total bits | Sign | Exponent | Mantissa | Bytes/parameter |
|---|---|---|---|---|---|
| **FP32** (full precision) | 32 | 1 | 8 | 23 | 4 bytes |
| **FP16** (half precision) | 16 | 1 | 5 | 10 | 2 bytes |
| **BF16** (Brain Float 16) | 16 | 1 | 8 | 7 | 2 bytes |

The interesting part is how FP16 and BF16 split up their 16 bits differently, even though both use the same total size.

### FP32 — the old default, rarely used to release models today
Years ago models were trained and shared in full 32-bit precision. It's the most numerically accurate, but it doubles memory and storage needs compared to 16-bit for essentially no meaningful gain in model quality at inference time. Companies today almost never release consumer-facing LLMs in FP32 — it's mostly kept internally for select operations during training (loss scaling, optimizer states, "master weights") rather than for the whole model.

### FP16 — decent precision, narrow range
FP16 has more mantissa bits (10) than BF16, so it can represent numbers more precisely within its range. Its problem is the exponent: only 5 bits, giving it a much narrower dynamic range than FP32. During LLM training, gradients and activations often span huge ranges of magnitude, and FP16 will silently overflow or underflow when values get too large or too small. Historically this required workarounds like "loss scaling" to keep training stable, and even then, some research shows FP16 training runs can be unstable or diverge without careful tuning.

### BF16 — the modern default for training and release
BF16 was developed by Google Brain and uses the *same 8-bit exponent as FP32*, just with a smaller 7-bit mantissa. That means it gives up some fine-grained precision but keeps FP32's wide dynamic range — which turns out to matter more for training stability than raw precision does. This is why BF16 has become the default 16-bit format across major training frameworks (PyTorch, Megatron, DeepSpeed) and why essentially all modern open-weight model families (Llama, Mistral, Gemma, Qwen, and others) are trained and originally released in BF16. Every major current GPU generation (NVIDIA Ampere and later, AMD, Intel, ARM) has native BF16 support, so there's little reason to go back to FP16.

**Bottom line:** if you download an "original" or "full precision" release of a modern LLM from Hugging Face, it is virtually always going to be BF16, occasionally FP16 for compatibility with older hardware/tooling, and essentially never FP32.

## Why This Matters for File Size

Since 16-bit precision means 2 bytes per parameter, you can estimate a model's original download size with a simple rule of thumb:

```
Model size (GB) ≈ number of parameters (in billions) × 2
```

Examples:
- **8B parameter model** → ~16 GB in BF16/FP16
- **70B parameter model** → ~140 GB in BF16/FP16

This is exactly why quantized formats like **GGUF** exist: compressing that 16 GB model down to 4-bit weights (~4x smaller) shrinks it to roughly 4–5 GB, letting it fit comfortably in RAM on a normal laptop, at some cost to precision and, in turn, a small amount of output quality.

## Where FP8 Fits In (Emerging, Not Yet Standard)

Worth knowing for context: with newer NVIDIA Hopper-generation GPUs, **FP8 training** is emerging as the next step down in precision for pretraining very large models, aiming to cut memory and compute costs further. As of now, most production training pipelines still compute the bulk of operations in BF16, with FP32 reserved for a few precision-sensitive parts (like optimizer states and master weight copies) — full FP8 training is still an active research area rather than the default.

## Quick Mental Model

```
FP32 (32-bit, "full precision")
   │  rarely used to release/store finished LLMs today
   ▼
BF16 (16-bit, wide range) ← the modern default for training & original release
   │  or occasionally FP16 (16-bit, more precise but narrower range)
   ▼
Quantized formats (8-bit, 4-bit, ...) ← GGUF, GPTQ, AWQ, etc.
   used for efficient local/edge inference, not for training
```

## Key Takeaways

- Modern LLMs are trained and released in **16-bit precision**, and specifically **BF16** in almost all current cases.
- **BF16 vs FP16**: BF16 trades some numerical precision (smaller mantissa) for a much wider dynamic range (same exponent size as FP32), which makes it far more stable for training large models.
- **FP32** used to be the default years ago, but is now mostly limited to specific internal training operations rather than full model storage/release.
- File size scales directly with precision: 16-bit ≈ 2 bytes/parameter, which is the baseline that quantized formats like GGUF compress further.
- **FP8** is an emerging, hardware-dependent step toward even lower-precision training, but it's not yet the mainstream default.

---

*Compiled from current documentation, hardware vendor guides, and recent research on mixed-precision training as of August 2026.*
