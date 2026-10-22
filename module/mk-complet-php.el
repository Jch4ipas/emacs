;;; mk-complet-php.el --- PHP, Symfony and Twig -*- lexical-binding: t; -*-
;;; Commentary:
;; PHP itself is handled by php-ts-mode (built in) and intelephense
;; (mk-lsp.el).  This module adds:
;;   - web-mode for Twig templates (.twig)
;;   - C-c r in a Symfony project: a menu of bin/console commands, and
;;     navigation between controllers and templates
;;; Code:

(declare-function mk/symfony--menu nil)

;;; Twig
(use-package web-mode
  :mode "\\.twig\\'"
  :custom
  (web-mode-engines-alist '(("twig" . "\\.twig\\'")))
  (web-mode-markup-indent-offset 4)
  (web-mode-css-indent-offset 4)
  (web-mode-code-indent-offset 4)
  (web-mode-enable-auto-pairing t)
  (web-mode-enable-current-element-highlight t))

;;; Symfony
(defun mk/symfony-root ()
  "Return the root of the current Symfony project, or nil."
  (when-let* ((dir (locate-dominating-file default-directory "bin/console")))
    (and (file-exists-p (expand-file-name "symfony.lock" dir)) dir)))

(defun mk/symfony-console (args &optional interactive)
  "Run bin/console ARGS at the project root.
With INTERACTIVE, the output buffer accepts input (for make:* questions)."
  (let ((default-directory (mk/symfony-root)))
    (compile (concat "php bin/console " args) interactive)))

(defun mk/symfony-command ()
  "Pick any bin/console command, with completion, and run it."
  (interactive)
  (let* ((default-directory (mk/symfony-root))
         (commands (mapcar (lambda (line) (car (split-string line)))
                           (process-lines "php" "bin/console" "list" "--raw")))
         (command (completing-read "bin/console " commands nil nil))
         (args (read-string (format "bin/console %s " command))))
    (mk/symfony-console (string-trim (concat command " " args)) t)))

(defun mk/symfony-template-at-point ()
  "Return the template name (\"dir/file.html.twig\") on this line, or nil.
When the line names several templates, the one under point wins."
  (let ((line (buffer-substring-no-properties (line-beginning-position)
                                              (line-end-position)))
        (column (current-column))
        (names nil)
        (start 0))
    (while (string-match "['\"]\\([^'\"]+\\.twig\\)['\"]" line start)
      (push (list (match-string 1 line) (match-beginning 0) (match-end 0)) names)
      (setq start (match-end 0)))
    (car (or (seq-find (lambda (n) (<= (nth 1 n) column (nth 2 n))) names)
             (car (last names))))))

(defun mk/symfony-goto-template ()
  "Open the Twig template named on this line (render, include, extends)."
  (interactive)
  (let ((name (or (mk/symfony-template-at-point)
                  (user-error "No .twig template name on this line"))))
    (find-file (expand-file-name (concat "templates/" (string-remove-prefix "@" name))
                                 (mk/symfony-root)))))

(defun mk/symfony-template-usages ()
  "Search where the current template is used (controllers and templates)."
  (interactive)
  (let* ((root (expand-file-name "templates/" (mk/symfony-root)))
         (name (if (and buffer-file-name (string-prefix-p root buffer-file-name))
                   (file-relative-name buffer-file-name root)
                 (read-string "Template : "))))
    (let ((default-directory (mk/symfony-root)))
      (consult-ripgrep default-directory (regexp-quote name)))))

(defun mk/symfony-menu ()
  "Menu of the Symfony commands (bin/console) of the current project."
  (interactive)
  (require 'transient)
  (mk/symfony--menu))

;; Defined once transient is loaded: loading it at startup costs ~0.1s
(with-eval-after-load 'transient
  (transient-define-prefix mk/symfony--menu ()
    "Symfony commands (bin/console) of the current project."
    [["Navigation"
      ("t" "Ouvrir le template de la ligne" mk/symfony-goto-template)
      ("u" "Où ce template est utilisé" mk/symfony-template-usages)]
     ["Générer (make:)"
      ("c" "Contrôleur" (lambda () (interactive) (mk/symfony-console "make:controller" t)))
      ("e" "Entité" (lambda () (interactive) (mk/symfony-console "make:entity" t)))
      ("f" "Formulaire" (lambda () (interactive) (mk/symfony-console "make:form" t)))
      ("m" "Migration" (lambda () (interactive) (mk/symfony-console "make:migration")))]
     ["Lancer"
      ("M" "Appliquer les migrations"
       (lambda () (interactive) (mk/symfony-console "doctrine:migrations:migrate --no-interaction")))
      ("r" "Routes" (lambda () (interactive) (mk/symfony-console "debug:router")))
      ("C" "Vider le cache" (lambda () (interactive) (mk/symfony-console "cache:clear")))
      ("T" "Tests (phpunit)"
       (lambda () (interactive)
         (let ((default-directory (mk/symfony-root))) (compile "php bin/phpunit"))))
      ("a" "Autre commande…" mk/symfony-command)]]))

(add-hook 'mk/project-task-functions
          (lambda () (and (mk/symfony-root) #'mk/symfony-menu)))

(provide 'mk-complet-php)
;;; mk-complet-php.el ends here
