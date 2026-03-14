{ osConfig, lib, ... }:
let
  cfg = osConfig.platform;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
  use1Password = cfg.apps.passwordManager == "1password";
  opAgentSock = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
in
{
  home.file.".ssh/config" = {
    text = lib.concatStringsSep "\n" (
      lib.optional (use1Password && isDarwin) "IdentityAgent \"${opAgentSock}\""
      ++ [
        "Include ${cfg.secrets.stateDir}/ssh/config"
        "Include ${cfg.local.sshConfig}"
      ]
    );
  };
}
