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
    dashboard = {
      enable = true;
      autoLoad = true;
    };
    lualine.enable = true;
    mini-ai.enable = true;
    mini-surround.enable = true;
    treesitter.enable = true;
    web-devicons.enable = true;
  };
}
