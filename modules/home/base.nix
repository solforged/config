{
  config,
  lib,
  pkgs,
  inputs,
  self,
  ...
}:
let
  cfg = config.dotfiles;

  editorCommand = if cfg.apps.editor == "emacs" then "emacsclient -c -a emacs" else "nvim";

  selectedPackages = [
    pkgs.starship
  ]
  ++ lib.optionals (cfg.apps.shell == "fish") [ pkgs.fish ]
  ++ lib.optionals (cfg.apps.shell == "nushell") [ pkgs.nushell ]
  ++ lib.optionals (cfg.apps.editor == "nvim") [ pkgs.neovim ]
  ++ lib.optionals (cfg.apps.editor == "emacs") [ pkgs.emacs ];
in
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";
  home-manager.extraSpecialArgs = {
    inherit inputs self;
  };

  home-manager.users.${cfg.user.name} =
    { config, lib, ... }:
    {
      imports = [
        ./dock.nix
        ./fish.nix
        ./git.nix
        ./nushell.nix
        ./prompt.nix
        ./ssh.nix
        ./zsh.nix
        ./ghostty.nix
        ./yazi.nix
        ./zellij.nix
        ./nvim.nix
      ];

      home.username = cfg.user.name;
      home.homeDirectory = cfg.user.home;
      home.stateVersion = cfg.host.homeStateVersion;

      home.packages = lib.unique (cfg.packages.home ++ selectedPackages);

      xdg.enable = true;

      home.sessionPath = [ "$HOME/.local/bin" ];

      home.sessionVariables = {
        AWS_CONFIG_FILE = "$XDG_CONFIG_HOME/aws/config";
        AWS_SHARED_CREDENTIALS_FILE = "$XDG_CONFIG_HOME/aws/credentials";
        BAT_THEME = "Monokai Extended";
        BUILDX_CONFIG = "$XDG_STATE_HOME/docker/buildx";
        CARGO_HOME = "$XDG_DATA_HOME/cargo";
        CODEX_HOME = "$XDG_DATA_HOME/codex";
        DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
        EDITOR = editorCommand;
        GNUPGHOME = "$XDG_CONFIG_HOME/gnupg";
        GOPATH = "$XDG_DATA_HOME/go";
        IPYTHONDIR = "$XDG_CONFIG_HOME/ipython";
        JUPYTER_CONFIG_DIR = "$XDG_CONFIG_HOME/jupyter";
        JUPYTER_DATA_DIR = "$XDG_DATA_HOME/jupyter";
        KUBECONFIG = "$XDG_CONFIG_HOME/kube/config";
        LESSHISTFILE = "$XDG_STATE_HOME/less/history";
        NPM_CONFIG_CACHE = "$XDG_CACHE_HOME/npm";
        NPM_CONFIG_PREFIX = "$XDG_DATA_HOME/npm";
        NPM_CONFIG_USERCONFIG = "$XDG_CONFIG_HOME/npm/npmrc";
        PSQL_HISTORY = "$XDG_STATE_HOME/psql/history";
        PYTHON_HISTORY = "$XDG_STATE_HOME/python/history";
        RIG_HOST = cfg.host.slug;
        RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
        TASKDATA = "$XDG_DATA_HOME/task";
        TASKRC = "$XDG_CONFIG_HOME/task/taskrc";
        VISUAL = editorCommand;
      };

      programs.bat.enable = true;
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      programs.eza.enable = true;
      programs.fzf.enable = true;
      programs.home-manager.enable = true;
      programs.zoxide.enable = true;

      home.activation.ensureGnupgHome = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        /bin/mkdir -p "${config.xdg.configHome}/gnupg"
        /bin/chmod 700 "${config.xdg.configHome}/gnupg"
      '';

      home.activation.ensureCodexHome = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        /bin/mkdir -p "${config.xdg.dataHome}/codex"
      '';

      home.file.".local/bin/rig".source = ../../bin/rig;
      home.file.".config/nix-darwin/README.md".text = ''
        Local-only overrides belong outside the flake.
        Common examples:
          $XDG_STATE_HOME/dotfiles/secrets
          ~/.config/fish/local.fish
          ~/.config/git/local.inc
          ~/.config/nushell/local.nu
          ~/.config/zsh/local.zsh
          ~/.ssh/config.local
      '';
    };
}
