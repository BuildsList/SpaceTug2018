area
	var/realm = "none"
		//This var is used to aid in the end-of-game victory detection.

	var/backgroundSound = 'bkgrndGeneral.wav'



	Entered(mob/M)
		if(istype(M) && !CheckGhost(M) && !istype(M,/mob/cat/))
			for(var/obj/fluorescent_light/F in src)
				if(F.on)
					continue

				spawn F.TurnOn()


	Exited(mob/M)
		//If mob leaves area and there are no other mobs remaining in area, turn off
		//fluorescents.
		if(istype(M) && !CheckGhost(M) && !istype(M,/mob/cat/))
			var/found_other = 0
			for(var/mob/MM in src)
				if(M != MM) //fixme: check that MM isn't a ghost
					found_other = 1
					break

			if(!found_other)
				for(var/obj/fluorescent_light/F in src)
					if(!F.on)
						continue

					F.TurnOff()


	Dream_world
		Enter(mob/M)
			//An object can't drift in from space, but can enter at game start.
			if(istype(M.loc, /turf/space) || M.icon == 'ghost.dmi') return 0
			else return 1


		Entered(mob/player/M)
			. = ..()
			if(istype(M))
				to_chat(M,"<B><font color='red'>SPACE TUG</font>. Создатели - Gughunter, Gazoot. Перевод и адаптация - Difilex.")
				var/welcomeTxt = "<b>Ты - член экипажа космического буксира <i>Монстромо.</i><p>\
				Как только ты напишешь 'Start', или же нажмешь на соответствующую кнопку - ты присоединишься к быстро развивающемуся космическому кризису.\
				<p>Каким-то непонятным образом на корабль попала неизвестная форма жизни. Она убьет тебя и весь остальной экипаж, если ее не остановить.<p>"

				to_chat(M,welcomeTxt)


		Exited(mob/player/M)
			//Alternative to typing 'start': just walk out of the area.
			. = ..()
			usr = M; Start()

		verb/Start()
			set category = "Lobby"

			if(!generated)
				return to_chat(src,"<font color='red'><B>Мир еще не готов к твоему присутствию.</font>")

			var/mob/critter/C
			var/playableCritters

			usr.loc = null
			sleep(10)

			for(C in world)
				if(!C.client)
					playableCritters = 1 && PLAY_AS_CRITTER
					break

			if(playableCritters)
				switch(input(usr,"Be THE ALIEN?") in list("YES","NO"))
					if("YES")
						for(C in world)
							if(!C.key)
								to_chat(usr,"Роль - ПРИШЕЛЕЦ.")
								C.key = usr.key
								return

						to_chat(usr,"Ошибочка. --Роль антагониста занята.")

					if("NO")
						to_chat(usr,"Ок.")

			var/new_role = usr.pick_role()

			var/datum/role/new_ROLE = new
			new_ROLE.title = new_role
			for(var/datum/role/R in PLAYABLE_ROLES)
				if(new_ROLE.title == R.title)
					new_ROLE.name = R.name

			usr.my_role = new_ROLE
			to_chat(usr,"Роль - ЧЕЛОВЕК ([usr.my_role.name]).")
			usr.buff_by_role()

			if(PutInPlace(usr, PLAYER_START_AREA))

				for(var/mob/M in world)
					M.HearSound('newplayer.wav')
					to_chat(M,"<B>[usr] ([usr.my_role.name]) пробудился от криосна.</B>")

				spawn(41) usr << sound(MAIN_THEME, 1)
					//Background music: Moonlight Sonata (Beethoven)

	space

	room
		realm = "ship"

		airlock
			New()
				. = ..()
					//AlterPropriety prevents the computer from making embarrassing
					//blunders like "...in the airlock 2a."

			airlock_2a
			airlock_3a
			airlock_4a

		Aunt_Sophie
		bridge
		chapel
		garage
		generator_room
		infirmary

		Mess
			New()
				. = ..()

		maintenance_access
			New()
				. = ..()

			maintenance_access_2a
			maintenance_access_2b
			maintenance_access_2c

			maintenance_access_3a
			maintenance_access_3b
			maintenance_access_3c

			maintenance_access_4a
			maintenance_access_4b
			maintenance_access_4c

		observation_pod
		power_plant
		ramp

		shuttle
			proc/Launch()
				if(locks["shuttlelaunched"])
					usr << "Ошибка."
					return
				else locks["shuttlelaunched"] = 1

				for(var/turf/door/D in contents)
					if(D.open)
						D.Close()
						D.Lock()
						//fixme: In theory, one or both of these calls could fail, I think.

				spawn(DOOR_EFFECT_DELAY + 1)
					SayPA("Бортовой Компьютер", "[localize(usr.name)] запустил процесс эвакуации.")

				var/turf/SB = locate("shuttleBase")
				var/turf/FSB = locate("fakeShuttleBase")

				var/turf/companion
				for(var/turf/T in src)
					companion = locate(T.x + FSB.x - SB.x, T.y + FSB.y - SB.y, T.z + FSB.z - SB.z)
					companion.GetLaunchedStuff(T)

		shuttle2
			name = "shuttle"
			realm = "shuttle"

		sleep_chamber

		storage
			New()
				. = ..()

			storage_2a
			storage_2b
			storage_2c

			storage_3a
			storage_3b
			storage_3c

			storage_4a
			storage_4b
			storage_4c

		theater
		turbine_room

		unnamed
			unnamed_2a
			unnamed_2b
			unnamed_2c
			unnamed_2d

			unnamed_3a
			unnamed_3b
			unnamed_3c
			unnamed_3d

			unnamed_4a
			unnamed_4b
			unnamed_4c
			unnamed_4d

	corridor
		realm = "ship"

		New()
			. = ..()

		corridor_1a
		corridor_2a
		corridor_2b
		corridor_2c
		corridor_2d
		corridor_2e
		corridor_2f
		corridor_2g
		corridor_2h

		corridor_3a
		corridor_3b
		corridor_3c
		corridor_3d
		corridor_3e
		corridor_3f
		corridor_3g
		corridor_3h

		corridor_4a
		corridor_4b
		corridor_4c
		corridor_4d
		corridor_4e
		corridor_4f
		corridor_4g
		corridor_4h

	junction
		realm = "ship"

		New()
			. = ..()

		junction_2a
		junction_2b
		junction_2c
		junction_2d

		junction_3a
		junction_3b
		junction_3c
		junction_3d

		junction_4a
		junction_4b
		junction_4c
		junction_4d

	ventilation_shaft
		realm = "ship"

		New()
			. = ..()



		Entered(mob/player/M)
			. = ..()
			if(istype(M) && !CheckGhost(M) && M.icon != 'h_cadet.dmi' && M.icon != 'h_assistant.dmi')
				M.moveDelay = initial(M.moveDelay) + VENTSHAFT_SLOWDOWN_TICKS


		Exited(mob/player/M)
			. = ..()
			//Note: if, in the future, other things can affect the player's movement speed
			//(e.g., wounded legs), this code and the code in Entered() will be inadequate.
			//Leaving the ventilation shaft would heal the player's legs!
			if(istype(M))
				if(M.icon != 'h_cadet.dmi' && M.icon != 'h_assistant.dmi')
					M.moveDelay = initial(M.moveDelay)


		climate_control
		ventilation_shaft_2a
		ventilation_shaft_2b
		ventilation_shaft_2c
		ventilation_shaft_2d

		ventilation_shaft_3a
		ventilation_shaft_3b
		ventilation_shaft_3c
		ventilation_shaft_3d

		ventilation_shaft_4a
		ventilation_shaft_4b
		ventilation_shaft_4c
		ventilation_shaft_4d
