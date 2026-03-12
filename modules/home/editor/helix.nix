{
  lib,
  osConfig,
  ...
}:
let
  cfg = osConfig.platform;
in
{
  config = lib.mkIf (builtins.elem "helix" cfg.apps.enabledEditors) {
    programs.helix = {
      enable = true;
      defaultEditor = cfg.apps.editor == "helix";

      settings = {
        theme = "tokyonight_storm";
        editor = {
          line-number = "relative";
          auto-format = true;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          file-picker.hidden = false;
          indent-guides.render = true;
          lsp.display-messages = true;
          statusline = {
            left = [
              "mode"
              "spinner"
              "file-name"
              "file-modification-indicator"
            ];
            right = [
              "diagnostics"
              "selections"
              "position"
              "file-encoding"
            ];
          };
        };
      };

      languages = {
        language-server.nil = {
          command = "nil";
          config.nil.formatting.command = [ "nixfmt" ];
        };

        language = [
          {
            name = "nix";
            formatter.command = "nixfmt";
          }
          {
            name = "go";
            formatter.command = "gofmt";
          }
          {
            name = "rust";
            formatter.command = "rustfmt";
          }
          {
            name = "javascript";
            formatter = {
              command = "prettier";
              args = [ "--parser" "babel" ];
            };
          }
          {
            name = "typescript";
            formatter = {
              command = "prettier";
              args = [ "--parser" "typescript" ];
            };
          }
        ];
      };
    };
  };
}
