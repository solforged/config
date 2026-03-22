{
  lib,
  osConfig,
  ...
}:
let
  cfg = osConfig.platform;
in
{
  config = lib.mkIf (builtins.elem "nvim" cfg.apps.enabledEditors) {
    programs.nixvim = {
      enable = true;
      defaultEditor = cfg.apps.editor == "nvim";
      viAlias = true;
      vimAlias = true;
      colorschemes.${cfg.theme.schemes.nvim}.enable = true;
      imports = [
        ./nvim/core.nix
        ./nvim/navigation.nix
        ./nvim/files-projects.nix
        ./nvim/git-diagnostics.nix
        ./nvim/lsp-formatting.nix
        ./nvim/terminal-session.nix
      ];
    };
  };
}
