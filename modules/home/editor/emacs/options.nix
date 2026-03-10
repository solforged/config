{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.dotfiles.emacs.appearance = {
    fixedPitchFamily = mkOption {
      type = types.str;
      default = "Monospace";
      example = "JetBrainsMono Nerd Font";
      description = "Primary fixed-pitch font family for Emacs.";
    };

    fixedPitchHeight = mkOption {
      type = types.int;
      default = 110;
      example = 110;
      description = "Default Emacs fixed-pitch face height.";
    };

    variablePitchFamily = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "SF Pro Text";
      description = "Optional variable-pitch font family for prose-facing buffers.";
    };

    variablePitchHeight = mkOption {
      type = types.float;
      default = 1.05;
      example = 1.05;
      description = "Relative Emacs variable-pitch face height.";
    };

    themeName = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "doom-tokyo-night";
      description = "Theme symbol name to load inside Emacs.";
    };

    themePackage = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "doom-themes";
      description = "Optional package name from the Emacs package set that provides `themeName`.";
    };

    lineSpacing = mkOption {
      type = types.float;
      default = 0.12;
      example = 0.12;
      description = "Default Emacs line spacing for reading-oriented buffers.";
    };

    startupStyle = mkOption {
      type = types.enum [
        "minimal-dashboard"
        "blank"
        "none"
      ];
      default = "minimal-dashboard";
      description = "Startup surface style for Emacs.";
    };
  };
}
