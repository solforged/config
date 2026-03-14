{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.platform;

  defaultShell =
    if cfg.apps.shell == "zsh" then
      "${pkgs.zsh}/bin/zsh"
    else if cfg.apps.shell == "fish" then
      "${pkgs.fish}/bin/fish"
    else if cfg.apps.shell == "nushell" then
      "${pkgs.nushell}/bin/nu"
    else
      "${pkgs.zsh}/bin/zsh";

  plugins = {
    zellij-forgot = pkgs.fetchurl {
      url = "https://github.com/karimould/zellij-forgot/releases/latest/download/zellij_forgot.wasm";
      hash = "sha256-MRlBRVGdvcEoaFtFb5cDdDePoZ/J2nQvvkoyG6zkSds=";
    };
    zj-quit = pkgs.fetchurl {
      url = "https://github.com/cristiand391/zj-quit/releases/latest/download/zj-quit.wasm";
      hash = "sha256-JSYnGGN2SLNComhMg4P814dV3TV6jRvTv9fts9oTf5Q=";
    };
    zjstatus = pkgs.fetchurl {
      url = "https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm";
      hash = "sha256-TeQm0gscv4YScuknrutbSdksF/Diu50XP4W/fwFU3VM=";
    };
    zjstatus-hints = pkgs.fetchurl {
      url = "https://github.com/b0o/zjstatus-hints/releases/latest/download/zjstatus-hints.wasm";
      hash = "sha256-k2xV6QJcDtvUNCE4PvwVG9/ceOkk+Wa/6efGgr7IcZ0=";
    };
  };
in
{
  config = lib.mkIf cfg.profiles.base.enable {
    xdg.configFile = {
      "zellij/plugins/zellij_forgot.wasm".source = plugins.zellij-forgot;
      "zellij/plugins/zj-quit.wasm".source = plugins.zj-quit;
      "zellij/plugins/zjstatus.wasm".source = plugins.zjstatus;
      "zellij/plugins/zjstatus-hints.wasm".source = plugins.zjstatus-hints;
    };

    programs.zellij = {
      enable = true;
      extraConfig = ''
        default_shell "${defaultShell}"

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
                bind "Alt ?" {
                    LaunchOrFocusPlugin "file:~/.config/zellij/plugins/zellij_forgot.wasm" {
                        floating true
                    }
                }
                bind "Ctrl q" {
                    LaunchOrFocusPlugin "file:~/.config/zellij/plugins/zj-quit.wasm" {
                        floating true
                    }
                }
            }

            pane {
                bind "Alt [" { SwitchToMode "locked"; }
                bind "h" { MoveFocus "Left"; }
                bind "j" { MoveFocus "Down"; }
                bind "k" { MoveFocus "Up"; }
                bind "l" { MoveFocus "Right"; }
                bind "n" { NewPane; }
                bind "v" { NewPane "Right"; }
                bind "b" { NewPane "Down"; }
                bind "x" { CloseFocus; }
                bind "f" { ToggleFocusFullscreen; SwitchToMode "locked"; }
                bind "w" { ToggleFloatingPanes; SwitchToMode "locked"; }
                bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "locked"; }
                bind "r" { SwitchToMode "RenamePane"; PaneNameInput 0; }
            }

            tab {
                bind "Alt [" { SwitchToMode "locked"; }
                bind "h" { GoToPreviousTab; }
                bind "l" { GoToNextTab; }
                bind "n" { NewTab; SwitchToMode "locked"; }
                bind "x" { CloseTab; SwitchToMode "locked"; }
                bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
                bind "s" { ToggleActiveSyncTab; SwitchToMode "locked"; }
                bind "1" { GoToTab 1; SwitchToMode "locked"; }
                bind "2" { GoToTab 2; SwitchToMode "locked"; }
                bind "3" { GoToTab 3; SwitchToMode "locked"; }
                bind "4" { GoToTab 4; SwitchToMode "locked"; }
                bind "5" { GoToTab 5; SwitchToMode "locked"; }
                bind "6" { GoToTab 6; SwitchToMode "locked"; }
                bind "7" { GoToTab 7; SwitchToMode "locked"; }
                bind "8" { GoToTab 8; SwitchToMode "locked"; }
                bind "9" { GoToTab 9; SwitchToMode "locked"; }
            }

            resize {
                bind "Alt [" { SwitchToMode "locked"; }
                bind "h" { Resize "Increase Left"; }
                bind "j" { Resize "Increase Down"; }
                bind "k" { Resize "Increase Up"; }
                bind "l" { Resize "Increase Right"; }
                bind "H" { Resize "Decrease Left"; }
                bind "J" { Resize "Decrease Down"; }
                bind "K" { Resize "Decrease Up"; }
                bind "L" { Resize "Decrease Right"; }
                bind "=" { Resize "Increase"; }
                bind "-" { Resize "Decrease"; }
            }

            scroll {
                bind "Alt [" { SwitchToMode "locked"; }
                bind "j" { ScrollDown; }
                bind "k" { ScrollUp; }
                bind "d" { HalfPageScrollDown; }
                bind "u" { HalfPageScrollUp; }
                bind "f" { PageScrollDown; }
                bind "b" { PageScrollUp; }
                bind "e" { EditScrollback; SwitchToMode "locked"; }
                bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
                bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
            }

            "EnterSearch" {
                bind "Esc" { SwitchToMode "scroll"; }
                bind "Enter" { SwitchToMode "search"; }
            }

            search {
                bind "Alt [" { SwitchToMode "locked"; }
                bind "j" { ScrollDown; }
                bind "k" { ScrollUp; }
                bind "d" { HalfPageScrollDown; }
                bind "u" { HalfPageScrollUp; }
                bind "n" { Search "down"; }
                bind "N" { Search "up"; }
                bind "c" { SearchToggleOption "CaseSensitivity"; }
                bind "w" { SearchToggleOption "Wrap"; }
                bind "o" { SearchToggleOption "WholeWord"; }
            }

            session {
                bind "Alt [" { SwitchToMode "locked"; }
                bind "d" { Detach; }
            }

            "RenameTab" {
                bind "Esc" { UndoRenameTab; SwitchToMode "locked"; }
                bind "Enter" { SwitchToMode "locked"; }
            }

            "RenamePane" {
                bind "Esc" { UndoRenamePane; SwitchToMode "locked"; }
                bind "Enter" { SwitchToMode "locked"; }
            }

            shared_except "locked" {
                bind "Alt [" { SwitchToMode "locked"; }
                bind "Esc" { SwitchToMode "locked"; }
            }

            shared_except "locked" "pane" {
                bind "Alt ]" { SwitchToMode "pane"; }
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
