;;; mk-profiles.el --- Switch between several configurations -*- lexical-binding: t; -*-
;;; Commentary:
;; One configuration, several profiles.  A profile is the list of modules
;; it loads; mk-base (packages, shell PATH) is always loaded first.
;;
;;   M-x mk/switch-profile  (C-c P)   pick a profile and restart Emacs
;;
;; The active profile is stored in var/profile.  The EMACS_PROFILE
;; environment variable overrides it for one launch:
;;   open --env EMACS_PROFILE=minimal -a Emacs
;;
;; minimal (mk-minimal.el) is built like the reference minimal configs
;; (Emacs Bedrock, minimal-emacs.d): built-ins first, then a handful of
;; packages.  complet is minimal, with the same Emacs keys, plus the
;; mk-complet-*.el modules (look, editing tools, languages, help).
;;; Code:

(defconst mk/complet-modules
  '(mk-minimal mk-lsp mk-complet-ui mk-complet-edit mk-complet-debug mk-complet-web)
  "Modules of the complet profile: minimal plus extra modules.")

(defconst mk/profiles
  `((complet      "Minimal + interface, outils, langages et aides"
                  ,mk/complet-modules)
    (minimal      "Config pro minimaliste : built-ins + vertico, corfu, eglot, magit"
                  (mk-minimal mk-lsp))
    (evil         "Comme complet, avec les touches Vim (leader : SPC)"
                  (,@mk/complet-modules mk-evil))
    (evil-minimal "Comme minimal, avec les touches Vim (leader : SPC)"
                  (mk-minimal mk-lsp mk-evil)))
  "Available profiles: (NAME DESCRIPTION MODULES).")

(defconst mk/profile-file
  (expand-file-name "var/profile" user-emacs-directory)
  "File holding the name of the active profile.")

(defun mk/read-profile ()
  "Return the profile to use, from EMACS_PROFILE or `mk/profile-file'."
  (let* ((env (getenv "EMACS_PROFILE"))
         (saved (and (file-readable-p mk/profile-file)
                     (with-temp-buffer
                       (insert-file-contents mk/profile-file)
                       (string-trim (buffer-string)))))
         (name (intern (or (and env (not (string-empty-p env)) env)
                           (and saved (not (string-empty-p saved)) saved)
                           "complet"))))
    (if (assq name mk/profiles) name 'complet)))

(defconst mk/profile (mk/read-profile)
  "The active profile.")

(defun mk/profile-modules ()
  "Return the modules to load for the active profile, in order."
  (cons 'mk-base (nth 2 (assq mk/profile mk/profiles))))

(defun mk/module-p (module)
  "Return non-nil if MODULE is loaded by the active profile."
  (memq module (mk/profile-modules)))

(defun mk/switch-profile (profile)
  "Save PROFILE as the active profile and restart Emacs."
  (interactive
   (let* ((width (apply #'max (mapcar (lambda (p) (length (symbol-name (car p)))) mk/profiles)))
          (completion-extra-properties
           `(:annotation-function
             ,(lambda (name)
                (let ((p (assq (intern name) mk/profiles)))
                  (concat (make-string (- (+ width 2) (length name)) ?\s)
                          (nth 1 p)
                          (if (eq (car p) mk/profile) "  (actif)" "")))))))
     (list (intern (completing-read "Profil : "
                                    (mapcar (lambda (p) (symbol-name (car p))) mk/profiles)
                                    nil t)))))
  (make-directory (file-name-directory mk/profile-file) t)
  (with-temp-file mk/profile-file (insert (symbol-name profile)))
  (when (and (getenv "EMACS_PROFILE") (not (string-empty-p (getenv "EMACS_PROFILE"))))
    (message "Attention : EMACS_PROFILE=%s a la priorité sur ce choix" (getenv "EMACS_PROFILE")))
  (if (y-or-n-p (format "Profil « %s » enregistré. Redémarrer Emacs maintenant ? " profile))
      (restart-emacs)
    (message "Le profil « %s » sera utilisé au prochain démarrage" profile)))

(keymap-global-set "C-c P" #'mk/switch-profile)

(provide 'mk-profiles)
;;; mk-profiles.el ends here
