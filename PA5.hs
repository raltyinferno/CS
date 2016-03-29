--foldl 
--function that takes an oeration, a number, and a list

--foldl (+) 0 [1,2,3,4] 	--  = (((0 + 1) + 2) + 3) + 4
--0 is what you want to getwhen the list is empty

--foldr (+) 0 [1,2,3,4] 	-- = 1 + (2 + (3 + (4 + 0)))

--foldl1 (+) [1,2,3,4]  	-- = 1 + (2 + (3 + 4))
-- can only be done on lists with at least 1 element
--if 1 element, just returns the list


-- PA5.hs
-- Tristan Craddick
-- 28 Mar 2016
--
-- For CS 331 Spring 2016


module PA5 where

import System.IO  -- for hFlush


--collatzCounts
--variable that is a list of integers. Item k details how many
--iterations are required to take k+1 to 1.
collatzCounts = [0,1,2,3]






--findList
--function that returns a Maybe followed by an int depending upon
--whether two passed lists are found to be contigues sublists
--(first of the second list)

findList = do
	let list = [0,1,2,3]


--infix operator ##
--takes two passed lists and returns an integer representing
--the number of indecies where both lists contain the same value.
a ## b = 0

--filterAB
--takes a boolean function and two lists. returns a list of all items
--in the second list for which the related item in the first list returns
--true.
filterAB = do
	let list = [0,1,2]
	return list


--sumEvenOdd
--takes a list of numbers and returns a tuple of two numbers, the sum
--of the even numbers, and the sum of the odd numbers.



-- squareThem
-- Repeatedly input a number from the user. If 0, then quit; otherwise
--  print its square, and repeat.
-- Uses "let" in do-block.
squareThem = do
    putStr "Type a number (0 to quit): "
    hFlush stdout      -- Make sure prompt comes before input
    line <- getLine    -- Bind name to I/O-wrapped value
    let n = read line  -- Bind name to non-I/O value
                       -- Compiler knows n is a number by how it is used
    if n == 0
        then return () -- Must have I/O action here, so make it null
        else do
            putStrLn ""
            putStr "Squaring, we get: "
            putStrLn (show (n*n))
            putStrLn ""
            squareThem   -- repeat

			
			

-- main
-- Demonstrate squareThem.
main = squareThem