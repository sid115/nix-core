# Jellyfin

Jellyfin is a free and open-source media server and suite of multimedia applications.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/jellyfin).

## References

[docs](https://jellyfin.org/docs/)

## Setup

Users, Plugins, and Libraries are managed in the web interface. You have to declare them manually.

Visit the web interface and follow the on screen instructions. Create libraries corresponding to `config.services.jellyfin.libraries`.

## Upload files

```bash
rsync -arvzP -e 'ssh -p SSH_PORT' LOCAL_PATH YOU@REMOTE:JELLYFIN_DATA_DIR/libraries/LIBRARY
```

> the user `YOU` has to be in the *jellyfin* group on the remote machine `REMOTE`

- `SSH_PORT`: Your SSH port
- `LOCAL_PATH`: Local path to your media file(s)
- `YOU`: Your user on your remote machine
- `REMOTE`: IP/domain of your remote machine
- `JELLYFIN_DATA_DIR`: `config.services.jellyfin.dataDir`
- `LIBRARY`: Target library. See `config.services.jellyfin.libraries`
