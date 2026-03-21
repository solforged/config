{ config, pkgs, ... }:
let
  cfg = config.platform;
  secretsDir = cfg.secrets.stateDir;
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
      "ssh/id_ed25519" = {
        path = "${cfg.user.home}/.ssh/id_ed25519";
        owner = cfg.user.name;
        mode = "0600";
      };
      "ssh/id_ed25519_pub" = {
        path = "${cfg.user.home}/.ssh/id_ed25519.pub";
        owner = cfg.user.name;
        mode = "0644";
      };
    };
  };
}
