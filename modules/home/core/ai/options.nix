{
  lib,
  self,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
  inherit (self.lib) mkOpt;
in
{
  options.platform.ai = {
    enable = mkEnableOption "Codex-first local AI helpers";

    openclawRemoteUrl =
      mkOpt (types.nullOr types.str) null
        "Optional remote OpenClaw URL exposed to local helper commands.";
    openclawRemoteHostnameFile =
      mkOpt (types.nullOr types.str) null
        "Path to a file containing the remote OpenClaw hostname, resolved at helper runtime.";

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

      apiKeyFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "~/.local/state/platform/secrets/groq/api_key";
        description = "Path to a file containing the Groq API key, exported as GROQ_API_KEY at shell startup.";
      };
    };

    claude.package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Claude Code package to install. Null disables the default (e.g. when an external HM module provides it).";
    };

    claude.bypassPermissions = mkOption {
      type = types.bool;
      default = false;
      description = "Skip all permission prompts (including shell-operator heuristics). Only enable in sandboxed/container environments.";
    };

    claude.settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Content for ~/.claude/settings.json — global Claude Code settings.";
    };

    codex.settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Content for $CODEX_HOME/config.toml — merged with runtime Codex state such as trusted projects.";
    };
  };
}
