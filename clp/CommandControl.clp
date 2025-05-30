;; Command Control
	 	
(deffunction head (?dir)
	(bind ?*CAM-HDG* (string-to-field ?dir)))
	
(deffunction altitude (?alt)
	(bind ?*CAM-ALT* (string-to-field ?alt)))
	
(deffunction alt-power (?alt)
	(bind ?*POW-ALT* (string-to-field ?alt)))

(deffunction tilt (?tlt)
	(bind ?*CAM-TLT* (string-to-field ?tlt)))

(deffunction range (?rng)
	(bind ?*CAM-RNG* (string-to-field ?rng)))
	
(deffunction exec (?exp)
	(println "Command: " ?exp)
	(eval ?exp))
	
(deffunction onboard (?bname)
	(assert (onboard ?bname)))
	

(defrule Update-onb-boat
	?onb <- (ONB-BOAT ?n1)
	?cmd <- (onboard ?n2 & :(neq ?n2 ?n1))
	=>
	(retract ?onb ?cmd)
	(assert (ONB-BOAT ?n2)))
	
(defrule Change_onboard
	(ONB-BOAT ?n1)
	?b1 <- (Boat (onboard FALSE)
				(name ?n1))
	?b2 <- (Boat (onboard TRUE)
				(name ?n2))
	=>
	(modify ?b2 (onboard FALSE))
	(modify ?b1 (onboard TRUE)))
	
(defrule Go_onboard
	(ONB-BOAT ?n1)
	?b1 <- (Boat (onboard FALSE)
				(name ?n1))
	(not (Boat (onboard TRUE)))
	=>
	(modify ?b1 (onboard TRUE)))

	

	



