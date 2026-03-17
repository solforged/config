{
  system = "aarch64-linux";

  module =
    { ... }:
    {
      imports = [
        ./preferences.nix
      ];

      platform = {
        user = {
          name = "admin";
          home = "/home/admin";
        };

        host = {
          slug = "sigil-test";
          title = "sigil-test";
          platform = "aarch64-linux";
          stateVersion = "25.11";
          homeStateVersion = "25.11";
        };
      };
    };
}
