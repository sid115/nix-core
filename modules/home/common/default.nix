{ config, lib, ... }:

{
  imports = [
    ./zsh.nix
  ];

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  home.homeDirectory = lib.mkDefault "/home/${config.home.username}";

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # JSON formatted list of Home Manager options
  manual.json.enable = true;

  news.display = "silent";
}
