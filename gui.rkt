#lang racket/gui

(require "network.rkt")



(define frame (new frame% [label "Example"]))
(define sim-time (new message%
                 [parent frame]
                 [label "not started"]))
(define current-node (new message%
                          [parent frame]
                          [label "No node"]))
                         
(new button%
     [parent frame]
     [label "Examination"]
     [callback (lambda (button event)
                 (send sim-time set-label "Button click"))])

(new button%
     [parent frame]
     [label "Start"]
     [callback (lambda (button event)
                 (display "this will start the sim"))])

(send frame show #t)
(let ((msg "42")
      (target sim-time))
  
(send target set-label msg))