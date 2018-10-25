(module network racket/gui
  (provide define-node
           set-current-node!
           current-node-name
           db-set!
           db-data
           timer
           handle-tick
           handle-event
           logging
           narrate
           bind-gui)


  (struct node  (string-name timeout timeout-arc trigger-arcs) #:transparent)
  (struct arc (name trigger actions destination) #:transparent)

  (define sim-running-time 0)
  (define time-in-current-node 0)
  (define current-node #f)
  (define (set-current-node! node)
    (set! current-node node))
  (define (current-node-name)
    (node-string-name current-node))

  (define gui #f)
  (define (bind-gui gui)
    (set! gui gui))
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
  (define (db-data)
    (display db))

  (define (has-timeout? node)
    (node-timeout node))

  (define (has-trigger-arcs? node)
    (node-trigger-arcs node))

  (define (timed-out? node)
    (and (has-timeout? node) (>= time-in-current-node (node-timeout node))))

  (define (end-node? node)
    (eq? (substring (node-string-name node) 0 1) "en" ))

  (define timer (new timer%
                     [notify-callback (lambda ()
                                        (handle-tick))]
                     [interval #f]))
 
  (define (handle-tick)
    (set! sim-running-time (+ sim-running-time 1))
    (set! time-in-current-node (+ time-in-current-node 1))
    ; update the display
    (logging (string-append "Time: " (number->string sim-running-time)))
    ; handle end-node
    (cond
      [(end-node? current-node)
       (begin
         (logging "End-node reached")
         (send timer stop))]
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
       
  (define-syntax (define-arc stx)
    (syntax-case stx (do: to:)
      [(_ #f)
       #' #f]
      [(_ (name trigger do: (actions ...) to: destination))
       #'(arc name trigger (lambda () actions ...) (delay destination))]))
       

  (define-syntax (define-node stx)
    (syntax-case stx (end-node timeout: timeout-arc: trigger-arcs:)
      ; end node
      [(_  name end-node string-name)
       #'(define name (node string-name #f #f #f))]
      ; timeout arc, but no trigger arcs
      [(_  name string-name timeout: timeout timeout-arc: arc0)
       #'(define name (node string-name timeout (define-arc arc0) #f))]
      ; no timeout, but trigger arcs
      [(_  name string-name trigger-arcs: (arc1 ...))
       #'(define name (node string-name #f #f (list (define-arc arc1)... )))]
      ; both timeout and trigger arcs
      [(_  name string-name timeout: timeout timeout-arc: arc0 trigger-arcs: (arc1 ...))
       #'(define name (node string-name timeout (define-arc arc0) (list (define-arc arc1)... )))]))

   
  )


