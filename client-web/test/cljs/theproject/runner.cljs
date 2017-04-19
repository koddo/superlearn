(ns theproject.runner
    (:require [doo.runner :refer-macros [doo-tests]]
              [theproject.core-test]))

(doo-tests 'theproject.core-test)
