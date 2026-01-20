;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Stratos Staboulis"
      user-mail-address "stratos.staboulis@gmail.com")  ;; FIXME: Should be secret

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font @font@)

;; Add custom themes directory to load path
(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" doom-user-dir))

;; TokyoNight Moon theme customization options (set before loading theme)
;; Uncomment and adjust these to customize the theme:
;; FIXME: Are these used? Move to under theme
;; (setq doom-tokyonight-moon-brighter-comments t)    ; Brighter purple comments
;; (setq doom-tokyonight-moon-brighter-modeline t)    ; Vivid blue modeline
;; (setq doom-tokyonight-moon-padded-modeline 4)      ; Add 4px padding to modeline
;; (setq doom-tokyonight-moon-transparent-background nil) ; Enable transparency

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (load (concat doom-private-dir "color.el"))
;; (setq doom-theme '@theme@)

;; To use TokyoNight Moon theme, uncomment the line below and comment out the line above:
(setq doom-theme 'doom-tokyonight-moon)

;; Enable tree-sitter mode for Python (for enhanced multicolor syntax highlighting)
(after! python
  ;; Use python-ts-mode instead of python-mode for tree-sitter support
  (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode)))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Documents/org/"
      org-journal-file (concat org-directory "journal.org"))
(after! org
  (add-to-list 'org-capture-templates
               '("J" "Custom journal" entry (file+olp+datetree org-journal-file)
                 "* %<%H:%M> %?\n")))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Quit Emacs without asking for confirmation
(setq confirm-kill-emacs nil)

;; Use complicated fonts with neotree
;; Requires running `all-the-icons-install-fonts'
(after! neotree
  (setq doom-themes-neotree-file-icons t))

;; JS offset
(after! javascript
  (setq js2-basic-offset 2))

;; TS offset
(after! typescript-tsx-mode
  (setq typescript-indent-level 2))

;; HTML offset
(after! web-mode
  (setq web-mode-markup-indent-offset 2))

;; CSS offset
(after! css-mode
  (setq css-indent-offset 2))


;;
;; Github Copilot
;; NOTE: Need to `npm install @github/copilot-language-server` in project
;;

;; Accept completion from copilot in both code and text/markup modes
(use-package! copilot
  :hook ((prog-mode
          markdown-mode
          org-mode
          text-mode) . copilot-mode)
  :bind (:map copilot-completion-map
              ("<backtab>" . 'copilot-accept-completion)
              ;; ("TAB" . 'copilot-accept-completion)
              ;; ("C-TAB" . 'copilot-accept-completion-by-word)
              ;; Control + Shift + Tab
              ("C-<iso-lefttab>" . 'copilot-accept-completion-by-word))
  :config
  ;; Disable company-mode auto-completion in text modes (prevent fallback)
  (dolist (mode '(markdown-mode org-mode text-mode))
    (add-hook (intern (format "%s-hook" (symbol-name mode)))
              (lambda () (setq-local company-idle-delay nil)))))


;;
;; gptel: A simple LLM client for Emacs
;;

(defun read-openai-api-key ()
  (with-temp-buffer
    (insert-file-contents "~/.openai-api-key")
    (string-trim (buffer-string))))

(use-package! gptel
 :config
 (setq gptel-default-mode 'org-mode
       gptel-api-key (read-openai-api-key)
       gptel-model 'claude-sonnet-4
       gptel-backend (gptel-make-gh-copilot "Copilot"))
 (gptel-make-ollama "Ollama"
   :host "localhost:11434"
   :stream t
   :models '(qwen2.5-coder:3b deepseek-coder-v2:16b))
 )

;;
;; Python formatter ruff
;;
(use-package! lazy-ruff
  ;; Enable automatic ruff formatting on save in Python buffers
  ;; :hook (python-mode . lazy-ruff-mode)
  ;; Don't lint, only format
  :config
  (setq lazy-ruff-only-format-block t)
  (setq lazy-ruff-only-format-region t)
  (setq lazy-ruff-only-format-buffer t))

;;
;; Dashboard customization - LazyVim TokyoNight Moon style
;;
;; Override dashboard menu sections to use custom icon face (blue1 instead of purple)
;; This separates icon colors (blue1) from menu text colors (cyan)
(after! doom-dashboard
  (setq +doom-dashboard-menu-sections
        '(("Recently opened files"
           :icon (nerd-icons-faicon "nf-fa-file_text" :face 'doom-dashboard-menu-icon)
           :action recentf-open-files)
          ("Reload last session"
           :icon (nerd-icons-octicon "nf-oct-history" :face 'doom-dashboard-menu-icon)
           :when (cond ((modulep! :ui workspaces)
                        (file-exists-p (expand-file-name persp-auto-save-fname persp-save-dir)))
                       ((require 'desktop nil t)
                        (file-exists-p (desktop-full-file-name))))
           :action doom/quickload-session)
          ("Open org-agenda"
           :icon (nerd-icons-octicon "nf-oct-calendar" :face 'doom-dashboard-menu-icon)
           :when (fboundp 'org-agenda)
           :action org-agenda)
          ("Open project"
           :icon (nerd-icons-octicon "nf-oct-briefcase" :face 'doom-dashboard-menu-icon)
           :action projectile-switch-project)
          ("Jump to bookmark"
           :icon (nerd-icons-octicon "nf-oct-bookmark" :face 'doom-dashboard-menu-icon)
           :action bookmark-jump)
          ("Open private configuration"
           :icon (nerd-icons-octicon "nf-oct-tools" :face 'doom-dashboard-menu-icon)
           :when (file-directory-p doom-user-dir)
           :action doom/open-private-config)
           ("Open documentation"
            :icon (nerd-icons-octicon "nf-oct-book" :face 'doom-dashboard-menu-icon)
            :action doom/help))))

;;
;; Treemacs customization - LazyVim Neo-Tree style
;;
(after! treemacs
  ;; Reduce icon size for compact LazyVim-style appearance
  (setq treemacs-nerd-icons-icon-size 0.8)

  ;; Set treemacs window width
  (setq treemacs-width 40))

;; Darken minibuffer background to match sidebar aesthetic
(add-hook 'minibuffer-setup-hook
          (lambda ()
            (face-remap-add-relative 'default :background "#181924")))

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.
