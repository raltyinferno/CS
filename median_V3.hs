-- Kai Davids Schell
-- 3/28/16
-- CS331
-- Assignment 5
-- median.hs

module Main where

import System.IO
import Data.List


main = do
	putStrLn "Enter an integer and press enter"
	putStrLn "Repeat until you have entered all the integers you want"
	putStrLn "Once you have entered all the ints you want press enter twice to"
	putStrLn "put an empty line and the program will procede to calculate"
	putStrLn "and display the median of the integers you entered"
	putStrLn ""
	inputs <- read_input
	if length inputs == 0
		then putStrLn "Nothing entered"
	else do
		let lis = sort inputs
		median lis	
		putStrLn "is the median"
		
		


		
		
read_input = do
	input <- getLine
	if input == "" then return []
	else do
		next <- read_input
		return ((read input :: Int):next)
		
median lis = do
	print (lis!!(div (length lis) 2))