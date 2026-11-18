;; packages.el -*- lexical-binding: t; -*-

;; GitHub Copilot (opt-in per buffer, see config.el)
(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el" :files ("*.el")))

;; gptel
(package! gptel :recipe (:nonrecursive t))

;; Ruff
(package! lazy-ruff
  :recipe (:host github :repo "christophermadsen/emacs-lazy-ruff" :files ("*.el")))

;; Icons
(package! nerd-icons)
