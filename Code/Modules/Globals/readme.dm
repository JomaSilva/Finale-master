proc/generateTXT()
	var/thetext = {"
	Hello! If you're seeing this file, that means Dragonball Climax launched successfully! In order to help you out with your new server,
	I'd like to tell you a few things!
	You have a few files that are 'deletable' and 'not deletable'
	First and formost, the ItemSave and MapSave files contain the save data for the map. All objects dropped on the floor that can
	be saved will be saved here. MapSave saves ONLY all the PLAYER MADE TURFS. This means that if you manually changed a turf or two,
	unless it was player made, you will not see it update.
	Also, there's the whole \"MobSave\" file. It's the same as ItemSave, but for custom NPCs and dormant bodies. 
	GAIN contains your gains.
	Illegal contains your illegal/legal races.
	Ban contains the player bans (on software side, sticky bans WILL need to be made VIA byond list. I think only the host can do this!)
	Admins contains the manual admins. Host is automatically an admin.
	Rank contains rank data.
	Year contains year data.
	Persistant Settings contains other misc settings you'd want to keep.
	Per Wipe Settings contains misc settings you want to keep between reboots, but don't want to keep when you restart. (E.G. the first SSJ)
	Other than that, everything else shouldn't be deleted!

	Ingame commands that also delete data: 
	-Normal Wipe Server
		This command deletes the data files Save/, RANK, Year, and PerWipeSettings. Save/ is an entire folder, by the way.
		At the end of the command, it'll delete the world, which is the same as shutting it down.

	-Wipe Clean Server
		This command deletes EVERYTHING. Essentially, it deletes all of the above, but also includes PersistantSettings, Illegal,
		and GAIN. Your directory should look pretty blank except for log files and the 'Admin' file.

	If you downloaded straight from the git, and intend on only hosting,
	then you should be able to delete everything in the folder but the dmb, rsc, and int file
	before first run to avoid issues with save data.



	-King
	"}
	fdel("INFO.txt")
	file("INFO.txt")<<"[thetext]"