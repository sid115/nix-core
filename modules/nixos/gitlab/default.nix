{ config, lib, ... }:

let
  cfg = config.services.gitlab;
  domain = config.networking.domain;
  subdomain = cfg.reverseProxy.subdomain;
  fqdn = if (cfg.reverseProxy.enable && subdomain != "") then "${subdomain}.${domain}" else domain;

  inherit (config) sops;
  inherit (config.services) openssh;

  inherit (lib) mkDefault mkIf elemAt;

  inherit (lib.utils) mkReverseProxyOption mkMailIntegrationOption;
in
{
  options.services.gitlab = {
    reverseProxy = mkReverseProxyOption "GitLab" "git";
    mailIntegration = mkMailIntegrationOption "GitLab";
  };

  config = mkIf cfg.enable {
    services.gitlab = {
      host = mkDefault fqdn;
      https = mkDefault (with cfg.reverseProxy; enable && forceSSL);
      port = if (with cfg.reverseProxy; enable && forceSSL) then 443 else mkDefault 8080;

      extraConfig = {
        gitlab = {
          username_changing_enabled = mkDefault false;
          email_from = mkIf cfg.mailIntegration.enable "gitlab@${domain}";
          email_display_name = mkIf cfg.mailIntegration.enable "${fqdn} GitLab";
          email_reply_to = mkIf cfg.mailIntegration.enable "no-reply@${domain}";
          default_theme = mkDefault 2; # dark mode
          default_projects_features = {
            wiki = mkDefault false;
            snippets = mkDefault false;
          };
          disable_animations = mkDefault true;
          time_zone = mkDefault "Europe/Berlin";
          ssh_port = if openssh.enable then mkDefault (elemAt openssh.ports 0) else mkDefault 22;
        };
        incoming_email.enable = mkDefault false;
      };

      smtp = mkIf cfg.mailIntegration.enable {
        enable = true;
        address = cfg.mailIntegration.smtpHost;
        port = 465;
        username = "gitlab@${domain}";
        passwordFile = sops.secrets."gitlab/smtp-password".path;
        domain = domain;
        enableStartTLSAuto = false;
        tls = true;
      };

      initialRootPasswordFile = sops.secrets."gitlab/root-password".path;
      databasePasswordFile = sops.secrets."gitlab/db".path;

      secrets = {
        secretFile = sops.secrets."gitlab/secret".path;
        dbFile = sops.secrets."gitlab/db".path;
        otpFile = sops.secrets."gitlab/otp".path;
        jwsFile = sops.secrets."gitlab/jws".path;
        activeRecordPrimaryKeyFile = sops.secrets."gitlab/ar-primary".path;
        activeRecordDeterministicKeyFile = sops.secrets."gitlab/ar-deterministic".path;
        activeRecordSaltFile = sops.secrets."gitlab/ar-salt".path;
      };
    };

    systemd.tmpfiles.rules = [ "d ${cfg.statePath} 0755 ${cfg.user} ${cfg.group} -" ];

    services.nginx.virtualHosts = mkIf cfg.reverseProxy.enable {
      "${fqdn}" = {
        enableACME = cfg.reverseProxy.forceSSL;
        forceSSL = cfg.reverseProxy.forceSSL;

        locations."/" = {
          proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
          proxyWebsockets = true;
          extraConfig = ''
            client_max_body_size 0;
          '';
        };
      };
    };

    sops.secrets =
      let
        owner = cfg.user;
        group = cfg.group;
        mode = "0400";
      in
      {
        "gitlab/root-password" = {
          inherit owner group mode;
        };
        "gitlab/secret" = {
          inherit owner group mode;
        };
        "gitlab/db" = {
          inherit owner group mode;
        };
        "gitlab/otp" = {
          inherit owner group mode;
        };
        "gitlab/jws" = {
          inherit owner group mode;
        };
        "gitlab/ar-primary" = {
          inherit owner group mode;
        };
        "gitlab/ar-deterministic" = {
          inherit owner group mode;
        };
        "gitlab/ar-salt" = {
          inherit owner group mode;
        };
        "gitlab/smtp-password" = mkIf cfg.mailIntegration.enable {
          inherit owner group mode;
        };
      };
  };
}
