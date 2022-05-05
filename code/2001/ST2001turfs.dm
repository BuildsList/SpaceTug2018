var/list/doorDirs = list(0, 180, -90, 90, -45, 45, -135, 135)
var/cardinalDirs = list(1, 2, 4, 8)
var/currentAir


proc/BlowAirlock(mob/M)
	if(CheckGhostOrBrute(M)) return
	for(var/turf/door/D in world)
		if(D.z == M.z && D.AdjacentToSpace())
			D.Toggle()


proc/AbortSelfDestruct()
	if(locks["selfdestruct"] == 1 && !locks["destructwait"])
		SayPA("Бортовой Компьютер", "Самоуничтожение отменено.")
		locks["selfdestruct"] = 0
		locks["lastabort"] = world.time


proc/SelfDestruct()
	var/incept = world.time

	if(locks["selfdestruct"])
		to_chat(world,"Самоуничтожение уже приведено в действие.")
		return
	else
		locks["selfdestruct"] = 1

	for(var/mob/M in world)
		M.HearSound('reactor_2min_lhr.wav')
	SayPA("Бортовой Компьютер", "Самоуничтожение запущено.")
	sleep(600)

	if(locks["lastabort"] > incept) return
	for(var/mob/M in world)
		M.HearSound('reactor_1min_lhr.wav')
	sleep(300)

	if(locks["lastabort"] > incept) return
	for(var/mob/M in world)
		M.HearSound('reactor_30sec_lhr.wav')
	sleep(250)

	if(locks["lastabort"] > incept) return
	SayPA("Бортовой Компьютер", "Пять.")
	sleep(10)

	if(locks["lastabort"] > incept) return
	SayPA("Бортовой Компьютер", "Четыре.")
	sleep(10)

	if(locks["lastabort"] > incept) return
	SayPA("Бортовой Компьютер", "Три.")
	sleep(10)

	if(locks["lastabort"] > incept) return
	SayPA("Бортовой Компьютер", "Два.")
	sleep(10)

	if(locks["lastabort"] > incept) return
	SayPA("Бортовой Компьютер", "Один.")
	sleep(10)

	if(locks["lastabort"] > incept) return
	locks["destructwait"] = 1
	for(var/area/A in world)
		if(A.type == /area/space) continue
		if(A.type == /area/room/shuttle2 && locks["shuttlelaunched"]) continue
		for(var/mob/M in A)
			M.Damage(999,0)
		for(var/obj/O in A)
			del O
		for(var/turf/T in A)
			T.underlays.len = 0
			T.overlays.len = 0
			T.icon = null
			flick('explode.dmi', T)
		sleep(1)

	locks["destructwait"] = 0
	locks["selfdestruct"] = 2
	checkVictory = 1


obj
	atmosphere
		suckable = 0
		icon = 'atmosphere.dmi'


		New()
			. = ..()
			name = icon_state


obj/helper/hole
	icon = 'acid.dmi'
	icon_state = "hole"
	suckable = 0

	New()
		layer = OBJ_LAYER - 0.1
		spawn flick("burning", src)

/turf/proc/check_turf_density()
	if(density)
		return 1
	return 0


