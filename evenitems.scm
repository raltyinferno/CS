#lang scheme

(define (evenitems myList)
  (print myList)
  (define mynewList '())
  (cons (car myList)(removeodds (cdr myList) 2))
  )

(define (removeodds myList counter)

  (if (null? myList)
      '()
  (if (even? counter) (removeodds (cdr myList) 1)

   (cons (car myList) (removeodds (cdr myList) 2))))
)
