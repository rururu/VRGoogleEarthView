;; Deffunctions

(defglobal
  ?*pause* = 20
  ?*race* = EOF
  ?*gmt* = (gm-time)
  ?*boat-names* = (create$)
  ?*boat-names-path* = "resources/public/chart/fleet.txt"
  ?*base* = "http://localhost:8448/")
  

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

(deffunction pause (?delay)
   (bind ?start (time))
   (while (< (time) (+ ?start ?delay)) do))

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

(deffunction epoch-from-gmt (?gmt ?sec)
  (bind ?y (nth$ 1 ?gmt))
  (bind ?mn (nth$ 2 ?gmt))
  (bind ?d (nth$ 3 ?gmt))
  (bind ?h (nth$ 4 ?gmt))
  (bind ?m (nth$ 5 ?gmt))
  (bind ?s (nth$ 6 ?gmt))
  (bind ?ss (min (+ ?s (* ?m 60) (* ?h 3600) ?sec) (* 60 60 24))) ;; stop at midnight
  (bind ?rhs (mod ?ss 3600))
  (if (= ?rhs 0)
    then (bind ?h (integer (/ ?ss 3600))) (bind ?m 0) (bind ?s 0)
    else
    (bind ?h (integer (/ ?ss 3600))) (bind ?m (integer (/ ?rhs 60))) (bind ?s (mod ?rhs 60)))
  (format nil "%04d-%02d-%02dT%02d:%02d:%02dZ" ?y ?mn ?d ?h ?m ?s))

(deffunction boat-feature (?name ?lat ?lon ?course ?speed ?iconURL)
  (bind ?props (str-cat "{\"name\":\"" ?name "\",\"iconURL\":\"" ?iconURL "\",\"course\":" ?course ",\"speed\":" ?speed "}"))
  (bind ?coord (str-cat "[" ?lon "," ?lat "]"))
  (str-cat "{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":" 
            ?coord 
            "},\"properties\":" 
            ?props
            "}"))

(deffunction document (?start)
	(bind ?clk (str-cat "{\"currentTime\":\""
						?start
						"\"}"))
    (str-cat "{\"id\":\"document\",\"version\":\"1.0\",\"clock\":" ?clk "}"))
            
(deffunction boat-view3d-label (?name)
  (str-cat "{\"text\":\""
            ?name 
            "\",\"scale\":0.3,\"pixelOffset\":{\"cartesian2\":[0.0, -40.0]}"
            "}"))
            ;;",\"heightReference\":\"RELATIVE_TO_GROUND\"}"))

(deffunction boat-view3d-model (?model)
  (bind ?gltf (fact-slot-value ?model gltf))
  (bind ?scale (fact-slot-value ?model scale))
  (bind ?extra (fact-slot-value ?model extra))
  (str-cat "{\"gltf\":\"" ?gltf "\""
            ",\"scale\":" ?scale
            ?extra
            ;;"}"))
            ;;",\"heightReference\":\"CLAMP_TO_GROUND\"}"))
            ",\"heightReference\":\"RELATIVE_TO_GROUND\"}"))
            
(deffunction boat-view3d-altitude (?model)
  (bind ?draft (fact-slot-value ?model draft))
  (if (eq ?draft nil)
	then
	(bind ?draft 0))
  (- 0 ?draft))

(deffunction boat-view3d (?name ?start ?finish ?lat ?lon ?lat2 ?lon2 ?model)
  (bind ?lab (boat-view3d-label ?name))
  (bind ?mod (boat-view3d-model ?model))
  (bind ?alt (boat-view3d-altitude ?model))
  (bind ?cgd (str-cat "[\"" ?start "\"," ?lon "," ?lat "," ?alt ",\"" ?finish "\"," ?lon2 "," ?lat2 "," ?alt "]"))
  (str-cat "{\"id\":\"" 
            ?name 
            "\",\"label\":" 
            ?lab 
            ",\"model\":" 
            ?mod 
            ",\"orientation\":{\"velocityReference\":\"#position\"}"
            ",\"position\":{\"cartographicDegrees\":"
            ?cgd
            ",\"interpolationAlgorithm\":\"LINEAR\""
            ",\"forwardExtrapolationType\":\"HOLD\"}}"))
            
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

(deffunction add-boats-to-view3d-packet (?pv3 ?start ?time ?finish)
   (do-for-all-facts ((?b Boat)(?m Model)) (eq ?b:model ?m)
		(bind ?lat (nth$ 1 ?b:motion))
		(bind ?lon (nth$ 2 ?b:motion))
		(bind ?crs (nth$ 3 ?b:motion))
		(bind ?spd (nth$ 4 ?b:motion))
		(bind ?ang (deg-rad ?crs))
		(bind ?lat2 (fut-lat ?lat ?spd ?time ?ang))
		(bind ?lon2 (fut-lon ?lon ?spd ?time ?ang ?lat))
        (bind ?pv3 (str-cat ?pv3 "," (boat-view3d ?b:name ?start ?finish ?lat ?lon ?lat2 ?lon2 ?m))))
	?pv3)
	
(deffunction create-fleet-czml ()
    (bind ?start (epoch-from-gmt ?*gmt* 0))
    (bind ?time (* 2 ?*pause*))
    (bind ?finish (epoch-from-gmt ?*gmt* ?time))
    (bind ?doc (document ?start))
    (bind ?pv3 (str-cat "[" ?doc))
    (bind ?pv3 (add-boats-to-view3d-packet ?pv3 ?start ?time ?finish))
    (bind ?pv3 (str-cat ?pv3 "]"))
    ?pv3)
	
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



	



