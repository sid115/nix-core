# Baibot

Baibot is a Matrix AI bot.

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

#### Optional Settings
- **OpenAI API Key**: If you intend to use OpenAI integrations, provide your API key as `BAIBOT_AGENTS_OPENAI_API_KEY` in your `.env` file.

#### How to Create the `.env` File
Create a file (e.g., `/var/lib/secrets/baibot.env`) with the following content, replacing placeholders with your actual secrets:

```bash
BAIBOT_USER_PASSWORD="your-secure-password-for-baibot"
BAIBOT_ENCRYPTION_RECOVERY_PASSPHRASE="your-long-and-secure-recovery-passphrase"
...
```

Set secure permissions for the `.env` file:
```bash
sudo chown baibot:baibot /var/lib/secrets/baibot.env
sudo chmod 600 /var/lib/secrets/baibot.env
```

#### Configure the `environmentFile` Option
In your NixOS configuration, set the path to the `.env` file using the `environmentFile` option:
```nix
services.baibot.environmentFile = "/var/lib/secrets/baibot.env";
```

### User Creation

Create the `baibot` user on your Matrix instance. If you are using the [nix-core Matrix module](../matrix-synapse/README.md), this can be done with the `register_new_matrix_user` alias:

```bash
register_new_matrix_user
```

Set the `user localpart` and `password` according to your configuration.

## Tips

### Set Handlers Dynamically
You can set handlers dynamically in a Matrix chat with Baibot. For example:
```
!bai config global set-handler speech-to-text static/openai
```
This expects a static definition of an OpenAI agent in the configuration file. Handlers in the command must be specified with dashes instead of underscores as in the configuration file.

### Set STT to Transcribe Only
```
!bai config global speech-to-text set-flow-type only_transcribe
```

## Todo

1. Set up a local LLM for speech-to-text with Ollama.
1. Whitelist each user for the speech-to-text engine only.
