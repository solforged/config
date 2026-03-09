{
  config,
  lib,
  pkgs,
  ...
}:
let
  documentsDir = ../../../config/openclaw/documents;
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
  tailscaleHostName = "sigil";
  tailscaleMagicDnsName = "${tailscaleHostName}.ussuri-alphard.ts.net";
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

  home.activation.ensureOpenclawGatewayTokenEnv = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f "${secretDir}/gateway-token" ]; then
      token="$(${lib.getExe' pkgs.coreutils "cat"} "${secretDir}/gateway-token")"
      /bin/launchctl setenv OPENCLAW_GATEWAY_TOKEN "$token"
    fi
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
            resetOnExit = true;
          };
        };

        channels.telegram = {
          tokenFile = "${secretDir}/telegram-bot-token";
          allowFrom = [
            8190147609
          ];
          groups."*" = {
            requireMention = true;
          };
        };

        agents.defaults.model = {
          primary = "openai-codex/gpt-5.4";
          fallbacks = [
            "anthropic/claude-opus-4-6"
            "google-gemini-cli/gemini-3.1-pro"
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
}
