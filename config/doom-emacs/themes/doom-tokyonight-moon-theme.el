;;; doom-tokyonight-moon-theme.el --- TokyoNight Moon theme for Doom Emacs -*- lexical-binding: t; no-byte-compile: t; -*-
;;
;; Author: Malmgrek
;; Maintainer: Malmgrek
;; Source: https://github.com/folke/tokyonight.nvim
;;
;;; Commentary:
;;
;; A vibrant, dark theme inspired by the TokyoNight Moon variant from
;; LazyVim/Neovim. Features bright, saturated colors with glossy highlights
;; and colored backgrounds for LSP diagnostics.
;;
;;; Code:

(require 'doom-themes)


;;
;;; Variables

(defgroup doom-tokyonight-moon-theme nil
  "Options for the `doom-tokyonight-moon' theme."
  :group 'doom-themes)

(defcustom doom-tokyonight-moon-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'doom-tokyonight-moon-theme
  :type 'boolean)

(defcustom doom-tokyonight-moon-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'doom-tokyonight-moon-theme
  :type 'boolean)

(defcustom doom-tokyonight-moon-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line.
Can be an integer to determine the exact padding."
  :group 'doom-tokyonight-moon-theme
  :type '(choice integer boolean))

(defcustom doom-tokyonight-moon-transparent-background nil
  "If non-nil, use a transparent background."
  :group 'doom-tokyonight-moon-theme
  :type 'boolean)


;;
;;; Theme definition

(def-doom-theme doom-tokyonight-moon
    "A dark theme inspired by TokyoNight Moon from LazyVim.
Features vibrant colors with glossy highlights and colored diagnostic backgrounds."

  ;; name        default   256           16
  ((bg         (if doom-tokyonight-moon-transparent-background 'unspecified "#222436"))
   (fg         '("#c8d3f5" "#c8d3f5"     "brightwhite"  ))

   ;; These are off-color variants of bg/fg, used primarily for `solaire-mode',
   ;; but can also be useful as a basis for subtle highlights
   (bg-alt     (if doom-tokyonight-moon-transparent-background 'unspecified "#1e2030"))
   (fg-alt     '("#828bb8" "#828bb8"     "white"        ))

   ;; These should represent a spectrum from bg to fg
   (base0      '("#1b1d2b" "#1b1d2b"     "black"        ))
   (base1      '("#1e2030" "#1e2030"     "brightblack"  ))
   (base2      '("#24283c" "#24283c"     "brightblack"  ))
   (base3      '("#2f334d" "#2f334d"     "brightblack"  ))
   (base4      '("#3b4261" "#3b4261"     "brightblack"  ))
   (base5      '("#545c7e" "#545c7e"     "brightblack"  ))
   (base6      '("#636da6" "#636da6"     "brightblack"  ))
   (base7      '("#828bb8" "#828bb8"     "brightblack"  ))
   (base8      '("#c8d3f5" "#c8d3f5"     "white"        ))

    (grey       base4)
    (red        '("#ff757f" "#ff757f" "red"          ))
    (red1       '("#c53b53" "#c53b53" "red"          ))
    (orange     '("#ff966c" "#ff966c" "brightred"    ))
    (green      '("#c3e88d" "#c3e88d" "green"        ))
    (green1     '("#b8db87" "#b8db87" "green"        ))
    (green2     '("#4fd6be" "#4fd6be" "brightgreen"  ))
    (teal       '("#1abc9c" "#1abc9c" "brightgreen"  ))
    (yellow     '("#ffc777" "#ffc777" "yellow"       ))
    (blue       '("#82aaff" "#82aaff" "brightblue"   ))
    (blue0      '("#3e68d7" "#3e68d7" "blue"         ))
    (blue1      '("#65bcff" "#65bcff" "brightblue"   ))
    (blue2      '("#0db9d7" "#0db9d7" "brightblue"   ))
    (blue5      '("#89ddff" "#89ddff" "brightcyan"   ))
    (dark-blue  '("#394b70" "#394b70" "blue"         ))
    (magenta    '("#c099ff" "#c099ff" "brightmagenta"))
    (purple     '("#fca7ea" "#fca7ea" "magenta"      ))
    (violet     '("#c099ff" "#c099ff" "magenta"      ))
    (cyan       '("#86e1fc" "#86e1fc" "brightcyan"   ))
    (dark-cyan  '("#41a6b5" "#41a6b5" "cyan"         ))

    ;; TokyoNight Moon specific colors
    (bg-dark    '("#1e2030" "#1e2030" "black"))
    (bg-highlight '("#2f334d" "#2f334d" "brightblack"))
    (bg-visual  '("#2d3f76" "#2d3f76" "blue"))        ; The glossy selection!
    (bg-search  '("#3e68d7" "#3e68d7" "brightblue"))
    (comment-fg '("#636da6" "#636da6" "brightblack"))
    (border     '("#589ed7" "#589ed7" "brightblue"))

    ;; Darker colors for modeline and borders
    (modeline-bg-dark   '("#15161f" "#15161f" "black"))      ; Very dark modeline
    (modeline-bg-darker '("#0f1014" "#0f1014" "black"))      ; Even darker for inactive
    (border-dark        '("#0d0e14" "#0d0e14" "black"))      ; Very dark blue-black border

   ;; Diagnostic background colors (the glossy effect!)
   (error-bg   '("#322639" "#322639" "black"))
   (warning-bg '("#38343d" "#38343d" "black"))
   (info-bg    '("#203346" "#203346" "black"))
   (hint-bg    '("#273644" "#273644" "black"))

   ;; Git colors
   (git-add    green1)
   (git-change '("#7ca1f2" "#7ca1f2" "blue"))
   (git-delete '("#e26a75" "#e26a75" "red"))

    ;; These are the "universal syntax classes" that doom-themes establishes.
    (highlight      blue)
    (vertical-bar   border-dark)
   (selection      bg-visual)  ; The vibrant glossy selection!
   (builtin        magenta)
   (comments       (if doom-tokyonight-moon-brighter-comments
                       (doom-lighten comment-fg 0.2)
                     comment-fg))
   (doc-comments   (doom-lighten comment-fg 0.25))
   (constants      orange)
   (functions      blue)
   (keywords       purple)
   (methods        blue)
   (operators      blue5)
   (type           yellow)
   (strings        green)
   (variables      fg)
   (numbers        orange)
   (region         bg-visual)  ; Glossy blue selection region
   (error          red1)
   (warning        yellow)
   (success        green)
   (vc-modified    git-change)
   (vc-added       git-add)
   (vc-deleted     git-delete)

     ;; Additional vibrant syntax classes for multicolor highlighting
     (property-name  green2)
     (property-use   green2)
     (parameter      yellow)     ; Function parameters - match LazyVim
     (decorator      magenta)    ; Decorators like @property
     (special-param  red)        ; Special parameters like self, cls - match LazyVim

    ;; Modeline colors
    (modeline-fg              fg)
    (modeline-fg-alt          base5)
    (modeline-bg              (if doom-tokyonight-moon-brighter-modeline
                                  (doom-darken blue 0.45)
                                modeline-bg-dark))
    (modeline-bg-alt          (if doom-tokyonight-moon-brighter-modeline
                                  (doom-darken blue 0.475)
                                modeline-bg-darker))
    (modeline-bg-inactive     modeline-bg-darker)
    (modeline-bg-inactive-alt (doom-darken modeline-bg-darker 0.1))

    (-modeline-pad
    (when doom-tokyonight-moon-padded-modeline
      (if (integerp doom-tokyonight-moon-padded-modeline)
          doom-tokyonight-moon-padded-modeline
        4))))


   ;;;; Base theme face overrides
  (((line-number &override) :foreground base4)
   ((line-number-current-line &override) :foreground orange :weight 'bold)
    ((font-lock-comment-face &override) :slant 'italic)
    ((font-lock-doc-face &override) :slant 'italic :foreground (doom-lighten comment-fg 0.3))

   ;; Cursor and highlights
   (cursor :background fg :foreground bg)
   (hl-line :background bg-highlight)

   ;; Selection and search
   (region :background bg-visual :distant-foreground fg :extend t)
   (lazy-highlight :background bg-search :foreground fg :weight 'bold)
   (isearch :background orange :foreground base0 :weight 'bold)

    ;; Borders and visual elements
    (vertical-border :foreground border-dark)
   (fringe :background bg)
   (vi-tilde-fringe-face :foreground base4)

   ;; Mode line
   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))
   (mode-line-emphasis :foreground (if doom-tokyonight-moon-brighter-modeline base8 highlight))

    ;;;; LSP & Diagnostics (with colored backgrounds - the glossy effect!)
    (lsp-face-highlight-textual :background "#3b4261" :foreground fg)
    (lsp-face-highlight-read :background "#3b4261" :foreground fg :underline t)
    (lsp-face-highlight-write :background "#3b4261" :foreground fg)

   ;; Flycheck with background colors
   (flycheck-error :background error-bg :foreground red1 :underline `(:style wave :color ,red1))
   (flycheck-warning :background warning-bg :foreground yellow :underline `(:style wave :color ,yellow))
   (flycheck-info :background info-bg :foreground blue2 :underline `(:style wave :color ,blue2))

   ;; Flymake with background colors
   (flymake-error :background error-bg :foreground red1 :underline `(:style wave :color ,red1))
   (flymake-warning :background warning-bg :foreground yellow :underline `(:style wave :color ,yellow))
   (flymake-note :background info-bg :foreground blue2 :underline `(:style wave :color ,blue2))

   ;; LSP UI
   (lsp-ui-doc-background :background bg-dark)
   (lsp-ui-doc-border :foreground border)
   (lsp-ui-peek-filename :foreground blue)
   (lsp-ui-peek-header :background bg-dark :foreground fg)
   (lsp-ui-peek-highlight :background bg-visual :foreground fg)
   (lsp-ui-peek-line-number :foreground base5)
   (lsp-ui-peek-list :background bg-alt)
   (lsp-ui-peek-peek :background bg-alt)
   (lsp-ui-peek-selection :background bg-visual :foreground fg :weight 'bold)
   (lsp-ui-sideline-code-action :foreground yellow)
   (lsp-ui-sideline-current-symbol :foreground blue :weight 'bold)
   (lsp-ui-sideline-symbol :foreground base7)

    ;;;; Org-mode (with backgrounds like markdown in tokyonight)
    (org-level-1 :foreground blue :weight 'bold :height 1.1 :background "#2c314a" :extend t)
    (org-level-2 :foreground yellow :weight 'bold :height 1.05 :background "#38343d" :extend t)
    (org-level-3 :foreground green :weight 'bold :height 1.0 :background "#32383f" :extend t)
    (org-level-4 :foreground green2 :weight 'bold :background "#273644" :extend t)
    (org-level-5 :foreground magenta :weight 'bold :background "#32304a" :extend t)
    (org-level-6 :foreground purple :weight 'bold :background "#383148" :extend t)
    (org-level-7 :foreground orange :weight 'bold :background "#382f3b" :extend t)
    (org-level-8 :foreground red :background "#382c3d" :extend t)
   (org-block :background bg-dark :extend t)
   (org-block-begin-line :foreground comment-fg :slant 'italic :background bg-dark :extend t)
   (org-block-end-line :foreground comment-fg :slant 'italic :background bg-dark :extend t)
    (org-code :foreground blue :background "#444a73")
   (org-verbatim :foreground green :weight 'semi-bold)
   (org-todo :foreground red :weight 'bold)
   (org-done :foreground green :weight 'bold)
   (org-headline-done :foreground base5 :strike-through t)
   (org-link :foreground teal :underline t :weight 'semi-bold)
   (org-checkbox :foreground cyan :weight 'bold)
   (org-date :foreground blue5 :slant 'italic)
   (org-tag :foreground magenta :weight 'bold :slant 'italic)
   (org-document-title :foreground blue :weight 'bold :height 1.4)
   (org-document-info :foreground cyan)
   (org-document-info-keyword :foreground comment-fg :slant 'italic)

   ;;;; Magit
   (magit-section-heading :foreground blue :weight 'bold)
   (magit-section-highlight :background bg-highlight :extend t)
   (magit-section-heading-selection :foreground orange :weight 'bold)
   (magit-diff-added :foreground git-add :background "#2a4556" :extend t)
   (magit-diff-added-highlight :foreground git-add :background "#2a4556" :weight 'bold :extend t)
   (magit-diff-removed :foreground git-delete :background "#4b2a3d" :extend t)
   (magit-diff-removed-highlight :foreground git-delete :background "#4b2a3d" :weight 'bold :extend t)
   (magit-diff-context :foreground fg-alt)
   (magit-diff-context-highlight :foreground fg :background bg-highlight)
   (magit-diff-hunk-heading :background base3 :foreground fg-alt :extend t)
   (magit-diff-hunk-heading-highlight :background base4 :foreground blue :weight 'bold :extend t)
   (magit-branch-local :foreground magenta)
   (magit-branch-remote :foreground green)
   (magit-branch-current :foreground blue :weight 'bold :box t)
   (magit-tag :foreground yellow)
   (magit-hash :foreground base7)
   (magit-sequence-done :foreground green)
   (magit-sequence-drop :foreground red)
   (magit-sequence-head :foreground blue)
   (magit-sequence-part :foreground yellow)
   (magit-sequence-stop :foreground teal)

   ;;;; Treemacs - LazyVim Neo-Tree style
   (treemacs-window-background-face :background base0)  ; Darker sidebar background
   (treemacs-root-face :foreground blue :weight 'bold :height 1.0)
   (treemacs-directory-face :foreground blue)
   (treemacs-file-face :foreground fg)
   (treemacs-git-modified-face :foreground yellow)
   (treemacs-git-added-face :foreground git-add)
   (treemacs-git-conflict-face :foreground red)
   (treemacs-git-untracked-face :foreground magenta)
   (treemacs-git-ignored-face :foreground base5)

    ;;;; Neotree
    (neo-root-dir-face :foreground blue :weight 'bold :height 1.2)
    (neo-dir-link-face :foreground blue)
    (neo-file-link-face :foreground fg)
    (neo-expand-btn-face :foreground cyan)

    ;;;; Window Separators (for sidebars like Treemacs, NeoTree)
    (window-separator :foreground border-dark :background bg)
    (win-separator :foreground border-dark :background bg)

    ;;;; Company (glossy completion popup)
   (company-tooltip :background bg-dark :foreground fg)
   (company-tooltip-selection :background bg-visual :foreground fg :weight 'bold)
   (company-tooltip-common :foreground blue1 :weight 'bold)
   (company-tooltip-common-selection :foreground blue1 :weight 'bold)
   (company-tooltip-annotation :foreground fg-alt)
   (company-tooltip-annotation-selection :foreground fg-alt)
   (company-scrollbar-bg :background base3)
   (company-scrollbar-fg :foreground border)
   (company-preview :foreground base5)
   (company-preview-common :foreground blue1)
   (company-preview-search :background bg-search :foreground fg)

   ;;;; Ivy/Counsel/Swiper
   (ivy-current-match :background bg-visual :foreground fg :weight 'bold :extend t)
   (ivy-minibuffer-match-face-1 :foreground blue1)
   (ivy-minibuffer-match-face-2 :foreground blue :weight 'bold)
   (ivy-minibuffer-match-face-3 :foreground magenta :weight 'bold)
   (ivy-minibuffer-match-face-4 :foreground purple :weight 'bold)
   (ivy-match-required-face :foreground red)
   (ivy-virtual :foreground base5)
   (ivy-modified-buffer :foreground yellow)
   (ivy-remote :foreground cyan)
   (counsel-active-mode :foreground green)
   (counsel-outline-default :foreground blue)
   (swiper-match-face-1 :background bg-search :foreground fg)
   (swiper-match-face-2 :background bg-visual :foreground fg :weight 'bold)
   (swiper-match-face-3 :background magenta :foreground base0 :weight 'bold)
   (swiper-match-face-4 :background purple :foreground base0 :weight 'bold)
   (swiper-line-face :background bg-highlight :extend t)

   ;;;; Dired
   (dired-directory :foreground blue :weight 'bold)
   (dired-symlink :foreground cyan :slant 'italic)
   (dired-flagged :foreground red :weight 'bold)
   (dired-marked :foreground yellow :weight 'bold)
   (dired-header :foreground blue :weight 'bold)
   (dired-warning :foreground warning)
   (dired-perm-write :foreground orange)

   ;;;; JavaScript/TypeScript/TSX
   (js2-function-call :foreground blue :slant 'italic)
   (js2-function-param :foreground orange)
   (js2-object-property :foreground teal)
   (js2-private-function-call :foreground blue :slant 'italic)
   (js2-jsdoc-tag :foreground blue :slant 'italic :weight 'semi-bold)
   (js2-jsdoc-type :foreground cyan :slant 'italic)
   (js2-jsdoc-value :foreground green)
   (typescript-jsdoc-tag :foreground blue :slant 'italic :weight 'semi-bold)
   (typescript-jsdoc-type :foreground cyan :slant 'italic)
   (rjsx-tag :foreground red :weight 'bold)
   (rjsx-tag-bracket-face :foreground base7)
   (rjsx-attr :foreground orange :slant 'italic)

    ;; Tree-sitter Python faces (python-ts-mode)
    ;; Function calls and definitions
    (font-lock-function-call-face :foreground blue)

    ;; Properties and attributes (obj.property)
    (font-lock-property-name-face :foreground green2)
    (font-lock-property-use-face :foreground green2)

    ;; Variable names - match LazyVim which uses default fg
    (font-lock-variable-name-face :foreground fg)
    (font-lock-variable-use-face :foreground fg)

    ;; Numbers get their own vibrant color
    (font-lock-number-face :foreground orange)

   ;; Operators - glossy cyan-blue
   (font-lock-operator-face :foreground blue5)

    ;; Brackets and delimiters
    (font-lock-bracket-face :foreground base7)
    (font-lock-delimiter-face :foreground blue5)
    (font-lock-punctuation-face :foreground blue5)
    (font-lock-misc-punctuation-face :foreground blue5)

    ;; String escape sequences (like \n, \t)
    (font-lock-escape-face :foreground magenta)

    ;; Keywords like def, class, return
    ((font-lock-keyword-face &override) :slant 'italic)

   ;;;; Web-mode
   (web-mode-html-tag-face :foreground red)
   (web-mode-html-tag-bracket-face :foreground base7)
   (web-mode-html-attr-name-face :foreground orange :slant 'italic)
   (web-mode-html-attr-value-face :foreground green)
   (web-mode-css-selector-face :foreground blue)
   (web-mode-css-property-name-face :foreground teal)

   ;;;; CSS/SCSS
   (css-selector :foreground blue)
   (css-property :foreground teal)
   (css-proprietary-property :foreground orange)

   ;;;; Doom-specific
   (doom-modeline-bar :background (if doom-tokyonight-moon-brighter-modeline modeline-bg blue))
   (doom-modeline-bar-inactive :background base3)
   (doom-modeline-buffer-file :foreground fg :weight 'bold)
   (doom-modeline-buffer-modified :foreground yellow :weight 'bold)
   (doom-modeline-buffer-path :foreground blue)
   (doom-modeline-project-dir :foreground blue :weight 'bold)
   (doom-modeline-buffer-major-mode :foreground blue)
   (doom-modeline-info :foreground green)
   (doom-modeline-warning :foreground yellow)
   (doom-modeline-urgent :foreground red)
   (doom-modeline-debug :foreground orange)
   (doom-modeline-lsp-success :foreground green)
   (doom-modeline-lsp-warning :foreground yellow)
   (doom-modeline-lsp-error :foreground red)

   ;;;; Solaire-mode
   (solaire-default-face :inherit 'default :background bg-alt)
   (solaire-hl-line-face :background bg-highlight)
   (solaire-mode-line-face
    :inherit 'mode-line
    :background modeline-bg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-alt)))
   (solaire-mode-line-inactive-face
    :inherit 'mode-line-inactive
    :background modeline-bg-inactive-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive-alt)))

   ;;;; Popup/Which-key
   (popup-face :background bg-dark :foreground fg)
   (popup-selection-face :background bg-visual :foreground fg :weight 'bold)
   (popup-tip-face :background bg-dark :foreground cyan)
   (which-key-key-face :foreground magenta :weight 'bold)
   (which-key-command-description-face :foreground fg)
   (which-key-group-description-face :foreground blue)
   (which-key-separator-face :foreground comment-fg)

    ;;;; Alpha/Dashboard - LazyVim TokyoNight Moon style colors
    ;; Dashboard colors matching LazyVim TokyoNight Moon (snacks.nvim dashboard)
    ;; Banner/Logo: blue (#82aaff) - the actual face used by Doom dashboard
    (doom-dashboard-banner :foreground blue :weight 'bold)
    ;; Dashboard menu items (Doom-specific faces)
    (doom-dashboard-menu-title :foreground cyan)        ; Menu item text: cyan (#86e1fc)
    (doom-dashboard-menu-desc :foreground orange)       ; Menu keys/shortcuts: orange (#ff966c)
    (doom-dashboard-menu-icon :foreground blue1)        ; Menu icons: blue1 (#65bcff)
    ;; Dashboard footer (Doom loaded X packages...)
    (doom-dashboard-loaded :foreground blue1)           ; Footer text: blue1 (#65bcff)
    (doom-dashboard-footer :foreground blue1)
    ;; Alpha/Dashboard generic faces (for compatibility)
    ;; Header/Logo: blue (#82aaff)
    (AlphaHeader :foreground blue :weight 'bold)
    (DashboardHeader :foreground blue :weight 'bold)
    ;; Keys/Shortcuts: orange (#ff966c)
    (AlphaShortcut :foreground orange)
    (DashboardKey :foreground orange)
    (DashboardShortCut :foreground cyan)
    ;; Icons: blue1 (#65bcff) - changed from cyan to match LazyVim
    (AlphaButtons :foreground blue1)
    (DashboardIcon :foreground blue1)
    (DashboardMruIcon :foreground purple)
    (DashboardProjectIcon :foreground yellow)
    (DashboardShortCutIcon :foreground magenta)
    ;; Descriptions: cyan (#86e1fc)
    (DashboardDesc :foreground cyan)
    (DashboardMruTitle :foreground cyan)
    (DashboardProjectTitle :foreground cyan)
    (DashboardFiles :foreground blue)
    ;; Footer: blue1 (#65bcff)
    (AlphaFooter :foreground blue1)
    (DashboardFooter :foreground blue1)
    ;; Special/Numbers (like startup time): purple (#fca7ea) - matches LazyVim
    (AlphaSpecial :foreground purple :weight 'bold)
    (DashboardSpecial :foreground purple :weight 'bold)

    ;;;; Markdown
    (markdown-header-face-1 :foreground blue :weight 'bold :background "#2c314a" :extend t)
    (markdown-header-face-2 :foreground yellow :weight 'bold :background "#38343d" :extend t)
    (markdown-header-face-3 :foreground green :weight 'bold :background "#32383f" :extend t)
    (markdown-header-face-4 :foreground teal :weight 'bold :background "#273644" :extend t)
    (markdown-header-face-5 :foreground magenta :weight 'bold)
    (markdown-header-face-6 :foreground purple :weight 'bold)
    (markdown-code-face :background "#2c314a" :foreground blue :extend t)
    (markdown-inline-code-face :background "#2c314a" :foreground blue)
    (markdown-link-face :foreground teal :underline t)
    (markdown-url-face :foreground cyan :underline t)
    (markdown-markup-face :foreground orange)

   ;;;; Rainbow-delimiters
   (rainbow-delimiters-depth-1-face :foreground blue)
   (rainbow-delimiters-depth-2-face :foreground yellow)
   (rainbow-delimiters-depth-3-face :foreground green)
   (rainbow-delimiters-depth-4-face :foreground teal)
   (rainbow-delimiters-depth-5-face :foreground magenta)
   (rainbow-delimiters-depth-6-face :foreground purple)
   (rainbow-delimiters-depth-7-face :foreground orange)
   (rainbow-delimiters-depth-8-face :foreground red)
   (rainbow-delimiters-depth-9-face :foreground cyan)

   ;;;; Highlight-indent-guides
   (highlight-indent-guides-character-face :foreground base4)
   (highlight-indent-guides-stack-character-face :foreground base4)
   (highlight-indent-guides-top-character-face :foreground blue1)

   ;;;; Git-gutter
   (git-gutter:added :foreground git-add)
   (git-gutter:deleted :foreground git-delete)
   (git-gutter:modified :foreground git-change)
   (git-gutter-fr:added :foreground git-add)
   (git-gutter-fr:deleted :foreground git-delete)
   (git-gutter-fr:modified :foreground git-change)

   ;;;; Diff-hl
   (diff-hl-insert :foreground git-add :background git-add)
   (diff-hl-delete :foreground git-delete :background git-delete)
   (diff-hl-change :foreground git-change :background git-change))

   ;;;; Base theme variable overrides
  ())

;;; doom-tokyonight-moon-theme.el ends here
