local rings = { }

rings.sunstone = {
	name = 'sunstone',
	dname = 'Sunstone Ring',
	icon = love.graphics.newImage("/dat/img/playerType/sunstoneicon.png"),
	weight = 1,
	affect = 'Increases maximum health.',
	effects = {
		healthMax = {effect = 50, name = 'Max Health', icon = love.graphics.newImage("/dat/img/hud/health.png")},
	},
	desc = 'A golden ring adorned by a gemstone that fell from a sun.'
}

rings.atlas = {
	name = 'atlas',
	dname = 'Atlas Strength Ring',
	icon = love.graphics.newImage("/dat/img/playerType/atlasicon.png"),
	weight = 3,
	affect = 'Increases maximum weight capacity.',
	effects = {
		weightMax = {effect = 40, name = 'Max Weight', icon = love.graphics.newImage("/dat/img/hud/weight.png")},
	},
	desc = 'A large ring whose imposing structure depicts strength and resolve.',
}

rings.hornet = {
	name = 'hornet',
	dname = 'Hornet\'s Ring',
	icon = love.graphics.newImage("/dat/img/playerType/horneticon.png"),
	weight = 1,
	affect = 'Increases thrust damage.',
	effects = {
		thrustDam = {effect = 15, name = 'Thrust Damage', icon = love.graphics.newImage("/dat/img/hud/thrust.png")},
	},
	desc = 'A ring adorned by a crystalized stinger borne from a hornet.',
}

return rings