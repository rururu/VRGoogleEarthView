;; Boat Information and Movement

(defrule Assert-Boat
	?bi <- (BoatInfo 1 ?lat ?lon ?crs ?spd ?mmsi)
	?bn <- (BoatName 5 ?name ?mmsi)
	=>
	(retract ?bi ?bn)
	(assert (Boat (name ?name)
				(lat ?lat)
				(lon ?lon)
				(crs ?crs)
				(spd ?spd)
				(time (integer (time)))
				(mmsi ?mmsi))))
				
(defrule Assert-My-Boat1
    ?mb <- (MyBoat ?time ?lat ?lon ?crs ?spd ?date)
	(MY-BOAT ?n)
	(not (Boat (name ?n)))
	=>
	(retract ?mb)
	(bind ?idt (str-cat ?date " " ?time))
	(println "My boat " ?n " lat " ?lat " lon " ?lon " crs " ?crs " spd " ?spd)
	(assert (Boat (name ?n) 
				(time (integer (time)))
				(lat ?lat) 
				(lon ?lon) 
				(crs ?crs) 
				(spd ?spd)
				(onboard TRUE)
				(info-date ?idt))))
				
(defrule Assert-My-Boat2
    ?mb <- (MyBoat ?time ?lat ?lon ?crs ?spd ?date)
	(MY-BOAT ?n)
	?b <- (Boat (name ?n)
				(info-date ?idt1))
	=>
	(retract ?mb)
	(bind ?idt2 (str-cat ?date " " ?time))
	(if (after ?idt1 ?idt2)
		then
		(println "My boat " ?n " lat " ?lat " lon " ?lon " crs " ?crs " spd " ?spd)
		(modify ?b (time (integer (time)))
					(lat ?lat) 
					(lon ?lon) 
					(crs ?crs) 
					(spd ?spd)
					(info-date ?idt2))))
				
(defrule Retract-Old-Boat
	?bo <- (Boat (name ?n)
				(time ?to))
	?bn <- (Boat (name ?n)
				(time ?tn & :(> ?tn ?to)))
	=>
	(retract ?bo))
	
(defrule Move-All-Boats
	?mab <- (move all boats)
	=>
	(move-boats (integer(time)))
	(retract ?mab))
	
(defrule Print-Race
	?r <- (RACE ?race)
	=>
	(println "Race " ?race))
	
 

