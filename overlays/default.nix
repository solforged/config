final: prev: {
  musicctl = final.callPackage ../modules/home/media/music/openclaw-plugin/package.nix { };

  emacs = prev.emacs.overrideAttrs (old: {
    patches =
      (old.patches or [ ])
      ++ prev.lib.optionals prev.stdenv.isDarwin [
        # Auto-detect macOS light/dark mode and update `ns-system-appearance'
        (prev.fetchpatch {
          name = "system-appearance.patch";
          url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-30/system-appearance.patch";
          hash = "sha256-3QLq91AQ6E921/W9nfDjdOUWR8YVsqBAT/W9c1woqAw=";
        })
        # Fix window role so Emacs is visible to Mission Control and Cmd-Tab
        (prev.fetchpatch {
          name = "fix-window-role.patch";
          url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
          hash = "sha256-+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
        })
        # Round corners on undecorated frames (adds `undecorated-round' parameter)
        (prev.fetchpatch {
          name = "round-undecorated-frame.patch";
          url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-30/round-undecorated-frame.patch";
          hash = "sha256-uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
        })
      ];
  });

  zsh-fzf-tab = prev.zsh-fzf-tab.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + prev.lib.optionalString prev.stdenv.hostPlatform.isDarwin ''
        if [ -e "$out/share/fzf-tab/modules/Src/aloxaf/fzftab.so" ] && [ ! -e "$out/share/fzf-tab/modules/Src/aloxaf/fzftab.bundle" ]; then
          ln -s fzftab.so "$out/share/fzf-tab/modules/Src/aloxaf/fzftab.bundle"
        fi
      '';
  });
}
