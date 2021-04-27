## Genetic Programming Applied as Arithmetic Expressions
Genetic algorithms, being based on the theory of evolution, imitate natural selection by producing randomized solutions that are evaluated for their “fitness.” The “fittest” solutions are then “bred,” producing another generation of recombined solutions. Genetic programming is a subset of genetic algorithms in that it is applied to written computer programs. The ultimate goal of genetic programming is to autonomously generate efficient computer programs that are perfected through “natural selection.” 

In this implementation of genetic programming written in **Common Lisp**, quadratic arithmetic expressions represent the individuals of a population. Naturally, each organism has a unique quality of fitness, which is represented by a fitness value derived from evaluating an expression. Every expression is composed of operators, constant integers, and variables, which are randomly set as global parameters at the beginning of every program execution. The range of integers is from -9 to +9; the variables used are x, y, and z; and the operators are +, -, and *.

Lisp uses prefix notation to represent arithmetic expressions. For example,
>9 * (3 + 5)  
is written as
>\* 9 (+ 3 5)

Each parenthesized nested expression, or “node,” is allowed to have up to four elements. E.g., 
>(- (* 3 x 4) (+ y (* 8 z) (* x (+ 5 -8 z y))))

The fitness of every expression is evaluated to determine its fitness.
>Global variables: x = 5, y = 3, z =8  
>(- (* 3 x 4) (+ y (* 8 z) (* x (+ 5 -8 z y)))) = -47

Each generation in the population is set to 50 individuals, four of which are a "family" derived from the two fittest organisms of the previous generation. The pair of expressions with the highest fitness scores in any generation are bred together, and they and their offspring are added to the next generation's pool of individuals.

Crossover picks two random points in a “gene” (in this case, an expression) and combines the snippet with another gene at the same point.

| = crossover point
>(+ |(* 1 x x) 2 | 0 (* -3 x y z)) <- fittest individual  
>(* |(* 4 (- x -7)| (* 2)) 3 y) <- individual in same generation

Offspring:
>(+ (* 4 (- x -7) 0 (* -3 x y z))  
>(* (* 1 x x) 2 (* 2)) 3 y)
	
Mutation simply changes a single element in an expression to something random.
>(* x (+ **4** -7 y) 5 (- z 1))

Becomes
>(* x (+ **-8** -7 y) 5 (- z 1))
	
In short, this program follows the procedure:
1. For the first generation, set the global variables x, y, and z to randomized values (from -9 to +9) and generate 50 randomized arithmetic expressions
2. Evaluate each expression and find the pair with the highest fitness values
3. Subject the fittest expressions to crossover and mutation to produce two new offspring
4. Add the new offspring and the parents to the next generation's pool and populate it with 46 randomized individuals while purging the previous generation
5. Repeat steps 2-5 for a fixed number of generations (which is 50, in this case)

## Instructions
1. Install common lisp
   >https://common-lisp.net/
2. Navigate to folder containing ```gp.lisp```
3. Run the command
   >clisp gp.lisp
4. Review results printed to the terminal and “data.txt”


