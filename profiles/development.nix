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
