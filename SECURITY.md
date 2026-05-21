# Security Policy

## Reporting a vulnerability

This repository ships shell hooks and harness configuration that other projects
copy into their own tooling. If you find a security issue — an unsafe hook, a
command-injection vector in `assemble.sh`, a template that leaks secrets — please
report it privately:

- Open a [private security advisory](https://github.com/Camilool8/harness-engineering-templates/security/advisories/new), or
- Contact the repo owner (@Camilool8) directly.

Please do **not** open a public issue for a security vulnerability.

## Scope

In scope: `assemble.sh`, all hook scripts under `templates/**/hooks/`, the test
engine, and any template that could cause a consuming project to execute unsafe
code or expose credentials.

Out of scope: third-party MCP servers or tools that templates merely reference.

## Response

We aim to acknowledge a report within 7 days and to ship a fix or mitigation
before any public disclosure.
