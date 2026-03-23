{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
  inherit (self.lib) mkBoolOpt mkOpt;
in
{
  options.platform.notes = {
    enable = mkEnableOption "structured conversation capture into a markdown notebook";

    vaultPath =
      mkOpt (types.nullOr types.str) "${config.platform.user.home}/Documents/notes"
        "Root directory for the markdown notebook or Obsidian vault.";

    inboxDir =
      mkOpt types.str "Inbox"
        "Subdirectory inside the vault used for captured conversation notes.";

    styleGuidePath =
      mkOpt (types.nullOr types.str) null
        "Optional path to an additional style guide file consumed by humans or OpenClaw prompts.";

    privateStyleGuidePath =
      mkOpt (types.nullOr types.str) null
        "Optional machine-local style guide file kept outside the repository.";

    defaultTags = mkOption {
      type = types.listOf types.str;
      default = [
        "conversation"
      ];
      description = "Default frontmatter tags applied to captured conversation notes.";
    };

    obsidian = {
      enable = mkBoolOpt false "Treat the configured notebook as an Obsidian vault and expose open helpers.";
      openWithApp = mkBoolOpt true "Open captured notes with the platform default opener when requested.";
    };

    zk = {
      enable = mkBoolOpt false "Install zk and expose the configured notebook through zk.";
    };

    taskwarrior = {
      enable = mkBoolOpt false "Install Taskwarrior and mirror captured tasks into it.";
      package = mkOption {
        type = types.package;
        default = pkgs.taskwarrior3;
        defaultText = lib.literalExpression "pkgs.taskwarrior3";
        description = "Taskwarrior package used for task synchronization.";
      };
      dataDir =
        mkOpt (types.nullOr types.str) "${config.platform.user.home}/.local/share/task"
          "Taskwarrior data directory exported to notesctl when task sync is enabled.";
      project =
        mkOpt (types.nullOr types.str) "notes"
          "Default Taskwarrior project applied to imported tasks.";
      tags = mkOption {
        type = types.listOf types.str;
        default = [
          "conversation"
        ];
        description = "Default Taskwarrior tags applied to imported tasks.";
      };
    };

    openclaw.enable = mkBoolOpt false "Expose the note capture workflow through the local OpenClaw instance.";
  };
}
