{ inputs, outputs, ... }:

{
  imports = [
    inputs.core.homeModules.common
    inputs.core.homeModules.nixvim

    outputs.nixosModules.common
  ];

  home.username = "USERNAME";

  programs.git = {
    enable = true;
    userName = "GIT_NAME";
    userEmail = "GIT_EMAIL";
  };

  programs.nixvim.enable = true;

  home.stateVersion = "24.11";
}
