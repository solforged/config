{
  config,
  lib,
  osConfig,
  ...
}:
let
  cfg = osConfig.dotfiles;
  secretConfig = "${config.xdg.stateHome}/dotfiles/secrets/nushell/local.nu";
  secretEnv = "${config.xdg.stateHome}/dotfiles/secrets/nushell/env.nu";
  localConfig = "${config.xdg.configHome}/nushell/local.nu";
  localEnv = "${config.xdg.configHome}/nushell/env.local.nu";
in
{
  config = lib.mkIf (cfg.apps.shell == "nushell") {
    programs.nushell = {
      enable = true;
      extraConfig = ''
        if ("${secretConfig}" | path exists) {
          source "${secretConfig}"
        }

        if ("${localConfig}" | path exists) {
          source "${localConfig}"
        }
      '';
      extraEnv = ''
        if ("${secretEnv}" | path exists) {
          source "${secretEnv}"
        }

        if ("${localEnv}" | path exists) {
          source "${localEnv}"
        }
      '';
    };
  };
}
