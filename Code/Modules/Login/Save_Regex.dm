client
	verb
		exportSavefile()
			//set category = "DEBUG"
			set hidden = 1
			var/num = round(min(3,max(1,input(usr,"Which save number? It will be exported into \"Save/Exports/[usr.displaykey]/save_(the number here)_plaintext_savefile.txt\"","Save File Export") as num)))
			var/textfile = file("Save/Exports/[usr.displaykey]/save_[num]_plaintext_savefile.txt")
			var/savefile/F = file("Save/[usr.displaykey]/save[num].dbcsav")
			fdel(textfile)
			F.ExportText("/",textfile)

mob/Admin3/verb
	ImportSavefile()//for use with above after manually unfucking a savefile.
		set category = "Admin"
		var/num = round(min(3,max(1,input(usr,"Which save number? It will be imported from \"Save/Exports/[usr.displaykey]/save_(the number here)_plaintext_savefile.txt\" This number is rounded, and counts from 1 to 3.","Save File Export") as num)))
		var/textfile = file("Save/Exports/[usr.displaykey]/save_[num]_plaintext_savefile.txt")
		var/savefile/F = file("Save/[usr.displaykey]/save[num].dbcsav")
		F.ImportText("/",textfile)

//Issue: Sometimes objects are left within savefiles that make them unusable.
//Solution: Store savefile version, upon identifying update that causes issues, update savefile version internally and develop a fix. Ensure savefiles start with the newest version.
//Never go back on a version. (may be updated further to be time-based and version based?)
var/savefile_ver = "1.0"

var/savefile_fix_index = list("1.0" = list("remove" = list("","")))
//format: version = list(operation = list(args,target string))
proc/savefile_fix(save, s_ver) //clean up occasionally, older save issues may not need to be addressed anymore.
	//save, save version
	var/list/operation_list = list()
	//alright, first grab the operations we need to do
	for(var/i in savefile_fix_index)
		if(i == s_ver)
			operation_list.Add(savefile_fix_index[i])
	//then parse each operation using a proc below.
	for(var/i in operation_list)
		switch(i)
			if("remove")
				savefile_remove(save,operation_list[i])
			if("obliterate")
				savefile_obliterate(save,operation_list[i])
	




proc/savefile_obliterate(save, text)//this will take a matching string and "obliterate" the string and everything after it until it hits the next entry. (dont use this on variables.)

proc/savefile_remove(save, text)//this will simply remove the matching string's line. Useful for variable removal.