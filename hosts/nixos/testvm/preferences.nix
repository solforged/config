{
  platform = {
    profiles = {
      base.enable = true;
      server.enable = true;
    };

    apps = {
      shell = "zsh";
      editor = "helix";
      enabledEditors = [ "helix" ];
    };
  };
}
