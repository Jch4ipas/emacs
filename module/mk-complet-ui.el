;;; mk-complet-ui.el --- Look of the complet profile -*- lexical-binding: t; -*-
;;; Commentary:
;; Loaded after mk-minimal.el, whose look it replaces:
;;   - a transparent frame (the theme stays minimal's modus-vivendi)
;;   - welcome-dashboard at startup
;;   - doom-modeline
;;   - minibuffer menus in a floating frame (vertico-posframe)
;;   - icons in completion, dired and corfu
;;   - code helpers: colored parentheses, indent guides, breadcrumb,
;;     highlighting of the symbol at point
;;; Code:

;;; Transparency (the theme stays modus-vivendi, set by mk-minimal)
(set-frame-parameter nil 'alpha-background 85)
(add-to-list 'default-frame-alist '(alpha-background . 85))

;;; Icons (Symbols Nerd Font Mono must be installed)
(when (eq system-type 'darwin)
  (set-fontset-font t 'emoji (font-spec :family "Apple Color Emoji") nil 'prepend)
  (set-fontset-font t '(#xe000 . #xf8ff) "Symbols Nerd Font Mono")
  (set-fontset-font t '(#xf0000 . #xf1af0) "Symbols Nerd Font Mono"))

(use-package nerd-icons
  :defer t
  :custom (nerd-icons-font-family "Symbols Nerd Font Mono"))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode 1)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

;;; Dashboard
(use-package welcome-dashboard
  :ensure nil                           ; dependance/welcome-dashboard.el
  :demand t
  :custom
  (welcome-dashboard-latitude 46.52)    ; Lausanne
  (welcome-dashboard-longitude 6.56)
  (welcome-dashboard-use-nerd-icons t)
  (welcome-dashboard-max-number-of-projects 8)
  (welcome-dashboard-show-weather-info t)
  (welcome-dashboard-use-fahrenheit nil)
  (welcome-dashboard-min-left-padding 60)
  (welcome-dashboard-max-number-of-todos 5)
  (welcome-dashboard-path-max-length 50)
  (welcome-dashboard-image-file (expand-file-name "themes/emacs.png" user-emacs-directory))
  (welcome-dashboard-image-width 200)
  (welcome-dashboard-image-height 200)
  (welcome-dashboard-title (concat "Welcome " user-full-name ". Have a great day!"))
  :config
  (welcome-dashboard-create-welcome-hook))

;;; Mode line
(use-package doom-modeline
  :demand t
  :custom
  (doom-modeline-height 26)
  (doom-modeline-bar-width 4)
  (doom-modeline-buffer-file-name-style 'relative-to-project)
  (doom-modeline-buffer-encoding nil)   ; only shown when it is not UTF-8/LF
  (doom-modeline-check-simple-format t)
  :config
  (doom-modeline-mode 1))

;;; Minibuffer in a floating frame (searches with a preview stay at the bottom)
(use-package vertico-posframe
  :after vertico
  :custom
  (vertico-posframe-poshandler #'posframe-poshandler-frame-center)
  (vertico-posframe-min-width 120)
  (vertico-posframe-border-width 20)
  (vertico-posframe-parameters '((alpha . 1.0)))
  (vertico-multiform-commands
   '((consult-line (:not posframe))
     (consult-ripgrep (:not posframe))
     (consult-imenu (:not posframe))
     (consult-xref (:not posframe))
     (consult-flymake (:not posframe))
     (consult-eglot-symbols (:not posframe))
     (xref-find-references (:not posframe))
     (t posframe)))
  :config
  (vertico-multiform-mode 1))

;;; Code helpers
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package indent-bars
  :hook ((prog-mode yaml-ts-mode) . indent-bars-mode)
  :custom
  (indent-bars-treesit-support t)
  (indent-bars-width-frac 0.15))

(use-package breadcrumb
  :hook (prog-mode . breadcrumb-local-mode)) ; file > class > function at the top

(use-package highlight-symbol
  :hook (prog-mode . highlight-symbol-mode)
  :custom (highlight-symbol-idle-delay 0.5))

(provide 'mk-complet-ui)
;;; mk-complet-ui.el ends here
