{
  keymaps = [
    {
      mode = "n";
      key = "<leader>/";
      action = "<cmd>Telescope live_grep<CR>";
      options.desc = "Search in project";
    }
    {
      mode = "n";
      key = "<leader>f/";
      action = "<cmd>Telescope current_buffer_fuzzy_find<CR>";
      options.desc = "Search in buffer";
    }
  ];

  plugins = {
    flash = {
      enable = true;
      settings.modes.char.enabled = false;
    };

    telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
      keymaps = {
        "<leader>fb" = {
          action = "buffers";
          options.desc = "Buffers";
        };
        "<leader>fc" = {
          action = "commands";
          options.desc = "Commands";
        };
        "<leader>fd" = {
          action = "diagnostics";
          options.desc = "Diagnostics";
        };
        "<leader>ff" = {
          action = "find_files";
          options.desc = "Files";
        };
        "<leader>fg" = {
          action = "live_grep";
          options.desc = "Live grep";
        };
        "<leader>fh" = {
          action = "help_tags";
          options.desc = "Help";
        };
        "<leader>fk" = {
          action = "keymaps";
          options.desc = "Keymaps";
        };
        "<leader>fr" = {
          action = "oldfiles";
          options.desc = "Recent files";
        };
        "<leader>fs" = {
          action = "grep_string";
          options.desc = "Search word under cursor";
        };
        "<leader>fp" = {
          action = "resume";
          options.desc = "Resume last picker";
        };
      };
    };

    which-key = {
      enable = true;
      settings.spec = [
        {
          __unkeyed-1 = "<leader>c";
          group = "Code";
          mode = "n";
        }
        {
          __unkeyed-1 = "<leader>f";
          group = "Find";
          mode = "n";
        }
        {
          __unkeyed-1 = "<leader>g";
          group = "Git";
          mode = "n";
        }
        {
          __unkeyed-1 = "<leader>p";
          group = "Project";
          mode = "n";
        }
        {
          __unkeyed-1 = "<leader>q";
          group = "Session";
          mode = "n";
        }
        {
          __unkeyed-1 = "<leader>t";
          group = "Terminal";
          mode = "n";
        }
        {
          __unkeyed-1 = "<leader>b";
          group = "Buffer";
          mode = "n";
        }
        {
          __unkeyed-1 = "<leader>x";
          group = "Diagnostics";
          mode = "n";
        }
      ];
    };
  };
}
