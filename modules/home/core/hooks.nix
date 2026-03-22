{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.platform;
  hooks = cfg.hooks;
  hasPostDeploy = hooks.postDeploy != [ ];
  postDeployScript = pkgs.writeShellScript "rig-hook-post-deploy" (
    lib.concatStringsSep "\n" (
      [
        "set -eu"
      ]
      ++ hooks.postDeploy
    )
  );
in
{
  config = lib.mkIf hasPostDeploy {
    home.file.".local/share/rig/hooks/post-deploy" = {
      source = postDeployScript;
      executable = true;
    };
  };
}
