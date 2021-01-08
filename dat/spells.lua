local spells = { }

spells.heavystarshard = {
	name = 'heavystarshard',
	dname = 'Heavy Star Shard',
	type = 'sorcery',
	icon = love.graphics.newImage("/dat/img/playerType/heavystarshardicon.png"),
	casts = 10,
	castTime = 0.80,
	castPart = 'magiccast2',
	slot = 'spell',
	desc = 'Nearby matter is condensed by a catalyst to create a large shard of a star.  \n\nSpells must be attuned at a cryogenic pod and then require a staff to catalyze.',
	affect = 'Casts a large homing star shard that tracks your enemies.',
	onCast =	function (game, actor, angle, data)
					if actor.state ~= 'cast' then return end
					local update =  function (self, dt, data)
										if not self.onCreate then 
											self.onCreate = true 
											for x = self.x - 3, self.x + 3, 1 do 
												for y = self.y - 3, self.y + 3, 1 do
													data.game.emitParticlesAt(self.flight, x, y, 1)
												end
											end
										end
										self.speed = math.min(400, self.speed + (250 + self.speed) * dt)
										return self
									end
					local oy = 0
					local dam = 0
					if actor.state == 'cast' then 
						oy = actor.weapon.castOy
						dam = 125 + game.actorGetWeaponDamage(actor) * 5
					end
					game.addProjectile({img = data.img.weapon.starshard2, tracking = true, update = update, flight = 'magicflight2', x = actor.x + actor.weaponAction.x, y = actor.y + actor.weaponAction.y + oy, rot = angle, drot = angle, speed = 5, nohit = 0.05, dam = dam, dtype = 'magic', team = actor.team, stun = actor.weapon.stundam, bdam = actor.weapon.bdam, knockback = actor.weapon.knockback})
				end,
}

spells.lightbolt = {
	name = 'lightbolt',
	dname = 'Lightning Bolt',
	type = 'sorcery',
	icon = love.graphics.newImage("/dat/img/playerType/starshardicon.png"),
	casts = 30,
	castTime = 0.20,
	castPart = 'lightcast',
	slot = 'spell',
	desc = 'Nearby matter is condensed by a catalyst to create the shard of a star.  \n\nSpells must be attuned at a cryogenic pod and then require a staff to catalyze.',
	affect = 'Casts a homing star shard that tracks your enemies.',
	onCast =	function (game, actor, angle, data)
					if actor.state ~= 'cast' then return end
					local update =  function (self, dt, data)
										if not self.onCreate then 
											self.onCreate = true 
											for x = self.x - 3, self.x + 3, 1 do 
												for y = self.y - 3, self.y + 3, 1 do
													data.game.emitParticlesAt(self.flight, x, y, 1)
												end
											end
										end
										self.speed = math.min(800, self.speed + (400 + self.speed) * dt)
										return self
									end
					local oy = 0
					local dam = 0
					if actor.state == 'cast' then 
						oy = actor.weapon.castOy
						dam = 45 + game.actorGetWeaponDamage(actor)
					end
					game.addProjectile({img = data.img.weapon.lightbolt, tracking = true, update = update, flight = 'lightflight', x = actor.x + actor.weaponAction.x, y = actor.y + actor.weaponAction.y + oy, rot = angle, drot = angle, speed = 5, nohit = 0.05, dam = dam, dtype = 'magic', team = actor.team, stun = actor.weapon.stundam, bdam = actor.weapon.bdam, knockback = actor.weapon.knockback})
				end,
}

spells.starshard = {
	name = 'starshard',
	dname = 'Star Shard',
	type = 'sorcery',
	icon = love.graphics.newImage("/dat/img/playerType/starshardicon.png"),
	casts = 30,
	castTime = 0.20,
	castPart = 'magiccast',
	slot = 'spell',
	desc = 'Nearby matter is condensed by a catalyst to create the shard of a star.  \n\nSpells must be attuned at a cryogenic pod and then require a staff to catalyze.',
	affect = 'Casts a homing star shard that tracks your enemies.',
	onCast =	function (game, actor, angle, data)
					if actor.state ~= 'cast' then return end
					local update =  function (self, dt, data)
										if not self.onCreate then 
											self.onCreate = true 
											for x = self.x - 3, self.x + 3, 1 do 
												for y = self.y - 3, self.y + 3, 1 do
													data.game.emitParticlesAt(self.flight, x, y, 1)
												end
											end
										end
										self.speed = math.min(400, self.speed + (250 + self.speed) * dt)
										return self
									end
					local oy = 0
					local dam = 0
					if actor.state == 'cast' then 
						oy = actor.weapon.castOy
						dam = 45 + game.actorGetWeaponDamage(actor) * 5
					end
					game.addProjectile({img = data.img.weapon.starshard, tracking = true, update = update, flight = 'magicflight', x = actor.x + actor.weaponAction.x, y = actor.y + actor.weaponAction.y + oy, rot = angle, drot = angle, speed = 5, nohit = 0.05, dam = dam, dtype = 'magic', team = actor.team, stun = actor.weapon.stundam, bdam = actor.weapon.bdam, knockback = actor.weapon.knockback})
				end,
}

