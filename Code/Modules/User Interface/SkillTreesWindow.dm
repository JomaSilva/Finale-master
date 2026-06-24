obj/SkillTree/DummyTree
	var/datum/skill/tree/TreeType = null
	Click()
		usr.updateWindow = 0
		if(usr.IsLearning)
			return
		usr.IsLearning = 1
		if(TreeType&&usr.GetTreeMode==1)
			for(var/datum/skill/tree/S in usr.allowed_trees) if(S==TreeType)
				usr.getTree(S)
				usr.updateWindow = 0
				break
		if(TreeType&&usr.GetTreeMode==2)
			for(var/datum/skill/tree/S in usr.possessed_trees) if(S==TreeType)
				S.attemptrefund(0)
				usr.updateWindow = 0
				break
		if(TreeType&&!usr.GetTreeMode)
			for(var/datum/skill/tree/S in usr.possessed_trees) if(S==TreeType)
				usr.CurrentTree	 = S
				usr.SkillWindowOpen()
				usr.updateWindow = 0
				break
		usr.IsLearning = 0
obj/SkillTree/DummySkill
	var/datum/skill/SkillType = null
	Click()
		usr.updateWindow = 0
		if(usr.IsLearning)
			return
		usr.IsLearning = 1
		if(SkillType&&usr.LearnSkillMode)
			for(var/datum/skill/S in usr.CurrentTree.investedskills)
				if(S==SkillType&&S.can_forget)
					usr.CurrentTree.attemptforget(S)
					usr.updateWindow = 0
					break
				else
					if(S==SkillType)
						winset(usr,"SkillsListWindow.loglabel","text=\"Can't refund skill!\"")
						usr.updateWindow = 0
						break
		if(SkillType&&!usr.LearnSkillMode)
			for(var/datum/skill/S in usr.CurrentTree.constituentskills)
				if(S==SkillType)
					usr.CurrentTree.attemptlearn(S)
					usr.updateWindow = 0
					break
		//usr.SkillWindowRefreshDisplay()
		usr.IsLearning = 0
mob/var/tmp
	GetTreeMode = 0
	datum/skill/tree/CurrentTree = null
	WhichSkillWindow = null
	IsLearning = 0
	LearnSkillMode = 0
	updateWindow = 0
	list/SkillTreeContentsList = list() //objs die if they're not referenced by something.

mob/proc/SkillWindowRefreshDisplay()
	if(!inAwindow&&!WhichSkillWindow)
		return FALSE
	testunlocks()
	//outputline (to show stuff like errors)
	if(!updateWindow)
		if(WhichSkillWindow==2)
			winset(usr,"SkillsListWindow.skillpoints","text=\"Skillpoints: [usr.skillpoints]\"")
			spawn PopulateSkillWindow(CurrentTree)
			if(!LearnSkillMode)
				winset(usr,"SkillsListWindow.amirefunding","text=\"Learning Mode\"")
			else
				winset(usr,"SkillsListWindow.amirefunding","text=\"Forget Mode\"")
			if(winget(usr,"SkillsListWindow.loglabel","text")!=""&&!clearedline)
				clearedline = 1
				spawn(100)
					clearedline = 0
					winset(usr,"SkillsListWindow.loglabel","text=")
		if(WhichSkillWindow==1)
			winset(usr,"SkillTreeWindow.skillpoints","text=\"Skillpoints: [usr.skillpoints]\"")
			spawn PopulateTreeWindow()
			if(GetTreeMode==1)
				winset(usr,"SkillTreeWindow.switchtreelabel","text=\"Mode: Get Tree\"")
			if(GetTreeMode==2)
				winset(usr,"SkillTreeWindow.switchtreelabel","text=\"Mode: Forget Tree\"")
			if(!GetTreeMode)
				winset(usr,"SkillTreeWindow.switchtreelabel","text=\"Mode: Enter Tree\"")
			if(winget(usr,"SkillTreeWindow.loglabel","text")!=""&&!clearedline)
				clearedline = 1
				spawn(100)
					clearedline = 0
					winset(usr,"SkillTreeWindow.loglabel","text=")
	spawn(1) if(omegastun&&inAwindow&&WhichSkillWindow) SkillWindowRefreshDisplay()

obj/treewindow/verb
	learnskill()
		set hidden = 1
		usr.LearnSkillMode = 0
		usr.updateWindow = 0
		winset(usr,"SkillsListWindow.loglabel","text=\"Switched Modes!\"")
		winset(usr,"SkillsListWindow.amirefunding","text=\"Learning Mode\"")
	refundskill()
		set hidden = 1
		usr.LearnSkillMode = 1
		usr.updateWindow = 0
		winset(usr,"SkillsListWindow.loglabel","text=\"Switched Modes!\"")
		winset(usr,"SkillsListWindow.amirefunding","text=\"Forget Mode\"")
	backbutton()
		set hidden = 1
		usr.GetTreeMode = 0
		usr.CurrentTree = null
		usr.WhichSkillWindow = 1
		usr.LearnSkillMode = 0
		usr.updateWindow = 0
		usr.IsLearning = 0
		winshow(usr, "SkillsListWindow",0)
		winshow(usr, "SkillTreeWindow",1)
	donebutton()
		set hidden = 1
		usr.updateWindow = 0
		usr.TreeWindowClose()
		del(src)
	gettrees()
		set hidden = 1
		usr.GetTreeMode = 1
		usr.updateWindow = 0
	selecttrees()
		set hidden = 1
		usr.GetTreeMode = 0
		usr.updateWindow = 0
	refundtree()
		set hidden = 1
		usr.GetTreeMode = 2
		usr.updateWindow = 0

