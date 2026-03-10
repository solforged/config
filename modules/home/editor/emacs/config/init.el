;;; init.el --- Dotfiles Emacs bootstrap -*- lexical-binding: t; -*-

(setq user-emacs-directory (file-name-directory (or load-file-name buffer-file-name)))

(defconst dotfiles-emacs-source-file
  (expand-file-name "emacs.org" user-emacs-directory))

(defconst dotfiles-emacs-host-facts-file
  (expand-file-name "host-facts.el" user-emacs-directory))

(defconst dotfiles-emacs-cache-directory
  (expand-file-name
   "emacs/"
   (or (getenv "XDG_CACHE_HOME")
       (expand-file-name ".cache/" (getenv "HOME")))))

(defconst dotfiles-emacs-state-directory
  (expand-file-name
   "emacs/"
   (or (getenv "XDG_STATE_HOME")
       (expand-file-name ".local/state/" (getenv "HOME")))))

(defconst dotfiles-emacs-expanded-org-file
  (expand-file-name "expanded-config.org" dotfiles-emacs-cache-directory))

(defconst dotfiles-emacs-tangled-file
  (expand-file-name "init-tangled.el" dotfiles-emacs-cache-directory))

(when (file-exists-p dotfiles-emacs-host-facts-file)
  (load dotfiles-emacs-host-facts-file nil 'nomessage))

(require 'cl-lib)
(require 'seq)
(require 'subr-x)

(defconst dotfiles-emacs-include-regexp
  "^#\\+include:[[:space:]]+\"\\([^\"]+\\)\"")

(defun dotfiles-emacs--normalize-source-file (file)
  "Return FILE as an absolute path rooted in the current Emacs config."
  (expand-file-name file))

(defun dotfiles-emacs--collect-source-files (file &optional seen)
  "Return FILE and any recursively included Org files."
  (let* ((source-file (dotfiles-emacs--normalize-source-file file))
         (truename (file-truename source-file)))
    (when (member truename seen)
      (error "Recursive Org include detected: %s" truename))
    (with-temp-buffer
      (insert-file-contents source-file)
      (goto-char (point-min))
      (let ((files (list source-file))
            (base-directory (file-name-directory source-file)))
        (while (not (eobp))
          (let ((line (buffer-substring-no-properties
                       (line-beginning-position)
                       (line-end-position))))
            (when (string-match dotfiles-emacs-include-regexp line)
              (setq files
                    (append
                     files
                     (dotfiles-emacs--collect-source-files
                      (expand-file-name (match-string 1 line) base-directory)
                      (cons truename seen))))))
          (forward-line 1))
        (delete-dups files)))))

(defun dotfiles-emacs--expand-org-file (file &optional seen)
  "Return FILE with #+include directives expanded recursively."
  (let* ((source-file (dotfiles-emacs--normalize-source-file file))
         (truename (file-truename source-file)))
    (when (member truename seen)
      (error "Recursive Org include detected: %s" truename))
    (with-temp-buffer
      (insert-file-contents source-file)
      (goto-char (point-min))
      (let ((base-directory (file-name-directory source-file))
            (chunks '()))
        (while (not (eobp))
          (let ((line (buffer-substring-no-properties
                       (line-beginning-position)
                       (line-end-position))))
            (if (string-match dotfiles-emacs-include-regexp line)
                (push
                 (dotfiles-emacs--expand-org-file
                  (expand-file-name (match-string 1 line) base-directory)
                  (cons truename seen))
                 chunks)
              (push line chunks)))
          (forward-line 1))
        (string-join (nreverse chunks) "\n")))))

(defun dotfiles-emacs--latest-source-modification-time ()
  "Return the newest modification time among the literate source files."
  (seq-reduce
   (lambda (latest file)
     (let ((mtime (file-attribute-modification-time (file-attributes file))))
       (if (time-less-p latest mtime) mtime latest)))
   (dotfiles-emacs--collect-source-files dotfiles-emacs-source-file)
   '(0 0 0 0)))

(defun dotfiles-emacs-config-stale-p ()
  "Return non-nil when the tangled config needs to be rebuilt."
  (or (not (file-exists-p dotfiles-emacs-tangled-file))
      (time-less-p
       (file-attribute-modification-time
        (file-attributes dotfiles-emacs-tangled-file))
       (dotfiles-emacs--latest-source-modification-time))))

(defun dotfiles-emacs-tangle-config ()
  "Assemble and tangle the literate config into the cache directory."
  (interactive)
  (require 'org)
  (make-directory dotfiles-emacs-cache-directory t)
  (make-directory dotfiles-emacs-state-directory t)
  (with-temp-file dotfiles-emacs-expanded-org-file
    (insert (dotfiles-emacs--expand-org-file dotfiles-emacs-source-file)))
  (let ((org-confirm-babel-evaluate nil))
    (org-babel-tangle-file
     dotfiles-emacs-expanded-org-file
     dotfiles-emacs-tangled-file
     "emacs-lisp"))
  dotfiles-emacs-tangled-file)

(defun dotfiles-emacs-tangle-config-if-needed ()
  "Tangle the literate config when the cached output is missing or stale."
  (when (dotfiles-emacs-config-stale-p)
    (dotfiles-emacs-tangle-config)))

(defun dotfiles-emacs-open-config ()
  "Open the literate Emacs config."
  (interactive)
  (find-file dotfiles-emacs-source-file))

(defun dotfiles-emacs-reload-config ()
  "Retangle and reload the literate Emacs config."
  (interactive)
  (dotfiles-emacs-tangle-config)
  (load dotfiles-emacs-tangled-file nil 'nomessage)
  (message "Reloaded %s" dotfiles-emacs-source-file))

(dotfiles-emacs-tangle-config-if-needed)
(load dotfiles-emacs-tangled-file nil 'nomessage)

;;; init.el ends here
