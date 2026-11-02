;;; mk-windows.el --- Make the configuration work the same on Windows -*- lexical-binding: t; -*-
;;; Commentary:
;; Loaded only on Windows, right after mk-base (see mk-profiles.el), so
;; the macOS configuration never sees it.  It makes Windows behave like
;; the Mac as much as possible:
;;
;;   - the Windows key is Super, like Cmd on the Mac: s-p, s-z, s-/... work
;;     the same (Windows keeps a few for itself, such as Win+L)
;;   - the Unix tools of Git for Windows (diff, find, gpg...) are used by
;;     ediff, project.el, dired and auth-source
;;   - files are saved in UTF-8 with Unix line ends (LF), like on the Mac
;;   - the terminal (C-` and Claude Code) is ghostel running PowerShell
;;
;; Installation steps: WINDOWS.org.
;;; Code:

;;; Windows key = Super (Cmd on the Mac)
(setq w32-lwindow-modifier 'super
      w32-rwindow-modifier 'super
      ;; Do not open the Start menu when the Windows key is used in Emacs
      w32-pass-lwindow-to-system nil
      w32-pass-rwindow-to-system nil)

;; These combinations are Windows shortcuts (Win+P screens, Win+Z
;; layouts, Win+W widgets...): ask Windows to give them to Emacs instead
(dolist (key '([s-p] [s-P] [s-z] [s-Z] [s-w] [s-/] [s-F] [s-M]))
  (ignore-errors (w32-register-hot-key key)))

;;; Unix tools of Git for Windows
;; Appended: the Windows programs stay first in PATH.  find and grep get
;; full paths, because Windows has its own, different find.exe.
(let ((bin (expand-file-name "Git/usr/bin" (or (getenv "ProgramFiles") "C:/Program Files"))))
  (when (file-directory-p bin)
    (add-to-list 'exec-path bin t)
    (setenv "PATH" (concat (getenv "PATH") path-separator (convert-standard-filename bin)))
    (setq find-program (expand-file-name "find.exe" bin)
          grep-program (expand-file-name "grep.exe" bin)
          diff-command (expand-file-name "diff.exe" bin)
          ediff-diff-program diff-command)))

;;; Text: UTF-8 and LF line ends, like the files written on the Mac
(prefer-coding-system 'utf-8-unix)
(setq-default buffer-file-coding-system 'utf-8-unix)

;;; Speed: Windows pipes are slow by default (language servers, git)
(setq w32-pipe-read-delay 0
      w32-pipe-buffer-size (* 64 1024)
      w32-get-true-file-attributes nil)

;;; Dired: Emacs lists the files itself (no ls on Windows)
(setq ls-lisp-dirs-first t)
(with-eval-after-load 'dired
  ;; --group-directories-first is an option of GNU ls, see ls-lisp-dirs-first
  (setq dired-listing-switches "-alh"))

;;; Terminal: ghostel with PowerShell (vterm does not work on Windows)
(setq ghostel-shell (or (executable-find "pwsh") "powershell.exe"))

;;; API keys: ~/.authinfo.gpg instead of the macOS keychain
;; The passphrase is asked in the minibuffer (gpg of Git for Windows)
(setq epg-pinentry-mode 'loopback)

(provide 'mk-windows)
;;; mk-windows.el ends here
