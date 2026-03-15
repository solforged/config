{ osConfig, lib, ... }:
let
  cfg = osConfig.platform;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
  use1Password = cfg.apps.passwordManager == "1password";
in
{
  home.file.".ssh/config" = {
    text = lib.concatStringsSep "\n" (
      [
        "Include ${cfg.local.sshConfig}"
      ]
      ++ lib.optionals (use1Password && isDarwin) [
        ""
        "Host *"
        "  IdentityAgent \"${cfg.apps.passwordManagerSshAgentSocket}\""
      ]
    );
  };
}
