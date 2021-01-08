enemyType = { }

---
--- Props
---

enemyType.chair2 = {
	type = 'actor',
	team = 3,
	hitBoxWidth = 4,
	hitBoxHeight = 2,
	disableBackstab = true,
	vitality = 0.0001,
	bloodType = 'wood',
	gibAmount = {6,4,4},
	matter = 0,
	ai = '',
	draw =	function (self, game)
				love.graphics.draw(self.img, self.x, self.y, 0, 1, 1, 16, 16)
				return self
			end,
	onCreate =	function (self, game)
					self.img = love.graphics.newImage("/dat/img/map/prop/chair2.png")
					return self
				end,
}

enemyType.chair1 = {
	type = 'actor',
	team = 3,
	hitBoxWidth = 4,
	hitBoxHeight = 2,
	disableBackstab = true,
	vitality = 0.0001,
	bloodType = 'wood',
	gibAmount = {6,4,4},
	matter = 0,
	ai = '',
	draw =	function (self, game)
				love.graphics.draw(self.img, self.x, self.y, 0, 1, 1, 16, 16)
				return self
			end,
	onCreate =	function (self, game)
					self.img = love.graphics.newImage("/dat/img/map/prop/chair1.png")
					return self
				end,
}

enemyType.table1 = {
	type = 'actor',
	team = 3,
	hitBoxWidth = 32,
	hitBoxHeight = 2,
	disableBackstab = true,
	vitality = 0.0001,
	bloodType = 'wood',
	gibAmount = {12,8,8},
	matter = 0,
	ai = '',
	draw =	function (self, game)
				love.graphics.draw(self.img, self.x, self.y, 0, 1, 1, 32, 32)
				return self
			end,
	onCreate =	function (self, game)
					self.img = love.graphics.newImage("/dat/img/map/prop/table1.png")
					return self
				end,
}

---
--- Basic Enemies
---

enemyType.garg1 = {
	type = 'actor',
	team = 2,
	color = {100, 255, 125},
	playerType = true,
	acceleartion = 300,
	deceleration = 100,
	maxSpeed = 35,
	leash = 150,
	ai = 'simple',
	turnCDSet = 0.35,
	vitality = 9,
	hitBoxWidth = 16,
	hitBoxHeight = 16,
	weapon = 'gargsword',
	flying = true,
	attunement = {{spellName = 'lightbolt', casts = 3, stackable = false, stack = 1}},
	attuneSlotFocus = 1,
	update =	function (self, game, dt)
					for k,v in pairs(self.anims) do 
						v:update(dt)
					end
					return self
				end,
	draw =	function (self, game)
				local sway = {
						north = { {0,0},{0,-1},{0,0},{0,1}, },
						south = { {0,0},{0,-1},{0,0},{0,1}, },
						east = { {-1,0},{-1,-1},{0,-1},{0,0}, },
						west = { {1,0},{1,-1},{0,-1},{0,0}, },			
					}
				if self.dir == 'east' or self.dir == 'west' or self.dir == 'south' then 
					self.anims[self.dir]:draw(self.img, self.x, self.y, 0, 1, 1, 16, 16)
					game.drawWeapon(self, 0, 0, 0, false, self.dir, sway)
				else
					game.drawWeapon(self, 0, 0, 0, false, self.dir, sway)
					self.anims[self.dir]:draw(self.img, self.x, self.y, 0, 1, 1, 16, 16)
				end
				return self
			end,
	onCreate = 	function (self, game)
					local anim8 = game.getAnim8()	
					self.img = love.graphics.newImage("/dat/img/mon/gargsheet.png")
					self.anims = {
						east = anim8.newAnimation(anim8.newGrid(32, 32, 256, 128)('1-8',1), 0.15),
						west = anim8.newAnimation(anim8.newGrid(32, 32, 256, 128)('1-8',2), 0.15),
						south = anim8.newAnimation(anim8.newGrid(32, 32, 256, 128)('1-8',3), 0.15),
						north = anim8.newAnimation(anim8.newGrid(32, 32, 256, 128)('1-8',4), 0.15),
					}
					return self
				end,
}

