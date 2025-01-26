{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nixvim;
  plugin = cfg.plugins.dap;

  inherit (lib) mkDefault mkIf;
in
{
  config = {
    programs.nixvim = {
      plugins.dap = {
        enable = mkDefault true;
        extensions = {
          dap-ui.enable = true;
          dap-virtual-text.enable = true;
          dap-go.enable = true;
          dap-python.enable = true;
        };
      };

      extraPlugins = mkIf plugin.enable [ pkgs.vimPlugins.nvim-gdb ];

      extraConfigLua = mkIf plugin.enable ''
        local dap, dapui = require("dap"), require("dapui")
        dap.listeners.before.attach.dapui_config = function()
          dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
          dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
          dapui.close()
        end

        local dap = require('dap')
        dap.set_log_level('DEBUG')

        dap.adapters.lldb = {
          type = 'executable',
          command = '${pkgs.lldb_17}/bin/lldb-vscode', -- adjust as needed, must be absolute path
          name = 'lldb'
        }

        dap.adapters.gdb = {
          type = "executable",
          command = "gdb",
          args = { "-i", "dap" }
        }

        dap.configurations.c = {
          {
            name = "Launch",
            type = "gdb",
            request = "launch",
            program = function()
              return vim.fn.input('Path of the executable: ', vim.fn.getcwd() .. '/', 'file')
            end,
            cwd = "''${workspaceFolder}",
          },
        }

        dap.configurations.cpp = dap.configurations.c

        dap.configurations.rust = {
          {
            name = 'Launch',
            type = 'lldb',
            request = 'launch',
            program = function()
              return vim.fn.input('Path of the executable: ', vim.fn.getcwd() .. '/', 'file')
            end,
            cwd = "''${workspaceFolder}",
            stopOnEntry = false,
            args = {},
          },
        }

        -- Keymaps
        vim.keymap.set('n', '<F5>', function() dap.continue() end)
        vim.keymap.set('n', '<F10>', function() dap.step_over() end)
        vim.keymap.set('n', '<F11>', function() dap.step_into() end)
        vim.keymap.set('n', '<F12>', function() dap.step_out() end)
        vim.keymap.set('n', '<Leader>b', function() dap.toggle_breakpoint() end)
        vim.keymap.set('n', '<Leader>B', function() dap.set_breakpoint() end)
        vim.keymap.set('n', '<Leader>lp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
        vim.keymap.set('n', '<Leader>dr', function() dap.repl.open() end)
        vim.keymap.set('n', '<Leader>dl', function() dap.run_last() end)
        vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
          require('dap.ui.widgets').hover()
        end)
        vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
          require('dap.ui.widgets').preview()
        end)
        vim.keymap.set('n', '<Leader>df', function()
          local widgets = require('dap.ui.widgets')
          widgets.centered_float(widgets.frames)
        end)
        vim.keymap.set('n', '<Leader>ds', function()
          local widgets = require('dap.ui.widgets')
          widgets.centered_float(widgets.scopes)
        end)
      '';
    };
  };
}
