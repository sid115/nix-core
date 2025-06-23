{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.mcpo;

  configFile = pkgs.writeText "mcpo-config.json" (builtins.toJSON cfg.settings);

  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.mcpo = {
    enable = mkEnableOption "Enable mcpo, an MCP-to-OpenAPI proxy server.";

    package = mkOption {
      type = types.nullOr types.package;
      description = "The package to use for mcpo. You have to specify this manually.";
      default = null;
    };

    user = mkOption {
      type = types.str;
      description = "The user the mcpo service will run as.";
      default = "mcpo";
    };

    group = mkOption {
      type = types.str;
      description = "The group the mcpo service will run as.";
      default = "mcpo";
    };

    workDir = mkOption {
      type = types.str;
      description = "The working directory for the mcpo service.";
      default = "/var/lib/mcpo";
    };

    settings = mkOption {
      type = types.attrs;
      description = "A set of attributes that will be translated into the JSON configuration file for mcpo. It follows the Claude Desktop format.";
      default = { };
      example = {
        mcpServers = {
          memory = {
            command = "npx";
            args = [
              "-y"
              "@modelcontextprotocol/server-memory"
            ];
          };
          time = {
            command = "uvx";
            args = [
              "mcp-server-time"
              "--local-timezone=America/New_York"
            ];
          };
          mcp_sse = {
            type = "sse";
            url = "http://127.0.0.1:8001/sse";
            headers = {
              Authorization = "Bearer token";
              X-Custom-Header = "value";
            };
          };
          mcp_streamable_http = {
            type = "streamable_http";
            url = "http://127.0.0.1:8002/mcp";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.workDir} - ${cfg.user} ${cfg.group} - -"
    ];

    users.users."${cfg.user}" = {
      isSystem = true;
      group = cfg.group;
    };

    users.groups."${cfg.group}" = { };

    systemd.services.mcpo = {
      description = "Service for mcpo, an MCP-to-OpenAPI proxy server.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${getExe cfg.package} --config ${configFile}";
        Restart = "on-failure";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.workDir;
      };
    };
  };
}
