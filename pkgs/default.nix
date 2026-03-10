{ pkgs }:
{
  musicctl = pkgs.callPackage ../config/openclaw/plugins/music/package.nix { };
}
