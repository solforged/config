{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.dotfiles;
  hasDevelopmentProfile = lib.elem "development" cfg.profiles;
in
{
  config = lib.mkIf (cfg.apps.editor == "nvim") {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      globals.mapleader = " ";

      opts = {
        number = true;
        relativenumber = true;
        scrolloff = 8;
        sidescrolloff = 8;
      };

      colorschemes.tokyonight = {
        enable = true;
        settings.style = "storm";
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>e";
          action = "<cmd>Neotree toggle<CR>";
          options.desc = "Toggle explorer";
        }
        {
          mode = "n";
          key = "<leader>ff";
          action = "<cmd>Telescope find_files<CR>";
          options.desc = "Find files";
        }
        {
          mode = "n";
          key = "<leader>fg";
          action = "<cmd>Telescope live_grep<CR>";
          options.desc = "Live grep";
        }
        {
          mode = "n";
          key = "<leader>fb";
          action = "<cmd>Telescope buffers<CR>";
          options.desc = "Buffers";
        }
        {
          mode = "n";
          key = "<leader>fh";
          action = "<cmd>Telescope help_tags<CR>";
          options.desc = "Help";
        }
      ];

      plugins = {
        cmp.enable = true;
        conform-nvim = {
          enable = true;
          settings = {
            format_on_save = {
              lsp_format = "fallback";
              timeout_ms = 500;
            };
            formatters_by_ft = {
              nix = [ "nixfmt" ];
            }
            // lib.optionalAttrs hasDevelopmentProfile {
              go = [ "gofmt" ];
              rust = [ "rustfmt" ];
              javascript = [ "prettier" ];
              javascriptreact = [ "prettier" ];
              typescript = [ "prettier" ];
              typescriptreact = [ "prettier" ];
            };
          };
        };
        gitsigns.enable = true;
        lsp = {
          enable = true;
          servers = {
            nil_ls.enable = true;
          }
          // lib.optionalAttrs hasDevelopmentProfile {
            gopls.enable = true;
            rust_analyzer = {
              enable = true;
              installCargo = false;
              installRustc = false;
            };
            ts_ls.enable = true;
          };
        };
        lualine.enable = true;
        neo-tree.enable = true;
        telescope = {
          enable = true;
          extensions.fzf-native.enable = true;
        };
        treesitter.enable = true;
        web-devicons.enable = true;
      };

      extraPlugins = with pkgs.vimPlugins; [
        zellij-nav-nvim
      ];

      extraConfigLua = ''
        require("neo-tree").setup({
          filesystem = {
            filtered_items = {
              hide_dotfiles = false,
              hide_gitignored = false,
            },
          },
          window = {
            mappings = {
              ["<Tab>"] = "toggle_node",
            },
          },
        })

        require("zellij-nav").setup({})

        if vim.env.ZELLIJ ~= nil then
          vim.keymap.set({ "n", "t" }, "<C-h>", "<cmd>ZellijNavigateLeft<CR>", { silent = true, desc = "Navigate left" })
          vim.keymap.set({ "n", "t" }, "<C-j>", "<cmd>ZellijNavigateDown<CR>", { silent = true, desc = "Navigate down" })
          vim.keymap.set({ "n", "t" }, "<C-k>", "<cmd>ZellijNavigateUp<CR>", { silent = true, desc = "Navigate up" })
          vim.keymap.set({ "n", "t" }, "<C-l>", "<cmd>ZellijNavigateRight<CR>", { silent = true, desc = "Navigate right" })
        end
      '';
    };
  };
}
