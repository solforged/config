{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.dotfiles;
  claudeConfigDir = "${config.xdg.dataHome}/claude";
  claudeLegacyDir = "${config.home.homeDirectory}/.claude";
  claudeSettingsPath = "${claudeConfigDir}/settings.json";
  geminiHomeDir = "${config.xdg.dataHome}/gemini";
  geminiLegacyDir = "${config.home.homeDirectory}/.gemini";
in
{
  config = lib.mkIf (lib.elem "development" cfg.profiles) {
    home.sessionVariables = {
      CLAUDE_CONFIG_DIR = claudeConfigDir;
    };

    home.activation.prepareAiCliHomes = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      if [ -e "${claudeLegacyDir}" ] && [ ! -L "${claudeLegacyDir}" ]; then
        timestamp="$(${lib.getExe' pkgs.coreutils "date"} +%Y%m%d-%H%M%S)"
        backupPath="${claudeLegacyDir}.runtime-$timestamp"
        suffix=0

        while [ -e "$backupPath" ]; do
          suffix=$((suffix + 1))
          backupPath="${claudeLegacyDir}.runtime-$timestamp.$suffix"
        done

        run /bin/mv "${claudeLegacyDir}" "$backupPath"
      fi

      if [ -e "${geminiLegacyDir}" ] && [ ! -L "${geminiLegacyDir}" ]; then
        timestamp="$(${lib.getExe' pkgs.coreutils "date"} +%Y%m%d-%H%M%S)"
        backupPath="${geminiLegacyDir}.runtime-$timestamp"
        suffix=0

        while [ -e "$backupPath" ]; do
          suffix=$((suffix + 1))
          backupPath="${geminiLegacyDir}.runtime-$timestamp.$suffix"
        done

        run /bin/mv "${geminiLegacyDir}" "$backupPath"
      fi
    '';

    home.activation.ensureAiCliHomes = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            /bin/mkdir -p "${claudeConfigDir}" "${geminiHomeDir}"
            /bin/chmod 700 "${claudeConfigDir}" "${geminiHomeDir}"

            if [ -L "${claudeLegacyDir}" ]; then
              /bin/rm -f "${claudeLegacyDir}"
            fi

            if [ -L "${geminiLegacyDir}" ]; then
              /bin/rm -f "${geminiLegacyDir}"
            fi

            /bin/ln -s "${claudeConfigDir}" "${claudeLegacyDir}"
            /bin/ln -s "${geminiHomeDir}" "${geminiLegacyDir}"

            if [ ! -e "${claudeSettingsPath}" ]; then
              /bin/cat > "${claudeSettingsPath}" <<'EOF'
      {
        "$schema": "https://json.schemastore.org/claude-code-settings.json",
        "forceLoginMethod": "claudeai"
      }
      EOF
              /bin/chmod 600 "${claudeSettingsPath}"
            fi
    '';
  };
}
