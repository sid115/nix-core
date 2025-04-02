{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ntfy-sh;

  check-domain = pkgs.writeShellApplication {
    name = "check-domain";
    runtimeInputs = [
      pkgs.curl
      cfg.package
    ];
    text = builtins.readFile ./check-domain.sh;
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
        ExecStart = "${pkgs.bash}/bin/bash ${check-domain}/bin/check-domain ${escapedDomain} ${escapedTopic}";
        Restart = "on-failure";
        RestartSec = "300s";
      };
    };

  inherit (lib)
    escapeShellArg
    foldl'
    mkOption
    types
    ;
in
{
  options.services.ntfy-sh.notifiers = {
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

  config = {
    systemd.services = foldl' (
      acc: domainCfg:
      let
        serviceName = "ntfy-sh-monitor-domain-${domainCfg.fqdn}";
      in
      acc
      // {
        "${serviceName}" = mkMonitorDomainService domainCfg.fqdn domainCfg.topic;
      }
    ) { } cfg.notifiers.monitor-domains;
  };
}
