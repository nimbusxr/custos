# On-device model weights

The shipped `custos.yaml` enables three on-device providers. Each expects a specific weights file in `/sdcard/atak/custos/models/` on the device. The weights are not redistributed in this repo — they're published by their respective maintainers and are too large to carry in git.

The workflow is: download the files into **this directory** (`models/` at the repo root), then run `./install.sh` from the repo root. The installer pushes anything in `models/` to the device alongside config, skills, and scratches.

## What you need

| Filename | What it powers | Approximate size |
|---|---|---|
| `gemma-4-E2B-it.litertlm` | On-device chat LLM (`on-device-gemma4` provider) | ~2 GB |
| `nomic-embed-text-v1.5.Q8_0.gguf` | Embeddings — semantic skill selection and RAG (`on-device-embed`) | ~140 MB |
| `ggml-tiny.bin` | On-device Whisper for PTT transcription (`on-device-whisper`) | ~77 MB |

Filenames are matched exactly by the provider URLs in `custos.yaml`. If you rename a file, update the matching `url:` line.

## Downloading

### Whisper tiny

Stable URL from the upstream whisper.cpp release mirror:

```bash
curl -L -o ggml-tiny.bin \
    https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin
```

### Gemma 4 E2B-it (LiteRT-LM)

Google publishes Gemma 4 models through the LiteRT community organization on Hugging Face and through ai.google.dev. The `.litertlm` format is required — LiteRT-LM does **not** load GGUF.

Starting points:

- **[ai.google.dev/gemma](https://ai.google.dev/gemma)** — official Gemma 4 release info
- **[huggingface.co/litert-community](https://huggingface.co/litert-community)** — LiteRT-LM community conversions

Download `Gemma-4-E2B-it.litertlm` (or whatever the maintainer has named the E2B-it LiteRT-LM artifact) and rename it to `gemma-4-E2B-it.litertlm` so the filename matches the shipped `custos.yaml`.

> **Note**: you need a Hugging Face account and an accepted Gemma license agreement to pull Google's Gemma models. Follow the prompts on the model card.

### Nomic embed

The Q8_0 GGUF quantization of Nomic Embed v1.5:

- **[huggingface.co/nomic-ai/nomic-embed-text-v1.5-GGUF](https://huggingface.co/nomic-ai/nomic-embed-text-v1.5-GGUF)**

Download `nomic-embed-text-v1.5.Q8_0.gguf` from the files tab into this directory.

## Installing to the device

Once all three files are in `models/`, from the repo root:

```bash
./install.sh
```

`install.sh` detects anything under `models/` and pushes it to `/sdcard/atak/custos/models/` on the device. Existing files on the device are overwritten.

To push models only (without also re-pushing config / skills / scratches):

```bash
adb push models/*.litertlm models/*.gguf models/*.bin /sdcard/atak/custos/models/
```

## Using different models

The shipped `custos.yaml` is a reasonable starting point, not a requirement. If you want to run a different LLM, embedding model, or larger Whisper model:

1. Download your preferred weights into `models/`.
2. Uncomment the matching provider block in `custos.yaml` (or edit one of the active ones), making sure the `url:` path matches the filename you downloaded.
3. For llama.cpp-served LLMs, make sure the tool-calling Jinja template is also in `models/` and referenced via `chatTemplatePath`.
4. Re-run `./install.sh`.

See [custos.nimbusxr.us/docs](https://custos.nimbusxr.us/docs) for the full provider reference and supported runtimes.

## Verifying

After install, open ATAK and tap the **Status** icon in the CUST/OS NavBar. Every configured provider should show online within 10–20 seconds. If one stays offline, tap the row to see the error — usually it's a missing file, a wrong filename, or a model format mismatch (e.g., trying to load a GGUF with `protocol: litert`).

You can also tail logcat while the plugin starts:

```bash
adb logcat | grep -E "NativeServerManager|LiteRtAdapter|AdapterHealth"
```
