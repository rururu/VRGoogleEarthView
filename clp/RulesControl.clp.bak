;; RulesControl

(deffunction execute-commands ()
	(bind ?c (read-file ?*cmd-path*))
	(if (and (neq ?c EOF)(> (str-length ?c) 2)(eq (sub-string 1 2 ?c) "C:"))
		then
		(bind ?c (sub-string 3 (str-length ?c) ?c))
		(bind ?c (str-replace ?c "~" "\""))
		(println "Command: " ?c)
		(bind ?r (eval ?c))
		(println "Result: " ?r)
		(bind ?r (if (numberp ?r) then ?r
					else (if (stringp ?r) then (str-cat "\"" ?r "\"")
					else (if (symbolp ?r) then ?r
					else (if (multifieldp ?r) then (str-cat "(" (implode$ ?r) ")")
					else "")))))
		(write-file ?*cmd-path* (str-cat "R:" ?r))))
		
;;;;;;;;;;;;;;;;;;;;;; Command execution by rule  ;;;;;;;;;;;;;;;;;;;;;		
	 	
(defrule KML-view
	?cmd <- (Kml-cam-hdg ?dir)
	=>
	;(println "Kml-cam-hdg " ?dir)
	(bind ?*CAM-HDG* ?dir)
	(retract ?cmd))
	
(defrule KML-camera_altitude
	?cmd <- (Kml-cam-alt ?alt)
	=>
	;(println "Kml-cam-alt " ?alt)
	(bind ?*CAM-ALT* ?alt)
	(retract ?cmd))
	
(defrule KML-camera_tilt
	?cmd <- (Kml-cam_tilt ?tlt)
	=>
	;(println "Kml-cam_tilt " ?tlt)
	(bind ?*CAM-TLT* ?tlt)
	(retract ?cmd))

(defrule KML-camera_range
	?cmd <- (Kml-cam_rng ?rng)
	=>
	;(println "Kml-cam_rng " ?rng)
	(bind ?*CAM-RNG* ?rng)
	(retract ?cmd))
	
(defrule Go_onboard
	?onb <- (ONB-BOAT ?onb1)
	?cmd <- (On-board ?onb2)
	(test (neq ?onb1 ?onb2))
	=>
	;(println "On-board " ?onb2)
	(retract ?onb ?cmd)
	(assert (ONB-BOAT ?onb2)))
	
;(defrule Update-model-cmd
	;?cmd <- (Update model ?scale ?draft)
	;?m <- (Model (type ?type))
	;?b <- (Boat (name ?n)(onboard TRUE)(model ?m))
	;=>
	;(println "Command: Update model for " ?n ": " ?type " " ?scale " " ?draft)
	;(retract ?cmd)
	;(modify ?m (scale ?scale)(draft ?draft)))
	
	



