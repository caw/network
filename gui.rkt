#lang racket/gui
(require "network.rkt")
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


(define timer (new timer%
                   [notify-callback (lambda ()
                                      (unless (network-finished?)
                                        (handle-tick)))]
                   [interval #f]))

(send frame show #t)




