-- median.hs
-- Scott Corcoran
-- CS331 Assignment 5.C
-- 3/28/2016
-- A program to calculate the Median of a list made from user input integers.

-------------------------------------
--This program is for recieving    --
--a set of integers and computing  --
--the median of the data set       --
--  This program WILL break if not --
--	given ONLY Integers.       --
-------------------------------------

import Data.List

main = do
    putStrLn ""
    putStrLn "Give me integers, one per line."
    putStrLn "And I shall compute the median of them."
    putStrLn ""
    medianList <- getInput
    if length medianList == 0
		then print("Empty list - no median")
    else do
		let sortedList = sort medianList
		calculateMedian sortedList
    continueProgram

-- Takes a sorted list and prints the median of the list
calculateMedian sortedList = do
    let lengthOfSortedList = length sortedList
    let medianIndexOfList = lengthOfSortedList `div` 2
    print(sortedList!!medianIndexOfList)

-- Prompts user to repeat or end program
continueProgram = do
    putStr "Compute another median? [y/n] "
    word <- getLine
    if word == "y"
		then main
    else do
		putStrLn "Program terminated"
     
-- Gets INTEGERS from the user, and returns a list
-- populated with the INTEGERS.
getInput = do 
    putStr "Input: (Enter an integer, or blank line to finish):"
    word <- getLine
    if word == ""
		then return []
    else do
		rest <- getInput
		return ((read word :: Int) : rest)

