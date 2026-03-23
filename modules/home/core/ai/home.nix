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
  lumenConfig = {
    provider = aiCfg.lumen.provider;
    draft = {
      commit_types = {
        feat = "A new feature";
        fix = "A bug fix";
        docs = "Documentation only changes";
        style = "Changes that do not affect code meaning";
        refactor = "Code changes without bug fixes or features";
        perf = "Performance improvements";
        test = "Adding or correcting tests";
        build = "Build system or dependency changes";
        ci = "CI configuration changes";
        chore = "Other changes not modifying src or test";
        revert = "Reverts a previous commit";
      };
    };
  }
  // lib.optionalAttrs (aiCfg.lumen.model != null) { model = aiCfg.lumen.model; };
in
{
  config = lib.mkIf aiCfg.enable {
    home.packages =
      lib.optional (aiCfg.claude.package != null) aiCfg.claude.package
      ++ lib.optional (aiCfg.lumen.enable && aiCfg.lumen.package != null) aiCfg.lumen.package;

    xdg.configFile."lumen/lumen.config.json" = lib.mkIf aiCfg.lumen.enable {
      text = builtins.toJSON lumenConfig;
    };

    programs.zsh.shellAliases = lib.mkIf (aiCfg.claude.package != null) {
      claude = "claude-bun";
    };

    programs.zsh.initContent = lib.mkIf (aiCfg.lumen.enable && aiCfg.lumen.apiKeyFile != null) (
      lib.mkOrder 500 ''
        if [[ -r "${aiCfg.lumen.apiKeyFile}" ]]; then
          export GROQ_API_KEY="$(<"${aiCfg.lumen.apiKeyFile}")"
        fi
      ''
    );

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

    home.activation.codexSettings = lib.mkIf (aiCfg.codex.settings != { }) (
      let
        nixSettings = (pkgs.formats.toml { }).generate "codex-settings-nix.toml" aiCfg.codex.settings;
        python = lib.getExe pkgs.python3;
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        config_path="${config.xdg.dataHome}/codex/config.toml"
        nix_settings="${nixSettings}"

        /bin/mkdir -p "${config.xdg.dataHome}/codex"

        "${python}" - "$config_path" "$nix_settings" <<'PY'
        import pathlib
        import sys
        import tomllib


        def merge_values(base, override):
            if isinstance(base, dict) and isinstance(override, dict):
                merged = dict(base)
                for key, value in override.items():
                    if key in merged:
                        merged[key] = merge_values(merged[key], value)
                    else:
                        merged[key] = value
                return merged
            return override


        def format_string(value: str) -> str:
            escaped = (
                value.replace("\\", "\\\\")
                .replace('"', '\\"')
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t")
            )
            return f'"{escaped}"'


        def format_value(value):
            if isinstance(value, bool):
                return "true" if value else "false"
            if isinstance(value, int):
                return str(value)
            if isinstance(value, float):
                return repr(value)
            if isinstance(value, str):
                return format_string(value)
            if isinstance(value, list):
                return "[" + ", ".join(format_value(item) for item in value) + "]"
            raise TypeError(f"Unsupported TOML value: {value!r}")


        def sort_key(key):
            value = str(key)
            return (0, value) if value == "projects" else (1, value)


        def write_table(lines, path, table):
            scalar_keys = []
            nested_keys = []
            for key, value in table.items():
                if isinstance(value, dict):
                    nested_keys.append(key)
                else:
                    scalar_keys.append(key)

            if path:
                rendered_path = ".".join(format_string(part) for part in path)
                lines.append(f"[{rendered_path}]")

            for key in sorted(scalar_keys, key=sort_key):
                lines.append(f"{key} = {format_value(table[key])}")

            if path and nested_keys:
                lines.append("")

            first_nested = True
            for key in sorted(nested_keys, key=sort_key):
                if not first_nested:
                    lines.append("")
                write_table(lines, path + [key], table[key])
                first_nested = False


        config_path = pathlib.Path(sys.argv[1])
        nix_settings_path = pathlib.Path(sys.argv[2])

        desired = tomllib.loads(nix_settings_path.read_text(encoding="utf-8"))

        if config_path.exists():
            current = tomllib.loads(config_path.read_text(encoding="utf-8"))
        else:
            current = {}

        merged = merge_values(current, desired)

        lines = []
        write_table(lines, [], merged)
        rendered = "\n".join(lines).rstrip() + "\n"
        config_path.write_text(rendered, encoding="utf-8")
        PY

        /bin/chmod 644 "$config_path"
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

    home.file.".local/bin/claude-hook-nixfmt" = {
      executable = true;
      text =
        let
          jq = lib.getExe pkgs.jq;
          nixfmt = lib.getExe pkgs.nixfmt-rfc-style;
        in
        ''
          #!/bin/sh
          f="$(${jq} -r '.tool_input.file_path // empty')"
          case "$f" in
            *.nix) ${nixfmt} "$f" 2>/dev/null || true ;;
          esac
          exit 0
        '';
    };

    home.file.".local/bin/claude-oauth-token" = {
      executable = true;
      text =
        let
          jq = lib.getExe pkgs.jq;
        in
        ''
          #!/bin/sh
          set -eu
          security find-generic-password -s "Claude Code-credentials" -w \
            | ${jq} -r '.claudeAiOauth.accessToken'
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
