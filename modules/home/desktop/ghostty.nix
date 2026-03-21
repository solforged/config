{ lib, osConfig, ... }:
let
  cfg = osConfig.platform;
in
{
  config = lib.mkIf (cfg.apps.terminal == "ghostty") {
    programs.ghostty = {
      enable = true;
      package = null;
      enableZshIntegration = cfg.apps.shell == "zsh";
      settings = {
        "font-size" = 12;
        "font-family" = [
          "JetBrains Mono"
        ];
        "macos-option-as-alt" = true;
        theme = "dark:Doom One,light:Doom One";
        "scrollback-limit" = 1000000;
        keybind = [
          # Discoverability
          "super+shift+p=toggle_command_palette"
          "super+shift+slash=toggle_command_palette"

          # Tabs — brackets + numbers
          "super+t=new_tab"
          "super+w=close_surface"
          "super+left_bracket=previous_tab"
          "super+right_bracket=next_tab"
          "super+shift+left_bracket=move_tab:-1"
          "super+shift+right_bracket=move_tab:1"
          "super+comma=prompt_surface_title"
          "super+1=goto_tab:1"
          "super+2=goto_tab:2"
          "super+3=goto_tab:3"
          "super+4=goto_tab:4"
          "super+5=goto_tab:5"
          "super+6=goto_tab:6"
          "super+7=goto_tab:7"
          "super+8=goto_tab:8"
          "super+9=goto_tab:9"

          # Window & config
          "super+n=new_window"
          "super+r=reload_config"
        ];
        "window-save-state" = "always";
      };
    };
  };
}
