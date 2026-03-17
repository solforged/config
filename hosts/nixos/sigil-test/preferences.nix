{
  platform = {
    profiles = {
      base.enable = true;
      server.enable = true;
      development.enable = true;
    };

    apps = {
      shell = "zsh";
      editor = "helix";
      enabledEditors = [ "helix" ];
    };
  };
}
