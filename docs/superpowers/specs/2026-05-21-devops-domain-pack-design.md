# DevOps Domain Pack — Design

> Status: ⏳ Pending implementation.
> Date: 2026-05-21.
> Curates the `devops` thin recipe into a three-layer **domain pack**, second
> after `web/`. Companion to `docs/HARNESS_ENGINEERING.md` §3,
> `docs/AGENT_ROLES.md`, and the master design
> `docs/superpowers/specs/2026-05-15-curated-domain-packs-design.md` (which
> defines the pack mechanics this design reuses verbatim).

## 1. Context & motivation

The maintainer roadmap in the master design lists devops as the next domain to
curate (`data → devops → mobile → finance → security → game → embedded →
scientific → content → ops`). The current `templates/devops/` is a working v1
thin recipe — a pre-filled `harness.config.yml`, a `claude-md.md` snippet, and
two hooks (`plan-before-apply.sh`, `kubectl-context-guard.sh`). It assembles and
prevents the obvious anti-patterns, but it has no sub-domain specificity, no
curated agent team, no dated dossier, and no per-cloud or per-CI specialization.

DevOps as a domain spans wider orthogonal axes than web (cloud × IaC tool ×
workflow shape × CI platform × K8s engine × observability vendor). A flat recipe
cannot encode all of these — it picks one default and pretends the others do not
exist. This design partitions the domain by **deliverable shape** at the
sub-domain level and pushes every other axis (cloud, IaC tool, CI platform,
GitOps engine) into composable addons.

Three 2026 forcing functions shape the gate set:

- **Trivy supply-chain compromise (March 2026, two waves)** — even "trusted"
  scanner vendors are part of the attack surface. Default IaC scanner shifts to
  Checkov; image scanner shifts to Grype+Syft; module artifacts get Cosign-signed.
- **Agent-in-CI prompt-injection attack class** (CSA research note, May 3 2026;
  Aikido "Comment and Control", Apr 2026) — Copilot Coding Agent, Gemini CLI,
  Claude Code, Codex, and GitHub AI Inference can all be hijacked by a single
  malicious PR comment to exfiltrate tokens. Read-only `GITHUB_TOKEN` is
  necessary but not sufficient. New hook required.
- **EU AI Act enforcement (August 2 2026)** — Article 12 makes audit-logging
  of agent-issued commands a regulatory obligation. The harness must default to
  attributable agent identity and time-bound credentials.

## 2. Decisions locked in brainstorming

| Question | Decision |
|---|---|
| Sub-domain count | **Four** (`infrastructure`, `kubernetes-platform`, `cicd-platform`, `observability-sre`). |
| Should IaC modules and cloud environments be separate sub-domains? | **No** — collapse into one `infrastructure` sub-domain; workflow shape (publish-modules vs operate-envs) is selected by addon. (User direction.) |
| Cloud providers as sub-domains? | **No** — one addon per big cloud (`aws`, `azure`, `gcp`); cloud cuts across `infrastructure`, `kubernetes-platform`, and `cicd-platform`. (User direction.) |
| CI platforms shipped in v1? | **Three**: `github-actions`, `azure-devops`, `gitlab-ci`. (User direction.) |
| Incident response as a sub-domain? | **No** — it is an *activity* every devops sub-domain performs; lives as a shared `incident-commander` agent + two-key hook + runbook-as-skill loader. Mirrors how UI/UX is shared across web sub-domains. |
| Addons may contribute agents? | **Yes** — the existing module-shaped `_addons/<addon>/files/` tree already mechanically supports `agents/`; this design formalises the pattern (`reusable-modules` ships `contract-tester`; `multi-env-state` ships `drift-surfacer`; `argo-cd` ships `gitops-promoter`; `kyverno` ships `policy-author`). |
| Backward compatibility for the v1 thin `devops/harness.config.yml`? | Delete it after the sub-domain configs land — same approach `web/` migration took. Anyone pinning the old path gets a clear failure. |

## 3. Architecture — the devops pack

The master design's three-layer shape and `assemble.sh` v2 mechanics are reused
unchanged. The devops layout follows the web template:

