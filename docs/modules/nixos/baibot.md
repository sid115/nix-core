# Baibot

Baibot is a Matrix AI bot.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/baibot).

## References

- [GitHub](https://github.com/etkecc/baibot)

## Setup

### Configuration

Since baibot's configuration file requires setting secrets as plain text strings, configuring the baibot service through Nix is not supported. You have to create a configuration file on your machine and point to it with `services.baibot.configFile`. 

Use the [template configuration file](https://github.com/etkecc/baibot/blob/main/etc/app/config.yml.dist) for reference.

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
!bai agent create-global openai openai
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

Set `openai` as the default for any purpose you like:

```
!bai config global set-handler text-generation global/openai
!bai config global set-handler speech-to-text global/openai
!bai config global set-handler text-to-speech global/openai
!bai config global set-handler image-generation global/openai
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
