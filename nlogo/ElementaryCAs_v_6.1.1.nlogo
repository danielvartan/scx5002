breed   [cells cell]
globals [rule          ;;  a list of booleans
         history       ;;  a list of lists of booleans
         scroll?       ;;whether or not the view needs to scroll
         scroll-offset]

to startup setup end
to setup
  clear-all
  set scroll? false
  set scroll-offset 0
  resize-world 0 (visible-size - 1) 0 (world-height - 1)
  set-rule  set-default-shape cells "square"
  reset-ticks
  set history (list initial-condition)
  ask patches [set plabel-color sky]
  setup-table display-history
  go
end

to set-rule
  set rule-code max list 0 (min list rule-code 255)
  set rule encode 3 rule-code
end

to-report initial-condition report
  ifelse-value random-start?
    [n-values world-width [1 = random 2]]
   ;;; this line in  v5.3 [n-values world-width [? = max-pxcor – 2 – floor (world-width / 2)]] changed to the line below
    [n-values world-width [ ?1 -> ?1 = max-pxcor - 2 - floor (world-width / 2) ]]
end

to go
    if [pcolor] of patch 0 30 = 7 [hide-table]
    tick
    step display-history
    if one-of [pcolor] of patches with [pycor = min-pycor] != 7 [set scroll? true]
end

to step set history lput new-state history end

to go-steps [n] repeat n [step tick] display-history end

to-report new-state       ;; with appropriate padding at ends
  let these last history  ;; for calculating the new middle
  set these ifelse-value circular?
     [(sentence  (last these) these (first these))]
     [(sentence (first these) these  (last these))]
  let n length these - 2    let i 0   let next []
  while [i < n]
    [set next lput (eval-bfn rule (sublist these i (i + 3))) next
     set i i + 1]
  ifelse circular? [report next]  ;; otherwise make the list bigger
                   [report (sentence (first next) next (last next))]
end

;;;;;;;;;;;  displaying the space-time diagram  ;;;;;;;;;;;;;

to display-history
  ifelse scroll?
  [
    set scroll-offset scroll-offset + 1
    let n (length history) - 1
    ask patches [set pcolor grey + 2]
    ;;; this line in v5.3, foreach n-values (min list n world-height) [min-pycor + ?] changed to line below
    foreach n-values (min list n world-height) [ ?1 -> min-pycor + ?1 ]
    ;;; this line in v5.3 [display-row (max-pycor – ?) (item (? + scroll-offset) history)] changed to line below
    [ ?1 -> display-row (max-pycor - ?1) (item (?1 + scroll-offset) history) ]
  ]
  [
    let n (length history) - 1
    ask patches [set pcolor grey + 2]
    ;;; this line in v5.3 foreach n-values (min list n world-height) [min-pycor + ?] changed to line below
    foreach n-values (min list n world-height) [ ?1 -> min-pycor + ?1 ]
    ;;; this line in v5.3 [display-row (max-pycor – ?) (item (?) history)] changed to line below
    [ ?1 -> display-row (max-pycor - ?1) (item (?1) history) ]
  ]
  ask patches with [pxcor > max-pxcor - 4 and pcolor != grey + 2][set pcolor white]
  ask patches [set plabel ifelse-value (pcolor != grey + 2 and
    pxcor = max-pxcor and 0 = (max-pycor - pycor + scroll-offset) mod 5)
  [max-pycor - pycor + scroll-offset] [""]]
  display
end

to display-row [row-ycor values]
  let offset floor ((length values - world-width) / 2)
  ask patches with [pycor = row-ycor]
    [set pcolor ifelse-value (item (pxcor + offset) values)
                             [black] [white]]
end

;;;;;;;;;;;  text representation of current state  ;;;;;;;;;;;;;
;;              ... as a list, e.g. [1 0 1 0 0 1]

to-report current-state report to-binary last history end

to set-state [state]
  set state (map [ ?1 -> ?1 = 1 ] state)
  while [length state < visible-size] ;; pad both sides
    [set state fput false lput false state]
  set state sublist state 0 visible-size
  set history lput state history
  display-history
end

;; These two reporters are just conveniences for display alignment.
;; Use them like "set-state on-right [1]", from the command line.

to-report on-left [state]
  while [length state < visible-size]
        [set state lput 0 state] ;; pad right
  report state
end

to-report on-right [state]
  while [length state < visible-size]
        [set state fput 0 state] ;; pad left
  report state
end

;;;;;;;;;;;  editing the cell states  ;;;;;;;;;;;;;

