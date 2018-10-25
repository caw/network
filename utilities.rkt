(module utilities racket/gui
  (provide logging
           narrate
           db-set!
           db-get
           db-data
           define-node
           node
           node-string-name
           node-timeout
           node-trigger-arcs
           node-timeout-arc
           arc
           arc-trigger
           arc-actions
           arc-destination)

  (struct node  (string-name timeout timeout-arc trigger-arcs) #:transparent)
  (struct arc (name trigger actions destination) #:transparent)
  (struct task (task arguments when) #:transparent)
  
  (define-syntax (define-arc stx)
    (syntax-case stx (do: to:)
      [(_ #f)
       #' #f]
      [(_ (name trigger do: (action ...) to: destination))
       #'(arc name trigger (lambda () action ...) (delay destination))]))
       

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

  )