local armor = { }

armor.longheavycoat = {
	name = 'longheavycoat',
	dname = 'Heavy Coat',
	icon = love.graphics.newImage("/dat/img/playerType/heavycoaticon.png"),
	slot = 'chest',
	img = 'longheavycoat',
	def = 8,
	balance = 0,
	defense = {
		slash = 4,
		thrust = 3,
		crush = 3,
		magic = 5,
		fire = 5,
		solar = 4,
	},
	weight = 4,
	desc = 'A robe wone by sorcerers.  Offers little in the way of physical protection, but has decent protection against magical attacks.',
}

armor.heavycoat = {
	name = 'heavycoat',
	dname = 'Heavy Coat',
	icon = love.graphics.newImage("/dat/img/playerType/heavycoaticon.png"),
	slot = 'chest',
	img = 'heavycoat',
	def = 8,
	balance = 0,
	defense = {
		slash = 4,
		thrust = 3,
		crush = 3,
		magic = 5,
		fire = 5,
		solar = 4,
	},
	weight = 4,
	desc = 'A robe wone by sorcerers.  Offers little in the way of physical protection, but has decent protection against magical attacks.',
}

armor.robe = {
	name = 'robe',
	dname = 'Cloth Robe',
	icon = love.graphics.newImage("/dat/img/playerType/robeicon.png"),
	slot = 'chest',
	img = 'robe',
	def = 8,
	balance = 0,
	defense = {
		slash = 3,
		thrust = 2,
		crush = 1,
		magic = 5,
		fire = 2,
		solar = 4,
	},
	weight = 2,
	desc = 'A robe wone by sorcerers.  Offers little in the way of physical protection, but has decent protection against magical attacks.',
}

armor.hood = {
	name = 'hood',
	dname = 'Cloth Hood',
	icon = love.graphics.newImage("/dat/img/playerType/hoodicon.png"),
	slot = 'head',
	img = 'hood',
	weight = 1,
	balance = 0,
	defense = {
		slash = 2,
		thrust = 1,
		crush = 0,
		magic = 4,
		fire = 1,
		solar = 4,
	},
	desc = 'A hood worn by sorcerers.  Offers high magic defense, but little in the way of physical defenses.',
}

armor.leathervest = {
	name = 'leathervest',
	dname = 'Leather Vest',
	icon = love.graphics.newImage("/dat/img/playerType/leathervesticon.png"),
	slot = 'chest',
	img = 'leathervest',
	def = 8,
	balance = 5,
	defense = {
		slash = 9,
		thrust = 7,
		crush = 9,
		magic = 4,
		fire = 4,
		solar = 4,
	},
	weight = 5,
	desc = 'A leather vest commonly made and worn by hunters.  Offers decent resists while being light and agile.',
}

armor.leatherhat = {
	name = 'leatherhat',
	dname = 'Leather Hat',
	icon = love.graphics.newImage("/dat/img/playerType/leatherhaticon.png"),
	slot = 'head',
	img = 'leatherhat',
	weight = 3,
	balance = 0,
	defense = {
		slash = 3,
		thrust = 2,
		crush = 1,
		magic = 2,
		fire = 3,
		solar = 2,
	},
	desc = 'A hat worn by hunters of the forest.',
}

armor.thiefmask = {
	name = 'thiefmask',
	dname = 'Thief\'s Mask',
	icon = love.graphics.newImage("/dat/img/playerType/thiefmaskicon.png"),
	slot = 'head',
	img = 'thiefmask',
	weight = 1,
	balance = 0,
	defense = {
		slash = 1,
		thrust = 1,
		crush = 1,
		magic = 1,
		fire = 0,
		solar = 1,
	},
	desc = 'A bandanda commonly worn by thieves to conceal their faces\'s.',
}

armor.skullcap = {
	name = 'skullcap',
	dname = 'Skull Cap',
	icon = love.graphics.newImage("/dat/img/playerType/skullcapicon.png"),
	slot = 'head',
	img = 'skullcap',
	def = 6,
	weight = 5,
	balance = 5,
	defense = {
		slash = 5,
		thrust = 5,
		crush = 4,
		magic = 3,
		fire = 3,
		solar = 3,
	},
	weight = 4,
	desc = 'A sturdy helm with few weak points.  Worn by knights of the star legions.',
}

armor.knighthelm = {
	name = 'knighthelm',
	dname = 'Knight Helm',
	icon = love.graphics.newImage("/dat/img/playerType/knighthelmicon.png"),
	slot = 'head',
	img = 'knighthelm',
	def = 6,
	weight = 5,
	balance = 5,
	defense = {
		slash = 7,
		thrust = 7,
		crush = 5,
		magic = 4,
		fire = 3,
		solar = 3,
	},
	weight = 5,
	desc = 'A sturdy helm with few weak points.  Worn by knights of the star legions.',
}

armor.tutbosshelm = {
	name = 'tutbosshelm',
	dname = 'Guardian Helm',
	icon = love.graphics.newImage("/dat/img/playerType/knighthelmicon.png"),
	slot = 'head',
	img = 'tutbosshelm',
	def = 6,
	weight = 5,
	balance = 7,
	defense = {
		slash = 10,
		thrust = 9,
		crush = 8,
		magic = 10,
		fire = 10,
		solar = 10,
	},
	weight = 5,
	desc = 'Helm of the spirit who guards the chamber of awakening.',
}

armor.tutbosschest = {
	name = 'tutbosschest',
	dname = 'Guardian Plate',
	icon = love.graphics.newImage("/dat/img/playerType/knightchesticon.png"),
	slot = 'chest',
	img = 'tutboss',
	def = 15,
	weight = 19,
	balance = 100,
	defense = {
		slash = 20,
		thrust = 18,
		crush = 17,
		magic = 15,
		fire = 12,
		solar = 10,
	},
	weight = 12,
	desc = 'Helm of the spirit who guards the chamber of awakening.',
}

armor.knightchest = {
	name = 'knightchest',
	dname = 'Knight Platemail',
	icon = love.graphics.newImage("/dat/img/playerType/knightchesticon.png"),
	slot = 'chest',
	img = 'knightchest',
	def = 15,
	balance = 20,
	defense = {
		slash = 15,
		thrust = 14,
		crush = 11,
		magic = 5,
		fire = 3,
		solar = 4,
	},
	weight = 12,
	desc = 'A sturdy chestplate that offers great defenses.  Worn by knights of the star legions.',
}

return armor