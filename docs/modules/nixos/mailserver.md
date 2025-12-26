# Mail

A simple NixOS mailserver.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/mailserver).

## References

- [docs](https://nixos-mailserver.readthedocs.io/en/latest/index.html)

## Setup

Follow the [setup guide](https://nixos-mailserver.readthedocs.io/en/master/setup-guide.html#setup-dns-a-record-for-server).

## Sops

Provide every user's hashed password to your host's `secrets.yaml`:

> Replace `abc123` with your actual secrets

```yaml
mailserver:
    accounts:
        user1: abc123
        user2: abc123
        # ...
```

Generate hashed passwords with:

```sh
nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
```

## Config

### `flake.nix`

```nix
inputs = {
  nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
  nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs";
};
```

### Host configuration:

```nix
imports = [ inputs.core.nixosModules.mailserver ]

mailserver = {
  enable = true;
  accounts = {
    admin = {
      aliases = [ "postmaster" ];
    };
    alice = { };
  };
};
```

You may need to set [`mailserver.stateVersion`](https://nixos-mailserver.readthedocs.io/en/master/migrations.html). At the time of writing, you need to set it to `3`, but you should check the mailserver docs yourself.
