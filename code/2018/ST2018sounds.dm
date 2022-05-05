
/atom/proc/playsound(sound/S as sound, vision_distance, var/customVolume)
	var/tiles = VIEW
	if(vision_distance)
		tiles = vision_distance

	for(var/mob/M in view(tiles,src))
		var/Volume = M.SoundVolume
		if(customVolume)
			Volume = customVolume
		M << sound(S,0,0,0,Volume)

/mob/proc/HearSound(sound/S as sound, var/customVolume)
	var/myVolume = SoundVolume
	if(customVolume)
		myVolume = customVolume

	usr << sound(S,0,0,0,myVolume)

/mob/verb/Sound_Volume(var/newVolume as num)
	set category = "OOC"
	if(newVolume)
		if(newVolume > 100)
			newVolume = 100

		if(newVolume < 0)
			newVolume = 0

		SoundVolume = newVolume
		to_chat(src,"<small>Текущая громкость звуков - [SoundVolume].</small>")