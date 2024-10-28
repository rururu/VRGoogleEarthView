;; KML Generation

;;;;;;;;;;;;;;;;;;;;;; G L O B A L S ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defglobal
	?*CAM-HDG* = 0
	?*CAM-ALT* = 0
	?*CAM-TLT* = 80
	?*CAM-RNG* = 100
	?*FLT-KML-PATH* = "resources/public/kml/Fleet.kml"
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
"
	?*BOAT-KML* = 
	"<Placemark>
	  <styleUrl>#1</styleUrl>
	  <name>$name</name>
	  <description>On board of boat in Race</description>
	  <Point>
		<coordinates>$lon,$lat,0</coordinates>
	  </Point>
	</Placemark>"
	?*FLEET-PFX-KML* =
	"<kml xmlns=\"http://www.opengis.net/kml/2.2\"
	xmlns:gx=\"http://www.google.com/kml/ext/2.2\">
	<Document>
	  <Style id=\"1\">
	    <IconStyle>
		  <Icon>
		   <href>img/sailing.png</href>
		  </Icon>
	    </IconStyle>
	  </Style>"
	?*FLEET-SFX-KML* =
	"</Document>
</kml>
")

;;;;;;;;;;;;;;;;;;;; F U N C T I O N S ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deffunction name-correction (?name)
	(bind ?name (str-replace ?name "<" ""))
	(bind ?name (str-replace ?name ">" ""))
	?name)

(deffunction substitute-in-kml (?kml ?name ?lat ?lon ?hdg)
	(bind ?name (name-correction ?name))
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

(deffunction create-fleet-kml ()
	(bind ?kml ?*FLEET-PFX-KML*)
	(do-for-all-facts ((?b Boat)) TRUE
		(if (eq ?b:onboard FALSE)
			then
			(bind ?lat ?b:lat)
			(bind ?lon ?b:lon)
			(bind ?bpm ?*BOAT-KML*)
			(bind ?bpm (str-replace ?bpm "$name" (name-correction ?b:name)))
			(bind ?bpm (str-replace ?bpm "$lat" (str-cat ?lat)))
			(bind ?bpm (str-replace ?bpm "$lon" (str-cat ?lon)))
			(bind ?kml (str-cat ?kml ?bpm))))
	(bind ?kml (str-cat ?kml ?*FLEET-SFX-KML*))
	?kml)
	
(deffunction create-onboard-kml ()
	(bind ?kml "")
	(do-for-fact ((?b Boat)) (eq ?b:onboard TRUE)
		(bind ?ang (deg-rad ?b:crs))
		(bind ?lat2 (fut-lat ?b:lat ?b:spd ?*interval* ?ang))
		(bind ?lon2 (fut-lon ?b:lon ?b:spd ?*interval* ?ang ?b:lat))
		(bind ?name (name-correction ?b:name))
		(bind ?kml (substitute-in-kml ?*TEMP-KML* ?name ?lat2 ?lon2 (+ ?b:crs ?*CAM-HDG*))))
	?kml)
	
(deffunction save-fleet-kml ()
	(save-kml (create-fleet-kml) ?*FLT-KML-PATH*))
	

		

