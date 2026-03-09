{ lib, osConfig, ... }:
let
  cfg = osConfig.dotfiles;
in
{
  config = lib.mkIf (cfg.apps.terminal == "ghostty") {
    programs.ghostty = {
      enable = true;
      package = null;
      settings = {
        "font-size" = 12;
        theme = "dark:TokyoNight Storm,light:TokyoNight Day";
        "scrollback-limit" = 1000000;
        keybind = [
          "super+n=new_window"
          "super+alt+h=goto_split:left"
          "super+alt+j=goto_split:bottom"
          "super+alt+k=goto_split:top"
          "super+alt+l=goto_split:right"
          "super+ctrl+h=new_split:left"
          "super+ctrl+j=new_split:down"
          "super+ctrl+k=new_split:up"
          "super+ctrl+l=new_split:right"
          "super+ctrl+f=toggle_split_zoom"
          "super+alt+n=next_tab"
          "super+alt+p=previous_tab"
          "super+r=reload_config"
        ];
        "window-save-state" = "always";
        "auto-update-channel" = "tip";
      };
    };
  };
}
