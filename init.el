;;; Init.el --- optimized init file -*- no-byte-compile: t; lexical-binding: t; -*-

;;; Commentary:
;; Personal Emacs configuration with optimized startup and modern packages.
;; Features include LSP support (eglot), project management, and development tools.
;; Garbage collector and package system are tuned in early-init.el.

;;; Code:

;; Keep Custom's auto-generated code out of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror 'nomessage)

(setopt debug-on-error nil)

(electric-indent-mode 0)

(dolist (dir '("module" "dependance"))
  (add-to-list 'load-path (expand-file-name dir user-emacs-directory)))

;; Profiles (M-x mk/switch-profile or C-c P): which modules and features load
(require 'mk-profiles)
(dolist (module (mk/profile-modules))
  (require module))

;; Modules never loaded by any profile:
;; (require 'mk-misc)               ;;  Plein de problême si ta version de emacs n'est pas au moins de 30. C'est ici que se cachent les trucs bizarres comme "knockknock" !
;; (require 'mk-ai)                 ;; Fait souvent planter si tu n'as pas configuré de clé API ChatGPT/Copilot.
;; (require 'mk-ios-development)    ;; .
;; (require 'mk-haskell)            ;; (Langage spécifique).
;; (require 'mk-lisp)               ;; lisp.
;; (require 'mk-org)                ;; On enlève pour l'instant pour accélérer le démarrage.
;; (require 'mk-notifications)      ;;
;; (require 'mk-elfeed)             ;; C'est un lecteur de flux RSS

(message "Profil Emacs : %s" mk/profile)

(provide 'init)
;;; init.el ends here
