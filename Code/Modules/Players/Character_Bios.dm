//character bios: you right click someone to get a character biography on them.
mob/var
    character_bio ={"<html>
<head><title></title></head><body>
<body bgcolor="#000000"><font size=2 color="#0099FF">
</body>"}

mob/verb/Character_Biography()
    set category = null
    set src in view(10)
    usr<<browse(character_bio,"window=browserwindow")

mob/verb/Edit_Character_Biography()
    set category = "Other"
    character_bio=input(usr,"Character Biography","Character Biography",character_bio) as message
