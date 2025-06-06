{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nixvim;
  plugin = cfg.plugins.lsp;

  inherit (lib) mkDefault mkIf;
in
{
  config = {
    programs.nixvim = {
      plugins = {
        lsp-format = mkIf plugin.enable { enable = mkDefault true; };

        lsp = {
          enable = mkDefault true;
          postConfig = '''';
          keymaps = {
            silent = mkDefault true;
            diagnostic = mkDefault {
              # Navigate in diagnostics
              "<leader>k" = "goto_prev";
              "<leader>j" = "goto_next";
            };

            lspBuf = mkDefault {
              gd = "definition";
              gD = "references";
              gt = "type_definition";
              gi = "implementation";
              K = "hover";
              "<F2>" = "rename";
            };
          };

          servers = {
            bashls.enable = mkDefault true;
            clangd.enable = mkDefault true;
            cssls.enable = mkDefault true;
            dockerls.enable = mkDefault true;
            gopls.enable = mkDefault true;
            html.enable = mkDefault true;
            jsonls.enable = mkDefault true;
            nil_ls = {
              enable = mkDefault true;
              settings.nix.flake.autoArchive = false;
              settings.formatting.command = mkDefault [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];
            };
            pyright.enable = mkDefault true;
            rust_analyzer = {
              enable = mkDefault true;
              installCargo = mkDefault true;
              installRustc = mkDefault true;
              settings.rustfmt.overrideCommand = mkDefault [
                "${pkgs.rustfmt}/bin/rustfmt --edition 2021" # --config tab_spaces=2"
              ];
            };
            texlab.enable = mkDefault true;
            vhdl_ls.enable = mkDefault true;
            yamlls.enable = mkDefault true;
          };
        };
      };
    };
  };
}