mob/proc/PopulateSkillWindow(var/datum/skill/tree/specifedTree)
	var/amount=6
	while(amount>=1)
		winset(usr,"SkillsListWindow.SkillListTier[amount]Grid","cells=0")
		amount-=1
	usr.SkillTreeContentsList = new/list()
	updateWindow = 1
	//world << "got here"
	var/count0 = 0
	var/count1 = 0
	var/count2 = 0
	var/count3 = 0
	var/count4 = 0
	var/count5 = 0
	var/count6 = 0
	var/list/SkillList = new/list
	if(!LearnSkillMode)
		for(var/datum/skill/A in specifedTree.constituentskills)
			var/flag=0
			if(locate(A.type) in learned_skills)flag=1
			if(A.enabled==0)flag=1
			if(A.override==1)flag=1
			if(A.tier>specifedTree.allowedtier)flag=1
			if(!flag)SkillList+=A
	else
		for(var/datum/skill/A in specifedTree.investedskills)
			var/flag
			if(locate(A.type) in learned_skills)flag=1
			if(A.can_forget == FALSE) flag = 0
			if(flag) SkillList+=A
	for(var/datum/skill/A in SkillList)
		var/obj/SkillTree/DummySkill/S = new/obj/SkillTree/DummySkill
		S.SkillType = A
		S.name = A.name
		S.icon = A.icon
		/*world << "[A.name]"*/
		usr.SkillTreeContentsList += S
		switch(A.tier)
			if(0)
				src<<output(S,"SkillsListWindow.SkillListTier[A.tier]Grid: [++count0]")
			if(1)
				src<<output(S,"SkillsListWindow.SkillListTier[A.tier]Grid: [++count1]")
			if(2)
				src<<output(S,"SkillsListWindow.SkillListTier[A.tier]Grid: [++count2]")
			if(3)
				src<<output(S,"SkillsListWindow.SkillListTier[A.tier]Grid: [++count3]")
			if(4)
				src<<output(S,"SkillsListWindow.SkillListTier[A.tier]Grid: [++count4]")
			if(5)
				src<<output(S,"SkillsListWindow.SkillListTier[A.tier]Grid: [++count5]")
			if(6)
				src<<output(S,"SkillsListWindow.SkillListTier[A.tier]Grid: [++count6]")
	winset(usr,null, \
		"SkillsListWindow.SkillListTier0Grid.cells=[count0];SkillsListWindow.SkillListTier1Grid.cells=[count1];SkillsListWindow.SkillListTier2Grid.cells=[count2]")
	winset(usr,null, \
		"SkillsListWindow.SkillListTier3Grid.cells=[count3];SkillsListWindow.SkillListTier4Grid.cells=[count4];SkillsListWindow.SkillListTier5Grid.cells=[count5];SkillsListWindow.SkillListTier6Grid.cells=[count6]")
