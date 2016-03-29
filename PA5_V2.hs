-- PA5.hs
-- Scott Corcoran
-- 3/28/2016
--
-- For CS 331 Spring 2015
-- PA5 module Program for Assignment 5, Exercise A


module PA5 where 

import Data.List

	
----------------------
-- Filter Functions --
----------------------
filterAB cond [] _ = []
filterAB cond _ [] = []
filterAB cond (x:xs) (y:ys) | cond x = y:others
							| otherwise = others where
							  others = filterAB cond xs ys


-- infinite list
list = [1..]

-- collatz
-- a helper function for collatzCounts, performs the calculation
collatz k
	| k == 1 		= 0
	| odd k 			= 1 + collatz( 3 * k + 1)
	| otherwise 	= 1 + collatz( k `div` 2 )
	
	
-- collatzCounts
-- This is a list of integers. Item k (counting from zero) of collatzCounts
-- tell how many iterations of the Collatz function are required to take the
-- number k+1 to 1
collatzCounts = map collatz list

-- findList
-- Infix operator ##. The two operands are lists of the same type.
-- The return value is an integer giving the number of indices at
-- which the two lists contain equal values.
findList :: Eq a => [a] -> [a] -> Maybe Int
findList _ [] = Nothing
findList [] _ = Just 0
findList sub theList = find ( \i -> isPrefixOf sub (drop i theList)) (elemIndices (head sub) theList)

--operator ##
[ ] ## _ = 0
_ ## [ ] = 0
(x:xs) ## (y:ys) = doubleSharp (x:xs) (y:ys) 0 (length (x:xs)) (length (y:ys))

--keeps track of lists sizes=knows when to end/return c
--c counts how many items are equal
doubleSharp [ ] _ q j1 j2 = q  
doubleSharp _ [ ] q j1 j2 = q 
doubleSharp (x:xs) (y:ys) q j1 j2 
	| (j1 == 0 || j2 == 0)   = q
	| x == y   			   = doubleSharp xs ys (q+1) (j1-1) (j2-1) 
	| otherwise   		   = doubleSharp xs ys q (j1-1) (j2-1)
	


--Return a tuple, even sum and odd sum as the pair of numbers--
sumEvenOdd n[] = do
	let total1 = []
	let total2 = []
	let final 
SeperateEvenOdd
	value1 <- foldr total1 []
	value2 <- foldr total2 []
	final(value1,value2)
	
SeperateEvenOdd n[] =do
	if even n
		then total1 ++ n 
		else do
			total2 ++ n 
		sumEvenOdd