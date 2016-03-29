-- PA5.hs
-- Matthew Parrish
-- CS331 Assignment 5, part A
-- 3/27/2014
-- Module PA5 with functions to filter and return a list,
-- and to calculate a list of collatz numbers.

module PA5 where
	
----------------------
-- Filter Functions --
----------------------
filterAB cond [] _ = []
filterAB cond _ [] = []
filterAB cond (x:xs) (y:ys) | cond x = y:others
							| otherwise = others where
							  others = filterAB cond xs ys

-----------------------
-- Collatz Functions --
-----------------------
						  
collatz n
     | (mod n 2 == 0) = div n 2
     | otherwise =  3 * n + 1

collatz' = map collatzList[1..]
collatz'' = map length collatz'
collatzCounts = map (subtract 1) collatz''

collatzList n
        | n < 1 = error "Number go down the hoooole. And it broke."
        | n == 1 = [n]
        | otherwise = n:collatzList (collatz n)
					

-- This checks for string existance in list--
--must use fold--
findList = do
	let list = [0,1,2,3]
	1 + 2
		
--return an int giving the number of numbers shared between two lists--
-- ## n 
--	|
a ## b = 0

--Return a tuple, even sum and odd sum as the pair of numbers--
sumEvenOdd n = do
	value1 <- 0
	value2 <- 0
	if even n
		then value1 + n 
		else do
			value2 + n 