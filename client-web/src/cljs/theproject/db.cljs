(ns theproject.db
  (:require [cljs.spec :as s]
            [cljs.core.match :refer-macros [match]])
  (:require-macros [theproject.core :refer [only-keys]]))


(s/def ::name string?)

;; (s/def ::panel #{:home-panel :about-panel})
;; (s/def ::card-panel (fn [] false))
;; (s/def ::active-panel (s/or ::panel ::card-panel))
;; (s/def ::active-panel #{:home-panel :about-panel :card-panel})
(s/def ::active-panel #(match %
                              :home-panel true
                              :about-panel true
                              [:card-panel _card_id] true   ; TODO: check id
                              :else false))

;; (s/def ::cards (s/map-of string? (fn [_] true)))
(s/def ::cards (s/coll-of map? :kind vector?))

;; TODO: fully qualified names instead of ::
(s/def ::good-state (only-keys :req-un [::name ::active-panel ::cards]))


(def default-db
  {:name "re-frame"
   :active-panel :home-panel
   :cards []
   })


