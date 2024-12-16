(clear)
(load clp/Templates.clp)
(load clp/GlobalsFunctions.clp)
(load clp/RulesControl.clp)
(load clp/RulesMainLoop.clp)
(load clp/KMLGeneration.clp)
(load clp/Facts.clp)
(reset)
(clear-file ?*cmd-path*)
(clear-file ?*rst-path*)
(assert 
	(Step phase)
	(clock 0)
	(future 0.0))
(run)


