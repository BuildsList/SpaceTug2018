
/*/mob/verb/localize_me(var/txt as text)
	to_chat(src,localize(txt))*/

/*
proc/localize(var/text)
	var/index

	if(findtext(text,"a"))
		index = findtext(text,"a")
		while(index)
			text = copytext(text,1,index) + "à" + copytext(text,index+1)
			index = findtext(text,"a")

	if(findtext(text,"b"))
		index = findtext(text,"b")
		while(index)
			text = copytext(text,1,index) + "á" + copytext(text,index+1)
			index = findtext(text,"b")

	if(findtext(text,"c"))
		index = findtext(text,"c")
		while(index)
			text = copytext(text,1,index) + "ê" + copytext(text,index+1)
			index = findtext(text,"c")

	if(findtext(text,"d"))
		index = findtext(text,"d")
		while(index)
			text = copytext(text,1,index) + "ä" + copytext(text,index+1)
			index = findtext(text,"d")

	if(findtext(text,"e"))
		index = findtext(text,"e")
		while(index)
			text = copytext(text,1,index) + "å" + copytext(text,index+1)
			index = findtext(text,"e")

	if(findtext(text,"f"))
		index = findtext(text,"f")
		while(index)
			text = copytext(text,1,index) + "ô" + copytext(text,index+1)
			index = findtext(text,"f")

	if(findtext(text,"g"))
		index = findtext(text,"g")
		while(index)
			text = copytext(text,1,index) + "ã" + copytext(text,index+1)
			index = findtext(text,"g")

	if(findtext(text,"h"))
		index = findtext(text,"h")
		while(index)
			text = copytext(text,1,index) + "õ" + copytext(text,index+1)
			index = findtext(text,"h")

	if(findtext(text,"i"))
		index = findtext(text,"i")
		while(index)
			text = copytext(text,1,index) + "è" + copytext(text,index+1)
			index = findtext(text,"i")

	if(findtext(text,"j"))
		index = findtext(text,"j")
		while(index)
			text = copytext(text,1,index) + "æ" + copytext(text,index+1)
			index = findtext(text,"j")

	if(findtext(text,"k"))
		index = findtext(text,"k")
		while(index)
			text = copytext(text,1,index) + "ê" + copytext(text,index+1)
			index = findtext(text,"k")

	if(findtext(text,"l"))
		index = findtext(text,"l")
		while(index)
			text = copytext(text,1,index) + "ë" + copytext(text,index+1)
			index = findtext(text,"l")

	if(findtext(text,"m"))
		index = findtext(text,"m")
		while(index)
			text = copytext(text,1,index) + "ì" + copytext(text,index+1)
			index = findtext(text,"m")

	if(findtext(text,"n"))
		index = findtext(text,"n")
		while(index)
			text = copytext(text,1,index) + "í" + copytext(text,index+1)
			index = findtext(text,"n")

	if(findtext(text,"o"))
		index = findtext(text,"o")
		while(index)
			text = copytext(text,1,index) + "î" + copytext(text,index+1)
			index = findtext(text,"o")

	if(findtext(text,"p"))
		index = findtext(text,"p")
		while(index)
			text = copytext(text,1,index) + "ï" + copytext(text,index+1)
			index = findtext(text,"p")

	if(findtext(text,"q"))
		index = findtext(text,"q")
		while(index)
			text = copytext(text,1,index) + "ê" + copytext(text,index+1)
			index = findtext(text,"q")

	if(findtext(text,"r"))
		index = findtext(text,"r")
		while(index)
			text = copytext(text,1,index) + "ð" + copytext(text,index+1)
			index = findtext(text,"r")

	if(findtext(text,"s"))
		index = findtext(text,"s")
		while(index)
			text = copytext(text,1,index) + "ñ" + copytext(text,index+1)
			index = findtext(text,"s")

	if(findtext(text,"t"))
		index = findtext(text,"t")
		while(index)
			text = copytext(text,1,index) + "ò" + copytext(text,index+1)
			index = findtext(text,"t")

	if(findtext(text,"u"))
		index = findtext(text,"u")
		while(index)
			text = copytext(text,1,index) + "ó" + copytext(text,index+1)
			index = findtext(text,"u")

	if(findtext(text,"v"))
		index = findtext(text,"v")
		while(index)
			text = copytext(text,1,index) + "â" + copytext(text,index+1)
			index = findtext(text,"v")

	if(findtext(text,"w"))
		index = findtext(text,"w")
		while(index)
			text = copytext(text,1,index) + "óî" + copytext(text,index+2)
			index = findtext(text,"w")

	if(findtext(text,"x"))
		index = findtext(text,"x")
		while(index)
			text = copytext(text,1,index) + "êñ" + copytext(text,index+2)
			index = findtext(text,"x")

	if(findtext(text,"y"))
		index = findtext(text,"y")
		while(index)
			text = copytext(text,1,index) + "è" + copytext(text,index+1)
			index = findtext(text,"y")

	if(findtext(text,"z"))
		index = findtext(text,"z")
		while(index)
			text = copytext(text,1,index) + "ç" + copytext(text,index+1)
			index = findtext(text,"z")

	return text */

var/list/alphabet = list(
    "a" = "à", "b" = "á", "c" = "ê", "d" = "ä", "e" = "å",
    "f" = "ô", "g" = "ã", "h" = "õ", "i" = "è", "j" = "æ",
    "k" = "ê", "l" = "ë", "m" = "ì", "n" = "í", "o" = "î",
    "p" = "ï", "r" = "ð", "s" = "ñ", "t" = "ò", "u" = "ó",
    "v" = "â", "w" = "óî", "x" = "êñ", "y" = "è", "z" = "ç")

proc/localize(message)
    for(var/i in alphabet)
        message = replacetext(message, i , "[alphabet[i]]")
    return message