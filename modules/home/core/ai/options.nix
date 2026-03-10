{ lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.dotfiles.ai = {
    enable = mkEnableOption "Codex-first local AI helpers";

    openclawRemoteUrl = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "https://server.domain.ts.net";
      description = "Optional remote OpenClaw URL exposed to local helper commands.";
    };
  };
}
