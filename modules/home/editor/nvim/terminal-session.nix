{ pkgs, ... }:
{
  keymaps = [
    {
      mode = "n";
      key = "<leader>pR";
      action = "<cmd>lua DotfilesProject.rerun()<CR>";
      options.desc = "Rerun project command";
    }
    {
      mode = "n";
      key = "<leader>pr";
      action = "<cmd>lua DotfilesProject.prompt()<CR>";
      options.desc = "Run project command";
    }
    {
      mode = "n";
      key = "<leader>qr";
      action = "<cmd>lua DotfilesSession.restore()<CR>";
      options.desc = "Restore session";
    }
    {
      mode = "n";
      key = "<leader>qs";
      action = "<cmd>lua DotfilesSession.save()<CR>";
      options.desc = "Save session";
    }
    {
      mode = "n";
      key = "<leader>qd";
      action = "<cmd>Dashboard<CR>";
      options.desc = "Dashboard";
    }
    {
      mode = "n";
      key = "<leader>tt";
      action = "<cmd>lua DotfilesProject.toggle_terminal()<CR>";
      options.desc = "Toggle project terminal";
    }
    {
      mode = "n";
      key = "<leader>xo";
      action = "<cmd>lua DotfilesQuickfix.toggle()<CR>";
      options.desc = "Toggle quickfix window";
    }
  ];

  plugins.toggleterm = {
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

    local flash = require("flash")
    local project_runner = {
      last_command = nil,
      terminal = nil,
    }

    DotfilesQuickfix = {}
    DotfilesProject = {}
    DotfilesSession = {}

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

    function DotfilesSession.save()
      vim.fn.mkdir(session_dir(), "p")
      vim.cmd("silent! mksession! " .. vim.fn.fnameescape(session_file()))
      vim.notify("Session saved", vim.log.levels.INFO)
    end

    function DotfilesSession.restore()
      local file = session_file()
      if vim.fn.filereadable(file) == 0 then
        vim.notify("No saved session for " .. project_root(), vim.log.levels.WARN)
        return
      end

      vim.cmd("silent! source " .. vim.fn.fnameescape(file))
      vim.notify("Session restored", vim.log.levels.INFO)
    end

    function DotfilesQuickfix.toggle()
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

    function DotfilesProject.prompt()
      vim.ui.input({
        prompt = "Run from project root: ",
        default = project_runner.last_command or "",
      }, function(input)
        run_project_command(input)
      end)
    end

    function DotfilesProject.rerun()
      if project_runner.last_command == nil then
        vim.notify("No previous project command in this session", vim.log.levels.WARN)
        return
      end

      run_project_command(project_runner.last_command)
    end

    function DotfilesProject.toggle_terminal()
      runner_terminal():toggle()
    end

    vim.diagnostic.config({
      float = {
        border = "rounded",
        source = "if_many",
      },
      severity_sort = true,
    })

    vim.keymap.set("n", "<leader>j", function()
      flash.jump()
    end, { desc = "Jump", silent = true })
    vim.keymap.set("n", "<leader>J", function()
      flash.treesitter()
    end, { desc = "Treesitter jump", silent = true })

    if vim.env.ZELLIJ ~= nil then
      vim.keymap.set({ "n", "t" }, "<C-h>", "<cmd>ZellijNavigateLeft<CR>", { silent = true, desc = "Navigate left" })
      vim.keymap.set({ "n", "t" }, "<C-j>", "<cmd>ZellijNavigateDown<CR>", { silent = true, desc = "Navigate down" })
      vim.keymap.set({ "n", "t" }, "<C-k>", "<cmd>ZellijNavigateUp<CR>", { silent = true, desc = "Navigate up" })
      vim.keymap.set({ "n", "t" }, "<C-l>", "<cmd>ZellijNavigateRight<CR>", { silent = true, desc = "Navigate right" })
    end
  '';
}
