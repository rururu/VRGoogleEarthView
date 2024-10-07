;; Geographical calculation Functions

;(deftemplate Ob
;	(slot lat (type FLOAT))
;	(slot lon (type FLOAT)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                           ;;
;;  ATTENTION! All Polygons and Polylines must be defined COUNTERCLOCKWISE!  ;;
;;                                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defglobal
	?*NM-DEG* = 0.017
	?*PI* = (pi)
	?*MPI* = (- 0 (pi))
	?*2PI* = (* (pi) 2)
	?*HPI* = (/ (pi) 2)
	?*MHPI* = (- 0 (/ (pi) 2)))

(deffunction rand-crs (?c1 ?c2)
	(if (<= ?c1 ?c2)
		then (integer (rand-xy ?c1 ?c2))
		else (if (> (rand01) 0.5)
		then (integer (rand-xy ?c1 359))
		else (integer (rand-xy 0 ?c2)))))


(deffunction direct (?x1 ?y1 ?x2 ?y2)
	(atan2 (- ?y2 ?y1)(- ?x2 ?x1)))
		
(deffunction relative-position (?x ?y ?dir ?dist)
  (create$ (+ ?x (* (cos ?dir) ?dist))(+ ?y (* (sin ?dir) ?dist))))

(deffunction rand-dxdy (?speed ?dir1 ?dir2) ;; knots (NM/hrs), rad = [-pi. pi]
  (bind ?s (/ ?speed 60 3600)) ;; degrees/sec
  (bind ?a (rand-xy ?dir1 ?dir2))
  (create$ (* (cos ?a) ?s)(* (sin ?a) ?s)))

(deffunction dirspd-to-dxdy (?dir ?speed) ;; rads, knots (NM/hrs)
  (bind ?s (/ ?speed 60 3600)) ;; degrees/sec
  (create$ (* (cos ?dir) ?s)(* (sin ?dir) ?s)))
  
(deffunction norm-dir (?d)
	(if (< ?d ?*MPI*)
		then (+ ?d ?*2PI*)
		else (if (> ?d ?*PI*)
		then (- ?d ?*2PI*)
		else ?d)))

(deffunction distance (?x1 ?y1 ?x2 ?y2) ;; degrees, ret degrees
	(bind ?dx (- ?x2 ?x1))
	(bind ?dy (- ?y2 ?y1))
	(sqrt (+ (* ?dx ?dx) (* ?dy ?dy))))
	
(deffunction distance-nm (?x1 ?y1 ?x2 ?y2)
	(* (distance ?x1 ?y1 ?x2 ?y2) 60)) ;; degrees, ret nautical miles
  
(deffunction obj-distance (?o1 ?o2)
	(bind ?y1 (fact-slot-value ?o1 lat))
	(bind ?y2 (fact-slot-value ?o2 lat))
	(bind ?x1 (fact-slot-value ?o1 lon))
	(bind ?x2 (fact-slot-value ?o2 lon))
	(distance ?x1 ?y1 ?x2 ?y2))

(deffunction calc-arrive-time (?x1 ?y1 ?x2 ?y2 ?v) ;; degrees, knots
  (bind ?deg-in-sec (/ ?v 60 3600))
  (bind ?dist (distance ?x1 ?y1 ?x2 ?y2))
  (integer (/ ?dist ?deg-in-sec)))
	
(deffunction crs-to-dir (?c)
	(if (> ?c 270)
		then (bind ?r (- 450 ?c))
		else (bind ?r (- 90 ?c)))
	(deg-rad ?r))
	
(deffunction ahead? (?dir1 ?x1 ?y1 ?x2 ?y2)
	(bind ?dir2 (direct ?x1 ?y1 ?x2 ?y2))
	(bind ?dif (abs (- ?dir1 ?dir2)))
	(or (<= ?dif (* (pi) 0.5))(>= ?dif (* (pi) 1.5))))

(deffunction abaft? (?dir1 ?x1 ?y1 ?x2 ?y2)
	(bind ?dir2 (direct ?x1 ?y1 ?x2 ?y2))
	(bind ?dif (abs (- ?dir1 ?dir2)))
	(or (> ?dif (* (pi) 0.5))(> ?dif (* (pi) 1.5))))
	
(deffunction abaft-both? (?dir1 ?x1 ?y1 ?x2 ?y2 ?x3 ?y3)
	(and (abaft? ?dir1 ?x1 ?y1 ?x2 ?y2)(abaft? ?dir1 ?x1 ?y1 ?x3 ?y3)))

(deffunction ahead-both? (?dir1 ?x1 ?y1 ?x2 ?y2 ?x3 ?y3)
	(and (ahead? ?dir1 ?x1 ?y1 ?x2 ?y2) (ahead? ?dir1 ?x1 ?y1 ?x3 ?y3)))
	
(deffunction normal (?x1 ?y1 ?x2 ?y2)
	(bind ?dir (direct ?x1 ?y1 ?x2 ?y2))
	(if (< ?dir (* ?*PI* 0.5))
		then (+ ?dir (* ?*PI* 0.5))
		else (- ?dir (* ?*PI* 1.5))))
		
(deffunction segment-n (?n ?xx ?yy)
	(bind ?x1 (nth$ ?n ?xx))
	(bind ?y1 (nth$ ?n ?yy))
	(bind ?x2 (nth$ (+ ?n 1) ?xx))
	(bind ?y2 (nth$ (+ ?n 1) ?yy))
	(create$ ?x1 ?y1 ?x2 ?y2))
		
(deffunction normal-n (?n ?seg)
	(funcall normal (expand$ ?seg)))

(deffunction inside-convex? (?x ?y ?xx ?yy)
	(loop-for-count (?i (- (length$ ?xx) 1))
		(bind ?j (+ ?i 1))
		(bind ?seg (segment-n ?i ?xx ?yy))
		(bind ?norm (normal-n ?i ?seg))
		(if (ahead-both? ?norm ?x ?y (nth$ 1 ?seg)(nth$ 2 ?seg)(nth$ 3 ?seg)(nth$ 4 ?seg))
			then (return FALSE)))
	TRUE)
	
(deffunction outside-convex? (?x ?y ?xx ?yy)
	(loop-for-count (?i (- (length$ ?xx) 1))
		(bind ?j (+ ?i 1))
		(bind ?seg (segment-n ?i ?xx ?yy))
		(bind ?norm (normal-n ?i ?seg))
		(if (ahead-both? ?norm ?x ?y (nth$ 1 ?seg)(nth$ 2 ?seg)(nth$ 3 ?seg)(nth$ 4 ?seg))
			then (return (create$ ?norm ?seg))))
	FALSE)

(deffunction dist-point-two-points (?x0 ?y0 ?x1 ?y1 ?x2 ?y2)
	(bind ?y21 (- ?y2 ?y1))
	(bind ?x21 (- ?x2 ?x1))
	(bind ?nmr (abs (+ (- (* ?y21 ?x0)(* ?x21 ?y0))(- (* ?x2 ?y1)(* ?y2 ?x1)))))
	(bind ?dnr (sqrt (+ (* ?y21 ?y21)(* ?x21 ?x21))))
	(/ ?nmr ?dnr))
	
(deffunction dist-point-segment (?x ?y ?seg)
	(funcall dist-point-two-points ?x ?y (expand$ ?seg)))
	
(deffunction spherical-between (?phi1 ?lambda0 ?c ?az)
	(bind ?cosphi1 (cos ?phi1))
	(bind ?sinphi1 (sin ?phi1))
	(bind ?cosaz (cos ?az))
	(bind ?sinaz (sin ?az))
	(bind ?sinc (sin ?c))
	(bind ?cosc (cos ?c))
	(bind ?phi2 (asin (+ (* ?sinphi1 ?cosc) (* ?cosphi1 ?sinc ?cosaz))))
	(bind ?lam2 (+ (atan2 (* ?sinc ?sinaz) (- (* ?cosphi1 ?cosc) (* ?sinphi1 ?sinc ?cosaz))) ?lambda0))
	(create$ ?phi2 ?lam2))
  
(deffunction forward (?lat ?lon ?crs ?spd ?secs)
	(bind ?dis (/ ?spd 60 3600)) ;; degrees in second
	(bind ?wid (* ?dis ?secs))
	(bind ?phi (deg-rad ?lat))
	(bind ?lam (deg-rad ?lon))
	(bind ?azi (deg-rad ?crs))
	(bind ?wir (deg-rad ?wid))
	(spherical-between ?phi ?lam ?wir ?azi))
	


	
	

			 

	



	
