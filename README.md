# CUST/OS

**/kuh-stohs/** · The Agentic Custom Operator's System

The home for CUST/OS — issues, discussions, project tracking, and the default skill kit operators install on a device.

Full product documentation lives at **[custos.nimbusxr.us/docs](https://custos.nimbusxr.us/docs)**.

---

## What this repo is for

This repository is the CUST/OS public hub. Three things happen here:

- **Issues** — bug reports, feature requests, and questions about CUST/OS. Please search before filing.
- **Discussions** — operator and author discussion: use cases, skill patterns, deployment stories.
- **Project** — roadmap and release tracking.

It also contains the default skill kit and starter configuration operators deploy alongside the plugin:

```
custos/
├── custos.yaml         # Starter config — providers, agents, sandbox, security
├── skills/             # 44 skill directories (SKILL.md + .lua files)
├── scratches/          # 87 skill tests + run_all_tests.lua (pushed to /sdcard/atak/custos/scratch/)
├── models/             # On-device model weights — operators download here (see models/README.md)
└── install.sh          # One-command push of config + skills + scratches + models
```

Runtime-critical skills (don't delete unless you know what you're doing): `custos.skill_creator`, `custos.agents`, `custos.automation`, `custos.helpers`, `custos.memory`, `custos.rag`. Everything else is example content — copy, modify, or replace freely.

## Prerequisites

Before installing, you need:

1. An Android device (or emulator) with a supported version of **ATAK-CIV** installed.
2. The **CUST/OS plugin APK** installed on the device.
3. `adb` on your workstation, with the device connected and authorized (`adb devices` shows it).
4. **On-device model weights** downloaded into `models/` in this repo. The shipped `custos.yaml` enables three on-device providers out of the box (Gemma 4 E2B-it chat, Nomic embed, Whisper tiny). Each needs a specific weights file — **see [`models/README.md`](models/README.md) for download links, filename requirements, and how to swap in different models**.

   `install.sh` pushes whatever is in `models/` to the device automatically, so the normal flow is: download the three files into `models/`, then run `./install.sh`.

## Install

### Quick install (recommended)

```bash
./install.sh
```

`install.sh` pushes `custos.yaml` to `/sdcard/atak/custos/config/`, every skill in `skills/` to `/sdcard/atak/custos/skills/`, and every scratch file in `scratches/` to `/sdcard/atak/custos/scratch/` so they can be run from the in-app editor.

### Manual install

```bash
# 1. Config
adb shell mkdir -p /sdcard/atak/custos/config
adb push custos.yaml /sdcard/atak/custos/config/custos.yaml

# 2. Skills
adb shell mkdir -p /sdcard/atak/custos/skills
for skill in skills/custos.*/; do
    name=$(basename "$skill")
    adb shell mkdir -p "/sdcard/atak/custos/skills/$name"
    adb push "$skill"/. "/sdcard/atak/custos/skills/$name/"
done

# 3. Scratches (optional)
adb shell mkdir -p /sdcard/atak/custos/scratch
adb push scratches/*.lua /sdcard/atak/custos/scratch/
```

### Installing a single skill

To install just one skill (e.g., when you've authored your own or want to try one in isolation):

```bash
adb shell mkdir -p /sdcard/atak/custos/skills/custos.my_skill
adb push skills/custos.my_skill/. /sdcard/atak/custos/skills/custos.my_skill/
```

The plugin watches the skills directory and hot-reloads on change — no ATAK restart needed.

## Configuring providers

The shipped `custos.yaml` enables three on-device providers by default, each of which expects a weights file in `/sdcard/atak/custos/models/` (see [`models/README.md`](models/README.md) for what to download):

- **`on-device-gemma4`** (LiteRT-LM, `handheld` tier, priority 1) — primary chat LLM, runs entirely on the device. Needs `gemma-4-E2B-it.litertlm`.
- **`on-device-embed`** (llama.cpp, embeddings) — powers semantic skill selection and RAG. Needs `nomic-embed-text-v1.5.Q8_0.gguf`.
- **`on-device-whisper`** (whisper.cpp, `handheld` tier) — on-device PTT transcription. Needs `ggml-tiny.bin`.

Cloud providers (Anthropic, OpenAI, xAI) and vision detection are in the file as commented-out examples. Uncomment the block you want, then set the API key from inside the chat:

```
Set the API key for anthropic-claude
```

Keys are stored in the encrypted Android Keystore — never in `custos.yaml`.

For the full field reference and every supported provider, see [custos.nimbusxr.us/docs](https://custos.nimbusxr.us/docs).

## Running the scratch tests

Once the scratches are pushed to `/sdcard/atak/custos/scratch/`:

1. Open the CUST/OS **Editor** panel in ATAK.
2. Navigate to the `scratch` directory in the file tree.
3. Open `run_all_tests.lua`.
4. Tap **Run**.

The console reports pass/fail per test and cleans up any test artifacts at the end.

## Authoring your own skill

The fastest path is in-chat, via the built-in skill authoring agent:

```
Create a new skill called custos.my_skill that ...
```

The `custos.skill_creator` skill scaffolds the directory, writes the initial `SKILL.md` and `.lua` files, and hot-reloads. You can then open the files in the in-app editor to refine.

To author locally and push manually:

```bash
mkdir -p skills/custos.my_skill
# Create SKILL.md and your .lua files
./install.sh                         # or adb push just your skill
```

For the skill format, Lua API, and authoring cookbook, see [custos.nimbusxr.us/docs](https://custos.nimbusxr.us/docs).

## Uninstall the skill kit

```bash
adb shell rm -rf /sdcard/atak/custos/skills
adb shell rm -rf /sdcard/atak/custos/scratch
adb shell rm /sdcard/atak/custos/config/custos.yaml
```

The plugin will log that the skills directory went away and fall back to zero skills — a valid runtime state.

## Filing issues and joining the conversation

- **Bugs, feature requests, skill ideas, docs issues:** use the **Issues** tab. Pick the matching template.
- **General questions, use cases, patterns, deployment stories:** use the **Discussions** tab.
- **What we're working on next:** the **Projects** tab.
- **Security vulnerabilities:** please **don't** file a public issue — see [SECURITY.md](SECURITY.md) for the private disclosure process.

## Contributing

Contributions are welcome — new skills, fixes to existing ones, better scratches, clearer docs, and install-flow improvements. See [CONTRIBUTING.md](CONTRIBUTING.md) for the process, style conventions, and how to open a good PR.

Everyone interacting in this project is expected to follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## License

This repository (the skill kit, scratches, starter configuration, and install tooling) is licensed under the [MIT License](LICENSE).

The CUST/OS plugin itself — the Android APK and its runtime source — is a separate project under its own proprietary license.
