;;; markdown-beautify.el --- Description -*- lexical-binding: t; -*-

(after! markdown-mode

  (defun my/setup-markdown-faces ()
    "Setup markdown faces dynamically based on current theme colors"
    (let ((code-bg (doom-darken (doom-color 'bg) 0.15)))
      (custom-set-faces!
        `(markdown-header-delimiter-face :foreground "#616161" :height 0.9)
        `(markdown-header-face-1 :height 1.4 :foreground ,(doom-color 'green) :weight extra-bold)
        `(markdown-header-face-2 :height 1.3 :foreground ,(doom-color 'yellow) :weight extra-bold)
        `(markdown-header-face-3 :height 1.2 :foreground ,(doom-color 'orange) :weight extra-bold)
        `(markdown-header-face-4 :height 1.15 :foreground ,(doom-color 'red) :weight bold)
        `(markdown-header-face-5 :height 1.1 :foreground ,(doom-color 'magenta) :weight bold)
        `(markdown-header-face-6 :height 1.05 :foreground ,(doom-color 'blue) :weight semi-bold)
        `(markdown-code-face :background ,code-bg :extend t)
        `(markdown-inline-code-face :background ,code-bg))))

  (my/setup-markdown-faces)

  ;; Update faces on theme change
  (add-hook 'doom-load-theme-hook #'my/setup-markdown-faces)

  ;; Hide markup characters when not editing current line
  (defvar my/current-line '(0 . 0)
    "(start . end) of current line in current buffer")

  (make-variable-buffer-local 'my/current-line)

  (defun my/unhide-current-line (limit)
    "Font-lock function to show markup on current line"
    (let ((start (max (point) (car my/current-line)))
          (end (min limit (cdr my/current-line))))
      (when (< start end)
        (remove-text-properties start end
                                '(invisible t display "" composition ""))
        (goto-char limit)
        t)))

  (defun my/refontify-on-linemove ()
    "Post-command-hook to refontify when moving lines"
    (let* ((start (line-beginning-position))
           (end (line-beginning-position 2))
           (needs-update (not (equal start (car my/current-line)))))
      (setq my/current-line (cons start end))
      (when needs-update
        (font-lock-fontify-block 3))))

  (defun my/markdown-unhighlight ()
    "Enable markdown concealing with selective reveal on current line"
    (interactive)
    (markdown-toggle-markup-hiding 'toggle)
    (font-lock-add-keywords nil '((my/unhide-current-line)) t)
    (add-hook 'post-command-hook #'my/refontify-on-linemove nil t))

  (add-hook 'markdown-mode-hook #'my/markdown-unhighlight))
