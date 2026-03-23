{ config, ... }:
let
  cfg = config.platform;
in
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
      editor = "nvim";
      enabledEditors = [
        "nvim"
        "helix"
      ];
      terminal = "ghostty";
      browser = "chatgpt-atlas";
      notes = "obsidian";
      passwordManager = "1password";
    };

    features = {
      homebrew.enable = true;
      dock.enable = true;
      dock.items = [
        "Apps"
        "ChatGPT Atlas"
        "Ghostty"
        "1Password"
        "App Store"
        "Claude"
        "System Settings"
      ];
      touchIdSudo.enable = true;
      capsToEscape.enable = true;
    };

    music = {
      enable = true;
      beets.enable = true;
      roon.enable = true;
      openclaw.enable = true;
    };

    notes = {
      enable = true;
      vaultPath = "${cfg.user.home}/dev/personal/vault";
      obsidian.enable = true;
      zk.enable = true;
      taskwarrior.enable = true;
      openclaw.enable = true;
      privateStyleGuidePath = "${cfg.user.home}/.config/notes/style-guide.local.md";
    };

    ai.lumen.apiKeyFile = "${cfg.secrets.stateDir}/groq/api_key";
    ai.openclawRemoteHostnameFile = "${cfg.secrets.stateDir}/openclaw/gateway_hostname";
  };
}
