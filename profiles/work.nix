{ config, lib, ... }:
let
  cfg = config.dotfiles;
in
{
  config = lib.mkIf (lib.elem "work" cfg.profiles) {
    # Work-specific policy stays intentionally small. Add managed apps or
    # package overlays here once you have a concrete work host to model.
  };
}

