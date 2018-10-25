#lang racket/gui

(require "network.rkt" "user-data.rkt")

(define frame (new frame%
                   [label "Example"]
                   [width 800]
                   [height 600]))

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
                 (handle-event 'exam))])

(new button%
     [parent frame]
     [label "Start"]
     [callback (lambda (button event)
                 (send timer start 1000))])

(new button%
     [parent frame]
     [label "Stop"]
     [callback (lambda (button event)
                 (send timer stop))])

(send frame show #t)

(define timer (new timer%
                   [notify-callback (lambda ()
                                      (handle-tick))]
                   [interval #f]))

(set-current-node! test-node-1)

