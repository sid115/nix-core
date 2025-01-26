{ config, pkgs, ... }:

# pass the mode (output, window, region) as a command line argument

let
  screenshotDir = "${config.xdg.userDirs.pictures}/screenshots";
in
(pkgs.writeShellScriptBin "screenshot" ''
  mkdir -p ${screenshotDir}
  ${pkgs.hyprshot}/bin/hyprshot --mode $1 --output-folder ${screenshotDir} --filename screenshot_$(date +"%Y-%m-%d_%H-%M-%S").png
'')
