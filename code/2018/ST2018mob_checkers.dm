
/mob
	var
		canAct = 1
		SoundVolume = 30

/mob/proc/delay_act(var/n)
	canAct = 0
	spawn(n)
		canAct = 1

/mob/proc/calculate_n_contents()
	var/n = 0
	for(var/atom/A in contents)
		n++

	return n

/mob/proc/find_content(var/objName)
	if(!objName)
		return

	for(var/atom/A in contents)
		if(A.name == objName)
			return 1

	return 0

/mob/proc/return_content(var/objName)
	if(!objName)
		return

	for(var/atom/A in contents)
		if(A.name == objName)
			return A

	return 0