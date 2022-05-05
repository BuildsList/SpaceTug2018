proc/GetID()
	var/static/ID = 0
	return ID++


proc/GetOnOffText(x)
	if(x) return "ON"
	else return "OFF"


proc/IsNearComms(mob/M)
	//fixme: doesn't handle radios in mob contents!
	if(locate(/obj/portable/walkie_talkie, range(M, WALKIE_TALKIE_RANGE))) return "on radio:"
	for(var/obj/intercom/I in range(M, INTERCOM_RANGE))
		if(I.icon_state == "on") return "on intercom:"

proc/SayPA(speaker, Z)
	if(locks["selfdestruct"] == 2) return
	var/T = "<b>[speaker]: [Z]</b>"
	for(var/mob/M in world)
		to_chat(M,T)

proc/to_chat(target,message)
	var/index = findtext(message, "я")
	while(index)
		message = copytext(message,1,index) + "&#255;" + copytext(message,index+1)
		index = findtext(message, "я")
	target << message

/atom/proc/msg(message, vision_distance)
	var/tiles = VIEW
	if(vision_distance)
		tiles = vision_distance
	for(var/mob/M in view(tiles,src))
		to_chat(M,message)

proc/Say(speaker, T)
	if(!istype(speaker,/mob/))
		return

	var/mob/M

	//Everyone within a range of world.view will hear it.
	for(M in range(speaker, VIEW))
		if(istype(speaker,/mob/critter/) && !istype(M,/mob/critter/)) //если говорящий - алиен, а слышащий - нет, то будет слышать жуткости
			to_chat(M,"<B>[localize(speaker:name)]</B> [pick("шипит","булькает","угрожающе балаганит")]. [pick("Жуть, блин","Жуть какая","Страшно","Пугаюсь","Боязно очень")]!")
			continue

/*		if(!istype(speaker,/mob/critter/) && istype(M,/mob/critter/)) //если говорящий - человек, а слышащий - алиен, то ему будет злобно
			to_chat(M,"<B>[speaker]</B> [pick("глупо шевелит ртом","небрежно дергает губами","издает омерзительные звуки","уродливо визжит")]. Как же это бесит!")
			continue */

		to_chat(M,"[localize(speaker:name)] [pick("сообщает","говорит","вещает")], <B>\"[T]\"</B>")

	//Интеркомы и рации
	if(!CheckGhost(speaker))

		for(var/obj/intercom/INTERCOM in range(1,speaker))
			if(INTERCOM.icon_state == "off")
				continue

			for(var/obj/intercom/I in world)

				for(M in range(3,I))
					to_chat(M,"Голос из интеркома([localize(speaker:name)]): <B>\"[T]\"</B>")

		for(var/obj/portable/walkie_talkie/W in speaker)
			for(var/obj/portable/walkie_talkie/TALKIE in world)

				for(M in range(2,TALKIE))
					to_chat(M,"Голос из рации([localize(speaker:name)]): <B>\"[T]\"</B>")

	for(M in world)
		if(CheckGhost(M) && speaker != M)
			to_chat(M,"(GHOST EARS)[localize(speaker:name)] [pick("сообщает","говорит","вещает")], <B>\"[T]\"</B>") //ghosts hear everything

proc/CheckGhost(mob/M)
	if(!M) return
	if(M.icon == 'ghost.dmi') return 1


proc/CheckNotSentient(mob/critter/M)
	//This is to support critter types that can do things like opening doors.
	if(!M) return
	if(istype(M))
		if(!M:sentient) return 1


proc/CheckGhostOrBrute(mob/M)
	return(CheckGhost(M))


proc/PutInPlace(mob/M, myType, unusable)
	//Put M in an area of myType.
	//L could be a single type, or a list of types, because subtracting one list from
	//another actually subtracts all *elements* of the subtracted list.
	var/list/L = typesof(myType)
	if(unusable) L -= unusable

	var/R
	while(1)
		R = locate(L[rand(1, L.len)])
		if(R)
			var/turf/floor/F
			for(F in R)
				if(M.Move(F)) return 1

		sleep(1)
		//fixme: This could potentially fail, I think.


proc/IsRoughlyFacing(mob/M, mob/M2, myAngle)
	//Returns 1 if M is facing M2 or only myAngle degrees off.
	//myAngle should be a multiple of 45.
	var/G = get_dir(M, M2)
	var/curAngle
	for(curAngle = -myAngle; curAngle <= myAngle; curAngle += 45)
		if(M.dir == turn(G, curAngle)) return 1

/atom/proc/examine(var/mob/M)
	msg("[localize(M.name)] смотрит на [localize(name)].")
	var/examineTxt = "--------\nПеред тобой <B>[localize(name)]</B>."
	if(desc)
		examineTxt += "\n[desc]"

	if(istype(src,/mob/critter/) && !CheckGhost(M) && !CheckNotSentient(M))
		examineTxt += "\n<font color='red'><B>БОЖЕ КАК СТРАШНО!!!</font>"
		Say(M,pick("ООООЙЙЙЙ!","БЛЯЯЯЯ!","ААААООООООУУУ!"))

	if(istype(src,/mob/) && src:calculate_n_contents() >= 1)
		examineTxt = "С собой:"
		for(var/atom/A in contents)
			examineTxt += "\n<B>\icon[A][localize(A.name)]</B>"

	examineTxt += "\n--------"
	to_chat(M,examineTxt)
