;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Quit Emacs without asking for confirmation
(setq confirm-kill-emacs nil)

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Stratos Staboulis"
      user-mail-address "stratos.staboulis@gmail.com")  ;; FIXME: Should be secret

;; Fonts
(setq doom-font @font@)

;; Add custom themes directory to load path
(add-to-list 'custom-theme-load-path
             (expand-file-name "my/themes" doom-user-dir))

;; Theme
(setq doom-theme '@theme@)

;; Markdown beautification
(load! "my/markdown-beautify")

;; Org setup
(setq org-directory "~/Documents/org/"
      org-journal-file (concat org-directory "journal.org"))
(after! org
  (add-to-list 'org-capture-templates
               '("J" "Custom journal" entry (file+olp+datetree org-journal-file)
                 "* %<%H:%M> %?\n")))

;; For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;;
;; Set 2-space indentation for web
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;
(setq-default
 ;; JavaScript
 js-indent-level 2                    ; built-in js-mode
 js2-basic-offset 2                   ; js2-mode (Doom default for JS)
 js3-indent-level 2                   ; js3-mode
 ;; TypeScript
 typescript-indent-level 2            ; typescript-mode
 typescript-ts-mode-indent-offset 2   ; tree-sitter TypeScript
 ;; Web mode (HTML/JS/CSS in one)
 web-mode-markup-indent-offset 2      ; HTML indentation
 web-mode-css-indent-offset 2         ; CSS indentation in <style>
 web-mode-code-indent-offset 2        ; JS indentation in <script>
 web-mode-attr-indent-offset 2        ; HTML attribute indentation
 web-mode-attr-value-indent-offset 2  ; HTML attribute value indentation
 ;; HTML
 sgml-basic-offset 2                  ; built-in SGML/HTML mode
 ;; CSS/SCSS/SASS
 css-indent-offset 2                  ; CSS
 scss-indent-offset 2                 ; SCSS
 sass-indent-offset 2                 ; SASS
 ;; JSON
 js-json-indent-level 2)              ; JSON files (uses js-mode)


;;
;; AI settings
;; ~~~~~~~~~~~
;;

(defun my/read-openai-api-key ()
  (with-temp-buffer
    (insert-file-contents "~/.openai-api-key")
    (string-trim (buffer-string))))

;; GPTel
(use-package! gptel
  :config
  (setq gptel-default-mode 'markdown-mode
        gptel-use-tools t
        gptel-api-key (my/read-openai-api-key)
        gptel-model 'claude-haiku-4.5
        gptel-backend (gptel-make-gh-copilot "Copilot"))
  (gptel-make-ollama "Ollama"
    :host "localhost:11434"
    :stream t
    :models '(qwen2.5-coder:3b deepseek-coder-v2:16b))
  )

(use-package! gptel-agent  ;; Agentic features for gptel
  :config
  (gptel-agent-update))  ;Read files from agents directories

;; Github Copilot completion
;; NOTE: Requires `copilot-language-server` to be installed on system
(use-package! copilot
  :hook ((prog-mode
          markdown-mode
          org-mode
          text-mode) . copilot-mode)
  :bind (:map copilot-completion-map
              ("<backtab>" . 'copilot-accept-completion)
              ("C-<iso-lefttab>" . 'copilot-accept-completion-by-word)
              ("C-n" . 'copilot-next-completion)
              ("C-p" . 'copilot-previous-completion))
  :config
  ;; Disable company-mode auto-completion in text modes (prevent fallback)
  (add-to-list 'copilot-indentation-alist '(org-mode 2))
  (add-to-list 'copilot-indentation-alist '(markdown-mode 2))
  (add-to-list 'copilot-indentation-alist '(text-mode 2))
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2)))

;;
;; Nerd trees
;; ~~~~~~~~~~
;;

(after! treemacs
  ;; Reduce icon size for compact LazyVim-style appearance
  (setq treemacs-nerd-icons-icon-size 0.8)
  ;; Set treemacs window width
  (setq treemacs-width 40))

(after! neotree
  (setq neo-theme (if (display-graphic-p) 'nerd-icons)))

;;
;; LSP mode customizations
;; ~~~~~~~~~~~~~~~~~~~~~~~

(load! "my/lsp-booster")

(use-package! lazy-ruff
  ;; Enable automatic ruff formatting on save in Python buffers
  ;; :hook (python-mode . lazy-ruff-mode)
  ;; Don't lint, only format
  :config
  (setq lazy-ruff-only-format-block t
        lazy-ruff-only-format-region t
        lazy-ruff-only-format-buffer t))

(after! lsp-pyright
  (setq lsp-pyright-type-checking-mode "strict"
        ;; Override specific rules to be warnings instead of errors
        lsp-pyright-diagnostic-severity-overrides
        '(("reportDeprecated" . "warning")
          ("reportMissingTypeStubs" . "warning")
          ("reportMissingParameterType" . "warning")
          ("reportUnknownMemberType" . "warning")
          ("reportUnknownParameterType" . "warning")
          ("reportUnknownArgumentType" . "warning")
          ("reportUnknownVariableType" . "warning"))))

(after! lsp-ui
  (setq lsp-ui-sideline-enable t
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-code-actions nil
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-ignore-duplicate t
        lsp-ui-sideline-delay 0.5
        lsp-ui-sideline-update-mode 'line))
