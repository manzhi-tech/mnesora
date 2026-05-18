# Contributing to mnesora

Thanks for considering a contribution! mnesora is in pre-alpha and we welcome:

- Bug reports — use the "Bug report" issue template
- Feature requests — use the "Feature request" issue template
- Questions — use the "Question" issue template
- Code contributions — read below

## Before you start

Read the [design spec](docs/superpowers/specs/2026-05-18-mnesora-design.md) and the [v0.1 Roadmap](https://github.com/manzhi-tech/mnesora/issues/9). If your change is large or architectural, please open an issue first to discuss approach.

## License & sign-off

mnesora is licensed under [AGPL v3](LICENSE). Until our CLA system is live (see [issue #5](https://github.com/manzhi-tech/mnesora/issues/5)), please add a **DCO sign-off** to every commit:

```bash
git commit -s -m "your message"
```

This adds a `Signed-off-by: Your Name <your@email>` line to the commit, indicating you have the right to contribute the code under AGPL (per the [Developer Certificate of Origin](https://developercertificate.org/)).

Once the CLA system is live, contributors will sign a one-time CLA enabling future dual-licensing.

## Pull request flow

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Commit with sign-off: `git commit -s -m "..."`
4. Push: `git push origin feat/your-feature`
5. Open a PR — fill out the PR template
6. CI will run (when set up); fix any issues
7. Wait for review from a code owner

## Code style

To be defined per language as v0.1 implementation progresses. Currently:

- Markdown / docs: 80-char soft wrap, GFM
- Per-language style added as we pick stacks

## Reporting security issues

Please use [GitHub Security Advisories](https://github.com/manzhi-tech/mnesora/security/advisories/new) instead of opening a public issue.
