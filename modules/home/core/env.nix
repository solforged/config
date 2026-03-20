# XDG-compliant session variables and PATH.
#
# Most of these relocate dotfiles out of $HOME and into the appropriate
# XDG base directory. Kept separate from the main home module so the
# mapping is easy to audit and extend.
{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.platform;
  editorCommand =
    if cfg.apps.editor == "emacs" then
      toString (
        pkgs.writeShellScript "emacs-editor" ''
          socket_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/emacs/server"
          exec emacsclient -c -s "$socket_dir/server" -a "" "$@"
        ''
      )
    else if cfg.apps.editor == "helix" then
      "hx"
    else
      "nvim";
  homeDirectory = config.home.homeDirectory;
  xdg = config.xdg;
in
{
  home.sessionPath = [ "${homeDirectory}/.local/bin" ];

  home.sessionVariables = {
    AWS_CONFIG_FILE = "${xdg.configHome}/aws/config";
    AWS_SHARED_CREDENTIALS_FILE = "${xdg.configHome}/aws/credentials";
    BAT_THEME = "TwoDark";
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
}
