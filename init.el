;;; Init.el --- optimized init file -*- no-byte-compile: t; lexical-binding: t; -*-

;;; Commentary:
;; Personal Emacs configuration with optimized startup and modern packages.
;; Features include Evil mode, LSP support, project management, and development tools.

;;; Code:

;; Keep Custom's auto-generated code out of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror 'nomessage)

(setopt debug-on-error nil)
;; (load (expand-file-name "suppress-warnings" cser-emacs-directory) nil t)

(electric-indent-mode 0)
(dolist (dir '("module" "dependance"))
  (add-to-list 'load-path (expand-file-name dir user-emacs-directory)))

(require 'mk-base)      ;; Paquets et PATH du shell (partagé)
(require 'mk-core)      ;; Optimisations de base
(require 'mk-theme)     ;; Tes thèmes (Oxocarbon, etc.)
(require 'mk-emacs)     ;; Nettoyage de l'interface (barres moches en moins)
(require 'mk-ui)        ;; La belle barre d'état en bas de l'écran
(require 'mk-completion)      ;; Les beaux menus de recherche modernes
(require 'mk-code-completion) ;; L'auto-complétion (menu déroulant dans le code)
(require 'mk-development)     ;; Les moteurs de code (LSP, Tree-sitter)
(require 'mk-lsp)             ;; Serveurs de langage (eglot)
(require 'mk-editing)         ;; Outils pratiques (auto-fermeture des parenthèses)
(require 'mk-web)             ;; Mode React/TSX and other !
(require 'mk-term)      ;; Le terminal (vterm)
(require 'mk-vc)        ;; Magit (L'intégration Git)
(require 'mk-tools)     ;; Outils standards (helpful, vundo, snippets...)

(require 'mk-treemacs)  ;; L'explorateur de fichiers à gauche
(require 'mk-ide)       ;; Touches et fonctions de VS Code
;; (require 'mk-evil)               ;; Change complétement le fonctionnement de base de emacs et ressemble plus à vim
;; (require 'mk-misc)               ;;  Plein de problême si ta version de emacs n'est pas au moins de 30. C'est ici que se cachent les trucs bizarres comme "knockknock" !
;; (require 'mk-ai)                 ;; Fait souvent planter si tu n'as pas configuré de clé API ChatGPT/Copilot.
;; (require 'mk-ios-development)    ;; .
;; (require 'mk-haskell)            ;; (Langage spécifique).
;; (require 'mk-lisp)               ;; lisp.
;; (require 'mk-org)                ;; On enlève pour l'instant pour accélérer le démarrage.
;; (require 'mk-notifications)      ;; 
;; (require 'mk-elfeed)             ;; C'est un lecteur de flux RSS


(provide 'init)
;;; init.el ends here
