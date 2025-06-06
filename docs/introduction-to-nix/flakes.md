# Flakes

Before flakes, Nix users often relied on "channels" like `nixos-23.11` or `nixpkgs-unstable`. You'd subscribe to a channel, and `nix` would fetch the latest version of Nixpkgs from it. While convenient, this had a major drawback for reproducibility:

- **Channels are moving targets:** The content of a channel (e.g., `nixos-23.11`) changes daily. If you built a project today and your friend built it tomorrow using the "same" channel, they might get a different version of a package because the channel updated overnight.
- **No explicit dependency locking:** There was no `.lock` file to record the *exact* commit or version of `nixpkgs` (or other Nix sources) that was used to build a specific project or system.

Nix Flakes solve this by introducing explicit, locked dependencies and a standardized project structure leveraging a `flake.lock` file.

They do this by:

1. **Explicit Inputs:** Instead of implicitly relying on a global channel, `flake.nix` explicitly declares all its dependencies (like `nixpkgs`) by pointing to their exact source (e.g., a specific GitHub repository and branch/tag, or even a local path).

    Example in `flake.nix`:
    ```nix
    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; # Declare we need nixpkgs, specifically this branch
    };
    ```

2. **`flake.lock` for Reproducibility:** When you first use a flake (e.g., `nix build`), Nix generates a file called `flake.lock`. This file records the *exact* commit hash for *every* input in your `flake.nix`.

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
    This `flake.lock` file is typically committed to version control (e.g., Git) alongside `flake.nix`. Anyone else who clones your repository and uses your flake will use the *exact same* commit of `nixpkgs` as recorded in your `flake.lock`. This guarantees identical builds.

## Flake Schema

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
- `outputs`: A function that takes `self` (this flake) and all `inputs` as arguments. It returns an attribute set defining what this flake provides. Common outputs are `packages`, `devShells`, `nixosConfigurations`, etc., usually segregated by system architecture.

## `nix flake` Commands

The `nix flake` subcommand is your primary interface for interacting with flakes.

-   **Initializing a flake:**
    ```bash
    mkdir my-flake && cd my-flake
    nix flake init
    ```
    This creates a minimal `flake.nix` and `flake.lock` (a file that locks the exact versions of your inputs).

-   **Updating flake inputs:**
    ```bash
    nix flake update
    ```
    This updates all inputs to their latest versions allowed by their `url` (e.g., the latest commit on `nixos-23.11` for `nixpkgs`) and then updates the `flake.lock` file.

-   **Showing flake info:**
    ```bash
    nix flake info
    ```
    Shows details about your flake, including its inputs and locked versions.

-   **Building packages from a flake:**
    Assuming your `flake.nix` defines `packages.x86_64-linux.my-other-app = pkgs.hello;`:
    ```bash
    nix build .#my-other-app # The '.' refers to the current directory's flake
    ./result/bin/hello
    ```

-   **Running a package from a flake:**
    ```bash
    nix run .#my-other-app/bin/hello
    ```
    (Note: If the `packages.<system>.default` output exists, you can just do `nix run .`)

## `nix develop`

One of the most powerful features of flakes for developers is `nix develop`. This command spins up a temporary shell environment with all the tools and dependencies specified in your flake's `devShells` output.

Let's expand your `flake.nix`:
```nix
# flake.nix
{
  description = "A development environment for my project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        # Packages available in the shell
        packages = [ pkgs.git pkgs.go pkgs.vscode ];
        # Environment variables for the shell
        GIT_COMMITTER_EMAIL = "your-email@example.com";
        # Commands to run when entering the shell
        shellHook = ''
          echo "Entering development shell for my project."
          echo "You have Git, Go, and VS Code available."
        '';
      };
    };
}
```

Now, from your project directory:

```bash
nix develop
```

You'll instantly find yourself in a shell where `git`, `go`, and `code` are available, and your `GIT_COMMITTER_EMAIL` is set. When you exit, your regular shell environment is restored – no lingering installations or modified global state. This makes it incredibly easy to switch between projects, each with its specific toolchain and dependencies, without conflicts.
