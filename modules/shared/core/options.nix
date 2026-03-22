{
  config,
  lib,
  self,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (self.lib) mkOpt;
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

      fullName =
        mkOpt (types.nullOr types.str) null
          "Human-readable account name. Leave null and override locally if preferred.";
      email =
        mkOpt (types.nullOr types.str) null
          "Primary email used for git identity defaults. Leave null and override locally if preferred.";
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
      shell = mkOpt (types.enum [
        "zsh"
        "fish"
        "nushell"
      ]) "zsh" "Preferred interactive shell.";

      editor = mkOpt (types.enum [
        "nvim"
        "emacs"
        "helix"
      ]) "nvim" "Preferred editor.";

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

      terminal = mkOpt (types.enum [
        "ghostty"
        "kitty"
        "terminal"
      ]) "terminal" "Preferred GUI terminal.";

      browser = mkOpt (types.enum [
        "brave"
        "chatgpt-atlas"
        "chrome"
        "safari"
        "none"
      ]) "none" "Preferred browser.";

      notes = mkOpt (types.enum [
        "obsidian"
        "none"
      ]) "none" "Preferred notes app.";

      passwordManager = mkOpt (types.enum [
        "1password"
        "bitwarden"
        "proton-pass"
        "none"
      ]) "none" "Preferred password manager integration.";
    };

    local = {
      repoRoot =
        mkOpt types.str "${config.platform.user.home}/dev/personal/repos/config"
          "Absolute path to this config repository checkout.";
      gitInclude =
        mkOpt types.str "~/.config/git/local.inc"
          "Optional git include file kept outside the repo.";
      sshConfig =
        mkOpt types.str "~/.ssh/config.local*"
          "Optional SSH include glob kept outside the repo.";
      zshLocal = mkOpt types.str "~/.config/zsh/local.zsh" "Optional zsh override kept outside the repo.";
    };

    secrets = {
      stateDir =
        mkOpt types.str "${config.platform.user.home}/.local/state/platform/secrets"
          "Absolute runtime secrets directory populated by activation.";
    };

    packages = {
      home = mkOpt (types.listOf types.package) [ ] "Merged Home Manager package set from profiles.";
      system = mkOpt (types.listOf types.package) [ ] "Merged system package set from profiles.";
    };

    hooks = {
      postDeploy =
        mkOpt (types.listOf types.str) [ ]
          "Shell script fragments to run after rig deploy completes.";
    };
  };

  config.assertions = [
    {
      assertion = builtins.elem cfg.editor cfg.enabledEditors;
      message = "platform.apps.editor must be included in platform.apps.enabledEditors.";
    }
  ];
}
