(ns theproject.events
  (:require [re-frame.core :as re-frame]
            [theproject.db :as db]
            [cljs.spec :as s]
            [cognitect.transit]
            [day8.re-frame.http-fx]
            [ajax.core :as ajax]
            ))

(def check-spec-interceptor
  (re-frame/after #(s/assert :theproject.db/good-state %)))



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

(re-frame/reg-event-fx
 :request-it
 [check-spec-interceptor re-frame/debug]
 (fn
   [{:keys [db]} _]
   {
    :http-xhrio {:method          :get
                 :uri             "http://vagrant.local:8080/rest"
                 :format          (ajax/json-request-format)
                 :response-format (ajax/json-response-format {:keywords? true}) 
                 :on-success      [:good-http-result]
                 :on-failure      [:bad-http-result]}
    :db db  ;  (assoc db :loading? true)
    }))

(re-frame/reg-event-db
  :good-http-result
  (fn [db [_ result]]
    (println result)
    db     ; (assoc db :api-result result)
    ))


(re-frame/reg-event-db
  :bad-http-result
  (fn [db eee]
    (println eee)
    db     ;; (assoc db :api-result result)
    ))




