-- median.hs
-- Tristan Craddick
-- 28 Mar 2016
--
-- For CS 331 Spring 2016
-- CS-201-Style Haskell Program

module Main where

import System.IO  -- for hFlush

-- *****Global Lists******
medlist = []

--sum of a list
listsum = 0

--median
--takes a series of integer inputs from the user, ending
--with a blank line, and then computes and returns the median
--of said integers. A message will be displayed if the list
--is empty, and the user will be asked if they want to run
--the program again upon completion.
median = do
	putStr "Type a number and press enter to input it into a list."
	putStr "Continue this process until you are satisfied with the list"
	putStr "and then enter a blank line to calculate the median of the"
	putStr "list of numbers that you inputted."
	
	hFlush stdout      -- Make sure prompt comes before input
	
	takeInput
	calcMed

			
			
--takeInput
--takes user input and calls itself if a blank line was
-- not inputted.
takeInput = do


    testline <- getLine    -- Bind name to I/O-wrapped value
    let n = read testline  -- Bind name to non-I/O value
                       -- Compiler knows n is a number by how it is used
    if n == ""
        then return () -- Must have I/O action here, so make it null
        else do
			let medlist = n:medlist
            takeInput   -- repeat

			
--calcMed
--does the actual calculation for the median.			
calcMed = do
	let size = length medlist
	let listsum = sum medlist
	let retval = listsum / size
	
	let medlist = []
	let listsum = 0
	
	return retval
	


-- main
-- Demonstrate squareThem.
main = median

