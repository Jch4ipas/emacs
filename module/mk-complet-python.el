;;; mk-complet-python.el --- Python environments and tests -*- lexical-binding: t; -*-
;;; Commentary:
;;   pet          : finds the environment of the project (.venv, venv,
;;                  poetry, pipenv, conda, uv...) and makes the REPL
;;                  (C-c C-p), eglot and the debugger use its Python
;;   python-pytest: C-c r in a Python file opens the pytest menu (all
;;                  tests, this file, the test at point, last failed...)
;;; Code:

(use-package pet
  :hook (python-base-mode . pet-mode))

(use-package python-pytest
  :defer t
  :commands python-pytest-dispatch
  :custom (python-pytest-confirm nil))

(add-hook 'mk/project-task-functions
          (lambda () (and (derived-mode-p 'python-base-mode) #'python-pytest-dispatch)))

(provide 'mk-complet-python)
;;; mk-complet-python.el ends here
