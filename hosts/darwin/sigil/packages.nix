{ pkgs, ... }:
{
  dotfiles = {
    packages.home = [
      pkgs.neovim
    ];

    packages.system = [
      pkgs.tailscale
    ];

    homebrew.casks = [
      "font-blex-mono-nerd-font"
      "font-ibm-plex-sans"
      "tailscale-app"
    ];

    homebrew.masApps = {
      # "AdGuard Mini" = 1555374974;
      # Amphetamine = 937984704;
      # "Dark Reader for Safari" = 1438243180;
      # Surfingkeys = 1498893305;
    };
  };
}
