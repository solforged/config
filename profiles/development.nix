{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
in
{
  config = lib.mkIf (lib.elem "development" cfg.profiles) {
    dotfiles.packages.home = with pkgs; [
      claude-code
      codex
      gemini-cli
    ];

    dotfiles.homebrew.casks = lib.optionals isDarwin [
      "codex-app"
    ];
  };
}
