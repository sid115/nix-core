# cifsMount

> [!WARNING]
> This module is not actively maintained. Expect things to break!

This module allows you to automount cifs shares after the login of the specified user. The remote has to have a running samba server.

## Config

```nix
config.services.cifsMount = {
  enable = true;
  remotes = [
    {
      host = "ip_address";
      shareName = "share_name";
      mountPoint = "/home/user/mount_point";
      credentialsFile = "/home/user/.smbcredentials";
      user = "user";
    }
    # more remotes ...
  ];
};
```