```
templates/devops/                          DOMAIN PACK
  DOMAIN.md                index + sub-domain decision guide
  references.md            curated dossier — Verified: 2026-05, cited links
  domain.claude-md.md      shared devops rules (cardinal rule, GitOps, OIDC)
  files/
    .mcp.json.fragment     (auto-merged — devops MCP defaults)
    .claude/
      context7.mcp.json.fragment   (merged only if docs.context7_mcp: true)
      agents/              shared devops agents
      hooks/               shared devops hooks (plan-before-apply, etc.)
      settings.fragment.json
  _addons/<addon>/         15 addons — each module-shaped
  <sub-domain>/                          THE ASSEMBLE UNIT
    SUBDOMAIN.md
    harness.config.yml
    references.md
    claude-md.md
    files/.claude/{agents,hooks,settings.fragment.json}
```

No changes to `_base/`, `_modules/`, the `harness.config.yml` schema, or
`assemble.sh`. The pack reuses every mechanic the web pack already exercises.

## 4. Sub-domains — partitioned by deliverable shape

| Sub-domain | Ships | Distinct harness because |
|---|---|---|
| **infrastructure** | Cloud resources provisioned/managed via IaC — reusable modules and/or operated environments | Universal IaC gates: plan-before-apply (≤15-min plan freshness), OIDC-only credentials, no autonomous drift remediation. Per-cloud and per-workflow specifics arrive via addons. |
| **kubernetes-platform** | A cluster (or fleet) + GitOps engine + platform addons + paved-path manifests for app teams | `kubectl`-context-guard with nuclear-pattern deny; manifest validation pipeline (kubeconform → kube-linter → Kyverno); the GitOps cardinal rule (write to Git, not the cluster); Argo Rollouts `AnalysisRun` decides promotion. |
| **cicd-platform** | Reusable workflows / pipeline templates / release engineering / supply-chain attestations | OIDC mandate, 40-char SHA-pinning for every `uses:`/`include:` (post-Trivy lesson), SLSA L3 via `actions/attest-build-provenance` v2 + Cosign keyless + Rekor inclusion verify, **agent-in-CI prompt-injection guard** (new 2026). |
| **observability-sre** | Telemetry collection, dashboards, alert rules, SLOs / error budgets, on-call automation | MCP-as-telemetry-interface (Datadog/Honeycomb/NR/Sentry/PagerDuty MCPs all GA in 2026), SLOs-as-code (Pyrra/Sloth) compiled to multi-window multi-burn-rate alerts, typed-token wrapper for any MCP `trigger_incident` call. |

**Explicitly NOT a sub-domain:**

- *Incident response* — activity, not deliverable; shared agent + hook + skill.
- *Supply-chain audit* — activity; shared agent + cross-cutting hook.
- *Container build* — concern of `cicd-platform`; addons handle Bazel/`rules_oci`
  specifics in a follow-up cycle.
- *Cloud provider* — addon, not sub-domain (cuts across multiple sub-domains).
- *Service mesh* — addon of `kubernetes-platform` (deferred to follow-up).

## 5. Addons — 15 in the initial set

Bigger initial set than web's 7 because DevOps has more orthogonal axes. Each
addon is module-shaped (`_addons/<addon>/MODULE.md`, `claude-md.md`, `files/`,
optional `settings.fragment.json`, optional `.mcp.json.fragment`).

### 5.1 Cloud (3) — one per big cloud

| Addon | Pairs with | Contributes |
|---|---|---|
| `aws` | `infrastructure`, `kubernetes-platform`, `cicd-platform` | AWS-specific claude-md (STS sessions ≤15 min, AFT/Control Tower bootstrap pattern, IRSA / Pod Identity); AWS Agent Toolkit MCP wiring; EKS Kubernetes-version-EOL check (1.32 EOL Feb 28 2026). |
| `azure` | same | Azure-specific claude-md (WIF GA-default for new service connections; Bicep deployment notes); Azure MCP Server wiring; AKS context-guard notes. |
| `gcp` | same | GCP-specific claude-md (Workload Identity Federation defaults; GitLab issuer support GA in 2026); Cloud Build OIDC pattern; GKE context-guard notes. |

### 5.2 IaC tooling (2)

