{
  config,
  lib,
  osConfig,
  pkgs,
  self,
  ...
}:
let
  cfg = osConfig.platform;
  openclawCfg = cfg.openclaw;
  documentsDir = builtins.path {
    path = self.outPath + "/hosts/darwin/sigil/openclaw/documents";
    name = "openclaw-documents";
  };
  openclawStateDir = "${config.xdg.stateHome}/openclaw";
  openclawOAuthDir = "${openclawStateDir}/credentials";
  openclawWorkspaceDir = "${config.xdg.dataHome}/openclaw/workspace";
  opCliBin = "/opt/homebrew/bin/op";
  installBin = lib.getExe' pkgs.coreutils "install";
  bootstrapDocNames = [
    "AGENTS.md"
    "SOUL.md"
    "TOOLS.md"
    "IDENTITY.md"
  ];
  bootstrapDocRelPath = name: ".local/share/openclaw/workspace/${name}";
  bootstrapDocSources = builtins.listToAttrs (
    map (name: {
      inherit name;
      value = config.home.file."${bootstrapDocRelPath name}".source;
    }) bootstrapDocNames
  );
  tailscaleBin = lib.getExe' pkgs.tailscale "tailscale";
  tailscaleHostName = cfg.host.slug;
  tailscaleMagicDnsName = openclawCfg.tailscaleMagicDnsName;
  telegramOwnerId = openclawCfg.telegramOwnerId;
  # Keep the 1Password item refs close to the host-specific service wiring so
  # rotating or relocating an item only requires one edit.
  openclawSecretRefs = {
    braveApiKey = "op://Private/Brave Search/credential";
    gatewayToken = "op://Private/OpenClaw Gateway Token/credential";
    telegramBotToken = "op://Private/Telegram Bot Token/credential";
  };
in
{
  assertions = [
    {
      assertion = tailscaleMagicDnsName != null;
      message = "platform.openclaw.tailscaleMagicDnsName must be set for OpenClaw hosts.";
    }
    {
      assertion = telegramOwnerId != null;
      message = "platform.openclaw.telegramOwnerId must be set for OpenClaw hosts.";
    }
  ];

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

  home.file = lib.genAttrs (map bootstrapDocRelPath bootstrapDocNames) (_: {
    enable = lib.mkForce false;
  });

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

  home.activation.ensureOpenclawTailscaleHostname = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if "${tailscaleBin}" status --json >/dev/null 2>&1; then
      if ! "${tailscaleBin}" set --hostname "${tailscaleHostName}" >/dev/null 2>&1; then
        /bin/echo "warning: unable to set Tailscale hostname to ${tailscaleHostName}; OpenClaw will keep using the current MagicDNS name." >&2
      fi
    else
      /bin/echo "warning: Tailscale is not connected; start the app and run 'tailscale set --hostname ${tailscaleHostName}' so OpenClaw resolves ${tailscaleMagicDnsName}." >&2
    fi
  '';

  home.activation.materializeOpenclawBootstrapDocs = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    /bin/mkdir -p "${openclawWorkspaceDir}"

    # OpenClaw rejects workspace symlinks that resolve outside the workspace
    # root, so materialize the Nix-generated bootstrap docs as plain files
    # after Home Manager finishes its normal link step.
    ${lib.concatStringsSep "\n" (
      map (name: ''
        run rm -f "${openclawWorkspaceDir}/${name}"
        "${installBin}" -m 0644 "${bootstrapDocSources.${name}}" "${openclawWorkspaceDir}/${name}"
      '') bootstrapDocNames
    )}
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
      config = {
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
            "https://${tailscaleMagicDnsName}"
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
          allowFrom = [
            telegramOwnerId
          ];
          dmPolicy = "allowlist";
          # Telegram group senders are authorized separately from DMs/pairing.
          groupAllowFrom = [
            telegramOwnerId
          ];
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
      op_bin="${opCliBin}"
      if [ ! -x "$op_bin" ]; then
        echo "missing 1Password CLI at $op_bin" >&2
        exit 1
      fi

      read_secret() {
        ref="$1"
        name="$2"

        value="$("$op_bin" read "$ref" 2>/dev/null)" || {
          echo "failed to read $name from $ref; verify the item reference and that 1Password CLI is signed in" >&2
          exit 1
        }

        if [ -z "$value" ]; then
          echo "empty value returned for $name from $ref" >&2
          exit 1
        fi

        printf '%s' "$value"
      }

      OPENCLAW_GATEWAY_TOKEN="$(read_secret "${openclawSecretRefs.gatewayToken}" "OPENCLAW_GATEWAY_TOKEN")" \
      TELEGRAM_BOT_TOKEN="$(read_secret "${openclawSecretRefs.telegramBotToken}" "TELEGRAM_BOT_TOKEN")" \
      BRAVE_API_KEY="$(read_secret "${openclawSecretRefs.braveApiKey}" "BRAVE_API_KEY")" \
        exec "${pkgs.openclaw-gateway}/bin/openclaw" gateway --port 18789
    ''
  ];
}
