{
  platform = {
    profiles = {
      base.enable = true;
      desktop.enable = true;
      development.enable = true;
      media.enable = true;
      personal.enable = true;
    };

    apps = {
      shell = "zsh";
      editor = "helix";
      enabledEditors = [ "helix" ];
      terminal = "ghostty";
      browser = "brave";
      passwordManager = "1password";
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
