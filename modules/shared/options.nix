{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.dotfiles = {
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

    profiles = mkOption {
      type = types.listOf (
        types.enum [
          "base"
          "desktop"
          "development"
          "media"
          "personal"
          "work"
        ]
      );
      default = [ "base" ];
      description = "Composable profile modules enabled for the host.";
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
        ];
        default = "nvim";
        description = "Preferred editor.";
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
        default = "~/.local/state/dotfiles/secrets";
        description = "Directory where age-encrypted repo files are decrypted at runtime.";
      };
    };

    openclaw = {
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

    music = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable the sigil-first music management foundation.";
      };

      beets.enable = mkOption {
        type = types.bool;
        default = true;
        description = "Install and configure beets-backed read-only music library helpers.";
      };

      roon.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Install Roon bootstrap tooling for diagnostics only.";
      };

      openclaw.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Expose the music helper through the host OpenClaw instance.";
      };
    };

    ai = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Codex-first local AI helpers for development hosts.";
      };

      openclawRemoteUrl = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "https://server.domain.ts.net";
        description = "Optional remote OpenClaw URL exposed to local helper commands.";
      };
    };

    features = {
      homebrew.enable = mkOption {
        type = types.bool;
        default = true;
        description = "Manage Homebrew through nix-darwin.";
      };

      dock.enable = mkOption {
        type = types.bool;
        default = true;
        description = "Apply an opinionated Dock layout on Darwin desktop hosts.";
      };

      touchIdSudo.enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Touch ID for sudo via activation script.";
      };

      capsToCtrl.enable = mkOption {
        type = types.bool;
        default = true;
        description = "Map Caps Lock to Control via hidutil on Darwin.";
      };
    };

    power = {
      settings = mkOption {
        type = types.attrsOf (
          types.oneOf [
            types.bool
            types.int
          ]
        );
        default = { };
        example = {
          displaysleep = 10;
          disksleep = 0;
          sleep = 0;
          tcpkeepalive = true;
          womp = true;
        };
        description = "Darwin power-management settings applied via pmset -a during activation.";
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

    homebrew = {
      taps = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Merged Homebrew taps from profiles.";
      };

      brews = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Merged Homebrew brews from profiles.";
      };

      casks = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Merged Homebrew casks from profiles.";
      };

      masApps = mkOption {
        type = types.attrsOf types.int;
        default = { };
        example = {
          Amphetamine = 937984704;
        };
        description = "Merged Mac App Store applications for nix-darwin Homebrew management.";
      };
    };
  };
}