| Addon | Pairs with | Contributes |
|---|---|---|
| `terraform` | `infrastructure` | Covers Terraform + OpenTofu (shared surface); `.tftest.hcl` first, Terratest only for cloud-API e2e; OpenTofu 1.11.4 `enabled`-in-local-provider init-break note; provider-cache pitfall with Terragrunt. |
| `pulumi` | `infrastructure` | Pulumi ESC dynamic credentials as the default OIDC pattern; `pulumi convert --from terraform` migration recipe (CDKTF archived Dec 10 2025). |

### 5.3 Workflow-shape (2) — the differentiation the user asked for

| Addon | Pairs with | Contributes |
|---|---|---|
| `reusable-modules` | `infrastructure` | Semver-publish gates; Cosign-sign module artifacts before publish (Trivy-tag-rewrite lesson); `contract-tester` agent (native `tftest` + selective Terratest); `tftest-not-apply.sh` hook (block `*.tftest.hcl` with `command = apply` against non-mock providers). |
| `multi-env-state` | `infrastructure` | Per-env state isolation; two-key on prod-tagged accounts; `cost-gate.sh` hook (Infracost+OPA on plan JSON); `drift-surfacer` agent (`tofu plan -refresh-only` read-only — **never** autonomous remediation). |

### 5.4 CI/CD (3)

| Addon | Pairs with | Contributes |
|---|---|---|
| `github-actions` | `cicd-platform`, any | `oidc-only.sh`, `sha-pin-actions.sh`, `agent-in-ci-guard.sh` hooks; `job_workflow_ref` claim enforcement in cloud trust policies; `actions/attest-build-provenance` v2 recipes. |
| `azure-devops` | `cicd-platform`, any | WIF-GA defaults claude-md (WIF GA + on-by-default for new service connections in 2026; legacy SPN-with-secret deprecation note); `oidc-only.sh` (Azure variant; blocks static-SPN secrets); `agent-in-ci-guard.sh` (Azure variant). |
| `gitlab-ci` | `cicd-platform`, any | GitLab ID-tokens (JWT) claude-md with AWS/Azure/GCP recipes; `include:project` SHA-pinning hook; `agent-in-ci-guard.sh` (GitLab variant; checks `job-token` scope + protected-branch enforcement). |

### 5.5 Kubernetes (2)

| Addon | Pairs with | Contributes |
|---|---|---|
| `argo-cd` | `kubernetes-platform` | Argo CD 3.0 ApplicationSet cluster-version label format break (`vMajor.Minor.Patch`, not `Major.Minor`); Source Hydrator + GitOps Promoter PR-as-promotion-gate; `gitops-promoter` agent. |
| `kyverno` | `kubernetes-platform` | Kyverno 1.13+ `ValidatingPolicy` compiles to in-tree `ValidatingAdmissionPolicy`; `policy-author` agent; `manifest-validate.sh` PostToolUse hook (kubeconform → kube-linter → Kyverno on `*.yaml` writes). |

### 5.6 Observability (2)

| Addon | Pairs with | Contributes |
|---|---|---|
| `opentelemetry` | `observability-sre`, any | OTel Collector pipeline-validate in CI (`otelcol validate`); Semantic Conventions 1.41 pin; pipeline-misroute gotcha (logs-pipeline → metrics-only exporter silently drops data). |
| `datadog` | `observability-sre` | Datadog MCP wiring (GA March 9 2026, remote-hosted, 16+ core tools + 6 toolsets); per-tenant MCP rate-limit cap (no built-in cost guardrail). |

### 5.7 Supply chain (1)

| Addon | Pairs with | Contributes |
|---|---|---|
| `sigstore-cosign` | `cicd-platform`, `infrastructure` (via `reusable-modules`) | SLSA L3 keyless via OIDC; `cosign-tlog-required.sh` hook (refuses `--insecure-ignore-tlog`); Rekor inclusion verify in CI; multi-arch index-vs-manifest digest pitfall note. |

### 5.8 Deferred to follow-up cycles (named, not built in v1)

`opentofu` (only if surface diverges from terraform), `flux`, `opa-gatekeeper`,
`argo-rollouts`, `bazel-rules-oci`, `honeycomb`, `new-relic`, `sentry-mcp`,
`pagerduty-mcp`, `istio-ambient`, `cilium`, `infracost-opa`, `backstage-templates`.

## 6. Agent teams

All agents obey the four `AGENT_ROLES.md` invariants: least-privilege tools
(architects/auditors read-only; only implementers get `Edit/Write/Bash`,
scope-bounded), model routing, typed return contracts, and
evaluators-in-a-different-family.

