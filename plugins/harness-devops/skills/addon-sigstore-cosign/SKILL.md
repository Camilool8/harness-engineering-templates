---
name: devops-addon-sigstore-cosign
description: Sigstore Cosign conventions — keyless OIDC signing with no long-lived keys, mandatory Rekor transparency-log inclusion verification (the cosign-tlog-required hook refuses --insecure-ignore-tlog), the SLSA L3 GitHub path, and multi-arch index-vs-manifest signing. Use when signing or verifying artifacts.
---

## Sigstore Cosign

- Keyless signing via OIDC: `cosign sign --identity-token <oidc>`. No
  long-lived keys.
- Verify Rekor transparency-log inclusion on every check. The
  `cosign-tlog-required` hook (domain-shared) refuses
  `--insecure-ignore-tlog`.
- SLSA L3 path on GitHub: `actions/attest-build-provenance@v2` →
  cosign signature → Rekor inclusion verify. What was a multi-week
  project in 2024 is now an afternoon.
- Multi-arch images: sign the INDEX, but verifiers often check the
  manifest digest. Either sign both, or attach the attestation to the
  index digest specifically.
