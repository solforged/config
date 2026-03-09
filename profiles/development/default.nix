{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption;
  cfg = config.dotfiles;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
in
{
  options.dotfiles.profiles.development.enable = mkEnableOption "development tooling profile";

  config = lib.mkIf cfg.profiles.development.enable {
    dotfiles.ai.enable = true;

    dotfiles.packages.home = with pkgs; [
      codex
      cargo
      clippy
      delve
      gemini-cli
      gh
      go
      gopls
      memo
      nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.prettier
      pnpm
      resvg
      rust-analyzer
      rustc
      rustfmt
    ];

    dotfiles.homebrew.casks = lib.optionals isDarwin [
      "codex-app"
    ];
  };
}
