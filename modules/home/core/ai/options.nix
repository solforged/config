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

    openclawRemoteHostnameFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "~/.local/state/platform/secrets/openclaw/gateway_hostname";
      description = "Path to a file containing the remote OpenClaw hostname, resolved at helper runtime.";
    };

    lumen = {
      enable = mkEnableOption "lumen AI commit message drafting";

      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "Lumen package to install. Set by the profile that enables lumen.";
      };

      provider = mkOption {
        type = types.str;
        default = "groq";
        description = "AI provider for lumen (groq, openai, claude, ollama, etc.).";
      };

      model = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Model override for lumen. Null uses the provider's default.";
      };
    };

    claude.package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Claude Code package to install. Null disables the default (e.g. when an external HM module provides it).";
    };

    claude.settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Content for ~/.claude/settings.json — global Claude Code settings.";
    };
  };
}
