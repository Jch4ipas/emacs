;;; mk-complet-docs.el --- Documentation inside Emacs -*- lexical-binding: t; -*-
;;; Commentary:
;;   C-h D   devdocs: official documentation of the language of the
;;           buffer (MDN for JS/HTML/CSS, Python, PHP, Twig, Bash...),
;;           offline, starting with the symbol at point
;;   C-h T   tldr: short examples of a terminal command (tar, ssh, docker...)
;;
;; More documentations: M-x devdocs-install (C# is not on DevDocs: the
;; language server shows its documentation with C-h . instead).
;;; Code:

(defconst mk/devdocs-by-mode
  '((js-base-mode          "javascript" "dom" "node")
    (typescript-ts-base-mode "typescript" "javascript" "dom" "node")
    (tsx-ts-mode           "typescript" "javascript" "dom" "react")
    (html-ts-mode          "html" "css")
    (mhtml-mode            "html" "css")
    (css-ts-mode           "css")
    (css-mode              "css")
    (python-base-mode      "python~3.13")
    (php-ts-mode           "php")
    (php-mode              "php")
    (web-mode              "twig~3" "html" "css")
    (bash-ts-mode          "bash")
    (sh-mode               "bash")
    (dockerfile-ts-mode    "docker")
    (yaml-ts-mode          "docker"))
  "Documentations searched by `devdocs-lookup' in each major mode.")

(defconst mk/devdocs-docs
  (delete-dups (apply #'append (mapcar #'cdr mk/devdocs-by-mode)))
  "Every documentation listed in `mk/devdocs-by-mode'.")

(use-package devdocs
  :defer t
  :bind ("C-h D" . devdocs-lookup)
  :custom
  (devdocs-data-dir (expand-file-name "var/devdocs" user-emacs-directory))
  :init
  (defun mk/devdocs-set-docs ()
    "Set the documentations of the current buffer from `mk/devdocs-by-mode'."
    (when-let* ((entry (seq-find (lambda (e) (derived-mode-p (car e))) mk/devdocs-by-mode)))
      (setq-local devdocs-current-docs (cdr entry))))
  (add-hook 'after-change-major-mode-hook #'mk/devdocs-set-docs))

(defun mk/devdocs-install-all ()
  "Install (or update) every documentation of `mk/devdocs-docs'."
  (interactive)
  (require 'devdocs)
  (dolist (doc mk/devdocs-docs)
    (devdocs-install doc)))

(use-package tldr
  :defer t
  :bind ("C-h T" . tldr)
  :custom
  (tldr-directory-path (expand-file-name "var/tldr/" user-emacs-directory))
  (tldr-locales '("fr")))               ; French page when there is one

(provide 'mk-complet-docs)
;;; mk-complet-docs.el ends here
