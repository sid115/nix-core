# Nixvim

This module provides some defaults to quickly set up Nixvim with some plugins. Here is an example configuration:

```nix
# flake.nix
inputs = {
  nixvim.url = "github:nix-community/nixvim/nixos-24.11";
  nixvim.inputs.nixpkgs.follows = "nixpkgs";
};
```

> Replace `24.11` with your `nixpkgs` version.

```nix
# home/YOU/default.nix
{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    inputs.core.homeModules.styling # This module works great with the styling module
    inputs.core.homeMmodules.nixvim # You need to import this module
  ];

  programs.nixvim = {
    enable = true;
    #colorschemes.SCHEME.enable = true; # If you do not use the styling module, set a scheme manually
    # This module provides defaults for the following plugins.
    # They are all enabled by default.
    plugins = {
      cmp.enable = true; # Auto completion
      copilot-chat.enable = true; # Chat with GitHub Copilot. Run `:Copilot auth` to authenticate
      copilot-lua.enable = true; # AI code generation.
      dap.enable = true; # Debugging 
      lsp.enable = true; # Language server
      lualine.enable = true; # Statusline
      luasnip.enable = true; # Coding snippets
      markdown-preview.enable = true; # Markdown preview in Browser
      telescope.enable = true; # Fuzzy finder
      treesitter.enable = true; # Syntax highlighting
      trouble.enable = true; # Diagnostic messages
    };
  };

  styling = {
    enable = true;
    scheme = "dracula"; # This automatically sets the nixvim scheme as well
  };
}
```

## Keymaps

This module sets some keymaps. Here are some important ones:

> `<leader>` defaults to the space key

key | action
---|---
`<leader>pv` | ex command (file explorer)
`<leader>s` | search and replace word under cursor
`<C-a>` | select whole buffer
`<leader>ss` | toggle spell checking
`<leader>se` | switch to english spell checking
`<leader>sg` | switch to german spell checking
`z=` | correction suggestions for a misspelled word
`zg` | add word to spell list
`<CR>` | confirm selection in completion menu
`<Tab>` | select next item in completion menu
`gd` | go to definition
`K` | display more information about word under cursor
`<leader>fb` or `<C-e>` | open file browser
`<leader>ff` | find files by name
`<leader>fg` | find files containing string
`<leader>ce` | let copilot explains the selected code
`<leader>cr` | let copilot review the selected code
`<leader>cf` | let copilot fix the selected code
`<leader>co` | let copilot optimize the selected code
`<leader>cd` | let copilot comment the selected code
`<leader>ct` | let copilot generate tests for the selected code

See [keymaps.nix](./keymaps.nix) and [plugins](./plugins/) for more details.

These commands do not have keymaps yet but might be useful anyway:

command | action
---|---
`:CopilotChat <question>` | ask Copilot a question
`:MarkdownPreview` | live render the current markdown buffer
