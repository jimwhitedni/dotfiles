;;; config.el --- Spacemacs Layer Config File
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq vc-follow-symlinks t)
(setq emerge-diff-options "--ignore-all-space")
(setq magit-repository-directories '("~/src/"))
(setq sentence-end-double-space nil)
(setq-default c-basic-offset 4)
(setq-default require-final-newline t)

;; Centralize backup location.
(setq backup-directory-alist '(("~/.spacemacs.d/backups")))
(setq vc-make-backup-files t ; Enable backups for versioned files.
      version-control t      ; Use version numbers for backups.
      kept-new-versions 10   ; Number of newest versions to keep.
      kept-old-versions 0    ; Number of oldest versions to keep.
      delete-old-versions t  ; Don't ask to delete excess backup versions.
      backup-by-copying t)   ; Copy all files, don't rename them.

(setq enh-ruby-add-encoding-comment-on-save nil)
(add-hook 'enh-ruby-mode-hook
          (lambda ()
            (setq-local enh-ruby-indent-level 2)
            (setq-local enh-ruby-deep-indent-paren nil)
            (setq-local enh-ruby-deep-arglist nil)))

(add-to-list 'auto-mode-alist
             '(
               "\\(?:\\.rb\\|ru\\|rake\\|thor\\|jbuilder\\|gemspec\\|podspec\\|/\\(?:Gem\\|Rake\\|Cap\\|Thor\\|Vagrant\\|Guard\\|Pod\\|Fast\\)file\\)\\'"
               .
               enh-ruby-mode
               ))

;; YouCompleteMe hooks.
(add-hook 'c++-mode-hook #'ycmd-init)
(add-hook 'c-mode-hook #'ycmd-init)
(add-hook 'js2-mode-hook #'ycmd-init)
(add-hook 'python-mode-hook #'ycmd-init)
(add-hook 'swift-mode-hook #'icmd-init)
(add-hook 'company-mode-hook #'company-ycmd-setup)