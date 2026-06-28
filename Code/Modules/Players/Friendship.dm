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
	list/enmity = list()     // other character's signature -> accumulated enmity points (only grows toward DECLARED rivals)
	list/rivals = list()     // signatures this character has declared as rival/enemy
	tmp/friend_tick = 0
	tmp/pendingFriendReq      // signature of whoever last asked THIS character to be friends
	tmp/pendingFriendName     // their display name
	tmp/lastDamager           // last mob to land a melee hit on this character (credits friend-harm enmity)

var
	FRIEND_RANGE    = 6   // how close (tiles, within view) two players must be to bond
	FRIEND_RATE     = 0.1 // friendship gained per accrual step while together (was 0.5 — proximity bonded far too fast)
	FRIEND_REQ      = 50  // points needed to count as a real friend (drives the fury trigger)
	FRIEND_THROTTLE = 10  // only run the proximity scan once every N GlobalStats cycles (keeps it cheap)
	ACQUAINTANCE_CAP   = 49 // proximity ALONE caps just below Friend; a real friendship needs an accepted request
	ENMITY_HIT         = 1  // enmity gained each time a declared rival lands a hit on you
	ENMITY_FRIEND_KO   = 25 // enmity gained when a declared rival KOs a friend of yours
	ENMITY_FRIEND_KILL = 60 // enmity gained when a declared rival kills a friend of yours
	ENMITY_MAX         = 200// enmity ceiling (mirrors friendship's 'Bonded' scale)

mob/proc/accrue_friendship()
	if(!client || isNPC || !signature) return
	friend_tick++
	if(friend_tick < FRIEND_THROTTLE) return
	friend_tick = 0
	for(var/mob/M in view(FRIEND_RANGE, src))
		if(M == src || !M.client || M.isNPC || !M.signature) continue
		if(M.signature in rivals) continue //a declared rival never breeds friendship from proximity — only enmity grows
		var/cur = friendship["[M.signature]"]
		if(cur >= FRIEND_REQ)
			friendship["[M.signature]"] = min(cur + FRIEND_RATE, 200) //already friends: closeness keeps growing toward 'Bonded'
		else
			friendship["[M.signature]"] = min(cur + FRIEND_RATE, ACQUAINTANCE_CAP) //not friends yet: proximity caps at acquaintance until a friend request is accepted
		if(isnull(known_contact_list["[M.signature]"]) && contact_list["[M.signature]"])
			known_contact_list["[M.signature]"] = contact_list["[M.signature]"] //seeing someone often makes them a known person (with their last snapshot)

mob/proc/is_friend(var/mob/M)
	if(!M || !M.signature || !friendship) return FALSE
	return friendship["[M.signature]"] >= FRIEND_REQ

// Degree-of-acquaintance label derived from accumulated friendship points (drives the Known People tab).
mob/proc/acquaintance_label(var/fpts)
	if(!fpts) return "Barely Known"
	if(fpts >= 200) return "Bonded"
	if(fpts >= FRIEND_REQ) return "Friend"
	if(fpts >= 20) return "Familiar"
	if(fpts >= 5) return "Acquaintance"
	return "Barely Known"

// =====================================================================
// ENMITY / RIVALRY — mirrors friendship, but unlike friendship it does
// NOT grow from proximity. It only rises toward someone you have chosen
// as a rival/enemy, and only when they hurt you or harm your friends.
// =====================================================================
mob/proc/enmity_label(var/epts)
	if(!epts) return ""
	if(epts >= 150) return "Nemesis"
	if(epts >= 75)  return "Hated Rival"
	if(epts >= 25)  return "Rival"
	if(epts >= 5)   return "Disliked"
	return ""

mob/proc/add_enmity(var/mob/foe, var/amt)
	if(!foe || !foe.signature || foe == src || !signature || isNPC) return
	if(!(foe.signature in rivals)) return //only builds toward a rival/enemy you've chosen
	enmity["[foe.signature]"] = min(enmity["[foe.signature]"] + amt, ENMITY_MAX)

// Run on a victim: nearby FRIENDS who declared the harmer a rival gain enmity.
mob/proc/friend_harmed_by(var/mob/harmer, var/amt)
	if(!harmer || !harmer.signature) return
	for(var/mob/A in view(src))
		if(A == src || A == harmer || !A.client || A.isNPC || !A.signature) continue
		if(A.is_friend(src) && (harmer.signature in A.rivals))
			A.add_enmity(harmer, amt)
			to_chat(A, "<font color=red>Seeing [src] hurt at the hands of [harmer] fuels your hatred.</font>")

mob/verb/Request_Friendship()
	set category = null
	set name = "Request Friendship"
	set src in oview(3)
	if(src == usr || !usr.client || !src.client || usr.isNPC || src.isNPC) return
	if(!usr.signature || !src.signature) return
	if(usr.is_friend(src))
		to_chat(usr, "You are already friends with [src].")
		return
	src.pendingFriendReq = usr.signature
	src.pendingFriendName = usr.name
	to_chat(usr, "<font color=#88cc88>You ask [src] to be your friend.</font>")
	to_chat(src, "<font color=#88cc88><b>[usr] wants to be your friend!</b> Right-click them and choose 'Accept Friendship' (or 'Decline Friendship').</font>")

mob/verb/Accept_Friendship()
	set category = null
	set name = "Accept Friendship"
	set src in oview(3)
	if(usr.pendingFriendReq != src.signature)
		to_chat(usr, "[src] hasn't asked to be your friend.")
		return
	usr.pendingFriendReq = null
	usr.pendingFriendName = null
	usr.friendship["[src.signature]"] = max(usr.friendship["[src.signature]"], FRIEND_REQ)
	src.friendship["[usr.signature]"] = max(src.friendship["[usr.signature]"], FRIEND_REQ)
	to_chat(usr, "<font color=#88cc88><b>You and [src] are now friends!</b></font>")
	to_chat(src, "<font color=#88cc88><b>[usr] accepted your friendship!</b></font>")

mob/verb/Decline_Friendship()
	set category = null
	set name = "Decline Friendship"
	set src in oview(3)
	if(usr.pendingFriendReq != src.signature)
		to_chat(usr, "[src] hasn't asked to be your friend.")
		return
	usr.pendingFriendReq = null
	usr.pendingFriendName = null
	to_chat(usr, "You decline [src]'s offer of friendship.")
	to_chat(src, "[usr] declined your friendship request.")

mob/verb/Declare_Rival()
	set category = null
	set name = "Declare Rival/Enemy"
	set src in oview(5)
	if(src == usr || !src.signature || src.isNPC || !src.client) return
	if(src.signature in usr.rivals)
		usr.rivals -= src.signature
		to_chat(usr, "You no longer consider [src] a rival.")
	else
		usr.rivals += src.signature
		to_chat(usr, "<font color=red>You have declared [src] your rival. Their attacks on you — or on your friends — will breed enmity.</font>")

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
		to_chat(src, "<font color=yellow><b>Through relentless training and flawless ki control, a new power stirs within you — Super Saiyan 3 is finally within your grasp!</b></font>")
		emit_Sound('powerup.wav')
