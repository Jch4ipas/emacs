;;; mk-complet-debug.el --- Debugger (dape) -*- lexical-binding: t; -*-
;;; Commentary:
;; dape speaks the Debug Adapter Protocol, like VS Code.  All its
;; commands are under C-x C-a (the prefix of Emacs' own debugger gud):
;;
;;   C-x C-a d   start (choose a config: node, debugpy, ...)
;;   C-x C-a b   toggle a breakpoint on the line (or click in the margin)
;;   C-x C-a n / s / o   next line / step into / step out
;;   C-x C-a c   continue          C-x C-a q   quit
;;
;; Adapters installed on this machine:
;;   JavaScript / TypeScript : debug-adapters/js-debug (vscode-js-debug)
;;   Python                  : debugpy (pip, in the active environment)
;;; Code:

(use-package dape
  :defer t
  :commands dape
  ;; The whole C-x C-a map works before dape is loaded
  :bind-keymap ("C-x C-a" . dape-global-map)
  :init
  ;; Click in the left margin = breakpoint.  Turned on when idle: it loads
  ;; dape, which would add ~0.25s to startup.
  (run-with-idle-timer 2 nil #'dape-breakpoint-global-mode 1)
  :custom
  (dape-buffer-window-arrangement 'right)
  :config
  ;; Save the files before starting, so the debugger runs the shown code
  (add-hook 'dape-start-hook (lambda () (save-some-buffers t t)))
  (add-hook 'dape-display-source-hook #'pulse-momentary-highlight-one-line))

(provide 'mk-complet-debug)
;;; mk-complet-debug.el ends here
