extends Node


var WeaponModAvailabilityPresets: = {
	'unowned' : func(title: String) -> bool:
		return !GlobalData.weaponMods.has(title),
	'always' : func(title: String) -> bool:
		return true,
	'currentMods' : func(title: String, has: Array, hasNot: Array) -> bool:
		for mod in has:
			if !GlobalData.weaponMods.has(mod):
				return false
		for mod in hasNot:
			if GlobalData.weaponMods.has(mod):
				return false
		return true
}

var FortuneReadingAvailabilityPresets: = {
	'unowned' : func(title: String) -> bool:
		return !GlobalData.fortuneReadings.has(title),
	'always' : func(title: String) -> bool:
		return true,
	'currentMods' : func(title: String, has: Array, hasNot: Array) -> bool:
		for mod in has:
			if !GlobalData.fortuneReadings.has(mod):
				return false
		for mod in hasNot:
			if GlobalData.fortuneReadings.has(mod):
				return false
		return true
}


const UpgradeShownTitles: = {
	# smith
	'doubleVision': 'Double Vision',
	'clusteredShot': 'Clustered Shot',
	'metaboloader': 'The Metaboloader',
	'fullbodyMetaboloader': 'Fullbody Metaboloader',
	'atpCharges': 'ATP Charges',
	'sprayMetaboloader': 'Spray Metaboloader',
	# teller
	'succubus': 'the Succubus',
	'desperado': 'the Desperado',
	'vampire': 'the Vampire',
}

const WeaponModTitles: = [
	'doubleVision',
	'clusteredShot',
	'metaboloader',
	'fullbodyMetaboloader',
	'atpCharges',
	'sprayMetaboloader',
]

const FortuneReadingTitles: = [
	'succubus',
	'desperado',
	'vampire',
]


var UpgradeAvailableChecks: = {
	# smith
	'doubleVision': WeaponModAvailabilityPresets['unowned'],
	'clusteredShot': WeaponModAvailabilityPresets['currentMods'].bind(['doubleVision'], ['clusteredShot']),
	'metaboloader': WeaponModAvailabilityPresets['unowned'],
	'fullbodyMetaboloader': WeaponModAvailabilityPresets['currentMods'].bind(['metaboloader'], ['fullbodyMetaboloader', 'sprayMetaboloader']),
	'atpCharges': WeaponModAvailabilityPresets['currentMods'].bind(['metaboloader'], ['atpCharges']),
	'sprayMetaboloader': WeaponModAvailabilityPresets['currentMods'].bind(['metaboloader'], ['sprayMetaboloader', 'fullbodyMetaboloader']),
	# teller
	'succubus': FortuneReadingAvailabilityPresets['unowned'],
	'desperado': FortuneReadingAvailabilityPresets['unowned'],
	'vampire': FortuneReadingAvailabilityPresets['currentMods'].bind(['succubus'], ['vampire']),
}



