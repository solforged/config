{ lib, osConfig, ... }:
let
  cfg = osConfig.platform;
in
{
  config = lib.mkIf cfg.profiles.base.enable {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      enableFishIntegration = cfg.apps.shell == "fish";
      enableNushellIntegration = cfg.apps.shell == "nushell";
      enableZshIntegration = cfg.apps.shell == "zsh";
      settings = {
        mgr = {
          ratio = [
            1
            3
            4
          ];
          sort_by = "natural";
          sort_sensitive = false;
          sort_reverse = false;
          sort_dir_first = true;
          sort_translit = true;
          linemode = "none";
          show_hidden = false;
          show_symlink = true;
          scrolloff = 8;
          mouse_events = [
            "click"
            "scroll"
            "touch"
          ];
          title_format = "Yazi: {cwd}";
        };

        preview = {
          wrap = "yes";
          tab_size = 2;
          max_width = 1800;
          max_height = 1800;
          image_delay = 20;
          image_filter = "triangle";
          image_quality = 80;
        };

        input.cursor_blink = true;

        which = {
          sort_by = "key";
          sort_sensitive = false;
          sort_reverse = false;
          sort_translit = true;
        };
      };
      keymap.manager.prepend_keymap = [
        {
          on = "<C-j>";
          run = "arrow next";
          desc = "Move down (friendly Ctrl-j)";
        }
        {
          on = "<C-k>";
          run = "arrow prev";
          desc = "Move up (friendly Ctrl-k)";
        }
        {
          on = "<C-h>";
          run = "leave";
          desc = "Go to parent directory (friendly Ctrl-h)";
        }
        {
          on = "<C-l>";
          run = "enter";
          desc = "Enter directory (friendly Ctrl-l)";
        }
        {
          on = "<A-h>";
          run = "tab_switch -1 --relative";
          desc = "Previous tab (Alt-h)";
        }
        {
          on = "<A-l>";
          run = "tab_switch 1 --relative";
          desc = "Next tab (Alt-l)";
        }
        {
          on = "<A-n>";
          run = "tab_create --current";
          desc = "New tab with current directory";
        }
        {
          on = "<A-1>";
          run = "tab_switch 0";
          desc = "Switch to tab 1";
        }
        {
          on = "<A-2>";
          run = "tab_switch 1";
          desc = "Switch to tab 2";
        }
        {
          on = "<A-3>";
          run = "tab_switch 2";
          desc = "Switch to tab 3";
        }
        {
          on = "<A-4>";
          run = "tab_switch 3";
          desc = "Switch to tab 4";
        }
        {
          on = "<A-5>";
          run = "tab_switch 4";
          desc = "Switch to tab 5";
        }
        {
          on = "<A-6>";
          run = "tab_switch 5";
          desc = "Switch to tab 6";
        }
        {
          on = "<A-7>";
          run = "tab_switch 6";
          desc = "Switch to tab 7";
        }
        {
          on = "<A-8>";
          run = "tab_switch 7";
          desc = "Switch to tab 8";
        }
        {
          on = "<A-9>";
          run = "tab_switch 8";
          desc = "Switch to tab 9";
        }
        {
          on = [
            "g"
            "?"
          ];
          run = "help";
          desc = "Open help";
        }
      ];
    };
  };
}
