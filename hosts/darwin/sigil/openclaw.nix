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

  programs.openclaw = {
    documents = documentsDir;
    package = pkgs.openclaw-gateway;
    appPackage = null;
    stateDir = openclawStateDir;
    workspaceDir = openclawWorkspaceDir;

    bundledPlugins = {
      summarize.enable = true;
      peekaboo.enable = true;
      goplaces.enable = false;
    };

    config = {
      secrets.providers = {
        gatewayToken = {
          source = "file";
          path = "${secretDir}/gateway-token";
          mode = "singleValue";
        };
      };

      env.vars = {
        OPENAI_API_KEY = "${secretDir}/openai-api-key";
      };

      gateway = {
        mode = "local";
        auth = {
          token = {
            source = "file";
            provider = "gatewayToken";
            id = "value";
          };
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
    };

    instances.default = {
      enable = true;
      stateDir = openclawStateDir;
      workspaceDir = openclawWorkspaceDir;
      launchd.enable = true;
      appDefaults = {
        enable = false;
        attachExistingOnly = true;
      };
    };
  };
}
