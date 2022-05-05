var/locks[0]
var/overlayManager/OverlayManager

obj/helper
	suckable = 0
	invisibility = 101

	doorCloser
		icon = 'doorCloser.dmi'

	opacityClearer
		icon = 'clearer.dmi'

		New()
			loc:opacity = 0
			del src

var/global/generated = 0

world
	view = VIEW
	fps = 30
	name = "SpaceTug"
	mob = /mob/player
	turf = /turf/space
	area = /area/space

	New()
		. = ..()
		spawn setup_world()

	proc/setup_world()
		spawn(10)
			to_chat(world,"\n<font color='red'>ЗАГРУЖАЕМ МИР:</font>")
			init_roles()
			init_passwords()
			SetUpIcons() //Register icon overlays
			Populate() //Add cats and critters
			init_luminosity()
			spawn MaintainVacuum()
			spawn WatchForVictory()
			generated = 1

	proc/WatchForVictory()
		to_chat(world,"<font color='red'><small>Бесконечный и лагающий цикл, проверяющий победу - запущен!</font>")

		while(1)
			if(checkVictory && (locks["selfdestruct"] != 1)) CheckVictory()
			sleep(11)


	proc/CheckVictory()
		if(locks["victory"]) return

		checkVictory = 0

		var/list/victors = new()

		var/critterCount = 0
		var/R
		var/V

		for(var/M as mob in world)

			if(CheckGhost(M)) continue

			var/area/A = M:loc
			if(A) A = A.loc

			if(istype(A)) R = A.realm
			else R = "none"

			V = victors[R]
			if(V == "ongoing") continue

			if(istype(M, /mob/player) && M:client)
				if(V == /mob/critter) victors[R] = "ongoing"
				else victors[R] = /mob/player
			else
				if(istype(M, /mob/critter) && M:health > 0)
					critterCount += 1
					if(V == /mob/player) victors[R] = "ongoing"
					else victors[R] = /mob/critter


		var/shipType = victors["ship"]
		var/shuttleType = victors["shuttle"]

		if(shipType == "ongoing" || shuttleType == "ongoing") return

		var/overTxt
		switch(shipType)
			if(/mob/player)
				overTxt = "\n<b>Экипаж победил!</b>"
				spawn Recap()
			if(/mob/critter)
				overTxt = "\n<b>Монстромо возвращается на землю с [critterCount] существами на борту. \
				Ад продолжается.</b>"
				spawn Recap()
			else
				switch(shuttleType)
					if(/mob/player)
						overTxt = "\n<b>Монстромо утерян, но экипаж пережил катастрофу.</b>"
						spawn Recap()
					if(/mob/critter)
						overTxt = "\n<b>Шаттл заполнен неизвестной формой жизни.</b>"
						spawn Recap()
					else
						overTxt = "\n<b>Пришельцы истреблены! Это победа для земли... \
						но не сильное утешение для экипажа.</b>"
						spawn Recap()
		to_chat(world,overTxt)


	proc/Recap()
		locks["victory"] = 1
		to_chat(world,"<p>Перезапуск через [REBOOT_DELAY / 10] секунд.")
		sleep(REBOOT_DELAY)
		Reboot()


	proc/SetUpIcons()
		OverlayManager = new()
		OverlayManager.RegisterIcon('soot.dmi', list("1", "2", "3", "4"), TURF_LAYER + 0.5)
		OverlayManager.RegisterIcon('dirs.dmi', list("1", "2", "4", "8"))
		OverlayManager.RegisterIcon('wall5.dmi', list("a1", "a2", "a3"), TURF_LAYER + 0.1)
		OverlayManager.RegisterIcon('blip.dmi', \
			list("11", "31", "51", "13", "33", "53", "15", "35", "55"))

		OverlayManager.RegisterIcon('flasher.dmi', list("small"), TURF_LAYER + 0.2)
		//(Mobs will register their own splat overlays independently.)

		to_chat(world,"<font color='red'><small>Иконки готовы.</font>")


	proc/Populate()
		var/i
		for(i = 1; i <= CAT_COUNT; i++)
			var/mob/cat/C = new()
			PutInPlace(C, /area/room)

		var/K
		if(!CRITTER_TYPE) //Pick random critter if world does not have a fixed type
			var/list/L = typesof(/mob/critter) - /mob/critter
			K = L[rand(1, L.len)]
		else K = CRITTER_TYPE

		for(i = 1; i <= CRITTER_COUNT; i++)
			var/mob/critter/CR = new K()
			PutInPlace(CR, /area/ventilation_shaft)

		to_chat(world,"<font color='red'><small>Заселили на корабль ВСЯКОЕ.</font>")


