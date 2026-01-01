# NixOS Container

Imperative container NixOS configuration.

## References:

- [NixOS Manual](https://nixos.org/manual/nixos/stable/#sec-imperative-containers)
- [NixOS Wiki](https://wiki.nixos.org/wiki/NixOS_Containers#Define_and_create_nixos-container_from_a_Flake_file)

## Setup

In your host configuration, set:

```nix
boot.enableContainers = true;
```

Create a new directory and initialize the template inside of it:

> `nxc` is an arbitrary name

```bash
mkdir -p nxc
cd nxc
nix flake init -t github:sid115/nix-core#container
```

## Usage

Create the container:

```bash
sudo nixos-container create nxc --flake .
```

Start the container:

```bash
sudo nixos-container start nxc
```

Rebuild the container:

```bash
sudo nixos-container update nxc --flake .
```

Log in as root:

```bash
sudo nixos-container root-login nxc
```

Stop the container:

```bash
sudo nixos-container stop nxc
```

Destroy the container:

```bash
sudo nixos-container destroy nxc
```

For more, see the help page:

```bash
nixos-container --help
```
