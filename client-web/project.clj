(defproject theproject "0.1.0-SNAPSHOT"
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [org.clojure/clojurescript "1.9.229"]
                 [reagent "0.6.1" :exclusions [cljsjs/react]]   ; exclusions below are explained here: https://github.com/reagent-project/reagent/issues/290
                 [cljsjs/react-with-addons "15.4.2-2"]
                 [cljsjs/react-dom "15.4.2-2" :exclusions [cljsjs/react]]
                 [cljsjs/react-dom-server "15.4.2-2" :exclusions [cljsjs/react]]
                 [re-frame "0.9.2"]
                 [re-frisk "0.3.2"]
                 [secretary "1.2.3"]
                 [kibu/pushy "0.3.6"]
                 ;; [org.clojars.stumitchell/clairvoyant "0.2.0"]    [day8/re-frame-tracer "0.1.1-SNAPSHOT"]
                 [cljs-ajax "0.5.8"]
                 [com.cognitect/transit-cljs "0.8.239"]
                 [day8.re-frame/http-fx "0.1.3"]
                 [com.andrewmcveigh/cljs-time "0.4.0"]
                 [org.clojure/core.match "0.3.0-alpha4"]
                 ]

  :plugins [[lein-cljsbuild "1.1.4"]]

  :min-lein-version "2.5.3"

  :source-paths ["src/clj"]

  :clean-targets ^{:protect false} ["resources/public/js/compiled" "target" "test/js"]

  :figwheel {
             :server-ip     "0.0.0.0"
             :server-port   3449
             :css-dirs ["resources/public/css"]
             :repl false :nrepl-host "0.0.0.0" :nrepl-port 7888
             ;; :hawk-options {:watcher :polling}
             }

  
  :repl-options {:nrepl-middleware [cemerick.piggieback/wrap-cljs-repl]}

  :profiles
  {:dev
   {:dependencies [[binaryage/devtools "0.8.2"]
                   [figwheel-sidecar "0.5.9"]
                   [com.cemerick/piggieback "0.2.1"]]

    :plugins      [[lein-figwheel "0.5.9"]
                   [lein-doo "0.1.7"]]
    }}

  :cljsbuild
  {:builds
   [{:id           "dev"
     :source-paths ["src/cljs"]
     :figwheel     {
                    :on-jsload "theproject.core/mount-root"
                    :websocket-url "wss://[[client-hostname]]:[[client-port]]/figwheel-ws"      ; was :websocket-host :js-client-host
                    }
     :compiler     {:main                 theproject.core
                    :output-to            "resources/public/js/compiled/app.js"
                    :output-dir           "resources/public/js/compiled/out"
                    :asset-path           "js/compiled/out"
                    :source-map-timestamp true
                    :preloads             [devtools.preload]
                    :external-config      {:devtools/config {:features-to-install :all}}
                    ;; :closure-defines {"clairvoyant.core.devmode" true}
                    }}

    {:id           "min"
     :source-paths ["src/cljs"]
     :compiler     {:main            theproject.core
                    :output-to       "resources/public/js/compiled/app.js"
                    :optimizations   :advanced
                    :closure-defines {goog.DEBUG false}
                    :pretty-print    false}}

    {:id           "test"
     :source-paths ["src/cljs" "test/cljs"]
     :compiler     {:main          theproject.runner
                    :output-to     "resources/public/js/compiled/test.js"
                    :output-dir    "resources/public/js/compiled/test/out"
                    :optimizations :none}}
    ]}
  )
