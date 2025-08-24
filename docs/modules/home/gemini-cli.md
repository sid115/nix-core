# Gemini CLI

An open-source AI agent that brings the power of Gemini directly into your terminal.

View the [*nix-core* Home Manager module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/home/gemini-cli).

## References

- [GitHub](https://github.com/google-gemini/gemini-cli)
- [CLI Docs](https://github.com/google-gemini/gemini-cli/tree/main/docs/cli)

## Setup

The package must be set by you. Easiest option is to use the nix-core overlay:

```nix
{ inputs, pkgs, ... }:

{
  imports = [
    inputs.core.homeModules.gemini-cli
  ];

  programs.gemini-cli = {
    enable = true;
    package = pkgs.core.gemini-cli;
  };
}
```

Gemini CLI reads environment variables, such as your API key, from `~/.gemini/.env`. You can manage it with sops-nix:

```nix
{ config, ... }:

{
  sops.secrets.gemini-api-key = { };
  sops.templates.gemini-cli-env = {
    content = ''
      GEMINI_API_KEY=${config.sops.placeholder.gemini-api-key}
    '';
    path = config.home.homeDirectory + "/.gemini/.env";
  };
}
```

Set `gemini-api-key` in your `secrets.yaml`:

> Replace `abc123` with your Gemini API key.

```yaml
gemini-api-key: abc123
```

## Troubleshooting

These are some common warnings and errors you might encounter when using Gemini CLI:

### Error saving user settings file

```
Error saving user settings file: Error: EROFS: read-only file system, open '/home/you/.gemini/settings.json'
```

This is intended behavior.
