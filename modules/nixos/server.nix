{
  config,
  lib,
  ...
}:
let
  cfg = config.platform;
  isLinux = lib.hasSuffix "linux" cfg.host.platform;
in
{
  config = lib.mkIf (isLinux && cfg.profiles.server.enable) {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    networking.firewall.allowedTCPPorts = [ 22 ];

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    time.timeZone = lib.mkDefault "UTC";
    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  };
}
