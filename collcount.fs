\ Kai Davids Schell
\ 4/19/16
\ CS331
\ Assignment 7
\ collcount.fs



: collatzcount { count n -- c }
	n 1 =
	if
		count
	else
		n 2 mod
		0 =
		if
			count 1 + 
			n 2 / 
			recurse
		else
			count 1 + 
			n 3 * 
			1 + 
			recurse
		then
	then
;
	
: collcount ( n -- c )
	0 swap
	collatzcount
;
	
