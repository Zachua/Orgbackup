;;; init.el --- Spacemacs Initialization File
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;; Without this comment emacs25 adds (package-initialize) here
;; (package-initialize)

;; Increase gc-cons-threshold, depending on your system you may set it back to a
;; lower value in your dotfile (function `dotspacemacs/user-config')
(setq gc-cons-threshold 100000000)

(defconst spacemacs-version          "0.200.5" "Spacemacs version.")
(defconst spacemacs-emacs-min-version   "24.4" "Minimal version of Emacs.")

(if (not (version<= spacemacs-emacs-min-version emacs-version))
    (message (concat "Your version of Emacs (%s) is too old. "
                     "Spacemacs requires Emacs version %s or above.")
             emacs-version spacemacs-emacs-min-version)
  (load-file (concat (file-name-directory load-file-name)
                     "core/core-load-paths.el"))
  (require 'core-spacemacs)
  (spacemacs/init)
  (spacemacs/maybe-install-dotfile)
  (configuration-layer/sync)
  (spacemacs-buffer/display-info-box)
  (spacemacs/setup-startup-hook)
  (require 'server)
  (unless (server-running-p) (server-start)))

; 显示行号
;;(global-linum-mode 1)

;;设置光标样式
(global-company-mode t)
(setq-default cursor-type 'bar)

;;开启删除模式
(delete-selection-mode t)

;; 快速打开配置文件
(defun open-init-file()
  (interactive)
  (find-file "~/.emacs.d/init.el"))

;; 这一行代码，将函数 open-init-file 绑定到 <f2> 键上
(global-set-key (kbd "<f2>") 'open-init-file)

;;全屏显示
(setq initial-frame-alist(quote ((fullscreen . maximized))))

;;开启hungry delete mode
(require 'hungry-delete)
(global-hungry-delete-mode)



;;The following make-backup-file-name will store your files in dated directories (for example, ~/.backups/emacs/07/04/07/filename):
(defun make-backup-file-name (FILE)
  (let ((dirname (concat "~/.backups/emacs/"
                         (format-time-string "%y/%m/%d/"))))
    (if (not (file-exists-p dirname))
        (make-directory dirname t))
    (concat dirname (file-name-nondirectory FILE))))


;;快速打开最近文件
(require 'recentf)
(recentf-mode 1)
(global-set-key "\C-c\ \C-r" 'recentf-open-files)



;;;;;;;;;;;;python shell setting;;;;;;;;;;;;
;;set python shell-interpreter
(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i")
;;disable python warning info
(setq python-shell-prompt-detect-failure-warning nil)




;;;;;;;;;;;;;;;;;;;;;DIY org agenda;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "<f8>") 'org-agenda-list)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "<f7>") 'org-agenda)

(setq org-agenda-custom-commands
      '(
        ("w" . "ASSIGNMENTS")
        ("wa" "important&urgent" tags-todo "+PRIORITY=\"A\"" )
        ("wb" "important&not urgent" tags-todo "-Weekly-Monthly-Daily-Habits-Clocking+PRIORITY=\"B\"")
        ("wc" "unimportant&not urgent" tags-todo "+PRIORITY=\"C\"")
        ("wd" "All important&urgent" tags "+PRIORITY=\"A\"" )
        ("p" . "PROJECTS")
        ("pe" "emacs project" tags "Emacs")
        ("pw" "web project" tags "Web")
        ("pr" "Ruby project" tags "Ruby")
        ("pp" "Python project" tags "Python")
        ("pa" "Algorithm project" tags "Study")

        ("h" "Zach Study"
         (
          (tags-todo "Emacs")
          (tags-todo "Web")
          (tags-todo "Python")
          (tags-todo "Ruby")
          (tags "Study")
          (org-agenda-list nil nil 1)
          ))

          ("n" "Zach AGENDA"
           (
            (tags-todo "Work")
            (tags-todo "Career")
            (tags-todo "Life")
            ;; (tags-todo "-Maybe")
            ;; (tags-todo "Maybe")
            (org-agenda-list nil nil 1)
            ))
      ))

 (setq org-agenda-span 1
       org-agenda-start-day nil)
;; (setq org-agenda-start-on-weekday nil
;;  org-agenda-span 10
;;  org-agenda-start-day "-3d")

;;;;;;;;;;;;neotree in emacs;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'neotree-mode-hook
          (lambda ()
            (define-key evil-normal-state-local-map (kbd "q") 'neotree-hide)))

(require 'neotree)
(define-key neotree-mode-map (kbd "O") #'neotree-enter-horizontal-split)
(define-key neotree-mode-map (kbd "o") #'neotree-enter-vertical-split)
(global-set-key (kbd "<f3>") 'neotree-toggle)


;;;;;;;;;;;;;;each access to other window;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "C-;") 'other-window)
;;(setq org-startup-truncated nil)




;;;;;;;;;;;;;;;;;;;;;org-auto-clcok;;;;;;;;;;;;;;;;;;;;;;;;;;
(eval-after-load 'org
  '(progn
     (defun wicked/org-clock-in-if-starting ()
       "Clock in when the task is marked STARTED."
       (when (and (string= org-state "STARTED")
                  (not (string= org-last-state org-state)))
         (org-clock-in)))

     (add-hook 'org-after-todo-state-change-hook
               'wicked/org-clock-in-if-starting)

     (defadvice org-clock-in (after wicked activate)
       "Set this task's status to 'STARTED'."
       (org-todo "STARTED"))


     (defun wicked/org-clock-out-if-waiting ()
       "Clock out when the task is marked WAITING or PAUSED."
       (when (and (or (string= org-state "WAITING")
                      (string= org-state "PAUSED"))
                  (equal (marker-buffer org-clock-marker) (current-buffer))
                  (< (point) org-clock-marker)
                  (> (save-excursion (outline-next-heading) (point))
                     org-clock-marker)
                  (not (string= org-last-state org-state)))
         (org-clock-out)))

     (add-hook 'org-after-todo-state-change-hook
               'wicked/org-clock-out-if-waiting)))



;;;;;;;;;;;;;;;;;;;;;kill-other-buffer;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun kill-other-buffers()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer
        (delq (current-buffer)
              (remove-if-not 'buffer-file-name (buffer-list)))))

(global-set-key (kbd "C-x C-b") 'ibuffer)
;; Ensure ibuffer opens with point at the current buffer's entry.
(defadvice ibuffer
    (around ibuffer-point-to-most-recent) ()
    "Open ibuffer with cursor pointed to most recent buffer name."
    (let ((recent-buffer-name (buffer-name)))
      ad-do-it
      (ibuffer-jump-to-buffer recent-buffer-name)))
(ad-activate 'ibuffer)


(require 'ibuffer)
(global-set-key (kbd "<f4>") 'ibuffer)


;;;;;;;;;;;;;;;;Dired Mode;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;设定为默认递归删除目录
(setq dired-recursive-deletes 'always)
(setq dired-recursive-copies 'always)
;; 延迟加载
;;(with-eval-after-load 'dired
;;  (define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file))

;;启用 dired-x 可以让每一次进入 Dired 模式时，使用新的快捷键 C-x C-j 就可以进 入当前文件夹的所在的路径。
(require 'dired-x)
(require 'dired)
(global-set-key (kbd "<f1>") 'dired-jump)
(define-key dired-mode-map (kbd "u") 'dired-up-directory)
(define-key dired-mode-map (kbd "e") 'dired-display-file)
;;(global-unset-key "\t")
;;(define-key(current-global-map) "\t" nil)
;;(local-unset-key "\t")
;;(define-key (current-local-map) "\t" nil)
;;(define-key dired-mode-map (kbd "\t") 'other-window)



;;;;;;;;;;;;;;;;ibuffer Mode;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'ibuf-ext)
(require 'ibuffer)
(define-key ibuffer-mode-map (kbd "J") 'ibuffer-jump-to-buffer)
(define-key ibuffer-mode-map (kbd "j") 'ibuffer-forward-line)
(define-key ibuffer-mode-map (kbd "k") 'ibuffer-backward-line)


;;;;;;;;;;;;;;;;evil mode;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'evil-maps)
(define-key evil-insert-state-map (kbd "C-y") 'evil-paste-after)
(define-key evil-insert-state-map (kbd "C-e") 'evil-append-line)
(define-key evil-insert-state-map (kbd "C-a") 'evil-insert-line)
(define-key evil-insert-state-map (kbd "M-b") 'evil-backward-word-begin)
(define-key evil-insert-state-map (kbd "M-f") 'evil-forward-word-begin)
