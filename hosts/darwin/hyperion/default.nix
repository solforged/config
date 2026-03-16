{
  system = "aarch64-darwin";

  module =
    { ... }:
    {
      imports = [
        ./preferences.nix
        ./packages.nix
      ];

      platform = {
        user = {
          name = "admin";
          home = "/Users/admin";
        };

        host = {
          slug = "hyperion";
          title = "hyperion";
          platform = "aarch64-darwin";
          stateVersion = 6;
          homeStateVersion = "25.11";
        };
      };
    };
}
