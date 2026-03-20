{
  system = "aarch64-darwin";

  module =
    {
      inputs,
      pkgs,
      self,
      ...
    }:
    {
      imports = [
        ./preferences.nix
        ./packages.nix
        ./power.nix
        ./secrets.nix
      ];

      nixpkgs.overlays = [
        inputs.nix-openclaw.overlays.default
        self.overlays.default
      ];

      services.openssh.enable = true;

      home-manager.sharedModules = [
        inputs.nix-openclaw.homeManagerModules.openclaw
      ];

      home-manager.users.admin.imports = [
        ./services
      ];

      platform = {
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
      };
    };
}