turf
	layer = 1

	var/splatterable = 1

	start_area
		icon = 'STlogo.dmi'

	proc/GetLaunchedStuff(turf/T)
		var/K
		for(K in T)
			if(ismob(K) || isobj(K))
				K:loc = src

	proc/StartAcid(myGeneration)
		new /obj/helper/hole(src)

		if(prob(100 - myGeneration * 45)) //0 = 100; 1 = 55; 2 = 10; 3+ = 0
			sleep(ACID_DELAY)
			SayPA("Бортовой Компьютер", "ВНИМАНИЕ. Обнаружены структурные повреждения в [localize(loc.name)].")

			if(AdjacentToVacuum()) PunchHole()
			else
				var/turf/T = locate(x, y, z - 1)
				if(T)
					if(istype(T, /turf/space))
						PunchHole()
					else spawn T.StartAcid(myGeneration + 1)


	proc/Get4AdjacentTurfs()
		var
			adjs[0]
			turf/T
			K

		for(K in cardinalDirs)
			T = get_step(src, K)
			if(T) adjs += T
		return adjs


	proc/Get6AdjacentTurfs()
		var
			adjs[0]

		adjs = Get4AdjacentTurfs()

		//fixme: check above & below turfs, to be safe.
		if(istype(src, /turf/floor/ladder))
			if(icon_state == "up" || icon_state == "updown")
				adjs += locate(x, y, z + 1)

			if(icon_state == "down" || icon_state == "updown")
				adjs += locate(x, y, z - 1)

		return adjs


	proc/AdjacentToSpace()
		var/turf/T
		for(T in Get4AdjacentTurfs())
			if(istype(T, /turf/space)) return T


	proc/AdjacentToVacuum()
		var/turf/T
		T = AdjacentToSpace()
		if(T) return T
		else
			for(T in Get4AdjacentTurfs())
				if(T.vacuumSource) return T


	space
		icon = 'space.dmi'
		splatterable = 0

		New()
			//Make it look all starry and stuff.
			if(prob(SPACE_DETAIL_PROB)) icon_state = num2text(rand(1, 4))

	wall
		density = 1
		opacity = 1


		New()
			. = ..()
			if(name == "wall") name = loc:name


		dark_wall
			name = "wall"
			icon = 'dark_wall.dmi'

		hull
			icon = 'hull.dmi'
			icon_state = "Hrivets"

		white_wall
			name = "wall"
			icon = 'wall.dmi'

		beige_wall
			name = "wall"
			icon = 'wall2.dmi'

		pipe_wall
			name = "wall"
			icon = 'wall3.dmi'

		bridge_wall
			name = "wall"
			icon = 'wall4.dmi'

		sophie_wall
			name = "wall"
			icon = 'wall5.dmi'

		shaft_wall
			name = "wall"
			icon = 'wall6.dmi'

		chapel_wall
			name = "wall"
			icon = 'wall7.dmi'

		rust_wall
			name = "wall"
			icon = 'wall8.dmi'

		window
			icon = 'window.dmi'
			opacity = 0

	floor
		icon = 'floor.dmi'
		splatterable = 1


		New()
			. = ..()
			if(name == "floor") name = loc:name
			if(loc:type == /area/space) spawn world << "Bad floor: [x] [y] [z]"
			currentAir++

		table
			icon = 'obstacle.dmi'
			density = 1
			splatterable = 0

		ladder
			icon = 'ladder.dmi'
			splatterable = 0

			//alien shit
			alienAct(var/mob/M)
				act(M)

			//so the ghost would descend and climb quickly
			ghostAct(var/mob/M)
				if(icon_state == "up" || icon_state == "updown")
					M.Move(locate(x, y, z + 1))
					return

				else if(icon_state == "down")
					M.Move(locate(x, y, z - 1))
					return

			//human shit
			act(var/mob/M)
				if(icon_state == "up" || icon_state == "updown")
					climb(M)
					return

				else if(icon_state == "down")
					descend(M)
					return

			proc/climb(var/mob/M)
				msg("[localize(M.name)] <B>ползет по лестнице вверх.</B>")

				sleep(CLIMB_SLEEP)
				M.Move(locate(x, y, z + 1))


			proc/descend(var/mob/M)
				msg("[localize(M.name)] <B>спускается по лестнице.</B>")

				sleep(DESCEND_SLEEP)
				M.Move(locate(x, y, z - 1))


			New()
				. = ..()


	door
		var
			open
			locked
		icon_state = "closed"
		density = 1
		opacity = 1
		splatterable = 0
		var/broken = 0


		proc/Break()
			OverlayManager.AddOverlay(src, 'flasher.dmi', "small")
			broken = 1


		New()
			. = ..()
			if(loc:type == /area/space) spawn world << "Bad door: [x] [y] [z]"

			spawn
				if(AdjacentToSpace()) Close()
				else
					var/obj/helper/doorCloser/D
					for(D in src)
						del D
						return
					//And if a door closer wasn't found, open the door
					Open()


		act(var/mob/M)
			if(CheckGhostOrBrute(M) || !M.canAct) return

			if(broken)
				if(M.find_content("screwdriver"))
					msg("[localize(M.name)] <B>ПОЧИНИЛ</B> [localize(name)]!")
					broken = 0
					return

			M.delay_act(7)
			var/foundDoor = 0
			var/D
			for(D in range(M, 1))
				if(istype(D, /turf/door))
					foundDoor = 1
					break

			if(foundDoor) Toggle()
			else . = ..()


		proc/Lock()
			locked = 1


		proc/Toggle()
			if(CheckGhostOrBrute(usr)) return

			if(!open) Open()
			else Close()

		proc/Open()
			if(!open && !locked)
				icon_state = "open"
				flick("opening", src)
				open = 1
				playsound('door1.wav')
				spawn(DOOR_EFFECT_DELAY)
					if(open)
						density = 0
						opacity = 0
						SetVacuumSource(AdjacentToVacuum(), src)
						if(AdjacentToSpace())
							SayPA("Бортовой Компьютер", "ВНИМАНИЕ. Шлюз в космос, в [localize(loc.name)], был открыт [localize(usr.name)].")

		proc/Close()
			if(open)
				if(broken)
					to_chat(usr,"Дверь не работает.")
					return

				icon_state = "closed"
				flick("closing", src)
				open = 0
				playsound('door1.wav')

				var/mob/M
				for(M in src)
					M.Damage(1,1)
					spawn Open()
					return

				spawn(DOOR_EFFECT_DELAY)
					if(!open)
						density = 1
						opacity = initial(opacity)
						SetVacuumSource(null)


		spiral_door
			name = "ventilation system access"
			icon = 'spiralDoor.dmi'

		beige_door
			name = "door"
			icon = 'door3.dmi'
			opacity = 0

		purina_door
			name = "door"
			icon = 'door2.dmi'

		blue_door
			name = "door"
			icon = 'door4.dmi'

var/list/LIGHTS = list()

obj
	var/suckable = 0

	intercom
		icon = 'intercom.dmi'
		icon_state = "on"
		layer = TURF_LAYER + 0.1


		act(var/mob/M)
			if(CheckGhostOrBrute(M)) return
			if(src in range(M, 1))
				if(icon_state == "on") icon_state = "off"
				else icon_state = "on"


	fluorescent_light
		icon = 'fluorescent.dmi'
		icon_state = "off"
		var/on
		layer = TURF_LAYER + 12

		New()
			..()
			LIGHTS += src

		proc/TurnOn()
			if(on) return
			on = 1
			var/turf/T = loc
			T.calculate_lum(7)

			sleep(FLUO_INITIAL_DELAY)

			while(on && icon_state != "on")
				switch(icon_state)
					if("off")
						icon_state = pick(
							prob(100)
								"dim",
							prob(200)
								"off",
							prob(100)
								"on")
					if("dim")
						icon_state = pick(
							prob(200)
								"off",
							prob(100)
								"dim")

				switch(icon_state)
					if("off")
						T.clear_lum(7)
					if("dim")
						T.clear_lum(7)
						T.calculate_lum(5)
					if("on")
						T.clear_lum(7)
						T.calculate_lum(7)
						return

				sleep(FLUO_FLICKER_DELAY)


		proc/TurnOff()
			on = 0
			icon_state = "off"
