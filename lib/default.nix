{ inputs, self }:
let
  localIdentityModule = ../modules/local/identity.nix;

  sharedModules = [
    ../modules/shared/options.nix
    ../modules/shared/base.nix
  ];

  profileModules = [
    ../profiles/base.nix
    ../profiles/desktop.nix
    ../profiles/development.nix
    ../profiles/media.nix
    ../profiles/personal.nix
    ../profiles/work.nix
  ];
in
{
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
      } // extraSpecialArgs;
      modules =
        sharedModules
        ++ profileModules
        ++ inputs.nixpkgs.lib.optionals (builtins.pathExists localIdentityModule) [
          localIdentityModule
        ]
        ++ [
          inputs.determinate.darwinModules.default
          inputs.home-manager.darwinModules.home-manager
          ../modules/darwin/base.nix
          ../modules/darwin/homebrew.nix
          ../modules/darwin/activation.nix
          ../modules/home/base.nix
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
      } // extraSpecialArgs;
      modules =
        sharedModules
        ++ profileModules
        ++ inputs.nixpkgs.lib.optionals (builtins.pathExists localIdentityModule) [
          localIdentityModule
        ]
        ++ [
          inputs.home-manager.nixosModules.home-manager
          ../modules/nixos/base.nix
          ../modules/home/base.nix
        ]
        ++ extraModules
        ++ [
          host.module
        ];
    };
}
