var/list/flameDirs = list(-45, -90, -135, 45, 90, 135, 180)
	//This list differs from mob's wander dirs list because it's nice to have the flame spread
	//out in multiple directions... using the other list, it will often go in only the easiest
	//direction.

obj/portable
	icon = 'items.dmi'
	layer = 2
	suckable = 1


	act(var/mob/M)
		if(CheckGhostOrBrute(M)) return

		if(M.calculate_n_contents() >= 5)
			return to_chat(M,"В моем инвентаре больше нет места на подобные глупости!")

		Move(usr)

	verb/Drop()
		set category = "IC"
		set src in usr
		//Put the object in whatever nearby turf can hold it. Since range() returns turfs
		//closest first, this will usually be the turf the player is standing in.
		if(CheckGhostOrBrute(usr)) return
		var/turf/T
		for(T in range(usr, 1))
			if(Move(T, usr.dir)) return


	flamethrower
		icon_state = "flamethrower"
		density = 0
		opacity = 0
		var/on = 0
		var/fuel = FLAMETHROWER_FUEL
		var/fuelSputter
		var/sound = 'flamethrower.wav'

		New()
			. = ..()
			//Calculate the fuel threshold where the flamethrower will start to have less
			//than a 100% chance of firing (i.e., start to sputter).
			fuelSputter = fuel * FLAMETHROWER_SPUTTER_PERCENT / 100
			spawn Maintain()


		proc/Maintain()
			var/turf/realLoc
			while(src)
				//Flamethrower in mob contents list will turn to face the mob's direction.
				if(ismob(loc))
					realLoc = loc:loc
					dir = loc:dir
				else realLoc = loc

				if(on)
					if(fuel > 0)
						if(prob(100 * fuel / fuelSputter))
							new /obj/flame(realLoc, dir, loc)
							--fuel
					else
						if(ismob(loc))
							loc << "Out of fuel."
						extinguish()

				sleep(FLAMETHROWER_SLEEP)


		verb/flame()
			set src in view(1)
			if(CheckGhostOrBrute(usr)) return
			on = 1


		verb/extinguish()
			set src in view(1)
			if(CheckGhostOrBrute(usr)) return
			on = 0

	prod
		name = "cattle prod"
		icon_state = "cattle_prod"

	walkie_talkie
		name = "walkie-talkie"
		icon_state = "walkie_talkie"

	fuel
		name = "fuel charge"
		icon_state = "fuel"

	screwdriver
		name = "screwdriver"
		icon_state = "screwdriver"

	medkit
		name = "medkit"
		icon_state = "medkit"

obj

	flame
		icon = 'flame.dmi'
		var/distance = FLAME_RANGE
		var/mob/originator
		var/ID


		New(myLoc, myDir, myOrig)
			. = ..()
			originator = myOrig
			dir = myDir
			invisibility = 1
			ID = GetID()
			spawn Maintain()


		proc/Maintain()
			var/turf/T
			var/mob/M
			var/oldLoc

			oldLoc = loc
			while(distance--)
				density = 1 //As with the cat, make temporarily dense so walls can block it.
				T = get_step(loc, dir)
				if(!T || !Move(T)) //Note: very similar to Wander... merge someday?
					var/modifier = rand(0, 1) * 2 - 1
					var/oldDir = dir
					var/K
					for(K in flameDirs)
						dir = turn(oldDir, K * modifier)
						T = get_step(src, dir)
						if(T) if(Move(T)) break
				density = 0

				invisibility = 0
				for(M in loc)
					DealDamage(M)
					if(ismob(M)) distance = 0 //Flame dies when it hits a mob
				if(oldLoc == loc) break //Flame dies if it wasn't able to move

				sleep(FLAMETHROWER_SLEEP)
			del src


		Bump(mob/M)
			DealDamage(M)
			if(isturf(M))
				var/turf/T = M
				if(T.splatterable)
					OverlayManager.AddRandomOverlay(T, 'soot.dmi')


		proc/DealDamage(mob/M)
			if(istype(M))
				if(prob(FLAME_DAMAGE_PROB))
					M.Damage(1,1)
