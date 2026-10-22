;;; mk-complet-web.el --- Web / TypeScript tools -*- lexical-binding: t; -*-
;;; Commentary:
;;   emmet   : type div.card>ul>li*3 then C-j (HTML, CSS, JSX/TSX, Twig)
;;   prettier: files are formatted on save, only in projects that use
;;             prettier (a .prettierrc, prettier.config.* or a "prettier"
;;             entry in package.json), so other projects are not reformatted
;;   verb    : HTTP requests written in an Org file, sent with C-c C-r C-r
;;
;; verb example (in any .org file):
;;   * API                                   :verb:
;;   template http://localhost:3000
;;   ** List users
;;   get /users
;;; Code:

;;; Emmet
(use-package emmet-mode
  :hook ((html-ts-mode mhtml-mode css-ts-mode css-mode tsx-ts-mode web-mode)
         . emmet-mode)
  :config
  ;; className instead of class in JSX/TSX
  (add-hook 'tsx-ts-mode-hook (lambda () (setq-local emmet-expand-jsx-className? t))))

;;; Prettier on save, only where the project uses it
(defun mk/prettier-project-p ()
  "Return non-nil if the current file belongs to a project that uses prettier."
  (when-let* ((file buffer-file-name))
    (or (locate-dominating-file
         file (lambda (dir)
                (directory-files dir nil "\\`\\(\\.prettierrc.*\\|prettier\\.config\\..*\\)\\'" t)))
        (when-let* ((dir (locate-dominating-file file "package.json")))
          (with-temp-buffer
            (insert-file-contents (expand-file-name "package.json" dir))
            (re-search-forward "\"prettier\"" nil t))))))

(use-package apheleia
  :defer t
  :commands apheleia-mode
  :init
  (defun mk/apheleia-maybe ()
    "Format on save with prettier when the project uses it."
    (when (and (not (file-remote-p default-directory)) (mk/prettier-project-p))
      (apheleia-mode 1)))
  (dolist (hook '(js-ts-mode-hook typescript-ts-mode-hook tsx-ts-mode-hook
                  css-ts-mode-hook html-ts-mode-hook json-ts-mode-hook))
    (add-hook hook #'mk/apheleia-maybe)))

;;; HTTP client in Org
(use-package verb
  :defer t
  :init
  (with-eval-after-load 'org
    (require 'verb)
    (keymap-set org-mode-map "C-c C-r" verb-command-map)))

(provide 'mk-complet-web)
;;; mk-complet-web.el ends here
