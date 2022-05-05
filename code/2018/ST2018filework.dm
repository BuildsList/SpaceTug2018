proc/error(msg)
	world.log << "## ÎØÈÁÎ×ÊÀ: [msg]"

proc/warning(msg)
	world.log << "## ÏÐÅÄÓÏÐÅÆÄÅÍÈÅ: [msg]"

proc/file2list(filename, seperator="\n")
	return text2list(return_file_text(filename),seperator)

proc/return_file_text(filename)
	if(fexists(filename) == 0)
		error("Ôàéë íå íàéäåí ([filename])")
		return

	var/text = file2text(filename)
	if(!text)
		error("Ôàéë ïóñò ([filename])")
		return

	return text

proc/text2list(text, delimiter="\n")
	var/delim_len = length(delimiter)
	if(delim_len < 1) return list(text)
	. = list()
	var/last_found = 1
	var/found
	do
		found = findtext(text, delimiter, last_found, 0)
		. += copytext(text, last_found, found)
		last_found = found + delim_len
	while(found)

var/list/first_names_male = file2list("config/first_names_male.txt")
var/list/last_names = file2list("config/last_names.txt")