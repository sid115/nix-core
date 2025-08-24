{
  imports = [
    ./nationalization.nix
    ./networking.nix
    ./nix.nix
    ./packages.nix
    ./shellAliases.nix
    ./zsh.nix
  ];

  nixpkgs.config.allowUnfree = true;

  programs.dconf.enable = true; # fixes nixvim hm module

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
