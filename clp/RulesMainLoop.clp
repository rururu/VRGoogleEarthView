;; Main Defrules
;;;;;;;;;;;;;;;;;;;;;;;; MAIN LOOP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule step-clock
	(declare (salience -100))
	?c <- (clock ?t)
	=>
	(pause 1)
	(retract ?c)
	(assert (clock (+ ?t 1)))
	(run))

(defrule Main-loop
	(declare (salience +1))
	(MY-BOAT ?mb)
	(clock ?t)
	(test (= (mod ?t ?*pause*) 0))
    =>
    (println "clock " ?t)
    (bind ?*gmt* (gm-time))
    (if (neq ?*race* EOF)
		then
		(load-facts (str-cat "NMEA_CACHE/" ?*race* "/GPRMC.txt"))
		(load-facts (str-cat "NMEA_CACHE/" ?*race* "/boat_models.fct")))
		(assert (Information phase))
		else
		(bind ?*race* (read-file "NMEA_CACHE/RACE.txt")))
		
;;;;;;;;;;;;;;;;;;;;;;;; INFORMATION PHASE ;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule Old-timestamp
	?p <- (Information phase)
    ?ts <- (timestamp ?time1)
    ?mbi <- (MyBoatInfo (timestamp ?time2))
    (test (eq ?time1 ?time2))
    =>
	(retract ?mbi)
	(move-boats ?*pause*)
	;;(println "Visualisation phase 1")
	(retract ?p)
	(assert (Visualisation phase)))

(defrule New-timestamp
	(Information phase)
    ?ts <- (timestamp ?time1)
    ?mbi <- (MyBoatInfo (timestamp ?time2))
    (test (neq ?time1 ?time2))
    =>
	(println "New Info Timestamp " ?time2)
	(retract ?ts)
	(do-for-all-facts ((?b Boat)) TRUE
		(retract ?b))
	(println "Fleet " (load-facts (str-cat "NMEA_CACHE/" ?*race* "/AIVDM.txt"))))
	
(defrule Assert-Boat
	(Information phase)
	?bi <- (BoatInfo 
				(motion ?lat ?lon ?crs ?spd)
				(mmsi ?mmsi))
	?bn <- (boat-name ?name ?mmsi)
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
    ?mbi <- (MyBoatInfo 
				(timestamp ?time2)
				(motion ?lat ?lon ?crs ?spd))
	(MY-BOAT ?n)
	(clock ?c)
	(not (Boat (name ?n)))
	=>
	(retract ?mbi)
	(retract ?p)
	(println "Onboard boat " ?n " lat " ?lat " lon " ?lon " crs " ?crs " spd " ?spd)
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
		 		(info-clock ?c)
				(clock ?c)))
	;;(println "Visualisation phase 2")
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
	(clock ?c)
	=>
	(println "Onboard Boat " ?obb " lat " ?lat " lon " ?lon " crs " ?crs " spd " ?spd)
	(modify ?ob (onboard FALSE))
	(modify ?nb (onboard TRUE)
		 		(info-clock ?c)
				(clock ?c)))
		 			
;;;;;;;;;;;;;;;;;;;;;;;; VISUALISATION PHASE ;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule Write-chart-file
    (Visualisation phase)
    =>
    ;;(println "Write-chart-file")
    (write-file "resources/public/chart/fleet.geojson" (create-fleet-geojson)))
    
(defrule Continue-main-loop
    (declare (salience -1))
    ?p <- (Visualisation phase)
    =>
    (retract ?p))
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    


	

