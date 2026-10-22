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
;;   C-x b / C-TAB  buffers (preview)    M-s l  search buffer M-g i  symbols in file
;;   F12 / S-F12 / M-F12  definition / references / back
;;   F2  rename   M-F  format   M-n / M-p  next / previous error   s-M  errors
;;   C-.  actions on thing at point (embark)   M-j  jump anywhere (avy)
;;   s-z / s-Z  undo / redo   s-/  comment   s-w  close buffer   C-`  terminal
;;   C-x g  magit
;;   TAB / S-TAB  indent / unindent (the line, or every line of the region)
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
        tab-always-indent t                  ; never complete: see mk/tab-mode
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
         ("C-<tab>" . consult-buffer)     ; like Ctrl+Tab in VS Code (not in Org)
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
  :bind (:map corfu-map
              ;; TAB accepts the first proposal, like other editors (RET
              ;; still needs C-n first, so RET at end of line stays RET)
              ("TAB" . mk/corfu-accept)
              ("<tab>" . mk/corfu-accept))
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

;;; TAB and S-TAB like other editors
;; In code buffers TAB inserts spaces up to the next indentation step at
;; the cursor (or a real tab where the mode uses tabs, like Go or
;; Makefiles), S-TAB removes one step, and both shift every line of the
;; region while keeping it selected.  RET still indents new lines the
;; way the mode wants, and C-M-i opens the completion menu by hand.
(defconst mk/indent-offset-variables
  '((python-base-mode . python-indent-offset)
    (typescript-ts-base-mode . typescript-ts-mode-indent-offset)
    (js-base-mode . js-indent-level)
    (json-ts-mode . json-ts-mode-indent-offset)
    (css-base-mode . css-indent-offset)
    (html-ts-mode . html-ts-mode-indent-offset)
    (web-mode . web-mode-code-indent-offset)
    (php-ts-mode . php-ts-mode-indent-offset)
    (csharp-ts-mode . csharp-ts-mode-indent-offset)
    (sh-base-mode . sh-basic-offset)
    (c-ts-base-mode . c-ts-mode-indent-offset)
    (go-ts-mode . go-ts-mode-indent-offset)
    (java-ts-mode . java-ts-mode-indent-offset)
    (rust-ts-mode . rust-ts-mode-indent-offset)
    (lua-ts-mode . lua-ts-indent-offset)
    (ruby-base-mode . ruby-indent-level)
    (toml-ts-mode . toml-ts-mode-indent-offset)
    (yaml-ts-mode . 2))
  "Indentation step of each major mode: a variable or a number.")

(defun mk/indent-offset ()
  "Return the indentation step of the current buffer, in columns."
  (let* ((entry (seq-find (lambda (e) (derived-mode-p (car e))) mk/indent-offset-variables))
         (value (and entry (if (symbolp (cdr entry))
                               (and (boundp (cdr entry)) (symbol-value (cdr entry)))
                             (cdr entry)))))
    (if (and (integerp value) (> value 0)) value tab-width)))

(defun mk/region-lines ()
  "Return (FIRST . LAST): the start of the first and last lines of the region.
A region ending at the start of a line does not include that line."
  (let ((beg (region-beginning))
        (end (region-end)))
    (save-excursion
      (goto-char end)
      (when (and (bolp) (> end beg)) (forward-line -1))
      (cons (save-excursion (goto-char beg) (line-beginning-position))
            (line-beginning-position)))))

(defun mk/unindented-column (column offset)
  "COLUMN moved back to the previous multiple of OFFSET."
  (max 0 (if (zerop (% column offset)) (- column offset) (* offset (/ column offset)))))

(defun mk/shift-lines (direction)
  "Indent (DIRECTION 1) or unindent (-1) the lines of the region by one step."
  (let ((offset (mk/indent-offset))
        (lines (mk/region-lines))
        (mark (copy-marker (mark)))
        (point (point-marker)))
    (save-excursion
      (goto-char (car lines))
      (dotimes (_ (1+ (count-lines (car lines) (cdr lines))))
        (unless (looking-at-p "[ \t]*$")   ; leave empty lines empty
          (let ((column (current-indentation)))
            (indent-line-to (if (> direction 0)
                                (+ column offset)
                              (mk/unindented-column column offset)))))
        (forward-line 1)))
    (set-mark mark)
    (goto-char point)
    (setq deactivate-mark nil)))

(defun mk/tab ()
  "Expand a snippet, shift the region, or insert one indentation step."
  (interactive)
  (cond
   ((and (bound-and-true-p yas-minor-mode)
         (let ((yas-fallback-behavior 'return-nil)) (yas-expand))))
   ((use-region-p) (mk/shift-lines 1))
   (indent-tabs-mode (insert "\t"))
   (t (let ((offset (mk/indent-offset)))
        (insert (make-string (- offset (% (current-column) offset)) ?\s))))))

(defun mk/backtab ()
  "Remove one indentation step from the line, or from each line of the region."
  (interactive)
  (if (use-region-p)
      (mk/shift-lines -1)
    (let ((in-indentation (<= (current-column) (current-indentation)))
          (from-end (- (line-end-position) (point))))
      (indent-line-to (mk/unindented-column (current-indentation) (mk/indent-offset)))
      (if in-indentation
          (back-to-indentation)
        (goto-char (- (line-end-position) from-end))))))

(defun mk/corfu-accept ()
  "Insert the selected completion, or the first one when none is selected."
  (interactive)
  (when (< corfu--index 0) (corfu-next))
  (corfu-insert))

(defvar-keymap mk/tab-mode-map
  "TAB" #'mk/tab
  "<tab>" #'mk/tab
  "<backtab>" #'mk/backtab)

(define-minor-mode mk/tab-mode
  "TAB and S-TAB indent and unindent like other editors."
  :keymap mk/tab-mode-map)

(defun mk/tab-mode-maybe ()
  "Turn on `mk/tab-mode', except in Lisp, where TAB indents by structure."
  (unless (derived-mode-p 'lisp-data-mode)
    (mk/tab-mode 1)))

(dolist (hook '(prog-mode-hook yaml-ts-mode-hook conf-mode-hook))
  (add-hook hook #'mk/tab-mode-maybe))

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
