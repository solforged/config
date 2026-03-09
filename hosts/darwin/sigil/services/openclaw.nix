{
  config,
  lib,
  osConfig,
  pkgs,
  self,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = osConfig.dotfiles;
  openclawCfg = cfg.openclaw;
  documentsDir = builtins.path {
    path = self.outPath + "/hosts/darwin/sigil/openclaw/documents";
    name = "openclaw-documents";
  };
  secretDir = "${config.xdg.stateHome}/dotfiles/secrets/openclaw";
  openclawStateDir = "${config.xdg.stateHome}/openclaw";
  openclawOAuthDir = "${openclawStateDir}/credentials";
  openclawWorkspaceDir = "${config.xdg.dataHome}/openclaw/workspace";
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
in
{
  assertions = [
    {
      assertion = tailscaleMagicDnsName != null;
      message = "dotfiles.openclaw.tailscaleMagicDnsName must be set for OpenClaw hosts.";
    }
    {
      assertion = telegramOwnerId != null;
      message = "dotfiles.openclaw.telegramOwnerId must be set for OpenClaw hosts.";
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

  home.activation.clearOpenclawGatewayTokenEnv = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /bin/launchctl unsetenv OPENCLAW_GATEWAY_TOKEN || true
  '';

  home.activation.ensureOpenclawBraveApiKeyEnv = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f "${secretDir}/brave-api-key" ]; then
      key="$(${lib.getExe' pkgs.coreutils "cat"} "${secretDir}/brave-api-key")"
      /bin/launchctl setenv BRAVE_API_KEY "$key"
    fi
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
          tokenFile = "${secretDir}/telegram-bot-token";
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
      tokenFile="${secretDir}/gateway-token"
      if [ ! -f "$tokenFile" ]; then
        echo "missing $tokenFile" >&2
        exit 1
      fi
      OPENCLAW_GATEWAY_TOKEN="$(${lib.getExe' pkgs.coreutils "cat"} "$tokenFile")" \
        exec "${pkgs.openclaw-gateway}/bin/openclaw" gateway --port 18789
    ''
  ];
}
