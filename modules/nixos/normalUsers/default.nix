{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.normalUsers;

  inherit (lib)
    attrNames
    genAttrs
    mkOption
    types
    ;
in
{
  options.normalUsers = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          extraGroups = mkOption {
            type = (types.listOf types.str);
            default = [ ];
            description = "Extra groups for the user";
            example = [ "wheel" ];
          };
          shell = mkOption {
            type = types.path;
            default = pkgs.zsh;
            description = "Shell for the user";
          };
          initialPassword = mkOption {
            type = types.str;
            default = "changeme";
            description = "Initial password for the user";
          };
          sshKeyFiles = mkOption {
            type = (types.listOf types.path);
            default = [ ];
            description = "SSH key files for the user";
            example = [ "/path/to/id_rsa.pub" ];
          };
        };
      }
    );
    default = { };
    description = "Users to create. The usernames are the attribute names.";
  };

  config = {
    # Create user groups
    users.groups = genAttrs (attrNames cfg) (userName: {
      name = userName;
    });

    # Create users
    users.users = genAttrs (attrNames cfg) (userName: {
      name = userName;
      inherit (cfg.${userName}) extraGroups shell initialPassword;

      isNormalUser = true;
      group = "${userName}";
      home = "/home/${userName}";
      openssh.authorizedKeys.keyFiles = cfg.${userName}.sshKeyFiles;
    });
  };
}
