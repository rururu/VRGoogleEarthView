;; RulesControl

;;;;;;;;;;;;;;;;;;;;;;;; C O N T R O L ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule Go-onboard-cmd
	?cmd <- (Command onboard ?n1)
	?b1 <- (Boat (name ?n1) (onboard FALSE))
	?b2 <- (Boat (name ?n2)(onboard TRUE))
	=>
	(println "Command: Go onboard " ?n1)
	(retract ?cmd)
	(modify ?b1 (onboard TRUE))
	(modify ?b2 (onboard FALSE)))
  
(defrule Update-model-cmd
	?cmd <- (Command update-model ?scale ?draft)
	?m <- (Model (type ?type))
	?b <- (Boat (name ?n)(onboard TRUE)(model ?m))
	=>
	(println "Command: Update model for " ?n ": " ?type " " ?scale " " ?draft)
	(modify ?m (scale ?scale)(draft ?draft))
	(retract ?cmd))
	
(defrule KML-view
	?cmd <- (Command kml-cam-hdg ?dir)
	=>
	(println "Command: kml-cam-hdg " ?dir)
	(bind ?*CAM-HDG* ?dir)
	(retract ?cmd))
	
(defrule KML-camera_altitude
	?cmd <- (Command kml-cam-alt ?alt)
	=>
	(println "Command: kml-cam-alt " ?alt)
	(bind ?*CAM-ALT* ?alt)
	(retract ?cmd))
	
(defrule KML-camera_tilt
	?cmd <- (Command kml-cam_tilt ?tlt)
	=>
	(println "Command: kml-cam_tilt " ?tlt)
	(bind ?*CAM-TLT* ?tlt)
	(retract ?cmd))

(defrule KML-camera_range
	?cmd <- (Command kml-cam_rng ?rng)
	=>
	(println "Command: kml-cam_rng " ?rng)
	(bind ?*CAM-RNG* ?rng)
	(retract ?cmd))
	
(defrule Go_onboard
	?onb <- (ONB-BOAT ?onb1)
	?cmd <- (Command on-board ?onb2)
	(test (neq ?onb1 ?onb2))
	=>
	(println "Command: on-board " ?onb2)
	(retract ?onb ?cmd)
	(assert (ONB-BOAT ?onb2)))
	



