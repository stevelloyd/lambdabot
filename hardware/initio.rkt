#lang racket/base

(require "../../wiringpi-racket/wiringpi/wiringpi.rkt")

;; pin definitions
;; these refer to physical pin numbers on the GPIO header

;; infra-red proximity sensors
(define IR-LEFT 7)
(define IR-RIGHT 11)
(define IR '(7 11))

;; motors
(define MOTOR-LEFT-1 19)
(define MOTOR-LEFT-2 21)
(define MOTOR-RIGHT-1 24)
(define MOTOR-RIGHT-2 26)

;; sonar
(define SONAR 8)


;; call to set up the hardware
;; -> true
(define (setup-bot)
  (wiringPiSetupPhys)	
  (setup-obstacle)
  (setup-motors))

;; setup-obstacle
;; set up obstacle sensors
(define (setup-obstacle)
  (map (lambda (pin) ; all button pins inputs 
         (pinMode pin INPUT)
         (pullUpDnControl pin PUD_OFF)) IR)
  #t)
  
;; setup-motors
;;
(define (setup-motors)
  (begin
    (softPwmCreate MOTOR-LEFT-1 0 100)
    (softPwmCreate MOTOR-LEFT-2 0 100)
    (softPwmCreate MOTOR-RIGHT-1 0 100)
    (softPwmCreate MOTOR-RIGHT-2 0 100)))

;; sonar
(define (distance)
  (let ([start (current-inexact-milliseconds)]
        [init (current-inexact-milliseconds)]
        [stop 0]
        [count 0]
        [elapsed 0])
  ;; send 10uS pulse
  (pinMode SONAR OUTPUT)
  (digitalWrite SONAR HIGH)
;  (sleep 0.00001)
  (digitalWrite SONAR LOW)
  (set! count (current-inexact-milliseconds))
  (pinMode SONAR INPUT)
  (do ([x 0 0])
      ((and (= 0 (digitalRead SONAR)) 1)
    (set! start (current-inexact-milliseconds))))
;  (set! count (current-inexact-milliseconds))
  (set! stop count)  
;  (do ([x 0 0])
;     ((and (= 1 (digitalRead SONAR)) 1)
;    (set! stop (current-inexact-milliseconds))))
;  (set! elapsed (- stop start))
;  (/ (* 34 (- stop start)) 2)))
   (display (- count init))
   (display "\n")
   (display (- start init))))
  
  ;; motor-stop
(define (motor-stop)
  (begin
    (softPwmWrite MOTOR-LEFT-1 0)
    (softPwmWrite MOTOR-LEFT-2 0)
    (softPwmWrite MOTOR-RIGHT-1 0)
    (softPwmWrite MOTOR-RIGHT-2 0)))

(define (motor-test)
  (begin
    (softPwmWrite MOTOR-LEFT-1 50)
    (softPwmWrite MOTOR-RIGHT-1 50)
    (sleep 2)
    (softPwmWrite MOTOR-LEFT-1 70)
    (softPwmWrite MOTOR-RIGHT-1 0)
    (softPwmWrite MOTOR-RIGHT-2 70)
    (sleep 1)
    (motor-stop)))

(define (turn-right)
    (softPwmWrite MOTOR-LEFT-1 70)
    (softPwmWrite MOTOR-RIGHT-1 0)
    (softPwmWrite MOTOR-RIGHT-2 70)
    (sleep 1)
    (motor-stop))

(define (turn-left)
    (softPwmWrite MOTOR-RIGHT-1 70)
    (softPwmWrite MOTOR-LEFT-1 0)
    (softPwmWrite MOTOR-LEFT-2 70)
    (sleep 1)
    (motor-stop))

(define (forward)
  (softPwmWrite MOTOR-LEFT-1 40)
  (softPwmWrite MOTOR-RIGHT-1 40)
  (sleep 1))
  
(define (reverse)
  (softPwmWrite MOTOR-LEFT-1 0)
  (softPwmWrite MOTOR-RIGHT-1 0)
  (softPwmWrite MOTOR-LEFT-2 40)
  (softPwmWrite MOTOR-RIGHT-2 40)
  (sleep 1.5)
  (motor-stop)
  (sleep 5))
  

  
;; active?
;;
(define (active? input)
  (= 0 (digitalRead input)))


;; display-ir
;;
(define (display-ir)
  (begin 
  (cond
    [(and (active? IR-LEFT) (active? IR-RIGHT)) (display "Obstacle both")]
    [(active? IR-LEFT) (display "Obstacle left")]
    [(active? IR-RIGHT) (display "Obstacle right")]
    [else (display "No obstacle")])
  (newline)))


(define (run)
  (do ([s (setup-bot)]
       [stop? #f])
     (stop? #t)
      (display-ir)
      (cond
       [(and (active? IR-LEFT) (active? IR-RIGHT)) 
                (reverse)
                (turn-right)
                ]
       [(active? IR-LEFT) (turn-right)]
       [(active? IR-RIGHT) (turn-left)]
       [else (forward)])))
    

(run)

   
