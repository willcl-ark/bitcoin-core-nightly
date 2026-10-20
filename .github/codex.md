# CI failure diagnosis

Add an OpenAI API key with API billing enabled as the repository Actions secret
`OPENAI_API_KEY`. The workflow uses `openai/codex-action@v1` with its default model.
See the [Codex action documentation](https://learn.chatgpt.com/docs/github-action).

After `nix.yml` opens a failure issue, it calls `codex.yml` directly. Issues
created using `GITHUB_TOKEN` do not trigger an `issues: opened` workflow.
Diagnosis runs for push, schedule, and manual builds, excluding pull requests
so PR-controlled workflows do not receive the API secret.

Codex reads the issue, completed failed-job logs, nightly configuration, and the
Bitcoin revision reported by the build matrix when available. It suggests a fix
and validation steps without implementing them. The agent runs in a read-only
sandbox with sudo removed, without network access or GitHub write permissions.
A separate job posts its final report to the failure issue.

Unavailable logs and missing source revisions limit the diagnosis. Cancellation
can prevent the follow-up jobs from running. Each diagnosis makes billable API
requests and has a 20-minute job timeout.
