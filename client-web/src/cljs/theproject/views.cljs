(ns theproject.views
  (:require [re-frame.core :as re-frame]
            [ajax.core :as ajax]
            [clojure.string :as string]
            [reagent.core :as reagent]
            ))

(let [name (re-frame/subscribe [:name])
      cards (re-frame/subscribe [:cards])
      ]
  (defn home-panel []
    [:div (str "Hello from " @name ". This is the Home Page.")
     [:div [:a {:href "/about"} "go to About Page"]]
     [:input {
              :type "button"
              :value "get request"
              :on-click #(re-frame/dispatch [:request-it])
              }]
     (into [:div]
             (for [c @cards]
               ^{:key c}
               [:p (str c)]
               ;; [:span
               ;;  [:input {:type "checkbox"
               ;;           :checked (boolean (<sub [:move x]))
               ;;           :on-change #(>evt [:set-move [x (-> % .-target .-checked)]])
               ;;           }]
               ;;  [:label x]
               ;;  ]
               ))
     ]))

;; about

(defn about-panel []
  [:div "This is the About Page."
   [:div [:a {:href "/"} "go to Home Page"]]])


;; main

(defn- panels [panel-name]
  (case panel-name
    :home-panel [home-panel]
    :about-panel [about-panel]
    [:div]))

(defn show-panel [panel-name]
  [panels panel-name])


(defn main-panel []
  (let [active-panel (re-frame/subscribe [:active-panel])]
    (fn []
      [show-panel @active-panel])))
