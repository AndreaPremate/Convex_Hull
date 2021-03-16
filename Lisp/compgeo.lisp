;;;; -*- Mode: Lisp -*-
;; compgeo.lisp
;; Progetto lisp
;; Premate_Andrea_829777_CH_LP_201907


(defparameter p0 'p0)
"p0 è il punto minimo della lista di punti di partenza"


;;; DEFINIZIONI GEOMETRICHE

(defun new-point (x y)
  (if (and (integerp x)
           (integerp y))
      (cons x y)
    nil))


(defun x (point-2d)
  (if (is-point point-2d)
      (car point-2d)
    nil))


(defun y (point-2d)
  (if (is-point point-2d)
      (cdr point-2d)
    nil))


(defun area2 (a b c)
  (if (and (is-point a) 
           (is-point b) 
           (is-point c))
      (- (* (- (x a) (x c)) 
            (- (y b) (y c)))
         (* (- (y a) (y c))
            (- (x b) (x c))))
    nil))


(defun left (a b c)
  (if (and (integerp (area2 a b c))
           (> (area2 a b c) 0))
      T
    nil))


(defun left-on (a b c)
  (if (and (integerp (area2 a b c))
           (< (area2 a b c) 0))
      T
    nil))


(defun is-coll (a b c)
  (if (and (integerp (area2 a b c))
           (= (area2 a b c) 0))
      T
    nil))


(defun angle2d (a b)
  (if (and (is-point a) (is-point b))
      (atan (- (y b) (y a))
            (- (x b) (x a)))
    nil))



;;; CONTROLLO

(defun is-point (point-2d)
  "Controlla che l'argomento sia un punto,
 applicando la definizione scelta in new-point."
  (if (and (consp point-2d) 
           (integerp (car point-2d))
           (integerp (cdr point-2d)))
      T nil))


(defun is-point-list (lista)
  "Controlla se la lista passata
 è una lista di punti."
    (cond ((and (is-point (car lista))
                (null (cdr lista)))
           T)
          ((and (not (is-point (car lista)))
                (null (cdr lista)))
           nil)
          (T 
           (and (is-point (car lista))
                (is-point-list (cdr lista))))))



;;; ORDINAMENTO, PUNTO MINIMO E MANIPOLAZIONE LISTE

(defun smaller-coordinates (p1 p2)
 "Determina se il primo punto passato ha
 ordinata inferiore al secondo, in caso di
 parità controlla l'ascissa."
  (if (and (is-point p1) (is-point p2))
      (cond ((< (y p1) (y p2)) 
             p1)
            ((= (y p1) (y p2))
             (if (<= (x p1) (x p2))
                 p1
               p2))
            (T 
             p2))
    nil))


(defun make-point-set (lista)
  "Controlla la lista di punti in entrata
 e rimuove eventuali duplicati."
  (if (is-point-list lista)
      (remove-duplicates lista :test #'equal)
    nil))


(defun get-p0 (lista)
  "Data una lista di punti in entrata ritorna quello
 minimo, denominato p0, secondo la definizione
 data nella funzione smaller-coordinates."
  (if (and (is-point (car lista))
           (null (cdr lista)))
      (car lista)
    (smaller-coordinates (car lista)
                         (get-p0 (cdr lista)))))


(defun set-p0 (lista)
  "Setta il punto minimo come p0."
  (set 'p0 (get-p0 lista)))


(defun smaller-angle (a b)
  "Determina quale tra due punti forma, con p0 e la
 direzione orizzontale, l'angolo
 minore, in caso di parità è considerato minore il
 punto più vicino a p0. ATTENZIONE: leggere il readme"
  (if (and (is-point a) (is-point b))
      (cond ((and (is-point a)
                  (is-point b)
                  (< (angle2d p0 a) (angle2d p0 b)))
             T)
            ((and (= (angle2d p0 a) (angle2d p0 b))
                  (< (y a) (y b)))
             T)
            ((and (= (angle2d p0 a) (angle2d p0 b))
                  (= (y a) (y b)) (<= (x a) (x b)))
             T))
    nil))


(defun sort-by-angle (lista)
  "Ordina la lista di punti in ingresso in ordine
 crescente secondo l'angolo che formano con p0
 e la direzione orizzontale."
  (sort lista 'smaller-angle))


;; ATTENZIONE: Vedere il punto 5) del readme
(defun same-angle-list (lista punto)
  "Data una lista e un punto in input ritorna una
 lista contenente tutti i punti che formano con p0
 lo stesso angolo del punto in ingresso"
  (cond ((null lista)
         nil)
        ((is-point lista)
         (if (= (angle2d p0 punto)
                (angle2d p0 lista))
             (list lista)
           nil))
        (T
         (append (same-angle-list (car lista) punto) 
                 (same-angle-list (cdr lista) punto)))))


;; Vedere il punto 6) del readme
(defun reverse-lista (lista)
  "Data una lista in ingresso, la
 restituisce in output ribaltata"
  (cond ((null lista) '())
        (T (append (reverse-lista (cdr lista)) (list (car lista))))))



;;; STACK

;; Le funzioni di questa sezione sono praticamente immediate;
;; è stato scelto di implementarle per dare maggiore leggibilità
;; al codice e fare intendere che si ha a che fare con uno stack."

(defun stack-pop (lista)
  (cdr lista))

(defun stack-top (lista)
  (car lista))

(defun stack-push (x lista)
  (if (is-point x)
      (append (list x) lista)
    nil))

(defun stack-next-to-top (lista)
  (stack-top (cdr lista)))



;;; CONVEXH HULLS

(defun convexh-algorithm (lista stack)
  "Implementa il punto focale dell'algoritmo nella
 sua definizione generale."
  (cond ((null lista)
         stack)
        ((left (stack-next-to-top stack)
               (stack-top stack)
               (first lista))
         (convexh-algorithm (rest lista)
                            (stack-push (first lista) stack)))
        ((left-on (stack-next-to-top stack)
                  (stack-top stack) 
                  (first lista))
         (convexh-algorithm lista 
                            (stack-pop stack)))
        ((is-coll (stack-next-to-top stack) ;mantengo i punti collineari
                  (stack-top stack)
                  (first lista))
         (convexh-algorithm (rest lista)
                            (stack-push (first lista) stack)))))


(defun make-convexh (lista)
  "Prepara stack e lista con i primi punti
 ed esegue l'algoritmo convexh"
  (let ((mylist (sort-by-angle lista))
        (mystack (stack-push (second (sort-by-angle lista))
                             (stack-push (first (sort-by-angle lista))
                                         nil))))
    (convexh-algorithm (cdr(cdr mylist)) mystack)))


(defun convexh (lista)
  "Data in ingresso una lista di punti esegue
 l'intero algoritmo convexh e ritorna i punti
 che formano la chiglia convessa relativa."
  (set-p0 lista)
  (let ((non-adj-convexh 
         (make-convexh (make-point-set lista))))
    (reverse-lista
     (append
      (sort-by-angle
       (same-angle-list (make-point-set lista)
                        (car non-adj-convexh)))
      (cdr non-adj-convexh)))))



;;; FILE INPUT

(defun read-list-from (input-stream)
  (let ((e (read input-stream nil 'eof)))
    (unless (eq e 'eof)
      (cons e (read-list-from input-stream)))))


(defun make-coordinates-list (file)
  "Dato un file in input legge le coordinate dei
 vari punti e le ritorna tutte insieme(sfuse) in una lista"
  (with-open-file (in file
                      :direction :input
                      :if-does-not-exist :error)
    (read-list-from in)))


(defun from-coord-to-points (listacoord)
  "Data in ingresso una lista con tutte le coordinate(sfuse)
 dei punti ritorna una lista contenente i veri e propri
 punti corrispondenti"
  (cond ((null listacoord)
         nil)
        ((and (numberp (car listacoord))
              (numberp (car (cdr listacoord))))
         (append (list
                  (new-point (car listacoord)
                             (car (cdr listacoord))))
                 (from-coord-to-points (cdr (cdr listacoord)))))
        (T
         nil)))


(defun read-points(file)
  "Dato in input un file contenente coordinate di punti
 ritorna la lista di punti corrispondente"
  (from-coord-to-points (make-coordinates-list file)))



;;;; end of file -- compgeo.lisp
