(ns theproject.config
  (:require [cljs.spec :as s]))


(def debug?
  ^boolean js/goog.DEBUG)

(s/check-asserts true)

