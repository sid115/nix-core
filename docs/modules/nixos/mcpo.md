# mcpo

A simple MCP-to-OpenAPI proxy server.

View the [*nix-core* NixOS module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/nixos/mcpo).

## References

- [GitHub](https://github.com/open-webui/mcpo)

## Configuration

You have to provide a package, for example from [nix-core](https://github.com/sid115/nix-core/tree/master/pkgs/mcpo/default.nix).

Setting `mcpServers` is required. The following example runs a NixOS MCP server using [mcp-nixos](https://github.com/utensils/mcp-nixos).

```nix
{ inputs, lib, ... }:

{
  imports = [ inputs.core.nixosModules.mcpo ];

  services.mcpo = {
    enable = true;
    package = inputs.core.packages.${pkgs.system}.mcpo;
    settings = {
      mcpServers = {
        nixos = {
          command = lib.getExe inputs.mcp-nixos.packages.${pkgs.system}.mcp-nixos;
        };
      };
    };
  };
}
```

## Usage

Each tool will be accessible under its own unique route `127.0.0.1:8000/<mcp-server>`. Following the example from above, visit [127.0.0.1:8000/nixos/docs](http://127.0.0.1:8000/nixos/docs) to send requests manually.

## Open WebUI Integration

Follow the [official Open WebUI integration documentation starting at *Step 2*](https://docs.openwebui.com/openapi-servers/open-webui/#step-2-connect-tool-server-in-open-webui).

In Open WebUI, users have to set *Function Calling* to *Native* in *Settings* > *General* > *Advanced Parameters*. Then, they can enable MCP servers in a chat by clicking *More* (the plus sign) in the bottom left of the prompt window.