to edit
  if rule-code != decode rule [set-rule update-rule-table display]
  if length history < 31 or [pcolor] of patch 0 40 != 7 [show-table]
  if mouse-down?
    [ifelse round mouse-ycor = 41
       [let m round mouse-xcor
         if 2 < m and m < 34 ;and odd?
          [ ask cells-on patch mouse-xcor mouse-ycor [toggle]
            let i (m - 3) / 4
           set rule replace-item i rule (not item i rule)
           set rule-code decode rule]]
       [if round mouse-ycor = 0
          [ask cells-on patch mouse-xcor mouse-ycor [toggle]]]
     update-rule-table display wait 0.2]
end

to toggle
  let offset floor ((length (last history) - world-width) / 2)
  set color ifelse-value (color = black) [white] [black]
  set history lput (replace-item (offset + pxcor)
                    (last history) (color = black))
              butlast history
end

;;;;;;;;;;;  displaying and editing the rule table  ;;;;;;;;;;;;;

to-report cell-at [d-x d-y] report one-of cells-on patch-at d-x d-y end
to-report nbhd report (list (cell-at 1 0) self (cell-at -1 0)) end

to-report table-patches ;; in order!
  report map [ ?1 -> patch (first ?1) (last ?1) ]
    [[ 3 43] [ 7 43] [ 11 43] [ 15 43] [19 43] [23 43] [27 43] [31 43]]
end

to setup-table
  ask patch-set table-patches
    [ask (patch-set patch-at -1 0 self patch-at 1 0)
         [sprout-cells 1 [hide-turtle]]]
  foreach n-values 8 [ ?1 -> ?1 ]
    [ ?1 -> ask patch (3 + 4 * ?1) 41 [sprout-cells 1 [hide-turtle]]
     ask cells-on item ?1 table-patches [make-index-label (15 - ?1)] ]
end

to make-index-label [index]
  let bits reverse encode 2 index ;; reverse to read left-to-right
  foreach [0 1 2] [ ?1 -> ask item ?1 nbhd
                      [set color ifelse-value (item ?1 bits) [black] [white]] ]
end

to show-table
  ask patches
    [set pcolor grey + 2 set plabel ""
     ask cells-here [show-turtle]
     set plabel-color ifelse-value (pycor = 37) [black] [white]]
  update-rule-table  display
end

to hide-table
  ask patches with [pycor > 29]
   [ask cells-here [hide-turtle]
    set plabel-color sky set plabel ""]
  display-history
end

to update-rule-table
  foreach n-values 8 [ ?1 -> ?1 ]
   [ ?1 -> ask cells-on patch (3 + 4 * ?1) 41
     [set color ifelse-value (item ?1 rule) [black] [white]]
    ask patch (3 + 4 * ?1) 39
     [set plabel ifelse-value (item ?1 rule) [1] [0]] ]
  ask patch 32 37
   [set plabel-color black
    set plabel (word "= " rule-code " in base 10")]
end

;;;;;;;;;;;  the rule coding and evaluation machinery  ;;;;;;;;;;;;;

to-report eval-bfn [fn-code args]
  let l length fn-code
  report ifelse-value (l = 1)
     [last fn-code]
     [ifelse-value first args
       [eval-bfn (sublist fn-code 0 (l / 2)) (butfirst args)]
       [eval-bfn (sublist fn-code (l / 2) l) (butfirst args)]]
end

to-report encode [r n] ;; 'r' for arity
  report pad-to-length (2 ^ r) binary-list n
end

to-report binary-list [n] report
;; integer n represented as a list of booleans, where item i is the (2^i)'s bit.
;; to read the list as a 'normal' binary number (with the low bit on the right)
;; replace true by 1, false by 0
  ifelse-value (n < 1)
    [ [] ]  [lput (odd? n) binary-list (floor (n / 2))]
end

to-report pad-to-length [n a-list]
  if length a-list > n [error "list too long!"]
  report ifelse-value (length a-list >= n)
           [a-list]  [pad-to-length n (fput false a-list)]
end

to-report decode [a-bool-list] ;; decimal representation
  report ifelse-value (empty? a-bool-list) [0]
           [2 ^ (length a-bool-list - 1)
              * (ifelse-value first a-bool-list [1] [0])
              ;;; I deleted the brackets around (first a-bool-list) and placed them (iflse ....[0])
            + decode butfirst a-bool-list]
end

to-report to-binary [a-bool-list]  ;; true/false --> 1/0
  report map [ ?1 -> ifelse-value ?1 [1] [0] ] a-bool-list end

