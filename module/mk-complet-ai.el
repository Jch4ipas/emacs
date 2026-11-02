;;; mk-complet-ai.el --- AI assistant (gptel) -*- lexical-binding: t; -*-
;;; Commentary:
;; gptel with the server of OpenCode: the EPFL RCP inference server
;; (OpenAI compatible API).  The default model is DeepSeek-V4.1-Flash
;; (fast and good at code); C-c i m switches to the others.  OpenCode's
;; Kimi-K2.7-Code is not allowed for this key (HTTP 403), it is kept at
;; the end of the list in case access is granted.
;;
;;   C-c i i   chat buffer (write, then C-c RET to send)
;;   C-c i s   send the region, or the buffer up to point, and insert the answer
;;   C-c i r   rewrite / refactor the region (shows a diff to accept)
;;   C-c i m   menu: model, system prompt, where the answer goes...
;;
;; The API key is read with auth-source, never from this file:
;;   macOS  : the keychain (internet password, server
;;            inference.rcp.epfl.ch, account apikey)
;;              security add-internet-password -U -a apikey -s inference.rcp.epfl.ch -w
;;   Windows: the encrypted file ~/.authinfo.gpg (see WINDOWS.org), line
;;              machine inference.rcp.epfl.ch login apikey password LA-CLÉ
;;; Code:

(use-package auth-source
  :ensure nil
  :defer t
  :config
  (when (eq system-type 'darwin)
    (add-to-list 'auth-sources 'macos-keychain-internet)))

(defun mk/gptel-epfl-key ()
  "Return the EPFL inference API key from auth-source."
  (require 'auth-source)
  (or (auth-source-pick-first-password :host "inference.rcp.epfl.ch" :user "apikey")
      (user-error "No API key for inference.rcp.epfl.ch in %s"
                  (if (eq system-type 'darwin) "the keychain" "~/.authinfo.gpg"))))

(use-package gptel
  :defer t
  :bind (("C-c i i" . gptel)
         ("C-c i s" . gptel-send)
         ("C-c i r" . gptel-rewrite)
         ("C-c i m" . gptel-menu))
  :custom
  (gptel-default-mode 'org-mode)        ; chat buffers in Org: code blocks, headings
  :config
  (setq gptel-backend (gptel-make-openai "EPFL"
                        :host "inference.rcp.epfl.ch"
                        :endpoint "/v1/chat/completions"
                        :stream t
                        :key #'mk/gptel-epfl-key
                        :models '(deepseek-ai/DeepSeek-V4.1-Flash
                                  zai-org/GLM-5.3-Flash
                                  openai/gpt-oss-120b
                                  Qwen/Qwen3.5-397B-A17B ; the largest, but ~20s
                                  moonshotai/Kimi-K2.7-Code))
        gptel-model 'deepseek-ai/DeepSeek-V4.1-Flash)
  (setf (alist-get 'default gptel-directives)
        "Tu es un assistant de programmation dans Emacs. Réponds en français, de façon concise. Explique le pourquoi, pas seulement le comment : l'utilisateur est apprenti développeur."))

(provide 'mk-complet-ai)
;;; mk-complet-ai.el ends here
