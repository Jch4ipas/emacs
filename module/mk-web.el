;;; mk-web.el --- Web development and markup languages -*- lexical-binding: t; -*-
;;; Commentary:
;; Configuration for web development including HTML, XML, CSS, JavaScript, and TypeScript.
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
    (markdown   "https://github.com/ikatyang/tree-sitter-markdown" "master" "src")
    ;; Scripts & Systèmes
    (bash       "https://github.com/tree-sitter/tree-sitter-bash")
    (python     "https://github.com/tree-sitter/tree-sitter-python")
    (c          "https://github.com/tree-sitter/tree-sitter-c")
    (cpp        "https://github.com/tree-sitter/tree-sitter-cpp")
    (rust       "https://github.com/tree-sitter/tree-sitter-rust")
    (go         "https://github.com/tree-sitter/tree-sitter-go")
    (make       "https://github.com/alemuller/tree-sitter-make")))

(dolist (lang (mapcar #'car treesit-language-source-alist))
  (unless (treesit-language-available-p lang)
    (treesit-install-language-grammar lang)))

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
  :mode (("\\.tsx\\'" . tsx-ts-mode)
         ("\\.js\\'"  . typescript-ts-mode)
         ("\\.mjs\\'" . typescript-ts-mode)
         ("\\.mts\\'" . typescript-ts-mode)
         ("\\.cjs\\'" . typescript-ts-mode)
         ("\\.ts\\'"  . typescript-ts-mode)
         ("\\.jsx\\'" . tsx-ts-mode)))

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
  :mode "\\.md\\'"
  :config
  (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-ts-mode)))

(provide 'mk-web)
;;; mk-web.el ends here
