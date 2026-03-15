{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.platform.apps;
in
{
  options.platform = {
    user = {
      name = mkOption {
        type = types.str;
        example = "admin";
        description = "Local username used by the host.";
      };

      home = mkOption {
        type = types.str;
        example = "/Users/admin";
        description = "Absolute home directory path.";
      };

      fullName = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "Alice Example";
        description = "Human-readable account name. Leave null and override locally if preferred.";
      };

      email = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "alice@example.com";
        description = "Primary email used for git identity defaults. Leave null and override locally if preferred.";
      };
    };

    host = {
      slug = mkOption {
        type = types.str;
        example = "sigil";
        description = "Slug-safe flake host name.";
      };

      title = mkOption {
        type = types.str;
        example = "sigil";
        description = "Human-facing machine name.";
      };

      platform = mkOption {
        type = types.str;
        example = "aarch64-darwin";
        description = "Nix platform identifier.";
      };

      stateVersion = mkOption {
        type = types.oneOf [
          types.int
          types.str
        ];
        description = "System stateVersion for the host platform.";
      };

      homeStateVersion = mkOption {
        type = types.str;
        description = "Home Manager state version.";
      };
    };

    apps = {
      shell = mkOption {
        type = types.enum [
          "zsh"
          "fish"
          "nushell"
        ];
        default = "zsh";
        description = "Preferred interactive shell.";
      };

      editor = mkOption {
        type = types.enum [
          "nvim"
          "emacs"
          "helix"
        ];
        default = "nvim";
        description = "Preferred editor.";
      };

      enabledEditors = mkOption {
        type = types.listOf (
          types.enum [
            "nvim"
            "emacs"
            "helix"
          ]
        );
        default = [ config.platform.apps.editor ];
        description = "Editors to configure on this host.";
      };

      terminal = mkOption {
        type = types.enum [
          "ghostty"
          "kitty"
          "terminal"
        ];
        default = "terminal";
        description = "Preferred GUI terminal.";
      };

      browser = mkOption {
        type = types.enum [
          "brave"
          "chatgpt-atlas"
          "safari"
          "none"
        ];
        default = "none";
        description = "Preferred browser.";
      };

      passwordManager = mkOption {
        type = types.enum [
          "1password"
          "bitwarden"
          "proton-pass"
          "none"
        ];
        default = "none";
        description = "Preferred password manager integration.";
      };
    };

    local = {
      gitInclude = mkOption {
        type = types.str;
        default = "~/.config/git/local.inc";
        description = "Optional git include file kept outside the repo.";
      };

      sshConfig = mkOption {
        type = types.str;
        default = "~/.ssh/config.local*";
        description = "Optional SSH include glob kept outside the repo.";
      };

      zshLocal = mkOption {
        type = types.str;
        default = "~/.config/zsh/local.zsh";
        description = "Optional zsh override kept outside the repo.";
      };
    };

    secrets = {
      stateDir = mkOption {
        type = types.str;
        default = "~/.local/state/platform/secrets";
        description = "Runtime secrets directory populated by rig secrets pull.";
      };
    };

    packages = {
      home = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = "Merged Home Manager package set from profiles.";
      };

      system = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = "Merged system package set from profiles.";
      };
    };

  };

  config.assertions = [
    {
      assertion = builtins.elem cfg.editor cfg.enabledEditors;
      message = "platform.apps.editor must be included in platform.apps.enabledEditors.";
    }
  ];
}
