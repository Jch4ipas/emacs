;;; mk-windows.el --- Make the configuration work the same on Windows -*- lexical-binding: t; -*-
;;; Commentary:
;; Loaded only on Windows, right after mk-base (see mk-profiles.el), so
;; the macOS configuration never sees it.  It makes Windows behave like
;; the Mac as much as possible:
;;
;;   - the Windows key is Super, like Cmd on the Mac: Win+C copies, Win+V
;;     pastes, s-p, s-z, s-/... work the same (Windows keeps a few for
;;     itself, such as Win+L)
;;   - the Unix tools of Git for Windows (diff, find, grep) are used by
;;     ediff, project.el and dired; gpg is the Windows one (GnuPG)
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

;; The Cmd keys that Emacs gives on the Mac (term/ns-win.el), so Win+C
;; copies like Cmd+C.  The other s- keys are in mk-minimal.el.
(dolist (binding '(("s-c" . kill-ring-save)
                   ("s-v" . yank)
                   ("s-x" . kill-region)
                   ("s-a" . mark-whole-buffer)
                   ("s-s" . save-buffer)
                   ("s-f" . isearch-forward)
                   ("s-g" . isearch-repeat-forward)
                   ("s-o" . find-file)
                   ("s-n" . make-frame)
                   ("s-q" . save-buffers-kill-emacs)
                   ("s-k" . kill-current-buffer)
                   ("s-u" . revert-buffer)
                   ("s-+" . text-scale-adjust)
                   ("s-=" . text-scale-adjust)
                   ("s--" . text-scale-adjust)
                   ("s-0" . text-scale-adjust)))
  (keymap-global-set (car binding) (cdr binding)))

;; These combinations are Windows shortcuts (Win+C Copilot, Win+V
;; clipboard history, Win+P screens, Win+Z layouts...): ask Windows to
;; give them to Emacs instead.  Win+L (lock) cannot be taken.
(dolist (key '([s-c] [s-v] [s-x] [s-a] [s-s] [s-f] [s-g] [s-o] [s-n] [s-q]
               [s-k] [s-u] [s-+] [s-=] [s--] [s-0]
               [s-p] [s-P] [s-z] [s-Z] [s-w] [s-/] [s-F] [s-M]))
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

;;; gpg: package signatures and ~/.authinfo.gpg (instead of the keychain)
;; The gpg of Git for Windows is an MSYS program: it reads "c:/Users/..."
;; as a relative path, so checking the signature of GNU ELPA failed and
;; its packages (vertico-posframe...) could not be installed.  Use the
;; Windows gpg (winget install GnuPG.GnuPG) when it is there; without it,
;; signatures are not checked (the download itself is still HTTPS).
(let ((gpg (seq-find #'file-executable-p
                     (mapcar (lambda (dir) (expand-file-name "GnuPG/bin/gpg.exe" dir))
                             (delq nil (list (getenv "ProgramFiles")
                                             (getenv "ProgramFiles(x86)")))))))
  (if gpg
      (setq epg-gpg-program gpg)
    (setq package-check-signature nil)))
;; The passphrase is asked in the minibuffer
(setq epg-pinentry-mode 'loopback)

(provide 'mk-windows)
;;; mk-windows.el ends here
