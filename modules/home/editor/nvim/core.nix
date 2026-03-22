{
  globals.mapleader = " ";

  opts = {
    clipboard = "unnamedplus";
    confirm = true;
    cursorline = true;
    laststatus = 3;
    number = true;
    relativenumber = true;
    scrolloff = 8;
    sessionoptions = "buffers,curdir,folds,help,tabpages,terminal,winsize";
    sidescrolloff = 8;
    splitbelow = true;
    splitright = true;
    updatetime = 200;
  };

  colorschemes.onedark = {
    enable = true;
  };

  plugins = {
    comment.enable = true;
    dashboard = {
      enable = true;
      autoLoad = true;
    };
    indent-blankline.enable = true;
    lualine.enable = true;
    mini-ai.enable = true;
    mini-surround.enable = true;
    nvim-autopairs.enable = true;
    treesitter.enable = true;
    treesitter-context.enable = true;
    treesitter-textobjects = {
      enable = true;
      move = {
        enable = true;
        setJumps = true;
        gotoNextStart = {
          "]f" = {
            query = "@function.outer";
            desc = "Next function start";
          };
          "]c" = {
            query = "@class.outer";
            desc = "Next class start";
          };
        };
        gotoPreviousStart = {
          "[f" = {
            query = "@function.outer";
            desc = "Previous function start";
          };
          "[c" = {
            query = "@class.outer";
            desc = "Previous class start";
          };
        };
      };
      select = {
        enable = true;
        lookahead = true;
        keymaps = {
          "af" = {
            query = "@function.outer";
            desc = "around function";
          };
          "if" = {
            query = "@function.inner";
            desc = "inside function";
          };
          "ac" = {
            query = "@class.outer";
            desc = "around class";
          };
          "ic" = {
            query = "@class.inner";
            desc = "inside class";
          };
        };
      };
    };
    web-devicons.enable = true;
  };
}
