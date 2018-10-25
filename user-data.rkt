(module user-data racket
  (require "network.rkt")
  (provide h1 h2 h3)
  (provide test-node-1
           test-node-2
           test-node-3
           test-node-4
           test-node-5)
 

  (define h1 #<<;
You've just arrived in Ward 3W, respoinding to a call
from the nurse looking after Ms Jones:

"Thank heavens you're here - she's really confused and I
think she's had a stroke."

;
    )

  (define h2 #<<;
One of the patient's relatives rushes out of the room and
says "Doctor - please help my mother -- she's dying!"

;
    )

  (define h3 #<<;
The nurse tells you that Ms Jones is a 61 year old woman admitted
4 days ago for an umbilical hernia repair. She's got a past history of
hypertension, and is taking Enalapril 10mg daily, and is allergic to
penicillin

;
    )

  ;; node with timeout and trigger arcs
  (define-node test-node-1
    "tn-1"
    timeout: 5
    timeout-arc: ('a-test 'trig do: ((logging "test-node-1-timeout, going to test-node-3") (narrate h3)) to: test-node-3)
    trigger-arcs: (('a1 'exam do:  ((logging "got exam, going to test-node-3") (narrate h1)) to: test-node-3)
                   ('a2 'history do: ((logging "got history, looping back to test-node-1") (narrate h3)) to: test-node-1)))

  ;; node with no timeout arc and 3 trigger arcs
  (define-node test-node-2
    "tn-2"
    trigger-arcs: (('a1 'exam do:  ((logging "got exam, going to test-node-1") (narrate h1)) to: test-node-3)
                   ('a2 'history do: ((logging "got history, looping back to test-node-2") (narrate h3)) to: test-node-2)
                   ('a3 'ix do: ((logging "got ix, going to test-node-3") (narrate h3)) to: test-node-3)))

  ;; node with timeout arc and 1 trigger arc
  (define-node test-node-3
    "tn-3"
    timeout: 3
    timeout-arc: ('a-test 'trig do: ((logging "test-node-3-timeout, going to test-node-1") (narrate h3)) to: test-node-4)
    trigger-arcs: (('a1 'exam do:  ((logging "got exam, going to test-node-4") (narrate h1)) to: test-node-4)
                   ('a2 'fever do: ((db-set! 'temp 100) (db-set! 'hr 180) (db-set! 'bp 75)) to: test-node-3)))

  ;; node with timeout arc and no trigger arcs
  (define-node test-node-4
    "tn-4"
    timeout: 2
    timeout-arc: ('a-test 'trig do: ((logging "test-node-4-timeout, going to test-node-5 (an end-node)") (narrate h3)) to: test-node-5))

  ;; end node
  (define-node test-node-5 end-node "en-1")

  (set-current-node! test-node-1)
  )