to-report from-binary [a-number-list] ;; 1/0 --> true/false
  report map [ ?1 -> ?1 = 1 ] a-number-list end

to-report even? [n] report n mod 2 = 0 end
to-report odd?  [n] report n mod 2 = 1 end
@#$#@#$#@
GRAPHICS-WINDOW
357
15
925
381
-1
-1
7.0
1
12
1
1
1
0
1
1
1
0
79
0
50
1
1
1
Current time step
30.0

BUTTON
8
118
93
153
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
123
283
310
316
rule-code
rule-code
0
255
110.0
1
1
NIL
HORIZONTAL

BUTTON
8
168
94
202
Go 1
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
10
215
95
249
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
122
211
307
244
circular?
circular?
1
1
-1000

SWITCH
125
363
305
396
random-start?
random-start?
0
1
-1000

TEXTBOX
14
10
297
52
Elementary Cellular Automata
18
95.0
1

TEXTBOX
13
40
330
74
One dimension, two cell states, three neighbors
11
0.0
1

TEXTBOX
122
167
342
209
If circular? is on, the cell lattice wraps around left to right.  If off, the lattice extends infinitely off-screen.
11
4.0
1

TEXTBOX
123
329
344
364
Random initial conditions or a single black cell?
11
4.0
1

TEXTBOX
122
264
366
291
Wolfram code of the CA update function.
11
4.0
1

TEXTBOX
173
89
246
109
Settings
14
0.0
1

TEXTBOX
10
90
104
110
Procedures
14
0.0
1

BUTTON
10
263
96
296
Edit Rule
edit
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
122
121
300
154
visible-size
visible-size
10
200
80.0
1
1
NIL
HORIZONTAL

TEXTBOX
60
434
360
551
tente osseguintes CA elementares\nregras 0, 32, 160 e 232 -> Classe 1\nregras -> 4, 108, 218 e 250 -> Classe 2\nregras 22, 30, 126, 150 e 182 -> Classe 3\nregra - 110 -> Classe 4
10
0.0
1

@#$#@#$#@
## Elementary Cellular Automata
This model presents one-dimensional CAs with two-state cells in three-cell neighborhoods. Following Stephen Wolfram, who invented them in the early 1980s, these are called _elementary_ CAs (ECAs).

This model shows how to assign _Wolfram code_ numbers to all 256 possible cellular automaton rules for discrete one-dimensional spaces (a horizontal row or _lattice_) of two-state (black/white) cells, each with three neighbors: nearest left, self, and nearest right. (Our convention is that each cell is its own 'middle neighbor' -- this may seem awkward at first, but it makes the description of a CA much simpler overall.)   Using this model, you can experiment with these systems by interactively editing the state of each cell, as well as the ECA rule itself.

An ECA _rule_ is a finite function. It can be thought of as a look-up table, consistently assigning a single 'output' -- one of the two possible Boolean values -- to each of the eight possible 'inputs', which are ordered combinations (_permutations_) of three Boolean values. These Boolean values are, depending on context, either called `true` and `false`, black and white, or 1 and 0. For each cell, on each time step, the inputs to the rule are the Boolean-valued _states_ of the cells in that cell's neighborhood. The rule's output becomes the cell's new state on the next step. All cells' states are updated simultaneously. By convention, the older states are displayed above the newer ones, with the current lattice shown at the bottom of the display. This makes a picture called a _space-time diagram_, where time runs down the vertical axis of the display.

## How to use the model
The family of elementary cellular automata is conceptually quite simple. The only parameters are the rule, the initial conditions, and the size of the space. All of these parameters are accessible from the Interface tab.

The **visible-size** slider sets the number of cells shown in the display. The position of the **circular?** switch determines whether or not this visible lattice is wrapped around into a circle, making the rightmost visible cell the left neighbor of the leftmost visible cell. If **circular?** is set **On**, then **visible-size** is the total size of the lattice. On the other hand, if **circular?** is set **Off**, then the lattice extends infinitely to the left and right. In this case, you can't actually see the 'invisible' cells off-screen, but they really are there in NetLogo's memory, and will affect the patterns produced by the CA.

The **rule-code** slider lets you choose an ECA rule by its Wolfram code number, from 0 to 255. Alternatively, you can edit the individual bits of the rule table directly, as described below.

