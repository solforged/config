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
      }
      // lib.optionalAttrs cfg.profiles.development.enable {
        za = "agent-session";
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
          if [[ -d "/opt/homebrew/share/zsh/site-functions" ]]; then
            fpath[1,0]="/opt/homebrew/share/zsh/site-functions"
          elif [[ -d "/usr/local/share/zsh/site-functions" ]]; then
            fpath[1,0]="/usr/local/share/zsh/site-functions"
          fi
        '')

        (lib.mkOrder 600 ''
          # --- keybindings ---
          bindkey -e

          # word navigation
          bindkey '^[[1;5C' forward-word         # Ctrl+Right
          bindkey '^[[1;5D' backward-word        # Ctrl+Left
          bindkey '^[[1;3C' forward-word         # Alt+Right  (also partial-accepts autosuggestion)
          bindkey '^[[1;3D' backward-word        # Alt+Left

          # home / end
          bindkey '^[[H' beginning-of-line
          bindkey '^[[F' end-of-line

          # word deletion
          bindkey '^[[3;5~' kill-word            # Ctrl+Delete
          bindkey '^[^?' backward-kill-word      # Alt+Backspace

          # edit command line in $EDITOR (Ctrl+X Ctrl+E)
          autoload -U edit-command-line
          zle -N edit-command-line
          bindkey '^X^E' edit-command-line

          # Ctrl+Z toggle — press again to foreground suspended job
          _zsh-fg() { fg 2>/dev/null; zle redisplay; }
          zle -N _zsh-fg
          bindkey '^Z' _zsh-fg
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

          ${lib.optionalString cfg.profiles.development.enable ''
            agent-session() {
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

              session="agent-$session"

              cd "$root" || return

              if zellij list-sessions --short 2>/dev/null | grep -Fxq "$session"; then
                exec zellij attach "$session"
              else
                exec zellij --session "$session" --layout agent
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

        (lib.mkOrder 1350 ''
          if [[ "$OSTYPE" == darwin* ]]; then
            if [[ -z "$SSH_AUTH_SOCK" ]] && (( $+commands[launchctl] )); then
              export SSH_AUTH_SOCK="$(launchctl getenv SSH_AUTH_SOCK 2>/dev/null)"
            fi

            ssh_agent_state=2
            if [[ -n "$SSH_AUTH_SOCK" ]]; then
              /usr/bin/ssh-add -l >/dev/null 2>&1
              ssh_agent_state=$?
            fi

            if [[ $ssh_agent_state -eq 2 ]] && [[ -f ~/.ssh/id_ed25519 ]]; then
              eval "$(/usr/bin/ssh-agent -s)" >/dev/null
              (( $+commands[launchctl] )) && launchctl setenv SSH_AUTH_SOCK "$SSH_AUTH_SOCK" >/dev/null 2>&1 || true
              ssh_agent_state=1
            fi

            if [[ $ssh_agent_state -ne 0 ]] && [[ -f ~/.ssh/id_ed25519 ]]; then
              /usr/bin/ssh-add --apple-load-keychain ~/.ssh/id_ed25519 >/dev/null 2>&1 \
                || /usr/bin/ssh-add --apple-use-keychain ~/.ssh/id_ed25519 >/dev/null 2>&1 \
                || true
            fi
          fi
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