const UpgradeDescriptions: = {
	
	# smith
	'doubleVision': 
'''	[color=#bfbfbf][i]Trippy glasses that double your bullets. Well, actually, they just add 1 bullet. Doubling would be overpowered, you understand. And hey, just so you know, "33.33%" is always actually exactly 1/3 in the code. And 16.66% is 1/6, etc. Also, the theme of this upgrade is going to completely change and so will the description, so I can say whatever dumb stuff I want here.[/i][/color]
	
		[color=#bce3c3]+1 bullet per attack[/color]
		[color=#f5a9a4]-1/3 attack speed[/color]
	
	Press [E] or [X] to select.''',
	
	
	
	'clusteredShot': 
'''	[color=#bfbfbf][i]Makes your weapon fire an extra volley each time you fire it. It's growing ever closer to the shotgun archtype...[/i][/color]
	
		[color=#bce3c3]Shoot +1 vollies each time you attack[/color]
		[color=#f5a9a4]-1/3 attack speed[/color]
	
	Press [E] or [X] to select.''',
	
	
	
	'metaboloader': 
'''	[color=#bfbfbf][i]Fuels the reloading of your gun with your own bodily functions. You don't wanna know how it works, trust me.[/i][/color]
	
		[color=#bce3c3]Gain up to +33.33% attack speed while sprinting. Charges up over 1 second while continuously sprinting[/color]
		[color=#f5a9a4]-1/6 max stamina[/color]
	
	Press [E] or [X] to select.''',
	
	
	
	'fullbodyMetaboloader': 
'''	[color=#bfbfbf][i]Makes the metaboloader take all of your attention. Just like my ex. Eh? Hah! Heh heh.[/i][/color]
	
		[color=#bce3c3]Fire twice as many bullets while Metaboloader is fully activated[/color]
		[color=#ff0000]Metaboloader only activates while standing still and holding the sprint key[/color]
		[color=#8d9df2]Mutually exclusive with the Spray Metaboloader mod[/color]
		
	
	Press [E] or [X] to select.''',
	
	
	
	'atpCharges': 
'''	[color=#bfbfbf][i]Did you know that ATP stands for deoxyriboneucleic acid? Congratulations, you're basically a p.h.d. scientist now.[/i][/color]
	
		[color=#bce3c3]Metaboloader gives your bullets (up to) +1/3 size and +2/3 damage.[/color]
		[color=#f5a9a4]Using Metaboloader costs +50% stamina.[/color]
	
	Press [E] or [X] to select.''',
	
	
	
	'sprayMetaboloader': 
'''	[color=#bfbfbf][i]It turns out that omitting the aiming step allows for the firing process to go much faster.[/i][/color]
	
		[color=#bce3c3]Increases Metaboloader attack speed bonus from +1/3 to +2/3[/color]
		[color=#ff0000]Makes you shoot in a random direction[/color]
		[color=#f5a9a4]Makes your bullets not home in on enemies for the first .25 seconds[/color]
		[color=#f5a9a4]Decreases your bullets' homing by 80%[/color]
			[color=#bfbfbf](It's not as bad as it sounds, I promise)[/color]
		[color=#8d9df2]Mutually exclusive with the Fullbody Metaboloader mod[/color]
	
	Press [E] or [X] to select.''',
	
	
	
	# teller
	'succubus':
'''	[color=#bfbfbf][i]"The Succubus shall gain its energy from leeching it out of its prey."[/i][/color]
	
		[color=#bce3c3]Gain stamina when killing an enemy, based on its max health[/color]
			[color=#bfbfbf](For reference, killing a shadow hound and all its children gives 50% of your default max stamina)[/color]
		[color=#f5a9a4]-40% passive stamina regeneration[/color]
	
	Press [E] or [X] to select.''',
	
	'vampire':
'''	[color=#bfbfbf][i]"The Vampire shall rely exclusively on its prey for its energy."[/i][/color]
	
		[color=#bce3c3]Gain three times as much stamina upon killing an enemy.[/color]
			[color=#bfbfbf](For reference, killing a shadow hound and all its children now gives 150% of your default max stamina)[/color]
		[color=#ff0000]No passive stamina regeneration[/color]
	
	Press [E] or [X] to select.''',
	
	
	
	'desperado':
'''	[color=#bfbfbf][i]"The Desperado shall use all its available resources, albiet with diminishing returns."[/i][/color]
	
		[color=#bce3c3]While holding [Space], your bullets' homing increases by +300%[/color]
		[color=#f5a9a4]While holding [Space], you get -2/3% attack speed[/color]
	
	Press [E] or [X] to select.''',
}



func getAvailableWeaponMods() -> Array[String]:
	var rtrn: Array[String] = []
	for mod in WeaponModTitles:
		if UpgradeAvailableChecks[mod].call(mod):
			rtrn.append(mod)
	return rtrn
	
func getAvailableFortuneReadings() -> Array[String]:
	var rtrn: Array[String] = []
	for mod in FortuneReadingTitles:
		if UpgradeAvailableChecks[mod].call(mod):
			rtrn.append(mod)
	return rtrn
