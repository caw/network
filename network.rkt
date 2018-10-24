#lang racket
(require "user-data.rkt")

(struct node  (timeout timeout-arc trigger-arcs) #:transparent)
(struct arc (name trigger actions destination) #:transparent)
(define no-trigger-arcs '(()))

(define (logging str)
  (display (string-append "<< " str " >>\n")))

(define (narrate str)
  (display (string-append "NARRATION: " str)))

(define db (make-hash
            '((bp .100)
             (hr . 80)
             (sat .95)
             (temp 37.9))))
(define (db-set! key value)
  (hash-set! db key value))
(define (db-get key)
  (hash-ref db key))



(define-syntax (define-arc stx)
  (syntax-case stx (do: to:)
    [(_ #f)
     #' #f]
    [(_ (name trigger do: (actions ...) to: destination))
     #'(arc name trigger (lambda () actions ...) (delay destination))]))
       

(define-syntax (define-node stx)
  (syntax-case stx (timeout: timeout-arc: trigger-arcs:)
    ; timeout arc, but no trigger arcs
    [(_  name timeout: timeout timeout-arc: arc0)
     #'(define name (node timeout (define-arc arc0) #f))]
    ; no timeout, but trigger arcs
    [(_  name trigger-arcs: (arc1 ...))
     #'(define name (node #f #f (list (define-arc arc1)... )))]
    ; both timeout and trigger arcs
    [(_  name timeout: timeout timeout-arc: arc0 trigger-arcs: (arc1 ...))
     #'(define name (node timeout (define-arc arc0) (list (define-arc arc1)... )))]))

;; node with timeout and trigger arcs
(define-node test-node-1
  timeout: 5
  timeout-arc: ('a-test 'trig do: ((logging "test-node-1-timeout, going to test-node-2") (narrate h3)) to: test-node-2)
  trigger-arcs: (('a1 'exam do:  ((logging "got exam, going to test-node-3") (narrate h1)) to: test-node-3)
               ('a2 'history do: ((logging "got history, looping back to test-node-1") (narrate h3)) to: test-node-1)))
;; node with no timeout arc and 3 trigger arcs
(define-node test-node-2
  trigger-arcs: (('a1 'exam do:  ((logging "got exam, going to test-node-1") (narrate h1)) to: test-node-1)
               ('a2 'history do: ((logging "got history, looping back to test-node-2") (narrate h3)) to: test-node-2)
               ('a3 'ix do: ((logging "got ix, going to test-node-3") (narrate h3)) to: test-node-3)))
;; node with timeout arc and 1 trigger arc
(define-node test-node-3
  timeout: 3
  timeout-arc: ('a-test 'trig do: ((logging "test-node-3-timeout, going to test-node-1") (narrate h3)) to: test-node-1)
  trigger-arcs: (('a1 'exam do:  ((logging "got exam, going to test-node-2") (narrate h1)) to: test-node-2)))
;; node with timeout arc and no trigger arcs
(define-node test-node-4
  timeout: 8
  timeout-arc: ('a-test 'trig do: ((logging "test-node-4-timeout, going to test-node-1") (narrate h3)) to: test-node-1))

(define (do-actions arc)
  (let* ((actions (arc-actions arc)))
    (actions)))


(let ((arc (second (node-trigger-arcs test-node-1))))
  (do-actions arc))

(let ((arc (third (node-trigger-arcs test-node-2))))
  (do-actions arc))

(let ((arc (first (node-trigger-arcs test-node-3))))
  (do-actions arc))

;(let ((arc (first (node-trigger-arcs test-node-4))))
;  (do-actions arc))




