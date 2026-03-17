;;; absolutely-dark-theme.el --- A warm, Claude-inspired dark theme for Emacs -*- lexical-binding: t; -*-

;; Author: Claude (still ironic)
;; URL: https://github.com/FIXME/absolutely-theme
;; Version: 1.0.0
;; Package-Requires: ((emacs "24.1"))
;; Keywords: faces, theme

;; This file is not part of GNU Emacs.

;;; Commentary:

;; The dark variant of the Absolutely theme.  Same warm earth-tone
;; palette, now on a deep espresso background.  For those late-night
;; sessions where you absolutely need to ship that feature.
;;
;; Install:
;;   Copy this file to your custom theme directory, e.g.:
;;     ~/.emacs.d/themes/
;;
;;   Then add to your init:
;;     (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
;;     (load-theme 'absolutely-dark t)

;;; Code:

(deftheme absolutely-dark
  "Absolutely, but make it dark. A warm, Claude-inspired dark theme.")

(let (;; ── Core palette ──────────────────────────────────────────
      ;; Background tones (warm espresso darks)
      (bg-main     "#1E1B18")
      (bg-alt      "#252220")
      (bg-accent   "#2E2A26")
      (bg-strong   "#3A3530")
      (bg-hover    "#352E28")

      ;; Foreground tones (warm lights)
      (fg-main     "#E8E0D6")
      (fg-dim      "#A89E92")
      (fg-faint    "#7A7268")
      (fg-ghost    "#5A534C")

      ;; ── Signature Claude terracotta ──────────────────────────
      (terra        "#D88060")
      (terra-bright "#E89070")
      (terra-dim    "#B86E50")

      ;; ── Earth tones for syntax (boosted for dark bg) ─────────
      (clay         "#D08060")   ; functions
      (sage         "#8AAA70")   ; strings
      (sage-light   "#9AB880")   ; string escapes
      (ochre        "#D0A050")   ; constants/numbers
      (sienna       "#C08860")   ; types
      (plum         "#A888B8")   ; builtins
      (slate        "#88A0B0")   ; operators/delimiters
      (umber        "#C09878")   ; variables

      ;; ── Functional colors ────────────────────────────────────
      (info         "#70A8B8")   ; cool teal
      (success      "#80A870")   ; muted green
      (warning      "#D0A048")   ; warm amber
      (error        "#D06060")   ; warm red
      (error-bg     "#3A2020")

      ;; ── UI elements ──────────────────────────────────────────
      (cursor       "#D88060")   ; terracotta cursor
      (region       "#3E3530")
      (hl-line      "#262320")
      (border       "#3A3530")
      (shadow       "#2A2622")
      (link         "#88A8B8")
      (match-bg     "#4A3828")
      (match-fg     "#E0C8A0")
      (diff-add-bg  "#1E3020")
      (diff-add-fg  "#80C070")
      (diff-del-bg  "#302020")
      (diff-del-fg  "#D07070")
      (diff-chg-bg  "#302818")
      (diff-chg-fg  "#D0B868"))

  (custom-theme-set-faces
   'absolutely-dark

   ;; ── Basic faces ─────────────────────────────────────────────
   `(default                         ((t (:foreground ,fg-main :background ,bg-main))))
   `(cursor                          ((t (:background ,cursor))))
   `(region                          ((t (:background ,region :extend t))))
   `(highlight                       ((t (:background ,bg-hover))))
   `(hl-line                         ((t (:background ,hl-line))))
   `(fringe                          ((t (:background ,bg-main :foreground ,fg-ghost))))
   `(vertical-border                 ((t (:foreground ,border))))
   `(border                          ((t (:background ,border :foreground ,border))))
   `(shadow                          ((t (:foreground ,fg-faint))))
   `(minibuffer-prompt               ((t (:foreground ,terra :weight bold))))
   `(link                            ((t (:foreground ,link :underline t))))
   `(link-visited                    ((t (:foreground ,plum :underline t))))
   `(button                          ((t (:foreground ,link :underline t))))
   `(error                           ((t (:foreground ,error :weight bold))))
   `(warning                         ((t (:foreground ,warning :weight bold))))
   `(success                         ((t (:foreground ,success :weight bold))))
   `(escape-glyph                    ((t (:foreground ,ochre))))
   `(homoglyph                       ((t (:foreground ,ochre))))
   `(trailing-whitespace             ((t (:background ,error-bg))))

   ;; ── Line numbers ───────────────────────────────────────────
   `(line-number                     ((t (:foreground ,fg-ghost :background ,bg-main))))
   `(line-number-current-line        ((t (:foreground ,terra :background ,hl-line :weight bold))))

   ;; ── Font lock (syntax highlighting) ─────────────────────────
   `(font-lock-keyword-face          ((t (:foreground ,terra :weight semi-bold))))
   `(font-lock-function-name-face    ((t (:foreground ,clay :weight semi-bold))))
   `(font-lock-function-call-face    ((t (:foreground ,clay))))
   `(font-lock-variable-name-face    ((t (:foreground ,umber))))
   `(font-lock-variable-use-face     ((t (:foreground ,fg-main))))
   `(font-lock-string-face           ((t (:foreground ,sage))))
   `(font-lock-doc-face              ((t (:foreground ,sage-light :slant italic))))
   `(font-lock-comment-face          ((t (:foreground ,fg-faint :slant italic))))
   `(font-lock-comment-delimiter-face ((t (:foreground ,fg-ghost :slant italic))))
   `(font-lock-type-face             ((t (:foreground ,sienna))))
   `(font-lock-constant-face         ((t (:foreground ,ochre))))
   `(font-lock-number-face           ((t (:foreground ,ochre))))
   `(font-lock-builtin-face          ((t (:foreground ,plum))))
   `(font-lock-preprocessor-face     ((t (:foreground ,slate :weight semi-bold))))
   `(font-lock-negation-char-face    ((t (:foreground ,error))))
   `(font-lock-warning-face          ((t (:foreground ,warning :weight bold))))
   `(font-lock-regexp-grouping-backslash ((t (:foreground ,ochre :weight bold))))
   `(font-lock-regexp-grouping-construct ((t (:foreground ,plum :weight bold))))
   `(font-lock-property-name-face    ((t (:foreground ,sienna))))
   `(font-lock-property-use-face     ((t (:foreground ,fg-main))))
   `(font-lock-operator-face         ((t (:foreground ,slate))))
   `(font-lock-punctuation-face      ((t (:foreground ,fg-dim))))
   `(font-lock-bracket-face          ((t (:foreground ,fg-dim))))
   `(font-lock-delimiter-face        ((t (:foreground ,fg-dim))))
   `(font-lock-escape-face           ((t (:foreground ,sage-light :weight bold))))
   `(font-lock-misc-punctuation-face ((t (:foreground ,fg-dim))))

   ;; ── Search / match ─────────────────────────────────────────
   `(isearch                         ((t (:background ,terra-bright :foreground ,bg-main :weight bold))))
   `(isearch-fail                    ((t (:background ,error-bg :foreground ,error))))
   `(lazy-highlight                  ((t (:background ,match-bg :foreground ,match-fg))))
   `(match                           ((t (:background ,match-bg :foreground ,match-fg :weight bold))))

   ;; ── Mode line ───────────────────────────────────────────────
   `(mode-line                       ((t (:background ,bg-accent :foreground ,fg-main :box (:line-width 1 :color ,border)))))
   `(mode-line-active                ((t (:inherit mode-line))))
   `(mode-line-inactive              ((t (:background ,bg-alt :foreground ,fg-faint :box (:line-width 1 :color ,bg-strong)))))
   `(mode-line-emphasis              ((t (:foreground ,terra :weight bold))))
   `(mode-line-buffer-id             ((t (:foreground ,fg-main :weight bold))))
   `(mode-line-highlight             ((t (:box (:line-width 1 :color ,terra)))))

   ;; ── Header line ─────────────────────────────────────────────
   `(header-line                     ((t (:background ,bg-alt :foreground ,fg-dim :box (:line-width 1 :color ,border)))))
   `(header-line-highlight           ((t (:foreground ,terra))))

   ;; ── Tab bar / tab line ──────────────────────────────────────
   `(tab-bar                         ((t (:background ,bg-accent :foreground ,fg-dim))))
   `(tab-bar-tab                     ((t (:background ,bg-main :foreground ,fg-main :weight bold :box (:line-width 1 :color ,border)))))
   `(tab-bar-tab-inactive            ((t (:background ,bg-accent :foreground ,fg-faint :box (:line-width 1 :color ,bg-strong)))))
   `(tab-line                        ((t (:background ,bg-accent))))

   ;; ── Completions / minibuffer ────────────────────────────────
   `(completions-common-part         ((t (:foreground ,terra :weight bold))))
   `(completions-first-difference    ((t (:foreground ,clay :weight bold))))
   `(completions-annotations         ((t (:foreground ,fg-faint :slant italic))))
   `(icomplete-first-match           ((t (:foreground ,terra :weight bold))))

   ;; ── Parenthesis matching ───────────────────────────────────
   `(show-paren-match                ((t (:background ,match-bg :foreground ,terra :weight bold))))
   `(show-paren-mismatch             ((t (:background ,error :foreground ,bg-main :weight bold))))

   ;; ── Whitespace mode ─────────────────────────────────────────
   `(whitespace-space                ((t (:foreground ,bg-strong))))
   `(whitespace-tab                  ((t (:foreground ,bg-strong))))
   `(whitespace-newline              ((t (:foreground ,bg-strong))))
   `(whitespace-trailing             ((t (:background ,error-bg))))
   `(whitespace-line                 ((t (:background ,error-bg :foreground ,error))))
   `(whitespace-empty                ((t (:background ,error-bg))))

   ;; ── Diff / ediff ───────────────────────────────────────────
   `(diff-added                      ((t (:background ,diff-add-bg :foreground ,diff-add-fg :extend t))))
   `(diff-removed                    ((t (:background ,diff-del-bg :foreground ,diff-del-fg :extend t))))
   `(diff-changed                    ((t (:background ,diff-chg-bg :foreground ,diff-chg-fg :extend t))))
   `(diff-header                     ((t (:background ,bg-accent :foreground ,fg-dim :extend t))))
   `(diff-file-header                ((t (:background ,bg-accent :foreground ,fg-main :weight bold :extend t))))
   `(diff-hunk-header                ((t (:background ,bg-accent :foreground ,terra :extend t))))
   `(diff-indicator-added            ((t (:foreground ,diff-add-fg :weight bold))))
   `(diff-indicator-removed          ((t (:foreground ,diff-del-fg :weight bold))))
   `(diff-refine-added               ((t (:background ,diff-add-fg :foreground ,bg-main))))
   `(diff-refine-removed             ((t (:background ,diff-del-fg :foreground ,bg-main))))

   ;; ── Org mode ────────────────────────────────────────────────
   `(org-level-1                     ((t (:foreground ,terra :weight bold :height 1.2))))
   `(org-level-2                     ((t (:foreground ,clay :weight bold :height 1.1))))
   `(org-level-3                     ((t (:foreground ,sienna :weight bold))))
   `(org-level-4                     ((t (:foreground ,plum :weight bold))))
   `(org-level-5                     ((t (:foreground ,slate :weight bold))))
   `(org-level-6                     ((t (:foreground ,sage :weight bold))))
   `(org-level-7                     ((t (:foreground ,umber :weight bold))))
   `(org-level-8                     ((t (:foreground ,ochre :weight bold))))
   `(org-document-title              ((t (:foreground ,fg-main :weight bold :height 1.4))))
   `(org-document-info               ((t (:foreground ,fg-dim :slant italic))))
   `(org-document-info-keyword       ((t (:foreground ,fg-faint))))
   `(org-todo                        ((t (:foreground ,terra-bright :weight bold))))
   `(org-done                        ((t (:foreground ,success :weight bold))))
   `(org-headline-done               ((t (:foreground ,fg-faint :strike-through t))))
   `(org-date                        ((t (:foreground ,info :underline t))))
   `(org-tag                         ((t (:foreground ,fg-faint :weight normal))))
   `(org-code                        ((t (:foreground ,clay :background ,bg-alt))))
   `(org-verbatim                    ((t (:foreground ,plum :background ,bg-alt))))
   `(org-block                       ((t (:background ,bg-alt :extend t))))
   `(org-block-begin-line            ((t (:foreground ,fg-ghost :background ,bg-accent :extend t))))
   `(org-block-end-line              ((t (:inherit org-block-begin-line))))
   `(org-table                       ((t (:foreground ,fg-main))))
   `(org-meta-line                   ((t (:foreground ,fg-ghost))))
   `(org-drawer                      ((t (:foreground ,fg-ghost))))
   `(org-link                        ((t (:foreground ,link :underline t))))
   `(org-checkbox                    ((t (:foreground ,terra :weight bold))))
   `(org-list-dt                     ((t (:foreground ,terra :weight bold))))
   `(org-agenda-date                 ((t (:foreground ,terra :weight bold))))
   `(org-agenda-date-today           ((t (:foreground ,terra-bright :weight bold :height 1.1))))
   `(org-agenda-structure            ((t (:foreground ,fg-dim :weight bold))))
   `(org-scheduled                   ((t (:foreground ,sage))))
   `(org-scheduled-today             ((t (:foreground ,fg-main :weight bold))))
   `(org-upcoming-deadline           ((t (:foreground ,warning))))
   `(org-warning                     ((t (:foreground ,error :weight bold))))

   ;; ── Markdown ────────────────────────────────────────────────
   `(markdown-header-face-1          ((t (:foreground ,terra :weight bold :height 1.2))))
   `(markdown-header-face-2          ((t (:foreground ,clay :weight bold :height 1.1))))
   `(markdown-header-face-3          ((t (:foreground ,sienna :weight bold))))
   `(markdown-header-face-4          ((t (:foreground ,plum :weight bold))))
   `(markdown-bold-face              ((t (:weight bold))))
   `(markdown-italic-face            ((t (:slant italic))))
   `(markdown-code-face              ((t (:foreground ,clay :background ,bg-alt))))
   `(markdown-inline-code-face       ((t (:foreground ,clay :background ,bg-alt))))
   `(markdown-pre-face               ((t (:foreground ,clay :background ,bg-alt))))
   `(markdown-link-face              ((t (:foreground ,link))))
   `(markdown-url-face               ((t (:foreground ,fg-faint :underline t))))
   `(markdown-blockquote-face        ((t (:foreground ,fg-dim :slant italic))))

   ;; ── Magit ───────────────────────────────────────────────────
   `(magit-section-heading           ((t (:foreground ,terra :weight bold))))
   `(magit-section-highlight         ((t (:background ,hl-line :extend t))))
   `(magit-branch-local              ((t (:foreground ,info :weight bold))))
   `(magit-branch-remote             ((t (:foreground ,sage :weight bold))))
   `(magit-branch-current            ((t (:foreground ,info :weight bold :box (:line-width 1 :color ,info)))))
   `(magit-tag                       ((t (:foreground ,ochre))))
   `(magit-hash                      ((t (:foreground ,fg-faint))))
   `(magit-log-author                ((t (:foreground ,fg-dim))))
   `(magit-log-date                  ((t (:foreground ,fg-faint))))
   `(magit-diff-added                ((t (:background ,diff-add-bg :foreground ,diff-add-fg :extend t))))
   `(magit-diff-added-highlight      ((t (:background ,diff-add-bg :foreground ,diff-add-fg :extend t))))
   `(magit-diff-removed              ((t (:background ,diff-del-bg :foreground ,diff-del-fg :extend t))))
   `(magit-diff-removed-highlight    ((t (:background ,diff-del-bg :foreground ,diff-del-fg :extend t))))
   `(magit-diff-context              ((t (:foreground ,fg-dim :extend t))))
   `(magit-diff-context-highlight    ((t (:background ,hl-line :foreground ,fg-dim :extend t))))
   `(magit-diff-hunk-heading         ((t (:background ,bg-accent :foreground ,fg-dim :extend t))))
   `(magit-diff-hunk-heading-highlight ((t (:background ,bg-strong :foreground ,fg-main :extend t))))
   `(magit-diff-file-heading         ((t (:foreground ,fg-main :weight bold))))
   `(magit-diffstat-added            ((t (:foreground ,success))))
   `(magit-diffstat-removed          ((t (:foreground ,error))))
   `(magit-dimmed                    ((t (:foreground ,fg-faint))))
   `(magit-filename                  ((t (:foreground ,fg-main))))

   ;; ── Company / Corfu (completion popups) ─────────────────────
   `(company-tooltip                 ((t (:background ,bg-accent :foreground ,fg-main))))
   `(company-tooltip-selection       ((t (:background ,bg-hover :foreground ,fg-main :weight bold))))
   `(company-tooltip-common          ((t (:foreground ,terra :weight bold))))
   `(company-tooltip-common-selection ((t (:foreground ,terra-bright :weight bold))))
   `(company-tooltip-annotation      ((t (:foreground ,fg-faint))))
   `(company-scrollbar-bg            ((t (:background ,bg-strong))))
   `(company-scrollbar-fg            ((t (:background ,terra-dim))))
   `(company-preview                 ((t (:foreground ,fg-faint :slant italic))))
   `(company-preview-common          ((t (:foreground ,terra :slant italic))))

   `(corfu-default                   ((t (:background ,bg-accent :foreground ,fg-main))))
   `(corfu-current                   ((t (:background ,bg-hover :foreground ,fg-main :weight bold))))
   `(corfu-bar                       ((t (:background ,terra-dim))))
   `(corfu-border                    ((t (:background ,border))))
   `(corfu-annotations               ((t (:foreground ,fg-faint))))

   ;; ── Vertico / Orderless / Marginalia ────────────────────────
   `(vertico-current                 ((t (:background ,bg-hover :extend t))))
   `(orderless-match-face-0          ((t (:foreground ,terra :weight bold))))
   `(orderless-match-face-1          ((t (:foreground ,clay :weight bold))))
   `(orderless-match-face-2          ((t (:foreground ,plum :weight bold))))
   `(orderless-match-face-3          ((t (:foreground ,sage :weight bold))))
   `(marginalia-documentation        ((t (:foreground ,fg-faint :slant italic))))
   `(marginalia-key                  ((t (:foreground ,terra))))
   `(marginalia-file-name            ((t (:foreground ,fg-dim))))

   ;; ── Which-key ───────────────────────────────────────────────
   `(which-key-key-face              ((t (:foreground ,terra :weight bold))))
   `(which-key-separator-face        ((t (:foreground ,fg-ghost))))
   `(which-key-command-description-face ((t (:foreground ,fg-main))))
   `(which-key-group-description-face ((t (:foreground ,plum))))

   ;; ── Flycheck / Flymake ──────────────────────────────────────
   `(flycheck-error                  ((t (:underline (:style wave :color ,error)))))
   `(flycheck-warning                ((t (:underline (:style wave :color ,warning)))))
   `(flycheck-info                   ((t (:underline (:style wave :color ,info)))))
   `(flycheck-fringe-error           ((t (:foreground ,error))))
   `(flycheck-fringe-warning         ((t (:foreground ,warning))))
   `(flycheck-fringe-info            ((t (:foreground ,info))))
   `(flymake-error                   ((t (:underline (:style wave :color ,error)))))
   `(flymake-warning                 ((t (:underline (:style wave :color ,warning)))))
   `(flymake-note                    ((t (:underline (:style wave :color ,info)))))

   ;; ── Eglot / LSP ────────────────────────────────────────────
   `(eglot-highlight-symbol-face     ((t (:background ,match-bg :weight bold))))
   `(eglot-diagnostic-tag-unnecessary-face ((t (:foreground ,fg-faint :slant italic))))

   ;; ── Tree-sitter ─────────────────────────────────────────────
   `(tree-sitter-hl-face:keyword     ((t (:foreground ,terra :weight semi-bold))))
   `(tree-sitter-hl-face:function    ((t (:foreground ,clay :weight semi-bold))))
   `(tree-sitter-hl-face:function.call ((t (:foreground ,clay))))
   `(tree-sitter-hl-face:method      ((t (:foreground ,clay))))
   `(tree-sitter-hl-face:method.call ((t (:foreground ,clay))))
   `(tree-sitter-hl-face:type        ((t (:foreground ,sienna))))
   `(tree-sitter-hl-face:type.builtin ((t (:foreground ,sienna :slant italic))))
   `(tree-sitter-hl-face:variable    ((t (:foreground ,fg-main))))
   `(tree-sitter-hl-face:variable.parameter ((t (:foreground ,umber))))
   `(tree-sitter-hl-face:variable.builtin ((t (:foreground ,plum))))
   `(tree-sitter-hl-face:string      ((t (:foreground ,sage))))
   `(tree-sitter-hl-face:string.special ((t (:foreground ,sage-light))))
   `(tree-sitter-hl-face:comment     ((t (:foreground ,fg-faint :slant italic))))
   `(tree-sitter-hl-face:doc         ((t (:foreground ,sage-light :slant italic))))
   `(tree-sitter-hl-face:number      ((t (:foreground ,ochre))))
   `(tree-sitter-hl-face:constant    ((t (:foreground ,ochre))))
   `(tree-sitter-hl-face:constant.builtin ((t (:foreground ,ochre :slant italic))))
   `(tree-sitter-hl-face:property    ((t (:foreground ,sienna))))
   `(tree-sitter-hl-face:operator    ((t (:foreground ,slate))))
   `(tree-sitter-hl-face:punctuation ((t (:foreground ,fg-dim))))
   `(tree-sitter-hl-face:punctuation.bracket ((t (:foreground ,fg-dim))))
   `(tree-sitter-hl-face:punctuation.delimiter ((t (:foreground ,fg-dim))))
   `(tree-sitter-hl-face:label       ((t (:foreground ,info))))
   `(tree-sitter-hl-face:attribute   ((t (:foreground ,plum))))
   `(tree-sitter-hl-face:embedded    ((t (:foreground ,fg-main))))
   `(tree-sitter-hl-face:constructor ((t (:foreground ,sienna :weight semi-bold))))
   `(tree-sitter-hl-face:tag         ((t (:foreground ,terra))))
   `(tree-sitter-hl-face:escape      ((t (:foreground ,sage-light :weight bold))))

   ;; ── Dired ───────────────────────────────────────────────────
   `(dired-directory                 ((t (:foreground ,terra :weight bold))))
   `(dired-symlink                   ((t (:foreground ,info))))
   `(dired-flagged                   ((t (:foreground ,error :weight bold))))
   `(dired-marked                    ((t (:foreground ,warning :weight bold))))
   `(dired-header                    ((t (:foreground ,terra :weight bold :height 1.1))))
   `(dired-ignored                   ((t (:foreground ,fg-faint))))
   `(dired-perm-write                ((t (:foreground ,clay))))

   ;; ── Eshell / term ──────────────────────────────────────────
   `(eshell-prompt                   ((t (:foreground ,terra :weight bold))))
   `(eshell-ls-directory             ((t (:foreground ,info :weight bold))))
   `(eshell-ls-executable            ((t (:foreground ,success :weight bold))))
   `(eshell-ls-symlink               ((t (:foreground ,info))))
   `(eshell-ls-archive               ((t (:foreground ,plum))))
   `(eshell-ls-backup                ((t (:foreground ,fg-faint))))
   `(eshell-ls-readonly              ((t (:foreground ,ochre))))
   `(eshell-ls-unreadable            ((t (:foreground ,error))))

   ;; ── Ansi colors (for terminal emulators) ───────────────────
   `(ansi-color-black                ((t (:foreground ,bg-accent :background ,bg-accent))))
   `(ansi-color-red                  ((t (:foreground ,error :background ,error))))
   `(ansi-color-green                ((t (:foreground ,sage :background ,sage))))
   `(ansi-color-yellow               ((t (:foreground ,ochre :background ,ochre))))
   `(ansi-color-blue                 ((t (:foreground ,slate :background ,slate))))
   `(ansi-color-magenta              ((t (:foreground ,plum :background ,plum))))
   `(ansi-color-cyan                 ((t (:foreground ,info :background ,info))))
   `(ansi-color-white                ((t (:foreground ,fg-main :background ,fg-main))))
   `(ansi-color-bright-black         ((t (:foreground ,fg-faint :background ,fg-faint))))
   `(ansi-color-bright-red           ((t (:foreground ,terra-bright :background ,terra-bright))))
   `(ansi-color-bright-green         ((t (:foreground ,sage-light :background ,sage-light))))
   `(ansi-color-bright-yellow        ((t (:foreground ,warning :background ,warning))))
   `(ansi-color-bright-blue          ((t (:foreground ,link :background ,link))))
   `(ansi-color-bright-magenta       ((t (:foreground ,plum :background ,plum))))
   `(ansi-color-bright-cyan          ((t (:foreground ,info :background ,info))))
   `(ansi-color-bright-white         ((t (:foreground ,fg-main :background ,fg-main))))

   ;; ── Misc ────────────────────────────────────────────────────
   `(tooltip                         ((t (:background ,bg-accent :foreground ,fg-main))))
   `(widget-field                    ((t (:background ,bg-alt :foreground ,fg-main :box (:line-width 1 :color ,border)))))
   `(widget-button                   ((t (:foreground ,terra :weight bold :underline t))))
   `(secondary-selection             ((t (:background ,bg-strong))))
   `(window-divider                  ((t (:foreground ,border))))
   `(window-divider-first-pixel      ((t (:foreground ,bg-alt))))
   `(window-divider-last-pixel       ((t (:foreground ,bg-alt))))
   `(fill-column-indicator           ((t (:foreground ,bg-strong))))
   `(bookmark-face                   ((t (:foreground ,terra :weight bold))))
   `(fixed-pitch                     ((t (:family unspecified))))
   `(fixed-pitch-serif               ((t (:family unspecified))))
   `(variable-pitch                  ((t (:family unspecified)))))

  ;; ── Custom variables ─────────────────────────────────────────
  (custom-theme-set-variables
   'absolutely-dark
   `(ansi-color-names-vector
     [,bg-accent ,error ,sage ,ochre ,slate ,plum ,info ,fg-main])))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'absolutely-dark)

;; Local Variables:
;; no-byte-compile: t
;; End:

;;; absolutely-dark-theme.el ends here
