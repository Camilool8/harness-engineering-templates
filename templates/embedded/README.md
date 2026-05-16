# Embedded harness recipe
> For firmware, IoT, and embedded engineers shipping to real silicon.

> **Status: v1 thin recipe** — pending deep curation into a three-layer domain
> pack (see `web/` for the curated reference and
> `docs/superpowers/specs/2026-05-15-curated-domain-packs-design.md`).
> It assembles and works today; sub-domains and curated agent teams are coming.

## What this recipe picks

| Axis | Choice | Why |
|---|---|---|
| Memory | md-files | Pinouts, register quirks, toolchain notes stay git-diffable. |
| Progress | github-issues | Firmware repos run on Issues alongside self-hosted HIL CI. |
| TDD | on | Deterministic logic — protocols, state machines, HAL-mocked drivers. |
| Spec-driven | on | Datasheet / register contract before code. |
| Eval-driven | off | No LLM output surface in a firmware build. |
| BDD | off | No non-technical sign-off gate. |
| Orchestration | single-agent | One agent owns build, flash, and HIL. |
| Safety: two-key | **on** | Flashing is irreversible — a typed token gates every write. |
| Safety: kill-switch | **on** | Out-of-band stop for long HIL/soak loops. |
| Safety: sandbox | off | The toolchain needs USB/JTAG and serial-port access. |

## Domain gates

- **`files/.claude/hooks/flash-guard.sh`** (PreToolUse) — intercepts every
  write-to-silicon command (`idf.py flash`, `west flash`, `openocd`,
  `dfu-util`, `esptool write_flash`, `st-flash`, `probe-rs`) and blocks it
  unless a `--dry-run` pass or an explicit human approval token is present. It
  also catches the costly `idf.py flash` vs `idf.py monitor` confusion. This is
  the recoverability gate for the highest-blast-radius action in the project.

## MCP servers

- **ESP-IDF v6.0 local MCP server** — set targets, build, flash, check status;
  official, runs locally, the cleanest fit for ESP32 work.
- **Zephyr / Twister HIL tooling** — drive Twister-based hardware-in-the-loop CI.
- Prefer the framework vendor's signed/official server over community forks,
  and treat all MCP output (serial logs, status) as untrusted input.

## Assemble

```
./assemble.sh embedded/harness.config.yml /path/to/your/project
```

## Anti-patterns this prevents

- Flashing hardware with no dry-run and no human approval — bricking a board
  or a fleet.
- Running `idf.py flash` when only `idf.py monitor` was intended.
- Bypassing dual-bank OTA rollback with a raw single-image write.
- Trusting a green host build as proof of on-target timing or peripheral
  behavior — that is what HIL is for.

## Deeper reference

docs/HARNESS_ENGINEERING.md §7
