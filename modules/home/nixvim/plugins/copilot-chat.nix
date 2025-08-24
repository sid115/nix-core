{ config, lib, ... }:

let
  cfg = config.programs.nixvim;
  plugin = cfg.plugins.copilot-chat;

  inherit (lib) mkDefault mkIf;
in
{
  config = {
    programs.nixvim = {
      plugins.copilot-chat = {
        enable = mkDefault true;
        # TODO: Add keymaps
      };

      plugins.copilot-lua = mkIf plugin.enable {
        # You need to authenticate manually by running `:Copilot auth`
        enable = mkDefault true;
        settings = {
          suggestion.enabled = mkDefault false; # use copilot-cmp instead
          panel.enabled = mkDefault false; # use copilot-cmp instead
        };
      };
      keymaps = [
        {
          key = "<leader>ce";
          action = ":CopilotChatExplain<CR>";
          mode = "v";
        }
        {
          key = "<leader>cr";
          action = ":CopilotChatReview<CR>";
          mode = "v";
        }
        {
          key = "<leader>cf";
          action = ":CopilotChatFix<CR>";
          mode = "v";
        }
        {
          key = "<leader>co";
          action = ":CopilotChatOptimize<CR>";
          mode = "v";
        }
        {
          key = "<leader>cd";
          action = ":CopilotChatDocs<CR>";
          mode = "v";
        }
        {
          key = "<leader>ct";
          action = ":CopilotChatTests<CR>";
          mode = "v";
        }
      ];
    };
  };
}
