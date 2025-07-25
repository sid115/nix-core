{ lib, ... }:

{
  imports = [
    ./cmp.nix
    ./copilot-chat.nix
    ./lsp.nix
    ./lualine.nix
    ./telescope.nix
    ./treesitter.nix
    ./trouble.nix
  ];

  config.programs.nixvim.plugins = {
    luasnip.enable = lib.mkDefault true;
    markdown-preview.enable = lib.mkDefault true;
    # warning: Nixvim: `plugins.web-devicons` was enabled automatically because the following plugins are enabled. This behaviour is deprecated. Please explicitly define `plugins.web-devicons.enable`
    web-devicons.enable = true;
  };
}
