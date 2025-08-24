# Stylix

This module wraps [stylix](https://github.com/nix-community/stylix), a theming framework for NixOS, Home Manager, nix-darwin, and Nix-on-Droid.

View the [*nix-core* Home Manager module on GitHub](https://github.com/sid115/nix-core/tree/master/modules/home/stylix).

## References

- [docs](https://nix-community.github.io/stylix/)

## Usage

Add stylix to your flake inputs:

```nix
inputs = {
  stylix.url = "github:nix-community/stylix";
  stylix.inputs.nixpkgs.follows = "nixpkgs";
};
```

For example, in your home configuration, set:

```nix
imports = [ inputs.core.homeModules.stylix ];

stylix = {
  enable = true;
  scheme = "SCHEME";
};
```

Replace `SCHEME` with the name of your scheme. Available schemes are listed as `validSchemes` in [our stylix module](https://github.com/sid115/nix-core/tree/master/modules/home/stylix/default.nix).

## Create a scheme

You can create your own scheme in `schemes/<scheme>.yaml`. To make it available via `stylix.scheme`, you need to add it to `validSchemes` and `customSchemes` in [the module's `default.nix`](https://github.com/sid115/nix-core/tree/master/modules/home/stylix/default.nix). Make sure that the resulting scheme name is a valid [colorscheme in nixvim](https://github.com/nix-community/nixvim/tree/main/plugins/colorschemes).

It is recommended to set colors according to their purpose / name. This means that `base00` should always be a rather dark color for the background and `base08` a reddish color.

```yaml
# <scheme>.yaml
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

You can preview your color schemes with the [base16-viewer](https://sesh.github.io/base16-viewer/) (*Disable your dark reader*) or `print-colors` - a Python script to view color schemes in the terminal:

```bash
print-colors PATH/TO/colors.yaml
```

## Wallpaper

You can set a wallpaper with:

```nix
stylix.image = ./path/to/wallpaper.png;
```

This can be any image as a PNG file. You might want to take a look at [some Nix themed wallpapers](https://github.com/NixOS/nixos-artwork/tree/master/wallpapers) or [nix-wallpaper](https://github.com/lunik1/nix-wallpaper/tree/master) to create your own wallpaper with the Nix logo and custom colors.

Or create a solid color image with:

```bash
convert -size 3840x2160 "xc:#080808" wallpaper.png
```
