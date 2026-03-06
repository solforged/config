{ inputs, self }:
let
  nixpkgsLib = inputs.nixpkgs.lib;
  localIdentityModule = ../modules/local/identity.nix;
  supportedSystems = [
    "aarch64-darwin"
    "x86_64-linux"
  ];

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

  appCatalog = {
    browser = {
      brave = {
        cask = "brave-browser";
        dockPath = "/Applications/Brave Browser.app";
      };
      safari = {
        cask = null;
        dockPath = "/System/Applications/Safari.app";
      };
      none = null;
    };

    terminal = {
      ghostty = {
        cask = "ghostty";
        dockPath = "/Applications/Ghostty.app";
      };
      kitty = {
        cask = "kitty";
        dockPath = "/Applications/kitty.app";
      };
      terminal = {
        cask = null;
        dockPath = "/System/Applications/Utilities/Terminal.app";
      };
    };

    passwordManager = {
      "1password" = {
        cask = "1password";
        dockPath = "/Applications/1Password.app";
        extraCasks = [ "1password-cli" ];
      };
      bitwarden = {
        cask = "bitwarden";
        dockPath = "/Applications/Bitwarden.app";
      };
      proton-pass = {
        cask = "proton-pass";
        dockPath = "/Applications/Proton Pass.app";
      };
      none = null;
    };
  };
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
          value = import "${dir}/${name}";
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
          ../modules/nixos/base.nix
          ../modules/home/base.nix
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

  inherit appCatalog;

  resolveSelectedApps = cfg: {
    browser = appCatalog.browser.${cfg.apps.browser};
    terminal = appCatalog.terminal.${cfg.apps.terminal};
    passwordManager = appCatalog.passwordManager.${cfg.apps.passwordManager};
  };
}
