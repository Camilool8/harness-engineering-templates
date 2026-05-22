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
