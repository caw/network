#lang racket
(define-struct node  (timeout timeout-arc arcs) #:transparent #:mutable)
(define-struct arc (name trigger actions destination) #:transparent)

(define logging display)
(define narrate display)
(define h1 "H1")
(define h3 "H3")
(define no-arcs '(()))

(define-syntax (define-arc stx)
  (syntax-case stx (do: to:)
    [(_ ())
     #' #f]
    [(_ (name trigger do: (actions ...) to: destination))
     #'(make-arc name trigger (lambda () actions ...) destination)]))
       

(define-syntax (define-node stx)
  (syntax-case stx (timeout: timeout-arc: other-arcs:)
    [(_  name timeout: timeout timeout-arc: arc0 other-arcs: (arc1 ...))
     #'(define name (make-node timeout (define-arc arc0) (list (define-arc arc1)... )))]))


(define s1 'foo)



(define-arc ('a1 'trigger do: ((logging "init-mode-timed-out") (narrate h1)) to: s1))
(define-arc ('a2 'history do: ((logging "history from a2") (narrate h3)) to: s1))


(define-node test-node-1
  timeout: 5
  timeout-arc: ('a-test 'trig do: ((logging "init-mode-timeout") (narrate h3)) to: s1)
  other-arcs: (('a1 'exam do:  ((logging "working") (narrate h1)) to: s1)
         ('a2 'history do: ((logging "history from a2") (narrate h3)) to: s1)))

(define-node test-node-2
  timeout: 0
  timeout-arc: ()
  other-arcs: (('a1 'exam do:  ((logging "working") (narrate h1)) to: s1)
         ('a2 'history do: ((logging "history from a2") (narrate h3)) to: s1)))

(define-node test-node-3
  timeout: 0
  timeout-arc: ('a-test 'trig do: ((logging "init-mode-timeout") (narrate h3)) to: s1)
  other-arcs: (('a1 'exam do:  ((logging "working") (narrate h1)) to: s1)))
         



(define (do-actions arc)
  (let* ((actions (arc-actions arc)))
    (actions)))


(let ((arc (second (node-arcs test-node-1))))
  (do-actions arc))

(let ((arc (second (node-arcs test-node-2))))
  (do-actions arc))


(let ((arc (first (node-arcs test-node-3))))
  (do-actions arc))