# Security

These skills are plain-text instructions plus a few shell scripts (`install.sh`, `scripts/`, `evals/trigger-test.sh`). None of them download or run compiled binaries on their own; the catalog's tool installers are opt-in (`--with-tools`) and flagged as such.

`production-readiness` is read-only by design: it never mutates platform settings and never prints secret values.

To report a problem, such as a skill instruction that could make an agent leak a secret, or an installer step that runs more than it says, open a private security advisory on this repository (Security tab, "Report a vulnerability") instead of a public issue.
