{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.platform;
  aiCfg = cfg.ai;
  helperCommon = ''
    find_project_root() {
      if command -v git >/dev/null 2>&1; then
        root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
        if [ -n "$root" ]; then
          printf '%s\n' "$root"
          return 0
        fi
      fi

      pwd
    }
  '';
in
{
  config = lib.mkIf aiCfg.enable {
    home.packages = lib.optional (aiCfg.claude.package != null) aiCfg.claude.package;

    programs.zsh.shellAliases = lib.mkIf (aiCfg.claude.package != null) {
      claude = "claude-bun";
    };

    home.sessionVariables =
      lib.optionalAttrs (aiCfg.openclawRemoteUrl != null) {
        OPENCLAW_REMOTE_URL = aiCfg.openclawRemoteUrl;
      }
      // lib.optionalAttrs (aiCfg.openclawRemoteHostnameFile != null) {
        OPENCLAW_REMOTE_HOSTNAME_FILE = aiCfg.openclawRemoteHostnameFile;
      };

    home.activation.claudeSettings = lib.mkIf (aiCfg.claude.settings != { }) (
      let
        nixSettings = pkgs.writeText "claude-settings-nix.json" (builtins.toJSON aiCfg.claude.settings);
        jq = lib.getExe pkgs.jq;
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        settings="$HOME/.claude/settings.json"
        /bin/mkdir -p "$HOME/.claude"

        # Remove stale Home Manager symlink pointing into the Nix store
        if [ -L "$settings" ]; then
          /bin/rm "$settings"
        fi

        if [ -f "$settings" ]; then
          # Deep-merge: existing runtime keys stay, Nix-declared keys win
          merged="$(${jq} -s '.[0] * .[1]' "$settings" "${nixSettings}")"
          printf '%s\n' "$merged" > "$settings"
        else
          /bin/cp "${nixSettings}" "$settings"
          /bin/chmod 644 "$settings"
        fi
      ''
    );

    home.file.".local/bin/codex-here" = {
      executable = true;
      text = ''
        #!/bin/sh
        set -eu

        ${helperCommon}

        root="$(find_project_root)"
        exec codex --cd "$root" "$@"
      '';
    };

    home.file.".local/bin/codex-resume" = {
      executable = true;
      text = ''
        #!/bin/sh
        set -eu

        ${helperCommon}

        root="$(find_project_root)"

        if [ "$#" -eq 0 ]; then
          exec codex --cd "$root" resume --last
        fi

        exec codex --cd "$root" resume "$@"
      '';
    };

    home.file.".local/bin/openclaw-remote" = {
      executable = true;
      text = ''
        #!/bin/sh
        set -eu

        normalize_url() {
          value="$1"

          case "$value" in
            http://*|https://*)
              printf '%s\n' "''${value%/}"
              ;;
            *)
              printf 'https://%s\n' "$value"
              ;;
          esac
        }

        hostname_file="''${OPENCLAW_REMOTE_HOSTNAME_FILE:-}"
        url="''${OPENCLAW_REMOTE_URL:-}"

        if [ -n "$hostname_file" ]; then
          if [ ! -f "$hostname_file" ]; then
            printf '%s\n' "error: hostname file not found at $hostname_file; run 'rig deploy' to decrypt secrets" >&2
            exit 1
          fi

          hostname="$(/bin/cat "$hostname_file")" || {
            printf '%s\n' "error: failed to read hostname from $hostname_file" >&2
            exit 1
          }

          if [ -z "$hostname" ]; then
            printf '%s\n' "error: hostname file at $hostname_file is empty" >&2
            exit 1
          fi

          url="$(normalize_url "$hostname")"
        elif [ -n "$url" ]; then
          url="$(normalize_url "$url")"
        else
          printf '%s\n' "error: OPENCLAW_REMOTE_URL is not configured" >&2
          exit 1
        fi

        case "''${1:-}" in
          "")
            printf '%s\n' "$url"
            ;;
          --open)
            if command -v open >/dev/null 2>&1; then
              exec open "$url"
            fi

            if command -v xdg-open >/dev/null 2>&1; then
              exec xdg-open "$url"
            fi

            printf '%s\n' "error: no URL opener found" >&2
            exit 1
            ;;
          *)
            printf '%s\n' "usage: openclaw-remote [--open]" >&2
            exit 1
            ;;
        esac
      '';
    };
  };
}
