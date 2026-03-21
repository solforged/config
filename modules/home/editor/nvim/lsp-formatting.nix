{ ... }:
{
  keymaps = [
    {
      mode = "n";
      key = "gd";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      options.desc = "Go to definition";
    }
    {
      mode = "n";
      key = "gD";
      action = "<cmd>lua vim.lsp.buf.declaration()<CR>";
      options.desc = "Go to declaration";
    }
    {
      mode = "n";
      key = "gi";
      action = "<cmd>lua vim.lsp.buf.implementation()<CR>";
      options.desc = "Go to implementation";
    }
    {
      mode = "n";
      key = "gr";
      action = "<cmd>lua vim.lsp.buf.references()<CR>";
      options.desc = "References";
    }
    {
      mode = "n";
      key = "K";
      action = "<cmd>lua vim.lsp.buf.hover()<CR>";
      options.desc = "Hover";
    }
    {
      mode = "n";
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
      options.desc = "Code action";
    }
    {
      mode = "n";
      key = "<leader>cr";
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
      options.desc = "Rename symbol";
    }
    {
      mode = "n";
      key = "<leader>ci";
      action = "<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>";
      options.desc = "Toggle inlay hints";
    }
  ];

  plugins = {
    cmp = {
      enable = true;
      settings = {
        snippet.expand = ''
          function(args)
            require('luasnip').lsp_expand(args.body)
          end
        '';
        mapping = {
          "<C-n>" = "cmp.mapping.select_next_item()";
          "<C-p>" = "cmp.mapping.select_prev_item()";
          "<C-y>" = "cmp.mapping.confirm({ select = true })";
          "<C-e>" = "cmp.mapping.abort()";
          "<Tab>" = ''
            cmp.mapping(function(fallback)
              local luasnip = require('luasnip')
              if luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { 'i', 's' })
          '';
          "<S-Tab>" = ''
            cmp.mapping(function(fallback)
              local luasnip = require('luasnip')
              if luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { 'i', 's' })
          '';
        };
        sources = [
          { name = "nvim_lsp"; }
          { name = "luasnip"; }
          { name = "buffer"; }
          { name = "path"; }
        ];
      };
      cmdline = {
        ":" = {
          mapping = {
            __raw = "cmp.mapping.preset.cmdline()";
          };
          sources = [
            { name = "path"; }
            { name = "cmdline"; }
          ];
        };
      };
    };
    cmp-cmdline.enable = true;
    conform-nvim = {
      enable = true;
      settings = {
        format_on_save = {
          lsp_format = "fallback";
          timeout_ms = 500;
        };
        formatters_by_ft = {
          nix = [ "nixfmt" ];
          go = [ "gofmt" ];
          javascript = [ "prettier" ];
          javascriptreact = [ "prettier" ];
          python = [ "ruff_format" ];
          rust = [ "rustfmt" ];
          typescript = [ "prettier" ];
          typescriptreact = [ "prettier" ];
        };
      };
    };
    dressing.enable = true;
    fidget.enable = true;
    lsp = {
      enable = true;
      servers = {
        bashls.enable = true;
        gopls.enable = true;
        pyright.enable = true;
        ruff.enable = true;
        lua_ls.enable = true;
        nil_ls.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
        ts_ls.enable = true;
        yamlls.enable = true;
      };
    };
    luasnip.enable = true;
  };
}
