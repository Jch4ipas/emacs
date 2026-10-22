;;; mk-web.el --- Web development and markup languages -*- lexical-binding: t; -*-
;;; Commentary:
;; Configuration for web development including HTML, XML, CSS, JavaScript, and TypeScript.
;;; Code:

;; Grammar sources.  Missing grammars are offered by treesit-auto when a file
;; is opened; M-x mk/install-treesit-grammars installs them all at once.
(setq treesit-language-source-alist
  '(;; Web & Données
    (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
    (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
    (tsx        "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
    (html       "https://github.com/tree-sitter/tree-sitter-html")
    (css        "https://github.com/tree-sitter/tree-sitter-css")
    (json       "https://github.com/tree-sitter/tree-sitter-json")
    (yaml       "https://github.com/ikatyang/tree-sitter-yaml")
    (toml       "https://github.com/tree-sitter/tree-sitter-toml")
    (markdown   "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown/src")
    (markdown-inline "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown-inline/src")
    ;; Scripts & Systèmes
    (bash       "https://github.com/tree-sitter/tree-sitter-bash")
    (python     "https://github.com/tree-sitter/tree-sitter-python")
    (c          "https://github.com/tree-sitter/tree-sitter-c")
    (cpp        "https://github.com/tree-sitter/tree-sitter-cpp")
    (rust       "https://github.com/tree-sitter/tree-sitter-rust")
    (go         "https://github.com/tree-sitter/tree-sitter-go")
    (make       "https://github.com/alemuller/tree-sitter-make")
    (lua        "https://github.com/tree-sitter-grammars/tree-sitter-lua")
    (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
    (java       "https://github.com/tree-sitter/tree-sitter-java")
    (ruby       "https://github.com/tree-sitter/tree-sitter-ruby")
    (php        "https://github.com/tree-sitter/tree-sitter-php" "master" "php/src")
    (phpdoc     "https://github.com/claytonrcarter/tree-sitter-phpdoc")
    (jsdoc      "https://github.com/tree-sitter/tree-sitter-jsdoc")))

(defun mk/install-treesit-grammars ()
  "Install every grammar of `treesit-language-source-alist' that is missing."
  (interactive)
  (dolist (lang (mapcar #'car treesit-language-source-alist))
    (unless (treesit-language-available-p lang)
      (treesit-install-language-grammar lang))))

(setq major-mode-remap-alist
      '((yaml-mode      . yaml-ts-mode)
        (bash-mode      . bash-ts-mode)
        (js-mode        . tsx-ts-mode)
        (javascript-mode . tsx-ts-mode)
        (typescript-mode . tsx-ts-mode)
        (json-mode      . json-ts-mode)
        (css-mode       . css-ts-mode)
        (python-mode    . python-ts-mode)
        (c-mode         . c-ts-mode)
        (c++-mode       . c++-ts-mode)))

(use-package nxml-mode
  :ensure nil
  :mode "\\.xml\\'"
  :hook ((nxml-mode . setup-programming-mode)
         (nxml-mode . colorful-mode)
         (nxml-mode . display-line-numbers-mode)))

(use-package typescript-ts-mode
  :defer t
  :hook (typescript-ts-base-mode . (lambda ()
                                     (setq-local typescript-ts-indent-level 4
                                                 typescript-ts-mode-indent-offset 4
                                                 js-indent-level 4)))
  ;; tsx-ts-mode for JavaScript too, so JSX in .js files is understood
  :mode (("\\.[cm]?jsx?\\'" . tsx-ts-mode)
         ("\\.tsx\\'" . tsx-ts-mode)
         ("\\.[cm]?ts\\'" . typescript-ts-mode)))

;; (use-package markdown-mode
;;   :defer t
;;   :ensure t
;;   :commands (markdown-mode gfm-mode)
;;   :mode (("README\\.md\\'" . gfm-mode)
;;          ("\\.md\\'" . markdown-mode)
;;          ("\\.markdown\\'" . markdown-mode))
;;   :config
;;   (setq markdown-fontify-code-blocks-natively t))

(use-package markdown-ts-mode
  :ensure nil                           ; built into Emacs 31
  :mode "\\.md\\'")

(provide 'mk-web)
;;; mk-web.el ends here
