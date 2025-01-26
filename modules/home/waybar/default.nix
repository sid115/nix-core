{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.waybar;

  clock = {
    format = mkDefault "{:%a %d %b  %H:%M}";
    tooltip-format = mkDefault "<tt><small>{calendar}</small></tt>";
    timezone = mkDefault "Europe/Berlin";
    locale = mkDefault "en_US.UTF-8";
    calendar = {
      mode = mkDefault "year";
      mode-mon-col = mkDefault 3;
      weeks-pos = mkDefault "right";
      on-scroll = mkDefault 1;
    };
    actions = {
      on-click-right = mkDefault "mode";
      on-click-forward = mkDefault "tz_up";
      on-click-backward = mkDefault "tz_down";
      on-scroll-up = mkDefault "shift_up";
      on-scroll-down = mkDefault "shift_down";
    };
  };

  "hyprland/workspaces" = {
    active-only = mkDefault false;
    all-outputs = mkDefault false;
    format = mkDefault "{name}";
    on-click = mkDefault "activate";
    on-scroll-up = mkDefault "hyprctl dispatch workspace e-1";
    on-scroll-down = mkDefault "hyprctl dispatch workspace e+1";
  };

  keyboard-state = {
    numlock = mkDefault true;
    capslock = mkDefault true;
    scrolllock = mkDefault true;
    format = {
      scrolllock = mkDefault "S ";
      capslock = mkDefault "C ";
      numlock = mkDefault "N";
    };
  };

  "hyprland/language" = {
    format = mkDefault "{}";
    format-en = mkDefault "us";
    format-de = mkDefault "de";
    # TODO: switch language on click
  };

  # Add your custom modules here
  "custom/newsboat" = import ./modules/newsboat.nix { inherit lib pkgs; };
  "pulseaudio#input" = import ./modules/pulseaudio/input.nix { inherit lib pkgs; };
  "pulseaudio#output" = import ./modules/pulseaudio/output.nix { inherit lib pkgs; };
  battery = import ./modules/battery.nix { inherit lib; };
  bluetooth = import ./modules/bluetooth.nix { inherit lib; };
  cpu = import ./modules/cpu.nix { inherit lib; };
  disk = import ./modules/disk.nix { inherit lib; };
  memory = import ./modules/memory.nix { inherit lib; };
  network = import ./modules/network.nix { inherit lib; };
  wireplumber = import ./modules/wireplumber.nix { inherit lib; };

  inherit (lib) mkDefault mkIf;
in
{
  imports = [
    ./modules/timer # TODO: Do not use imports. Move to let-in-block.
  ];

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ font-awesome ];

    programs.waybar = {
      systemd.enable = mkDefault true;
      settings = {
        mainBar = {
          output = mkDefault "";
          modules-left = mkDefault [
            "hyprland/workspaces"
            "keyboard-state"
            "hyprland/language"
          ];
          modules-center = mkDefault [ "clock" ];
          modules-right = mkDefault [
            "network"
            "cpu"
            "memory"
            "disk"
            "pulseaudio#input"
            "pulseaudio#output"
            "tray"
          ];

          inherit
            "custom/newsboat"
            "hyprland/language"
            "hyprland/workspaces"
            "pulseaudio#input"
            "pulseaudio#output"
            battery
            bluetooth
            clock
            cpu
            disk
            keyboard-state
            memory
            network
            wireplumber
            ;
        };
        otherBar = {
          output = with cfg.settings.mainBar; if (output != "") then "!${output}" else "nowhere";
          modules-left = mkDefault [
            "hyprland/workspaces"
          ];
          modules-center = mkDefault [ "clock" ];

          inherit
            "hyprland/workspaces"
            clock
            ;
        };
      };
    };
  };
}
