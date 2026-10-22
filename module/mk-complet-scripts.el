;;; mk-complet-scripts.el --- Shell scripts and AutoHotkey -*- lexical-binding: t; -*-
;;; Commentary:
;;   Bash : bash-ts-mode + bash-language-server (mk-lsp.el), which reports
;;          the shellcheck warnings as flymake errors (M-n / M-p).
;;          Scripts starting with #! are made executable on save.
;;   AHK  : ahk-mode for AutoHotkey files (.ahk): highlighting,
;;          indentation and completion of the AutoHotkey commands.
;;          AutoHotkey only runs on Windows, so it is editing only.
;;; Code:

(add-hook 'after-save-hook #'executable-make-buffer-file-executable-if-script-p)

(use-package ahk-mode
  :mode "\\.ahk\\'"
  :custom (ahk-indentation 4))

(provide 'mk-complet-scripts)
;;; mk-complet-scripts.el ends here
