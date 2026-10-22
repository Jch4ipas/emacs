;;; mk-complet-help.el --- Help to not have to remember keys -*- lexical-binding: t; -*-
;;; Commentary:
;;   C-c SPC   menu of every feature, grouped, with its direct key shown
;;             next to it (learn the key, or just use the menu)
;;   C-o       in dired, isearch (C-s), ibuffer (C-x C-b) and the agenda:
;;             a menu of the commands of that mode (casual)
;;   Tip of the day on the dashboard; M-x mk/tip shows another one.
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
        ,(mk/menu-entry "!" "Une astuce" 'mk/tip)
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

;;; Tip of the day
(defconst mk/tips
  '("M-. va à la définition, M-, revient là où tu étais."
    "M-? liste toutes les utilisations du symbole sous le curseur."
    "F2 renomme une variable ou une fonction dans tout le projet."
    "C-c l a propose les corrections automatiques : import manquant, faute de frappe…"
    "M-n / M-p sautent à l'erreur suivante / précédente."
    "C-x p f ouvre un fichier du projet en tapant une partie de son nom."
    "M-s r cherche un texte dans tout le projet, avec un aperçu."
    "M-s l cherche dans le fichier, avec un aperçu de chaque ligne."
    "M-g i liste les fonctions et classes du fichier pour y sauter."
    "C-x b change de buffer. Tape « f » puis espace pour ne voir que les fichiers récents."
    "C-. sur n'importe quoi (fichier, symbole, URL) propose les actions possibles."
    "Après M-s r : C-. E exporte les résultats, C-c C-p les rend modifiables, C-c C-c enregistre tout."
    "M-j puis deux lettres : saute n'importe où à l'écran."
    "C-x g ouvre magit : s ajoute un fichier, c c commite, P p pousse."
    "C-c d duplique la ligne, M-↑ / M-↓ la déplacent."
    "C-> ajoute un curseur sur l'occurrence suivante, C-c m sur toutes."
    "C-x u montre l'arbre des annulations : tu peux revenir à n'importe quel état."
    "C-c r lance les tâches du projet : tests, commandes Symfony, dotnet…"
    "C-x C-a b pose un point d'arrêt, C-x C-a d lance le débogueur."
    "C-h D ouvre la doc du langage, C-h T des exemples de commandes du terminal."
    "C-c i i ouvre le chat IA, C-c i r réécrit la sélection."
    "C-c c note une tâche ou une idée sans quitter ce que tu fais ; C-c a montre l'agenda."
    "C-x 3 coupe l'écran en deux, C-x o passe à l'autre fenêtre, C-x 0 la ferme."
    "C-x 4 . ouvre la définition dans l'autre fenêtre."
    "C-x SPC sélectionne un rectangle ; C-x r t écrit le même texte sur chaque ligne."
    "F3 enregistre une macro, F4 l'arrête, puis F4 la rejoue."
    "C-u C-SPC ramène le curseur à ses positions précédentes."
    "M-% remplace avec confirmation : y oui, n non, ! tout le reste."
    "C-c t ouvre l'explorateur de fichiers."
    "C-h k puis une touche explique ce que fait cette touche."
    "C-h B liste toutes les touches disponibles ici, avec une recherche."
    "M-x accepte des morceaux de nom dans le désordre : « rena egl » trouve eglot-rename."
    "C-c SPC ouvre le menu de toutes les fonctions, avec leurs touches."
    "M-F formate tout le fichier."
    "s-/ commente ou décommente la ligne ou la sélection."
    "Dans dired, C-o ouvre le menu de toutes ses commandes."
    "Dans dired, C-x C-q permet de renommer des fichiers en éditant le texte, C-c C-c pour valider."
    "C-M-f / C-M-b sautent par-dessus un bloc entre parenthèses ou accolades."
    "C-s cherche dans le fichier ; C-o pendant la recherche ouvre son menu.")
  "Tips shown on the dashboard and by `mk/tip'.")

(defun mk/random-tip ()
  "Return a random tip from `mk/tips'."
  (nth (random (length mk/tips)) mk/tips))

(defun mk/tip ()
  "Show a random tip in the echo area."
  (interactive)
  (message "Astuce : %s" (mk/random-tip)))

(with-eval-after-load 'welcome-dashboard
  (advice-add 'welcome-dashboard--insert-misc-info :after
              (lambda (&rest _)
                ;; Not welcome-dashboard--insert-centered: it fails when the
                ;; text is wider than the window
                (let ((tip (concat "Astuce : " (mk/random-tip))))
                  (insert "\n" (make-string (max 0 (/ (- (window-width) (string-width tip)) 2)) ?\s)
                          (propertize tip 'face 'font-lock-comment-face) "\n")))))

(provide 'mk-complet-help)
;;; mk-complet-help.el ends here
