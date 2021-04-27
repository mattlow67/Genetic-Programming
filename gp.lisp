#|
   Description:
	This program implements genetic programming, a concept that
	can be simply described as computer programming that mimics
	certain aspects of the process of evolution. In this case, the
	program generates a pool of 'creatures,' which are represented
	by 'genotypes' of simple linear expressions. For every generation,
	the two 'fittest' creatures are removed from the pool, mated, and
	returned to the next generation's pool with their two offspring. 
	The 'family,' initial to being placed in the succeeding generation's
	pool, is subjected to the genetic operators of crossover and mutation.
	50 generations are run in total. 	

   Contact Info:
	Matthew Low
	CPSC 481
	Prof. Charles Siska
	Weds 7-9:45PM
	mcorelow@csu.fullerton.edu
	CWID: 891556854
|#

;; global variables 
(defvar x nil)
(defvar y nil)
(defvar z nil)
(defvar generations (list))
;; 'fittest' family for every generation
(defvar parent1 nil)
(defvar parent2 nil)
(defvar child1 nil)
(defvar child2 nil)

;; the several functions that follow are used for generating expressions
(defun randomOperator()
	(let ((choose (random 3)))
		(cond ((= choose 0) '+)
			((= choose 1) '-)
			((= choose 2) '*))))

(defun randomVariable()
	(let ((choose (random 3)))
		(cond ((= choose 0) 'x)
			((= choose 1) 'y)
			((= choose 2) 'z))))


(defun randomDigit()
	(let ((choose (random 2)))
		(cond ((= choose 0) (- (random 9)))
			((= choose 1) (random 9)))))

(defun generateNestedExpr()
	;; random number of elements to be put in sublist/subtree
	(setq lExpr (+ 1 (random 3)))
	;; initialize temp list with a root operator
	(setq tList (list (randomOperator)))
	(dotimes (n lExpr)
		(setq tList (append tList
			;; TODO replace with (roll) for deeper lists
			(list (rollShort)))))
	tList)		

;; determines whether node will just be a node, or a parent for a subtree
(defun roll()
	(let ((choose (random 3)))
		(cond ((= choose 0) (randomDigit))
			((= choose 1) (randomVariable))
			((= choose 2) (generateNestedExpr)))))

;; node in sublist is restricted to digit or variable to prevent creating
;;	long expression
(defun rollShort()
	(let ((choose (random 2)))
		(cond ((= choose 0) (randomDigit))
			((= choose 1) (randomVariable)))))

(defun getIndex(expr)
	; gets random index from 1 to length(expr)
	(+ 1 (random (- (length expr) 1))))

(defun getIndexCell (cTree)
	; get random index of cell from 1 to length(cTree)
	(+ 1 (random (- (cell-count cTree) 1))))
	
(defun isVariable (cell)
	(setq isVar nil)
	(cond ((eq cell 'x) (setq isVar t))
	      ((eq cell 'y) (setq isVar t))
	      ((eq cell 'z) (setq isVar t)))
	isVar)

;; traverses each cell in a list (expr) and determines at random
;;	whether a node is to be mutated
(defun mutateCreature (expr)
	(setq iCell 0)			; current cell index
	(setq randNum 9)		; random number for comparison
					;	10% chance of mutation
	(loop for cCell in expr
		do
		    (if (= (random 10) randNum)		
			;; replace current cell with roll
			(setf (nth iCell expr) 
				(cond 
				      ;; root operator in expression
				      ((eq (first expr) (nth iCell expr))
					(randomOperator))
				      ;; current cell is parent of sublist
				      ((listp (nth iCell expr))
					(roll))
				      ;; current cell is variable
				      ((isVariable (nth iCell expr)) (roll))
				      ;; assumes cell is a digit
				      (t (roll)))
			))
			(setq iCell (+ 1 iCell)))
	expr)

;; generates creatures with random attributes (op's, var's, and expr's)
(defun populatePool()
    (let ((cPool (list)))
	;; add 'fit' family from previous generation
	(push parent1 cPool)
	(push parent2 cPool)
	(push child1 cPool)
	(push child2 cPool)

	;; add 46 more creatures to current pool
	(dotimes (n 46)
	   (let ((tcreature (list (randomOperator))))
		;; for each expr (creature), generate 1 to 4 random modules,
		;;	each of which will contain either an element or a
		;;	subtree
		(dotimes (i (+ 1 (random 4)))
			(setq tcreature (append tcreature (list (roll)))))
		(push tcreature cPool)))
    cPool
    )   
)

;; generates 50 generations' worth of creatures
(defun generateHistory() 
	(dotimes (n 50)
	   (setf *random-state* (make-random-state t))		; seed for random
	   ;; generate pool for current generation
	   (let ((cGeneration (populatePool)))
		(push cGeneration generations)))
)
	
(defun calculateFitness(expr fitCompare)
	(abs (- fitCompare (eval expr))))

(defun randomFitnessValue()
	(let ((choose (random 2)))
		(cond ((= choose 0) (- (random 500)))
			((= choose 1) (random 500)))))	

(defun printPool (pool)
	(print (listp pool))
	(loop for cCreature in pool
	    do
		(print cCreature))
	(print '--------------------------------------------------------))

(defun randomCreature ()
	(let ((tcreature (list (randomOperator))))
		;; for each expr (creature), generate 1 to 4 random modules,
		;;	each of which will contain either an element or a
		;;	subtree
		(dotimes (i (+ 1 (random 4)))
			(setq tcreature (append tcreature (list (roll)))))
	tcreature))

(defun copySublist (expr)
    (cond
	((not (listp expr)) expr)
	(t (let ((lx (copySublist (car expr)))
		 (rx (copySublist (cdr expr))))
		(cons lx rx)))))

(defun randomCellIndex (n)
	; gets random index from 1 to length(expr)
	(+ 2 (random (- n 1))))

(defun getSubtree (index tree)
	(nth index tree))

;;;------------------------------------------------------------------------	
;;; MAIN
(defun main()

	;; stuff for writing out to file
	(with-open-file (str "data.txt"
                     :direction :output
                     :if-exists :supersede
                     :if-does-not-exist :create)

	(setq genNum 1)		; current generation number

	;; add placeholder expressions for first generation
	(setq parent1 (randomCreature))
	(setq parent2 (randomCreature))
	(setq child1 (randomCreature))
	(setq child2 (randomCreature))

	;;;----------------create/evaluate/print creature pools--------------------
	;; iterate through 50 generations
	(dotimes (n 50)

		;; print current generation number (1-50)
		(format t "~%~%Generation ~d" genNum)

		;; for current temp pool, populate with creatures, while
		;; 	first adding 'fittest' creatures from previous pool,
		;;	but for first generation, add dummy expressions
		;; cPool is temp since it is purged every generation
	    (let ((cPool (populatePool))
		  ;; fitness values and creatures
		  (alphaFitness 10000)			; lowest value of (calcFit)
		  (betaFitness 0)			; second lowest/fittest
		  (omegaFitness 0)			; highest value of (calcFit)
		  (alphaCreature nil)
		  (betaCreature nil)
		  (omegaCreature nil)
		  (fitnessValue (randomFitnessValue))
		  ;; random variales that help calculate current gen's fitness
		  ;;	changes with every generation to maintain randomness
		  (x (randomDigit))
		  (y (randomDigit))
		  (z (randomDigit)))

		;; calculate fitness info for every creature in current generation,
		;;	then print to console and file
		(loop for cCreature in cPool
		    do
			;; compare current creature's value, and if min/max, assign
			;;	values to respective variables
			(let ((cFitness (calculateFitness cCreature fitnessValue)))
				(cond ((< cFitness alphaFitness)
					;; before assigning alpha's fitness, take
					;;	previous value and assign it to 
					;;	beta (keeps second fittest value)
					(setq betaCreature alphaCreature)
					(setq betaFitness alphaFitness)
					(setq alphaFitness cFitness)
					(setq alphaCreature cCreature))
				      ((> cFitness omegaFitness)
					(setq omegaFitness cFitness)
					(setq omegaCreature cCreature)))))
		;; special cases when betaCreature isn't assinged appropriate expr
		(cond ((eq betaCreature nil)
			(setq betaCreature (randomCreature))
			(setq betaFitness (eval betaFitness)))
		       ((= (eval betaCreature) 10000)
			(setq betaCreature (randomCreature))
			(setq betaFitness (eval betaFitness))))

		(print '--------------------------)
		(format str "~d ~d ~d ~d~%" x y z alphaFitness)	; prints to file
		;; following stuff is printed to console
		(format t "~%x:~d y:~d z:~d ~%~%" x y z) 		
		(format t "Fitness Value: ~d~%" fitnessValue)
		(format t "Alpha Creature: ~A ==> ~d~%" alphaCreature alphaFitness)
		(format t "Beta Creature: ~A ==> ~d~%" betaCreature betaFitness)
		(format t "Omega Creature: ~A ==> ~d~%" omegaCreature omegaFitness)

		;; increment generation number
		(setq genNum (+ 1 genNum))			
		
		;;;-------------------crossover and mutation----------------------------
		;; note: family members are defined globally
		;; get first parent (the fittest creature in the current pool) and
		;;	choose random DNA subsequence from its genotype
		(format t "~%Crossover:")
		(setq parent1 alphaCreature)
		(setq randIndex1 (getIndex parent1))
		(setq subParent1 (getSubTree randIndex1 parent1))
		;; repeat steps above for second fittest creature
		(setq parent2 betaCreature)
		(setq randIndex2 (getIndex parent2))
		(setq subParent2 (getSubTree randIndex2 parent2))
		;; print parents' information
		(format t "~%Parent 1: ~A" parent1) 
		(format t "~%Parent 2: ~A" parent2)

		;; copy DNA sequences to two children, both of whose DNA will be crossed
		;;	note: copying DNA to children initially will preserve parents' DNA
		(setq child1 parent1)
		(setq child2 parent2)
		(setf (nth randIndex1 child1) subParent2)
		(setf (nth randIndex2 child2) subParent1)
		;; print children
		(format t "~%Child 1: ~A~%" child1)
		(format t "Child 2: ~A~%" child2)

		;; subject family to mutation
		;;(setq parent1 (mutateCreature parent1))
		;;(setq parent2 (mutateCreature parent2))
		(setq child1 (mutateCreature child1))
		(setq child2 (mutateCreature child2))
		(format t "~%Mutation: ~%")
		;;(format t "Parent 1: ~A~%" parent1)
		;;(format t "Parent 2: ~A~%" parent2)
		(format t "Child 1: ~A~%" child1)
		(format t "Child 2: ~A~%" child2)
		) ; end of let
		) ; end of loop
	) ; end of write to file
) ; end of main


;;; FUNCTION CALLS
(main)

	









