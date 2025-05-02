{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.open-webui;
  fqdn = "${cfg.subdomain}.${config.networking.domain}";
  searx = config.services.searx;

  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  options.services.open-webui = {
    subdomain = mkOption {
      type = types.str;
      default = "ai";
      description = "Subdomain for Nginx virtual host.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
  };

  config = mkIf cfg.enable {
    services.open-webui = {
      port = mkDefault 8082;
      environment = {
        ANONYMIZED_TELEMETRY = mkDefault "False";
        BYPASS_MODEL_ACCESS_CONTROL = "True";
        DEFAULT_USER_ROLE = mkDefault "user";
        DO_NOT_TRACK = mkDefault "True";
        ENABLE_IMAGE_GENERATION = mkDefault "True";
        ENABLE_RAG_WEB_SEARCH = mkDefault "True";
        ENABLE_SEARCH_QUERY = mkDefault "True";
        ENABLE_SIGNUP = mkDefault "False";
        SCARF_NO_ANALYTICS = mkDefault "True";
        USER_PERMISSIONS_WORKSPACE_KNOWLEDGE_ACCESS = "True";
        USER_PERMISSIONS_WORKSPACE_MODELS_ACCESS = "True";
        USER_PERMISSIONS_WORKSPACE_PROMPTS_ACCESS = "True";
        USER_PERMISSIONS_WORKSPACE_TOOLS_ACCESS = "True";

        # web search engine
        RAG_WEB_SEARCH_ENGINE = mkIf searx.enable (mkDefault "searxng");
        SEARXNG_QUERY_URL = mkIf searx.enable (
          mkDefault "http://127.0.0.1:${toString searx.settings.server.port}/search?q=<query>"
        );
      };
    };

    environment.systemPackages = [
      pkgs.ffmpeg-full
    ];

    services.nginx.virtualHosts."${fqdn}" = {
      enableACME = cfg.forceSSL;
      forceSSL = cfg.forceSSL;
      locations."/" = {
        proxyPass = "http://localhost:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };
  };
}
