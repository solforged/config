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
    let
      homeDirectory = config.home.homeDirectory;
      xdg = config.xdg;
    in
    {
      imports = [
        ./ai.nix
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

      home.sessionPath = [ "${homeDirectory}/.local/bin" ];

      home.sessionVariables = {
        AWS_CONFIG_FILE = "${xdg.configHome}/aws/config";
        AWS_SHARED_CREDENTIALS_FILE = "${xdg.configHome}/aws/credentials";
        BAT_THEME = "Monokai Extended";
        BUILDX_CONFIG = "${xdg.stateHome}/docker/buildx";
        CARGO_HOME = "${xdg.dataHome}/cargo";
        CODEX_HOME = "${xdg.dataHome}/codex";
        DOCKER_CONFIG = "${xdg.configHome}/docker";
        EDITOR = editorCommand;
        GNUPGHOME = "${xdg.configHome}/gnupg";
        GOPATH = "${xdg.dataHome}/go";
        IPYTHONDIR = "${xdg.configHome}/ipython";
        JUPYTER_CONFIG_DIR = "${xdg.configHome}/jupyter";
        JUPYTER_DATA_DIR = "${xdg.dataHome}/jupyter";
        KUBECONFIG = "${xdg.configHome}/kube/config";
        LESSHISTFILE = "${xdg.stateHome}/less/history";
        NPM_CONFIG_CACHE = "${xdg.cacheHome}/npm";
        NPM_CONFIG_PREFIX = "${xdg.dataHome}/npm";
        NPM_CONFIG_USERCONFIG = "${xdg.configHome}/npm/npmrc";
        PSQL_HISTORY = "${xdg.stateHome}/psql/history";
        PYTHON_HISTORY = "${xdg.stateHome}/python/history";
        RIG_HOST = cfg.host.slug;
        RUSTUP_HOME = "${xdg.dataHome}/rustup";
        TASKDATA = "${xdg.dataHome}/task";
        TASKRC = "${xdg.configHome}/task/taskrc";
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
          $XDG_DATA_HOME/codex
          $XDG_STATE_HOME/dotfiles/secrets
          ~/.config/fish/local.fish
          ~/.config/git/local.inc
          ~/.config/nushell/local.nu
          ~/.config/zsh/local.zsh
          ~/.ssh/config.local
      '';
    };
}
