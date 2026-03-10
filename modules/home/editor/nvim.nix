{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.dotfiles;
  hasDevelopmentProfile = cfg.profiles.development.enable;
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
        sessionoptions = "buffers,curdir,folds,help,tabpages,terminal,winsize";
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
        toggleterm = {
          enable = true;
          settings = {
            close_on_exit = false;
            direction = "float";
            float_opts.border = "curved";
            persist_mode = false;
            persist_size = false;
            start_in_insert = false;
          };
        };
        telescope = {
          enable = true;
          extensions.fzf-native.enable = true;
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
        treesitter.enable = true;
        web-devicons.enable = true;
        which-key = {
          enable = true;
          settings.spec = [
            {
              __unkeyed-1 = "<leader>c";
              group = "Codex";
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
              __unkeyed-1 = "<leader>x";
              group = "Diagnostics";
              mode = "n";
            }
          ];
        };
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

        local project_runner = {
          last_command = nil,
          terminal = nil,
        }

        local function project_root()
          local root = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })
          if vim.v.shell_error == 0 and root[1] and root[1] ~= "" then
            return root[1]
          end

          return vim.fn.getcwd()
        end

        local function session_dir()
          return vim.fn.stdpath("state") .. "/sessions"
        end

        local function session_file()
          local name = project_root():gsub("[^%w_.-]", "%%")
          return session_dir() .. "/" .. name .. ".vim"
        end

        local function save_session()
          vim.fn.mkdir(session_dir(), "p")
          vim.cmd("silent! mksession! " .. vim.fn.fnameescape(session_file()))
          vim.notify("Session saved", vim.log.levels.INFO)
        end

        local function restore_session()
          local file = session_file()
          if vim.fn.filereadable(file) == 0 then
            vim.notify("No saved session for " .. project_root(), vim.log.levels.WARN)
            return
          end

          vim.cmd("silent! source " .. vim.fn.fnameescape(file))
          vim.notify("Session restored", vim.log.levels.INFO)
        end

        local function toggle_quickfix()
          local quickfix = vim.fn.getqflist({ winid = 0 })
          if quickfix.winid and quickfix.winid ~= 0 then
            vim.cmd("cclose")
          else
            vim.cmd("copen")
          end
        end

        local function runner_terminal()
          if project_runner.terminal == nil then
            local Terminal = require("toggleterm.terminal").Terminal
            project_runner.terminal = Terminal:new({
              close_on_exit = false,
              direction = "float",
              hidden = true,
            })
          end

          return project_runner.terminal
        end

        local function run_project_command(command)
          if command == nil or command == "" then
            return
          end

          local terminal = runner_terminal()
          local root = project_root()
          local shell_command = "cd " .. vim.fn.shellescape(root) .. " && " .. command

          project_runner.last_command = command
          terminal:open()
          terminal:send(shell_command, false)
        end

        local function prompt_project_command()
          vim.ui.input({
            prompt = "Run from project root: ",
            default = project_runner.last_command or "",
          }, function(input)
            run_project_command(input)
          end)
        end

        local function rerun_project_command()
          if project_runner.last_command == nil then
            vim.notify("No previous project command in this session", vim.log.levels.WARN)
            return
          end

          run_project_command(project_runner.last_command)
        end

        local function toggle_project_terminal()
          runner_terminal():toggle()
        end

        vim.diagnostic.config({
          float = {
            border = "rounded",
            source = "if_many",
          },
          severity_sort = true,
        })

        vim.keymap.set("n", "<leader>qs", save_session, { desc = "Save session", silent = true })
        vim.keymap.set("n", "<leader>qr", restore_session, { desc = "Restore session", silent = true })
        vim.keymap.set("n", "<leader>tt", toggle_project_terminal, { desc = "Toggle project terminal", silent = true })
        vim.keymap.set("n", "<leader>pr", prompt_project_command, { desc = "Run project command", silent = true })
        vim.keymap.set("n", "<leader>pR", rerun_project_command, { desc = "Rerun project command", silent = true })
        vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics", silent = true })
        vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>", { desc = "Quickfix list", silent = true })
        vim.keymap.set("n", "<leader>xo", toggle_quickfix, { desc = "Toggle quickfix window", silent = true })
        vim.keymap.set("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix item", silent = true })
        vim.keymap.set("n", "[q", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item", silent = true })

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
