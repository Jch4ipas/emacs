;;; mk-editing.el --- Editing configurations -*- lexical-binding: t; -*-

;;; Commentary:
;; This file contains configurations related to editing in Emacs.
;;; Code:

(require 'cl-lib)
(require 'project)

(use-package iedit
  :defer t
  :init
  (setq iedit-toggle-key-default nil)
  :config
  (define-key iedit-mode-keymap (kbd "C-<return>") #'iedit-toggle-selection)
  (define-key iedit-mode-keymap (kbd "C-j") #'iedit-next-occurrence)
  (define-key iedit-mode-keymap (kbd "C-k") #'iedit-prev-occurrence)
  (define-key iedit-mode-keymap (kbd "C-g") #'iedit-mode))

(use-package isearch
  :ensure nil
  :config
  (setq isearch-allow-scroll t
        isearch-lazy-count t)

  (defun mk/isearch-to-iedit ()
    "Exit isearch and start iedit with the current search string."
    (interactive)
    (require 'iedit)
    (let ((search-string isearch-string))
      (isearch-exit)
      (iedit-mode)))

  (defun mk/project-search-from-isearch ()
    "Search project with current isearch string using consult-ripgrep."
    (interactive)
    (let ((query (if isearch-regexp
                     isearch-string
                   (regexp-quote isearch-string))))
      (isearch-update-ring isearch-string isearch-regexp)
      (isearch-done t t)
      (consult-ripgrep (project-root (project-current)) query)))

  (defun mk/isearch-consult-line ()
    "Search buffer with current isearch string using consult-line."
    (interactive)
    (let ((query (if isearch-regexp
                     isearch-string
                   (regexp-quote isearch-string))))
      (isearch-update-ring isearch-string isearch-regexp)
      (isearch-done t t)
      (consult-line query)))

  (defun mk/isearch-with-region-or-thing ()
    "Use region or symbol at point as isearch text."
    (interactive)
    (let ((search-text
           (if (region-active-p)
               (buffer-substring-no-properties (region-beginning) (region-end))
             (thing-at-point 'symbol t))))
      (when search-text
        (deactivate-mark)
        (isearch-forward-regexp nil t)
        (setq isearch-case-fold-search nil)
        (setq isearch-string (format "\\<%s\\>" (regexp-quote search-text)))
        (setq isearch-message isearch-string)
        (isearch-search-and-update))))

  :bind
  (:map isearch-mode-map
        ("C-e" . mk/isearch-to-iedit)
        ("C-f" . mk/project-search-from-isearch)
        ("M-f" . mk/isearch-consult-line)
        ("C-d" . mk/isearch-with-region-or-thing)
        ("C-s" . isearch-repeat-forward)
        ("C-r" . isearch-repeat-backward)
        ("C-o" . isearch-occur)
        ("M-e" . isearch-edit-string)))

(use-package wgrep
  :defer t
  :config
  (setq wgrep-auto-save-buffer t))

(use-package rg
  :ensure t
  :defer t)

(use-package visual-replace
  :defer t
  :bind (("C-c r" . visual-replace)
         :map isearch-mode-map
         ("C-c r" . visual-replace-from-isearch)))

(use-package avy
  :defer t
  :bind
  ("M-g" . avy-goto-line)
  (:map isearch-mode-map
        ("C-a" . avy-isearch))
  :config
  (setq avy-single-candidate-jump t))

(use-package undo-fu
  :ensure t
  :bind (("s-z"   . undo-fu-only-undo)
         ("s-Z"   . undo-fu-only-redo)))

(use-package undo-fu-session
  :ensure t
  :config
  (undo-fu-session-global-mode))

(use-package ultra-scroll ; Smooth scrolling
  :ensure t
  :init
  (setq scroll-conservatively 101
        scroll-margin 0)
  :config
  (ultra-scroll-mode 1))

(provide 'mk-editing)
;;; mk-editing.el ends here
