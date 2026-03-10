{ osConfig, ... }:
let
  cfg = osConfig.dotfiles;
in
{
  programs.git = {
    enable = true;
    includes = [
      {
        path = "${cfg.secrets.stateDir}/git/config.inc";
      }
      {
        path = cfg.local.gitInclude;
      }
    ];
    ignores = [ ];
    settings = {
      gpg.ssh.allowedSignersFile = "${cfg.secrets.stateDir}/git/allowed_signers";
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
    }
    // (
      if cfg.user.fullName != null || cfg.user.email != null then
        {
          user =
            { }
            // (if cfg.user.fullName != null then { name = cfg.user.fullName; } else { })
            // (if cfg.user.email != null then { email = cfg.user.email; } else { });
        }
      else
        { }
    );
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  xdg.configFile."git/ignore".source = ../../../config/git/ignore;
}
