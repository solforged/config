{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.platform;
  forgotPluginPath = "file:~/.config/zellij/plugins/zellij_forgot.wasm";
  quitPluginPath = "file:~/.config/zellij/plugins/zj-quit.wasm";
  zjstatusPluginPath = "file:~/.config/zellij/plugins/zjstatus.wasm";

  defaultShell =
    if cfg.apps.shell == "zsh" then
      "${pkgs.zsh}/bin/zsh"
    else if cfg.apps.shell == "fish" then
      "${pkgs.fish}/bin/fish"
    else if cfg.apps.shell == "nushell" then
      "${pkgs.nushell}/bin/nu"
    else
      "${pkgs.zsh}/bin/zsh";

  defaultTabTemplate = ''
    default_tab_template {
        children
        pane size=1 borderless=true {
            plugin location="${zjstatusPluginPath}" {
                format_left   "{mode} {tabs}"
                format_center "{pipe_zjstatus_hints}"
                format_right  "{datetime}#[bg=#cba6f7,fg=#1e1e2e,bold] {session} "
                format_space  ""
                format_hide_on_overlength "true"
                format_precedence "lrc"

                pipe_zjstatus_hints_format "#[fg=#6c7086]{output} "

                datetime_format "%H:%M"
                datetime_timezone "America/Los_Angeles"

                border_enabled  "true"
                border_char     "─"
                border_format   "#[fg=#6c7086]{char}"
                border_position "top"

                hide_frame_for_single_pane "false"

                mode_locked      "#[bg=#cba6f7,fg=#1e1e2e,bold]  LOCK "
                mode_normal      "#[bg=#f5c2e7,fg=#1e1e2e,bold]  NORMAL "
                mode_resize      "#[bg=#f38ba8,fg=#1e1e2e,bold]  RESIZE "
                mode_pane        "#[bg=#89b4fa,fg=#1e1e2e,bold]  PANE "
                mode_move        "#[bg=#94e2d5,fg=#1e1e2e,bold]  MOVE "
                mode_tab         "#[bg=#b4befe,fg=#1e1e2e,bold]  TAB "
                mode_scroll      "#[bg=#cdd6f4,fg=#1e1e2e,bold]  SCROLL "
                mode_search      "#[bg=#f9e2af,fg=#1e1e2e,bold]  SEARCH "
                mode_entersearch "#[bg=#f9e2af,fg=#1e1e2e,bold]  ENTER SEARCH "
                mode_renametab   "#[bg=#cba6f7,fg=#1e1e2e,bold]  RENAME TAB "
                mode_renamepane  "#[bg=#cba6f7,fg=#1e1e2e,bold]  RENAME PANE "
                mode_session     "#[bg=#f38ba8,fg=#1e1e2e,bold]  SESSION "
                mode_tmux        "#[bg=#cdd6f4,fg=#1e1e2e,bold]  TMUX "

                mode_pane_format_center        "#[fg=#89b4fa,bold]h/j/k/l#[fg=#6c7086] Navigate  #[fg=#89b4fa,bold]n#[fg=#6c7086] New  #[fg=#89b4fa,bold]v#[fg=#6c7086] Right  #[fg=#89b4fa,bold]b#[fg=#6c7086] Below  #[fg=#89b4fa,bold]x#[fg=#6c7086] Close  #[fg=#89b4fa,bold]f#[fg=#6c7086] Full  #[fg=#89b4fa,bold]w#[fg=#6c7086] Float  #[fg=#89b4fa,bold]r#[fg=#6c7086] Rename  #[fg=#89b4fa,bold]t#[fg=#6c7086] Break"
                mode_tab_format_center         "#[fg=#b4befe,bold]h/l#[fg=#6c7086] Prev/Next  #[fg=#b4befe,bold]n#[fg=#6c7086] New  #[fg=#b4befe,bold]x#[fg=#6c7086] Close  #[fg=#b4befe,bold]r#[fg=#6c7086] Rename  #[fg=#b4befe,bold]s#[fg=#6c7086] Sync  #[fg=#b4befe,bold]H/L#[fg=#6c7086] Move  #[fg=#b4befe,bold]1-9#[fg=#6c7086] Jump"
                mode_resize_format_center      "#[fg=#f38ba8,bold]h/j/k/l#[fg=#6c7086] Grow  #[fg=#f38ba8,bold]H/J/K/L#[fg=#6c7086] Shrink  #[fg=#f38ba8,bold]=/−#[fg=#6c7086] All"
                mode_move_format_center        "#[fg=#94e2d5,bold]h/j/k/l#[fg=#6c7086] Move pane"
                mode_scroll_format_center      "#[fg=#cdd6f4,bold]j/k#[fg=#6c7086] Scroll  #[fg=#cdd6f4,bold]d/u#[fg=#6c7086] Half-page  #[fg=#cdd6f4,bold]f/b#[fg=#6c7086] Full  #[fg=#cdd6f4,bold]e#[fg=#6c7086] Edit  #[fg=#cdd6f4,bold]/#[fg=#6c7086] Search"
                mode_search_format_center      "#[fg=#f9e2af,bold]j/k#[fg=#6c7086] Scroll  #[fg=#f9e2af,bold]n/N#[fg=#6c7086] Next/Prev  #[fg=#f9e2af,bold]c#[fg=#6c7086] Case  #[fg=#f9e2af,bold]w#[fg=#6c7086] Wrap  #[fg=#f9e2af,bold]o#[fg=#6c7086] Word"
                mode_session_format_center     "#[fg=#f38ba8,bold]d#[fg=#6c7086] Detach  #[fg=#f38ba8,bold]w#[fg=#6c7086] Sessions  #[fg=#f38ba8,bold]c#[fg=#6c7086] Config  #[fg=#f38ba8,bold]p#[fg=#6c7086] Plugins  #[fg=#f38ba8,bold]a#[fg=#6c7086] About"
                mode_entersearch_format_center "#[fg=#6c7086]Type to search · Enter confirm · Esc cancel"
                mode_renametab_format_center   "#[fg=#6c7086]Type new name · Enter confirm · Esc cancel"
                mode_renamepane_format_center  "#[fg=#6c7086]Type new name · Enter confirm · Esc cancel"

                tab_active              "#[bg=#cba6f7,fg=#1e1e2e,bold] {index} {name} "
                tab_active_fullscreen   "#[bg=#cba6f7,fg=#1e1e2e,bold] {fullscreen_indicator} {index} {name} "
                tab_active_sync         "#[bg=#cba6f7,fg=#1e1e2e,bold] {sync_indicator} {index} {name} "

                tab_normal              "#[fg=#6c7086,bold] {index} {name} "
                tab_normal_fullscreen   "#[fg=#6c7086,bold] {fullscreen_indicator} {index} {name} "
                tab_normal_sync         "#[fg=#6c7086,bold] {sync_indicator} {index} {name} "

                tab_separator " "

                tab_sync_indicator       "󰓦"
                tab_fullscreen_indicator "󰊓"
                tab_floating_indicator   "⬚"

                tab_rename              "#[bg=#b4befe,fg=#1e1e2e,bold] {index} {name} {floating_indicator} "

                tab_display_count         "9"
                tab_truncate_start_format "#[fg=#f9e2af]  +{count}  "
                tab_truncate_end_format   "#[fg=#f9e2af]   +{count} "
            }
        }
    }
  '';

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
        plugins {
            about location="zellij:about"
            configuration location="zellij:configuration"
            plugin-manager location="zellij:plugin-manager"
            session-manager location="zellij:session-manager"
            welcome-screen location="zellij:session-manager" {
                welcome_screen true
            }
            zjstatus location="${zjstatusPluginPath}"
            zjstatus-hints location="file:~/.config/zellij/plugins/zjstatus-hints.wasm" {
                overflow_str "..."
                pipe_name "zjstatus_hints"
                hide_in_base_mode false
            }
            zj-forgot location="${forgotPluginPath}"
            zj-quit location="${quitPluginPath}" {
                cancel_key "Esc"
                confirm_key "y"
            }
        }

        load_plugins {
            zjstatus-hints
        }

        default_shell "${defaultShell}"

        keybinds clear-defaults=true {
            locked {
                bind "Alt q" { Quit; }
                bind "Alt f" { ToggleFocusFullscreen; }
                bind "Alt w" { ToggleFloatingPanes; }
                bind "Alt e" { TogglePaneEmbedOrFloating; }
                bind "Alt i" { TogglePanePinned; }
                bind "Alt h" { MoveFocusOrTab "Left"; }
                bind "Alt j" { MoveFocus "Down"; }
                bind "Alt k" { MoveFocus "Up"; }
                bind "Alt l" { MoveFocusOrTab "Right"; }
                bind "Alt Left" { MoveFocusOrTab "Left"; }
                bind "Alt Down" { MoveFocus "Down"; }
                bind "Alt Up" { MoveFocus "Up"; }
                bind "Alt Right" { MoveFocusOrTab "Right"; }
                bind "Alt p" { SwitchToMode "pane"; }
                bind "Alt t" { SwitchToMode "tab"; }
                bind "Alt r" { SwitchToMode "resize"; }
                bind "Alt s" { SwitchToMode "scroll"; }
                bind "Alt /" { SwitchToMode "EnterSearch"; SearchInput 0; }
                bind "Alt o" { SwitchToMode "session"; }
                bind "Alt m" { SwitchToMode "move"; }
                bind "Alt n" { NewPane; }
                bind "Alt Shift n" { NewPane "stacked"; }
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
                bind "Alt Shift /" {
                    LaunchOrFocusPlugin "zj-forgot" {
                        floating true
                        move_to_focused_tab true
                        "Alt h/j/k/l"       "Navigate panes"
                        "Alt ,/."            "Previous/next tab"
                        "Alt 1-9"            "Jump to tab N"
                        "Alt n"              "New pane"
                        "Alt Shift n"        "New stacked pane"
                        "Alt v / Alt b"      "New pane right / below"
                        "Alt x"              "Close pane"
                        "Alt f"              "Toggle fullscreen"
                        "Alt w"              "Toggle floating"
                        "Alt e"              "Toggle embed/float"
                        "Alt i"              "Toggle pinned"
                        "Alt p"              "Pane mode"
                        "Alt t"              "Tab mode"
                        "Alt r"              "Resize mode"
                        "Alt s"              "Scroll mode"
                        "Alt m"              "Move mode"
                        "Alt o"              "Session mode"
                        "Alt /"              "Search"
                        "Alt Shift /"        "This cheat sheet"
                        "Alt [ / Esc"        "Return to locked"
                        "Ctrl q"             "Quit (confirm)"
                    }
                }
                bind "Ctrl q" {
                    LaunchOrFocusPlugin "zj-quit" {
                        floating true
                        move_to_focused_tab true
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
                bind "s" { NewPane "stacked"; }
                bind "v" { NewPane "Right"; }
                bind "b" { NewPane "Down"; }
                bind "x" { CloseFocus; }
                bind "f" { ToggleFocusFullscreen; SwitchToMode "locked"; }
                bind "w" { ToggleFloatingPanes; SwitchToMode "locked"; }
                bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "locked"; }
                bind "i" { TogglePanePinned; SwitchToMode "locked"; }
                bind "r" { SwitchToMode "RenamePane"; PaneNameInput 0; }
                bind "t" { BreakPane; SwitchToMode "locked"; }
            }

            tab {
                bind "Alt [" { SwitchToMode "locked"; }
                bind "h" { GoToPreviousTab; }
                bind "l" { GoToNextTab; }
                bind "n" { NewTab; SwitchToMode "locked"; }
                bind "x" { CloseTab; SwitchToMode "locked"; }
                bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
                bind "s" { ToggleActiveSyncTab; SwitchToMode "locked"; }
                bind "H" { MoveTab "Left"; }
                bind "L" { MoveTab "Right"; }
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

            move {
                bind "Alt [" { SwitchToMode "locked"; }
                bind "h" { MovePane "Left"; }
                bind "j" { MovePane "Down"; }
                bind "k" { MovePane "Up"; }
                bind "l" { MovePane "Right"; }
            }

            scroll {
                bind "Alt [" { SwitchToMode "locked"; }
                bind "j" { ScrollDown; }
                bind "k" { ScrollUp; }
                bind "d" { HalfPageScrollDown; }
                bind "u" { HalfPageScrollUp; }
                bind "f" { PageScrollDown; }
                bind "b" { PageScrollUp; }
                bind "Ctrl c" { ScrollToBottom; SwitchToMode "locked"; }
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
                bind "w" {
                    LaunchOrFocusPlugin "session-manager" {
                        floating true
                        move_to_focused_tab true
                    }
                    SwitchToMode "locked"
                }
                bind "c" {
                    LaunchOrFocusPlugin "configuration" {
                        floating true
                        move_to_focused_tab true
                    }
                    SwitchToMode "locked"
                }
                bind "p" {
                    LaunchOrFocusPlugin "plugin-manager" {
                        floating true
                        move_to_focused_tab true
                    }
                    SwitchToMode "locked"
                }
                bind "a" {
                    LaunchOrFocusPlugin "about" {
                        floating true
                        move_to_focused_tab true
                    }
                    SwitchToMode "locked"
                }
            }

            "RenameTab" {
                bind "Esc" { UndoRenameTab; SwitchToMode "locked"; }
                bind "Ctrl c" { SwitchToMode "locked"; }
                bind "Enter" { SwitchToMode "locked"; }
            }

            "RenamePane" {
                bind "Esc" { UndoRenamePane; SwitchToMode "locked"; }
                bind "Ctrl c" { SwitchToMode "locked"; }
                bind "Enter" { SwitchToMode "locked"; }
            }

            shared_except "locked" {
                bind "Alt [" { SwitchToMode "locked"; }
                bind "Esc" { SwitchToMode "locked"; }
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
                bind "Alt p" { SwitchToMode "pane"; }
                bind "Alt t" { SwitchToMode "tab"; }
                bind "Alt r" { SwitchToMode "resize"; }
                bind "Alt s" { SwitchToMode "scroll"; }
                bind "Alt /" { SwitchToMode "EnterSearch"; SearchInput 0; }
                bind "Alt o" { SwitchToMode "session"; }
                bind "Alt m" { SwitchToMode "move"; }
                bind "Alt Shift /" {
                    LaunchOrFocusPlugin "zj-forgot" {
                        floating true
                        move_to_focused_tab true
                        "Alt h/j/k/l"       "Navigate panes"
                        "Alt ,/."            "Previous/next tab"
                        "Alt 1-9"            "Jump to tab N"
                        "Alt n"              "New pane"
                        "Alt Shift n"        "New stacked pane"
                        "Alt v / Alt b"      "New pane right / below"
                        "Alt x"              "Close pane"
                        "Alt f"              "Toggle fullscreen"
                        "Alt w"              "Toggle floating"
                        "Alt e"              "Toggle embed/float"
                        "Alt i"              "Toggle pinned"
                        "Alt p"              "Pane mode"
                        "Alt t"              "Tab mode"
                        "Alt r"              "Resize mode"
                        "Alt s"              "Scroll mode"
                        "Alt m"              "Move mode"
                        "Alt o"              "Session mode"
                        "Alt /"              "Search"
                        "Alt Shift /"        "This cheat sheet"
                        "Alt [ / Esc"        "Return to locked"
                        "Ctrl q"             "Quit (confirm)"
                    }
                }
                bind "Ctrl q" {
                    LaunchOrFocusPlugin "zj-quit" {
                        floating true
                        move_to_focused_tab true
                    }
                }
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
      layouts = {
        default = ''
          layout {
              ${defaultTabTemplate}
              tab name=""
          }
        '';
      }
      // lib.optionalAttrs cfg.profiles.work.enable {
        work = ''
          layout {
              ${defaultTabTemplate}
              tab name="code" {
                  pane split_direction="Vertical" {
                      pane
                      pane size="30%"
                  }
              }
              tab name="scratch"
          }
        '';
      }
      // lib.optionalAttrs cfg.profiles.development.enable {
        agent = ''
          layout {
              ${defaultTabTemplate}
              tab name="agent" focus=true {
                  pane split_direction="Vertical" {
                      pane size="60%"
                      pane size="40%" split_direction="Horizontal" {
                          pane
                          pane size="30%"
                      }
                  }
              }
              tab name="edit"
          }
        '';
      };
    };
  };
}
