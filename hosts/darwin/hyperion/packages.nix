{ pkgs, ... }:
{
  platform = {
    packages.home = [ ];

    packages.system = [
      # pkgs.tailscale
    ];

    homebrew.casks = [
      "iina"
      "qbittorrent"
      "signal"
    ];

    homebrew.masApps = {
      # "AdGuard Mini" = 1555374974;
      # Amphetamine = 937984704;
      # "Dark Reader for Safari" = 1438243180;
      # Surfingkeys = 1498893305;
    };
  };
}
