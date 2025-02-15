;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Stratos Staboulis"
      user-mail-address "stratos.staboulis@gmail.com")

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

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (load (concat doom-private-dir "color.el"))
(setq doom-theme '@theme@)

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
;;

;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<backtab>" . 'copilot-accept-completion)
              ;; ("TAB" . 'copilot-accept-completion)
              ;; ("C-TAB" . 'copilot-accept-completion-by-word)
              ;; Control + Shift + Tab
              ("C-<iso-lefttab>" . 'copilot-accept-completion-by-word)))


;;
;; gptel: A simple LLM client for Emacs
;;

(defun read-openai-api-key ()
  (with-temp-buffer
    (insert-file-contents "~/.gptel-api-key")
    (string-trim (buffer-string))))

(use-package! gptel
 :config
 (setq gptel-default-mode 'org-mode)
 (setq! gptel-api-key (read-openai-api-key)))

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
