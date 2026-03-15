{
  config,
  inputs,
  lib,
  self,
  ...
}:
let
  cfg = config.platform;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
  use1Password = cfg.apps.passwordManager == "1password";
  editorCommand =
    if cfg.apps.editor == "emacs" then
      "emacsclient -c -a emacs"
    else if cfg.apps.editor == "helix" then
      "hx"
    else
      "nvim";
in
{
  imports = [
    ./core/ai/options.nix
    ./desktop/dock/options.nix
    ./media/music/options.nix
  ];

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
        inputs.nixvim.homeModules.nixvim
        ./core
        ./shell
        ./editor
        ./desktop
        ./media
      ];

      home.username = cfg.user.name;
      home.homeDirectory = cfg.user.home;
      home.stateVersion = cfg.host.homeStateVersion;

      home.packages = lib.unique cfg.packages.home;

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
      }
      // lib.optionalAttrs (use1Password && isDarwin) {
        SSH_AUTH_SOCK = cfg.apps.passwordManagerSshAgentSocket;
      };

      programs.bat.enable = true;
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      programs.eza = {
        enable = true;
        enableZshIntegration = false;
      };
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

      home.file.".hushlogin".text = "";
      home.file.".local/bin/rig".source = ../../bin/rig;
      home.file.".config/nix-darwin/README.md".text = ''
        Local-only overrides belong outside the flake.
        Common examples:
          $XDG_DATA_HOME/codex
          $XDG_STATE_HOME/platform/secrets
          ~/.config/fish/local.fish
          ~/.config/git/local.inc
          ~/.config/nushell/local.nu
          ~/.config/zsh/local.zsh
          ~/.ssh/config.local
      '';
    };
}
