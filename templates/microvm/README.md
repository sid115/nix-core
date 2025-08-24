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

> Note: `<build-host>` needs to be a remote host where you login as root via ssh with no password.

If you need to use remote sudo, you can also use [nix-core's rebuild script](https://github.com/sid115/nix-core/blob/master/modules/nixos/common/rebuild.sh) for remote rebuilds. But then, the root user password cannot be empty:

```bash
rebuild -p . -H uvm -T uvm -B <build-host>
```

You might want to set up [PAM's SSH agent Auth](https://search.nixos.org/options?channel=unstable&query=sshAgentAuth) or use an [askpass helper](https://search.nixos.org/options?channel=unstable&query=askpass).
