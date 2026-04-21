# Contributing to CUST/OS

Thanks for considering a contribution. This repository hosts the public CUST/OS community — issues, discussions, project planning — plus the default skill kit and starter configuration operators install alongside the plugin. There are a few different ways to contribute depending on what you want to do.

## Ways to contribute

- **Report a bug** — something broken in the shipped skills, configuration, or install script.
- **Propose a new skill** — an idea for a tool or workflow that would make CUST/OS more useful in the field.
- **Contribute a skill** — open a PR with a new skill directory or improvements to an existing one.
- **Improve a scratch / test** — add coverage or fix flaky tests in `scratches/`.
- **Improve the docs** — this repo's README, CONTRIBUTING, or install flow. Product documentation lives at [custos.nimbusxr.us/docs](https://custos.nimbusxr.us/docs).
- **Join a discussion** — use the Discussions tab for use cases, patterns, deployment stories, or questions that aren't a bug.

If you're unsure which category your contribution falls into, open an issue or a discussion first and we'll help you route it.

## Before you file

1. **Search existing issues and discussions.** Someone may have hit the same thing.
2. **Check the docs.** [custos.nimbusxr.us/docs](https://custos.nimbusxr.us/docs) is the authoritative reference for configuration keys, skill format, Lua API, and runtime behavior.
3. **Reproduce with the shipped `custos.yaml`** when possible, so we can separate "issue in the kit" from "issue in a local customization."

## Reporting bugs

Open an issue using the **Bug report** template. Include:

- Device and Android version
- ATAK-CIV version
- CUST/OS plugin version
- Which skill(s) or configuration triggered the bug
- What you expected vs. what happened
- A minimal reproduction (a chat message, a skill invocation, a config snippet) — the smaller the better
- Relevant `adb logcat` output if you have it

If the bug is in the CUST/OS plugin itself rather than a shipped skill, that's fine — this is the right place. We'll route it internally.

## Proposing and contributing skills

Skills are the most common form of contribution because they're self-contained and operator-authored.

### 1. Start with an issue

Use the **Skill idea** template. Describe:

- What the skill does from the operator's point of view
- What ATAK APIs or external services it needs
- Whether it would be runtime-critical (used by the framework) or example content

Discussing before implementing saves rework and helps catch scope or security issues early.

### 2. Author the skill locally

Skills live under `skills/custos.<name>/` with a `SKILL.md` and one or more `.lua` files. See the [skill authoring guide](https://custos.nimbusxr.us/docs) for the cookbook.

At minimum:

- `SKILL.md` with YAML frontmatter (`group`, `name`, `description`, `script_paths`, `tags`, `examples`)
- Each tool annotated with `@tool`, `@description`, `@tparam`, and an accurate `@impact` level
- A scratch test file under `scratches/` that exercises the tool — existence-check for high-impact tools, or a full invocation with cleanup for `PROCEDURAL` tools

### 3. Respect the runtime

- **Tool return shapes should be operator-useful**, not raw dumps. Distill collections into summaries the LLM can speak back to the operator in one sentence.
- **`@impact` levels should be accurate.** Under-declaring impact bypasses the approval gate; over-declaring creates friction. See the impact ladder at [custos.nimbusxr.us/docs](https://custos.nimbusxr.us/docs).
- **Don't call the LLM implicitly.** Automations and composed skill scripts should only invoke other tools via `tools.call(...)`. Use `tools.call("delegate", ...)` explicitly when LLM reasoning is needed.
- **File I/O stays inside `/sdcard/atak/custos/`** — the sandbox enforces this, but respect it in design too.

### 4. Test locally

```bash
./install.sh
# In ATAK, open the Editor, run your skill or the relevant scratch from /sdcard/atak/custos/scratch/
```

The scratch directory has a `run_all_tests.lua` that runs the full suite.

### 5. Open a PR

Use the PR template. Include:

- What the skill does and why
- Impact level justification for any `SIGNIFICANT+` tool
- Scratch test coverage (or an explicit note if the tool is existence-check only)
- Any external dependencies (API keys, external services, specific ATAK plugins)

Keep PRs focused — one skill per PR is easier to review than a bundle.

## Style and conventions

- **Lua style:** two-space indent, snake_case for functions and variables, `local` for everything that isn't intentionally global, descriptive names over clever ones.
- **SKILL.md `examples:` field:** write queries the way an operator would actually speak them, not formal descriptions. This is what the skill selector matches against.
- **Comments:** only where the *why* isn't obvious. Don't narrate what the code does.
- **LDoc annotations are required** for every tool, not optional. The loader reads them to build the tool schema the LLM sees.

## Security

Please don't report security issues in public issues or discussions. See [SECURITY.md](SECURITY.md) for the disclosure process.

## Licensing

By contributing to this repository you agree that your contributions will be licensed under the [MIT License](LICENSE), the same license this repository uses.

Note that the CUST/OS plugin itself (the Android APK and its source) is a separate project under its own proprietary license — this repo's open-source license covers the skill kit, scratches, configuration, and install tooling here.

## Code of conduct

Everyone interacting in this project — issues, discussions, PRs, or any other channel — is expected to follow the [Code of Conduct](CODE_OF_CONDUCT.md). Short version: be respectful, be constructive, assume good faith.

## Getting help

- **General questions, use cases, patterns:** use the Discussions tab.
- **Reference questions (config keys, Lua API, skill format):** [custos.nimbusxr.us/docs](https://custos.nimbusxr.us/docs) first, then Discussions if you don't find it.
- **Private / sensitive:** the email listed in [SECURITY.md](SECURITY.md).
