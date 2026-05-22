# DevOps — kubernetes-platform reference dossier

> Verified: 2026-05 · Refresh: re-verify version-sensitive notes each quarter.

## Current best practices

- **Argo CD and Flux are both GA-mature in 2026.** Pick Argo CD when you want a UI-first multi-tenant control plane; pick Flux when you want OCI-native gitless GitOps and tighter operator semantics. Flux 2.6 GA'd OCI artifacts (May 2025); Flux 2.8 (Feb 2026) added Cosign v3 verification.
- **Argo Rollouts is the default progressive-delivery layer.** `AnalysisTemplates` against Prometheus / Datadog / cloud-native metrics drive canary pass/fail/inconclusive thresholds; pair with Istio waypoints, Cilium, or NGINX-replacement Gateway API for traffic shaping.
- **Kyverno 1.13+ `ValidatingPolicy` generates upstream Kubernetes `ValidatingAdmissionPolicy`** — gives you Kyverno's HCL-like UX with in-tree CEL execution. Use Kyverno for K8s-native YAML/CEL policies; keep OPA Gatekeeper for cross-domain Rego policies (cloud + app + K8s).
- **For new clusters, default the CNI to Cilium and enable Hubble immediately.** Evaluate whether Cilium service mesh covers your needs before adding Istio. If you need full L7/mTLS-per-identity, Istio ambient mode (GA Nov 2024) avoids per-pod sidecars and is the upgrade path from sidecar Istio.
- **Use OCI-distributed manifests (Flux 2.6+ GA, or Argo CD Source Hydrator + GitOps Promoter) for tamper-evident promotion** between staging-next → staging → prod.

## Common gotchas / failure modes

- **Ingress NGINX retired Mar 24 2026** by SIG Network — no further releases. Production clusters must migrate to a Gateway API implementation (Envoy Gateway, Istio waypoints, Cilium Gateway, Kong).
- **Argo CD ApplicationSet cluster generators using `argocd.argoproj.io/auto-label-cluster-info`** now require the `argocd.argoproj.io/kubernetes-version` label in `vMajor.Minor.Patch` (not `Major.Minor`) after Argo CD 3.0 — silent generator no-ops until you notice.
- **Kyverno `generate` rules + Argo CD pruning fight each other** — Kyverno-generated child resources get pruned every reconcile unless explicitly excluded; AI-assisted policy generation makes this worse.
- **Argo Rollouts `AnalysisRun` against external metrics (Datadog/New Relic)** silently passes when the metric provider returns no data. Set `failureLimit` + `inconclusive` thresholds explicitly.
- **Sidecar-to-ambient Istio migration breaks any policy that referenced sidecar-injected ports** (15001/15006); waypoint proxies do not surface them.
- **Flux OCI artifacts with Cosign keyless verification fail offline-air-gapped clusters** without a configured custom Sigstore trusted root.

## Version-sensitive notes

- **Argo CD 3.0 GA in 2026** is a low-risk upgrade with minor breaking changes; the biggest break is the cluster-version label format (now `vMajor.Minor.Patch`). Argo CD 3.3 is the latest stable in mid-2026.
- **Flux 2.6 GA'd OCI artifacts (May 2025); 2.8 GA (Feb 2026) added Cosign v3 verification.** Older clusters on 2.5 cannot consume v3-signed artifacts.
- **Kubernetes 1.32 EOL Feb 28 2026.** 1.33 introduced in-place pod resize (beta) and sidecar `restartPolicy: Always` (stable). Endpoints API now warns on access.
- **Istio Ambient Multicluster is beta in 2026** (KubeCon EU); not yet recommended for prod multi-cluster east-west traffic.
- **Kubernetes v1.36 released Apr 22 2026** — 70 enhancements; review deprecation cadence before bumping.

## Cited links

- [Flux 2.6 GA blog — OCI Artifacts GA](https://fluxcd.io/blog/2025/05/flux-v2.6.0/) — canonical for the OCI-as-source-of-truth pivot.
- [Flux 2.8 GA blog (Feb 2026)](https://fluxcd.io/blog/2026/02/flux-v2.8.0/) — Cosign v3 verification.
- [Argo CD 2.14 → 3.0 upgrade docs](https://argo-cd.readthedocs.io/en/stable/operator-manual/upgrading/2.14-3.0/) — breaking-change checklist (cluster-version label format).
- [Argo CD 3.0 and the Future of Promotions (Platformers)](https://www.platformers.community/post/argo-cd-3-0-and-the-future-of-promotions) — Source Hydrator + GitOps Promoter PR-as-gate.
- [Argo Rollouts Analysis & Progressive Delivery docs](https://argo-rollouts.readthedocs.io/en/stable/features/analysis/) — primary AnalysisTemplate reference.
- [Kyverno ValidatingPolicy docs](https://kyverno.io/docs/policy-types/validating-policy/) — generating `ValidatingAdmissionPolicy` from Kyverno.
- [Istio Ambient + Multicluster + Inference Extension (CNCF, Mar 25 2026)](https://www.cncf.io/announcements/2026/03/25/istio-brings-future-ready-service-mesh-to-the-ai-era-with-new-ambient-multicluster-gateway-api-inference-extension-and-more/) — KubeCon EU announcement.
- [Kubernetes v1.36 release blog (Apr 22 2026)](https://kubernetes.io/blog/2026/04/22/kubernetes-v1-36-release/) — release-cadence reference.
