{ osConfig, ... }:
let
  cfg = osConfig.platform;
in
{
  home.file.".ssh/config" = {
    text = ''
      Include ${cfg.secrets.stateDir}/ssh/config
      Include ${cfg.local.sshConfig}
    '';
  };
}
