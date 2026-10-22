;;; mk-complet-devops.el --- Docker and remote servers -*- lexical-binding: t; -*-
;;; Commentary:
;;   M-x docker : containers, images, volumes, networks and compose:
;;                start, stop, logs, shell in a container (also in C-c SPC)
;;   TRAMP      : open /ssh:user@server:/path with C-x C-f to edit a
;;                remote file; /docker:container:/path for a container.
;;                Tuned to be fast; no language server is started on
;;                remote files (mk-lsp.el).
;; YAML (Kubernetes, compose, CI) and Dockerfiles use their tree-sitter
;; modes and language servers from mk-lsp.el.
;;; Code:

(use-package docker
  :defer t
  :commands docker
  :custom
  (docker-show-messages nil))

(use-package tramp
  :ensure nil
  :defer t
  :custom
  (tramp-verbose 2)                     ; only warnings and errors
  (tramp-default-method "ssh")
  (tramp-use-scp-direct-remote-copying t)
  (tramp-copy-size-limit (* 1024 1024)) ; bigger files: scp instead of inline
  (remote-file-name-inhibit-locks t)
  (remote-file-name-inhibit-auto-save-visited t)
  :config
  ;; Start remote processes (grep, git, compile) without the shell setup
  (connection-local-set-profile-variables
   'mk/remote-direct-async-process '((tramp-direct-async-process . t)))
  (connection-local-set-profiles '(:application tramp :protocol "ssh")
                                 'mk/remote-direct-async-process)
  ;; VC (used by diff-hl and the mode line) on every remote file is slow;
  ;; magit still works on remote repositories
  (setq vc-ignore-dir-regexp (format "\\(?:%s\\)\\|\\(?:%s\\)"
                                     vc-ignore-dir-regexp tramp-file-name-regexp)))

(with-eval-after-load 'magit
  (setq magit-tramp-pipe-stty-settings 'pty))

(provide 'mk-complet-devops)
;;; mk-complet-devops.el ends here
