
var/destruction_password
var/shuttle_password

proc/init_passwords()

	destruction_password = generate_password(null)
	shuttle_password = generate_password(null)

	to_chat(world,"<font color='red'><small>Пароли сгенерированы.</font>")

proc/generate_password(var/l = 0)
	var/password
	if(!l)
		l = rand(4,10)
		while(l > 0)
			if(prob(50))
				password += "[pick("A","B","C","D","E","F","G","H","I")]"
			else
				password += "[rand(1,9)]"
			l--
		return password

/obj/terminal/proc/check_password(var/mob/M, var/password)
	var/my_password = input(M,"Password")
	if(my_password == password)
		to_chat(M,"ПАРОЛЬ ПРИНЯТ.")
		return 1

	else
		to_chat(M,"<font color='red'>ДОСТУП ЗАПРЕЩЕН.</font>")
		TurnOff()
		return

/obj/terminal

	bridge_terminal
		menu(var/mob/M)
			switch(input(M,"Terminal Menu") in list("Self Destruction","Abort Self Destruction","(Turn Off)"))

				if("Self Destruction")
					if(M in range(1,src))
						if(check_password(M,destruction_password))
							self_destruct(M)
							menu(M)
					else
						TurnOff()
						return

				if("Abort Self Destruction")
					if(M in range(1,src))
						if(check_password(M,destruction_password))
							abort_self_destruct(M)
							menu(M)
					else
						TurnOff()
						return

				if("(Turn Off)")
					if(M in range(1,src))
						msg("[localize(M.name)] <B>выключает</B> [localize(name)]!")
						TurnOff()
						return
					else
						TurnOff()
						return

	shuttle_terminal
		icon = 'terminal2.dmi'
		menu(var/mob/M)
			switch(input(M,"Terminal Menu") in list("Shuttle Launch","(Turn Off)"))

				if("Shuttle Launch")
					if(M in range(1,src))
						if(check_password(M,shuttle_password))
							launch_shuttle(M)
							menu(M)
					else
						TurnOff()
						return

				if("(Turn Off)")
					if(M in range(1,src))
						msg("[localize(M.name)] <B>выключает</B> [localize(name)]!")
						TurnOff()
						return
					else
						TurnOff()
						return

	captain_terminal
		menu(var/mob/M)
			switch(input(M,"Terminal Menu") in list("Passwords","(Turn Off)"))

				if("Passwords")
					if(M in range(1,src))
						to_chat(M,"Запуск самоуничтожения - <B>[destruction_password]</B>\nЗапуск эвакуационной шлюпки - <B>[shuttle_password]</B>")
						menu(M)
					else
						TurnOff()
						return

				if("(Turn Off)")
					if(M in range(1,src))
						msg("[localize(M.name)] <B>выключает</B> [localize(name)]!")
						TurnOff()
						return
					else
						TurnOff()
						return

/obj

	terminal
		icon = 'terminal.dmi'
		icon_state = "off"
		density = 1
		var/on = 0
		var/occupied = 0

		act(var/mob/M)
			if(!on)
				msg("[localize(M.name)] <B>включает</B> [localize(name)]!")
				TurnOn()
				return

			else
				if(!occupied)
					occupied = 1
					menu(M)
				else
					return to_chat(M,"<font color='red'>Занято.</font>")

		proc/menu(var/mob/M)
			switch(input(M,"Terminal Menu",) in list("(Turn Off)"))

				if("(Turn Off)")
					msg("[localize(M.name)] <B>выключает</B> [localize(name)]!")
					TurnOff()
					return

		proc/TurnOn()
			if(on) return
			on = 1
			sleep(FLUO_INITIAL_DELAY)

			if(on && icon_state == "off")
				icon_state = "on"
				flick("powerup", src)

		proc/TurnOff()
			occupied = 0
			if(!on) return
			on = 0
			icon_state = "off"
			flick("shutdown", src)

		proc/self_destruct(var/mob/M)

			if(CheckGhostOrBrute(M)) return
			switch(input(M,"Activate Self-Destruct Sequence") in list("YES","NO"))
				if("YES")
					spawn SelfDestruct()
					return

				if("NO")
					return

		proc/abort_self_destruct(var/mob/M)

			if(CheckGhostOrBrute(M)) return

			switch(input(M,"Abort Self-Destruct Sequence") in list("YES","NO"))

				if("YES")
					spawn AbortSelfDestruct()
					return

				if("NO")
					return

		proc/launch_shuttle(var/mob/M)

			if(CheckGhostOrBrute(M)) return

			switch(input(M,"Launch Shuttle") in list("YES","NO"))

				if("YES")
					var/area/room/shuttle/S = locate()
					for(var/obj/machinery/generator/G in S)
						if(G.check_for_fuel())
							continue
						else
							return to_chat(M,"Генераторы не запитаны. Шаттл не сможет улететь.")

					spawn S.Launch()
					return

				if("NO")
					return

/obj/machinery/generator
	icon = 'machinery.dmi'
	icon_state = "generator"
	density = 1
	var/obj/portable/fuel/my_fuel = null

	act(var/mob/M)
		if(!my_fuel)
			if(M.find_content("fuel charge"))
				var/obj/portable/fuel/F = M.return_content("fuel charge")
				msg("[localize(M.name)] <B>вставляет</B> [localize(F.name)] в [localize(name)]!")
				F.Move(src)
				my_fuel = F
				return
			else
				return to_chat(M,"Нужно найти топливо.")

		else
			if(M.calculate_n_contents() < 5)
				if(locks["shuttlelaunched"])
					return to_chat(M,"<B>Да вы что!</B> Я не буду воровать заряды из генератора пока шаттл летит!")

				msg("[localize(M.name)] <B>ворует</B> [localize(my_fuel.name)] из [localize(name)]!")
				my_fuel = null
				new/obj/portable/fuel(M)
				return
			else
				return to_chat(M,"В моем инвентаре больше нет места на подобные глупости!")

	proc
		check_for_fuel()

			if(my_fuel)
				return 1

			return 0