enemyType.dog = {
	type = 'actor',
	team = 2,
	color = {245, 245, 245},
	acceleration = 500,
	deceleration = 300,
	maxSpeed = 90,
	leash = 150,
	ai = 'lost',
	turnCDSet = 0.35,
	vitality = 3,
	hitBoxWidth = 15,
	hitBoxHeight = 15,
	update =function (self, game, dt)
				local d = math.sqrt((game.getPlayer().y - self.y)^2 + (game.getPlayer().x - self.x)^2)
				local angle = math.atan2(game.getPlayer().y - self.y, game.getPlayer().x - self.x)
				self.anims['north'][self.state]:update(dt)
				self.anims['south'][self.state]:update(dt)
				self.anims['east'][self.state]:update(dt)
				self.anims['west'][self.state]:update(dt)
				self.stateTimer = self.stateTimer - dt
				self.turnCD = self.turnCD - dt
				if self.noticed then 
					if angle < 0 then angle = angle + 2 * math.pi end
					if angle > math.pi / 4 and angle <= 3 * math.pi / 4 then
						self = game.actorTurnTowards(self, {x = game.getPlayer().x, y = game.getPlayer().y}, 'south')
					elseif angle > 3 * math.pi / 4 and angle <= 5 * math.pi / 4 then 
						self = game.actorTurnTowards(self, {x = game.getPlayer().x, y = game.getPlayer().y}, 'west')
					elseif angle > 5 * math.pi / 4 and angle <= 7 * math.pi / 4 then 
						self = game.actorTurnTowards(self, {x = game.getPlayer().x, y = game.getPlayer().y}, 'north')
					else
						self = game.actorTurnTowards(self, {x = game.getPlayer().x, y = game.getPlayer().y}, 'east')
					end
				end
				if self.state == 'jump' and self.stateTimer < 1 and self.stateTimer > 0.5 then 
					game.addHurtbox(self.team, self.x - 12, self.y - 8, 24, 16, love.timer.getDelta(), 15, 'slash', self.x, self.y, 0.15, 2, -0.15)
				end
				if self.state == 'walk' and d > 32 then 
					self.dx = self.dx + math.cos(angle) * self.acceleration * dt 
					self.dy = self.dy + math.sin(angle) * self.acceleration * dt
				elseif self.state == 'jump' and self.stateTimer > 0.75 and self.stateTimer < 1 then 
					self.dx = self.dx + math.cos(angle) * self.acceleration * 3 * dt 
					self.dy = self.dy + math.sin(angle) * self.acceleration * 3 * dt
				elseif self.state == 'walk' and d <= 32 then 
					self.state = 'jump'
					self.anims['north'][self.state]:gotoFrame(1)
					self.anims['south'][self.state]:gotoFrame(1)
					self.anims['east'][self.state]:gotoFrame(1)
					self.anims['west'][self.state]:gotoFrame(1)
					self.stateTimer = 1.5
					self.maxSpeed = 175
				end
				if self.stateTimer <= 0 and self.state ~= 'jump' then 
					self.state = 'idle'
					if d <= self.leash and not self.noticed then 
						self.noticed = true 
						self.hasBarked = false
					end
					if self.noticed then 
						if not self.hasBarked then 
							self.state = 'bark'
							self.stateTimer = love.math.random(1.5, 3)
							self.hasBarked = true
						else
							self.state = 'walk'
							self.stateTimer = love.math.random(3, 6)
						end
					end
				elseif self.stateTimer <= 0 and self.state == 'jump' then
					self.state = 'idle'
					self.stateTimer = love.math.random(0.25, 1.5)
					self.hasBarked = false
					self.maxSpeed = 90
					self.dx = 0
					self.dy = 0
				end
				return self
			end,
	draw =	function (self, game)
				self.anims[self.dir][self.state]:draw(self.imgSheet, self.x, self.y, 0, 1, 1, 16, 16)
				return self
			end,
	onCreate =	function (self, game)
					local anim8 = game.getAnim8()
					self.state = 'idle'
					self.hasBarked = false
					self.stateTimer = 0.01
					self.imgSheet = love.graphics.newImage("/dat/img/mon/dogsheet.png")
					self.anims = {
						east = {
							idle = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('1-6',1), 0.3),
							stun = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)(1,1), 0.3),
							walk = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('1-4',2), 0.15),
							bark = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('3-4',3), 0.15),
							jump = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('1-2',3), 0.5, false),
						},
						west = {
							idle = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('1-6',4), 0.3),
							stun = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)(1,4), 0.3),
							walk = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('1-4',5), 0.15),
							bark = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('3-4',6), 0.15),
							jump = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('1-2',6), 0.5, false),
						},
						south = {
							idle = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('1-6',7), 0.3),
							stun = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)(1,7), 0.3),
							walk = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('1-4',8), 0.15),
							bark = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('3-4',9), 0.15),
							jump = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('1-2',9), 0.5, false),
						},
						north = {
							idle = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('1-6',10), 0.3),
							stun = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)(1,10), 0.3),
							walk = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('1-4',11), 0.15),
							bark = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('3-4',12), 0.15),
							jump = anim8.newAnimation(anim8.newGrid(32, 32, 192, 414)('1-2',12), 0.5, false),
						},
					}
					return self
				end,
}

enemyType.lostsword = {
	type = 'actor',
	playerType = true,
	team = 2,
	color = {237, 107, 199},
	acceleration = 600,
	deceleration = 500,
	maxSpeed = 60,
	ai = 'lost',
	weapon = 'shortsword',
	turnCDSet = 0.35,
}

enemyType.lostspear = {
	type = 'actor',
	playerType = true,
	team = 2,
	color = {237, 107, 199},
	acceleration = 600,
	deceleartion = 500,
	maxSpeed = 60,
	ai = 'lost',
	weapon = 'spear',
	turnCDSet = 0.35,
}

enemyType.advlostsword = {
	type = 'actor',
	playerType = true,
	team = 2,
	color = {217, 87, 179},
	acceleration = 600,
	deceleration = 400,
	maxSpeed = 70,
	ai = 'advlost',
	weapon = 'shortsword',
	armorChest = 'leathervest',
	turnCDSet = 0.35,
}

