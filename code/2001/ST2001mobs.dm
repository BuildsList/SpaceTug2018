
var/list/turnDirs = list(-45, 45, -90, 90, -135, 135, 180)
var/checkVictory = 0

/mob/verb/OOC(ooc as text)
	set category = "OOC"
	to_chat(world,"<font color='blue'><B>[key](OOC): [ooc]</B>")
	world.log << "<font color='blue'><B>[key](OOC): [ooc]</B>"

client
	New()
		. = ..()
		lazy_eye = LAZY_EYE


	Del()
		to_chat(world,"[localize(mob.name)] перенервничал и потерял сознание!")
		checkVictory = 1
		. = ..()


	Move(myLoc)
		if(mob.bound) return

		//Restrict the player's movement speed--will not affect NPC's,
		//nor external movement of the player's mob (via vacuum, conveyor belt, whatever)
		if(mob.lastMove + mob.moveDelay <= world.time)
			. = ..()
			if(.)
				mob.lastMove = world.time

/atom/Click(location,control,params,var/mob/M = usr)
	if(istype(M,/mob/cat/))
		return

	params = params2list(params)

	if("shift" in params)
		examine(M)
		return

	if("left" in params)
		if(src in range(1,M))
			if(!M.canAct) return

			if(CheckGhostOrBrute(M))
				ghostAct(M)
				return

			if(CheckNotSentient(M))
				alienAct(M)
				return

			else
				act(M)
				return

/atom/proc/act(var/mob/M)
	return

/atom/proc/alienAct(var/mob/M)
	return

/atom/proc/ghostAct(var/mob/M)

/atom/proc/Bumped(var/mob/M)
	return

/mob/Bump(var/atom/A)
	A.Bumped(src)

/mob/Bumped(var/mob/attacker)
	if(istype(src,/mob/cat/) || istype(attacker,/mob/cat/))
		return

	step(src,attacker.dir)

	var/mob/critter/Allen/CRITTER = attacker
	if(istype(CRITTER))
		CRITTER.Attack(src)
		return

mob
	layer = 3
	var
		acidBlood = 0
		moveDelay = HUMAN_MOVE
		lastMove = -999999
		splatIcon
		health = 3
		maxHealth = 3
		bound = 0
		suckable = 1
		maxPressure = DEFAULT_PRESSURE
		pressure = 0

		curSound
		curSoundPriority
		curSoundEnd
		DIRECTION = "v"

	act(var/mob/M)
		if(M.find_content("medkit"))
			if(health < maxHealth)
				health = maxHealth
				msg("[localize(M.name)] <B>[pick("лечит","мазюкает","обмазывает","тыкает")]</B> [localize(name)] аптечкой! ([health]/[maxHealth])")
				return
			else
				return to_chat(M,"[localize(name)] ВООБЩЕ не нуждается в лечении.")

	verb/Who()
		set category = "OOC"
		for(var/mob/M in world)
			if(M.client) usr << M

	proc/PlayBackground()
		if(curSoundEnd < world.time)
			curSoundPriority = 0
			if(isturf(loc))
				src << sound(loc:loc:backgroundSound, 1)

	Move()
		. = ..()
		switch(dir)
			if(SOUTH)
				DIRECTION = "v"

			if(NORTH)
				DIRECTION = "^"

			if(EAST)
				DIRECTION = ">"

			if(WEST)
				DIRECTION = "<"

	/*	for(var/obj/portable/motion_tracker/myMT in range(12,src))
			myMT.RegisterMove(src)  */


	New()
		. = ..()
		if(splatIcon && OverlayManager)
			OverlayManager.RegisterIcon(splatIcon, list("1", "2", "3", "4"), \
				TURF_LAYER + 0.5) //same layer as soot


	Stat()
		if(statpanel("Status"))
			stat(null,"CPU: [world.cpu]")
			stat(null,"Health: [health]/[maxHealth]")
			stat(null,"Direction: [DIRECTION]")

		if(statpanel("Carrying"))
			stat(contents)


	verb/Talk(T as text)
		set category = "IC"
		Say(usr, T)

	proc/Wander()
		var/turf/T = get_step(src, dir)
		if(!T || !Move(T) || prob(CHANGE_DIR_PROB))
			var/modifier = rand(0, 1) * 2 - 1
				//I.e., -1 or 1; this is so left or right turns will
				//get preference randomly.
			var/oldDir = dir
			for(var/K in turnDirs)
				//Try mild turns first, then sharper ones.
				dir = turn(oldDir, K * modifier)
				T = get_step(src, dir)
				if(T) if(Move(T)) break


	proc/Die()
		icon_state = "corpse"
		density = 0
		checkVictory = 1

