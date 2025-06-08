# Install Nix

Install the Nix package manager according to the official documentation on [nixos.org](https://nixos.org/download/).

On Linux, simply run:

```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
```

## Configuration

Add the following to `~/.config/nix/nix.conf` (recommended) or `/etc/nix/nix.conf`:

```ini
experimental-features = nix-command flakes
```

- `nix-command` enables the [new `nix` CLI](https://nix.dev/manual/nix/2.29/command-ref/new-cli/nix.html) Nix is transitioning to.
- `flakes` will be covered later in this guide. Don't worry about them for now.

Reload your session to get access to the `nix` command.
