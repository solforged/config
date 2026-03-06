{
  description = "Host-centric Nix systems for macOS and Linux";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      darwinHosts = dotfilesLib.discoverHosts ./hosts/darwin;
      nixosHosts = dotfilesLib.discoverHosts ./hosts/nixos;
      darwinConfigurations = builtins.mapAttrs (
        _: host: dotfilesLib.mkDarwinHost { inherit host; }
      ) darwinHosts;
      nixosConfigurations = builtins.mapAttrs (
        _: host: dotfilesLib.mkNixosHost { inherit host; }
      ) nixosHosts;
    in
    {
      lib = dotfilesLib;

      overlays.default = import ./overlays;

      packages = dotfilesLib.forAllSystems (
        system: import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; }
      );

      inherit darwinConfigurations nixosConfigurations;

      checks = dotfilesLib.mkChecks {
        inherit
          darwinHosts
          darwinConfigurations
          nixosHosts
          nixosConfigurations
          ;
      };

      formatter = dotfilesLib.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
