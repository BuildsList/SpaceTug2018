/obj
	layer = 1

	sleeper
		icon = 'sleeper.dmi'
		icon_state = "sw"
		density = 1

		act(var/mob/M)
			if(M.loc != src)
				Sleep(M)
				return
			else
				Awaken(M)
				return

		proc/Sleep(var/mob/USR)

			if(CheckGhostOrBrute(USR)) return

			for(var/mob/M in src)
				if(!CheckGhost(M))
					to_chat(USR,"Занято.")
					return

			USR.loc = src
			USR.bound = 1
			USR.invisibility = 1
			USR.suckable = 0

			icon_state = "[icon_state]o" //swo or seo: occupied

//			checkVictory = 1


		proc/Awaken(var/mob/USR)

			if(CheckGhost(USR)) return

			for(var/mob/M in src)
				if(!CheckGhost(M))
					M.loc = loc
					M.bound = 0
					M.invisibility = 0
					M.suckable = 1

					switch(icon_state)
						if("swo") icon_state = "sw"
						if("seo") icon_state = "se"

	seat
		icon = 'seat.dmi'

		act(var/mob/M)

			if(!M.bound)
				buckle(M)
				return

			else
				if(M.loc == loc)
					unbuckle(M)
					return

		proc/buckle(var/mob/USR)

			if(CheckGhostOrBrute(USR)) return

			for(var/mob/M in src)
				if(!CheckGhost(M) && M != USR)
					to_chat(USR,"Занято.")
					return

			USR.loc = loc
			USR.bound = 1
			USR.suckable = 0
			msg("[localize(USR.name)] садится на [localize(name)].")


		proc/unbuckle(var/mob/USR)

			if(CheckGhost(USR)) return

			USR.bound = 0
			USR.suckable = 1
			msg("[localize(USR.name)] встает с [localize(name)].")

	table
		icon = 'obstacle.dmi'
		icon_state = "table"
		density = 1

		act(var/mob/M)
			var/n = 0
			for(var/obj/O in M.contents)
				n++

			if(n > 0)

				place_item(M)

		proc/place_item(var/mob/M)
			var/list/INVENTORY = list()
			for(var/obj/O in M.contents)
				INVENTORY += O

			var/obj/pick = input(M,"What do you want to place on [src]?") in INVENTORY
			if(pick)
				for(var/obj/A in M.contents)
					if(A.name == pick.name)
						msg("[localize(M.name)] кидает [localize(A.name)] на стол.")
						A.Move(loc)
						return

/obj/decal
	layer = TURF_LAYER + 11

	beige
		icon = 'wall2.dmi'