## Terraform / OpenTofu

- Test framework: prefer native `*.tftest.hcl` co-located with `*.tf` files.
  Reach for Terratest (Go) only when you need real cloud-API assertions.
- `command = apply` in a `*.tftest.hcl` against real providers bills real
  money — the `tftest-not-apply` hook (from `reusable-modules`) blocks it.
- OpenTofu 1.11.4 rejects `enabled` in local provider configs and tightens
  JSON state-encryption template interpolation — modules using these
  patterns fail `init`.
- Terragrunt + OpenTofu provider caching can silently use stale checksums
  if `.terraform.lock.hcl` is not committed per unit.
- Always pin module source `ref=` to a commit SHA or a signed tag; tags
  alone can be force-pushed.
