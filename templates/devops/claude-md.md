## DevOps / Platform rules

### The cardinal rule — propose, never apply

- The agent **never** runs `terraform apply` / `tofu apply` / `pulumi up` /
  `cdk deploy` / `terraform destroy` directly. It produces a plan and a diff;
  a **human or CI** applies it. The `plan-before-apply` hook enforces this.
- The agent **never** mutates a live cluster. `kubectl apply` against prod, and
  every destructive verb, is gated by the `kubectl-context-guard` hook.

### GitOps means write to Git, not the cluster

- Infra and Kubernetes changes are committed to Git as a PR. Argo CD / Flux
  reconciles; a canary is promoted by an Argo analysis run, never by an
  agent-issued `kubectl` or `rollouts promote`.

### Credentials

- **OIDC over static keys, always.** Never write `AWS_ACCESS_KEY_ID`,
  `AZURE_CLIENT_SECRET`, or any long-lived secret into a workflow or `.tf`
  file. Use `id-token: write` + `configure-aws-credentials` (or the cloud
  equivalent) for short-lived, role-assumed credentials.
- Pin reusable workflows and actions to a commit SHA, never `@main`.

### Never do

- Never rubber-stamp a stale plan — a plan over 15 minutes old is a different
  reality.
- Never autonomously remediate drift — drift may be intentional. Surface and
  explain it; do not heal it.
- Never run `--dangerously-skip-permissions` outside an isolated sandbox.
