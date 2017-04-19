(ns theproject.core-test
  (:require [cljs.test :refer-macros [deftest testing is]]
            [theproject.core :as core]))

(deftest fake-test
  (testing "fake description"
    (is (= 1 1))))
