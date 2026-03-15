{ config, pkgs, ... }:
let
  cfg = config.platform;
  secretsDir = "${cfg.user.home}/.local/state/platform/secrets";
in
{
  environment.systemPackages = [
    pkgs.age
    pkgs.sops
  ];

  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    age = {
      keyFile = "${cfg.user.home}/.config/sops/age/keys.txt";
      sshKeyPaths = [ ];
    };
    gnupg.sshKeyPaths = [ ];

    secrets = {
      "git/config" = {
        path = "${secretsDir}/git/config";
        owner = cfg.user.name;
        mode = "0600";
      };
      "git/allowed_signers" = {
        path = "${secretsDir}/git/allowed_signers";
        owner = cfg.user.name;
        mode = "0600";
      };
    };
  };
}
