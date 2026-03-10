{
  description = "OpenClaw music plugin for sigil";

  inputs = {
    dotfiles.url = "../../../../";
    nixpkgs.follows = "dotfiles/nixpkgs";
  };

  outputs =
    {
      dotfiles,
      nixpkgs,
      ...
    }:
    {
      openclawPlugin = system: {
        name = "music";
        skills = [ ./skills/music ];
        packages = [
          dotfiles.packages.${system}.musicctl
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
