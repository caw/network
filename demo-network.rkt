#lang racket
(require "user-data.rkt")
(require "network.rkt")

;; node with timeout and trigger arcs
(define-node test-node-1
  "tn-1"
  timeout: 5
  timeout-arc: ('a-test 'trig do: ((logging "test-node-1-timeout, going to test-node-2") (narrate h3)) to: test-node-2)
  trigger-arcs: (('a1 'exam do:  ((logging "got exam, going to test-node-3") (narrate h1)) to: test-node-3)
                 ('a2 'history do: ((logging "got history, looping back to test-node-1") (narrate h3)) to: test-node-1)))

;; node with no timeout arc and 3 trigger arcs
(define-node test-node-2
  "tn-2"
  trigger-arcs: (('a1 'exam do:  ((logging "got exam, going to test-node-1") (narrate h1)) to: test-node-1)
                 ('a2 'history do: ((logging "got history, looping back to test-node-2") (narrate h3)) to: test-node-2)
                 ('a3 'ix do: ((logging "got ix, going to test-node-3") (narrate h3)) to: test-node-3)))

;; node with timeout arc and 1 trigger arc
(define-node test-node-3
  "tn-3"
  timeout: 3
  timeout-arc: ('a-test 'trig do: ((logging "test-node-3-timeout, going to test-node-1") (narrate h3)) to: test-node-1)
  trigger-arcs: (('a1 'exam do:  ((logging "got exam, going to test-node-4") (narrate h1)) to: test-node-4)))

;; node with timeout arc and no trigger arcs
(define-node test-node-4
  "tn-4"
  timeout: 2
  timeout-arc: ('a-test 'trig do: ((logging "test-node-4-timeout, going to test-node-5 (an end-node)") (narrate h3)) to: test-node-5))

;; end node
(define-node test-node-5 'end-node)
 
(set-current-node! test-node-1)
