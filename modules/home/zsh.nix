{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.dotfiles;
  secretLocalZsh = "${config.xdg.stateHome}/dotfiles/secrets/zsh/local.zsh";
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
        DOTFILES_DIR = "${config.xdg.dataHome}/dotfiles";
      };

      dirHashes = {
        cache = config.xdg.cacheHome;
        cfg = config.xdg.configHome;
        data = config.xdg.dataHome;
        df = "${config.xdg.dataHome}/dotfiles";
        state = config.xdg.stateHome;
      };

      shellAliases = {
        cdd = ''cd "$DOTFILES_DIR"'';
        e = "\${EDITOR:-nvim}";
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
        oc = "openclaw";
        rb = "rig build";
        rc = "rig check";
        rf = "rig fmt";
        rse = "rig secrets edit";
        rsi = "rig secrets import";
        rsk = "rig secrets rekey";
        rsw = "rig switch";
        tldr = "tldr --config-path ${config.xdg.configHome}/tldr/config.toml";
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
          cdd = "cd $DOTFILES_DIR";
          cfg = "~cfg";
          ci = "brew install --cask";
          data = "~data";
          df = "~df";
          e = "nvim";
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
            alias ls='eza --icons'
            alias l='eza -lbFa --git --icons'
            alias ll='eza -lbGFa --git --icons'
            alias la='eza -lbhHigUmuSa --git --color-scale --icons'
            alias ltr='eza -lbGd --git --sort=modified --icons'
            alias llm='eza --all --header --long --sort=modified --git --icons'
            alias lx='eza -lbhHigUmuSa@ --git --color-scale --icons'
            alias lS='eza -1 --icons'
            alias lt='eza --tree --level=2 --icons'
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
            compdef _eza ls l ll la ltr llm lx lS lt
          fi
        '')

        (lib.mkOrder 1400 ''
          if [[ -f "${secretLocalZsh}" ]]; then
            source "${secretLocalZsh}"
          fi

          if [[ -f "${config.xdg.configHome}/zsh/local.zsh" ]]; then
            source "${config.xdg.configHome}/zsh/local.zsh"
          fi
        '')
      ];
    };
  };
}
