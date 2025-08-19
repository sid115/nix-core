{
  inputs,
  config,
  lib,
  ...
}:

let
  inherit (lib) mkDefault mkIf;
in
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./plugins

    ./spellfiles.nix
  ];

  config = {
    programs.nixvim = {
      clipboard.providers.wl-copy.enable = mkDefault true;
      defaultEditor = mkDefault true;
      enableMan = mkDefault true;
      viAlias = mkDefault true;
      vimAlias = mkDefault true;
      vimdiffAlias = mkDefault true;

      # vim.g.*
      globals = {
        mapleader = mkDefault " ";
      };

      # vim.opt.*
      opts = {
        # behavior
        cursorline = mkDefault true; # highlights the line under the cursor
        mouse = mkDefault "a"; # enable mouse support
        nu = mkDefault true; # line numbers
        relativenumber = mkDefault true; # relative line numbers
        scrolloff = mkDefault 20; # keeps some context above/below cursor
        signcolumn = mkDefault "yes"; # reserve space for signs (e.g., GitGutter)
        undofile = mkDefault true; # persistent undo
        updatetime = mkDefault 500; # ms to wait for trigger an event (default 4000ms)
        wrap = mkDefault true; # wraps text if it exceeds the width of the window

        # search
        ignorecase = mkDefault true; # ignore case in search patterns
        smartcase = mkDefault true; # smart case
        incsearch = mkDefault true; # incremental search
        hlsearch = mkDefault true; # highlight search

        # windows
        splitbelow = mkDefault true; # new windows are created below current
        splitright = mkDefault true; # new windows are created to the right of current
        equalalways = mkDefault true; # window sizes are automatically updated.

        # tabs
        expandtab = mkDefault true; # convert tabs into spaces
        shiftwidth = mkDefault 2; # number of spaces to use for each step of (auto)indent
        smartindent = mkDefault true; # smart autoindenting on new lines
        softtabstop = mkDefault 2; # number of spaces in tab when editing
        tabstop = mkDefault 2; # number of visual spaces per tab

        # spell checking
        spell = mkDefault true;
        spelllang = mkDefault [
          "en_us"
          "de_20"
        ];

      };

      extraConfigLua = ''
        vim.cmd "set noshowmode"  -- Hides "--INSERT--" mode indicator
      '';

      keymaps = import ./keymaps.nix;
    };
  };
}
