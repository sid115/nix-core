# microvm

[microvm](https://github.com/microvm-nix/microvm.nix) NixOS configuration.

## Setup

To be able to rebuild remotely and for convenient ssh access, add the uvm host to your Home Manager ssh configuration:

```nix
programs.ssh.matchBlocks = {
  uvm = {
    host = "uvm";
    hostname = "localhost";
    port = 2222;
    user = "root";
    checkHostIP = false;
  };
};
```

Create a new directory and initialize the template inside of it:

```bash
mkdir -p microvm
cd microvm
nix flake init -t github:sid115/nix-core#microvm
```

Add your public key to the NixOS configuration. See [`config/configuration.nix`](./config/configuration.nix).

## Usage

Run VM:

```bash
nix run .#microvm
```

Or with `tmux`:

```bash
tmux new-session -s microvm 'nix run .#microvm'
```

> `tmux` is available in the Nix development shell.

SSH into VM:

```bash
ssh uvm
```

Remote rebuilding:

```bash
nix run .#rebuild <build-host> uvm
```

> `<build-host>` needs to be a remote host where you login as root via ssh with no password.   
> TODO: Add an askpass helper
