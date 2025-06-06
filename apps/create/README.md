# How to add configuration templates

The create script copies everything inside the template's directory to the nix-config flake. It will rename files and strings inside files to match the user input. Then, it applies diff files and deletes them.

At minimum, your template needs:
- `hosts/HOSTNAME`: NixOS configuration
- `users/USERNAME/.gitkeep`: user configuration
- `flake.nix.diff`: flake diff that applies your configuration

You can also add a Home Manager configuration: `users/USERNAME/home`

diff files are used to overwrite existing files in the [nix-config](../../templates/nix-config/). They need to have the same name as their original file with `.diff` at the end:
- `flake.nix` -> `flake.nix.diff`

Supported strings that will get replaced by the create script are:
- `HOSTNAME`
- `USERNAME`
- `GIT_NAME`
- `GIT_EMAIL`

Add your template to the [script's help page](./create.sh) and [getting started guide](../../docs/create_config.md).
