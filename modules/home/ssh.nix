{ osConfig, ... }:
let
  cfg = osConfig.dotfiles;
in
{
  home.file.".ssh/config" = {
    text = ''
      Include ${cfg.secrets.stateDir}/ssh/config
      Include ${cfg.local.sshConfig}
    '';
  };
}
