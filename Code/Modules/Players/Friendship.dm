// =====================================================================
// FRIENDSHIP
// Bonds grow automatically while two PLAYER characters stay near each
// other for a while. Friendship drives the emotional Super Saiyan trigger:
// seeing a close friend die or get beaten in a fight enrages you, which is
// what unlocks the next Saiyan stage (handled in KO/Death/Murder + the
// existing Emotion=="Very Angry" transformation gate).
// =====================================================================
mob/var
	list/friendship = list() // other character's signature -> accumulated friendship points (persists in the save)
	tmp/friend_tick = 0

var
	FRIEND_RANGE    = 6   // how close (tiles, within view) two players must be to bond
	FRIEND_RATE     = 0.5 // friendship gained per accrual step while together
	FRIEND_REQ      = 50  // points needed to count as a real friend (drives the fury trigger)
	FRIEND_THROTTLE = 10  // only run the proximity scan once every N GlobalStats cycles (keeps it cheap)

mob/proc/accrue_friendship()
	if(!client || isNPC || !signature) return
	friend_tick++
	if(friend_tick < FRIEND_THROTTLE) return
	friend_tick = 0
	for(var/mob/M in view(FRIEND_RANGE, src))
		if(M == src || !M.client || M.isNPC || !M.signature) continue
		friendship["[M.signature]"] += FRIEND_RATE

mob/proc/is_friend(var/mob/M)
	if(!M || !M.signature || !friendship) return FALSE
	return friendship["[M.signature]"] >= FRIEND_REQ

// =====================================================================
// SUPER SAIYAN 3 — unlike SSJ1/SSJ2 it is NOT awakened by rage. It is
// learned ALONE through training and high ki control: once a Saiyan's
// expressed power reaches a random 2x-3x of the SSJ3 requirement while
// sustaining full ki, they spontaneously grasp the form (chat notice).
// =====================================================================
mob/var/ssj3LearnReq = 0 // per-character random threshold, rolled once on first check

mob/proc/CheckSSj3Learn()
	if(ssj3able) return
	if(Class == "Legendary") return // Legendary Saiyans follow the LSSJ path instead
	if(!(Race == "Saiyan" || Parent_Race == "Saiyan" || canSSJ || (genome && genome.race_percent("Saiyan") >= 25))) return
	if(!ssj3LearnReq) ssj3LearnReq = ssj3at * (rand(200,300)/100) // random 2.0x - 3.0x per character
	if(expressedBP >= ssj3LearnReq && kiratio >= 1) // reached the power AND holding full ki = mastery of control
		ssj3able = 1
		src << "<font color=yellow><b>Through relentless training and flawless ki control, a new power stirs within you — Super Saiyan 3 is finally within your grasp!</b></font>"
		emit_Sound('powerup.wav')
