;;; mk-ide.el --- Features every common editor has (VS Code style keys) -*- lexical-binding: t; -*-
;;; Commentary:
;; Things VS Code / JetBrains / Sublime users expect, mapped to the same keys
;; (s- = Cmd, M- = Option).  The file explorer (s-b) lives in mk-treemacs.el.
;;
;;   s-P / s-p       Command palette / Quick open file
;;   s-F             Search in the whole project
;;   s-O / s-T       Go to symbol in file / in project
;;   F12 / S-F12     Go to definition / Find references
;;   F2 / M-F        Rename symbol / Format document
;;   s-M             Problems panel
;;   C-`             Toggle terminal
;;   M-up / M-down   Move line(s)       M-S-up / M-S-down  Duplicate line(s)
;;   s-K             Delete line        M-z               Toggle word wrap
;;   M-s-[ / M-s-]   Fold / Unfold      M-s-0 / M-s-j     Fold all / Unfold all
;;   s-= s-- s-0     Zoom in / out / reset
;;   s-{ / s-} / s-w Previous buffer / Next buffer / Close buffer
;;; Code:

(declare-function eglot-managed-p "eglot")
(declare-function eglot-format-buffer "eglot")
(declare-function toggle-vterm "mk-term")
(declare-function mk/toggle-flycheck-errors "mk-development")

;;; Command palette, quick open, search
(keymap-global-set "s-P" #'execute-extended-command)
(keymap-global-set "s-p" #'project-find-file)
(keymap-global-set "s-F" #'consult-ripgrep)
(keymap-global-set "s-O" #'consult-imenu)

(use-package consult-eglot
  :defer t
  :bind ("s-T" . consult-eglot-symbols))

;;; Code navigation (works with eglot, falls back to dumb-jump)
(keymap-global-set "<f12>" #'xref-find-definitions)
(keymap-global-set "S-<f12>" #'xref-find-references)
(keymap-global-set "M-<f12>" #'xref-go-back)

(with-eval-after-load 'eglot
  (keymap-set eglot-mode-map "<f2>" #'eglot-rename))

(defun mk/format-buffer ()
  "Format the buffer with the language server, or re-indent it."
  (interactive)
  (if (and (fboundp 'eglot-managed-p) (eglot-managed-p))
      (eglot-format-buffer)
    (save-excursion (indent-region (point-min) (point-max)))))
(keymap-global-set "M-F" #'mk/format-buffer)

(keymap-global-set "s-M" #'mk/toggle-flycheck-errors)

;;; Terminal
(keymap-global-set "C-`" #'toggle-vterm)

;;; Line editing
(use-package drag-stuff
  :defer t
  :config
  (keymap-set drag-stuff-mode-map "M-<up>" #'drag-stuff-up)
  (keymap-set drag-stuff-mode-map "M-<down>" #'drag-stuff-down))

(defun mk/duplicate-line-up ()
  "Duplicate the current line or region and keep point on the upper copy."
  (interactive)
  (let ((col (current-column)))
    (duplicate-dwim)
    (move-to-column col)))

(defun mk/duplicate-line-down ()
  "Duplicate the current line or region and move point to the lower copy."
  (interactive)
  (let ((col (current-column))
        (lines (if (use-region-p)
                   (count-lines (region-beginning) (region-end))
                 1)))
    (duplicate-dwim)
    (unless (use-region-p)
      (forward-line lines)
      (move-to-column col))))

(keymap-global-set "M-S-<up>" #'mk/duplicate-line-up)
(keymap-global-set "M-S-<down>" #'mk/duplicate-line-down)
(keymap-global-set "s-K" #'kill-whole-line)
(keymap-global-set "M-z" #'visual-line-mode)

;;; Code folding (hs-minor-mode is enabled in prog-mode)
(with-eval-after-load 'hideshow
  (keymap-set hs-minor-mode-map "M-s-[" #'hs-hide-block)
  (keymap-set hs-minor-mode-map "M-s-]" #'hs-show-block)
  (keymap-set hs-minor-mode-map "M-s-0" #'hs-hide-all)
  (keymap-set hs-minor-mode-map "M-s-j" #'hs-show-all))

;;; Zoom (the whole frame, like other editors)
(keymap-global-set "s-=" (lambda () (interactive) (global-text-scale-adjust 1)))
(keymap-global-set "s--" (lambda () (interactive) (global-text-scale-adjust -1)))
(keymap-global-set "s-0" (lambda () (interactive) (global-text-scale-adjust 0)))

;;; Buffers (no tab bar)
(keymap-global-set "s-{" #'previous-buffer)
(keymap-global-set "s-}" #'next-buffer)
;; s-w closes the whole frame by default on macOS
(keymap-global-set "s-w" #'kill-current-buffer)

;;; Right click menu
(context-menu-mode 1)

;;; Reopen the files of the last session (lazily, to keep startup fast)
(use-package desktop
  :ensure nil
  :custom
  (desktop-dirname (expand-file-name "var/" user-emacs-directory))
  (desktop-path (list (expand-file-name "var/" user-emacs-directory)))
  (desktop-restore-eager 5)          ; the rest is restored while idle
  (desktop-load-locked-desktop 'check-pid)
  (desktop-save t)
  (desktop-restore-frames nil)       ; keep the frame layout from early-init
  (desktop-auto-save-timeout 60)
  :config
  ;; Never save/restore the tab bar with the buffers
  (add-to-list 'desktop-minor-mode-table '(tab-line-mode nil))
  (desktop-save-mode 1))

;;; Emmet (div.class>ul>li*3 then C-j) for HTML, CSS and JSX
(use-package emmet-mode
  :defer t
  :hook ((html-ts-mode mhtml-mode css-ts-mode tsx-ts-mode) . emmet-mode)
  :custom
  (emmet-expand-jsx-className? t))

(provide 'mk-ide)
;;; mk-ide.el ends here
