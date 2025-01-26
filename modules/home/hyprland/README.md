# Hyprland

This module extends the options of and sets some defaults for [Hyprland](https://hyprland.org/):

- XDG Desktop Portal for screen sharing on Wayland
- XDG mime support and user directories
- enable Waybar as status bar
- enable dunst as notification service
- some [packages](./packages.nix)
- [keybindings](./binds/default.nix)
- manage default applications via the new `applications` option

> Always import both NixOS and Home Manager modules from `nix-core` when using Hyprland.

## Keybindings

The ["Master Layout"](https://wiki.hyprland.org/Configuring/Master-Layout/) is the only supported window layout.

> `$mod`, `modifier` or `SUPER` refer to the same key which is the Windows key by default.

Keybinding | Function
---|---
`SUPER SHIFT c` | Kill active window
`SUPER 0..9` | Focus workspace 1-10 (`0` maps to workspace 10)
`SUPER SHIFT 0..9` | Move active window to workspace 1-10
`SUPER CTRL 0..9` | Focus workspace 1-10 on active monitor (moves if necessary)
`SUPER Tab` | Focus previous workspace on active monitor
`SUPER SHIFT Tab` | Move active window to previous workspace on active monitor
`SUPER Comma` | Focus left monitor
`SUPER Period` | Focus right monitor
`SUPER SHIFT Comma` |  Move active workspace to left monitor
`SUPER SHIFT Period` | Move active workspace to right monitor
`SUPER SHIFT Return` | Make active window master
`SUPER CTRL Return` | Focus master window
`SUPER j` | Focus next window
`SUPER k` | Focus previous window
`SUPER SHIFT j` | Swap active window with the next window
`SUPER SHIFT k` | Swap active window with the previous window
`SUPER h` | Decrease horizontal space of master stack
`SUPER l` | Increase horizontal space of master stack
`SUPER SHIFT h` | Shrink active window vertically
`SUPER SHIFT l` | Expand active window vertically
`SUPER i` | Add active window to master stack
`SUPER SHIFT i` | Remove active window from master stack
`SUPER o` | Toggle between left and top orientation
`SUPER Left` | Focus window to the left
`SUPER Right` | Focus window to the right
`SUPER Up` | Focus upper window
`SUPER Down` | Focus lower window
`SUPER SHIFT Left` | Swap active window with window to the left
`SUPER SHIFT Right` | Swap active window with window to the right
`SUPER SHIFT Up` | Swap active window with upper window
`SUPER SHIFT Down` | Swap active window with lower window
`SUPER f` | Toggle floating for active window
`SUPER CTRL f` | Toggle floating for all windows on workspace
`SUPER SHIFT f` | Toggle fullscreen for active window
`SUPER LMB` | Move window by dragging
`SUPER RMB` | Resize window by dragging

Some [media keys](./binds/mediakeys.nix) are also supported.

## Default applications

For clarification purposes, let's define the following terms:

- `<application>`: The literal name of the application/program. For example, `firefox`.
- `<category>`: The category of the application. For example, `browser`.
- `<exec-field-code>`: Available options are listed [here](https://specifications.freedesktop.org/desktop-entry-spec/latest/exec-variables.html). For example, `%U`.

To add default applications to Hyprland, you need to do the following steps:

### 1. Look for an existing category

Check if a fitting category for your application exists in [`applications/default.nix`](./applications/default.nix).
Categories are listed under `options.wayland.windowManager.hyprland.applications`, for example:

```nix
# ...
emailclient = mkAppAttrs {
  default = "thunderbird";
  bind = [ "$mod, m, exec, ${emailclient}" ];
};

filemanager = mkAppAttrs {
  default = "lf";
  bind = [ "$mod, e, exec, ${terminal} -T ${filemanager} -e ${filemanager}" ];
  windowRule = [
    "float, title:^${filemanager}$"
    "size 50% 50%, title:^${filemanager}$"
  ];
};
# ...
```

If no fitting category exists, create a new one and assign a default application with optional binds and window rules.

### 2. Create a directory to configure the application in

```nix
# applications/<application>/default.nix

{ inputs, outputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wayland.windowManager.hyprland;
  app = cfg.applications.<category>;
in
{
  imports = [
    # Import a module if available.
    outputs.homeModules.<application> # or `inputs.core.homeModules.<application>`
  ];

  config = mkIf (cfg.enable && app == "<application>") {
    programs.<application> = {
      enable = true;
      # Add more config here if needed.
    };

    # Define a desktop entry if the app's module or package does not ship with one
    xdg.desktopEntries.<application> = {
      name = "<application>"; # Use capital letters. For example, "Firefox".
      genericName = "<category>"; # Be a bit more specific. For example, "Web Browser".
      exec = "<application> <exec-field-code>"; # Program to execute, possibly with arguments.
      terminal = false; #  Whether the program runs in a terminal window.
      mimeType = [ "<mime1>" "<mime2>" ]; # The MIME type(s) supported by this application. For example, "text/html".
    };
  };
}
```

> The function [`genMimeAssociations`](./applications/genMimeAssociations.nix) might be useful here. See [`feh`'s config](./applications/feh/default.nix) as an example.

> Available MIME types can be found [here](https://www.iana.org/assignments/media-types/media-types.xhtml).

### 3. Import the directory

You then need to import this directory in [`applications/default.nix`](./applications/default.nix).
Look for the comment `# add your application directories here`:

```nix
# applications/default.nix

imports = [
  ./lf
  ./thunderbird
  # add your application directories here
];
```
