{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption;
  cfg = osConfig.dotfiles;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
  dockPaths = {
    editor = {
      emacs = "$HOME/Applications/Home Manager Apps/Emacs.app";
      nvim = null;
    };
    browser = {
      brave = "/Applications/Brave Browser.app";
      safari = "/System/Applications/Safari.app";
      none = null;
    };
    terminal = {
      ghostty = "/Applications/Ghostty.app";
      kitty = "/Applications/kitty.app";
      terminal = "/System/Applications/Utilities/Terminal.app";
    };
    passwordManager = {
      "1password" = "/Applications/1Password.app";
      bitwarden = "/Applications/Bitwarden.app";
      proton-pass = "/Applications/Proton Pass.app";
      none = null;
    };
  };
  selectedDockApps = lib.filter (path: path != null && path != "") [
    dockPaths.editor.${cfg.apps.editor}
    dockPaths.browser.${cfg.apps.browser}
    dockPaths.terminal.${cfg.apps.terminal}
    dockPaths.passwordManager.${cfg.apps.passwordManager}
  ];
in
{
  config = lib.mkIf (isDarwin && cfg.features.dock.enable && cfg.profiles.desktop.enable) {
    home.activation.configureDock = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      DOCKUTIL="${lib.getExe pkgs.dockutil}"

      if [ -n "$DOCKUTIL" ] && [ -e "$HOME/Library/Preferences/com.apple.dock.plist" ]; then
        add_dock_item() {
          if [ -n "$1" ] && [ -e "$1" ]; then
            "$DOCKUTIL" --add "$1" --no-restart "$HOME"
          fi
        }

        "$DOCKUTIL" --remove all --no-restart "$HOME" || true
        add_dock_item "/System/Applications/Apps.app"
        ${lib.concatMapStringsSep "\n" (path: ''add_dock_item "${path}"'') selectedDockApps}
        add_dock_item "/System/Applications/Calendar.app"
        add_dock_item "/System/Applications/Mail.app"
        add_dock_item "/System/Applications/Music.app"
        add_dock_item "/System/Applications/App Store.app"
        add_dock_item "/System/Applications/System Settings.app"
        "$DOCKUTIL" --add "$HOME/Downloads" --view grid --display folder --section others --no-restart "$HOME" || true
        /usr/bin/killall Dock >/dev/null 2>&1 || true
      fi
    '';
  };
}
