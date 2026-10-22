;;; mk-complet-dotnet.el --- C# and .NET -*- lexical-binding: t; -*-
;;; Commentary:
;;   csharp-ts-mode (built in) + csharp-ls, installed with
;;   `dotnet tool install -g csharp-ls' (eglot finds it on its own).
;;   C-c r in a .NET project opens the dotnet menu (sharper): build,
;;   run, test, NuGet packages, new project...
;;; Code:

(defun mk/dotnet-project-p ()
  "Return non-nil if the current buffer belongs to a .NET project."
  (or (derived-mode-p 'csharp-mode 'csharp-ts-mode)
      (locate-dominating-file
       default-directory
       (lambda (dir) (directory-files dir nil "\\.\\(csproj\\|sln\\|slnx\\)\\'" t)))))

(use-package sharper
  :defer t
  :commands sharper-main-transient)

(add-hook 'mk/project-task-functions
          (lambda () (and (mk/dotnet-project-p) #'sharper-main-transient)))

(provide 'mk-complet-dotnet)
;;; mk-complet-dotnet.el ends here
