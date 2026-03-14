{
  config,
  lib,
  osConfig,
  ...
}:
let
  cfg = osConfig.platform;
  secretFish = "${config.xdg.stateHome}/platform/secrets/fish/local.fish";
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
