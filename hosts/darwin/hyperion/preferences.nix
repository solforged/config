{
  platform = {
    profiles = {
      base.enable = true;
      desktop.enable = true;
      development.enable = true;
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
      browser = "chrome";
      notes = "obsidian";
      passwordManager = "1password";
    };

    features = {
      homebrew.enable = true;
      dock.enable = true;
      dock.items = [
        "Apps"
        "Google Chrome"
        "Ghostty"
        "Signal"
        "1Password"
        "App Store"
        "Obsidian"
        "Claude"
        "System Settings"
      ];
      touchIdSudo.enable = true;
      capsToEscape.enable = true;
    };
  };
}
