## Pulumi

- Credentials: Pulumi ESC with dynamic logins (AWS/Azure/GCP/Doppler) is the
  GA OIDC pattern for module CI in 2026. Static cloud keys in module CI are
  an audit finding.
- CDKTF is archived (Dec 10 2025). Migrate via:
  `cdktf synth && pulumi convert --from terraform cdktf.out/stacks/<s>/cdk.tf`.
- `pulumi convert --from terraform` (early-2026 quality) handles `for_each`
  and dynamic blocks; it still struggles with `provider` aliases inside
  modules — review converted code for those.
- Run `pulumi preview` (not `up`) in CI; promote the preview file to apply.
