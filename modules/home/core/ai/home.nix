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
    home.sessionVariables = lib.optionalAttrs (aiCfg.openclawRemoteUrl != null) {
      OPENCLAW_REMOTE_URL = aiCfg.openclawRemoteUrl;
    };

    home.file.".claude/settings.local.json" = lib.mkIf (aiCfg.claude.settingsLocal != { }) {
      text = builtins.toJSON aiCfg.claude.settingsLocal;
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

        url="''${OPENCLAW_REMOTE_URL:-}"

        if [ -z "$url" ]; then
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
