(ns theproject.core)

;; add this to an ns where you use macros:
;; (:require-macros [theproject.core :as theproject :refer [my-add-macro-example]])

;; (defmacro my-add-macro-example
;;   [a b]
;;   `(+ ~a ~b))


;; https://groups.google.com/d/msg/clojure/fti0eJdPQJ8/CUOETpSJAQAJ
;; like (s/keys :req-un [::name ::active-panel])
;; but doesn't allow anything else, protects from having :actvie-pnael key by accident
(defmacro only-keys
  [& {:keys [req req-un opt opt-un] :as args}]
  `(s/merge (s/keys ~@(apply concat (vec args)))
            (s/map-of ~(set (concat req
                                    (map (comp keyword name) req-un)
                                    opt
                                    (map (comp keyword name) opt-un)))
                      cljs.core/any?)))

