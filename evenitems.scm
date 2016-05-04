#lang scheme


(define (removeodd lis counter)

  (if (null? lis)
      '()
  (if (even? counter) (removeodd (cdr lis) 1)

   (cons (car lis) (removeodd (cdr lis) 2))))
)
(define (evenitems lis)
  (cons (car lis)(removeodd (cdr lis) 2))
  )


