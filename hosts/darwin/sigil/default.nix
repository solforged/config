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
      };
    };
}
