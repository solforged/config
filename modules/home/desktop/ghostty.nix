{ lib, osConfig, ... }:
let
  cfg = osConfig.dotfiles;
in
{
  config = lib.mkIf (cfg.apps.terminal == "ghostty") {
    programs.ghostty = {
      enable = true;
      package = null;
      enableZshIntegration = cfg.apps.shell == "zsh";
      settings = {
        "font-size" = 12;
        theme = "dark:TokyoNight Storm,light:TokyoNight Storm";
        "scrollback-limit" = 1000000;
        keybind = [
          # Window
          "super+n=new_window"

          # Splits
          "super+alt+h=goto_split:left"
          "super+alt+j=goto_split:bottom"
          "super+alt+k=goto_split:top"
          "super+alt+l=goto_split:right"
          "super+ctrl+h=new_split:left"
          "super+ctrl+j=new_split:down"
          "super+ctrl+k=new_split:up"
          "super+ctrl+l=new_split:right"
          "super+ctrl+minus=new_split:down"
          "super+ctrl+shift+backslash=new_split:right"
          "super+ctrl+f=toggle_split_zoom"
          "super+ctrl+e=equalize_splits"

          # Tabs
          "super+t=new_tab"
          "super+w=close_tab"
          "super+shift+h=previous_tab"
          "super+shift+l=next_tab"
          "super+1=goto_tab:1"
          "super+2=goto_tab:2"
          "super+3=goto_tab:3"
          "super+4=goto_tab:4"
          "super+5=goto_tab:5"
          "super+6=goto_tab:6"
          "super+7=goto_tab:7"
          "super+8=goto_tab:8"
          "super+9=goto_tab:9"
          "super+ctrl+shift+h=move_tab:-1"
          "super+ctrl+shift+l=move_tab:1"
          "super+shift+r=prompt_surface_title"

          # Maintenance
          "super+r=reload_config"
        ];
        "window-save-state" = "always";
        "auto-update-channel" = "tip";
      };
    };
  };
}
