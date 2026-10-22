;;; mk-complet-edit.el --- Editing tools of the complet profile -*- lexical-binding: t; -*-
;;; Commentary:
;; Emacs keys are kept; a key is only added for what Emacs cannot do
;; out of the box.
;;
;;   C-c t        file explorer (treemacs)
;;   C-> / C-<    add a cursor on the next / previous occurrence
;;   C-c m        a cursor on every occurrence (C-S-c C-S-c: on each line)
;;   M-up/M-down  move the line or the region
;;   C-c d        duplicate the line or the region
;;   C-x u        undo tree (vundo)
;;   TAB          expand a snippet (yasnippet)
;;   C-h f/v/k    help with source and references (helpful)
;;
;; The files of the last session are reopened at startup (desktop).
;;; Code:

;;; File explorer
(use-package treemacs
  :defer t
  :bind ("C-c t" . treemacs)
  :custom
  (treemacs-width 35)
  (treemacs-follow-after-init t)
  (treemacs-project-follow-cleanup t)
  (treemacs-hide-dot-git-directory t)
  (treemacs-collapse-dirs 3)
  (treemacs-file-event-delay 1000)
  (treemacs-deferred-git-apply-delay 0.5)
  (treemacs-sorting 'treemacs--sort-alphabetic-case-insensitive-asc)
  :config
  (treemacs-project-follow-mode 1)      ; show the project of the current file
  (treemacs-filewatch-mode 1)
  (treemacs-git-mode 'deferred)
  (treemacs-hide-gitignored-files-mode 1))

(use-package treemacs-nerd-icons
  :after treemacs
  :config (treemacs-load-theme "nerd-icons"))

(use-package treemacs-magit
  :after (treemacs magit))

;;; Multiple cursors
(use-package multiple-cursors
  :unless (mk/module-p 'mk-evil)          ; does not work with evil
  :defer t
  :bind (("C->"         . mc/mark-next-like-this)
         ("C-<"         . mc/mark-previous-like-this)
         ("C-c m"       . mc/mark-all-dwim)
         ("C-S-c C-S-c" . mc/edit-lines)
         ("M-<mouse-1>" . mc/add-cursor-on-click))
  :init
  (keymap-global-unset "M-<down-mouse-1>")
  :custom
  (mc/list-file (expand-file-name "var/mc-lists.el" user-emacs-directory)))

;;; Snippets (TAB after "for", "if", "fn"...; M-x yas-describe-tables lists them)
(use-package yasnippet
  :hook ((prog-mode text-mode) . yas-minor-mode)
  :config
  (yas-reload-all))

(use-package yasnippet-snippets
  :after yasnippet)

;;; Lines
(use-package drag-stuff
  :defer t
  ;; Global keys: Org's own M-up / M-down (move a heading) still win in Org
  :bind (("M-<up>"   . drag-stuff-up)
         ("M-<down>" . drag-stuff-down)))

(keymap-global-set "C-c d" #'duplicate-dwim)   ; built in since Emacs 29
(setopt duplicate-line-final-position 1)       ; then go to the copy

;;; Undo tree and better help
(use-package vundo
  :defer t
  :bind ("C-x u" . vundo)
  :custom
  (vundo-glyph-alist vundo-unicode-symbols)
  (vundo-compact-display t))

(use-package helpful
  :defer t
  :bind (([remap describe-function] . helpful-callable)
         ([remap describe-variable] . helpful-variable)
         ([remap describe-key]      . helpful-key)
         ([remap describe-command]  . helpful-command)
         ([remap describe-symbol]   . helpful-symbol)))

;;; Reopen the files of the last session
(use-package desktop
  :ensure nil
  :custom
  (desktop-dirname (expand-file-name "var/" user-emacs-directory))
  (desktop-path (list (expand-file-name "var/" user-emacs-directory)))
  (desktop-restore-eager 5)             ; the rest is restored while idle
  (desktop-load-locked-desktop 'check-pid)
  (desktop-save t)
  (desktop-restore-frames nil)          ; keep the frame from early-init
  (desktop-auto-save-timeout 60)
  :config
  ;; The buffer tabs at the top are not wanted, never bring them back
  (add-to-list 'desktop-minor-mode-table '(tab-line-mode nil))
  (desktop-save-mode 1))

(provide 'mk-complet-edit)
;;; mk-complet-edit.el ends here
