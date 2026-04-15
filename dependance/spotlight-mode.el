;;; spotlight-mode.el --- Visual focus enhancement by adjusting buffer brightness -*- lexical-binding: t -*-

;; Author: Mikael Konradsson
;; Version: 2.0.0
;; Package-Requires: ((emacs "25.1"))
;; Keywords: faces, convenience
;; URL: https://github.com/konrad1977/spotlight-mode

;;; Commentary:

;; This package provides visual focus enhancement by darkening or lightening
;; buffer backgrounds based on window focus state.  The package allows users
;; to either darken the active buffer or lighten inactive buffers relative
;; to the theme's background color.
;;
;; Features:
;; - Darken active window's buffer background
;; - Lighten inactive windows' buffer backgrounds
;; - Automatic posframe detection and exclusion
;; - Configurable ignore lists for modes and buffers
;; - Always-darken lists for specific buffers
;; - Smart handling of split windows
;;
;; Usage:
;; (require 'spotlight-mode)
;; (spotlight-mode 1)
;;
;; Customization:
;; M-x customize-group RET spotlight-mode RET



;;; Code:
(require 'face-remap)
(require 'cl-lib)

(defgroup spotlight-mode nil
  "Customize spotlight-mode package."
  :group 'faces)

(defcustom spotlight-active-dim-percentage 10
  "Percentage by which to dim (darken) the active buffer background."
  :type 'integer
  :group 'spotlight-mode)

(defcustom spotlight-inactive-lighten-percentage 0
  "Percentage by which to lighten inactive buffer backgrounds."
  :type 'integer
  :group 'spotlight-mode)

(defcustom spotlight-always-darken-percentage 15
  "Percentage by which to darken buffers in always-darken lists."
  :type 'integer
  :group 'spotlight-mode)

(defvar-local spotlight-mode--cookie nil
  "Face remapping cookie for the current buffer.")

(defvar-local spotlight-mode--fringe-cookie nil
  "Face remapping cookie for the fringe in current buffer.")

(defvar-local spotlight-mode--linenumber-cookie nil
  "Face remapping cookie for the linenumber in current buffer.")

(defvar spotlight-mode-apply-effect-hook nil
  "Hook run after spotlight-mode effects are applied.")

(defvar spotlight-mode-remove-effect-hook nil
  "Hook run after spotlight-mode effects are removed.")

(defvar-local spotlight-mode--ignore-cache nil
  "Cache for whether the current buffer should be ignored.")

(defvar spotlight-mode--cached-bg-color nil
  "Cached background color of the current theme.")

(defcustom spotlight-mode-ignore-modes '(treemacs-mode vterm-mode eshell-mode shell-mode term-mode)
  "List of major modes where effects should not be applied."
  :type '(repeat symbol)
  :group 'spotlight-mode)

(defcustom spotlight-mode-ignore-buffers '("Messages" "dashboard" "*compilation*")
  "List of buffer names where effects should not be applied."
  :type '(repeat string)
  :group 'spotlight-mode)

(defcustom spotlight-mode-ignore-buffers-regexp '("posframe"
                                                  "\\*posframe\\*"
                                                  "\\*.*posframe.*\\*"
                                                  " \\*.*posframe.*\\*"
                                                  "vertico-posframe"
                                                  "messages"
                                                  "compilation")
  "List of regular expressions matching buffer names to ignore."
  :type '(repeat regexp)
  :group 'spotlight-mode)

(defcustom spotlight-mode-always-darken-buffers '("*compilation*")
  "List of buffer names that should always be darkened when shown."
  :type '(repeat string)
  :group 'spotlight-mode)

(defcustom spotlight-mode-always-darken-buffers-regexp '("\*which-key-\*"
                                                        "\*Flycheck.+\*"
                                                        "\*Flymake.+\*")
  "Regexps matching buffer names to always darken."
  :type '(repeat regexp)
  :group 'spotlight-mode)

(defcustom spotlight-mode-always-color-buffers '()
  "Alist of buffer names to specific colors.
Each element should be (BUFFER-NAME . COLOR-SPEC) where COLOR-SPEC is either:
- A color string for background: \"#1a1a2e\"
- A plist with :background and/or :foreground: (:background \"#1a1a2e\" :foreground \"#ffffff\")
Examples:
  '((\"*scratch*\" . \"#1a1a2e\")
    (\"*Messages*\" . (:background \"#16213e\" :foreground \"#00ff00\")))"
  :type '(alist :key-type string
                :value-type (choice string
                                   (plist :options ((:background string)
                                                   (:foreground string)))))
  :group 'spotlight-mode)

(defcustom spotlight-mode-always-color-buffers-regexp '()
  "Alist of regexps to specific colors.
Each element should be (REGEXP . COLOR-SPEC) where COLOR-SPEC is either:
- A color string for background: \"#1a1a2e\"
- A plist with :background and/or :foreground: (:background \"#1a1a2e\" :foreground \"#ffffff\")
Examples:
  '((\"\\\\*help.*\\\\*\" . (:background \"#0f3460\" :foreground \"#ffffff\"))
    (\"\\\\*compilation\\\\*\" . \"#1e1e2e\"))"
  :type '(alist :key-type regexp
                :value-type (choice string
                                   (plist :options ((:background string)
                                                   (:foreground string)))))
  :group 'spotlight-mode)

(defun spotlight-mode-should-ignore-p ()
  "Return t if current buffer should be ignored."
  (or (memq major-mode spotlight-mode-ignore-modes)
      (member (buffer-name) spotlight-mode-ignore-buffers)
      (cl-some (lambda (regexp)
                 (string-match-p regexp (buffer-name)))
               spotlight-mode-ignore-buffers-regexp)))

(defun spotlight-mode-should-always-darken-p ()
  "Return t if current buffer should always be darkened."
  (or (member (buffer-name) spotlight-mode-always-darken-buffers)
      (cl-some (lambda (regexp)
                 (string-match-p regexp (buffer-name)))
               spotlight-mode-always-darken-buffers-regexp)))

(defun spotlight-mode-get-custom-color ()
  "Get custom color for current buffer if configured.
Returns either a color string, a plist (:background COLOR :foreground COLOR),
or nil if no custom color is set."
  (or (cdr (assoc (buffer-name) spotlight-mode-always-color-buffers))
      (cl-some (lambda (entry)
                 (when (string-match-p (car entry) (buffer-name))
                   (cdr entry)))
               spotlight-mode-always-color-buffers-regexp)))

(defun spotlight-mode-color-to-rgb (color)
  "Convert COLOR (hex or name) to RGB components."
  (let ((rgb (color-values color)))
    (if rgb
        (mapcar (lambda (x) (/ x 256)) rgb)
      (error "Invalid color: %s" color))))

(defun spotlight-mode-rgb-to-hex (r g b)
  "Convert R G B components to hex color string."
  (format "#%02x%02x%02x" r g b))

(defun spotlight-mode-darken-color (color percent)
  "Darken COLOR by PERCENT."
  (let* ((rgb (spotlight-mode-color-to-rgb color))
         (darkened (mapcar (lambda (component)
                             (min 255
                                   (floor (* component (- 100 percent) 0.01))))
                           rgb)))
    (apply 'spotlight-mode-rgb-to-hex darkened)))

(defun spotlight-mode-lighten-color (color percent)
  "Lighten COLOR by PERCENT."
  (let* ((rgb (spotlight-mode-color-to-rgb color))
         (lightened (mapcar (lambda (component)
                               (min 255
                                  (floor (+ component
                                            (* (- 255 component)
                                                 (/ percent 100.0))))))
                             rgb)))
    (apply 'spotlight-mode-rgb-to-hex lightened)))


(defun spotlight-mode-get-background-color ()
  "Get the current theme's background color, using a cached value if available."
  (or spotlight-mode--cached-bg-color
      (setq spotlight-mode--cached-bg-color
            (or (face-background 'default) "#000000"))))

(defun spotlight-mode-count-visible-non-ignored-windows ()
  "Count number of visible windows that aren't in ignore lists."
  (let ((count 0))
    (dolist (window (window-list))
      (with-selected-window window
        (unless (spotlight-mode-should-ignore-p)
          (setq count (1+ count)))))
    count))

(defun spotlight-mode-count-unique-non-ignored-buffers ()
  "Count number of unique non-ignored buffers visible in windows."
  (let ((buffers '()))
    (dolist (window (window-list))
      (with-selected-window window
        (unless (spotlight-mode-should-ignore-p)
          (cl-pushnew (current-buffer) buffers))))
    (length buffers)))

(defun spotlight-mode-buffer-has-active-window-p (buffer)
  "Check if BUFFER is displayed in the currently active window."
  (eq (window-buffer (selected-window)) buffer))

(defun spotlight-mode-apply-effect (is-active)
  "Apply darkening or lightening effect based on whether window IS-ACTIVE."
  (when spotlight-mode--cookie
    (face-remap-remove-relative spotlight-mode--cookie))
  (when spotlight-mode--fringe-cookie
    (face-remap-remove-relative spotlight-mode--fringe-cookie))
  (when spotlight-mode--linenumber-cookie
    (face-remap-remove-relative spotlight-mode--linenumber-cookie))

  (let* ((bg-color (spotlight-mode-get-background-color))
         (custom-color (spotlight-mode-get-custom-color))
         ;; Parse custom color - can be string or plist
         (custom-bg (cond
                     ((stringp custom-color) custom-color)
                     ((listp custom-color) (plist-get custom-color :background))
                     (t nil)))
         (custom-fg (when (listp custom-color)
                      (plist-get custom-color :foreground)))
         (modified-bg (cond
                       ;; First priority: custom background if configured
                       (custom-bg custom-bg)
                       ;; Second priority: always darken
                       ((spotlight-mode-should-always-darken-p)
                        (spotlight-mode-darken-color bg-color spotlight-always-darken-percentage))
                       ;; Third priority: active window darkening
                       (is-active
                        (if (> spotlight-active-dim-percentage 0)
                            (spotlight-mode-darken-color bg-color spotlight-active-dim-percentage)
                          bg-color))
                       ;; Fourth priority: inactive window lightening
                       ((> spotlight-inactive-lighten-percentage 0)
                        (spotlight-mode-lighten-color bg-color spotlight-inactive-lighten-percentage))
                       ;; Default: unchanged background
                       (t bg-color))))

    ;; Apply background color changes
    (unless (string= modified-bg bg-color)
      (setq spotlight-mode--cookie
            (if custom-fg
                (face-remap-add-relative 'default :background modified-bg :foreground custom-fg)
              (face-remap-add-relative 'default :background modified-bg)))
      (setq spotlight-mode--fringe-cookie
            (face-remap-add-relative 'fringe :background modified-bg))
      (setq spotlight-mode--linenumber-cookie
            (if custom-fg
                (face-remap-add-relative 'line-number :background modified-bg :foreground custom-fg)
              (face-remap-add-relative 'line-number :background modified-bg))))
    ;; Apply only foreground if no background change but custom foreground exists
    (when (and (string= modified-bg bg-color) custom-fg)
      (setq spotlight-mode--cookie
            (face-remap-add-relative 'default :foreground custom-fg)))))

(defun spotlight-mode-remove-effect ()
  "Remove all effects from current buffer."
  (when spotlight-mode--cookie
    (face-remap-remove-relative spotlight-mode--cookie)
    (setq spotlight-mode--cookie nil))
  (when spotlight-mode--fringe-cookie
    (face-remap-remove-relative spotlight-mode--fringe-cookie)
    (setq spotlight-mode--fringe-cookie nil))
  (when spotlight-mode--linenumber-cookie
    (face-remap-remove-relative spotlight-mode--linenumber-cookie)
    (setq spotlight-mode--linenumber-cookie nil))

  (run-hooks 'spotlight-mode-remove-effect-hook))

(defun spotlight-mode-posframe-active-p ()
  "Check if any posframe is currently visible."
  (cl-some (lambda (frame)
             (and (frame-parameter frame 'posframe-buffer)
                  (frame-visible-p frame)))
           (frame-list)))

(defun spotlight-mode-window-switch-hook ()
  "Handle window focus change."
  (when (bound-and-true-p spotlight-mode)
    ;; Skip all processing if a posframe is active
    (unless (spotlight-mode-posframe-active-p)
      (let ((non-ignored-count (spotlight-mode-count-visible-non-ignored-windows))
            (unique-buffer-count (spotlight-mode-count-unique-non-ignored-buffers)))
        ;; Only apply effects if there are multiple non-ignored windows
        ;; OR if there are multiple unique buffers visible
        (if (or (> non-ignored-count 1) (> unique-buffer-count 1))
            ;; Update all visible buffers
            (dolist (buffer (buffer-list))
              (when (get-buffer-window buffer)
                (with-current-buffer buffer
                  (if (spotlight-mode-should-ignore-p)
                      (spotlight-mode-remove-effect)
                    ;; Check if this buffer is in the active window
                    (spotlight-mode-apply-effect
                     (spotlight-mode-buffer-has-active-window-p buffer))))))
          ;; Remove effects from all buffers if only one non-ignored window
          (dolist (buffer (buffer-list))
            (with-current-buffer buffer
              (spotlight-mode-remove-effect))))))))

(defun spotlight-mode-setup-hooks ()
  "Set up hooks for spotlight-mode."
  (add-hook 'window-selection-change-functions
            'spotlight-mode--window-selection-change-function)
  (add-hook 'window-configuration-change-hook
            'spotlight-mode-window-switch-hook)
  (add-hook 'post-command-hook 'spotlight-mode-window-switch-hook)

  (add-hook 'after-load-theme-hook #'spotlight-mode-invalidate-caches)
  (add-hook 'buffer-list-update-hook #'spotlight-mode-invalidate-caches))

(defun spotlight-mode-remove-hooks ()
  "Remove hooks for spotlight-mode."
  (remove-hook 'window-selection-change-functions
               'spotlight-mode--window-selection-change-function)
  (remove-hook 'window-configuration-change-hook
               'spotlight-mode-window-switch-hook)
  (remove-hook 'post-command-hook 'spotlight-mode-window-switch-hook)

  (remove-hook 'after-load-theme-hook #'spotlight-mode-invalidate-caches)
  (remove-hook 'buffer-list-update-hook #'spotlight-mode-invalidate-caches))

(defun spotlight-mode--window-selection-change-function (_)
  "Function to handle window selection change."
  (run-with-timer 0 nil #'spotlight-mode-window-switch-hook))

(defun spotlight-mode-toggle-effect ()
  "Toggle spotlight-mode effects for the current buffer."
  (interactive)
  (if spotlight-mode--cookie
      (spotlight-mode-remove-effect)
    (spotlight-mode-apply-effect (eq (selected-window) (get-buffer-window)))))

(defun spotlight-mode-set-active-dim-percentage (percentage)
  "Set the active buffer dim PERCENTAGE interactively."
  (interactive "nEnter active dim percentage: ")
  (setq spotlight-active-dim-percentage percentage)
  (spotlight-mode-window-switch-hook))

(defun spotlight-mode-invalidate-caches ()
  "Invalidate all caches used by spotlight-mode."
  (setq spotlight-mode--cached-bg-color nil)
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (setq spotlight-mode--ignore-cache nil))))

;;;###autoload
(define-minor-mode spotlight-mode
  "Minor mode to adjust buffer brightness based on window focus."
  :lighter " Spotlight"
  :global t
  (if spotlight-mode
      (progn
        (spotlight-mode-setup-hooks)
        ;; ;; Use both hooks to ensure we catch all window selection changes
        ;; Apply immediately
        (spotlight-mode-window-switch-hook))
    (spotlight-mode-remove-hooks)

    ;; Remove effects from all windows
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (spotlight-mode-remove-effect)))))

(provide 'spotlight-mode)
;;; spotlight-mode.el ends here
