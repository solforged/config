# Work profile toggle.
#
# This profile is intentionally empty. Work-specific packages, casks, and
# module config live in a separate work flake that layers on top of this
# repo's base configuration. The toggle is still useful:
#
#   - Emacs host-facts exposes `platform-profile-work-p` for elisp branching
#   - Modules can use `config.platform.profiles.work.enable` to gate behavior
#     that only makes sense on a work machine
#
# If you need work-only nix-darwin or Home Manager config that doesn't belong
# in the work flake, add it here behind `lib.mkIf cfg.enable`.
{ lib, ... }:
{
  options.platform.profiles.work.enable = lib.mkEnableOption "work profile";
}
