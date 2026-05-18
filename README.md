# mnesora

> Local-first AI relationship profile — your shared memory with AI.

mnesora 是本地优先的桌面 AI 助手，维护你的"AI 关系档案"（关于你、你身边的人、项目、决定、偏好、stance 的结构化卡片），并通过 MCP 让外部 AI 工具（Claude / Cursor / Claude Desktop / 任何 MCP-client）共享这份档案。AI 可以提议写入档案，但所有写入必经你审核。

## Why

- **本地优先 + 你掌控** — 卡片是普通 markdown 文件，git clone 走就能离开
- **AI 双向共享** — AI 不只是消费者，也是协作者；提议入档由你审
- **跨工具记忆** — 一份档案，所有 AI 工具（Claude / Cursor / ChatGPT 等）都能读
- **多模态采集** — 一句话 / 一张图 / 一段语音都能建数据
- **开源 + 可自托管** — AGPL v3 + CLA；OSS 版本包含可自托管 sync server

## Status

🚧 **Pre-alpha.** v0.1 设计已锁定，实现进行中。

- 设计文档：[docs/superpowers/specs/2026-05-18-mnesora-design.md](docs/superpowers/specs/2026-05-18-mnesora-design.md)
- v0.1 路线图：[#9 v0.1 Roadmap (tracking)](https://github.com/manzhi-tech/mnesora/issues/9)
- v0.1 目标发布：**2026-08-18**

## Architecture (snapshot)

- **Card Store** — markdown + frontmatter + git audit
- **Staging Queue** — AI 提案 inbox，你审 ✓ / ✗ / ✎
- **Local LLM** — Ollama / llama.cpp / MLX；云模型可选 / Pro
- **MCP Server** — `get_context` / `search` / `get_card` / `propose_update`
- **SQLite Index** — frontmatter + embedding

完整架构与决策记录见 [设计文档](docs/superpowers/specs/2026-05-18-mnesora-design.md)。

## OSS / Pro

|  | OSS (`mnesora`) | Pro (`mnesora-pro`) |
|---|---|---|
| 桌面 app | ✓ | ✓ |
| 本地 LLM 集成 | ✓ | ✓ |
| 本地 STT + embedding | ✓ | ✓ |
| MCP server | ✓ | ✓ |
| 配自己的云 API key | ✓ | ✓ |
| 自托管 sync server (v0.2+) | ✓ | ✓ |
| 托管云模型 quota | ✗ | ✓ |
| 托管 sync server | ✗ | ✓ |
| 高级云 STT / vision | ✗ | ✓ |
| 模板市场 | ✗ | ✓ |
| 团队 / 共享卡片 (v1+) | ✗ | ✓ |

Pro 是独立私仓，编译进生产 app，**不改 OSS 代码**（见 [issue #6](https://github.com/manzhi-tech/mnesora/issues/6)）。

## License

[AGPL v3](LICENSE) + CLA（双授权）。Contributor 需带 DCO sign-off（CLA 系统就绪后改为正式 CLA，见 [issue #5](https://github.com/manzhi-tech/mnesora/issues/5)）。详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## Contributing

请先读 [CONTRIBUTING.md](CONTRIBUTING.md)。

新人友好的 issue 见 [`good first issue`](https://github.com/manzhi-tech/mnesora/labels/good%20first%20issue) 标签（v0.1 ramp 之后陆续放出）。
