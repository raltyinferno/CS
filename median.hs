-- median.hs
-- Tristan Craddick
-- 28 Mar 2016
--
-- For CS 331 Spring 2016
-- CS-201-Style Haskell Program

module Main where

import System.IO  -- for hFlush
import Data.List



--median
--takes a series of integer inputs from the user, ending
--with a blank line, and then computes and returns the median
--of said integers. A message will be displayed if the list
--is empty, and the user will be asked if they want to run
--the program again upon completion.
main = do
	putStrLn ""
	putStrLn "Type a number and press enter to input it into a list."
	putStrLn "Continue this process until you are satisfied with the list"
	putStrLn "and then enter a blank line to calculate the median of the"
	putStrLn "list of numbers that you inputted."
	putStrLn ""
	medianList <- getInput
	if length medianList == 0
		then print("The list is empty, so there is no median")
	else do
		let sortedList = sort medianList
		calcMed sortedList
	-- Asks the user whether they would like to run the program again.
	putStr "Would you like to create a new list? [y/n]"
	word <- getLine
	if word == "y"
		then main
	else do
		putStrLn "Thank you for using Median services. We're not the best, but we're not the worst!"

-- Takes a sorted list and prints the median of the list
calcMed sortedList = do
    let listsize = length sortedList
    let medIndex = listsize `div` 2
    print(sortedList!!medIndex)

     
-- Gets INTEGERS from the user, and returns a list
-- populated with the INTEGERS.
getInput = do 
    putStr "Input an integer to add to the list or a blank line to calculate the median. "
    userinput <- getLine
    if userinput == ""
		then return []
    else do
		rest <- getInput
		return ((read userinput :: Int) : rest)





