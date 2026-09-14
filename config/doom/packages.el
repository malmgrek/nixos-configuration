;; packages.el -*- lexical-binding: t; -*-

;; GitHub Copilot
(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el" :files ("*.el")))

;; gptel
(package! gptel :recipe (:nonrecursive t))
(package! gptel-agent)

;; Ruff
(package! lazy-ruff
  :recipe (:host github :repo "christophermadsen/emacs-lazy-ruff" :files ("*.el")))

;; Icons
(package! nerd-icons)
