;; Deffunctions

(defglobal
	?*interval* = 1
	?*data-interval* = 4
	?*race* = EOF
	?*CAM-HDG* = 0
	?*CAM-ALT* = 0
	?*CAM-TLT* = 80
	?*CAM-RNG* = 100
	?*boat-names* = (create$)
	?*cmd-path* = "resources/public/comm/command.txt"
	?*boat-names-path* = "resources/public/chart/fleet.txt"
	?*base* = "http://localhost:8448/")
  
(deffunction step-clock ()
	(assert (clock (integer (time)))))

(deffunction rand01 ()
  (/ (random 0 100000) 100000))

(deffunction rand-11 ()
  (- (* (rand01) 2.0) 1.0))
  
(deffunction rand-xy (?x ?y)
	(bind ?w (- ?y ?x))
	(+ ?x (* (rand01) ?w)))

(deffunction rand-array (?n ?min ?max)
  (bind ?a (create$))
  (loop-for-count ?n
    (bind ?a (create$ ?a (+ ?min (* (rand01) (- ?max ?min))))))
  ?a)

(deffunction read-file (?path)
    (if (open ?path rr "r")
		then
		(bind ?r (read rr))
		(close rr)
		(return ?r)
		else
		(println "read-file " ?path " error!")
		(return FALSE)))

(deffunction write-file (?path ?txt)
    (if (open ?path rw "w")
     then
      (printout rw ?txt)
      (close rw)
      (return TRUE)
     else
      (println "write-file " ?path " error!")
      (return FALSE)))
      
(deffunction clear-file (?path)
	(write-file ?path ""))
	
(deffunction empty-file-p (?path)
	(eq (read-file ?path) EOF))

(deffunction append-file (?path ?txt)
    (open ?path ra "a")
    (printout ra ?txt)
    (close ra))

(deffunction fut-lat (?lat ?knots ?sec ?ang)
  (+ ?lat (* (/ ?knots 3600 60) ?sec (cos ?ang))))

(deffunction fut-lon (?lon ?knots ?sec ?ang ?lat)
  (+ ?lon (/ (* (/ ?knots 3600 60) ?sec (sin ?ang)) (cos (deg-rad ?lat)))))

(deffunction move-boats (?time)
  (do-for-all-facts ((?b Boat)) TRUE
    (bind ?lat ?b:lat)
    (bind ?lon ?b:lon)
    (bind ?crs ?b:crs)
    (bind ?spd ?b:spd)
    (bind ?ang (deg-rad ?crs))
    (bind ?lat2 (fut-lat ?lat ?spd ?time ?ang))
    (bind ?lon2 (fut-lon ?lon ?spd ?time ?ang ?lat))
 	(modify ?b 
		(lat ?lat2)
		(lon ?lon2)
		(crs ?crs)
		(spd ?spd))))

(deffunction boat-feature (?name ?lat ?lon ?course ?speed ?iconURL)
  (bind ?props (str-cat "{\"name\":\"" ?name "\",\"iconURL\":\"" ?iconURL "\",\"course\":" ?course ",\"speed\":" ?speed "}"))
  (bind ?coord (str-cat "[" ?lon "," ?lat "]"))
  (str-cat "{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":" 
            ?coord 
            "},\"properties\":" 
            ?props
            "}"))
                        
(deffunction create-fleet-geojson ()
	(bind ?geojson "{\"type\":\"FeatureCollection\",\"features\":[")
	(do-for-all-facts ((?b Boat)) TRUE
		(bind ?lat ?b:lat)
		(bind ?lon ?b:lon)
		(bind ?crs ?b:crs)
		(bind ?spd ?b:spd)
        (if ?b:onboard
            then 
            (bind ?url (str-cat ?*base* "img/yachtr.png"))
            else 
            (if (eq ?b:name "FRIGATE")
				then
				(bind ?url (str-cat ?*base* "img/tall.gif"))
				else 
				(bind ?url (str-cat ?*base* "img/yachtg.png"))))
        (bind ?geojson (str-cat ?geojson (boat-feature ?b:name ?lat ?lon ?crs ?spd ?url) ",")))
	(str-cat (sub-string 1 (- (str-length ?geojson) 1) ?geojson) "]}"))

(deffunction string> (?a ?b)
	(> (str-compare ?a ?b) 0))
	
(deffunction view-control-info ()
	;; boats
	(bind ?bns (create$))
	(bind ?onb "")
	(do-for-all-facts ((?b Boat)) TRUE
		(if ?b:onboard
		 then (bind ?onb ?b:name))
		(bind ?bns (create$ ?bns ?b:name)))	
	(bind ?bns (sort string> ?bns))
	(bind ?bs (str-cat "[\"" ?onb "\","))
	(foreach ?b ?bns
		(bind ?bs (str-cat ?bs "\"" ?b "\",")))
	(bind ?bs (str-cat (sub-string 1 (- (str-length ?bs) 1) ?bs) "]"))
	;; models
	(bind ?mns (create$))
	(do-for-all-facts ((?m Model)) TRUE
		(bind ?mns (create$ ?mns ?m:type)))
	(bind ?mns (sort string> ?mns))
	(bind ?ms "[")
	(foreach ?m ?mns
		(bind ?ms (str-cat ?ms "\"" ?m "\",")))
	(bind ?ms (str-cat (sub-string 1 (- (str-length ?ms) 1) ?ms) "]"))
	;; onbord model
	(bind ?onb-model "")
	(do-for-fact ((?b Boat)) ?b:onboard
		(bind ?onb-model (str-cat "[\"" ?b:name
			                        "\",\"" (fact-slot-value ?b:model type)
			                        "\",\"" (fact-slot-value ?b:model gltf)
			                        "\",\"" (fact-slot-value ?b:model scale)
			                        "\",\"" (fact-slot-value ?b:model draft) "\"]")))
	;; united json
	(str-cat "[{\"boats\":" ?bs ",\"models\":" ?ms ",\"onb_model\":" ?onb-model "}]"))

(deffunction save-mf (?mf ?path)
	(if (open ?path mf "w")
		then
		(foreach ?e ?mf
			(printout mf ?e crlf))
		(close mf)))



	



