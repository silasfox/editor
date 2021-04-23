;;;; editor.lisp

(in-package #:editor)

(clim:define-application-frame editor ()
  ()
  (:pointer-documentation t)
  (:menu-bar editor-menubar)
  (:panes
   (newdoc :text-editor
           :width 600
           :height 400)
   (int :interactor
        :width 600
        :height 150))
  (:layouts (default
             (clim:vertically ()
               (clim-tab-layout:with-tab-layout ('clim-tab-layout:tab-page :name 'editor-layout :height 400)
                 ("Untitled" newdoc))
               int))))

(clim:make-command-table 'editor-menubar
                         :errorp nil
                         :menu '(("File" :menu editor-file-menu)))

(clim:make-command-table 'editor-file-menu
                         :errorp nil
                         :menu '(("New" :command com-new)
                                 ("Open" :command com-open)
                                 ("Save" :command com-save)
                                 ("Close" :command com-close)
                                 ("Quit" :command com-quit)))

(define-editor-command (com-quit :name t) ()
  (clim:frame-exit clim:*application-frame*))

(defun new-editor-tab (&optional (title "Untitled") (text ""))
  (clim-tab-layout:add-page (make-instance 'clim-tab-layout:tab-page :title title
                                                                     :pane (clim:make-pane 'clim:text-editor-pane
                                                                                           :value text))
                            (get-editor-layout-pane)))

(define-editor-command (com-new :name t) ()
  (new-editor-tab))

(defun get-editor-layout-pane ()
  (clim:find-pane-named clim:*application-frame* 'editor-layout))

(defun get-current-tab ()
  (clim-tab-layout:tab-layout-enabled-page (get-editor-layout-pane)))

(define-editor-command (com-close :name t) ()
  (clim-tab-layout:remove-page (get-current-tab)))

(defun file->string (pathname)
  (with-open-file (infile pathname :direction :input)
    (let ((text (make-string (file-length infile))))
      (read-sequence text infile)
      )
    text))

(defun string->file (string pathname)
  (with-open-file (outfile pathname :direction :output :if-exists :supersede)
    (princ string outfile)))

(define-editor-command (com-open :name t) ((filename 'pathname :default (merge-pathnames (user-homedir-pathname)
                                                                                         #P"untitled.txt")
                                                               :insert-default t))
  (new-editor-tab (file-namestring filename) (file->string filename)))

(define-editor-command (com-save :name t) ((filename 'pathname :default (merge-pathnames (user-homedir-pathname)
                                                                                        #P"untitled.txt")
                                                              :insert-default t))
  (let* ((current-tab (get-current-tab))
         (current-pane (clim-tab-layout:tab-page-pane current-tab))
         (new-name (file-namestring filename)))
    (string->file (clim:gadget-value current-pane) filename)
    (setf (clim-tab-layout:tab-page-title current-tab) new-name)))

(define-editor-command (com-eval :name t) ((sexp 'string))
  (eval (read-from-string sexp)))

(defun run ()
  (load "~/.edi/init")
  (clim:run-frame-top-level (clim:make-application-frame 'editor)))

(defun make ()
  (sb-ext:save-lisp-and-die #P"./.local/bin/edi" :executable t :toplevel #'run))
