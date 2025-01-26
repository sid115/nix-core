# Mail

[docs](https://nixos-mailserver.readthedocs.io/en/latest/index.html)

## Setup

Follow the [setup guide](https://nixos-mailserver.readthedocs.io/en/nixos-24.05/setup-guide.html#setup-dns-a-record-for-server).

## Config

### `flake.nix`

```nix
inputs = {
  nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.11";
  nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs";
};
```

> Replace `24.11` with your `nixpkgs` version.

### Host configuration:

```nix
mailserver = {
  enable = true;
  loginAccounts = {
    "ADMIN@${config.networking.domain}" = {
      # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
      hashedPasswordFile = config.sops.secrets."mailserver/accounts/ADMIN".path;
      aliases = [ "postmaster@${config.networking.domain}" ];
    };
  };
};
sops.secrets."mailserver/accounts/ADMIN" = { };
```

> Replace `ADMIN` with an existing administrator account.
