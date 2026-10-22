;;; mk-base.el --- Shared by every profile: packages, shell PATH -*- lexical-binding: t; -*-
;;; Commentary:
;; Package archives, use-package defaults, the cached shell PATH and the
;; automatic package recompilation after an Emacs upgrade.
;;; Code:

;; Packages are already activated by `package-activate-all' (through the
;; quickstart file, see early-init.el), so no `package-initialize' here.
(require 'package)
(setopt package-archives '(("melpa" . "https://melpa.org/packages/")
                           ("gnu" . "https://elpa.gnu.org/packages/")
                           ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                           ("melpa-stable" . "https://stable.melpa.org/packages/"))
        package-archive-priorities '(("gnu" . 99)
                                     ("nongnu" . 80)
                                     ("melpa" . 70)
                                     ("melpa-stable" . 50))
        package-install-upgrade-built-in nil
        package-quickstart-file
        (expand-file-name "package-quickstart.el" user-emacs-directory))
;; No-op in a normal startup; needed when init.el is loaded by hand (emacs -l)
(unless (bound-and-true-p package--activated)
  (package-activate-all))

(require 'use-package-ensure) ;; Load use-package-always-ensure

(setopt use-package-always-defer nil
        use-package-verbose nil
        use-package-minimum-reported-time 0.1
        use-package-expand-minimally t
        ;; Turn on to profile startup with M-x use-package-report
        use-package-compute-statistics nil
        use-package-always-ensure t
        use-package-enable-imenu-support t)

;;; Shell PATH
;; Asking zsh for its PATH takes ~2s (nvm + conda in .zshrc), so the result is
;; cached: startup uses the cache instantly and refreshes it in the background.
(defvar mk/path-cache-file
  (expand-file-name "var/shell-path" user-emacs-directory)
  "File holding the PATH of the user's login shell.")

(defun mk/apply-path (path)
  "Use PATH (a colon separated string) for `exec-path' and subprocesses."
  (let ((dirs (seq-uniq (split-string path ":" t))))
    (setenv "PATH" (string-join dirs ":"))
    (setq exec-path (append dirs (list exec-directory)))))

(defun mk/refresh-shell-path ()
  "Ask the login shell for its PATH asynchronously, apply it and cache it."
  (interactive)
  (let ((output ""))
    (make-process
     :name "shell-path"
     :command (list (or (getenv "SHELL") "/bin/zsh") "-lic" "printf '@@%s@@' \"$PATH\"")
     :connection-type 'pipe
     :noquery t
     :filter (lambda (_proc string) (setq output (concat output string)))
     :sentinel
     (lambda (_proc _event)
       (when (string-match "@@\\([^@]+\\)@@" output)
         (let ((path (match-string 1 output)))
           (mk/apply-path path)
           (make-directory (file-name-directory mk/path-cache-file) t)
           (with-temp-file mk/path-cache-file (insert path))))))))

(when (file-readable-p mk/path-cache-file)
  (mk/apply-path (with-temp-buffer
                   (insert-file-contents mk/path-cache-file)
                   (string-trim (buffer-string)))))
(add-hook 'emacs-startup-hook #'mk/refresh-shell-path)

(provide 'mk-base)
;;; mk-base.el ends here
