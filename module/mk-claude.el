;;; mk-claude.el --- Claude Code inside Emacs (claude-code-ide) -*- lexical-binding: t; -*-
;;; Commentary:
;; Claude Code (the `claude' CLI, logged in with the Pro subscription, no
;; API key) runs in a terminal window on the right, connected to Emacs
;; the way the VS Code extension is: it knows the open file and the
;; selection, shows its edits in ediff (accept with y / refuse with n
;; after q), reads the flymake errors, and can use xref, imenu,
;; tree-sitter and project.el to explore the code.
;;
;;   C-c C        menu of every Claude Code command (start, resume, send
;;                the selection, show / hide the window, stop...)
;;   In the Claude window:
;;     M-RET      new line in the prompt      C-<escape>  cancel (Esc)
;;     C-c C-x    stop sharing the current file / selection
;;
;; Terminal: ghostel (no flickering, unlike vterm).  Its native module is
;; kept in var/ghostel so package upgrades do not delete it.
;;; Code:

(use-package ghostel
  :defer t
  :custom
  (ghostel-module-directory (expand-file-name "var/ghostel/" user-emacs-directory))
  (ghostel-module-auto-install 'download))

(use-package claude-code-ide
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
  :defer t
  :bind ("C-c C" . claude-code-ide-menu)
  :custom
  (claude-code-ide-terminal-backend 'ghostel)
  (claude-code-ide-show-backend-recommendation nil)
  (claude-code-ide-window-side 'right)
  (claude-code-ide-window-width 90)
  ;; The executeCode tool lets the model evaluate any Elisp in this Emacs;
  ;; the other Emacs tools (xref, imenu, project...) only read code
  (claude-code-ide-enable-execute-code nil)
  :config
  (claude-code-ide-emacs-tools-setup))

(provide 'mk-claude)
;;; mk-claude.el ends here
