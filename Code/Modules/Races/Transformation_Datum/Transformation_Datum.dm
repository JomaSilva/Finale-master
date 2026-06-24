datum/Transformation
	var
		name = ""
		forms = 1
		initial_multiplier = 1 //initial multiplier, for SSJ this'd be 50x
		var/list/form_multipliers = list()//list of form multipliers
		genetic_mutability = 1 //how much these values can change
		masterability = 1

		var/list/stats = list()
		//stats modified (if any)

		var/list/form_data = list()//masteries, modifications, etc. would be processed later on

		initial_drain = 0.001 //what % of stamina per tick does this take? stamina is used as the "global drain pool" and does not grow much, usually capping around 200/300 for most players. (everyone starts at 100 stamina.)
		//stamina drain affects ki regen and health regen, along with strength and gains.
		//drain is calculated automatically for further forms with this number:
		drain_mod = 1.25
		//(drain_mod * initial drain * form #)
		//eventually through the power of JSON you'll be able to add "* form drain #" which is a customizable number from the form data list, which will contain a JSON data table
		//for each form.

		slot=sFORM //this is what slot the buff generated through this datum will take up

		var/list/flavor_data = list()
		//similar to above, JSON memes will allow one to easily add effects to forms and stuff on the fly, will allow for ingame customization of effects of transformations.