{
  config,
  lib,
  options,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
  cfg = osConfig.dotfiles.music;
  musicctlConfigPath = "${config.xdg.configHome}/musicctl/config.json";
  musicctlLocalConfigPath = "${config.xdg.configHome}/musicctl/local.json";
  musicctlStateDir = "${config.xdg.stateHome}/musicctl";
  hasOpenclawModule = lib.hasAttrByPath [ "programs" "openclaw" "skills" ] options;
  openclawSkillSource = ./openclaw-plugin/skills/music;
  musicctlConfig = {
    beets = {
      enable = cfg.beets.enable;
      command = "beet";
      configPath = "${config.xdg.configHome}/beets/config.yaml";
    };
    roon = {
      enable = cfg.roon.enable;
      command = "roon-tui";
      configDir = "${config.xdg.configHome}/roon-tui";
    };
    openclaw = {
      enable = cfg.openclaw.enable;
    };
    paths = {
      localConfigPath = musicctlLocalConfigPath;
      stateDir = musicctlStateDir;
    };
  };
in
{
  config = lib.mkIf cfg.enable (
    {
      assertions = [
        {
          assertion = !cfg.openclaw.enable || hasOpenclawModule;
          message = "dotfiles.music.openclaw.enable requires the nix-openclaw Home Manager module.";
        }
      ];

      home.packages = [
        pkgs.musicctl
      ]
      ++ lib.optionals cfg.beets.enable [ pkgs.beets ]
      ++ lib.optionals cfg.roon.enable [ pkgs.roon-tui ];

      home.sessionVariables = {
        MUSICCTL_CONFIG_PATH = musicctlConfigPath;
        MUSICCTL_LOCAL_CONFIG_PATH = musicctlLocalConfigPath;
        MUSICCTL_STATE_DIR = musicctlStateDir;
      };

      xdg.configFile."musicctl/config.json".text = builtins.toJSON musicctlConfig;

      home.activation.ensureMusicctlStateDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        /bin/mkdir -p "${musicctlStateDir}"
      '';
    }
    // lib.optionalAttrs hasOpenclawModule {
      programs.openclaw.skills = lib.optionals cfg.openclaw.enable [
        {
          name = "music";
          mode = "copy";
          source = builtins.toString openclawSkillSource;
        }
      ];
    }
  );
}
