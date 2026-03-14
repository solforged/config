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
    claude-code-nix.url = "github:sadjow/claude-code-nix";
    worktrunk = {
      url = "github:max-sixty/worktrunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      platformLib = import ./lib {
        inherit inputs self;
      };
      darwinHosts = platformLib.discoverHosts ./hosts/darwin;
      nixosHosts = platformLib.discoverHosts ./hosts/nixos;
      darwinConfigurations = builtins.mapAttrs (
        _: host: platformLib.mkDarwinHost { inherit host; }
      ) darwinHosts;
      nixosConfigurations = builtins.mapAttrs (
        _: host: platformLib.mkNixosHost { inherit host; }
      ) nixosHosts;
    in
    {
      lib = platformLib;

      overlays.default = import ./overlays;

      packages = platformLib.forAllSystems (
        system: import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; }
      );

      inherit darwinConfigurations nixosConfigurations;

      checks = platformLib.mkChecks {
        inherit
          darwinHosts
          darwinConfigurations
          nixosHosts
          nixosConfigurations
          ;
      };

      formatter = platformLib.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
