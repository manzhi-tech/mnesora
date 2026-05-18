# Mnesora — Design Spec (v0.1)

- **Date:** 2026-05-18
- **Status:** Brainstorming-approved, pre-implementation
- **Repo:** https://github.com/manzhi-tech/mnesora
- **License:** AGPL v3 + CLA (dual-license)

## Vision

Mnesora 是本地优先的桌面 AI 助手，维护用户的"AI 关系档案"——一组结构化但有叙述的卡片（关于你、你身边的人、项目、决定、偏好、stance），并通过 MCP 让外部 AI 工具（Claude / Cursor / Claude Desktop / 任何 MCP-client）共享这份档案。AI 可以提议写入档案，但所有写入必经用户审核。

## Decisions Locked

| # | 决定 | 选择 |
|---|------|------|
| 1 | 记忆共享含义 | **B** — 双向：AI 可写回，用户审核 |
| 2 | 目标用户 | **D** — 垂直场景先深耕 |
| 3 | 垂直方向 | **D** — AI 关系档案（跨 AI 工具的自我档案）|
| 4 | 冷启动 wedge | **D** — 桌面 native 为 hub |
| 5 | OSS / Pro 边界 | **B** — Plausible 模式（OSS 含可自托管 sync，Pro = 托管 + 云 + 高级）|
| 6 | License | **A** — AGPL v3 + CLA（双授权）|
| 7 | 数据模型 | **C** — 卡片 + 叙述体 + 结构化字段 |
| 8 | Wow moment | **B** + 内置本地模型 |
| 9 | 模型策略 | **A** — 本地为先 + 云为补 |

---

## Section 1: 整体形态

### 关键组件

1. **Card Store** — markdown + frontmatter 文件 + git 历史 = 单一事实源 + 审计
2. **Staging Queue** — AI 提案在这里等用户审，所有 AI 写都经过它
3. **Local LLM Runtime** — 默认本地（Ollama / llama.cpp / MLX）；云模型可选 / Pro
4. **MCP Server** — 把档案暴露给外部 AI 工具
5. **SQLite Index** — frontmatter 结构化查询 + embedding 向量检索
6. **Sync Engine**（v0.2+）— 可选 E2EE 同步，OSS 自托管 server，Pro 托管

### Capture 数据流

```
你 → 输入层
     ├─ 语音 → STT (whisper.cpp / OS-native / 云) → 文本
     ├─ 图   → OCR + vision caption → 文本
     └─ 文   → 文本
        ↓
   本地 LLM 结构化（找候选卡 + 提案 patch）
        ↓
   Staging Queue（用户审 ✓ / ✗ / ✎）
        ↓
   Card Store 写 + git commit
        ↓
   SQLite Index 增量
```

### 外部 AI 读取

```
Claude / Cursor / Claude Desktop
     ↓ MCP: get_context(topic, depth)
MCP Server → SQLite Index 召回 → Card Store 取片段 → 拼上下文返回
```

### AI 写回

```
外部 AI（或本地 mnesora-AI）→ MCP: propose_update(card, patch, evidence)
     ↓
Staging Queue（用户审）
     ↓
Card Store 写
```

### 关键设计原则

- 结构化 LLM 是**纯文本**模型即可；多模态需求被前置到独立 transducer
- 原始 audio / image 都保留为 attachments；卡片 `source` 字段 link 回原件
- 人写直接落盘；AI 写必经 Staging

---

## Section 2: 数据 + AI 流

### 2.1 文件布局

```
.mnesora/
├── identity.md                 # 你自己（singleton）
├── people/<slug>.md            # 关系
├── projects/{current,archived}/<slug>.md
├── stances/<slug>.md           # 观点 / 框架
├── decisions/<date-slug>.md    # 决策日志
├── preferences/<slug>.md       # 偏好
├── templates/<type>.md         # 模板定义本身
└── attachments/<date>-<kind>   # 原始 audio / image / transcript
```

路径暗示类型；frontmatter 里 `template:` 字段精确指明。

### 2.2 默认模板（v0.1 出 6 个）

**Identity · Person · Project · Stance · Decision · Preference**

每个定义：必填字段 + 推荐字段 + 正文骨架（提示性 H2 标题）。模板本身也是 markdown，用户可 fork 改。Constraint / Skill / Routine / Reading 留 v0.2+。

### 2.3 Capture → 写盘 全流程

1. Capture（语音 / 文 / 图）
2. Transducer → 文本
3. 本地 LLM 做 3 件事：
   - **意图判断**：新事实 / 更新 / 提问 / 随想
   - **目标定位**：embedding 召回 top 3 候选卡
   - **patch 提案**：每张候选的 frontmatter / 正文 diff
4. 提案进 Staging Queue（不直接写盘）
5. 用户审：✓ 入档 / ✗ 丢弃 / ✎ 改后 ✓
6. 写盘 → git commit → SQLite index 增量

### 2.4 Staging Queue（inbox）

