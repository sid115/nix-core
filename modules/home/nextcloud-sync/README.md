# Nextcloud sync client

Because every other client sucks.

## Setup

This is an example home config:

```nix
{ inputs, config, ... }:

{
  imports = [
    inputs.core.homeModules.nextcloud-sync
  ];

  services.nextcloud-sync = {
    enable = true;
    remote = "cloud.portuus.de"; # just the URL without `https://`
    passwordFile = config.sops.secrets.nextcloud.path;
    connections = [ # absolute paths without trailing /
      {
        local = "/home/sid/aud";
        remote = "/aud";
      }
      {
        local = "/home/sid/doc";
        remote = "/doc";
      }
      {
        local = "/home/sid/img";
        remote = "/img";
      }
      {
        local = "/home/sid/vid";
        remote = "/vid";
      }
    ];
  };
}
```

## Troubleshooting

Each listed connection spawns a systemd user service and timer. Using the example above, we get:

```plaintext
nextcloud-sync-aud.service
nextcloud-sync-aud.timer
nextcloud-sync-doc.service
nextcloud-sync-doc.timer
nextcloud-sync-img.service
nextcloud-sync-img.timer
nextcloud-sync-vid.service
nextcloud-sync-vid.timer
```

Check their status to know what might go wrong:

```bash
systemctl --user status nextcloud-sync-doc.service
journalctl --user -xeu nextcloud-sync-doc.service
```
