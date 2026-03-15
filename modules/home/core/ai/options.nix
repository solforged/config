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

    openclawRemoteHostnameOpRef = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "op://Private/OpenClaw Gateway Token/hostname";
      description = "Optional 1Password reference for a remote OpenClaw hostname resolved at helper runtime.";
    };

    claude.settingsLocal = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Content for ~/.claude/settings.local.json — user-local overrides merged on top of managed settings.json.";
    };
  };
}
