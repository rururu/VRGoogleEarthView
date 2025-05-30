;; Deftemplates

(deftemplate Boat
    (slot name (type STRING))
    (slot lat (type FLOAT))
    (slot lon (type FLOAT))
    (slot crs (type FLOAT))
    (slot spd (type FLOAT))
	(slot time (type INTEGER))
    (slot mmsi (type INTEGER))
	(slot type (type STRING))
	(slot model (type FACT-ADDRESS))
    (slot onboard (type SYMBOL)(default FALSE))
	(slot info-date (type STRING)))
    
(deftemplate Model
    (slot boat (type STRING)(default ""))
	(slot type (type STRING)(default ""))
	(slot gltf (type STRING))
	(slot scale (type FLOAT))
	(slot draft (type INTEGER))
	(slot extra (type STRING)(default "")))
	
(deftemplate BoatModel
	(slot boat (type STRING))
	(slot model (type STRING)))




