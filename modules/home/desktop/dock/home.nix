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
  emacsExe = lib.getExe emacsPackage;
  dockItems = cfg.features.dock.items;
in
{
  config = lib.mkIf (isDarwin && cfg.features.dock.enable && cfg.profiles.desktop.enable) {
    home.activation.configureDock = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      DOCKUTIL="${lib.getExe pkgs.dockutil}"

      if [ -n "$DOCKUTIL" ] && [ -e "$HOME/Library/Preferences/com.apple.dock.plist" ]; then
        ${lib.optionalString (builtins.elem "emacs" cfg.apps.enabledEditors) ''
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
              <key>LSRequiresNativeExecution</key>
              <true/>
              <key>LSUIElement</key>
              <true/>
            </dict>
          </plist>
          EOF

          /bin/cp "${emacsPackage}/Applications/Emacs.app/Contents/Resources/Emacs.icns" \
            "$resources_dir/Emacs.icns"

          # Use a compiled trampoline so macOS sees a native arm64 Mach-O
          # and never prompts for Rosetta.
          cat > /tmp/emacs-client-trampoline.c <<CSRC
          #include <unistd.h>
          int main(int argc, char *argv[]) {
            char *args[] = {"emacsclient", "-c", "-a", "${emacsExe}", NULL};
            return execv("${emacsClient}", args);
          }
          CSRC
          /usr/bin/cc -arch arm64 -o "$macos_dir/Emacs Client" /tmp/emacs-client-trampoline.c
          /bin/rm -f /tmp/emacs-client-trampoline.c
          /usr/bin/codesign --force --sign - "$app_target"
        ''}

        find_app() {
          for dir in \
            /Applications \
            /System/Applications \
            /System/Applications/Utilities \
            "$HOME/Applications" \
            "$HOME/Applications/Home Manager Apps" \
            "$HOME/Applications/Nix Apps"; do
            if [ -d "$dir/$1.app" ]; then
              printf '%s' "$dir/$1.app"
              return
            fi
          done
        }

        add_dock_item() {
          app_path="$(find_app "$1")"
          if [ -n "$app_path" ]; then
            "$DOCKUTIL" --add "$app_path" --no-restart "$HOME"
          fi
        }

        /usr/bin/defaults write com.apple.dock size-immutable -bool true

        "$DOCKUTIL" --remove all --no-restart "$HOME" || true
        ${lib.concatMapStringsSep "\n" (name: ''add_dock_item "${name}"'') dockItems}
        "$DOCKUTIL" --add "$HOME/Downloads" --view grid --display folder --section others --no-restart "$HOME" || true
        /usr/bin/killall Dock >/dev/null 2>&1 || true
      fi
    '';
  };
}
