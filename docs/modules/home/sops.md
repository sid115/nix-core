# Sops

For more information on how to use this module, see the [Sops NixOS module documentation](../nixos/sops.md).

For extensive documentation, read the [Readme on GitHub](https://github.com/Mic92/sops-nix/blob/master/README.md).

View the [*nix-core* Home Manager module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/home/sops).

## 1. Generate an age key

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

> Take note of your public key. You can print it again with:   
> `age-keygen -y ~/.config/sops/age/keys.txt`


## 2. Edit `.sops.yaml`

This file manages access to all secrets in this repository (NixOS and Home Manager configurations).

```bash
vim ~/.config/nixos/.sops.yaml
```

Add your public key under `keys` and set creation rules for your config:

```yaml
keys:
  - &you age12zlz6lvcdk6eqaewfylg35w0syh58sm7gh53q5vvn7hd7c6nngyseftjxl
creation_rules:
  - path_regex: users/you/home/secrets/secrets.yaml$
    key_groups:
    - age:
      - *you
```

## 3. Create a `secrets` directory

This directory in your Home Manager configuration will hold your secrets and sops configuration.

```bash
mkdir -p ~/.config/nixos/users/$(whoami)/home/secrets
```

## 4. Create a sops file

A sops file contains secrets in plain text. This file will then be encrypted with age. Make sure to follow the path regex in the creation rules.

```bash
cd ~/.config/nixos
sops users/$(whoami)/home/secrets/secrets.yaml
```

```yaml
# Files must always have a string value
example-key: example-value
# Nesting the key results in the creation of directories.
myservice:
  my_subdir:
    my_secret: password1
```

## 5. Deploy the secrets to the Nix store

Define your secrets under `sops.secrets`.

```bash
vim ~/.config/nixos/users/$(whoami)/home/secrets/default.nix
```

```nix
{
  sops.secrets.example-key = {};
  sops.secrets."myservice/my_subdir/my_secret" = {};
}
```

## 6. Reference secrets in your Home Manager configuration

Now you can use these secrets in your Home Manager configuration:

```nix
{ outputs, ... }:

{
  imports = [
    ./secrets

    outputs.homeModules.sops # includes all necessary configuration for sops-nix
  ];

  someOption.secretFile = config.sops.secrets.example-key.path;

  anotherOption.passwordFile = config.sops.secrets."myservice/my_subdir/my_secret".path;
}
```
