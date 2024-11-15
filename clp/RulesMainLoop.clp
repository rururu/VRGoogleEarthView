;; Main Loop

;;;;;;;;;;;;;;;;;;;;;;;; MAIN LOOP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deffunction pause (?now ?future)
	(bind ?delay (- ?future ?now))
	(if (> ?delay 0)
		then
		(while (< (time) (+ ?now ?delay)) do)))
		
(defrule Step
	?s <- (Step phase)
	?c <- (clock ?t)
	?f <- (future ?)
	=>
	;(println "Step phase")
	(execute-commands)
	(retract ?s ?c ?f)
	(bind ?t (time))
	(assert (future (+ ?t ?*interval*)))
	(assert (clock (integer ?t)))
	(assert (Work phase)))

(defrule Continue-main-loop
    (declare (salience -100))
    ?w <- (Work phase)
	(future ?fut)
    =>
    (retract ?w)
	(pause (time) ?fut)
	(assert (Step phase)))

;;;;;;;;;;;;;;;;;;;;;;;; WORK PHASE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
(defrule Work-phase
	(Work phase)
	(MY-BOAT ?mb)
	(clock ?t)
    =>
    (if (and ?*race* (neq ?*race* EOF))
		then
		(if (load-csv-ordered-facts (str-cat "NMEA_CACHE/" ?*race* "/MyBoat.csv") "MyBoat")
			then
			(assert (Information phase)))
		else
		(bind ?*race* (read-file "NMEA_CACHE/RACE.txt"))))
		
;;;;;;;;;;;;;;;;;;;;;;;; INFORMATION PHASE ;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule Old-timestamp
	?p <- (Information phase)
    ?ts <- (timestamp ?time1)
    ?mbi <- (MyBoat ?time2 $?)
    (test (eq ?time1 ?time2))
    =>
	(retract ?mbi)
	(move-boats ?*data-interval*)
	(retract ?p)
	(assert (Visualisation phase)))

(defrule New-timestamp
	(Information phase)
    ?ts <- (timestamp ?time1)
    ?mbi <- (MyBoat ?time2 $?)
    (clock ?t)
    (test (neq ?time1 ?time2))
    =>
    (println "clock " ?t)
	(println "New Info Timestamp " ?time2)
	(retract ?ts)
	(do-for-all-facts ((?b Boat)) TRUE
		(retract ?b))
	(println "BoatInfos " (load-csv-ordered-facts (str-cat "NMEA_CACHE/" ?*race* "/BoatInfo.csv") "BoatInfo"))
	(println "BoatNames " (load-csv-ordered-facts (str-cat "NMEA_CACHE/" ?*race* "/BoatName.csv") "BoatName")))
	
(defrule Assert-Boat
	(Information phase)
	?bi <- (BoatInfo 1 ?lat ?lon ?crs ?spd ?mmsi)
	?bn <- (BoatName 5 ?name ?mmsi)
	=>
	(retract ?bi ?bn)
	(assert (Boat (name ?name)
				(lat ?lat)
				(lon ?lon)
				(crs ?crs)
				(spd ?spd)
				(mmsi ?mmsi))))
				
(defrule AssertONB-BOAT
	(declare (salience +1))
	(MY-BOAT ?mb)
	(not (ONB-BOAT))
	=>
	(assert (ONB-BOAT ?mb)))
	
(defrule Assert-my-Boat
	(declare (salience -1))
	?p <- (Information phase)
    ?mbi <- (MyBoat ?time2 ?lat ?lon ?crs ?spd ?data)
	(MY-BOAT ?n)
	(clock ?t)
	(not (Boat (name ?n)))
	=>
	(retract ?mbi)
	(retract ?p)
	(println "My boat " ?n " lat " ?lat " lon " ?lon " crs " ?crs " spd " ?spd)
	(bind ?*boat-names* (create$ ?n))
	(do-for-all-facts ((?b Boat)) TRUE
		(bind ?*boat-names* (create$ ?*boat-names* ?b:name)))
	(save-mf ?*boat-names* ?*boat-names-path*)
	(bind ?dis (/ ?spd 60 3600)) ;; degrees in second
	(assert (timestamp ?time2))
	(assert (Boat (name ?n) 
				(lat ?lat) 
				(lon ?lon) 
				(crs ?crs) 
				(spd ?spd)
				(onboard TRUE)
		 		(info-clock ?t)
				(clock ?t)))
	(assert (Visualisation phase)))
    	
(defrule ChangeOnboardBoat
	(ONB-BOAT ?obb)
	?ob <- (Boat (onboard TRUE)
				(name ?obn & :(neq ?obn ?obb)))
	?nb <- (Boat (onboard FALSE)
				(name ?obb)
				(lat ?lat)
				(lon ?lon)
				(crs ?crs)
				(spd ?spd))
	(clock ?t)
	=>
	(println "Onboard Boat " ?obb " lat " ?lat " lon " ?lon " crs " ?crs " spd " ?spd)
	(modify ?ob (onboard FALSE))
	(modify ?nb (onboard TRUE)
		 		(info-clock ?t)
				(clock ?t)))
		 			
;;;;;;;;;;;;;;;;;;;;;;;; VISUALISATION PHASE ;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule Write-chart-file
    ?p <- (Visualisation phase)
    =>
    (write-file "resources/public/chart/fleet.geojson" (create-fleet-geojson))
    (retract ?p)
    (assert (Work phase)))
    
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    


	

