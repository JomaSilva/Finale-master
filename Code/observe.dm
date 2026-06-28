mob/keyable/verb/Observe(mob/M in player_list)
	set category="Skills"
	if(istype(M,/mob/lobby)) return
	if(M==usr)
		usr.client.perspective=MOB_PERSPECTIVE
		usr.client.eye=src
		usr.observingnow=0
		return
	if(M.isconcealed||M.Race=="Android"||M.expressedBP <= 5)
		to_chat(usr, "You can't find their energy!")
		return
	usr.observingnow=1
	usr.client.perspective=EYE_PERSPECTIVE
	usr.client.eye=M

mob/verb/Reset_View()
	set category="Other"
	if(usr.piloting_ship && usr.piloted_ship) //piloting a ship -> return to your character on the bridge (not just reset the camera)
		usr.piloted_ship.return_to_interior(usr)
		return
	usr.client.perspective=MOB_PERSPECTIVE
	usr.client.eye=src
	usr.observingnow=0