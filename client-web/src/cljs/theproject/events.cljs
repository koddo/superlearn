(ns theproject.events
  (:require [re-frame.core :as re-frame]
            [theproject.db :as db]
            [cljs.spec :as s]
            [cognitect.transit]
            [day8.re-frame.http-fx]
            [ajax.core :as ajax]
            [cljs-time.core :as cljs-time]
            [cljs-time.format]
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
                 :uri             "/rest"
                 :format          (ajax/json-request-format)
                 :response-format (ajax/json-response-format {:keywords? true}) 
                 :on-success      [:good-http-result]
                 :on-failure      [:bad-http-result]}
    :db db  ;  (assoc db :loading? true)
    }))

(re-frame/reg-event-db
 :good-http-result
 [check-spec-interceptor re-frame/debug]
 (fn [db [_ result]]
   (assoc db :cards (:cards result))
   ))

(re-frame/reg-event-db
 :bad-http-result
 [check-spec-interceptor re-frame/debug]
 (fn [db e]
   (println e)
   db     ;; (assoc db :api-result result)
   ))


(re-frame/reg-event-fx
 :post-it
 [check-spec-interceptor re-frame/debug]
 (fn [{:keys [db]} [_ front back]]
   {:http-xhrio {:method          :post
                 :uri             "/rest"
                 :params          { :the_user_id 4 :the_prev_revision_id nil :new_front front :new_back back :new_due_date (cljs-time.format/unparse (cljs-time.format/formatters :basic-date) (cljs-time/now)) }
                 :timeout         5000
                 :format          (ajax/json-request-format)
                 :response-format (ajax/json-response-format {:keywords? true})
                 :on-success      [:good-post-result]
                 :on-failure      [:bad-post-result]}
    :db db
    }))

(re-frame/reg-event-db
 :good-post-result
 [check-spec-interceptor re-frame/debug]
 (fn [db [_ result]]
   db      ;; (assoc db :cards (:cards result))
   ))


(re-frame/reg-event-db
 :bad-post-result
 [check-spec-interceptor re-frame/debug]
 (fn [db e]
   (println e)
   db     ;; (assoc db :api-result result)
   ))

