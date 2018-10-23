#lang racket/gui
(require "user-data.rkt")

(define-struct node (name timeout timeout-arc arcs) #:transparent #:mutable)
(define-struct arc (trigger actions destination) #:transparent)

(define (logging str)
  (display (string-append "<< " str " >>\n")))

(define (narrate str)
  (display (string-append "NARRATION: " str)))

(define no-arcs '(()))
(define sim-running-time 0)

(define db (make-hash
            '((bp .100)
             (hr . 80)
             (sat .95)
             (temp 37.9))))
(define (db-set! key value)
  (hash-set! db key value))
(define (db-get key)
  (hash-ref db key))

(define agenda '(()))
(define (perform-scheduled-events)
  (logging "doing scheduled events"))

(define (timed-out? node)
  (>= sim-running-time (node-timeout node)))
      
(define timer (new timer%
                   [notify-callback (lambda ()
                                      (set! sim-running-time (+ sim-running-time 1))
                                      (do-a-step 'tick))]
                   [interval #f]))

(define (do-a-step event)
  (case event
    ((tick) 
    
     (if (member (node-name current-node) end-states)
         (begin
           (logging "End reached")
           (send timer stop))
         (begin
           (logging (string-append "Time: " (number->string sim-running-time)))
           (if (timed-out? current-node)
               (let* ([arc (node-timeout-arc current-node)]
                      [actions (arc-actions arc)]
                      [destination-node (force (arc-destination arc))])
                 (display "doing timeout actions\n")
                 (actions)
                 (set! current-node destination-node))
               (let* ([arcs (node-arcs current-node)]
                      [matching-arc (filter (lambda (a) (eq? (arc-trigger a) event)) arcs)])
                 (when (not (null? matching-arc))
                   (begin
                     (let ([match (car matching-arc)])
                       (logging (symbol->string event))
                       (let ([actions (arc-actions match)])
                         (actions))
                       (set! current-node (force (arc-destination match)))))))))))))

(define (get-destination node)
  (let* ([arc (node-arcs node)]
         [destination (arc-destination arc)])
    (force destination)))  

(define-syntax (define-arc stx)
  (syntax-case stx ()
    [(_ name trigger (actions ...) destination)
     #'(define name (make-arc trigger (lambda () actions ...) destination))])) ;;; ****  MAYBE DON'T NEED (delay destination)

  
(define-syntax (set-arcs! stx)
  (syntax-case stx (timeout: rest:)
    [(_ node timeout timeout-arc rest arc0 arcs ...)
     #' (begin
          (set-node-timeout-arc! node timeout-arc)
          (set-node-arcs! node (list arc0 arcs ...)))]))

(define init-node (node "init" 5 #f no-arcs))
(define s1 (node "s1" 10 #f  no-arcs))
(define end-states '("s1"))

(define-arc a1 'trigger ((logging "init-mode-timed-out") (narrate h1)) s1)
(define-arc a2 'history ((logging "history from a2") (narrate h3)) s1)
(define-arc s1-node-a1 'trigger ((logging "s1 timed out") (db-set! 'bp 80) (narrate h2)) s1)

(set-arcs! init-node timeout: a1 rest: a2)
(set-arcs! s1 timeout: s1-node-a1 rest: '())

(define current-node init-node)
  