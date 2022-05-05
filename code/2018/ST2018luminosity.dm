proc/init_luminosity()
	for(var/turf/T in world)
		if(!T.my_lum)
			var/obj/lum/LUM = new(T)
			T.my_lum = LUM
			T.set_lum(7)
		T.check_lum()

/turf
	var/obj/lum/my_lum = null

/turf/proc/check_lum()
	overlays = null
	overlays += my_lum.icon_state

/turf/proc/calculate_lum(var/lum)
	if(!lum || lum > 7)
		return

	var/newLum = 7-lum
	set_lum(newLum)

	for(var/turf/T in orange(lum,src))
		if(!T.my_lum)
			var/obj/lum/LUM = new(T)
			T.my_lum = LUM
			T.set_lum(7)

		if(T.my_lum.power == 7 || T.my_lum.power == 6 || T.my_lum.power == 5 || T.my_lum.power == 4)
			if(newLum+get_dist(T,src) <= 7)
				T.set_lum(newLum+get_dist(T,src))
			else
				break

/turf/proc/clear_lum(var/lum)
	set_lum(7)
	for(var/turf/T in orange(lum,src))
		if(!T.my_lum)
			var/obj/lum/LUM = new(T)
			T.my_lum = LUM
			T.set_lum(7)

		if(T.my_lum.power != 7)
			T.set_lum(7)

	for(var/obj/fluorescent_light/L in LIGHTS)
		var/turf/BLYAT = L.loc
		if(L.on)
			BLYAT.calculate_lum(7)


/turf/proc/set_lum(var/n)
	if(my_lum)
		if(n > 7)
			my_lum.icon_state = "dark7"
			my_lum.power = 7
		else
			my_lum.icon_state = "dark[n]"
			my_lum.power = n
		check_lum()

/obj/lum
	var/power = 7
	icon = 'luminosity.dmi'
	layer = 50
	mouse_opacity = 0