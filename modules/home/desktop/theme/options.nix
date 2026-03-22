{
  lib,
  self,
  ...
}:
let
  inherit (self.lib) mkOpt mkBoolOpt;
  inherit (lib) types;
  hexColor = types.strMatching "#[0-9a-fA-F]{6}";
in
{
  options.platform.theme = {
    preferDark = mkBoolOpt true "Whether to prefer dark mode across supported tools.";

    fonts.mono = {
      family = mkOpt types.str "JetBrains Mono" "Monospace font family for terminals and editors.";
      size = mkOpt types.int 12 "Base font size in points.";
    };

    schemes = {
      ghostty =
        mkOpt types.str "dark:Doom One,light:Doom One"
          "Ghostty theme string (supports dark:/light: prefixes).";
      nvim = mkOpt types.str "onedark" "Nixvim colorscheme name (maps to colorschemes.<name>.enable).";
      helix = mkOpt types.str "doomone" "Helix theme name.";
      bat = mkOpt types.str "TwoDark" "Bat syntax highlighting theme.";
      cheat = mkOpt types.str "monokai" "Cheat syntax highlighting style.";
    };

    palette = {
      base = mkOpt hexColor "#1e1e2e" "Dark background color.";
      text = mkOpt hexColor "#cdd6f4" "Primary text color.";
      muted = mkOpt hexColor "#6c7086" "Secondary text, borders, and helper text.";
      accent = mkOpt hexColor "#cba6f7" "Primary accent color (active tabs, session indicators).";
      pink = mkOpt hexColor "#f5c2e7" "Highlight color (normal mode).";
      red = mkOpt hexColor "#f38ba8" "Alert color (resize, session modes).";
      blue = mkOpt hexColor "#89b4fa" "Info color (pane mode).";
      teal = mkOpt hexColor "#94e2d5" "Secondary accent (move mode).";
      lavender = mkOpt hexColor "#b4befe" "Tertiary accent (tab mode).";
      yellow = mkOpt hexColor "#f9e2af" "Warning/search color.";
    };
  };
}
