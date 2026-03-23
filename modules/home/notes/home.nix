{
  config,
  lib,
  options,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.platform.notes;
  hasOpenclawModule = lib.hasAttrByPath [ "programs" "openclaw" "skills" ] options;
  notesctlConfigPath = "${config.xdg.configHome}/notesctl/config.json";
  notesctlLocalConfigPath = "${config.xdg.configHome}/notesctl/local.json";
  notesctlStateDir = "${config.xdg.stateHome}/notesctl";
  openclawSkillSource = ./openclaw-plugin/skills/notes;
  vaultPath = cfg.vaultPath;
  inboxPath = if vaultPath == null then null else "${vaultPath}/${cfg.inboxDir}";
  notesctlConfig = {
    vaultPath = cfg.vaultPath;
    inboxDir = cfg.inboxDir;
    styleGuidePath =
      if cfg.styleGuidePath != null then
        cfg.styleGuidePath
      else
        "${config.xdg.configHome}/notesctl/style-guide.md";
    privateStyleGuidePath = cfg.privateStyleGuidePath;
    defaultTags = cfg.defaultTags;
    obsidian = {
      enable = cfg.obsidian.enable;
      openWithApp = cfg.obsidian.openWithApp;
    };
    zk = {
      enable = cfg.zk.enable;
      notebookDir = cfg.vaultPath;
    };
    taskwarrior = {
      enable = cfg.taskwarrior.enable;
      dataDir = cfg.taskwarrior.dataDir;
      project = cfg.taskwarrior.project;
      tags = cfg.taskwarrior.tags;
    };
    paths = {
      configPath = notesctlConfigPath;
      localConfigPath = notesctlLocalConfigPath;
      stateDir = notesctlStateDir;
    };
  };
  zkConfig = lib.concatStringsSep "\n" (
    [
      "[notebook]"
      "dir = \"${cfg.vaultPath}\""
      ""
      "[format.markdown]"
      "hashtags = true"
      "colon-tags = false"
      ""
      "[tool]"
      "editor = \"${osConfig.platform.apps.editor}\""
      "shell = \"/bin/sh\""
      ""
      "[alias]"
      "recent = 'zk edit --sort modified- --limit 10 \"$@\"'"
      "inbox = 'zk list --path \"${cfg.inboxDir}\" \"$@\"'"
    ]
    ++ lib.optionals (osConfig.platform.user.fullName != null) [
      ""
      "[extra]"
      "author = \"${osConfig.platform.user.fullName}\""
    ]
  );
in
{
  config = lib.mkIf cfg.enable (
    {
      assertions = [
        {
          assertion = !cfg.openclaw.enable || hasOpenclawModule;
          message = "platform.notes.openclaw.enable requires the nix-openclaw Home Manager module.";
        }
        {
          assertion = !(cfg.obsidian.enable || cfg.zk.enable) || cfg.vaultPath != null;
          message = "platform.notes.vaultPath must be set when Obsidian or zk integration is enabled.";
        }
      ];

      home.packages = [
        pkgs.notesctl
      ]
      ++ lib.optionals cfg.zk.enable [ pkgs.zk ]
      ++ lib.optionals cfg.taskwarrior.enable [ cfg.taskwarrior.package ];

      home.sessionVariables = {
        NOTESCTL_CONFIG_PATH = notesctlConfigPath;
        NOTESCTL_LOCAL_CONFIG_PATH = notesctlLocalConfigPath;
        NOTESCTL_STATE_DIR = notesctlStateDir;
      }
      // lib.optionalAttrs (cfg.zk.enable && cfg.vaultPath != null) {
        ZK_NOTEBOOK_DIR = cfg.vaultPath;
      };

      xdg.configFile."notesctl/config.json".text = builtins.toJSON notesctlConfig;
      xdg.configFile."notesctl/style-guide.md".source = ../../../config/notes/style-guide.md;
      xdg.configFile."notesctl/templates/conversation.md".source =
        ../../../config/notes/templates/conversation.md;
      xdg.configFile."notesctl/payload.example.json".source = ../../../config/notes/payload.example.json;

      xdg.configFile."zk/config.toml" = lib.mkIf cfg.zk.enable {
        text = zkConfig;
      };

      xdg.configFile."zk/templates/conversation.md" = lib.mkIf cfg.zk.enable {
        source = ../../../config/notes/templates/conversation.md;
      };

      programs.zsh.shellAliases = {
        nc = "notesctl capture";
        nd = "notesctl capture --dry-run";
        nr = "notesctl render";
      }
      // lib.optionalAttrs (vaultPath != null) {
        nv = "cd ${vaultPath}";
      }
      // lib.optionalAttrs (inboxPath != null) {
        ni = "cd ${inboxPath}";
      };

      programs.nushell.shellAliases = {
        nc = "notesctl capture";
        nd = "notesctl capture --dry-run";
        nr = "notesctl render";
      }
      // lib.optionalAttrs (vaultPath != null) {
        nv = "cd ${vaultPath}";
      }
      // lib.optionalAttrs (inboxPath != null) {
        ni = "cd ${inboxPath}";
      };

      home.activation.ensureNotesctlDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] (
        ''
          /bin/mkdir -p "${notesctlStateDir}"
        ''
        + lib.optionalString (cfg.taskwarrior.enable && cfg.taskwarrior.dataDir != null) ''
          /bin/mkdir -p "${cfg.taskwarrior.dataDir}"
        ''
        + lib.optionalString (inboxPath != null) ''
          /bin/mkdir -p "${inboxPath}"
        ''
      );
    }
    // lib.optionalAttrs hasOpenclawModule {
      programs.openclaw.skills = lib.optionals cfg.openclaw.enable [
        {
          name = "notes";
          mode = "copy";
          source = builtins.toString openclawSkillSource;
        }
      ];
    }
  );
}
