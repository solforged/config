{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.platform;
  secretConfig = "${cfg.secrets.stateDir}/nushell/local.nu";
  secretEnv = "${cfg.secrets.stateDir}/nushell/env.nu";
  localConfig = "${config.xdg.configHome}/nushell/local.nu";
  localEnv = "${config.xdg.configHome}/nushell/env.local.nu";
  platformDir = "${cfg.user.home}/dev/personal/repos/config";
  editorCommand = builtins.toString (config.home.sessionVariables.EDITOR or "nvim");
  projectSession = pkgs.writeShellScript "project-session" ''
    if root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
      :
    else
      root="$PWD"
    fi

    session="$(basename "$root" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '-')"
    session="''${session#-}"
    session="''${session%-}"

    if [ -z "$session" ]; then
      session="shell"
    fi

    cd "$root" || exit 1
    exec zellij attach -c "$session"
  '';
  workSession = pkgs.writeShellScript "work-session" ''
    session="work"

    if zellij list-sessions --short 2>/dev/null | grep -Fxq "$session"; then
      exec zellij attach "$session"
    else
      exec zellij --session "$session" --layout work
    fi
  '';
  ghosttyKeys = pkgs.writeShellScript "ghostty-keys" ''
    if ! command -v ghostty >/dev/null 2>&1; then
      echo "ghostty is not installed" >&2
      exit 1
    fi

    ghostty +list-keybinds --default | ${pkgs.less}/bin/less
  '';
  nvimHelp = pkgs.writeShellScript "nvim-help" ''
    exec nvim '+Telescope keymaps'
  '';
  agentSession = pkgs.writeShellScript "agent-session" ''
    if root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
      :
    else
      root="$PWD"
    fi

    session="$(basename "$root" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '-')"
    session="''${session#-}"
    session="''${session%-}"

    if [ -z "$session" ]; then
      session="shell"
    fi

    session="agent-$session"

    cd "$root" || exit 1

    if zellij list-sessions --short 2>/dev/null | grep -Fxq "$session"; then
      exec zellij attach "$session"
    else
      exec zellij --session "$session" --layout agent
    fi
  '';
in
{
  config = lib.mkIf (cfg.apps.shell == "nushell") {
    programs.atuin = {
      enable = true;
      enableNushellIntegration = true;
      settings = {
        auto_sync = false;
      };
    };

    programs.nushell = {
      enable = true;
      environmentVariables = {
        PLATFORM_DIR = platformDir;
      };
      settings = {
        show_banner = false;
        history = {
          format = "sqlite";
          max_size = 100000;
          sync_on_enter = true;
        };
        completions.external = {
          enable = true;
          max_results = 200;
        };
      };
      shellAliases = {
        e = editorCommand;
        g = "git";
        ga = "git add";
        gb = "git branch";
        gc = "git commit";
        gcfg = "git config";
        gg = "lazygit";
        gl = "git log --oneline --decorate --graph";
        gp = "git push";
        gs = "git status -sb";
        lg = "lazygit";
        l = "eza --all --binary --classify=always --git --group-directories-first --header --icons=auto --long";
        la = "eza --all --binary --classify=always --git --group-directories-first --icons=auto --long";
        ll = "eza --binary --classify=always --git --group-directories-first --icons=auto --long";
        lla = "eza --all --binary --classify=always --git --group-directories-first --icons=auto --long";
        llm = "eza --all --classify=always --git --group-directories-first --header --icons=auto --long --sort=modified";
        ls = "eza --classify=always --group-directories-first --icons=auto";
        lS = "eza --classify=always --group-directories-first --icons=auto --oneline";
        lt = "eza --classify=always --icons=auto --level=2 --tree";
        ltr = "eza --binary --classify=always --git --group-directories-first --icons=auto --long --sort=modified --treat-dirs-as-files";
        lx = "eza --accessed --all --binary --blocksize --classify=always --color-scale=all --created --extended --git --group --group-directories-first --header --icons=auto --inode --links --long --modified";
        md = "mkdir -p";
        nk = builtins.toString nvimHelp;
        oc = "openclaw";
        rb = "rig build";
        rc = "rig check";
        rd = "rig deploy";
        rdu = "rig deploy --update";
        rf = "rig fmt";
        rsp = "rig secrets pull";
        rss = "rig secrets scan";
        zj = "zellij";
        zja = "zellij attach -c";
        zjl = "zellij list-sessions";
        zp = builtins.toString projectSession;
        "ghostty-keys" = builtins.toString ghosttyKeys;
        "nvim-help" = builtins.toString nvimHelp;
        "project-session" = builtins.toString projectSession;
      }
      // lib.optionalAttrs cfg.profiles.work.enable {
        zw = builtins.toString workSession;
        "work-session" = builtins.toString workSession;
      }
      // lib.optionalAttrs cfg.profiles.development.enable {
        za = builtins.toString agentSession;
        "agent-session" = builtins.toString agentSession;
      };
      extraConfig = ''
        def --env cache [] {
          cd $env.XDG_CACHE_HOME
        }

        def --env cfg [] {
          cd $env.XDG_CONFIG_HOME
        }

        def --env data [] {
          cd $env.XDG_DATA_HOME
        }

        def --env state [] {
          cd $env.XDG_STATE_HOME
        }

        def --env cfp [] {
          cd $env.PLATFORM_DIR
        }

        if ("${secretConfig}" | path exists) {
          source "${secretConfig}"
        }

        if ("${localConfig}" | path exists) {
          source "${localConfig}"
        }
      '';
      extraEnv = ''
        if ("${secretEnv}" | path exists) {
          source "${secretEnv}"
        }

        if ("${localEnv}" | path exists) {
          source "${localEnv}"
        }
      '';
    };
  };
}
