mob/keyable/verb/Observe(mob/M in player_list)
	set category="Skills"
	if(istype(M,/mob/lobby)) return
	if(M==usr)
		usr.client.perspective=MOB_PERSPECTIVE
		usr.client.eye=src
		usr.observingnow=0
		return
	if(M.isconcealed||M.Race=="Android"||M.expressedBP <= 5)
		usr<<"You can't find their energy!"
		return
	usr.observingnow=1
	usr.client.perspective=EYE_PERSPECTIVE
	usr.client.eye=M

mob/verb/Reset_View()
	set category="Other"
	usr.client.perspective=MOB_PERSPECTIVE
	usr.client.eye=src
	usr.observingnow=0