### 6.1 Shared devops agents (`devops/files/.claude/agents/`)

Installed with any devops sub-domain — devops equivalent of web's
`design-critic` / `accessibility-auditor` / `web-perf-auditor`.

- **`incident-commander`** — read-only; orchestrates the Komodor war-room model;
  dispatches specialist sub-agents per K8s/network/database/affected-app domain;
  routes high-risk actions to a typed-token confirmation card; never sends
  Slack/PagerDuty messages directly. Model: opus.
- **`supply-chain-auditor`** — read-only; verifies SBOM (CycloneDX 1.7 / SPDX
  3.0.1) + Cosign signature + Rekor inclusion + SLSA build-provenance
  attestation; refuses `--insecure-ignore-tlog`; flags Trivy versions in the
  March 2026 compromise window. Model: sonnet.
- **`cost-auditor`** — read-only; runs Infracost against plan JSON; OPA policy
  verdict; PASS/CHANGES-REQUESTED with measured-vs-budget. Model: haiku.

### 6.2 Per sub-domain rosters

| Sub-domain | Specialists shipped by sub-domain | Specialists contributed by addons | Shared agents installed |
|---|---|---|---|
| `infrastructure` | `infra-architect`, `infra-implementer` | `contract-tester` ← `reusable-modules`; `drift-surfacer` ← `multi-env-state` | all 3 |
| `kubernetes-platform` | `k8s-architect`, `manifest-implementer` | `gitops-promoter` ← `argo-cd`; `policy-author` ← `kyverno` | `incident-commander`, `cost-auditor` |
| `cicd-platform` | `pipeline-architect`, `workflow-implementer`, `release-engineer` | — | `supply-chain-auditor`, `incident-commander` |
| `observability-sre` | `slo-architect`, `telemetry-implementer`, `alert-curator`, `log-triage`, `trace-analyzer` | — | `incident-commander` |

