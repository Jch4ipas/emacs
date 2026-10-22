;;; mk-evil.el --- Vim keybindings (evil profiles) -*- lexical-binding: t; -*-
;;; Commentary:
;; Loaded by the `evil' and `evil-minimal' profiles (see mk-profiles.el),
;; so every command used here exists in both mk-minimal and the complet modules.
;; The previous version of this file is in backups/config-avant-claude/.
;;
;; Leader key: SPC in normal/visual state
;;   SPC SPC  M-x                 SPC f f  find file       SPC f s  save
;;   SPC p f  project file        SPC p p  switch project  SPC /    search project
;;   SPC s s  search buffer       SPC b b  buffers         SPC b k  kill buffer
;;   SPC g g  magit               SPC e    file explorer   SPC '    terminal
;;   SPC c r  rename symbol       SPC c a  code actions    SPC c f  format
;;   SPC c e  problems panel      SPC w    windows (C-w)   SPC h    help
;;   SPC u    undo tree           SPC q q  quit Emacs      SPC P    profile
;; Plus: gc (comment), ys / cs / ds (surround), gd / gr (definition / refs).
;;; Code:

(declare-function evil-set-leader "evil")
(declare-function evil-define-key "evil")
(declare-function evil-collection-init "evil-collection")
(declare-function mk/toggle-flycheck-errors "mk-development")
(declare-function toggle-vterm "mk-term")

(use-package evil
  :demand t
  :preface
  ;; evil 1.15 reads this variable, which Emacs 31's globalized minor modes
  ;; no longer define (void-variable evil-mode-buffers otherwise)
  (defvar evil-mode-buffers nil)
  :init
  ;; Must be set before evil loads (evil-collection provides the bindings)
  (setq evil-want-keybinding nil
        evil-want-integration t)
  :custom
  (evil-want-C-u-scroll t)
  (evil-want-C-i-jump nil)              ; keep TAB for indentation in terminal
  (evil-want-Y-yank-to-eol t)
  (evil-undo-system 'undo-redo)        ; built in, works in every profile
  (evil-split-window-below t)
  (evil-vsplit-window-right t)
  (evil-respect-visual-line-mode t)
  (evil-search-module 'evil-search)
  (evil-symbol-word-search t)
  :config
  (evil-mode 1)
  (evil-set-leader '(normal visual motion) (kbd "SPC"))
  (dolist (binding
           `(("SPC" . execute-extended-command)
             ("f f" . find-file)
             ("f s" . save-buffer)
             ("f r" . consult-recent-file)
             ("p f" . project-find-file)
             ("p p" . project-switch-project)
             ("/"   . consult-ripgrep)
             ("s s" . consult-line)
             ("s i" . consult-imenu)
             ("b b" . consult-buffer)
             ("b k" . kill-current-buffer)
             ("b i" . ibuffer)
             ("g g" . magit-status)
             ("g b" . magit-blame)
             ("e"   . ,(lambda () (interactive)
                         (if (fboundp 'treemacs) (treemacs) (dired-jump))))
             ("'"   . toggle-vterm)
             ("c r" . eglot-rename)
             ("c a" . eglot-code-actions)
             ("c f" . mk/format-buffer)
             ("c e" . ,(lambda () (interactive)
                         (if (bound-and-true-p flycheck-mode)
                             (mk/toggle-flycheck-errors)
                           (flymake-show-buffer-diagnostics))))
             ("w"   . ,evil-window-map)
             ("h"   . help-command)
             ("u"   . ,(lambda () (interactive)
                         (if (fboundp 'vundo) (vundo) (undo-redo))))
             ("q q" . save-buffers-kill-terminal)
             ("P"   . mk/switch-profile)))
    (evil-define-key '(normal visual motion) 'global
      (kbd (concat "<leader> " (car binding))) (cdr binding)))
  ;; Keep the editor-wide shortcuts usable in insert state too
  (dolist (key '("C-." "s-M"))
    (evil-define-key '(normal insert visual motion) 'global (kbd key) nil)))

(use-package evil-collection
  :after evil
  :demand t
  :custom
  (evil-collection-setup-minibuffer nil) ; keep vertico's own keys
  :config
  (evil-collection-init))

(use-package evil-surround
  :after evil
  :demand t
  :config
  (global-evil-surround-mode 1))

(use-package evil-commentary
  :after evil
  :demand t
  :config
  (evil-commentary-mode 1))

;; Plain Emacs keys in buffers where Vim keys make no sense
(with-eval-after-load 'evil
  (dolist (mode '(vterm-mode eshell-mode welcome-dashboard-mode))
    (evil-set-initial-state mode 'emacs)))

(provide 'mk-evil)
;;; mk-evil.el ends here
