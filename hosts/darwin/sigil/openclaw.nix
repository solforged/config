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
in
{
  home.activation.prepareOpenclawConfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    if [ -f "${openclawStateDir}/openclaw.json" ] && [ ! -L "${openclawStateDir}/openclaw.json" ]; then
      timestamp="$(${lib.getExe' pkgs.coreutils "date"} +%Y%m%d-%H%M%S)"
      backupPath="${openclawStateDir}/openclaw.json.runtime-$timestamp"
      suffix=0

      while [ -e "$backupPath" ]; do
        suffix=$((suffix + 1))
        backupPath="${openclawStateDir}/openclaw.json.runtime-$timestamp.$suffix"
      done

      run /bin/mv "${openclawStateDir}/openclaw.json" "$backupPath"
    fi
  '';

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

        env.vars = {
          OPENAI_API_KEY = "${secretDir}/openai-api-key";
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