**Model routing** (master design's defaults):

| Role | Model |
|---|---|
| Architects (`infra-architect`, `k8s-architect`, `pipeline-architect`, `slo-architect`) | opus |
| Implementers (`infra-implementer`, `manifest-implementer`, `workflow-implementer`, `telemetry-implementer`) | sonnet |
| Specialists with structured returns (`gitops-promoter`, `policy-author`, `contract-tester`, `release-engineer`, `alert-curator`) | sonnet |
| Triage/diff agents (`drift-surfacer`, `log-triage`, `trace-analyzer`) | haiku |

**Bounded behaviour worth calling out:**

- `drift-surfacer` explains drift but **never** remediates (autonomous drift
  remediation is an anti-pattern per HE §3.9).
- `gitops-promoter` writes only to Git, never to the cluster (GitOps cardinal
  rule per HE §3.8).
- `manifest-implementer` is bounded to a single namespace per invocation.
- `release-engineer` may not promote across environment boundaries without a
  typed-token confirmation.
- `log-triage` / `trace-analyzer` pre-summarise; verbose telemetry stays in
  their context (sub-agent isolation per HE §3.6).

### 6.3 Addon-contributes-agents pattern (formalised)

The master design says `_addons/<addon>/files/` is module-shaped and copied
verbatim. This means addons may ship `files/.claude/agents/*.md` already — no
new `assemble.sh` mechanic is required. This design **documents** the pattern
so addon authors know it is supported and intentional, and so
`docs/AGENT_ROLES.md` can reference it as the standard way addons specialise a
sub-domain.

## 7. Hooks

### 7.1 Domain-shared (`devops/files/.claude/hooks/`)

Installed with every devops sub-domain. Two are promoted from the current thin
recipe; one is new for 2026.

- **`plan-before-apply.sh`** *(promoted)* — PreToolUse on `Bash`. Blocks
  `terraform|tofu apply`, `pulumi up`, `cdk deploy`, `az deployment ... create`
  unless a plan file produced within the last 15 minutes exists; unconditionally
  blocks any apply/destroy that touches a protected resource type. Exit 2.
- **`kubectl-context-guard.sh`** *(promoted)* — PreToolUse on `Bash`. Parses
  `kubectl`/`helm`/`k`; reads current context; on prod-pattern contexts blocks
  `delete`, `drain`, `cordon`, scale-to-zero, and `apply`/`replace`/`create`
  without `--dry-run=server`. Nuclear patterns (`delete namespace`, `delete pvc`,
  `delete pv`, `delete crd`, `--all`) blocked unconditionally on prod. Exit 2.
- **`cosign-tlog-required.sh`** *(new)* — PreToolUse on `Bash` matching
  `cosign\s+(sign|verify|attest)`. Refuses `--insecure-ignore-tlog`. Exit 2.

### 7.2 Addon-shipped hooks

Hook filenames are **platform-prefixed** (`gha-*`, `ado-*`, `gitlab-*`) so a
project that legitimately uses two CI systems can install both addons without
collision in `.claude/hooks/`.

| Addon | Hook | Cadence | Behaviour |
|---|---|---|---|
| `github-actions` | `gha-oidc-only.sh` | PreToolUse `Write\|Edit` on `**/.github/workflows/**` | Blocks introduction of `AWS_ACCESS_KEY_ID`, `AZURE_CLIENT_SECRET`, GCP key JSON, or `aws_secret_access_key` references. |
| `github-actions` | `gha-sha-pin-actions.sh` | PreToolUse `Write\|Edit` on workflow files | Blocks any `uses:` reference without a 40-char hex SHA. (Trivy attacker force-pushed 76/77 version tags; Dependabot did not catch it.) |
| `github-actions` | `gha-agent-in-ci-guard.sh` | PreToolUse `Write\|Edit` on workflow files | If file invokes `anthropic/claude-code-action`, `github/copilot-cli`, `gemini-cli`, or `openai/codex`, require `permissions: { contents: read }` only and OIDC for any state-mutating step. Exit 2. |
| `azure-devops` | `ado-oidc-only.sh` | PreToolUse `Write\|Edit` on `**/azure-pipelines.yml`, `**/azure-pipelines/*.yml` | Blocks static SPN secrets; requires WIF service-connection reference. |
| `azure-devops` | `ado-sha-pin-templates.sh` | PreToolUse `Write\|Edit` on Azure pipeline files | Blocks `template:` references that resolve to another repo without a 40-char SHA `ref:` pin. |
| `azure-devops` | `ado-agent-in-ci-guard.sh` | PreToolUse `Write\|Edit` on Azure pipeline files | Same agent-detection logic as the GH variant, scoped to Azure step references. |
| `gitlab-ci` | `gitlab-oidc-only.sh` | PreToolUse `Write\|Edit` on `**/.gitlab-ci.yml`, `**/.gitlab/ci/**` | Blocks introduction of static cloud secrets in `variables:` or `secrets:`; requires `id_tokens:` reference. |
| `gitlab-ci` | `gitlab-sha-pin-includes.sh` | PreToolUse `Write\|Edit` on GitLab CI files | Blocks `include:project` / `include:remote` references without a 40-char SHA `ref:`. |
| `gitlab-ci` | `gitlab-agent-in-ci-guard.sh` | PreToolUse `Write\|Edit` on GitLab CI files | Checks `job-token` scope, protected-branch enforcement, same agent-detection logic. |
| `kyverno` | `manifest-validate.sh` | PostToolUse `Write\|Edit` on `**/*.yaml` under K8s manifest paths | Runs kubeconform → kube-linter → Kyverno in sequence on a 10 s budget; non-zero verdict blocks "done". |
| `multi-env-state` | `cost-gate.sh` | PostToolUse on `Bash` matching `terraform\|tofu plan` | Runs `infracost diff` against plan JSON; OPA verdict; blocks if monthly delta > env threshold. |
| `multi-env-state` | `prod-typed-token.sh` | PreToolUse on `Bash` against accounts tagged `env:prod` or `blast-radius:nuclear` | Requires typed `CONFIRM <last-4-of-resource-id>` token; single `y` insufficient. |
| `reusable-modules` | `tftest-not-apply.sh` | PreToolUse `Write\|Edit` on `**/*.tftest.hcl` | Blocks `command = apply` against non-mock providers (real-cloud bills from AI-generated test files). |

All hooks use `bash -n` syntax-clean exit-2 patterns so they survive
`--dangerously-skip-permissions` (HE §3.9 invariant).

## 8. Dossier model

Same fixed shape as web. The research dossier produced during brainstorming
(2026-05-21, ~3000 words, 30+ cited links) is distributed across:

- `devops/references.md` — cross-cutting threads (supply-chain posture, OIDC
  state-of-the-art, agent-in-CI prompt injection, two-key patterns, MCP
  inventory, EU AI Act timeline).
- `devops/infrastructure/references.md` — Terraform/OpenTofu/Pulumi specifics,
  CDKTF migration, AFT, WIF claim hardening.
- `devops/kubernetes-platform/references.md` — Argo CD 3.0 / Flux 2.8, Kyverno
  ValidatingPolicy, Ingress NGINX retirement (Mar 24 2026), Istio Ambient,
  EKS/AKS/GKE version EOLs.
- `devops/cicd-platform/references.md` — Trivy compromise, SHA-pinning policy
  GA, SLSA L3 keyless, CycloneDX 1.7 / SPDX 3.0.1, agent-in-CI attack class.
- `devops/observability-sre/references.md` — Datadog / Honeycomb / NR / Sentry /
  PagerDuty MCP inventory, Pyrra/Sloth, OTel Collector breaking changes.

Each file:
- Has the `Verified: 2026-05 · Refresh: re-verify version-sensitive notes each
  quarter.` header.
- Follows the fixed `Current best practices / Common gotchas / Version-sensitive
  notes / Cited links` shape.
- Has ≥5 cited links, each annotated with what the link is good for.

Context7 is wired via `devops/files/.claude/context7.mcp.json.fragment` exactly
as `web/` does, with the same shared rule: *`references.md` is the curated
baseline; for exact current library/framework API syntax, query Context7
(`resolve-library-id` then `query-docs`).*

## 9. Migration

In order (each step a separate commit; behind a feature flag is not necessary
because v1 thin recipes and pack recipes coexist by directory shape):

1. Create `devops/DOMAIN.md`, `devops/domain.claude-md.md`,
   `devops/references.md`, `devops/files/` skeleton (alongside existing thin
   recipe — both shapes assemble).
2. Migrate `devops/files/.claude/hooks/plan-before-apply.sh` and
   `kubectl-context-guard.sh` from the thin recipe location to the shared
   domain location. Add `cosign-tlog-required.sh`.
3. Build the 3 shared devops agents.
4. Build each sub-domain (`SUBDOMAIN.md`, `harness.config.yml`, `references.md`,
   `claude-md.md`, `files/.claude/`, specialists). One sub-domain per commit.
5. Build each addon (`MODULE.md`, `claude-md.md`, `files/`, optional
   `settings.fragment.json` / `.mcp.json.fragment` / `agents/`). Group commits
   by addon family (cloud / IaC / workflow-shape / CI / K8s / observability /
   supply chain).
6. Update `templates/tests/run.sh` to add `assert_assembles` for each new
   sub-domain config and at least one representative addon combination per
   sub-domain.
7. Update `docs/reference/domains.md` — flip the `devops` row to "curated
   (3-layer)"; add a devops sub-domain table mirroring web's; remove devops
   from the v1 thin recipe list.
8. Update `docs/how-to/pick-a-recipe.md` — point devops at the sub-domain
   decision guide instead of the flat recipe.
9. **Final task:** delete `templates/devops/harness.config.yml` (the v1 thin
   manifest) and `templates/devops/claude-md.md`. Remove the corresponding
   `assert_assembles` line in `tests/run.sh`. Same approach the `web/`
   migration took.

Backward compatibility throughout steps 1–8: both shapes assemble; the test
runner exercises both; nothing breaks for users until step 9.

## 10. Scope of the first implementation

**In scope:**

1. The complete devops domain pack: 4 sub-domains, 15 addons, all agent teams,
   domain + 4 sub-domain dossiers, Context7 wiring, all hooks listed in §7.
2. Migration of the current thin recipe assets into the pack (steps 1–2 of §9).
3. Test-runner extension for the new sub-domain configs and a representative
   addon combination per sub-domain.
4. Documentation updates in `docs/reference/domains.md` and
   `docs/how-to/pick-a-recipe.md`.
5. Deletion of the v1 thin recipe as the final commit.

**Out of scope (future cycles):**

- The 13 deferred addons named in §5.8.
- Curating any of the other 10 thin recipes (`data`, `finance`, `mobile`, …).
- Building per-cloud MCP server *implementations* — the addons wire the
  vendor's official MCP server config; they do not author MCP servers.
- Writing a public maintainer how-to about curating thin recipes (this remains
  internal maintainer work per repo stance).

## 11. Success criteria / verification

- `assemble.sh` produces a valid harness for each of the 4 devops sub-domains.
- A representative addon combination per sub-domain assembles cleanly:
  - `infrastructure` + `terraform` + `aws` + `multi-env-state` + `github-actions`
  - `infrastructure` + `pulumi` + `azure` + `reusable-modules` + `sigstore-cosign`
  - `kubernetes-platform` + `argo-cd` + `kyverno` + `aws`
  - `cicd-platform` + `github-actions` + `sigstore-cosign`
  - `cicd-platform` + `azure-devops` + `sigstore-cosign`
  - `cicd-platform` + `gitlab-ci` + `sigstore-cosign`
  - `observability-sre` + `opentelemetry` + `datadog`
- `settings.json` and `.mcp.json` are valid JSON with base + module + domain +
  addon entries all merged (no fragments lost; no leftover `*.fragment.json`).
- Backward compatibility: every previously-passing thin recipe still assembles
  in the test runner — until the final step deletes the devops thin recipe.
- Every agent `.md` has valid frontmatter and least-privilege `tools` (no
  architect/auditor with `Edit`/`Write`/unrestricted `Bash`).
- Every `references.md` has a `Verified:` header and ≥5 cited links each
  annotated with what the link is good for.
- All hooks pass `bash -n`; all JSON/JSONL valid.
- The agent-in-CI-guard hook in all three CI addons (`gha-`, `ado-`,
  `gitlab-agent-in-ci-guard.sh`) triggers on a fixture workflow that invokes
  `anthropic/claude-code-action` without read-only token scope.

## 12. Risks & open questions

- **Stacked `CLAUDE.md` length.** A loaded combination — base + modules +
  `devops/domain.claude-md.md` + `infrastructure/claude-md.md` + 5 addons —
  could push CLAUDE.md past the 200-line compliance threshold. Mitigation:
  ruthlessly prune every snippet; cap each addon claude-md at 15 lines; cap
  domain.claude-md and sub-domain claude-md at 30 lines.
- **Addon file-name collisions are unvalidated.** Nothing prevents two addons
  contributing the same-named agent, hook, or skill file; assemble would copy
  whichever is layered last. Mitigations adopted in this design: hook filenames
  in CI addons are platform-prefixed (`gha-*`, `ado-*`, `gitlab-*`); addon
  authors generally must use unique agent and hook names. Accepted as a known
  limitation; documented in `docs/AGENT_ROLES.md` when this design is
  implemented.
- **Agent-in-CI-guard hooks may produce false positives** if a user legitimately
  wants their CI agent to write commits or open PRs. The hooks detect the
  agent invocation and demand read-only token scope by default; users override
  by removing the hook from `settings.fragment.json` per-sub-domain. Accepted;
  documented in each CI addon's `MODULE.md`.
- **MCP-server availability assumed.** The `datadog`, `aws`, and `azure`
  addons wire vendor MCPs that require the user's own tenant/credentials. The
  addon installs the MCP config but cannot validate the user has access.
  Documented in each addon's `MODULE.md`.
- **Cloud-version EOL drift.** `aws` ships an EKS-version note pinning
  1.32-EOL Feb 28 2026; this drifts. The dossier's quarterly refresh policy
  catches this; addon `MODULE.md` calls out which facts are version-sensitive.

## 13. Related documents

- `docs/superpowers/specs/2026-05-15-curated-domain-packs-design.md` — master
  design defining pack mechanics; this design reuses every mechanic unchanged.
- `docs/superpowers/plans/2026-05-15-curated-domain-packs.md` — completed web
  implementation plan; the devops implementation plan will mirror its phase
  structure.
- `docs/HARNESS_ENGINEERING.md` §3 — substantive DevOps doctrine; the
  authoritative source for cardinal rules, gates, and anti-patterns referenced
  throughout this design.
- `docs/AGENT_ROLES.md` — agent-invariants reference; addons-contribute-agents
  pattern should be added here when this design is implemented.
- `docs/reference/domains.md` — domain catalog; the devops row flips to
  "curated (3-layer)" as part of this implementation.
