;;; mk-core.el --- Core settings -*- lexical-binding: t; no-byte-compile: t; mode: emacs-lisp; coding:utf-8; fill-column: 80 -*-
;;; Commentary:
;; Load paths, icons and other core settings of the complet profile.
;; Packages and the shell PATH are set up in mk-base.el.

;;; Code:
(eval-when-compile
  (defvar display-time-24hr-format t)
  (defvar display-time-default-load-average nil))

(use-package async
  :defer t)

(dolist (path (list
               (expand-file-name "localpackages/kanagawa-emacs" user-emacs-directory)
               (expand-file-name "localpackages/mito-laser-emacs" user-emacs-directory)
               (expand-file-name "localpackages/neofusion-emacs" user-emacs-directory)))
  (add-to-list 'custom-theme-load-path path))

;; Add local packages directory to load-path
(let ((dir (expand-file-name "localpackages" user-emacs-directory)))
  (when (file-directory-p dir)
    (add-to-list 'load-path dir)
    (let ((default-directory dir))
      (normal-top-level-add-subdirs-to-load-path))))

(global-unset-key (kbd "C-<wheel-up>"))
(global-unset-key (kbd "C-<wheel-down>"))
(global-set-key (kbd "M-w") 'ns-do-hide-emacs)

;; Emoji font fallback
(set-fontset-font t 'unicode (font-spec :family "Apple Color Emoji") nil 'append)

(use-package auto-compile
  :defer 1
  :custom
  (auto-compile-display-buffer nil)
  (auto-compile-mode-line-counter nil)
  (auto-compile-use-mode-line nil)
  (auto-compile-update-autoloads t)
  :config
  (auto-compile-on-load-mode)
  (auto-compile-on-save-mode))

(use-package nerd-icons
  :demand t)

(use-package posframe
  :demand t)

(provide 'mk-core)
;;; mk-core.el ends here
