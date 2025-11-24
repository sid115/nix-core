{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ntfy-sh;

  stripProtocol =
    str:
    let
      http = "http://";
      https = "https://";
    in
    if hasPrefix http str then
      substring (stringLength http) (stringLength str - stringLength http) str
    else if hasPrefix https str then
      substring (stringLength https) (stringLength str - stringLength https) str
    else
      str;

  fqdn = stripProtocol cfg.settings.base-url;

  check-domain = pkgs.writeShellApplication rec {
    name = "check-domain";
    runtimeInputs = [ pkgs.curl ];
    text = readFile ./${name}.sh;
    meta.mainProgram = name;
  };

  mkMonitorDomainService =
    domain: topic:
    let
      escapedDomain = escapeShellArg domain;
      escapedTopic = escapeShellArg topic;
    in
    {
      description = "Monitor ${domain} and send notifications via ntfy-sh to topic ${topic}";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "nobody";
        Group = "nogroup";
        ExecStart = "${getExe check-domain} ${escapedDomain} ${escapedTopic}";
      };
    };

  mkMonitorDomainTimer =
    domain:
    let
      serviceName = "ntfy-sh-monitor-domain-${domain}";
    in
    {
      description = "Timer for monitoring domain ${domain}";
      wantedBy = [ "timers.target" ];
      partOf = [ "${serviceName}.service" ];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = "10min";
      };
    };

  inherit (lib)
    escapeShellArg
    foldl'
    getExe
    hasPrefix
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  inherit (builtins)
    readFile
    stringLength
    substring
    ;
in
{
  options.services.ntfy-sh = {
    reverseProxy = {
      enable = mkEnableOption "Nginx reverse proxy for `settings.base-url`.";
      forceSSL = mkOption {
        type = types.bool;
        default = true;
        description = "Force SSL for Nginx virtual host.";
      };
    };
    notifiers = {
      monitor-domains = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              fqdn = mkOption {
                type = types.str;
                description = "The domain to monitor.";
              };
              topic = mkOption {
                type = types.str;
                description = "The ntfy-sh topic to send notifications to.";
              };
            };
          }
        );
        default = [ ];
        description = ''
          A list of domains to monitor and the ntfy-sh topic to send notifications to.
          Each element requires:
            - `fqdn`: The domain to monitor.
            - `topic`: The ntfy-sh topic to send notifications to.
        '';
        example = [
          {
            fqdn = "my.domain.tld";
            topic = "my-topic";
          }
        ];
      };
    };
  };

  config = {
    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${fqdn}" = {
        enableACME = cfg.reverseProxy.forceSSL;
        forceSSL = cfg.reverseProxy.forceSSL;
        locations."/".proxyPass = mkDefault "http://127.0.0.1:2586";
      };
    };

    systemd = {
      services = foldl' (
        acc: domainCfg:
        let
          serviceName = "ntfy-sh-monitor-domain-${domainCfg.fqdn}";
        in
        acc
        // {
          "${serviceName}" = mkMonitorDomainService domainCfg.fqdn domainCfg.topic;
        }
      ) { } cfg.notifiers.monitor-domains;

      timers = foldl' (
        acc: domainCfg:
        let
          timerName = "ntfy-sh-monitor-domain-${domainCfg.fqdn}";
        in
        acc
        // {
          "${timerName}" = mkMonitorDomainTimer domainCfg.fqdn;
        }
      ) { } cfg.notifiers.monitor-domains;
    };
  };
}
