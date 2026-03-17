{
  platform = {
    profiles = {
      base.enable = true;
      desktop.enable = true;
      development.enable = true;
      personal.enable = true;
      work.enable = false;
    };

    apps = {
      shell = "zsh";
      editor = "helix";
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
        "1Password"
        "App Store"
        "Claude"
        "System Settings"
      ];
      touchIdSudo.enable = true;
      capsToCtrl.enable = false;
      capsToEscape.enable = true;
    };
  };
}
