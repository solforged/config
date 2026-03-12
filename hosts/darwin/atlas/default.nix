{
  system = "aarch64-darwin";

  module =
    { ... }:
    {
      imports = [
        ./preferences.nix
      ];

      platform = {
        user = {
          name = "admin";
          home = "/Users/admin";
        };

        host = {
          slug = "atlas";
          title = "atlas";
          platform = "aarch64-darwin";
          stateVersion = 6;
          homeStateVersion = "25.11";
        };
      };
    };
}
