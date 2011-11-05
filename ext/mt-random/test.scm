;;
;; testing mt-random
;;

(use gauche.test)
(use gauche.collection)
(use srfi-1)
(use srfi-13)
(use gauche.uvector)

(test-start "mt-random")
(use math.mt-random)
(test-module 'math.mt-random)

(define (value-in-range? range)
  (^n (<= 0 n (- range 1))))
(define (make-random-sequence class size generator)
  (with-builder (class add! get :size size)
    (dotimes [i size (get)]
      (add! (generator)))))

(define m (make <mersenne-twister>))

(test "mt-random-integer" #t
      (^[] (every (value-in-range? 7)
                  (make-random-sequence <list> 1000
                                        (^[] (mt-random-integer m 7))))))

(test "mt-random-integer" #t
      (^[] (every (value-in-range? 113)
                  (make-random-sequence <list> 1000
                                        (^[] (mt-random-integer m 113))))))

(test "mt-random-integer" #t
      (^[] (every (value-in-range? 78356385638456)
                  (make-random-sequence <list> 1000
                                        (^[] (mt-random-integer m 78356385638456))))))

(test "mt-random-real" #t
      (^[] (every (^n (< 0 n 1))
                  (make-random-sequence <list> 1000
                                        (^[] (mt-random-real m))))))

(test "seed" #t
      (^[] (let ([m0 (make <mersenne-twister> :seed 1)]
                 [m1 (make <mersenne-twister> :seed 1)])
             (equal? (make-random-sequence <list> 100
                                           (^[] (mt-random-real m0)))
                     (make-random-sequence <list> 100
                                           (^[] (mt-random-real m1)))))))

(test "seed" #f
      (^[] (let ([m0 (make <mersenne-twister> :seed 1)]
                 [m1 (make <mersenne-twister> :seed 2)])
             (equal? (make-random-sequence <list> 100
                                           (^[] (mt-random-real m0)))
                     (make-random-sequence <list> 100
                                           (^[] (mt-random-real m1)))))))

;;; NB: Cygwin version doesn't suppor some procedures.  Exit here.
(when (string-contains (gauche-architecture) "cygwin")
  (test-end)
  (exit 0))

(test "seed" #t
      (^[] (let ([m0 (make <mersenne-twister>)]
                 [m1 (make <mersenne-twister>)])
             (mt-random-set-seed! m0 '#u32(472346 37429385 72))
             (mt-random-set-seed! m1 '#u32(472346 37429385 72))
             (equal? (make-random-sequence <list> 100
                                           (^[] (mt-random-real m0)))
                     (make-random-sequence <list> 100
                                           (^[] (mt-random-real m1)))))))

(test "seed" #f
      (^[] (let ([m0 (make <mersenne-twister>)]
                 [m1 (make <mersenne-twister>)])
             (mt-random-set-seed! m0 '#u32(472346 37429385 72))
             (mt-random-set-seed! m1 '#u32(472346 37429385 71))
             (equal? (make-random-sequence <list> 100
                                           (^[] (mt-random-real m0)))
                     (make-random-sequence <list> 100
                                           (^[] (mt-random-real m1)))))))

(test "u32vector" #t
      (^[] (let ([m0 (make <mersenne-twister> :seed 1)]
                 [m1 (make <mersenne-twister> :seed 1)])
             (equal? (make-random-sequence <u32vector> 100
                                           (^[] (mt-random-integer m0 (expt 2 32))))
                     (rlet1 v (make-u32vector 100 0)
                       (mt-random-fill-u32vector! m1 v))))))
        
(test "f64vector" #t
      (^[] (let ([m0 (make <mersenne-twister> :seed 1)]
                 [m1 (make <mersenne-twister> :seed 1)])
             (equal? (make-random-sequence <f64vector> 100
                                           (^[] (mt-random-real m0)))
                     (rlet1 v (make-f64vector 100 0)
                       (mt-random-fill-f64vector! m1 v))))))

(test "state" #t
      (^[] (let ([s  (mt-random-get-state m)]
                 [m2 (make <mersenne-twister> :seed 9324)])
             (mt-random-set-state! m2 s)
             (equal? (make-random-sequence <list> 100 (^[] (mt-random-real m)))
                     (make-random-sequence <list> 100 (^[] (mt-random-real m2)))
                     ))))

(test-end)

