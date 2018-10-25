(module network racket
  (require "user-data.rkt")
  (require "utilities.rkt")
  
  (provide set-network-finished!
           network-finished?
           handle-event
           handle-tick)
  

  (struct task (task arguments when) #:transparent)
  
 
    
  (define sim-running-time 0)
  (define time-in-current-node 0)
  (define current-node (start-node))
  (define (set-current-node! node)
    (set! current-node node))
  (define (current-node-name)
    (node-string-name current-node))
  (define network-finished #f)
  (define (set-network-finished! flag)
    (set! network-finished flag))
  (define (network-finished?)
    network-finished)
    
  (define (schedule-task task)
    (print task))

  (define (has-timeout? node)
    (node-timeout node))

  (define (has-trigger-arcs? node)
    (node-trigger-arcs node))

  (define (timed-out? node)
    (and (has-timeout? node) (>= time-in-current-node (node-timeout node))))

  (define (end-node? node)
    (equal? (substring (node-string-name node) 0 2) "en"))
       
  (define (handle-tick)
    (set! sim-running-time (+ sim-running-time 1))
    (set! time-in-current-node (+ time-in-current-node 1))
    ; update the display
    (logging (string-append "Time: " (number->string sim-running-time)))
    ; handle end-node
    (logging (string-append "Testing for end-node: node = " (node-string-name current-node)))
    (cond
      [(end-node? current-node)
       (begin
         (logging "End-node reached")
         (set-network-finished! #t)
         )]
      [(timed-out? current-node)
       (let* ([arc (node-timeout-arc current-node)]
              [actions (arc-actions arc)]
              [destination-node (force (arc-destination arc))])
         (display "doing timeout actions\n")
         (actions)
         (set-current-node! destination-node)
         (set! time-in-current-node 0))]
      ; handle 'tick as an event (loopback to current node on an arc, for example)
      [else
       (handle-event 'tick)]))

  (define (handle-event event)
    (when (has-trigger-arcs? current-node)
      (case event
        ['tick (display "handling tick as an arc trigger")]
        [else
         (let* ([arcs (node-trigger-arcs current-node)]
                [matching-arc (filter (lambda (a) (eq? (arc-trigger a) event)) arcs)])
           (when (not (null? matching-arc))
             (when (> (length matching-arc) 1)
               (logging "More than one arc matched"))
             (let ([match (car matching-arc)])
               (logging (symbol->string event))
               (let ([actions (arc-actions match)])
                 (actions))
               (set! time-in-current-node 0)
               (set-current-node! (force (arc-destination match))))))])))
   
  )


