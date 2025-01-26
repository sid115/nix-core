# Jellyfin

Jellyfin is a free and open-source media server and suite of multimedia applications.

[docs](https://jellyfin.org/docs/)

Users, Plugins, and Libraries are managed in the web interface. You have to declare them manually.

## Setup

Visit the web interface and follow the on screen instructions. Create libraries corresponding to `config.services.jellyfin.libraries`.

## Upload files

```bash
rsync -avzP -e "ssh -p SSH_PORT" --rsync-path="sudo rsync" LOCAL_PATH YOU@REMOTE:JELLYFIN_DATA_DIR/libraries/LIBRARY
```

> the user `YOU` needs sudo privileges on the remote machine `REMOTE`

- `SSH_PORT`: Your SSH port
- `LOCAL_PATH`: Local path to your media file(s)
- `YOU`: Your user on your remote machine
- `REMOTE`: IP/domain of your remote machine
- `JELLYFIN_DATA_DIR`: `config.services.jellyfin.dataDir`
- `LIBRARY`: Target library. See `config.services.jellyfin.libraries`
