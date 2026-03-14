{
  description = "OpenClaw music plugin for sigil";

  inputs = {
    platform.url = "../../../../";
    nixpkgs.follows = "platform/nixpkgs";
  };

  outputs =
    {
      platform,
      nixpkgs,
      ...
    }:
    {
      openclawPlugin = system: {
        name = "music";
        skills = [ ./skills/music ];
        packages = [
          platform.packages.${system}.musicctl
          nixpkgs.legacyPackages.${system}.beets
          nixpkgs.legacyPackages.${system}.roon-tui
        ];
        needs = {
          stateDirs = [ ];
          requiredEnv = [ ];
        };
      };
    };
}
