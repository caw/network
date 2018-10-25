(module nodes racket
  (provide define-node
           node
           arc)

  (struct node  (string-name timeout timeout-arc trigger-arcs) #:transparent)
  (struct arc (name trigger actions destination) #:transparent)
  
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