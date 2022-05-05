
var/list/PLAYABLE_ROLES = list()
var/list/role_list = list()

proc/init_subtypes(prototype, list/L, var/names = 0)
	if(!istype(L))
		L = list()

	for(var/path in typesof(prototype))
		if(path == prototype)
			continue
		var/datum/D = new path()
		if(names)
			L[D.title] = D
		else
			L += D

	return L

proc/init_roles()
	init_subtypes(/datum/role, role_list, 1)
	PLAYABLE_ROLES += new/datum/role/captain
	PLAYABLE_ROLES += new/datum/role/security
	PLAYABLE_ROLES += new/datum/role/doctor
	PLAYABLE_ROLES += new/datum/role/engineer
	PLAYABLE_ROLES += new/datum/role/mechanic
	PLAYABLE_ROLES += new/datum/role/cadet
	PLAYABLE_ROLES += new/datum/role/assistant

	var/n = 0
	for(var/datum/role/R in PLAYABLE_ROLES)
		n++

	to_chat(world,"<font color='red'><small>Прогрузили <B>[n]</B> ролей.</font>")

/mob
	var/datum/role/my_role = null

	proc
		check_role(var/title)
			if(!my_role) return

			if(my_role.title == title)
				return 1

			return 0

		pick_role()
			var/pick = input(usr,"Choose your role") in role_list
			if(pick)
				return pick

		buff_by_role()
			if(!my_role) return

			switch(my_role.name)
				if("Кадет")
					icon = 'h_cadet.dmi'
					moveDelay = HUMAN_MOVE-1
					usr.maxHealth = 2
					usr.health = 2
					contents += new/obj/portable/food/choco_cube
					return

				if("Ассистент")
					icon = 'h_assistant.dmi'
					moveDelay = HUMAN_MOVE-1
					usr.maxHealth = 2
					usr.health = 2
					return

				if("Капитан")
					icon = 'h_captain.dmi'
					return

				if("Офицер")
					icon = pick('h_security.dmi','h_security2.dmi')

					usr.maxHealth = 4
					usr.health = 4
					contents += new/obj/portable/prod
					return

				if("Научный Сотрудник")
					icon = 'h_doctor.dmi'
					contents += new/obj/portable/medkit
					return

				if("Механик")
					icon = 'h_mechanic.dmi'
					contents += new/obj/portable/screwdriver
					return

				if("Главный Инженер")
					icon = 'h_engineer.dmi'
					return

/datum
	var/title

/datum/role
	var/name

	captain
		name = "Капитан"
		title = "Captain"

	security
		name = "Офицер"
		title = "Security Officer"

	doctor
		name = "Научный Сотрудник"
		title = "Scientist"

	engineer
		name = "Главный Инженер"
		title = "Chief Engineer"

	mechanic
		name = "Механик"
		title = "Mechanic"

	cadet
		name = "Кадет"
		title = "Cadet"

	assistant
		name = "Ассистент"
		title = "Assistant"