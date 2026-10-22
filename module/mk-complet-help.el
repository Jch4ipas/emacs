;;; mk-complet-help.el --- Help to not have to remember keys -*- lexical-binding: t; -*-
;;; Commentary:
;;   C-c SPC   menu of every feature, grouped, with its direct key shown
;;             next to it (learn the key, or just use the menu)
;;   C-o       in dired, isearch (C-s), ibuffer (C-x C-b) and the agenda:
;;             a menu of the commands of that mode (casual)
;;; Code:

(declare-function mk/help--menu nil)
(defvar transient--original-buffer)

;;; Central menu
(defun mk/menu-label (label command &optional key)
  "Return LABEL followed by the key that runs COMMAND, if there is one.
KEY is shown when the key cannot be found yet (prefix of a package
that is not loaded)."
  (with-current-buffer (or (bound-and-true-p transient--original-buffer) (current-buffer))
    (let ((keys (seq-find (lambda (k) (not (memq (aref k 0) '(remap menu-bar tool-bar))))
                          (where-is-internal command))))
      (if-let* ((shown (if keys (key-description keys) key)))
          (concat label "  " (propertize shown 'face 'help-key-binding))
        label))))

(defun mk/menu-entry (key label command &optional direct-key)
  "Transient suffix for KEY running COMMAND, described by LABEL and its key.
DIRECT-KEY is shown when the key of COMMAND cannot be found."
  (list key command :description (lambda () (mk/menu-label label command direct-key))))

(defun mk/help-menu ()
  "Menu of every feature of the configuration, with their keys."
  (interactive)
  (require 'transient)
  (mk/help--menu))

;; Defined once transient is loaded: loading it at startup costs ~0.1s
(with-eval-after-load 'transient
  (eval
   `(transient-define-prefix mk/help--menu ()
      "Every feature of the configuration.  The direct key is shown in color."
      [["Fichiers"
        ,(mk/menu-entry "f" "Fichier du projet" 'project-find-file)
        ,(mk/menu-entry "F" "Fichiers récents" 'consult-recent-file)
        ,(mk/menu-entry "b" "Buffers" 'consult-buffer)
        ,(mk/menu-entry "p" "Changer de projet" 'project-switch-project)
        ,(mk/menu-entry "t" "Explorateur" 'treemacs)
        ,(mk/menu-entry "D" "Dossier (dired)" 'dired-jump)]
       ["Chercher"
        ,(mk/menu-entry "s" "Dans le fichier" 'consult-line)
        ,(mk/menu-entry "g" "Dans le projet" 'consult-ripgrep)
        ,(mk/menu-entry "i" "Fonctions du fichier" 'consult-imenu)
        ,(mk/menu-entry "j" "Sauter à l'écran" 'avy-goto-char-timer)
        ,(mk/menu-entry "%" "Remplacer" 'query-replace)]
       ["Code"
        ,(mk/menu-entry "." "Définition" 'xref-find-definitions)
        ,(mk/menu-entry "?" "Références" 'xref-find-references)
        ,(mk/menu-entry "," "Revenir" 'xref-go-back)
        ,(mk/menu-entry "n" "Renommer" 'eglot-rename)
        ,(mk/menu-entry "a" "Corrections / actions" 'eglot-code-actions)
        ,(mk/menu-entry "=" "Formater" 'mk/format-buffer)
        ,(mk/menu-entry "e" "Liste des erreurs" 'consult-flymake)]]
      [["Lancer"
        ,(mk/menu-entry "x" "Tâches du projet" 'mk/project-tasks)
        ,(mk/menu-entry "d" "Déboguer" 'dape "C-x C-a d")
        ,(mk/menu-entry "B" "Point d'arrêt" 'dape-breakpoint-toggle "C-x C-a b")
        ,(mk/menu-entry "`" "Terminal" 'toggle-vterm)
        ,(mk/menu-entry "w" "Docker" 'docker)]
       ["Git et notes"
        ,(mk/menu-entry "v" "Git (magit)" 'magit-status)
        ,(mk/menu-entry "V" "Qui a écrit cette ligne" 'magit-blame)
        ,(mk/menu-entry "c" "Noter une tâche / idée" 'org-capture)
        ,(mk/menu-entry "o" "Agenda" 'org-agenda)
        ,(mk/menu-entry "N" "Mes notes" 'mk/org-open-notes)]
       ["Aide"
        ,(mk/menu-entry "h" "Doc du langage" 'devdocs-lookup)
        ,(mk/menu-entry "T" "Exemples de commande" 'tldr)
        ,(mk/menu-entry "I" "Assistant IA" 'gptel)
        ,(mk/menu-entry "K" "Toutes les touches ici" 'embark-bindings)
        ,(mk/menu-entry "P" "Changer de profil" 'mk/switch-profile)]])
   t))

(keymap-global-set "C-c SPC" #'mk/help-menu)

;;; Menus of the modes (casual)
(use-package casual
  :defer t
  :init
  (keymap-global-set "C-x C-b" #'ibuffer)
  (with-eval-after-load 'dired
    (keymap-set dired-mode-map "C-o" #'casual-dired-tmenu))
  (with-eval-after-load 'isearch
    (keymap-set isearch-mode-map "C-o" #'casual-isearch-tmenu))
  (with-eval-after-load 'ibuffer
    (keymap-set ibuffer-mode-map "C-o" #'casual-ibuffer-tmenu))
  (with-eval-after-load 'org-agenda
    (keymap-set org-agenda-mode-map "C-o" #'casual-agenda-tmenu)))

(provide 'mk-complet-help)
;;; mk-complet-help.el ends here
