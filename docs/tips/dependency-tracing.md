# Dependency Tracing

Dependency tracing in Nix allows you to understand the relationships between packages in your system configuration.

## Forward Path Tracing

This section answers the question: "*What are the dependencies of an installed package?*"

Print a store path's dependency tree with:

```bash
nix-store --query --tree /nix/store/...
```

Get a package's store path with:

> Replace `YOUR_CONFIG` with the name of your NixOS or Home Manager configuration, and `PACKAGE` with the name of the package you want to analyze.

##### NixOS

```bash
nix path-info ~/.config/nixos#nixosConfigurations.YOUR_CONFIG.pkgs.PACKAGE
```

##### Home Manager

```bash
nix path-info ~/.config/nixos#homeConfigurations.YOUR_CONFIG.pkgs.PACKAGE
```

## Backward Path Tracing

This section answers the question: "*What are parents of an installed package?*" or "*Why is a certain package installed?*"

Print a package's dependency path with:

> Replace `YOUR_CONFIG` with the name of your NixOS or Home Manager configuration, and `PACKAGE` with the name of the package you want to analyze.

##### NixOS

```bash
nix why-depends --derivation ~/.config/nixos#nixosConfigurations.YOUR_CONFIG.config.system.build.toplevel ~/.config/nixos#nixosConfigurations.YOUR_CONFIG.pkgs.PACKAGE
```

##### Home Manager

```bash
nix why-depends --derivation ~/.config/nixos#homeConfigurations.YOUR_CONFIG.activationPackage ~/.config/nixos#homeConfigurations.YOUR_CONFIG.pkgs.PACKAGE
```
