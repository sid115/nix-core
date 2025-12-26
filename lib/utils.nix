{ lib, ... }:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  mkMailIntegrationOption = serviceName: {
    enable = mkEnableOption "Mail integration for ${serviceName}.";
    smtpHost = mkOption {
      type = types.str;
      default = "localhost";
      description = "SMTP host for sending emails.";
    };
  };

  mkReverseProxyOption = serviceName: subdomain: {
    enable = mkEnableOption "Nginx reverse proxy for ${serviceName}.";
    subdomain = mkOption {
      type = types.str;
      default = subdomain;
      description = "Subdomain for Nginx virtual host. Leave empty for root domain.";
    };
    forceSSL = mkOption {
      type = types.bool;
      default = true;
      description = "Force SSL for Nginx virtual host.";
    };
  };

  mkUrl =
    {
      fqdn,
      ssl ? false,
      port ? null,
      path ? "",
      ...
    }:
    let
      protocol = if ssl then "https" else "http";
      portPart = if port != null then ":${toString port}" else "";
      pathPart = if path != "" then "/${path}" else "";
    in
    "${protocol}://${fqdn}${portPart}${pathPart}";

  mkVirtualHost =
    {
      config,
      fqdn ? config.networking.domain,
      port ? null,
      ssl ? false,
      proxyWebsockets ? false,
      recommendedProxySettings ? true,
      extraConfig ? "",
      ...
    }:
    {
      enableACME = ssl;
      forceSSL = ssl;
      locations = mkIf (port != null) {
        "/" = {
          proxyPass = mkDefault "http://127.0.0.1:${builtins.toString port}";
          inherit proxyWebsockets recommendedProxySettings extraConfig;
        };
      };
      sslCertificate = mkIf ssl "${config.security.acme.certs."${fqdn}".directory}/cert.pem";
      sslCertificateKey = mkIf ssl "${config.security.acme.certs."${fqdn}".directory}/key.pem";
    };
}
