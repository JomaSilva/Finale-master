proc/Sub_Type(var/a)
	if(!ispath(a))
		return
	var/list/n = list()
	n+=typesof(a)
	return n.len-1