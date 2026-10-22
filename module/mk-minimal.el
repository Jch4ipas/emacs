;;; mk-minimal.el --- Minimal professional configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; A standalone config (it does not reuse the complet modules), built the way
;; the reference minimal configs are (Emacs Bedrock, minimal-emacs.d, Emacs
;; Solo): use what Emacs 31 already ships, add only the few packages that
;; nearly every professional config has.
;;
;; Built in : eglot (LSP, see mk-lsp.el), flymake (errors), tree-sitter with
;;            automatic grammars, project.el, xref, dired, which-key,
;;            editorconfig, savehist / recentf / save-place, modus themes
;; Packages : vertico + orderless + marginalia + consult + embark (minibuffer)
;;            corfu + cape (completion popup in the code)
;;            magit + diff-hl (git), avy (jump), wgrep (edit search results),
;;            vterm (terminal)
;;
;; Keys (Emacs defaults are kept; s- = Cmd, M- = Option):
;;   s-p  find file in project   s-P  M-x            s-F  search in project
;;   C-x b / S-TAB  buffers (preview)    M-s l  search buffer M-g i  symbols in file
;;   F12 / S-F12 / M-F12  definition / references / back
;;   F2  rename   M-F  format   M-n / M-p  next / previous error   s-M  errors
;;   C-.  actions on thing at point (embark)   M-j  jump anywhere (avy)
;;   s-z / s-Z  undo / redo   s-/  comment   s-w  close buffer   C-`  terminal
;;   C-x g  magit
;;; Code:

;;; Sane defaults
(setopt use-short-answers t
        ring-bell-function #'ignore
        use-dialog-box nil
        confirm-kill-processes nil
        create-lockfiles nil
        make-backup-files t
        backup-by-copying t
        delete-old-versions t
        backup-directory-alist `(("." . ,(expand-file-name "backups" user-emacs-directory)))
        auto-save-file-name-transforms
        `((".*" ,(expand-file-name "auto-save-list/" user-emacs-directory) t))
        require-final-newline t
        sentence-end-double-space nil
        kill-do-not-save-duplicates t
        save-interprogram-paste-before-kill t
        indent-tabs-mode nil
        tab-width 4
        tab-always-indent 'complete          ; TAB indents, then completes
        scroll-conservatively 101            ; never recenter while scrolling
        scroll-margin 2
        mouse-wheel-tilt-scroll t
        window-combination-resize t
        help-window-select t
        enable-recursive-minibuffers t
        xref-search-program 'ripgrep
        switch-to-buffer-obey-display-actions t)

(when (eq system-type 'darwin)
  (setq mac-command-modifier 'super ns-command-modifier 'super
        mac-option-modifier 'meta ns-option-modifier 'meta
        ;; Right Option stays a normal key for [ ] { } | ~ ...
        mac-right-option-modifier 'none ns-right-option-modifier 'none))

;;; Built-in modes
(savehist-mode 1)
(recentf-mode 1)
(save-place-mode 1)
(global-auto-revert-mode 1)
(delete-selection-mode 1)
(column-number-mode 1)
(which-key-mode 1)
(repeat-mode 1)
(editorconfig-mode 1)
(pixel-scroll-precision-mode 1)
(setopt recentf-max-saved-items 300
        auto-revert-avoid-polling t
        global-auto-revert-non-file-buffers t)

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'electric-pair-local-mode)
(add-hook 'prog-mode-hook #'hl-line-mode)

;;; Look: standard mode line, built-in modus theme
(setq-default mode-line-format mk/default-mode-line-format)
(load-theme 'modus-vivendi t)

;;; Tree-sitter: every *-ts-mode, grammars installed on demand (Emacs 31)
(setopt treesit-enabled-modes t
        treesit-auto-install-grammar 'ask
        treesit-font-lock-level 4)
(add-to-list 'auto-mode-alist '("\\.[cm]?jsx\\'" . tsx-ts-mode))
;; Built into Emacs 31 but neither autoloaded nor associated with .md
(autoload 'markdown-ts-mode "markdown-ts-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-ts-mode))

;;; Minibuffer completion: vertico, orderless, marginalia, consult, embark
(use-package vertico
  :demand t
  :custom
  (vertico-cycle t)
  (vertico-count 15)
  :config
  (vertico-mode 1))

(use-package vertico-directory
  :ensure nil                           ; ships with vertico
  :after vertico
  :bind (:map vertico-map
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package orderless
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion))))
  (completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  (read-file-name-completion-ignore-case t))

(use-package marginalia
  :demand t
  :config
  (marginalia-mode 1))

(use-package consult
  :defer t
  :bind (("C-x b"   . consult-buffer)
         ("<backtab>" . consult-buffer)   ; S-TAB, quicker to reach (not in Org)
         ("C-x p b" . consult-project-buffer)
         ("M-y"     . consult-yank-pop)
         ("M-g g"   . consult-goto-line)
         ("M-g i"   . consult-imenu)
         ("M-g e"   . consult-flymake)
         ("M-s l"   . consult-line)
         ("M-s r"   . consult-ripgrep)
         ("s-F"     . consult-ripgrep))
  :init
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :custom
  (consult-narrow-key "<")             ; C-x b then "< b" = only buffers, "< f" = files
  :config
  (consult-customize consult-ripgrep consult-buffer consult-xref
                     :preview-key '(:debounce 0.3 any)))

(use-package embark
  :defer t
  :bind (("C-." . embark-act)
         ("C-h B" . embark-bindings)))

(use-package embark-consult
  :after (embark consult))

(use-package wgrep
  :defer t
  :custom (wgrep-auto-save-buffer t))

;;; Completion popup in the code: corfu + cape
(use-package corfu
  :demand t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  :config
  (global-corfu-mode 1)
  (corfu-history-mode 1)
  (corfu-popupinfo-mode 1)              ; documentation next to the popup
  (add-to-list 'savehist-additional-variables 'corfu-history))

(use-package cape
  :demand t
  :config
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev 90))

;;; Code: diagnostics, navigation, formatting (eglot itself is in mk-lsp.el)
(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode)
  :bind (:map flymake-mode-map
              ("M-n" . flymake-goto-next-error)
              ("M-p" . flymake-goto-prev-error)
              ("s-M" . flymake-show-buffer-diagnostics))
  :custom
  (flymake-no-changes-timeout 0.5)
  (flymake-fringe-indicator-position 'left-fringe))

(defun mk/format-buffer ()
  "Format the buffer with the language server, or re-indent it."
  (interactive)
  (if (and (fboundp 'eglot-managed-p) (eglot-managed-p))
      (eglot-format-buffer)
    (save-excursion (indent-region (point-min) (point-max)))))

(with-eval-after-load 'eglot
  (keymap-set eglot-mode-map "<f2>" #'eglot-rename))

(keymap-global-set "<f12>" #'xref-find-definitions)
(keymap-global-set "S-<f12>" #'xref-find-references)
(keymap-global-set "M-<f12>" #'xref-go-back)
(keymap-global-set "M-F" #'mk/format-buffer)

(use-package avy
  :defer t
  :bind ("M-j" . avy-goto-char-timer))

;;; Compilation / tests (C-x p c): colors, scroll to the first error
(use-package compile
  :ensure nil
  :defer t
  :custom
  (compilation-scroll-output 'first-error)
  (compilation-ask-about-save nil)
  (compilation-max-output-line-length nil)
  :config
  (add-hook 'compilation-filter-hook #'ansi-color-compilation-filter))

;;; Git
(use-package magit
  :defer t
  :bind ("C-x g" . magit-status)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package diff-hl
  :demand t
  :hook ((dired-mode . diff-hl-dired-mode)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :custom (diff-hl-disable-on-remote t)
  :config
  (global-diff-hl-mode 1))

;;; Files
(use-package dired
  :ensure nil
  :defer t
  :custom
  (dired-listing-switches "-alh --group-directories-first")
  (dired-dwim-target t)                 ; copy/move to the other dired window
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-auto-revert-buffer t)
  (delete-by-moving-to-trash t)
  :config
  (when (executable-find "gls")
    (setq insert-directory-program "gls")))

;;; Terminal
(use-package vterm
  :defer t
  :commands vterm
  :custom (vterm-kill-buffer-on-exit t))

(defun toggle-vterm ()
  "Show or hide the terminal."
  (interactive)
  (let ((buffer (get-buffer "*vterm*")))
    (cond ((and buffer (eq buffer (current-buffer))) (delete-window))
          (buffer (switch-to-buffer-other-window buffer))
          (t (vterm-other-window)))))

;;; macOS style keys (just bindings to built-in commands)
(keymap-global-set "s-p" #'project-find-file)
(keymap-global-set "s-P" #'execute-extended-command)
(keymap-global-set "s-z" #'undo)
(keymap-global-set "s-Z" #'undo-redo)
(keymap-global-set "s-/" #'comment-line)
(keymap-global-set "s-w" #'kill-current-buffer)
(keymap-global-set "C-`" #'toggle-vterm)

(provide 'mk-minimal)
;;; mk-minimal.el ends here
