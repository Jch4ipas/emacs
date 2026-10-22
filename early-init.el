;; early-init.el --- summary -*- lexical-binding: t; no-byte-compile: t; mode: emacs-lisp; coding:utf-8; fill-column: 80 -*-

;;; Commentary:
;; Emacs early initialization file loaded before package system and UI.
;; Optimized for maximum performance and minimal startup time.

;;; Code:
(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)

(setq warning-minimum-level :error)
(setq native-comp-async-report-warnings-errors nil
      native-comp-warning-on-missing-source nil
      native-comp-jit-compilation t
      byte-compile-warnings '((not cl-functions obsolete))
      warning-suppress-log-types '((comp) (bytecomp) (files))
      warning-suppress-types '((comp) (bytecomp) (files)))

;;; Startup performance optimizations
;; No GC at all during startup; sane values are restored in `emacs-startup-hook'.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.8)

;;; Package system
;; Must be set here: `package-activate-all' runs between early-init and init.
;; The quickstart file bundles all package autoloads into one file.
(setq package-enable-at-startup t
      package-quickstart t
      load-prefer-newer t)

;;; Rendering / process performance
(setq read-process-output-max (* 4 1024 1024) ; LSP servers send big payloads
      process-adaptive-read-buffering nil
      inhibit-compacting-font-caches t
      fast-but-imprecise-scrolling t
      redisplay-skip-fontification-on-input t
      idle-update-delay 1.0
      frame-resize-pixelwise t)
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)

;;; UI suppression (must be early)
(setq inhibit-default-init t
      inhibit-startup-message t
      inhibit-startup-screen t
      inhibit-startup-echo-area-message "jwuersch" ;; You're pc user
      inhibit-splash-screen t
      inhibit-startup-buffer-menu t
      initial-scratch-message nil
      initial-major-mode 'fundamental-mode
      frame-inhibit-implied-resize t)

;;; Frame defaults (safe here)
(setq default-frame-alist
      '((background-color . "#13131a")
        (foreground-color . "#a0a0ae")
        (font . "Menlo-14")
        (min-height . 1)
        (min-width . 1)
        (height . 45)
        (width . 81)
        (internal-border-width . 1)
        (left-fringe . 8)
        (right-fringe . 0)
        (menu-bar-lines . 0)
        (tool-bar-lines . 0)
        (horizontal-scroll-bars . nil)
        (vertical-scroll-bars . nil)
        (mac-transparent-titlebar . t)
        (ns-transparent-titlebar . t)
        (fullscreen . maximized)))

;;; Avoid mode-line work before init (restored by profiles without punch-line)
(defvar mk/default-mode-line-format (default-value 'mode-line-format)
  "The standard Emacs mode line.")
(setq-default mode-line-format nil)

;;; Restore sane defaults after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist file-name-handler-alist-original
                  ;; 64MB: big enough for LSP traffic, small enough that a
                  ;; single GC pass stays short (no visible freeze).
                  gc-cons-threshold (* 64 1024 1024)
                  gc-cons-percentage 0.1)

            ;; Collect garbage while idle instead of while typing
            (run-with-idle-timer
             5 t
             (lambda ()
               (let ((inhibit-message t))
                 (garbage-collect))))

            (message "Emacs started in %.2f seconds with %d GCs"
                     (float-time
                      (time-subtract after-init-time before-init-time))
                     gcs-done)))

(provide 'early-init)
;;; early-init.el ends here
