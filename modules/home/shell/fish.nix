{
  config,
  lib,
  osConfig,
  ...
}:
let
  cfg = osConfig.platform;
  secretFish = "${cfg.secrets.stateDir}/fish/local.fish";
  localFish = "${config.xdg.configHome}/fish/local.fish";
in
{
  config = lib.mkIf (cfg.apps.shell == "fish") {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        if test -f "${secretFish}"
          source "${secretFish}"
        end

        if test -f "${localFish}"
          source "${localFish}"
        end
      '';
    };
  };
}
