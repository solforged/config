{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = osConfig.dotfiles;
  appearance = cfg.emacs.appearance;

  resolveThemePackage =
    epkgs:
    if appearance.themePackage == null then
      null
    else
      lib.attrByPath [ appearance.themePackage ] null epkgs;

  emacsPackages = pkgs.emacsPackagesFor pkgs.emacs;
  resolvedThemePackage = resolveThemePackage emacsPackages;
  emacsPackage = emacsPackages.emacsWithPackages (
    epkgs:
    let
      themePackage = resolveThemePackage epkgs;
    in
    with epkgs;
    [
      consult
      embark
      embark-consult
      evil
      evil-collection
      general
      magit
      marginalia
      mixed-pitch
      nix-mode
      orderless
      org-modern
      spacious-padding
      tempel
      undo-fu
      vertico
      which-key
    ]
    ++ lib.optionals (themePackage != null) [ themePackage ]
  );

  emacsHome =
    pkgs.runCommandLocal "emacs-home"
      {
        nativeBuildInputs = [ pkgs.emacs ];
        earlyInitOrg = ./config/early-init.org;
        initOrg = ./config/init.org;
        modulesDir = ./config/modules;
      }
      ''
        export HOME="$TMPDIR"
        export XDG_CONFIG_HOME="$TMPDIR/config"
        export XDG_DATA_HOME="$TMPDIR/share"
        export XDG_STATE_HOME="$TMPDIR/state"
        mkdir -p "$out"
        mkdir -p "$out/modules"
        cp "$earlyInitOrg" "$out/early-init.org"
        cp "$initOrg" "$out/init.org"
        cp -R "$modulesDir"/. "$out/modules/"

        ${lib.getExe pkgs.emacs} --batch --quick \
          --eval "(require 'org)" \
          --eval "(require 'ob-tangle)" \
          --eval "(let ((org-confirm-babel-evaluate nil)) (org-babel-tangle-file \"$earlyInitOrg\" \"${"$"}out/early-init.el\" \"emacs-lisp\"))"

        ${lib.getExe pkgs.emacs} --batch --quick \
          --eval "(require 'org)" \
          --eval "(require 'ob-tangle)" \
          --eval "(let ((org-confirm-babel-evaluate nil)) (org-babel-tangle-file \"$initOrg\" \"${"$"}out/init.el\" \"emacs-lisp\"))"

        mkdir -p "$out/lisp"

        for module in "$modulesDir"/*.org; do
          ${lib.getExe pkgs.emacs} --batch --quick \
            --eval "(require 'org)" \
            --eval "(require 'ob-tangle)" \
            --eval "(let ((org-confirm-babel-evaluate nil)) (org-babel-tangle-file \"$module\" \"${"$"}out/lisp/dotfiles-$(basename "$module" .org).el\" \"emacs-lisp\"))"
        done
      '';

  emacsPath = lib.makeBinPath (
    lib.unique (
      [
        emacsPackage
        pkgs.coreutils
        pkgs.findutils
        pkgs.git
        pkgs.gnugrep
        pkgs.nil
        pkgs.nixfmt-rfc-style
        pkgs.ripgrep
      ]
      ++ cfg.packages.home
      ++ cfg.packages.system
    )
  );

  emacsStateDir = "${config.xdg.stateHome}/emacs";
  orgDir = "${config.xdg.dataHome}/org";
  emacsEnvironment = {
    DOTFILES_EMACS_FIXED_PITCH_FAMILY = appearance.fixedPitchFamily;
    DOTFILES_EMACS_FIXED_PITCH_HEIGHT = builtins.toString appearance.fixedPitchHeight;
    DOTFILES_EMACS_VARIABLE_PITCH_FAMILY =
      if appearance.variablePitchFamily == null then "" else appearance.variablePitchFamily;
    DOTFILES_EMACS_VARIABLE_PITCH_HEIGHT = builtins.toString appearance.variablePitchHeight;
    DOTFILES_EMACS_THEME_NAME = if appearance.themeName == null then "" else appearance.themeName;
    DOTFILES_EMACS_LINE_SPACING = builtins.toString appearance.lineSpacing;
    DOTFILES_EMACS_STARTUP_STYLE = appearance.startupStyle;
  };
in
{
  config = lib.mkIf (cfg.apps.editor == "emacs") {
    assertions = lib.optional (appearance.themePackage != null) {
      assertion = resolvedThemePackage != null;
      message = "dotfiles.emacs.appearance.themePackage must name an Emacs package in pkgs.emacsPackages.";
    };

    home.packages = [
      emacsPackage
      pkgs.nil
      pkgs.nixfmt-rfc-style
    ];

    home.sessionVariables = emacsEnvironment;

    xdg.configFile."emacs" = {
      source = emacsHome;
      recursive = true;
    };

    home.activation.ensureEmacsDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      /bin/mkdir -p "${emacsStateDir}" "${orgDir}"
    '';

    home.activation.pruneLegacyEmacsModules = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      /bin/rm -f \
        "${config.xdg.configHome}/emacs/lisp/dotfiles-ui.el" \
        "${config.xdg.configHome}/emacs/modules/ui.org"
    '';

    launchd.enable = true;
    launchd.agents.emacs = {
      enable = true;
      config = {
        Label = "org.gnu.emacs";
        EnvironmentVariables = {
          HOME = config.home.homeDirectory;
          PATH = emacsPath;
          XDG_CONFIG_HOME = config.xdg.configHome;
          XDG_DATA_HOME = config.xdg.dataHome;
          XDG_STATE_HOME = config.xdg.stateHome;
        }
        // emacsEnvironment;
        KeepAlive = true;
        ProgramArguments = [
          "${emacsPackage}/bin/emacs"
          "--fg-daemon"
        ];
        RunAtLoad = true;
        StandardErrorPath = "${emacsStateDir}/daemon.stderr.log";
        StandardOutPath = "${emacsStateDir}/daemon.stdout.log";
        WorkingDirectory = config.home.homeDirectory;
      };
    };
  };
}