The **random-start?** switch, when set **On**, causes a random initial state to be chosen for all the visible cells, essentially by flipping a coin for each cell, when the system is reset by clicking the **setup** button. If **random-start?** is **Off**, then the initial condition will be a single black cell in the center of an otherwise all-white cell lattice.

The **go** button lets you edit the rule and cell states with the mouse, or simply steps the CA system though time, depending on the position of the **edit?** switch.  When **edit?** is **On** and the **go** button is active, you can click on the current cells at the bottom of the display to toggle their states. You can similarly toggle the output bits of the rule table: the resulting binary number is translated into a decimal Wolfram code, and is also used directly (by the `eval-bfn` procedure) to calculate new cell states. Alternatively, if **edit?** is set **Off**, then **go** just advances the ECA through time, repeatedly calculating new lattice states and displaying them in the space-time diagram. The **go 1** button does the same thing as **go**, but only for a single step -- it is only really useful when the **edit?** switch is **Off**.

The current time step is shown at the top of the display. In the space-time diagram, every fifth row of cells is numbered (in bright green) with its corresponding time step. You can 'run' the CA system for a specific number of steps without the (relatively slow) animation by turning up the speed slider in the toolbar and typing, for example,

     go-steps 999

into the input line of the Command Center. Other commands are provided too. If you want to see the current lattice state as a list of 0s and 1s, just type

     show current-state

To set the system state from the Command Center, type (for example)

     set-state [1 0 1 0 1]

If you give a list with fewer bits than the cycle length, both ends will be padded with (`false`, white) zeros to fit the width of the display. To pad only one end, so that the new pattern is aligned to the left or right of the lattice, use a command like

     set-state on-right [1]

## NetLogo tricks
Although patches and turtles are used for display and input, all the CA computation for this model is done indirectly, with list structures containing native Boolean values. Although this approach complicates the code somewhat, it has a few important advantages: it lets us show the rule editor or resize the display without destroying the patterns, it is considerably faster (especially for large systems), and  it lets us work with infinite lattices. If you'd like to see a simpler and more direct implementation, one (titled **CA 1D Elementary**) is available in the Models Library.

If you're wondering how we can represent an infinite lattice in our finite computers, the essential assumption is that, at any particular time step, all cells in the lattice except for a central segment of finite size (the 'interesting' part) are uniformly either black or white, so we need not represent them all explicitly. These infinite lattices have a form like (for example)

    [... 1 1 0 0 1 0 1 0 1 0 ...]

where the "`...`" on the left means an infinite sequence of 1s, and the "`...`" on the right means an infinite sequence of 0s. What actually happens when **circular?** is set **Off** is that the list representing the CA state grows by two elements (one left, one right) on each step. These new elements are taken to be the same Boolean values as the previous ends of the list. Although the list is potentially infinite, we can only run our program a finite number of steps. So, of course, the representation always remains finite. Because information can only propagate in an ECA at a maximum speed of one cell per tick, the 'interesting' central segment of the lattice is always represented. This use of an _infinite data structure_ is very helpful in the study of cellular automata, because it lets us avoid arbitrary size constraints which could affect the behavior of the CA.

## CREDITS AND REFERENCES

This model is part of the Cellular Automata series of the Complexity Explorer project.

Main Author:  Max Orhai

Contributions from: Melanie Mitchell and Vicki Niu

Netlogo:  Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

The elementary cellular automata were first described by Stephen Wolfram:
Wolfram, S. (1983). _Statistical Mechanics of Cellular Automata_. Reviews of Modern Physics 55 (3): 601–644. doi:10.1103/RevModPhys.55.601

## HOW TO CITE

If you use this model, please cite it as: "ElementaryCAs" model, Complexity Explorer project, http://complexityexplorer.org

## COPYRIGHT AND LICENSE

Copyright 2016 Santa Fe Institute.
This model is licensed by the Creative Commons Attribution-NonCommercial-ShareAlike International ( http://creativecommons.org/licenses/ ). This states that you may copy, distribute, and transmit the work under the condition that you give attribution to ComplexityExplorer.org, and your use is for non-commercial purposes.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

circle
false
0
Circle -7500403 true true 0 0 300

square
false
4
Rectangle -7500403 true false 0 0 300 300
Rectangle -1184463 true true 30 30 270 270
Polygon -16777216 false false 30 30 270 30 270 270 30 270

triangle
true
0
Polygon -7500403 true true 150 0 30 225 270 225
Polygon -16777216 false false 30 225 150 0 270 225 30 225
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 120 195
Line -7500403 true 150 150 180 195
@#$#@#$#@
0
@#$#@#$#@