enemyType.advlostspear = {
	type = 'actor',
	playerType = true,
	team = 2,
	color = {217, 87, 179},
	acceleration = 600,
	deceleration = 400,
	maxSpeed = 70,
	ai = 'advlost',
	weapon = 'spear',
	offhand = 'kiteshield',
	armorChest = 'knightchest',
	armorHead = 'knighthelm',
	turnCDSet = 0.35,
}

enemyType.normsword = {
	type = 'actor',
	playerType = true,
	team = 2,
	color = {255, 80, 200},
	acceleration = 600,
	deceleration = 400,
	maxSpeed = 70,
	ai = 'simple',
	weapon = 'shortsword',
	armorChest = 'leathervest',
	armorHead = 'knighthelm',
	leash = 150,
	turnCDSet = 0.35,
}

enemyType.normaxe = {
	type = 'actor',
	playerType = true,
	team = 2,
	color = {255, 170, 20},
	acceleration = 600,
	deceleration = 400,
	maxSpeed = 70,
	twoHanded = true,
	ai = 'simple',
	weapon = 'battleaxe',
	armorChest = 'knightchest',
	armorHead = 'skullcap',
	dexterity = 8,
	strength = 25,
	endurance = 15,
	stability = 10,
	vitality = 16,
	leash = 150,
	turnCDSet = 0.4,
}

enemyType.normrapier = {
	type = 'actor',
	playerType = true,
	team = 2,
	color = {255, 170, 20},
	acceleration = 600,
	deceleration = 400,
	maxSpeed = 70,
	twoHanded = true,
	ai = 'simple',
	weapon = 'rapier',
	armorChest = 'heavycoat',
	armorHead = 'knighthelm',
	dexterity = 15,
	endurance = 15,
	stability = 12,
	vitality = 8,
	leash = 150,
	turnCDSet = 0.35,
}

enemyType.nakedsword = {
	type = 'actor',
	playerType = true,
	team = 2,
	color = {255, 80, 200},
	acceleration = 600,
	deceleration = 400,
	maxSpeed = 70,
	ai = 'simple',
	weapon = 'shortsword',
	leash = 150,
	turnCDSet = 0.35,
}

enemyType.nakedspear = {
	type = 'actor',
	playerType = true,
	team = 2,
	color = {255, 80, 100},
	acceleration = 600,
	deceleration = 400,
	maxSpeed = 70,
	ai = 'simple',
	weapon = 'spear',
	leash = 150,
	turnCDSet = 0.35,
}

enemyType.normspear = {
	type = 'actor',
	playerType = true,
	team = 2,
	color = {255, 80, 100},
	acceleration = 600,
	deceleration = 400,
	maxSpeed = 70,
	ai = 'simple',
	weapon = 'spear',
	offhand = 'kiteshield',
	armorChest = 'knightchest',
	armorHead = 'knighthelm',
	leash = 150,
	turnCDSet = 0.35,
}

enemyType.normbow = {
	type = 'actor',
	playerType = true,
	team = 2,
	color = {125, 255, 50},
	acceleration = 600,
	deceleration = 400,
	maxSpeed = 70,
	ai = 'simple',
	weapon = 'longbow',
	armorChest = 'leathervest',
	setAttackCD = 4,
	leash = 220,
	turnCDSet = 0.35,
	endurance = 3,
	vitality = 5,
	dexterity = 8,
}

---
--- Bosses
---

enemyType.tutboss = {
	type = 'actor',
	playerType = true,
	dname = 'Guardian Spirit',
	team = 2,
	color = {100, 255, 150},
	acceleration = 400,
	deceleration = 200,
	maxSpeed = 55,
	ai = 'tutboss',
	weapon = 'bosshalberd',
	armorChest = 'tutbosschest',
	armorHead = 'tutbosshelm',
	dropList = {
		'naniteinjector',
	},
	headOffY = -2,
	leash = 200,
	turnCDSet = 0.45,
	strength = 5,
	vitality = 30,
	endurance = 20,
	stability = 200,
	matter = 2000,
	disableBackstab = true,
	boss = true,
	footType = 2,
	hitBoxHeight = 38,
	hitBoxWidth = 14,
}

enemyType.jericho = {
	type = 'actor',
	playerType = true,
	dname = 'Twin Fang Assassin',
	team = 2,
	color = {100, 100, 235},
	acceleration = 600,
	deceleration = 350,
	maxSpeed = 70,
	permDead = true,
	headOffY = -4,
	handOY = 3,
	hitBoxHeight = 26,
	footType = 2,
	boss = true,
	ai = 'simple',
	weapon = 'rapier',
	offhand = 'stiletto',
	armorChest = 'longheavycoat',
	armorHead = 'knighthelm',
	ring1 = 'hornet',
	ring2 = 'atlas',
	leash = 150,
	strength = 15,
	dexterity = 35,
	vitality = 77,
	endurance = 25,
	stability = 10,
	matter = 2000,
	turnCDSet = 0.35,
}

return enemyType