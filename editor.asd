;;;; editor.asd

(asdf:defsystem #:editor
  :description "Describe editor here"
  :author "Silas Vedder"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :depends-on (#:mcclim)
  :components ((:file "package")
               (:file "editor")))
