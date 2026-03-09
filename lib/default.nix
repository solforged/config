{ inputs, self }:
let
  nixpkgsLib = inputs.nixpkgs.lib;
  localIdentityModule = ../modules/local/identity.nix;
  supportedSystems = [
    "aarch64-darwin"
    "x86_64-linux"
  ];
  sharedModules = [ ../modules/shared ];
  profileModules = [ ../profiles ];
in
{
  inherit supportedSystems;

  forAllSystems =
    f:
    builtins.listToAttrs (
      map (system: {
        name = system;
        value = f system;
      }) supportedSystems
    );

  discoverHosts =
    dir:
    if builtins.pathExists dir then
      let
        entries = builtins.readDir dir;
        hostNames = nixpkgsLib.filter (
          name: entries.${name} == "directory" && builtins.pathExists "${dir}/${name}/default.nix"
        ) (builtins.attrNames entries);
      in
      builtins.listToAttrs (
        map (name: {
          inherit name;
          value = import (dir + "/${name}");
        }) hostNames
      )
    else
      { };

  mkDarwinHost =
    {
      host,
      extraModules ? [ ],
      extraSpecialArgs ? { },
    }:
    inputs.nix-darwin.lib.darwinSystem {
      system = host.system;
      specialArgs = {
        inherit inputs self;
      }
      // extraSpecialArgs;
      modules =
        sharedModules
        ++ profileModules
        ++ nixpkgsLib.optionals (builtins.pathExists localIdentityModule) [
          localIdentityModule
        ]
        ++ [
          inputs.determinate.darwinModules.default
          inputs.home-manager.darwinModules.home-manager
          ../modules/darwin
          ../modules/home
        ]
        ++ extraModules
        ++ [
          host.module
        ];
    };

  mkNixosHost =
    {
      host,
      extraModules ? [ ],
      extraSpecialArgs ? { },
    }:
    inputs.nixpkgs.lib.nixosSystem {
      system = host.system;
      specialArgs = {
        inherit inputs self;
      }
      // extraSpecialArgs;
      modules =
        sharedModules
        ++ profileModules
        ++ nixpkgsLib.optionals (builtins.pathExists localIdentityModule) [
          localIdentityModule
        ]
        ++ [
          inputs.home-manager.nixosModules.home-manager
          ../modules/nixos
          ../modules/home
        ]
        ++ extraModules
        ++ [
          host.module
        ];
    };

  mkChecks =
    {
      darwinHosts ? { },
      darwinConfigurations ? { },
      nixosHosts ? { },
      nixosConfigurations ? { },
    }:
    let
      addCheck =
        acc: system: name: value:
        acc
        // {
          ${system} = (acc.${system} or { }) // {
            ${name} = value;
          };
        };

      darwinChecks = nixpkgsLib.foldl' (
        acc: name: addCheck acc darwinHosts.${name}.system name darwinConfigurations.${name}.system
      ) { } (builtins.attrNames darwinHosts);

      nixosChecks = nixpkgsLib.foldl' (
        acc: name:
        addCheck acc nixosHosts.${name}.system name nixosConfigurations.${name}.config.system.build.toplevel
      ) { } (builtins.attrNames nixosHosts);
    in
    nixpkgsLib.recursiveUpdate darwinChecks nixosChecks;
}
