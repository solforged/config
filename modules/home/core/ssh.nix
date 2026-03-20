{ osConfig, lib, ... }:
let
  cfg = osConfig.platform;
in
{
  home.file.".ssh/config" = {
    text = lib.concatStringsSep "\n" [
      "Include ${cfg.local.sshConfig}"
      ""
      "Host *"
      "  AddKeysToAgent yes"
      "  UseKeychain yes"
      "  IdentityFile ~/.ssh/id_ed25519"
    ];
  };
}
