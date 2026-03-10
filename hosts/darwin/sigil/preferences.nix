{
  dotfiles = {
    profiles = {
      base.enable = true;
      desktop.enable = true;
      development.enable = true;
      media.enable = true;
      personal.enable = true;
    };

    apps = {
      shell = "zsh";
      editor = "emacs";
      terminal = "ghostty";
      browser = "brave";
      passwordManager = "proton-pass";
    };

    emacs.appearance = {
      fixedPitchFamily = "BlexMono Nerd Font";
      fixedPitchHeight = 125;
      variablePitchFamily = "IBM Plex Sans";
      variablePitchHeight = 1.08;
      themeName = "modus-vivendi-tinted";
      themePackage = null;
      lineSpacing = 0.16;
      startupStyle = "minimal-dashboard";
    };

    features = {
      homebrew.enable = true;
      dock.enable = true;
      touchIdSudo.enable = true;
      capsToCtrl.enable = true;
    };

    openclaw = {
      tailscaleMagicDnsName = "sigil.ussuri-alphard.ts.net";
      telegramOwnerId = 7703164198;
    };

    music = {
      enable = true;
      beets.enable = true;
      roon.enable = true;
      openclaw.enable = true;
    };

    ai.openclawRemoteUrl = "https://sigil.ussuri-alphard.ts.net";
  };
}
