{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.dotfiles.openclaw = {
    tailscaleMagicDnsName = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "host.example.ts.net";
      description = "MagicDNS hostname exposed to OpenClaw clients when the host runs through Tailscale.";
    };

    telegramOwnerId = mkOption {
      type = types.nullOr types.int;
      default = null;
      example = 123456789;
      description = "Telegram user ID authorized to pair and control the host-specific OpenClaw instance.";
    };
  };
}
