{
  system = "aarch64-darwin";

  module =
    { ... }:
    {
      dotfiles = {
        user = {
          name = "admin";
          home = "/Users/admin";
        };

        host = {
          slug = "atlas";
          title = "atlas";
          platform = "aarch64-darwin";
          stateVersion = 6;
          homeStateVersion = "25.11";
        };

        profiles = [
          "base"
          "desktop"
          "development"
          "work"
        ];

        apps = {
          shell = "zsh";
          editor = "nvim";
          terminal = "ghostty";
          browser = "brave";
          passwordManager = "proton-pass";
        };

        features = {
          homebrew.enable = true;
          dock.enable = false;
          touchIdSudo.enable = true;
          capsToCtrl.enable = false;
        };
      };
    };
}