//		if(client) --This line was causing the "bloody head" bug!
		var/mob/player/G = new(src.loc)
		G.icon = 'ghost.dmi'
		G.suckable = 0
		G.density = 0
		G.invisibility = 1
		G.sight |= SEEINVIS
		G.name = "[src]'s ghost"
		G.key = src.key


	proc/Damage(myAmount,doSplat)
		if(health <= 0) return
		if(CheckGhost(src)) return

		if(doSplat) Splatter(myAmount)

		health -= myAmount

		if(health <= 0)
			health = 0
			Die() //Die() will save the description for end-of-game recap.


	proc/Splatter(myAmount)
		//Try to splatter myAmount turfs with blood, acid, whatever.
		//If fewer splatterable turfs are available,
		//all splatterable turfs will get one splat; otherwise choice is random.
		if(splatIcon)
			var/list/L = list()
			var/splatAmount = myAmount

			for(var/turf/T in orange(1,src))
				if(T.splatterable)
					L += T

			var/n = 0
			for(var/turf/T in L)
				n++

			if(n > 0)
				while(splatAmount > 0)
					var/obj/cleanable/blood/B = new(pick(L))
					B.set_sprite(splatIcon,"[rand(1,4)]")
					splatAmount--

	proc/Think()
		while(src && health > 0)
			if(!client)
				Wander()
			sleep(moveDelay)


	player
		splatIcon = 'humanSplat.dmi'
		icon = 'h_cadet.dmi'


		Login()
			//If loc is already set, the player probably disconnected and came back.
			if(CheckGhost(src)) return
			if(!loc)
				var/area/Dream_world/D = locate()
				for(var/turf/T in D)
					if(Move(T)) return
			else src << sound(MAIN_THEME, 1)


	critter
		var/sentient = 0
		splatIcon = 'critterSplat.dmi'


		New()
			. = ..()
			spawn Think()


		Allen //You can call him Al.
			icon = 'critter.dmi'
			name = "critter"
			var/minBump
			var/joltEndTime
			acidBlood = 1
			maxHealth = 6
			health = 6
			maxPressure = DEFAULT_PRESSURE * 1.5

			proc/Attack(mob/M)
				if(!canAct) return
				if(M.type == src.type) return

				for(var/obj/O in M.contents)
					if(istype(O,/obj/portable/prod/))
						if(prob(PROD_EFFECTIVENESS))
							dir = turn(dir, 180)
							joltEndTime = world.time + 30
							msg("<font color='red'><B>[localize(M.name)] бьет [localize(name)] током!</font>")
							playsound('zap.wav')
							return

						if(world.time >= joltEndTime)
							break

				delay_act(7)
				flick("attack", src)

				playsound('critter1.wav')

				M.Damage(rand(2,4),1)


			Think()
				var/mob/player/target
				while(src && health > 0)
					if(!client)
						if(target)
							if(istype(target, /turf/floor/ladder) || target.health > 0)
								dir = get_dir(src, target)
							else target = null
						else
							if(world.time >= joltEndTime)
								target = locate() in view(src, 5)
								if(target && IsRoughlyFacing(src, target, 90))
									if((target.health <= 0) || CheckGhost(target)) target = null
									else target << sound('tense1.mid', 1)
							//The critter AI is really poor, and badly written too--but
							//luckily, most of the time a player is happy to step into
							//the critter's shoes.
							//fixme: look for ladder here
							//fixme: handle "flee"
							//fixme: handle music better--a simple flag would do

						Wander()

					else
						if(!target)
							target = locate() in view(src, 5)
							if(target)
								if((target.health <= 0) || CheckGhost(target)) target = null
								else target << sound('tense1.mid', 1)
						else
							if(target.health <= 0) target = null

					sleep(moveDelay)


			Bump(mob/M)
				if(istype(M))
					if(world.time >= joltEndTime)
						Attack(M)
						return

				else
					if(istype(M, /turf/door))
						var/turf/door/T = M
						if(minBump <= world.time)
							minBump = world.time + \
								rand(ALIEN_BUMP_DOOR_WAIT / 2, ALIEN_BUMP_DOOR_WAIT)
							playsound('hitdoor.wav')
							if(prob(ALIEN_OPEN_DOOR_PROB))
								T.Open()

								SayPA("Бортовой Компьютер", "ВНИМАНИЕ. Сбой двери в [localize(T.loc.name)].")

								if(prob(ALIEN_BREAK_DOOR_PROB))
									T.Break()


	cat
		splatIcon = 'humanSplat.dmi'
		density = 0
		icon = 'cat.dmi'
		health = 2
		maxPressure = 50
		moveDelay = HUMAN_MOVE+3


		Move()
			//Allow cat to be blocked by walls, etc. without getting in players' way.
			density = 1
			. = ..()
			density = 0


		act(var/mob/M)
			//Allow players to rescue cat
			if(CheckGhost(M)) return
			if(M in range(src, 1))
				src.Move(M)
				return

		New()
			. = ..()
			spawn Think()


		Think()
			//Don't move if picked up by player!
			while(src && health > 0)
				if(ismob(loc)) return
				//This code is copied from parent class Think(), because calling ..()
				//will sleep within *that* proc and never check for location in player contents!
				Wander()
				sleep(moveDelay)


		Die()
			Say(src, "РРРРЯУ!")
			. = ..()
