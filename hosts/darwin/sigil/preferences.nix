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
      browser = "chatgpt-atlas";
      passwordManager = "1password";
    };

    features = {
      homebrew.enable = true;
      dock.enable = true;
      touchIdSudo.enable = true;
      capsToEscape.enable = true;
    };

    music = {
      enable = true;
      beets.enable = true;
      roon.enable = true;
      openclaw.enable = true;
    };

    ai.openclawRemoteHostnameOpRef = "op://Private/OpenClaw Gateway Token/hostname";
  };
}
