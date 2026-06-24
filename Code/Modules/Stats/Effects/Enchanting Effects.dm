effect
	Enchantment
		id = "Enchantment"
		max_stacks = 20//should never reach 20 of the same effect on items, but who knows!
		General//stats and resistances, largely
			Health
				Buff
					sub_id = "Health Buff"
					Added(mob/target,time=world.time)
						..()
						target.healthmod*=1+0.1*tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.healthmod/=1+0.1*tier*stacks
			Energy
				Buff
					sub_id = "Energy Buff"
					Added(mob/target,time=world.time)
						..()
						target.TMaxKi*=1+0.1*tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.TMaxKi/=1+0.1*tier*stacks
			Phys_Off
				Buff
					sub_id = "Phys Off Buff"
					Added(mob/target,time=world.time)
						..()
						target.Tphysoff+=0.1*tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.Tphysoff-=0.1*tier*stacks
			Phys_Def
				Buff
					sub_id = "Phys Def Buff"
					Added(mob/target,time=world.time)
						..()
						target.Tphysdef+=0.1*tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.Tphysdef-=0.1*tier*stacks
			Ki_Off
				Buff
					sub_id = "Ki Off Buff"
					Added(mob/target,time=world.time)
						..()
						target.Tkioff+=0.1*tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.Tkioff-=0.1*tier*stacks
			Ki_Def
				Buff
					sub_id = "Ki Def Buff"
					Added(mob/target,time=world.time)
						..()
						target.Tkidef+=0.1*tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.Tkidef-=0.1*tier*stacks
			Technique
				Buff
					sub_id = "Technique Buff"
					Added(mob/target,time=world.time)
						..()
						target.Ttechnique+=0.1*tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.Ttechnique-=0.1*tier*stacks
			Ki_Skill
				Buff
					sub_id = "Ki Skill Buff"
					Added(mob/target,time=world.time)
						..()
						target.Tkiskill+=0.1*tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.Tkiskill-=0.1*tier*stacks
			Speed
				Buff
					sub_id = "Speed Buff"
					Added(mob/target,time=world.time)
						..()
						target.Tspeed+=0.1*tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.Tspeed-=0.1*tier*stacks
			Phys_Res
				Buff
					sub_id = "Phys Res Buff"
					Added(mob/target,time=world.time)
						..()
						target.Resistances["Physical"]=target.Resistances["Physical"]*(1+0.05*tier*stacks)
					Removed(mob/target,time=world.time)
						..()
						target.Resistances["Physical"]=target.Resistances["Physical"]/(1+0.05*tier*stacks)

			Energy_Res
				Buff
					sub_id = "Energy Res Buff"
					Added(mob/target,time=world.time)
						..()
						target.Resistances["Energy"]=target.Resistances["Energy"]*(1+0.05*tier*stacks)
					Removed(mob/target,time=world.time)
						..()
						target.Resistances["Energy"]=target.Resistances["Energy"]/(1+0.05*tier*stacks)

			Fire_Res
				Buff
					sub_id = "Fire Res Buff"
					Added(mob/target,time=world.time)
						..()
						target.Resistances["Fire"]=target.Resistances["Fire"]*(1+0.05*tier*stacks)
					Removed(mob/target,time=world.time)
						..()
						target.Resistances["Fire"]=target.Resistances["Fire"]/(1+0.05*tier*stacks)

			Ice_Res
				Buff
					sub_id = "Ice Res Buff"
					Added(mob/target,time=world.time)
						..()
						target.Resistances["Ice"]=target.Resistances["Ice"]*(1+0.05*tier*stacks)
					Removed(mob/target,time=world.time)
						..()
						target.Resistances["Ice"]=target.Resistances["Ice"]/(1+0.05*tier*stacks)
			Shock_Res
				Buff
					sub_id = "Shock Res Buff"
					Added(mob/target,time=world.time)
						..()
						target.Resistances["Shock"]=target.Resistances["Shock"]*(1+0.05*tier*stacks)
					Removed(mob/target,time=world.time)
						..()
						target.Resistances["Shock"]=target.Resistances["Shock"]/(1+0.05*tier*stacks)

			Poison_Res
				Buff
					sub_id = "Poison Res Buff"
					Added(mob/target,time=world.time)
						..()
						target.Resistances["Poison"]=target.Resistances["Poison"]*(1+0.05*tier*stacks)
					Removed(mob/target,time=world.time)
						..()
						target.Resistances["Poison"]=target.Resistances["Poison"]/(1+0.05*tier*stacks)

			Holy_Res
				Buff
					sub_id = "Holy Res Buff"
					Added(mob/target,time=world.time)
						..()
						target.Resistances["Holy"]=target.Resistances["Holy"]*(1+0.05*tier*stacks)
					Removed(mob/target,time=world.time)
						..()
						target.Resistances["Holy"]=target.Resistances["Holy"]/(1+0.05*tier*stacks)

			Dark_Res
				Buff
					sub_id = "Dark Res Buff"
					Added(mob/target,time=world.time)
						..()
						target.Resistances["Dark"]=target.Resistances["Dark"]*(1+0.05*tier*stacks)
					Removed(mob/target,time=world.time)
						..()
						target.Resistances["Dark"]=target.Resistances["Dark"]/(1+0.05*tier*stacks)
		Weapon//damage effects and proc effects
			Phys_Dam
				Buff
					sub_id = "Phys Dam"
					Added(mob/target,time=world.time)
						..()
						target.DamageTypes["Physical"]=target.DamageTypes["Physical"]+tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.DamageTypes["Physical"]=target.DamageTypes["Physical"]-tier*stacks

			Energy_Dam
				Buff
					sub_id = "Energy Dam"
					Added(mob/target,time=world.time)
						..()
						target.DamageTypes["Energy"]=target.DamageTypes["Energy"]+tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.DamageTypes["Energy"]=target.DamageTypes["Energy"]-tier*stacks

			Fire_Dam
				Buff
					sub_id = "Fire Dam"
					Added(mob/target,time=world.time)
						..()
						target.DamageTypes["Fire"]=target.DamageTypes["Fire"]+tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.DamageTypes["Fire"]=target.DamageTypes["Fire"]-tier*stacks

			Ice_Dam
				Buff
					sub_id = "Ice Dam"
					Added(mob/target,time=world.time)
						..()
						target.DamageTypes["Ice"]=target.DamageTypes["Ice"]+tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.DamageTypes["Ice"]=target.DamageTypes["Ice"]-tier*stacks
			Shock_Dam
				Buff
					sub_id = "Shock Dam"
					Added(mob/target,time=world.time)
						..()
						target.DamageTypes["Shock"]=target.DamageTypes["Shock"]+tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.DamageTypes["Shock"]=target.DamageTypes["Shock"]-tier*stacks

			Poison_Dam
				Buff
					sub_id = "Poison Dam"
					Added(mob/target,time=world.time)
						..()
						target.DamageTypes["Poison"]=target.DamageTypes["Poison"]+tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.DamageTypes["Poison"]=target.DamageTypes["Poison"]-tier*stacks

			Holy_Dam
				Buff
					sub_id = "Holy Dam"
					Added(mob/target,time=world.time)
						..()
						target.DamageTypes["Holy"]=target.DamageTypes["Holy"]+tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.DamageTypes["Holy"]=target.DamageTypes["Holy"]-tier*stacks

			Dark_Dam
				Buff
					sub_id = "Dark Dam"
					Added(mob/target,time=world.time)
						..()
						target.DamageTypes["Dark"]=target.DamageTypes["Dark"]+tier*stacks
					Removed(mob/target,time=world.time)
						..()
						target.DamageTypes["Dark"]=target.DamageTypes["Dark"]-tier*stacks

			Proc
				var/proctype = null//this is the path for the effect added to the target
				Added(mob/target,time=world.time)
					..()
					target.attackeffects[proctype]=target.attackeffects[proctype]+tier*stacks
				Removed(mob/target,time=world.time)
					..()
					target.attackeffects[proctype]=target.attackeffects[proctype]-tier*stacks
		Armor//armor-only effects
		Accessory//accessory-only effects
