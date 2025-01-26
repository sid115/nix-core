# Custom styling

This module wraps [stylix](https://github.com/danth/stylix) to streamline the process of setting a color scheme and styles for your applications.

Stylix colorizes most applications by default (see [`stylix.targets`](https://stylix.danth.me/options/hm.html)). Some custom color and style settings for various applications can be found in the [`custom` directory](./custom).

## Usage

Add stylix to your flake inputs:

```nix
inputs = {
  stylix.url = "github:danth/stylix/release-24.11";
  stylix.inputs.nixpkgs.follows = "nixpkgs";
};
```

> Replace `24.11` with your `nixpkgs` version.

For example, in your home configuration, set:

```nix
imports = [ inputs.core.homeModules.styling ];

styling = {
  enable = true;
  gaps = 8;
  radius = 4;
  scheme = "SCHEME";
};
```

Replace `SCHEME` with the name of your scheme. Available schemes can be found in the [`schemes` directory](./schemes).

## Create a scheme

You can create your own scheme in the `schemes` directory by creating a subdirectory with the name of your scheme. Inside this subdirectory, you need two files: `colors.yaml` and `wallpaper.png`.

It is recommended to set colors according to their purpose / name. This means that `base00` should always be a rather dark color for the background and `base08` a reddish color.

### 1. Color scheme

```yaml
# colors.yaml
system: "base16"
name: "SCHEME"
author: "AUTHOR"
description: "A dark theme inspired by the SCHEME color scheme."
slug: "SCHEME-theme"
variant: "dark"
palette:
  base00: "080808" # background
  base01: "323437" # alternate background
  base02: "9e9e9e" # selection background
  base03: "bdbdbd" # comments
  base04: "b2ceee" # alternate text
  base05: "c6c6c6" # default text
  base06: "e4e4e4" # light foreground
  base07: "eeeeee" # light background
  base08: "ff5454" # error / red
  base09: "cf87e8" # urgent / orange
  base0A: "8cc85f" # warning / yellow
  base0B: "e3c78a" # green
  base0C: "79dac8" # cyan
  base0D: "80a0ff" # blue
  base0E: "36c692" # magenta
  base0F: "74b2ff" # brown
```

Refer to [Stylix's style guide](https://stylix.danth.me/styling.html) for more information on where and how these colors will be used.

You can preview your color schemes with the [base16-viewer](https://sesh.github.io/base16-viewer/) (*Disable your dark reader*).

### 2. Wallpaper

This can be any image as a PNG file. You might want to take a look at [some Nix themed wallpapers](https://github.com/NixOS/nixos-artwork/tree/master/wallpapers) or [nix-wallpaper](https://github.com/lunik1/nix-wallpaper/tree/master) to create your own wallpaper with the Nix logo and custom colors.

Or create a solid color image with:

```bash
convert -size 3840x2160 "xc:#080808" wallpaper.png
```
