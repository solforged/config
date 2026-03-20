{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.platform;
  repoRoot = cfg.local.repoRoot;
  secretLocalZsh = "${cfg.secrets.stateDir}/zsh/local.zsh";
  localZsh = cfg.local.zshLocal;
in
{
  config = lib.mkIf (cfg.apps.shell == "zsh") {
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = false;
      };
    };

    programs.zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";

      autocd = true;
      enableCompletion = true;

      completionInit = ''
        mkdir -p "${config.xdg.cacheHome}/zsh"
        zstyle ':completion:*' cache-path "${config.xdg.cacheHome}/zsh/zcompcache"
        autoload -U compinit && compinit -d "${config.xdg.cacheHome}/zsh/zcompdump"
      '';

      history = {
        append = true;
        extended = true;
        findNoDups = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        path = "${config.xdg.stateHome}/zsh/history";
        save = 100000;
        share = true;
        size = 100000;
      };

      autosuggestion = {
        enable = true;
        strategy = [
          "history"
          "completion"
        ];
      };

      syntaxHighlighting.enable = true;

      setOptions = [
        "AUTO_PUSHD"
        "COMPLETE_ALIASES"
        "EXTENDED_GLOB"
        "GLOB_DOTS"
        "HIST_REDUCE_BLANKS"
        "HIST_VERIFY"
        "INC_APPEND_HISTORY"
        "INTERACTIVE_COMMENTS"
        "NO_BEEP"
        "NO_NOMATCH"
        "PUSHD_IGNORE_DUPS"
        "PUSHD_SILENT"
      ];

      sessionVariables = {
        PLATFORM_DIR = repoRoot;
        RIG_REPO_ROOT = repoRoot;
      };

      dirHashes = {
        cache = config.xdg.cacheHome;
        cfg = config.xdg.configHome;
        data = config.xdg.dataHome;
        cfp = repoRoot;
        state = config.xdg.stateHome;
      };

      shellAliases = {
        cfp = "cd $PLATFORM_DIR";
        e = "$EDITOR";
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
        md = "mkdir -p";
        nk = "nvim-help";
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
        zp = "project-session";
      }
      // lib.optionalAttrs cfg.profiles.work.enable {
        zw = "work-session";
      };

      zsh-abbr = {
        enable = true;
        globalAbbreviations = {
          b = "brew";
          bi = "brew install";
          brci = "brew install --cask";
          brcu = "brew uninstall --cask";
          brcz = "brew uninstall --cask --zap";
          bs = "brew search";
          bu = "brew uninstall --zap";
          bz = "brew uninstall --zap";
          cache = "~cache";
          cfg = "~cfg";
          ci = "brew install --cask";
          data = "~data";
          df = "~df";
          e = "$EDITOR";
          gcl = "git clone";
          gg = "lazygit";
          md = "mkdir -p";
          state = "~state";
        };
      };

      plugins = [
        {
          name = "fzf-tab";
          src = pkgs.zsh-fzf-tab;
          file = "share/fzf-tab/fzf-tab.plugin.zsh";
        }
      ];

      initContent = lib.mkMerge [
        (lib.mkOrder 550 ''
          if [[ -x "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
          elif [[ -x "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
          fi
        '')

        (lib.mkOrder 1000 ''
          if (( $+commands[eza] )); then
            alias ls='eza --classify=always --group-directories-first --icons=auto'
            alias l='eza --all --binary --classify=always --git --group-directories-first --header --icons=auto --long'
            alias ll='eza --binary --classify=always --git --group-directories-first --icons=auto --long'
            alias la='eza --all --binary --classify=always --git --group-directories-first --icons=auto --long'
            alias lla='eza --all --binary --classify=always --git --group-directories-first --icons=auto --long'
            alias ltr='eza --binary --classify=always --git --group-directories-first --icons=auto --long --sort=modified --treat-dirs-as-files'
            alias llm='eza --all --classify=always --git --group-directories-first --header --icons=auto --long --sort=modified'
            alias lx='eza --accessed --all --binary --blocksize --classify=always --color-scale=all --created --extended --git --group --group-directories-first --header --icons=auto --inode --links --long --modified'
            alias lS='eza --classify=always --group-directories-first --icons=auto --oneline'
            alias lt='eza --classify=always --icons=auto --level=2 --tree'
          else
            alias ll='ls -al'
          fi

          if (( $+commands[mise] )); then
            eval "$(mise activate zsh)"
          fi

          if (( $+commands[zoxide] )); then
            eval "$(zoxide init zsh)"
          fi
        '')

        (lib.mkOrder 1160 ''
          if (( $+commands[eza] )); then
            compdef _eza ls l ll la lla ltr llm lx lS lt
          fi
        '')

        (lib.mkOrder 1200 (
          lib.optionalString cfg.profiles.development.enable ''
            if (( $+commands[wt] )); then
              typeset wt_shell_init
              wt_shell_init="$(
                wt config shell init zsh 2>/dev/null || wt config shell init 2>/dev/null
              )"

              if [[ -n "$wt_shell_init" ]]; then
                eval "$wt_shell_init"
              fi
            fi
          ''
        ))

        (lib.mkOrder 1300 ''
          project-session() {
            local root session

            if root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
              :
            else
              root="$PWD"
            fi

            session="$(basename "$root" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '-')"
            session="''${session#-}"
            session="''${session%-}"

            if [[ -z "$session" ]]; then
              session="shell"
            fi

            cd "$root" || return
            exec zellij attach -c "$session"
          }

          ${lib.optionalString cfg.profiles.work.enable ''
            work-session() {
              local session="work"

              if zellij list-sessions --short 2>/dev/null | grep -Fxq "$session"; then
                exec zellij attach "$session"
              else
                exec zellij --session "$session" --layout work
              fi
            }
          ''}

          ghostty-keys() {
            if ! (( $+commands[ghostty] )); then
              print -u2 "ghostty is not installed"
              return 1
            fi

            ghostty +list-keybinds --default | ${pkgs.less}/bin/less
          }

          nvim-help() {
            exec nvim '+Telescope keymaps'
          }
        '')

        (lib.mkOrder 1400 ''
          if [[ -f "${secretLocalZsh}" ]]; then
            source "${secretLocalZsh}"
          fi

          if [[ -f "${localZsh}" ]]; then
            source "${localZsh}"
          fi
        '')
      ];
    };
  };
}
