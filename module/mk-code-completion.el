;;; mk-code-completion.el --- Code completion configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; This file contains configurations related to code completion in Emacs.
;; The language servers themselves (eglot) are configured in mk-lsp.el.
;;; Code:

;; company for the dropdown code completation
(use-package company
  :custom
  (company-minimum-prefix-length 2)
  ;; 0.0 asks the language server on every keystroke: a tiny delay is
  ;; imperceptible but avoids most useless requests.
  (company-idle-delay 0.1)
  (company-selection-wrap-around t)
  (company-dabbrev-downcase nil)
  (company-dabbrev-ignore-case nil)
  (company-tooltip-align-annotations t)
  :bind
  (:map company-active-map
        ("C-n" . company-select-next)
        ("C-p" . company-select-previous)
        ("RET" . company-complete-selection)
        ("<tab>" . company-complete-selection)
        ("<escape>" . company-abort))
  :hook (prog-mode . company-mode)
  :config
  (setq company-transformers '(delete-dups company-sort-by-occurrence)))

;; memory for company
(use-package company-prescient
  :after company
  :config
  (company-prescient-mode 1)
  (prescient-persist-mode 1))

(provide 'mk-code-completion)
;;; mk-code-completion.el ends here
