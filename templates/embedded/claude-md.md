## Embedded / firmware rules

**Flashing is irreversible.** This is the highest blast-radius action in the
project — a bad write bricks the board. Never flash without one of:
- a `--dry-run` / `--simulate` pass that comes back clean, or
- explicit human approval (`FLASH_APPROVED=1`, or `[flash-approved]` in the
  command).
The `flash-guard` hook enforces this. Do not look for ways around it.

**Know your flash command.** `idf.py flash` writes silicon; `idf.py monitor`
only reads serial. Confusing them is a classic, costly mistake — be sure which
one the task actually needs.

**Rely on OTA rollback for recoverability.** Updates go through dual-bank OTA
(`ota_0` / `ota_1`) with SHA256 image verification, so a bad image rolls back
to the last good bank instead of bricking. Do not bypass the OTA path with a
raw single-image write.

**HIL is the verification.** A passing host build proves nothing about timing,
peripherals, or power. The discriminating signal is hardware-in-the-loop:
flash to a real board on the self-hosted runner, capture serial logs, pass/fail
on actual board behavior. Deterministic logic (protocol parsing, state
machines, HAL-mocked drivers) is the TDD surface; everything physical is HIL.
