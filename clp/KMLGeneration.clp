;; KML Generation

;;;;;;;;;;;;;;;;;;;;;; G L O B A L S ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defglobal
	?*CAM-HDG* = 0
	?*CAM-ALT* = 0
	?*CAM-TLT* = 80
	?*CAM-RNG* = 100
	?*KML-PATH* = "resources/public/kml/Camera.kml"
	?*TEMP-KML* = "<kml xmlns=\"http://www.opengis.net/kml/2.2\"
 xmlns:gx=\"http://www.google.com/kml/ext/2.2\">
  <Document>
	  <LookAt>
		<longitude>$lon</longitude>
		<latitude>$lat</latitude>
		<range>$rng</range>
		<tilt>$tlt</tilt>
        <altitude>$alt</altitude>
		<heading>$hdg</heading>
		<altitudeMode>relativeToGround</altitudeMode>
	  </LookAt>
      <Style id=\"1\">
        <IconStyle>
          <Icon>
           <href>img/sailing.png</href>
        </Icon>
      </IconStyle>
    </Style>
	<Placemark>
	  <styleUrl>#1</styleUrl>
	  <name>$name</name>
	  <description>On board of boat in Race</description>
	  <Point>
		<coordinates>$lon,$lat,0</coordinates>
	  </Point>
	</Placemark>
  </Document>
</kml>
")

;;;;;;;;;;;;;;;;;;;; F U N C T I O N S ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deffunction substitute-in-kml (?kml ?name ?lat ?lon ?hdg)
	(bind ?kml (str-replace ?kml "$name" (str-cat ?name)))
	(bind ?kml (str-replace ?kml "$lat" (str-cat ?lat)))
	(bind ?kml (str-replace ?kml "$lon" (str-cat ?lon)))
	(bind ?kml (str-replace ?kml "$hdg" (str-cat ?hdg)))
	(bind ?kml (str-replace ?kml "$alt" (str-cat ?*CAM-ALT*)))
	(bind ?kml (str-replace ?kml "$tlt" (str-cat ?*CAM-TLT*)))
	(bind ?kml (str-replace ?kml "$rng" (str-cat ?*CAM-RNG*)))
	?kml)

(deffunction save-kml (?kml ?path)
	(if (open ?path kml "w")
		then
		(printout kml ?kml crlf)
		(close kml)))

;;;;;;;;;;;;;;;;;;;;;;;; R U L E S ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule OnboardBoatKMLIssue
	?obb <- (Boat (onboard TRUE)
				(name ?name)
				(lat ?lat)
				(lon ?lon)
				(crs ?crs)
				(spd ?spd)
		 		(info-clock ?icc)
		 		(clock ?obc))
	(clock ?c & :(> ?c ?obc))
	(test (= (mod ?c 4) 0))
	=>
	(bind ?elt (- ?c ?icc))
	(bind ?pila (forward ?lat ?lon ?crs ?spd ?elt))
	(bind ?lat (rad-deg (nth$ 1 ?pila)))
	(bind ?lon (rad-deg (nth$ 2 ?pila)))
	;;(println "OnbBoat " ?lat " " ?lon)
	(bind ?d (substitute-in-kml ?*TEMP-KML* ?name ?lat ?lon (+ ?crs ?*CAM-HDG*)))
	(save-kml ?d ?*KML-PATH*)
	(modify ?obb (clock ?c)))

		

