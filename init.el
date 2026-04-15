;;; Init.el --- optimized init file -*- no-byte-compile: t; lexical-binding: t; -*-

;;; Commentary:
;; Personal Emacs configuration with optimized startup and modern packages.
;; Features include Evil mode, LSP support, project management, and development tools.

;;; Code:

;; Suppress all warnings when loading packages

(setopt debug-on-error nil)
;; (load (expand-file-name "suppress-warnings" cser-emacs-directory) nil t)

(electric-indent-mode 0)
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; (package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'vterm)
  (package-install 'vterm))
(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(dolist (path (list
               (expand-file-name "module" user-emacs-directory)))
  (add-to-list 'load-path path))
(dolist (path (list
               (expand-file-name "dependance" user-emacs-directory)))
  (add-to-list 'load-path path))

(require 'mk-core)      ;; Optimisations de base
(require 'mk-theme)     ;; Tes thèmes (Oxocarbon, etc.)
(require 'mk-emacs)     ;; Nettoyage de l'interface (barres moches en moins)
(require 'mk-ui)        ;; La belle barre d'état en bas de l'écran
(require 'mk-completion)      ;; Les beaux menus de recherche modernes
(require 'mk-code-completion) ;; L'auto-complétion (menu déroulant dans le code)
(require 'mk-development)     ;; Les moteurs de code (LSP, Tree-sitter)
(require 'mk-editing)         ;; Outils pratiques (auto-fermeture des parenthèses)
(require 'mk-web)             ;; Mode React/TSX and other !
(require 'mk-term)      ;; Le terminal (vterm)
(require 'mk-vc)        ;; Magit (L'intégration Git)

;; (require 'mk-treemacs)  ;; L'explorateur de fichiers à gauche
;; (require 'mk-evil)               ;; Change complétement le fonctionnement de base de emacs et ressemble plus à vim
;; (require 'mk-misc)               ;;  Plein de problême si ta version de emacs n'est pas au moins de 30. C'est ici que se cachent les trucs bizarres comme "knockknock" !
;; (require 'mk-ai)                 ;; Fait souvent planter si tu n'as pas configuré de clé API ChatGPT/Copilot.
;; (require 'mk-ios-development)    ;; .
;; (require 'mk-haskell)            ;; (Langage spécifique).
;; (require 'mk-lisp)               ;; lisp.
;; (require 'mk-org)                ;; On enlève pour l'instant pour accélérer le démarrage.
;; (require 'mk-notifications)      ;; 
;; (require 'mk-elfeed)             ;; C'est un lecteur de flux RSS

;; Fix icons
(when (eq system-type 'darwin)
  (set-fontset-font t 'emoji (font-spec :family "Apple Color Emoji") nil 'prepend)
  (set-fontset-font t '(#xe000 . #xf8ff) "Symbols Nerd Font Mono")
  (set-fontset-font t '(#xf0000 . #xf1af0) "Symbols Nerd Font Mono"))
(setq nerd-icons-font-family "Symbols Nerd Font Mono")

(set-frame-parameter nil 'alpha-background 85)
(add-to-list 'default-frame-alist '(alpha-background . 85))
(set-face-attribute 'default nil :font "Menlo-14")
(add-to-list 'default-frame-alist '(font . "Menlo-14"))

;; Dashboard main page
(use-package welcome-dashboard
  :ensure nil
  :config
  (setq welcome-dashboard-latitude 46.52
        welcome-dashboard-longitude 6.56
        welcome-dashboard-use-nerd-icons t
        welcome-dashboard-max-number-of-projects 8
        welcome-dashboard-show-weather-info t
        welcome-dashboard-use-fahrenheit nil
        welcome-dashboard-min-left-padding 60        
        welcome-dashboard-max-number-of-todos 5
        welcome-dashboard-path-max-length 50
        welcome-dashboard-image-file "~/.emacs.d/themes/emacs.png"
        welcome-dashboard-image-width 200
        welcome-dashboard-image-height 200
        welcome-dashboard-title (concat "Welcome " user-full-name". Have a great day!"))
  
  (welcome-dashboard-create-welcome-hook))


(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(async auto-compile autothemer avy breadcrumb cape company-prescient
           corfu dape diff-hl doom-themes drag-stuff dumb-jump
           eldoc-box embark-consult evil exec-path-from-shell
           expand-region flycheck-eglot flycheck-package flyover
           git-timemachine highlight-symbol hl-todo iedit imenu-list
           indent-bars julia-vterm ligature magit marginalia
           markdown-ts-mode nerd-icons-completion nerd-icons-corfu
           nerd-icons-dired nerd-icons-ibuffer no-littering orderless
           rainbow-delimiters rg treesit-auto ultra-scroll undo-fu
           undo-fu-session vertico-posframe visual-replace
           vscode-dark-plus-theme wgrep which-key))
 '(package-vc-selected-packages
   '((ultra-scroll :url "https://github.com/jdtsmith/ultra-scroll"
                   :main-file "ultra-scroll.el" :branch "main"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(vertico-posframe-border ((t (:inherit vertico-posframe)))))
