{
  keymaps = [
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>LazyGit<CR>";
      options.desc = "Lazygit";
    }
    {
      mode = "n";
      key = "<leader>gs";
      action = "<cmd>Telescope git_status<CR>";
      options.desc = "Git status";
    }
    {
      mode = "n";
      key = "<leader>gc";
      action = "<cmd>Telescope git_commits<CR>";
      options.desc = "Git commits";
    }
    {
      mode = "n";
      key = "<leader>gB";
      action = "<cmd>Telescope git_branches<CR>";
      options.desc = "Git branches";
    }
    {
      mode = "n";
      key = "<leader>gd";
      action = "<cmd>DiffviewOpen<CR>";
      options.desc = "Diff working tree";
    }
    {
      mode = "n";
      key = "<leader>gD";
      action = "<cmd>DiffviewClose<CR>";
      options.desc = "Close diffview";
    }
    {
      mode = "n";
      key = "<leader>gh";
      action = "<cmd>DiffviewFileHistory %<CR>";
      options.desc = "File history";
    }
    {
      mode = "n";
      key = "<leader>xx";
      action = "<cmd>Trouble diagnostics toggle<CR>";
      options.desc = "Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>xq";
      action = "<cmd>Trouble qflist toggle<CR>";
      options.desc = "Quickfix list";
    }
    {
      mode = "n";
      key = "]q";
      action = "<cmd>cnext<CR>zz";
      options.desc = "Next quickfix item";
    }
    {
      mode = "n";
      key = "[q";
      action = "<cmd>cprev<CR>zz";
      options.desc = "Previous quickfix item";
    }
  ];

  plugins = {
    diffview.enable = true;
    gitsigns.enable = true;
    lazygit.enable = true;
    nvim-bqf.enable = true;
    todo-comments = {
      enable = true;
      keymaps = {
        todoTelescope = {
          key = "<leader>fT";
          options.desc = "TODO comments";
        };
        todoTrouble = {
          key = "<leader>xT";
          options.desc = "TODO comments";
        };
      };
    };
    trouble = {
      enable = true;
      settings = {
        auto_close = false;
        auto_open = false;
        auto_preview = false;
        focus = true;
        follow = true;
        indent_guides = true;
        restore = true;
      };
    };
  };
}