待审区 = SQLite 一张 `pending_proposals` 表。每条显示：原始输入 + 候选目标（≤3）+ 每张候选的 patch diff + ✓ / ✗ / ✎。未审 7 天后归档提醒。

**规则：所有 AI 写经 Staging；人手动写直接落盘。**

### 2.5 MCP 接口（v0.1 surface）

**读：**
- `get_context(topic, depth)` — 相关卡片片段拼成上下文
- `search(query, filters)` — embedding + frontmatter 联合检索
- `get_card(path)` — 明确取一张

**写（必经 Staging）：**
- `propose_update(card_path, patch, evidence)` — `evidence` 必填：model / conv_id / 摘录原文

### 2.6 审计 / 撤销

git 历史 = 天然审计日志（who / what / when / why）。GUI 触发 `git revert` 撤销。被拒提案也保留：下次 AI 提同一件事时能看到"这事曾被你 ✗，原因 X"，避免重提。

---

## Section 3: OSS / Pro + v0.1 范围 + 风险

### 3.1 OSS / Pro 具体分

**OSS（`mnesora`，AGPL v3 + CLA）：**
- 桌面 app（mac / win / linux）
- Card Store / Templates / Staging / git audit
- 本地 LLM 集成（Ollama / llama.cpp / MLX adapter）
- 本地 STT（whisper.cpp）+ 本地 embedding
- MCP server（read + propose_update）
- 配自己的云 API key（OpenAI / Anthropic / OpenRouter）
- 自托管 sync server（v0.2+）

**Pro（`mnesora-pro`，私仓，编译进生产 app）：**
- 我们托管的云模型 quota（不用配 key）
- 我们托管的 sync server（不用自托管）
- 高级云 STT / vision（Whisper Turbo / 多模态云模型）
- 模板市场（curator + 商城）
- 团队 / 共享卡片（v1+）
- 定期分析 / 周报 insight 推送

**移动 app**：代码 OSS，但分发走 App Store / Play Store 由我们做（密钥成本 + Apple 政策）；OSS 用户可以 build + TestFlight / sideload。

**架构含义**：OSS 必须留 clean extension points，Pro 通过插件 / adapter 接进来，**不改 OSS 代码**。这是分仓的硬约束。

### 3.2 v0.1 范围（3 个月）

**Ship：**
- macOS 桌面 app
- 6 默认模板
- 文本 + 语音 capture
- 本地 LLM（Qwen 2.5 / Llama 3.x 量化）
- 本地 STT（whisper.cpp）
- Card Store + Staging Queue
- MCP server（read + propose_update）
- 开源仓库可独立 build & 跑

**Defer：**
- Windows → v0.1.x
- 图像 capture → v0.2
- Sync → v0.2
- 移动 app → v0.3
- 云模型托管 → Pro v1
- 模板市场 → v1+
- 团队功能 → v1+

### 3.3 Top 3 风险

1. **本地 LLM 质量**：7-14B 量化模型做"意图判断 + patch 提案"能不能稳是产品质量硬瓶颈。
   - *Mitigation*：v0.1 做 eval harness，pin 模型版本，差的任务允许"换云"逃生通道。
   - *跟踪*：见 GitHub issue "Choose local LLM model + build eval harness"

2. **冷启动 onboarding**：选了 capture magic wedge，第一次打开档案是空的，capture 出来 AI 也"不知道关于谁"。
   - *Mitigation*：onboarding 引导填 Identity + 2-3 张 Person 卡 + 1 张 Project 卡，10 分钟内见到第一个 wow。可选"试试 demo 档案"。
   - *跟踪*：见 GitHub issue "Design onboarding flow for empty-state cold start"

3. **CLA 劝退贡献者**：AGPL + CLA 是商业化必需，但会把一部分社区贡献者推到无 CLA 的 fork。
   - *Mitigation*：CLA 用 DCO-lite 风格（一行 sign-off 替代签字），托管在 `cla.mnesora.dev`，5 秒过。
   - *跟踪*：见 GitHub issue "Set up DCO-lite CLA system"

### 3.4 开放问题（已迁移到 GitHub Issues）

| # | 问题 | GitHub issue 标题 |
|---|------|------|
| 1 | 本地 LLM 选哪个模型 + eval harness | Choose local LLM model + build eval harness |
| 2 | 是否要原生 SDK（Python / TS）| Decide on native SDKs (Python / TS) for agents |
| 3 | Sync 协议设计 | Sync protocol decision: CRDT vs git push/pull vs custom log |
| 4 | Onboarding 流程设计 | Design onboarding flow for empty-state cold start |
| 5 | CLA 系统搭建 | Set up DCO-lite CLA system |
| 6 | Plugin / extension point 架构 | Define plugin/extension architecture for OSS/Pro split |
| 7 | Mobile app 分发模式 | Decide mobile app distribution model |
| 8 | Apple notarization & code signing | Set up macOS code signing + notarization for v0.1 ship |

---

## Next Step

Hand off to `superpowers:writing-plans` skill to produce the implementation plan for v0.1 scope (Section 3.2).
