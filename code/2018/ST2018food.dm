
/obj/portable/food

	icon = 'food.dmi'
	var/hp

	verb/eat()
		set src in usr
		if(CheckGhostOrBrute(usr)) return

		if(usr.health >= usr.maxHealth)
			return to_chat(usr,"Я не голоден.")

		usr.msg("<B>[localize(usr.name)] кушает [localize(name)]!</B>")
		usr.health += hp
		if(usr.health > usr.maxHealth)
			usr.health = usr.maxHealth
		del(src)

	burger
		name = "hamburger"
		icon_state = "burger"
		hp = 2

	choco_cube
		name = "choco cube"
		icon_state = "choco_cube"
		hp = 1

	donut
		name = "donut"
		icon_state = "donut"
		hp = 1

	pill

		green_pill
			name = "green pill"
			icon_state = "gpill"
			hp = 4