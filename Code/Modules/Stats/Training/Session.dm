//system for tracking gains in a given training session
mob/var/tmp
	startingbp=0
	insession=0

mob/verb/Training_Session()
	set category = "Other"
	var/choice=alert(usr,"Would you like to start a new session, or view the current session?","","New Session","View Session")
	switch(choice)
		if("New Session")
			usr.startingbp=usr.BP
			usr.insession=1
			usr<<"Session started!"
		if("View Session")
			if(!usr.insession)
				usr<<"You need to start a session first!"
				return
			var/sessionbp=usr.BP-usr.startingbp
			usr<<"So far, you have gained [sessionbp] battle power!"