\ Scott Corcoran
\ collcount.fs 
\ 4/19/2016
\ CS331
\ The collatz word in forth for Assignment 7 


\ collcount 
: collHelper { m n -- COUNT }
	n 1 = if
		m
	else
		n 2 MOD 0 = if
			m 1 + n 2 / recurse 
		else
			m 1 + n 3 * 1 + recurse 
		endif
	endif
;

: collcount { n -- COUNT }
	0 n collHelper
;
