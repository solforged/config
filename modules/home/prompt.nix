{ lib, osConfig, ... }:
let
  cfg = osConfig.dotfiles;
in
{
  programs.starship = {
    enable = true;
    enableFishIntegration = cfg.apps.shell == "fish";
    enableNushellIntegration = cfg.apps.shell == "nushell";
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      command_timeout = 1200;

      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$nodejs"
        "$python"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      right_format = "$nix_shell";

      character = {
        success_symbol = "[λ](bold white)";
        error_symbol = "[λ](bold red)";
        vimcmd_symbol = "[λ](bold white)";
      };

      cmd_duration = {
        min_time = 2000;
        format = "took [$duration]($style) ";
        style = "bold yellow";
      };

      directory = {
        format = "[$path]($style) ";
        style = "bold green";
        home_symbol = "~";
        truncation_length = 3;
        truncate_to_repo = false;
      };

      git_branch = {
        symbol = "[](bold magenta) ";
        format = "on $symbol[$branch]($style) ";
        style = "bold magenta";
      };

      git_status = {
        ahead = ">";
        behind = "<";
        diverged = "<>";
        deleted = "x";
        format = "([$all_status$ahead_behind]($style) )";
        modified = "!";
        renamed = "r";
        staged = "+";
        style = "bold red";
        untracked = "?";
      };

      nodejs = {
        detect_extensions = [
          "js"
          "mjs"
          "cjs"
          "ts"
          "mts"
          "cts"
          "json"
        ];
        format = "via $symbol[$version]($style) ";
        style = "bold green";
        symbol = "[](bold green) ";
      };

      python = {
        format = "via $symbol[$version]($style) ";
        style = "bold yellow";
        symbol = "[](bold green) ";
      };

      nix_shell = {
        format = "[$name]($style) ";
        impure_msg = "";
        pure_msg = "";
      };
    };
  };
}
