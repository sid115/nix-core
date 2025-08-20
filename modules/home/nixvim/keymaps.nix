[
  # cursor navigation
  {
    # scroll down, recenter
    key = "<C-d>";
    action = "<C-d>zz";
    mode = "n";
  }
  {
    # scroll up, recenter
    key = "<C-u>";
    action = "<C-u>zz";
    mode = "n";
  }

  # searching
  {
    # center cursor after search next
    key = "n";
    action = "nzzzv";
    mode = "n";
  }
  {
    # center cursor after search previous
    key = "N";
    action = "Nzzzv";
    mode = "n";
  }
  {
    # ex command
    key = "<leader>pv";
    action = "<cmd>Ex<CR>";
    mode = "n";
  }

  # search and replace
  {
    # search and replace word under cursor
    key = "<leader>s";
    action = ":%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>";
    mode = "n";
  }
  # search and replace selected text
  {
    key = "<leader>s";
    action = "y:%s/<C-r>0/<C-r>0/gI<Left><Left><Left>";
    mode = "v";
  }

  # clipboard operations
  {
    # copy to system clipboard in visual mode
    key = "<C-c>";
    action = ''"+y '';
    mode = "v";
  }
  {
    # paste from system clipboard in visual mode
    key = "<C-v>";
    action = ''"+p '';
    mode = "v";
  }
  {
    # yank to system clipboard
    key = "<leader>Y";
    action = "+Y";
    mode = "n";
  }
  {
    # replace selected text with clipboard content
    key = "<leader>p";
    action = "_dP";
    mode = "x";
  }
  {
    # delete without copying to clipboard
    key = "<leader>d";
    action = "_d";
    mode = [
      "n"
      "v"
    ];
  }

  # line operations
  {
    # move lines down in visual mode
    key = "J";
    action = ":m '>+1<CR>gv=gv";
    mode = "v";
  }
  {
    # move lines up in visual mode
    key = "K";
    action = ":m '<-2<CR>gv=gv";
    mode = "v";
  }
  {
    # join lines
    key = "J";
    action = "mzJ`z";
    mode = "n";
  }

  # quickfix
  {
    # Run make command
    key = "<leader>m";
    action = "<cmd>:make<CR>";
    mode = "n";
  }
  {
    # previous quickfix item
    key = "<C-A-J>";
    action = "<cmd>cprev<CR>zz";
    mode = "n";
  }
  {
    # next quickfix item
    key = "<C-A-K>";
    action = "<cmd>cnext<CR>zz";
    mode = "n";
  }

  # location list navigation
  {
    # previous location list item
    key = "<leader>j";
    action = "<cmd>lprev<CR>zz";
    mode = "n";
  }
  {
    # next location list item
    key = "<leader>k";
    action = "<cmd>lnext<CR>zz";
    mode = "n";
  }

  # disabling keys
  {
    # disable the 'Q' key
    key = "Q";
    action = "<nop>";
    mode = "n";
  }

  # text selection
  {
    # select whole buffer
    key = "<C-a>";
    action = "ggVG";
    mode = "n";
  }

  # window operations
  {
    # focus next window
    key = "<C-j>";
    action = ":wincmd W<CR>";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }
  {
    # focus previous window
    key = "<C-k>";
    action = ":wincmd w<CR>";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }

  # window size adjustments
  {
    # increase window width
    key = "<C-l>";
    action = ":vertical resize +5<CR>";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }
  {
    # decrease window width
    key = "<C-h>";
    action = ":vertical resize -5<CR>";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }

  # window closing and opening
  {
    # close current window
    key = "<leader-S>c";
    action = ":q<CR>";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }
  {
    # new vertical split at $HOME
    key = "<leader>n";
    action = ":vsp $HOME<CR>";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }

  # window split orientation toggling
  {
    # toggle split orientation
    key = "<leader>t";
    action = ":wincmd T<CR>";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }

  # spell checking
  {
    # toggle spell checking
    key = "<leader>ss";
    action = ":setlocal spell!<CR>";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }
  {
    # switch to english spell checking
    key = "<leader>se";
    action = ":setlocal spelllang=en_us<CR>";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }
  {
    # switch to german spell checking
    key = "<leader>sg";
    action = ":setlocal spelllang=de_20<CR>";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }
  {
    # move to next misspelling
    key = "]s";
    action = "]szz";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }
  {
    # move to previous misspelling
    key = "[s";
    action = "[szz";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }
  {
    # correction suggestions for a misspelled word
    key = "z=";
    action = "z=";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }
  {
    # adding words to the dictionary
    key = "zg";
    action = "zg";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }

  # buffer navigation
  {
    # next buffer
    key = "<C-S-J>";
    action = ":bnext<CR>";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }
  {
    # previous buffer
    key = "<C-S-K>";
    action = ":bprevious<CR>";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }
  {
    # close current buffer
    key = "<leader>bd";
    action = ":bdelete<CR>";
    options = {
      noremap = true;
      silent = true;
    };
    mode = "n";
  }
]
