{ pkgs }:
{
  musicctl = pkgs.callPackage ../modules/home/media/music/openclaw-plugin/package.nix { };
  notesctl = pkgs.callPackage ../modules/home/notes/package.nix { };
}
