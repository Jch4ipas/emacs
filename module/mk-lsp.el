;;; mk-lsp.el --- Language servers (eglot) for every language -*- lexical-binding: t; -*-
;;; Commentary:
;; Eglot (built in) is started automatically in every buffer whose major
;; mode has a language server installed on this machine.  Modes without a
;; server (or whose server is not installed) are silently skipped.
;;
;; Servers installed on this machine:
;;   npm  : typescript-language-server vscode-langservers-extracted
;;          (html/css/json/eslint) bash-language-server yaml-language-server
;;          dockerfile-language-server-nodejs intelephense (PHP)
;;   brew : marksman (Markdown) taplo (TOML) lua-language-server texlab (LaTeX)
;;   other: clangd (C/C++), sourcekit-lsp (Swift), pylsp (Python, anaconda)
;;
;; To add another language: install its server, eglot's default
;; `eglot-server-programs' already knows ~80 of them.
;;; Code:

(declare-function eglot--lookup-mode "eglot")

(defun mk/eglot-server-available-p ()
  "Return non-nil if a language server for the current major mode is installed."
  (require 'eglot)
  (let ((contact (cdr (eglot--lookup-mode major-mode))))
    (when (functionp contact)
      (setq contact (ignore-errors (funcall contact nil (project-current)))))
    (cond ((null contact) nil)
          ((not (listp contact)) t)
          (t (let ((program (seq-find #'stringp contact)))
               (or (null program)          ; host/port style contact
                   (file-name-absolute-p program)
                   (executable-find program)))))))

(defun mk/eglot-ensure-maybe ()
  "Start eglot in this buffer only when a language server is available."
  (when (and buffer-file-name
             (not (file-remote-p buffer-file-name))
             (not (derived-mode-p 'emacs-lisp-mode 'lisp-interaction-mode))
             (mk/eglot-server-available-p))
    (eglot-ensure)))

(use-package eglot
  :ensure nil
  :defer t
  :hook ((prog-mode . mk/eglot-ensure-maybe)
         (text-mode . mk/eglot-ensure-maybe))
  :bind (:map eglot-mode-map
              ("C-c l r" . eglot-rename)
              ("C-c l a" . eglot-code-actions)
              ("C-c l f" . eglot-format)
              ("C-c l o" . eglot-code-action-organize-imports)
              ("C-c l q" . eglot-shutdown)
              ("C-c l R" . eglot-reconnect))
  :custom
  (eglot-autoshutdown t)              ; stop the server when its last buffer is killed
  (eglot-sync-connect 1)              ; block at most 1s when a server starts
  (eglot-connect-timeout 30)
  (eglot-report-progress nil)
  (eglot-extend-to-xref t)            ; stay in eglot when jumping into libraries
  (eglot-events-buffer-config '(:size 0 :format full)) ; no JSON logging = much faster
  (eglot-send-changes-idle-time 0.3)
  :config
  (dolist (entry
           `(((html-ts-mode mhtml-mode) . ("vscode-html-language-server" "--stdio"))
             ;; Renaming from a call site renames the function everywhere
             ;; (tsserver otherwise only creates a local `import {a as b}')
             (((js-mode :language-id "javascript")
               (js-ts-mode :language-id "javascript")
               (tsx-ts-mode :language-id "typescriptreact")
               (typescript-ts-mode :language-id "typescript")
               (typescript-mode :language-id "typescript"))
              . ("typescript-language-server" "--stdio"
                 :initializationOptions
                 (:preferences (:providePrefixAndSuffixTextForRename :json-false))))
             ((markdown-ts-mode gfm-mode) . ("marksman" "server"))
             ((php-mode phps-mode php-ts-mode)
              . ,(eglot-alternatives '(("intelephense" "--stdio")
                                       ("phpactor" "language-server"))))
             ((toml-ts-mode conf-toml-mode)
              . ,(eglot-alternatives '(("taplo" "lsp" "stdio") ("tombi" "lsp"))))
             ((LaTeX-mode latex-mode tex-mode bibtex-mode)
              . ,(eglot-alternatives '("texlab" "digestif")))))
    (add-to-list 'eglot-server-programs entry)))

;; Show documentation of the symbol at point in a childframe (C-h .)
(use-package eldoc-box
  :defer t
  :commands eldoc-box-help-at-point
  :custom (eldoc-box-clear-with-C-g t))

(with-eval-after-load 'eglot
  (keymap-set eglot-mode-map "C-h ." #'eldoc-box-help-at-point))

(use-package eldoc
  :ensure nil
  :custom
  (eldoc-echo-area-use-multiline-p nil)
  (eldoc-idle-delay 0.3))

(provide 'mk-lsp)
;;; mk-lsp.el ends here
