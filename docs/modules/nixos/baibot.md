# Baibot

> Warning: This module is not actively maintained. Expect things to break!

Baibot is a Matrix AI bot.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/baibot).

## References

- [GitHub](https://github.com/etkecc/baibot)

## Setup

### Configuration

Baibot requires specific configuration options and secrets to function correctly. These settings can be provided via an environment file (`.env`) to securely handle sensitive information. Below are the required and optional settings you must configure:

#### Required Settings
- **Matrix User Password**: The password for the `baibot` Matrix user. This is required for authentication with the homeserver. Set it as `BAIBOT_USER_PASSWORD` in your `.env` file.
- **Encryption Recovery Passphrase**: A secure passphrase for encryption key recovery. Required for secure message storage. Set it as `BAIBOT_ENCRYPTION_RECOVERY_PASSPHRASE` in your `.env` file.
- **Session Encryption Key**: A 64-character hex key (generated using `openssl rand -hex 32`) for encrypting session data. Set it as `BAIBOT_PERSISTENCE_SESSION_ENCRYPTION_KEY` in your `.env` file.
- **Config Encryption Key**: A 64-character hex key for encrypting configuration data. Set it as `BAIBOT_PERSISTENCE_CONFIG_ENCRYPTION_KEY` in your `.env` file.

```bash
BAIBOT_USER_PASSWORD="your-secure-password-for-baibot"
BAIBOT_ENCRYPTION_RECOVERY_PASSPHRASE="your-long-and-secure-recovery-passphrase"
...
```

#### Configure the `environmentFile` Option
In your NixOS configuration, set the path to the `.env` file using the `environmentFile` option:
```nix
services.baibot.environmentFile = "/var/lib/secrets/baibot.env";
```

### User Creation

Create the `baibot` user on your Matrix instance. If you are using the [nix-core Matrix module](./matrix-synapse.md), this can be done with the `register_new_matrix_user` alias:

```bash
register_new_matrix_user
```

Set the `user localpart` and `password` according to your configuration.

Restart both `matrix-synapse.service` and `baibot.service`. You can then invite Baibot to any room you like.

### OpenAI API

Send this message in a room where Baibot has joined:

```
!bai agent create-global openai openai-agent
```

The bot will reply with a YAML configuration which you need to edit and send back:

```yaml
base_url: https://api.openai.com/v1
api_key: YOUR_API_KEY_HERE
text_generation:
  model_id: gpt-4o
  prompt: 'You are a brief, but helpful bot called {{ baibot_name }} powered by the {{ baibot_model_id }} model. The date/time of this conversation''s start is: {{ baibot_conversation_start_time_utc }}.'
  temperature: 1.0
  max_response_tokens: 16384
  max_context_tokens: 128000
speech_to_text:
  model_id: whisper-1
text_to_speech:
  model_id: tts-1-hd
  voice: onyx
  speed: 1.0
  response_format: opus
image_generation:
  model_id: dall-e-3
  style: vivid
  size: 1024x1024
  quality: standard
```

Set `openai-agent` as the default for any purpose you like:

```
!bai config global set-handler text-generation global/openai-agent
!bai config global set-handler speech-to-text global/openai-agent
!bai config global set-handler text-to-speech global/openai-agent
!bai config global set-handler image-generation global/openai-agent
```

## Tips

### Set STT to Transcribe Only
```
!bai config global speech-to-text set-flow-type only_transcribe
```

### Set user access
```
!bai access set-users SPACE_SEPARATED_PATTERNS
```

> For example: `@*:example.com`

## Todo

1. Set up a local LLM for speech-to-text with Ollama.
1. Whitelist each user for the speech-to-text engine only.
