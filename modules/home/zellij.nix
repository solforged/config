{ lib, osConfig, ... }:
let
  cfg = osConfig.dotfiles;
in
{
  config = lib.mkIf (lib.elem "base" cfg.profiles) {
    programs.zellij = {
      enable = true;
      extraConfig = ''
        keybinds clear-defaults=true {
            locked {
                bind "Alt q" { Quit; }
                bind "Alt f" { ToggleFocusFullscreen; }
                bind "Alt w" { ToggleFloatingPanes; }
                bind "Alt h" { MoveFocusOrTab "Left"; }
                bind "Alt j" { MoveFocus "Down"; }
                bind "Alt k" { MoveFocus "Up"; }
                bind "Alt l" { MoveFocusOrTab "Right"; }
                bind "Alt n" { NewPane; }
                bind "Alt v" { NewPane "Right"; }
                bind "Alt b" { NewPane "Down"; }
                bind "Alt x" { CloseFocus; }
                bind "Alt ," { GoToPreviousTab; }
                bind "Alt ." { GoToNextTab; }
                bind "Alt 1" { GoToTab 1; }
                bind "Alt 2" { GoToTab 2; }
                bind "Alt 3" { GoToTab 3; }
                bind "Alt 4" { GoToTab 4; }
                bind "Alt 5" { GoToTab 5; }
                bind "Alt 6" { GoToTab 6; }
                bind "Alt 7" { GoToTab 7; }
                bind "Alt 8" { GoToTab 8; }
                bind "Alt 9" { GoToTab 9; }
            }
        }

        default_mode "locked"
        default_layout "default"
        scroll_buffer_size 100000
        on_force_close "detach"
        copy_on_select true
        pane_frames true

        ui {
            pane_frames {
                hide_session_name true
                rounded_corners false
            }
        }
      '';
      layouts.default = ''
        layout {
            default_tab_template {
                pane
            }

            tab name="shell"
        }
      '';
    };
  };
}
