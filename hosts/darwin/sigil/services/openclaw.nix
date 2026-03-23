{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.platform;
  documentsDir = pkgs.runCommandLocal "openclaw-documents-placeholder" { } ''
    mkdir -p "$out"

    cat <<'EOF' > "$out/AGENTS.md"
    # AGENTS.md

    OpenClaw bootstrap instructions are intentionally not shipped in this public repository.
    Provide machine-local or private workspace guidance separately.
    EOF

    cat <<'EOF' > "$out/SOUL.md"
    # SOUL.md

    No public persona baseline is committed here.
    Load private instructions outside this repository if needed.
    EOF

    cat <<'EOF' > "$out/TOOLS.md"
    # TOOLS.md

    No repository-managed OpenClaw tool guidance is provided here.
    Configure any required tool policy outside this public configuration.
    EOF

    cat <<'EOF' > "$out/IDENTITY.md"
    # IDENTITY.md

    No public identity prompt is committed here.
    Use private or machine-local instructions when an identity document is required.
    EOF
  '';
  openclawStateDir = "${config.xdg.stateHome}/openclaw";
  openclawOAuthDir = "${openclawStateDir}/credentials";
  openclawWorkspaceDir = "${config.xdg.dataHome}/openclaw/workspace";
  mktempBin = lib.getExe' pkgs.coreutils "mktemp";
  pythonBin = lib.getExe pkgs.python3;
  secretsDir = cfg.secrets.stateDir;
  tailscaleBin = lib.getExe' pkgs.tailscale "tailscale";
  tailscaleHostName = cfg.host.slug;
  openclawBaseConfig = {
    secrets.providers = {
      gatewaytoken = {
        source = "env";
      };
    };

    gateway = {
      mode = "local";
      bind = "loopback";
      # Tailscale Serve reaches the loopback-bound gateway through a local proxy.
      trustedProxies = [
        "127.0.0.1"
        "::1"
      ];
      controlUi.allowedOrigins = [
        "http://127.0.0.1:18789"
        "http://localhost:18789"
      ];
      auth = {
        mode = "token";
        token = {
          source = "env";
          provider = "gatewaytoken";
          id = "OPENCLAW_GATEWAY_TOKEN";
        };
      };
      tailscale = {
        # OpenClaw reads the node's MagicDNS name from `tailscale status --json`.
        mode = "serve";
        resetOnExit = false;
      };
    };

    channels.telegram = {
      enabled = true;
      botToken = {
        source = "env";
        provider = "default";
        id = "TELEGRAM_BOT_TOKEN";
      };
      dmPolicy = "allowlist";
      groupPolicy = "allowlist";
      groups."*" = {
        requireMention = true;
      };
    };

    agents.defaults.model = {
      primary = "openai-codex/gpt-5.4";
      fallbacks = [
        # Keep the non-OpenAI fallbacks disabled on sigil for now.
        # "anthropic/claude-opus-4-6"
        # "google-gemini-cli/gemini-3.1-pro"
      ];
    };

    tools.web.search = {
      enabled = true;
      provider = "brave";
      apiKey = {
        source = "env";
        provider = "default";
        id = "BRAVE_API_KEY";
      };
    };

    tools.alsoAllow = [
      "lobster"
      "llm-task"
    ];

    plugins.entries = {
      diffs = {
        enabled = true;
      };
      lobster = {
        enabled = true;
      };
      llm-task = {
        enabled = true;
        config = {
          defaultProvider = "openai-codex";
          defaultModel = "gpt-5.4";
          allowedModels = [ "openai-codex/gpt-5.4" ];
          maxTokens = 800;
          timeoutMs = 30000;
        };
      };
    };

    # Keep chat on Codex OAuth, but run semantic memory embeddings locally.
    agents.defaults.memorySearch = {
      provider = "local";
      fallback = "none";
      local = {
        modelPath = "hf:ggml-org/embeddinggemma-300M-GGUF/embeddinggemma-300M-Q8_0.gguf";
        modelCacheDir = "${openclawStateDir}/models";
      };
      sync.watch = true;
    };
  };
  # Render a non-sensitive template into the store, then inject host-specific
  # identifiers at launch so they never land in git or the Nix store.
  openclawConfigTemplate = pkgs.writeText "openclaw-sigil-template.json" (
    builtins.toJSON openclawBaseConfig
  );
in
{
  home.activation.prepareOpenclawConfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    configPath="${openclawStateDir}/openclaw.json"

    if [ -L "$configPath" ]; then
      linkTarget="$(readlink "$configPath" || true)"
      case "$linkTarget" in
        /nix/store/*-openclaw-*.json|/nix/store/*-openclaw-default.json)
          run rm "$configPath"
          ;;
      esac
    elif [ -f "$configPath" ]; then
      timestamp="$(${lib.getExe' pkgs.coreutils "date"} +%Y%m%d-%H%M%S)"
      backupPath="$configPath.runtime-$timestamp"
      suffix=0

      while [ -e "$backupPath" ]; do
        suffix=$((suffix + 1))
        backupPath="$configPath.runtime-$timestamp.$suffix"
      done

      run /bin/mv "$configPath" "$backupPath"
    fi
  '';

  home.activation.openclawConfigFiles = lib.mkForce (lib.hm.dag.entryAfter [ "openclawDirs" ] "");
  home.activation.openclawDocumentGuard = lib.mkForce (lib.hm.dag.entryBefore [ "writeBoundary" ] "");

  home.sessionVariables = {
    OPENCLAW_STATE_DIR = openclawStateDir;
    OPENCLAW_CONFIG_PATH = "${openclawStateDir}/openclaw.json";
    OPENCLAW_OAUTH_DIR = openclawOAuthDir;
    OPENCLAW_NIX_MODE = "1";
  };

  home.activation.ensureOpenclawOAuthDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /bin/mkdir -p "${openclawOAuthDir}"
    /bin/chmod 700 "${openclawOAuthDir}"
  '';

  home.activation.ensureOpenclawWorkspaceDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /bin/mkdir -p "${openclawWorkspaceDir}"
  '';

  home.activation.ensureOpenclawTailscaleHostname = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if "${tailscaleBin}" status --json >/dev/null 2>&1; then
      if ! "${tailscaleBin}" set --hostname "${tailscaleHostName}" >/dev/null 2>&1; then
        /bin/echo "warning: unable to set Tailscale hostname to ${tailscaleHostName}; OpenClaw will keep using its existing Tailscale origin." >&2
      fi
    else
      /bin/echo "warning: Tailscale is not connected; start the app and run 'tailscale set --hostname ${tailscaleHostName}' before using OpenClaw remotely." >&2
    fi
  '';

  programs.zsh.shellAliases = {
    # Prefer the loopback dashboard on sigil; keep the Tailscale URL for remote access.
    ocd = "openclaw dashboard";
  };

  programs.openclaw = {
    documents = documentsDir;
    package = pkgs.openclaw-gateway;
    appPackage = null;
    stateDir = openclawStateDir;
    workspaceDir = openclawWorkspaceDir;

    bundledPlugins = {
      goplaces.enable = false;
    };

    instances.default = {
      enable = true;
      stateDir = openclawStateDir;
      workspaceDir = openclawWorkspaceDir;
      config = openclawBaseConfig;
      launchd.enable = true;
      appDefaults = {
        enable = true;
        attachExistingOnly = true;
        nixMode = true;
      };
    };
  };

  launchd.agents."com.steipete.openclaw.gateway".config.ProgramArguments = lib.mkForce [
    "/bin/sh"
    "-c"
    ''
            read_secret() {
              path="$1"
              name="$2"

              if [ ! -f "$path" ]; then
                echo "missing secret file for $name at $path; run 'rig deploy' to decrypt secrets" >&2
                exit 1
              fi

              value="$(/bin/cat "$path")" || {
                echo "failed to read $name from $path" >&2
                exit 1
              }

              if [ -z "$value" ]; then
                echo "empty value in secret file for $name at $path" >&2
                exit 1
              fi

              printf '%s' "$value"
            }

            config_path="${openclawStateDir}/openclaw.json"
            template_path="${openclawConfigTemplate}"
            tmp_path="$("${mktempBin}" "${openclawStateDir}/openclaw.json.XXXXXX")"
            trap 'rm -f "$tmp_path"' EXIT

            TELEGRAM_OWNER_ID="$(read_secret "${secretsDir}/openclaw/telegram_owner_id" "TELEGRAM_OWNER_ID")"
            OPENCLAW_TAILSCALE_HOSTNAME="$(read_secret "${secretsDir}/openclaw/gateway_hostname" "OPENCLAW_TAILSCALE_HOSTNAME")"

            "${pythonBin}" - "$template_path" "$tmp_path" "$TELEGRAM_OWNER_ID" "$OPENCLAW_TAILSCALE_HOSTNAME" <<'PY'
      import json
      import sys


      def normalize_url(value: str) -> str:
          value = value.strip().rstrip("/")
          if not value:
              raise ValueError("remote hostname is empty")
          if "://" in value:
              return value
          return f"https://{value}"


      template_path, output_path, telegram_owner_id_raw, tailscale_hostname = sys.argv[1:5]

      try:
          telegram_owner_id = int(telegram_owner_id_raw.strip())
      except ValueError:
          print("invalid TELEGRAM_OWNER_ID; expected an integer", file=sys.stderr)
          raise SystemExit(1)

      with open(template_path, "r", encoding="utf-8") as handle:
          config = json.load(handle)

      try:
          origin = normalize_url(tailscale_hostname)
      except ValueError as exc:
          print(f"invalid OPENCLAW_TAILSCALE_HOSTNAME: {exc}", file=sys.stderr)
          raise SystemExit(1)
      allowed_origins = config["gateway"]["controlUi"]["allowedOrigins"]
      if origin not in allowed_origins:
          allowed_origins.append(origin)

      telegram = config["channels"]["telegram"]
      telegram["allowFrom"] = [telegram_owner_id]
      telegram["groupAllowFrom"] = [telegram_owner_id]

      with open(output_path, "w", encoding="utf-8") as handle:
          json.dump(config, handle, indent=2)
          handle.write("\n")
      PY

            /bin/chmod 600 "$tmp_path"
            /bin/mv "$tmp_path" "$config_path"
            trap - EXIT

            OPENCLAW_GATEWAY_TOKEN="$(read_secret "${secretsDir}/openclaw/gateway_token" "OPENCLAW_GATEWAY_TOKEN")" \
            TELEGRAM_BOT_TOKEN="$(read_secret "${secretsDir}/openclaw/telegram_bot_token" "TELEGRAM_BOT_TOKEN")" \
            BRAVE_API_KEY="$(read_secret "${secretsDir}/openclaw/brave_api_key" "BRAVE_API_KEY")" \
              exec "${pkgs.openclaw-gateway}/bin/openclaw" gateway --port 18789
    ''
  ];
}
