{ lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.platform.ai = {
    enable = mkEnableOption "Codex-first local AI helpers";

    openclawRemoteUrl = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "https://server.domain.ts.net";
      description = "Optional remote OpenClaw URL exposed to local helper commands.";
    };

    claude.settingsLocal = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Content for ~/.claude/settings.local.json — user-local overrides merged on top of managed settings.json.";
    };
  };
}
