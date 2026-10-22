;;; mk-vc.el --- Version Control Configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; Configuration for version control systems in Emacs using Magit, Git Gutter,

;;; Code:

(use-package transient
  :defer t)

(use-package magit
  :defer t
  :bind (("C-x g" . magit-status)
         ("C-c g" . magit-file-dispatch))
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package git-timemachine
  :defer t
  :commands (git-timemachine git-timemachine-toggle))

(use-package diff-hl
  :demand t
  :hook ((magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh)
         (dired-mode . diff-hl-dired-mode))
  :custom
  (diff-hl-side 'left)
  (diff-hl-disable-on-remote t)
  (diff-hl-update-async t)              ; run git in the background
  (diff-hl-margin-symbols-alist '((insert . "┃")
                                  (delete . "┃")
                                  (change . "┃")
                                  (unknown . "?")
                                  (ignored . "i")))
  :config
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1)              ; update while typing, not only on save
  (when (display-graphic-p)
    (diff-hl-margin-mode 1)))


;;
;; (use-package blamer
;;   :commands blamer-mode
;;   :config
;;   (setq blamer-tooltip-function 'blamer-tooltip-author-info)
;;   (setq blamer-view 'overlay
;;         blamer-type 'overlay-popup
;;         blamer-max-commit-message-length 270
;;         blamer-force-truncate-long-line nil
;;         blamer-show-avatar-p t
;;         blamer-author-formatter " ✎ %s "
;;         blamer-commit-formatter "● \'%s\' ● ")
;;   :custom
;;   (blamer-idle-time 1.0)
;;   :custom-face
;;   (blamer-face ((t :foreground "#E46876"
;;                    :height 130
;;                    :bold t
;;                    :italic t))))
;;

;;; Provide
(provide 'mk-vc)
;;; mk-vc.el ends here.
