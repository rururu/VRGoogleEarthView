(clear)
(load clp/Templates.clp)
(load clp/GlobalsFunctions.clp)
(load clp/RulesMainLoop.clp)
(load clp/KMLGeneration.clp)
(load clp/RulesControl.clp)
(load clp/Facts.clp)
(load clp/Sockets.clp)
(reset)
(assert (start-socket-server 127.0.0.1 8888))
(run)


