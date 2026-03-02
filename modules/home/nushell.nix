{ ... }:
{
  config = {
    xdg.configFile."nushell/config.nu".source = ../../config/nushell/config.nu;
    xdg.configFile."nushell/env.nu".source = ../../config/nushell/env.nu;
  };
}
