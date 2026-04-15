;;; mk-code-completion.el --- Code completion configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; This file contains configurations related to code completion in Emacs.
;;; Code:

;; company for the dropdown code completation
(use-package company
  :ensure t
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0)
  (company-selection-wrap-around t)
  (company-dabbrev-downcase nil)
  (company-dabbrev-ignore-case nil)
  :bind
  (:map company-active-map
        ("C-n" . company-select-next)
        ("C-p" . company-select-previous)
        ("RET" . company-complete-selection)
        ("<tab>" . company-complete-selection)
        ("<escape>" . company-abort))
  :hook (prog-mode . global-company-mode)
  :config
  (setq company-transformers '(delete-dups company-sort-by-occurrence)))

;; memory for company
(use-package company-prescient
  :ensure t
  :after company
  :config
  (company-prescient-mode 1)
  (prescient-persist-mode 1))

;; eglot understand the code
(use-package eglot
  :ensure t
  :hook (prog-mode . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs
               '((js-ts-mode typescript-ts-mode tsx-ts-mode) . ("typescript-language-server" "--stdio")))
  (setq eglot-report-progress nil))

(provide 'mk-code-completion)
;;; mk-code-completion.el ends here
