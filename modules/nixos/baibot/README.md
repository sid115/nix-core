# Baibot

Baibot is a Matrix AI bot.

## References

- [GitHub](https://github.com/etkecc/baibot)

## Setup

Create a config file at `services.baibot.configFile` (`/etc/baibot/config.yml` by default). Use the [sample config](https://github.com/etkecc/baibot/blob/main/etc/app/config.yml.dist) for reference.

The first rebuild with the baibot services enabled fails. This is expected behavior, since the config file cannot belong to the baibot user, since it does not yet exist. Set the correct permissions after the first rebuild:

```bash
sudo chown -R baibot:baibot /etc/baibot
```

Then, restart the service:

```bash
sudo systemctl restart baibot.service
```
