{ pkgs }:
{
  musicctl = pkgs.callPackage ../modules/home/media/music/openclaw-plugin/package.nix { };
}
