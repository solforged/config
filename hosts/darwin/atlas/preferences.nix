{
  platform = {
    profiles = {
      base.enable = true;
      desktop.enable = true;
      development.enable = true;
      work.enable = true;
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
      dock.enable = false;
      touchIdSudo.enable = true;
      capsToCtrl.enable = false;
    };
  };
}
