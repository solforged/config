{
  description = "Host-centric Nix systems for macOS and Linux";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-openclaw.url = "github:openclaw/nix-openclaw";
    nix-openclaw.inputs.nixpkgs.follows = "nixpkgs";
    nix-openclaw.inputs.home-manager.follows = "home-manager";
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      dotfilesLib = import ./lib {
        inherit inputs self;
      };
      sigil = import ./hosts/darwin/sigil;
    in
    {
      lib = dotfilesLib;

      overlays.default = import ./overlays;

      packages = {
        aarch64-darwin = import ./pkgs {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        };
        x86_64-linux = import ./pkgs {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
      };

      darwinConfigurations.sigil = dotfilesLib.mkDarwinHost {
        host = sigil;
      };

      checks = {
        aarch64-darwin = {
          sigil = self.darwinConfigurations.sigil.system;
        };
      };

      nixosConfigurations = { };

      formatter = {
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      };
    };
}
