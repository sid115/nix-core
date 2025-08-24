# Flakes

> Flakes are still an experimental feature in Nix. However, they are so widely used by the community that they almost became standard. Furthermore, *nix-core* uses Flakes.

Nix flakes are a reproducible way to define, build, and deploy Nix projects, making them reliable and portable.

Flakes accomplish that by:

## Standardized Input

They define a fixed, declarative input (the `flake.nix` file) that specifies all project dependencies, sources, and outputs. This eliminates implicit dependencies or environment variables that could cause builds to differ.

Example in `flake.nix`:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; # Declare we need nixpkgs, specifically this branch
};
```

## Reproducible "Lock File"

When you build or develop with a flake, Nix generates a `flake.lock` file. This file records the *exact* content-addressable hashes of *all* transitive inputs used for that specific build. This lock file can be committed to version control, ensuring that anyone else cloning the repository (or a CI system) will use precisely the same set of inputs and thus achieve the identical result.

Example `flake.lock` entry for `nixpkgs`:

```json
"nixpkgs": {
  "locked": {
    "lastModified": 1709259160,
    "narHash": "sha256-...",
    "owner": "NixOS",
    "repo": "nixpkgs",
    "rev": "b2f67f0b5d1a8e1b3c9f2d1e0f0e0c0b0a090807", // The exact commit!
    "type": "github"
  },
  "original": {
    "owner": "NixOS",
    "repo": "nixpkgs",
    "type": "github",
    "url": "github:NixOS/nixpkgs/nixos-23.11"
  }
}
```

## Flake Schema

The `flake.nix` has a well-defined structure for `inputs` (sources like Git repos, other flakes) and `outputs` (packages, applications, modules, etc.). This consistent schema makes flakes composable and predictable.

A `flake.nix` file typically looks like this:

```nix
# flake.nix
{
  description = "A simple example flake";

  inputs = {
    # Inputs are other flakes or external resources
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; # Locked to a specific branch/version
    # This is how you would add nix-core to your flake:
    # core.url = "github:sid115/nix-core"
  };

  outputs = { self, nixpkgs, ... }@inputs: # 'self' refers to this flake, inputs are available
    let
      # Define common arguments for packages from nixpkgs
      # This ensures all packages use the same version of Nixpkgs on this system
      pkgs = import nixpkgs {
        system = "x86_64-linux"; # The target system architecture
      };
    in
    {
      # Outputs include packages, devShells, modules, etc.
      # Packages that can be built by `nix build .#<package-name>`
      packages.x86_64-linux.my-app = pkgs.callPackage ./pkgs/my-app { };
      packages.x86_64-linux.my-other-app = pkgs.hello; # From nixpkgs directly

      # Development shells that can be entered using `nix develop`
      devShells.x86_64-linux.default = pkgs.mkShell {
        name = "my-dev-env";
        buildInputs = [ pkgs.nodejs pkgs.python3 ];
        shellHook = "echo 'Welcome to my dev environment!'";
      };

      # NixOS modules (for system config)
      # nixosConfigurations.<hostname>.modules = [ ./nixos-modules/webserver.nix ];
      # (This is more advanced and will be covered in NixOS section)
    };
}
```

Key parts of a `flake.nix`:

- `description`: A human-readable description of your flake.
- `inputs`: Defines all dependencies of your flake. Each input has a `url` pointing to another flake (e.g., a GitHub repository, a local path, or a Git URL) and an optional `follows` attribute to link inputs.
- `outputs`: A function that takes `self` (this flake) and all `inputs` as arguments. It returns an attribute set defining what this flake provides. Common outputs are `packages`, `devShells`, `nixosConfigurations`, etc., usually segregated by system architecture. You can read more about flake outputs in the [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/other-usage-of-flakes/outputs).

## `nix flake` Commands

The `nix flake` subcommand is your primary interface for interacting with flakes. Let's create a new flake to demonstrate them:

Initialize the flake:

```bash
mkdir my-flake && cd my-flake
nix flake init
```

This creates a minimal `flake.nix`.

Lock your flake:

```bash
nix flake lock
```

This creates `flake.lock`, a file that locks the exact versions of your inputs.

Update flake inputs:

```bash
nix flake update
``` 

This updates all inputs to their latest versions allowed by their `url` (e.g., the latest commit on `nixos-unstable` for `nixpkgs`) and then updates the `flake.lock` file. Since we just locked the flake for the first time, there probably won't be any updates available.

Print flake inputs:

```bash
nix flake metadata
```

Print flake outputs:

```bash
nix flake show
```

Build packages from a flake:

```bash
nix build .#hello # The '.' refers to the current directory's flake
./result/bin/hello
```

Run a package from a flake:

```bash
nix run .#hello
```

Since the `packages.<system>.default` output exists, you can just do `nix run`.

## `nix develop`

This command spins up a temporary shell environment with all the tools and dependencies specified in your flake's `devShells` output.

Let's expand your `flake.nix`:

```nix
# flake.nix
{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      # Define `pkgs` for the current system
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
    in
    {
      packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
      # With `pkgs` defined, we could also do this:
      # packages.x86_64-linux.hello = pkgs.hello;

      packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

      devShells.x86_64-linux.default = pkgs.mkShell {
        # Packages available in the shell
        packages = [
          pkgs.git
          pkgs.go
          pkgs.neovim
        ];
        # Environment variables for the shell
        GIT_COMMITTER_EMAIL = "your-email@example.com";
        # Commands to run when entering the shell
        shellHook = ''
          echo "Entering development shell for my project."
          echo "You have Git, Go, and Neovim available."
        '';
      };
    };
}
```

Now, from your project directory:

```bash
nix develop
```

You'll instantly find yourself in a shell where `git`, `go`, and `nvim` are available, and your `GIT_COMMITTER_EMAIL` is set. When you exit, your regular shell environment is restored – no lingering installations or modified global state. This makes it incredibly easy to switch between projects, each with its specific toolchain and dependencies, without conflicts.
