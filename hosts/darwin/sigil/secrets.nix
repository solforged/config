{ config, ... }:
let
  cfg = config.platform;
  secretsDir = cfg.secrets.stateDir;
in
{
  sops.secrets = {
    "openclaw/brave_api_key" = {
      path = "${secretsDir}/openclaw/brave_api_key";
      owner = cfg.user.name;
      mode = "0600";
    };
    "openclaw/gateway_token" = {
      path = "${secretsDir}/openclaw/gateway_token";
      owner = cfg.user.name;
      mode = "0600";
    };
    "openclaw/gateway_hostname" = {
      path = "${secretsDir}/openclaw/gateway_hostname";
      owner = cfg.user.name;
      mode = "0600";
    };
    "openclaw/telegram_bot_token" = {
      path = "${secretsDir}/openclaw/telegram_bot_token";
      owner = cfg.user.name;
      mode = "0600";
    };
    "openclaw/telegram_owner_id" = {
      path = "${secretsDir}/openclaw/telegram_owner_id";
      owner = cfg.user.name;
      mode = "0600";
    };
  };
}
