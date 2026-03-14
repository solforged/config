{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.platform;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
  formatPmsetValue =
    value: if builtins.isBool value then if value then "1" else "0" else toString value;
  pmsetArgs = lib.concatStringsSep " " (
    lib.mapAttrsToList (
      name: value: "${lib.escapeShellArg name} ${lib.escapeShellArg (formatPmsetValue value)}"
    ) cfg.power.settings
  );
in
{
  options.platform = {
    features.touchIdSudo.enable = mkEnableOption "enable Touch ID for sudo";
    features.capsToCtrl.enable = mkEnableOption "map Caps Lock to Control";

    power.settings = mkOption {
      type = types.attrsOf (
        types.oneOf [
          types.bool
          types.int
        ]
      );
      default = { };
      example = {
        displaysleep = 10;
        disksleep = 0;
        sleep = 0;
        tcpkeepalive = true;
        womp = true;
      };
      description = "Darwin power-management settings applied via pmset -a during activation.";
    };
  };

  config = lib.mkIf isDarwin {
    system.activationScripts.postActivation.text = lib.mkAfter ''
      ${lib.optionalString (cfg.power.settings != { }) ''
        /usr/bin/pmset -a ${pmsetArgs}
      ''}

      ${lib.optionalString cfg.features.touchIdSudo.enable ''
          pam_sudo_file="/etc/pam.d/sudo"
          pam_touch_id_line="auth       sufficient     pam_tid.so"

          if ! /usr/bin/grep -Fqx "$pam_touch_id_line" "$pam_sudo_file"; then
            /usr/bin/sed -i.bak "1s|^|$pam_touch_id_line\\
        |" "$pam_sudo_file"
          fi
      ''}

      ${lib.optionalString cfg.features.capsToCtrl.enable ''
        /usr/bin/hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000e0}]}' >/dev/null 2>&1 || true
      ''}
    '';
  };
}