spells.snapfire = {
	name = 'snapfire',
	dname = 'Snapfires',
	type = 'pyromancy',
	icon = love.graphics.newImage("/dat/img/playerType/snapfireicon.png"),
	casts = 30,
	castTime = -2,
	castPart = 'firecast',
	slot = 'spell',
	desc = 'Throws a conjured ball of flame that erupts upon contact.  Pyormancys require a flame to cast.',
	affect = 'Conjures a ball of flame that explodes upon contact.',
	onCast =	function (game, actor, angle, data)
					if actor.state ~= 'pyro' then return end
					local oy = 0
					local dam = 0
					local cox = 0
					local coy = 0
					if actor.dir == 'west' then 

					end
					if actor.state == 'pyro' then 
						oy = actor.offhand.castOy
						dam = 100 + game.actorGetOffhandDamage(actor) * 5
					end
					game.emitParticlesAt('fireexo2', actor.x + math.cos(angle) * 20, actor.y + math.sin(angle) * 20, 300)
					game.addHurtbox(1, actor.x - 15 + math.cos(angle) * 20 + cox, actor.y - 15 + math.sin(angle) * 20 + coy, 30, 30, 0.08, dam, 'fire', actor.x, actor.y, 0.35, 15, -0.2)
				end,
}

spells.fireball = {
	name = 'fireball',
	dname = 'Fireball',
	type = 'pyromancy',
	icon = love.graphics.newImage("/dat/img/playerType/fireballicon.png"),
	casts = 15,
	castTime = 0.35,
	castPart = 'firecast',
	slot = 'spell',
	desc = 'Throws a conjured ball of flame that erupts upon contact.  Pyormancys require a flame to cast.',
	affect = 'Conjures a ball of flame that explodes upon contact.',
	onCast =	function (game, actor, angle, data)
					if actor.state ~= 'pyro' then return end
					local onDestroy =	function (self, dt, data)
											data.game.emitParticlesAt('fireexo', self.x, self.y, 300)
											data.game.addHurtbox(1, self.x - 20, self.y - 20, 40, 40, 0.08, self.dam * 0.5, self.dtype, self.x, self.y, self.stun, self.bdam, -0.2)
										end
					local update =  function (self, dt, data)
										if not self.checkForTargetCD then 
											self.checkForTargetCD = 0
										end
										if not self.tween then 
											self.tween = 0.25
										end
										data.game.emitParticlesAt(self.flight, self.x - 1, self.y, 1)
										data.game.emitParticlesAt(self.flight, self.x + 1, self.y, 1)
										data.game.emitParticlesAt(self.flight, self.x, self.y - 1, 1)
										data.game.emitParticlesAt(self.flight, self.x, self.y + 1, 1)
										self.tween = self.tween - dt
										self.checkForTargetCD = self.checkForTargetCD - dt
										if not self.onCreate then 
											self.onCreate = true 
											for x = self.x - 3, self.x + 3, 1 do 
												for y = self.y - 3, self.y + 3, 1 do
													data.game.emitParticlesAt(self.flight, x, y, 1)
												end
											end
										end
										if not self.target and self.checkForTargetCD <= 0 then 
											self.target = game.getActorClosestToCursor()
											self.checkForTargetCD = 0.15
										elseif self.target then
											local ang = math.atan2(self.target.y - self.y, self.target.x - self.x)
											local dang = math.pi
											local tang = self.rot - ang 
											local otang = ang - ang 
											repeat
												if tang < 0 then 
													tang = tang + math.pi * 2 
												elseif tang > math.pi * 2 then 
													tang = tang - math.pi * 2 
												end
											until tang >= 0 and tang <= math.pi * 2 
											if tang < math.pi then 
												dang = -math.pi 
											else 
												dang = math.pi 
											end
											self.rot = self.rot + dang * dt
											self.drot = self.rot
										end
										if self.tween > 0 then 
											self.speed = math.min(400, self.speed + (250 + self.speed) * dt)
										else
											self.speed = math.min(400, self.speed - (250 + self.speed) * dt)
										end
										if self.speed <= 25 then 
											self.DESTROY = true 
											--team, x, y, w, h, dur, dam, dtype, sx, sy, stun, bdam, shieldBreaker
										end
										return self
									end
					local oy = 0
					local dam = 0
					if actor.state == 'pyro' then 
						oy = actor.offhand.castOy
						dam = 100 + game.actorGetOffhandDamage(actor) * 5
					end
					game.addProjectile({img = data.img.weapon.fireball, update = update, onDestroy = onDestroy, flight = 'fireflight', x = actor.x + actor.offhandAction.x, y = actor.y + actor.offhandAction.y + oy, rot = angle, drot = angle, speed = 150, nohit = 0.05, dam = dam, dtype = 'magic', team = actor.team, stun = actor.weapon.stundam, bdam = actor.weapon.bdam, knockback = actor.weapon.knockback})
				end,
}

return spells