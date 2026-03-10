{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.dotfiles;

  emacsPackages = pkgs.emacsPackagesFor pkgs.emacs;
  emacsPackage = emacsPackages.emacsWithPackages (
    epkgs: with epkgs; [
      consult
      dashboard
      doom-themes
      embark
      embark-consult
      evil
      evil-collection
      general
      magit
      marginalia
      mixed-pitch
      mood-line
      nerd-icons
      nix-mode
      orderless
      org-modern
      spacious-padding
      tempel
      undo-fu
      vertico
      which-key
    ]
  );

  emacsHome =
    pkgs.runCommandLocal "emacs-home"
      {
        nativeBuildInputs = [ pkgs.emacs ];
        earlyInitOrg = ../../config/emacs/early-init.org;
        initOrg = ../../config/emacs/init.org;
        modulesDir = ../../config/emacs/modules;
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
in
{
  config = lib.mkIf (cfg.apps.editor == "emacs") {
    home.packages = [
      emacsPackage
      pkgs.nil
      pkgs.nixfmt-rfc-style
    ];

    xdg.configFile."emacs" = {
      source = emacsHome;
      recursive = true;
    };

    home.activation.ensureEmacsDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      /bin/mkdir -p "${emacsStateDir}" "${orgDir}"
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
        };
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
