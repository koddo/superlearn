(ns theproject.events
  (:require [re-frame.core :as re-frame]
            [theproject.db :as db]
            [cljs.spec :as s]
            [cognitect.transit]
            ))

(re-frame/reg-event-db
 :initialize-db
 [check-spec-interceptor re-frame/debug]
 (fn  [_ _]
   db/default-db))

(re-frame/reg-event-db
 :set-active-panel
 [check-spec-interceptor re-frame/debug]
 (fn [db [_ active-panel]]
   (assoc db :active-panel active-panel)))
