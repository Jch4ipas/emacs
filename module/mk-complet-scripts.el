;;; mk-complet-scripts.el --- Shell scripts and AutoHotkey -*- lexical-binding: t; -*-
;;; Commentary:
;;   Bash : bash-ts-mode + bash-language-server (mk-lsp.el), which reports
;;          the shellcheck warnings as flymake errors (M-n / M-p).
;;          Scripts starting with #! are made executable on save.
;;   AHK  : ahk-mode for AutoHotkey v2 files (.ahk, .ah2): highlighting
;;          and indentation, plus the AutoHotkey v2 language server
;;          (completion, errors, C-h . documentation, F2 rename...) once
;;          installed with M-x mk/ahk-install-lsp (needs node).
;;            C-c C-c   save and run the script (Windows); running it
;;                      again replaces the copy already running
;;            C-c C-k   stop the script
;;            C-h D     AutoHotkey v2 documentation of the word at point
;;          The script stops when Emacs is closed: to keep it running,
;;          double-click the .ahk file, or put it in the Startup folder
;;          (Win+R, shell:startup).
;;; Code:

(add-hook 'after-save-hook #'executable-make-buffer-file-executable-if-script-p)

;;; AutoHotkey v2
(defconst mk/ahk-lsp-directory (expand-file-name "var/ahk2-lsp/" user-emacs-directory)
  "Where M-x mk/ahk-install-lsp installs the AutoHotkey v2 language server.")

(defconst mk/ahk-lsp-server (expand-file-name "server/dist/server.js" mk/ahk-lsp-directory)
  "Entry point of the AutoHotkey v2 language server.")

(defun mk/ahk-executable ()
  "Return the AutoHotkey v2 program, or nil when it is not installed."
  (or (executable-find "AutoHotkey64")
      (executable-find "AutoHotkey")
      (seq-find #'file-exists-p
                (mapcar (lambda (dir) (expand-file-name "AutoHotkey/v2/AutoHotkey64.exe" dir))
                        (delq nil (list (getenv "ProgramFiles")
                                        (when-let* ((local (getenv "LOCALAPPDATA")))
                                          (expand-file-name "Programs" local))))))))

(defun mk/ahk-install-lsp ()
  "Download (or update) the AutoHotkey v2 language server with node."
  (interactive)
  (unless (executable-find "node")
    (user-error "node is not installed (winget install OpenJS.NodeJS.LTS)"))
  (make-directory mk/ahk-lsp-directory t)
  (let ((default-directory mk/ahk-lsp-directory))
    (url-copy-file "https://raw.githubusercontent.com/thqby/vscode-autohotkey2-lsp/main/tools/install.js"
                   "install.js" t)
    (compile "node install.js")))

(defun mk/ahk-lsp-contact (&rest _)
  "Command of the AutoHotkey v2 language server, or nil when not installed."
  (when (file-exists-p mk/ahk-lsp-server)
    (list "node" mk/ahk-lsp-server "--stdio"
          :initializationOptions
          (list :locale "en-us"
                :InterpreterPath (or (mk/ahk-executable) "")))))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '(ahk-mode . mk/ahk-lsp-contact)))

(defvar mk/ahk-process nil
  "The script started by `mk/ahk-run'.")

(defun mk/ahk-run ()
  "Save the script and run it with AutoHotkey v2.
Errors that stop the script from starting are shown in *AutoHotkey*."
  (interactive)
  (unless (eq system-type 'windows-nt)
    (user-error "AutoHotkey only runs on Windows"))
  (let ((program (or (mk/ahk-executable)
                     (user-error "AutoHotkey v2 is not installed (winget install AutoHotkey.AutoHotkey)")))
        (file buffer-file-name)
        (buffer (get-buffer-create "*AutoHotkey*")))
    (save-buffer)
    (mk/ahk-stop)
    (with-current-buffer buffer (erase-buffer))
    (setq mk/ahk-process
          (make-process
           :name "autohotkey"
           :buffer buffer
           ;; /restart: replace the copy started by a double-click
           :command (list program "/restart" "/ErrorStdOut=UTF-8" file)
           :noquery t
           :sentinel (lambda (process _event)
                       (when (and (eq (process-status process) 'exit)
                                  (/= (process-exit-status process) 0))
                         (display-buffer (process-buffer process))))))
    (message "Script lancé : %s (C-c C-k pour l'arrêter)" (file-name-nondirectory file))))

(defun mk/ahk-stop ()
  "Stop the script started by `mk/ahk-run'."
  (interactive)
  (when (process-live-p mk/ahk-process)
    (delete-process mk/ahk-process)
    (message "Script arrêté")))

(defun mk/ahk-help ()
  "Open the AutoHotkey v2 documentation of the word at point."
  (interactive)
  (browse-url (if-let* ((word (thing-at-point 'symbol t)))
                  (format "https://www.autohotkey.com/docs/v2/lib/%s.htm" word)
                "https://www.autohotkey.com/docs/v2/")))

(defvar-local mk/ahk--prog-hooks-done nil)

(defun mk/ahk-run-prog-mode-hook ()
  "Run `prog-mode-hook', which `ahk-mode' loses.
Its body calls `kill-all-local-variables', so the delayed hooks of
`prog-mode' (line numbers, TAB, flymake, eglot...) never run."
  (unless mk/ahk--prog-hooks-done
    (setq mk/ahk--prog-hooks-done t)
    (run-hooks 'prog-mode-hook)))

(use-package ahk-mode
  :mode "\\.ah[k2]\\'"
  :hook (ahk-mode . mk/ahk-run-prog-mode-hook)
  :custom (ahk-indentation 4)
  :bind (:map ahk-mode-map
              ("C-c C-c" . mk/ahk-run)  ; was comment-dwim: M-; does it
              ("C-c C-k" . mk/ahk-stop)
              ("C-h D"   . mk/ahk-help)))

(provide 'mk-complet-scripts)
;;; mk-complet-scripts.el ends here
