{
  config,
  lib,
  osConfig,
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
    home.sessionVariables =
      lib.optionalAttrs (aiCfg.openclawRemoteUrl != null) {
        OPENCLAW_REMOTE_URL = aiCfg.openclawRemoteUrl;
      }
      // lib.optionalAttrs (aiCfg.openclawRemoteHostnameOpRef != null) {
        OPENCLAW_REMOTE_HOSTNAME_OP_REF = aiCfg.openclawRemoteHostnameOpRef;
      };

    home.file.".claude/settings.json" = lib.mkIf (aiCfg.claude.settings != { }) {
      text = builtins.toJSON aiCfg.claude.settings;
    };

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

        resolve_op_bin() {
          if command -v op >/dev/null 2>&1; then
            command -v op
            return 0
          fi

          if [ -x /opt/homebrew/bin/op ]; then
            printf '%s\n' /opt/homebrew/bin/op
            return 0
          fi

          printf '%s\n' "error: 1Password CLI is required to resolve OPENCLAW_REMOTE_HOSTNAME_OP_REF" >&2
          exit 1
        }

        remote_ref="''${OPENCLAW_REMOTE_HOSTNAME_OP_REF:-}"
        url="''${OPENCLAW_REMOTE_URL:-}"

        if [ -n "$remote_ref" ]; then
          op_bin="$(resolve_op_bin)"
          hostname="$("$op_bin" read "$remote_ref" 2>/dev/null)" || {
            printf '%s\n' "error: failed to read OPENCLAW_REMOTE_HOSTNAME_OP_REF via 1Password CLI" >&2
            exit 1
          }

          if [ -z "$hostname" ]; then
            printf '%s\n' "error: OPENCLAW_REMOTE_HOSTNAME_OP_REF resolved to an empty value" >&2
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
