{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.platform;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
  emacsPackage =
    let
      candidates = map (name: lib.attrByPath [ name ] null pkgs) [
        "emacs-unstable"
        "emacs"
      ];
    in
    lib.findFirst (pkg: pkg != null) pkgs.emacs candidates;
  emacsClient = lib.getExe' emacsPackage "emacsclient";
  dockPaths = {
    editor = {
      emacs = "$HOME/Applications/Emacs Client.app";
      helix = null;
      nvim = null;
    };
    browser = {
      brave = "/Applications/Brave Browser.app";
      chatgpt-atlas = "/Applications/ChatGPT Atlas.app";
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
    dockPaths.browser.${cfg.apps.browser}
    dockPaths.editor.${cfg.apps.editor}
    dockPaths.terminal.${cfg.apps.terminal}
    dockPaths.passwordManager.${cfg.apps.passwordManager}
  ];
in
{
  config = lib.mkIf (isDarwin && cfg.features.dock.enable && cfg.profiles.desktop.enable) {
    home.activation.configureDock = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      DOCKUTIL="${lib.getExe pkgs.dockutil}"

      if [ -n "$DOCKUTIL" ] && [ -e "$HOME/Library/Preferences/com.apple.dock.plist" ]; then
        ${lib.optionalString (cfg.apps.editor == "emacs") ''
          app_target="$HOME/Applications/Emacs Client.app"
          contents_dir="$app_target/Contents"
          macos_dir="$contents_dir/MacOS"
          resources_dir="$contents_dir/Resources"

          /bin/rm -rf "$HOME/Applications/Nix Apps/Emacs.app"
          /bin/rm -rf "$app_target"
          /bin/mkdir -p "$macos_dir" "$resources_dir"

          cat > "$contents_dir/Info.plist" <<'EOF'
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
            <dict>
              <key>CFBundleDevelopmentRegion</key>
              <string>English</string>
              <key>CFBundleExecutable</key>
              <string>Emacs Client</string>
              <key>CFBundleIconFile</key>
              <string>Emacs.icns</string>
              <key>CFBundleIdentifier</key>
              <string>io.solforged.emacs-client</string>
              <key>CFBundleInfoDictionaryVersion</key>
              <string>6.0</string>
              <key>CFBundleName</key>
              <string>Emacs Client</string>
              <key>CFBundlePackageType</key>
              <string>APPL</string>
              <key>CFBundleShortVersionString</key>
              <string>1.0</string>
              <key>CFBundleVersion</key>
              <string>1</string>
            </dict>
          </plist>
          EOF

          /bin/cp "${emacsPackage}/Applications/Emacs.app/Contents/Resources/Emacs.icns" \
            "$resources_dir/Emacs.icns"

          cat > "$macos_dir/Emacs Client" <<EOF
          #!${pkgs.runtimeShell}
          exec ${emacsClient} -c -a emacs "\$@"
          EOF

          /bin/chmod +x "$macos_dir/Emacs Client"
        ''}

        add_dock_item() {
          if [ -n "$1" ] && [ -e "$1" ]; then
            "$DOCKUTIL" --add "$1" --no-restart "$HOME"
          fi
        }

        "$DOCKUTIL" --remove all --no-restart "$HOME" || true
        add_dock_item "/System/Applications/Apps.app"
        ${lib.concatMapStringsSep "\n" (path: ''add_dock_item "${path}"'') selectedDockApps}
        add_dock_item "/System/Applications/App Store.app"
        add_dock_item "/Applications/Claude.app"
        add_dock_item "/System/Applications/System Settings.app"
        "$DOCKUTIL" --add "$HOME/Downloads" --view grid --display folder --section others --no-restart "$HOME" || true
        /usr/bin/killall Dock >/dev/null 2>&1 || true
      fi
    '';
  };
}
