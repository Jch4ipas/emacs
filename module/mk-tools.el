;;; mk-tools.el --- Standard tools most Emacs users have -*- lexical-binding: t; -*-
;;; Commentary:
;; helpful        : better *Help* buffers (source, references, callers)
;; vundo          : visual undo tree (C-x u)
;; multiple-cursors: VS Code style multi-cursor (s-d, s-L, M-click)
;; yasnippet      : snippets, also used by eglot for completion snippets
;; colorful-mode  : preview of colors (#ff0000, rgb(...)) in the buffer
;;; Code:

(use-package helpful
  :defer t
  :bind (([remap describe-function] . helpful-callable)
         ([remap describe-variable] . helpful-variable)
         ([remap describe-key]      . helpful-key)
         ([remap describe-command]  . helpful-command)
         ([remap describe-symbol]   . helpful-symbol)
         ("C-h ," . helpful-at-point)))

(use-package vundo
  :defer t
  :bind ("C-x u" . vundo)
  :custom
  (vundo-glyph-alist vundo-unicode-symbols)
  (vundo-compact-display t))

(use-package multiple-cursors
  :unless (mk/module-p 'mk-evil)          ; does not work well with evil
  :defer t
  :bind (("s-d"           . mc/mark-next-like-this)     ; like Cmd+D in VS Code
         ("s-D"           . mc/skip-to-next-like-this)
         ("s-L"           . mc/mark-all-like-this)      ; like Cmd+Shift+L
         ("C-S-c C-S-c"   . mc/edit-lines)
         ("M-<mouse-1>"   . mc/add-cursor-on-click))    ; like Option+click
  :init
  (global-unset-key (kbd "M-<down-mouse-1>"))
  :custom
  (mc/list-file (expand-file-name "var/mc-lists.el" user-emacs-directory)))

(use-package yasnippet
  :defer t
  :hook (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all))

(use-package yasnippet-snippets
  :after yasnippet)

(use-package colorful-mode
  :defer t
  :hook ((css-mode css-ts-mode html-ts-mode mhtml-mode) . colorful-mode))

(provide 'mk-tools)
;;; mk-tools.el ends here
