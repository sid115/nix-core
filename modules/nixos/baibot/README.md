# Baibot

Baibot is a Matrix AI bot.

## References

- [GitHub](https://github.com/etkecc/baibot)

## Setup

### Configuration

Create a config file at `services.baibot.configFile` (`/etc/baibot/config.yml` by default). Use the [sample config](https://github.com/etkecc/baibot/blob/main/etc/app/config.yml.dist) for reference.

### User creation

Create the baibot user on your Matrix instance. If you are using the [nix-core Matrix module](../matrix-synapse/README.md), this can be done with the `register_new_matrix_user` alias:

```bash
register_new_matrix_user
```

Set `user localpart` and `password` according to your configuration.

### Finalize

The first rebuild with the baibot service enabled fails. This is expected behavior, since the config file cannot belong to the baibot user, since it does not yet exist. Set the correct permissions after the first rebuild:

```bash
sudo chown -R baibot:baibot /etc/baibot
```

Then, restart the baibot and matrix-synapse services:

```bash
sudo systemctl restart baibot.service matrix-synapse.service
```

## Tips

### Set handlers dynamically

You can set handlers dynamically in a Matrix chat with baibot. For example:

```
!bai config global set-handler speech-to-text static/openai
```

This expects a static definition of an OpenAI agent in the configuration file. Handlers in the command must be specified with dashes instead of underscores as in the configuration file.

### Set STT to transcribe only

```
!bai config global speech-to-text set-flow-type only_transcribe
```

## Todo

1. implement config option to manage configuration file through nix
1. set up local LLM for speech to text with Ollama
1. whitelist each user for the speech to text engine only