mob/proc/PopulateTreeWindow()
	winset(usr,"SkillTreeWindow.SkillTreeTier0Grid","cells=0")
	usr << output(null,"SkillTreeWindow.SkillTreeTier0Grid")
	usr << output(null,"SkillTreeWindow.SkillTreeTier1Grid")
	usr << output(null,"SkillTreeWindow.SkillTreeTier2Grid")
	usr << output(null,"SkillTreeWindow.SkillTreeTier3Grid")
	usr << output(null,"SkillTreeWindow.SkillTreeTier4Grid")
	usr << output(null,"SkillTreeWindow.SkillTreeTier5Grid")
	usr << output(null,"SkillTreeWindow.SkillTreeTier6Grid")
	var/amount = 6
	while(amount>=1)
		winset(usr,"SkillTreeWindow.SkillTreeTier[amount]Grid","cells=0")
		amount-=1
	updateWindow = 1
	usr.SkillTreeContentsList = new/list()
	var/list/TreeList = new/list
	var/count0 = 0
	var/count1 = 0
	var/count2 = 0
	var/count3 = 0
	var/count4 = 0
	var/count5 = 0
	var/count6 = 0
	if(GetTreeMode==1)
		for(var/datum/skill/tree/A in allowed_trees)
			if(!(A in possessed_trees))
				var/flag
				if(locate(A.type) in TreeList)flag=1
				if(locate(A.type) in possessed_trees)flag=1
				if(A.enabled==0)flag=1
				if(A.override==1)flag=1
				if(GetTreeMode==2&&A.can_refund==FALSE) flag = 1
				if(!flag)TreeList+=A
	if(GetTreeMode==2||GetTreeMode==0)
		for(var/datum/skill/tree/A in possessed_trees)
			var/flag
			if(locate(A.type) in TreeList)flag=1
			if(A.enabled==0)flag=1
			if(A.override==1)flag=1
			if(GetTreeMode==2&&A.can_refund==FALSE) flag = 1
			if(!flag)TreeList+=A
	for(var/datum/skill/A in TreeList)
		var/obj/SkillTree/DummyTree/S = new/obj/SkillTree/DummyTree
		S.TreeType = A
		S.name = A.name
		S.icon = A.icon
		usr.SkillTreeContentsList += S
		switch(A.tier)
			if(0)
				src<<output(S,"SkillTreeWindow.SkillTreeTier0Grid: [++count0]")
			if(1)
				src<<output(S,"SkillTreeWindow.SkillTreeTier1Grid: [++count1]")
			if(2)
				src<<output(S,"SkillTreeWindow.SkillTreeTier2Grid: [++count2]")
			if(3)
				src<<output(S,"SkillTreeWindow.SkillTreeTier3Grid: [++count3]")
			if(4)
				src<<output(S,"SkillTreeWindow.SkillTreeTier4Grid: [++count4]")
			if(5)
				src<<output(S,"SkillTreeWindow.SkillTreeTier5Grid: [++count5]")
			if(6)
				src<<output(S,"SkillTreeWindow.SkillTreeTier6Grid: [++count6]")

mob/proc/TreeWindowOpen()
	contents += new /obj/treewindow
	omegastun = 1 //keeps users from doing shit when they're fighting.
	winshow(usr, "SkillTreeWindow",1)
	WhichSkillWindow=1
	updateWindow = 0
	SkillWindowRefreshDisplay()
	usr.IsLearning = 0

mob/proc/SkillWindowOpen()
	winshow(usr, "SkillTreeWindow",0)
	winshow(usr, "SkillsListWindow",1)
	WhichSkillWindow=2
	updateWindow = 0
	usr.IsLearning = 0

mob/proc/TreeWindowClose()
	omegastun = 0 //keeps users from doing shit when they're fighting.
	GetTreeMode = 0
	CurrentTree = null
	WhichSkillWindow = 0
	IsLearning = 0
	LearnSkillMode = 0
	inAwindow = 0
	updateWindow = 0
	SkillTreeContentsList -= SkillTreeContentsList
	SkillTreeContentsList = new/list()
	winshow(usr, "SkillsListWindow",0)
	winshow(usr, "SkillTreeWindow",0)
	contents -= /obj/treewindow


/mob/default/verb/Learn_Skill()
	set category = "Learning"
	if(inAwindow==1) return
	inAwindow=1
	TreeWindowOpen()

mob/proc/testunlocks()
	treerot()
	for(var/datum/skill/tree/T in possessed_trees)
		T.growbranches()
		T.prunebranches()

/datum/skill/tree/proc/attemptrefund(var/forced)
	if(forced && can_refund)
		for(var/datum/skill/S in investedskills)
			refund(S)
	else if(can_refund)
		var/list/remove=new/list
		remove.Add("Yes")
		remove.Add("No")
		var/Choice=input("Really refund this tree?") in remove
		if(Choice=="Yes")
			var/mob/M=src.savant
			demod()
			M.testunlocks()
		else return
/datum/skill/tree/proc/showcase_forgetable(var/datum/skill/S)
	if(!S) return FALSE
	switch(S.can_forget)
		if(TRUE)
			return "Is forgetable!"
		if(FALSE)
			return "Cannot be forgotten!"

/datum/skill/tree/proc/attemptlearn(var/datum/skill/S)
	var/list/Selection=new/list
	if(savant.skillpoints >= S.skillcost) Selection.Add("Learn this Skill")
	//world << "[S], [savant], [S.skillcost]"
	if(savant.skillpoints < S.skillcost) Selection.Add("You don't have enough skill points.")
	Selection.Add("Cancel")
	var/Choice=input("[S.name] costs [S.skillcost] point(s).\nYou have [savant.skillpoints] point(s) remaining.\n [showcase_forgetable(S)] \n[S.desc]") in Selection
	if(Choice=="Learn this Skill")
		//world << "Learned?"
		fund(S)
		//world << "Learned."
		treegrow()
		//world << "Learned..."
		return
	if(Choice=="Cancel"|| Choice == "You don't have enough skill points.") return

/datum/skill/tree/proc/attemptforget(var/datum/skill/S)
	var/list/Selection=new/list
	Selection.Add("Forget this Skill")
	Selection.Add("Cancel")
	var/Choice=input("[S.name] costed [S.skillcost] point(s).\nYou have [savant.skillpoints] point(s).\n[S.desc]") in Selection
	if(Choice=="Forget this Skill")
		refund(S)
		return
	if(Choice=="Cancel")
		return
