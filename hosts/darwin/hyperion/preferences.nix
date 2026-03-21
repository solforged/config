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
      browser = "brave";
      passwordManager = "1password";
    };

    features = {
      homebrew.enable = true;
      dock.enable = true;
      dock.items = [
        "Apps"
        "Brave Browser"
        "Ghostty"
        "Signal"
        "1Password"
        "App Store"
        "Claude"
        "System Settings"
      ];
      touchIdSudo.enable = true;
      capsToEscape.enable = true;
    };
  };
}
