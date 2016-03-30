-- Kai Davids Schell
-- 3/28/16
-- CS331
-- Assignment 5
-- PA5.hs



module PA5 where

--used for findList
import Data.List

--takes a number and applies collatz formula to it
collatz x 
	| x == 1 = 1
	| odd x = 3*x+1
	| otherwise = div x 2
--takes a number and counts how many steps to take it to 0 through collatz formula	
collatzcounter 1 = 0
collatzcounter x = 1 + collatzcounter (collatz x)
--applies collatzcounter to index of list item
collatzCounts = [collatzcounter x | x <- [1..]]


--takes two lists and if first appears as substring of the other returns 
--index of where it appears in the second
findList _ [] = Nothing
findList [] _ = Just 0
findList xs ys = find (\ind -> isPrefixOf xs (drop ind ys)) (elemIndices (head xs) ys)


--Infix opperator ## takes 2 lists of same type and returns number of indices where they
--are the same
correspond (x:xs) (y:ys) depth count lim lim2
	| (depth == lim || depth == lim2) = count +(if x==y then 1 else 0)
	| x == y                          = correspond xs ys (depth+1) (count+1) lim lim2
	| otherwise                       = correspond xs ys (depth+1) count lim lim2

[ ] ## _ = 0
_ ## [ ] = 0
(x:xs) ## (y:ys) = correspond (x:xs) (y:ys) 1 0 (length (x:xs)) (length (y:ys))


--Filter, takes a boolean func and 2 lists, returns item in second list for which coresponding
--item in first list satisfies the boolean

filterAB bool [] _ = []
filterAB bool _ [] = []
filterAB bool (x:xs) (y:ys)
	| bool x = y:rest
	| otherwise = rest 
	where rest = filterAB bool xs ys
	
--sumEvenOdd. Takes a list of ints and sums up the even and odd positioned numbers and puts them
--in a tuple

-- sumEvenOdd [] = (0,0)
-- sumEvenOdd lis = (addEvenOdd lis (length lis) 0 0, addEvenOdd lis (length lis) 1 0)


addEvenOdd lis leng index total
	| index < leng = addEvenOdd lis leng (index+2) (total+lis!!index)
	| otherwise = total
	--obviously not using folds as it should be. hopefully I'll get to it
	--before I pass out

-- addEven [] evens index leng = evens 
-- addEven x:xs:xss evens index leng
	-- | index < leng  = addEven xss (evens:x) (index+2) leng
	-- | otherwise     = evens

--splitEvenOdd [] flag evens odds = 
splitEvenOdd [] flag evens odds = (foldr (+) 0 evens, foldr (+) 0 odds)
splitEvenOdd (x:xs) flag evens odds
	-- | len == 0 = (foldr (+) 0 evens, foldr (+) 0 odds)
	| flag == 0 = splitEvenOdd xs 1 (x:evens) odds
	| flag == 1 = splitEvenOdd xs 0 evens (x:odds)

sumEvenOdd [] = (0,0)
sumEvenOdd lis = splitEvenOdd lis 0 [] []





