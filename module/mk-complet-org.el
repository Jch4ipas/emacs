;;; mk-complet-org.el --- Notes, tasks and documents -*- lexical-binding: t; -*-
;;; Commentary:
;; Notes and tasks live in ~/org:
;;   C-c c   capture: write a task or a note from anywhere, C-c C-c to file it
;;   C-c a   agenda: the tasks of the week and every TODO
;;   C-c n   open the notes file
;; Org files look cleaner with org-modern (bullets, tags, tables).
;;
;; Markdown: C-c C-v shows a preview of the file (pandoc) in Emacs.
;;; Code:

(use-package org
  :ensure nil
  :defer t
  :bind (("C-c c" . org-capture)
         ("C-c a" . org-agenda)
         ("C-c n" . mk/org-open-notes))
  :custom
  (org-directory "~/org")
  (org-default-notes-file "~/org/notes.org")
  (org-agenda-files '("~/org"))
  (org-todo-keywords '((sequence "TODO(t)" "EN-COURS(e)" "|" "FAIT(f)" "ANNULÉ(a)")))
  (org-log-done 'time)                  ; note when a task is done
  (org-startup-indented t)
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-return-follows-link t)
  (org-src-fontify-natively t)
  (org-src-tab-acts-natively t)
  (org-edit-src-content-indentation 0)
  (org-capture-templates
   '(("t" "Tâche" entry (file+headline "~/org/taches.org" "À faire")
      "* TODO %?\n  %U\n  %a")
     ("n" "Note" entry (file+headline "~/org/notes.org" "Notes")
      "* %?\n  %U")
     ("c" "Cours" entry (file+olp+datetree "~/org/cours.org")
      "* %?\n  %U")))
  :config
  (make-directory org-directory t))

(defun mk/org-open-notes ()
  "Open the notes file."
  (interactive)
  (find-file org-default-notes-file))

(use-package org-modern
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda)))

;;; Markdown preview (pandoc), shown with eww next to the file
(defun mk/markdown-preview ()
  "Render the current Markdown buffer with pandoc and show it in eww."
  (interactive)
  (unless (executable-find "pandoc")
    (user-error "pandoc is not installed (brew install pandoc)"))
  (let ((html (make-temp-file "preview-" nil ".html"))
        (dir default-directory))
    (call-process-region (point-min) (point-max) "pandoc" nil nil nil
                         "--from=gfm" "--to=html5" "--standalone"
                         "--metadata" (concat "title=" (buffer-name))
                         "--output" html)
    (let ((default-directory dir))
      (save-selected-window
        (select-window (or (window-in-direction 'right) (split-window-right)))
        (eww-open-file html)))))

(with-eval-after-load 'markdown-ts-mode
  (keymap-set markdown-ts-mode-map "C-c C-v" #'mk/markdown-preview))

(provide 'mk-complet-org)
;;; mk-complet-org.el ends here
