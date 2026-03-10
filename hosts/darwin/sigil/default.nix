{
  system = "aarch64-darwin";

  module =
    { inputs, ... }:
    {
      nixpkgs.overlays = [
        inputs.nix-openclaw.overlays.default
      ];

      home-manager.sharedModules = [
        inputs.nix-openclaw.homeManagerModules.openclaw
      ];

      home-manager.users.admin.imports = [
        ./openclaw.nix
      ];

      dotfiles = {
        user = {
          name = "admin";
          home = "/Users/admin";
        };

        host = {
          slug = "sigil";
          title = "sigil";
          platform = "aarch64-darwin";
          stateVersion = 6;
          homeStateVersion = "25.11";
        };

        profiles = [
          "base"
          "desktop"
          "development"
          "media"
          "personal"
        ];

        apps = {
          shell = "zsh";
          editor = "nvim";
          terminal = "ghostty";
          browser = "brave";
          passwordManager = "proton-pass";
        };

        features = {
          homebrew.enable = true;
          dock.enable = true;
          touchIdSudo.enable = true;
          capsToCtrl.enable = true;
        };

        power.settings = {
          displaysleep = 10;
          disksleep = 0;
          sleep = 0;
          tcpkeepalive = true;
          ttyskeepawake = true;
          womp = true;
        };

        openclaw = {
          tailscaleMagicDnsName = "sigil.ussuri-alphard.ts.net";
          telegramOwnerId = 7703164198;
        };

        ai.openclawRemoteUrl = "https://sigil.ussuri-alphard.ts.net";

        packages.system = [
          inputs.nixpkgs.legacyPackages.aarch64-darwin.tailscale
        ];

        homebrew.casks = [
          "tailscale-app"
        ];

        homebrew.masApps = {
          # "AdGuard Mini" = 1555374974;
          # Amphetamine = 937984704;
          # "Dark Reader for Safari" = 1438243180;
          # Surfingkeys = 1498893305;
        };
      };
    };
}
