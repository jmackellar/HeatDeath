local game = { }
local anim8 = require("/lib/anim8")

--- Data
local weapons = false
local armor = false
local enemyType = false
local rings = false
local items = false
local spells = false
local particles = false

--- Vars
local actors = { }
local anims = { }
local hurtbox = { }
local projectiles = { }
local particles = { }
local decals = { }
local map = { }
local dead = { }
local permDead = { }
local unloadedActors = { }
local unloadedDecals = { }
local bigText = { }
local matterShards = { }
local residualLights = { }
local inventory = { }
local locations = { }
local mapItems = { }
local mapItemsFound = { }
local itemPickupPrompt = { }
local grapplePoints = { }
local gibs = { }
local unloadedGibs = { }
local cursorLockon = false
local actorCanvas = false
local invFilter = false
local matterDrop = false
local curMap = false
local playerTran = false
local menu = false
local menuAction = false
local canvas = false
local sti = false
local player = false
local camera = false
local scarletLib = false
local bump = false
local world = false
local mapWidth = 100
local mapHeight = 100
local timeOut = 0
local lightpow = 200
local avglightpow = 200
local lightpowcd = 0
local lightpowdt = 1
local screenShakeVal = 0
local respawnHaze = 0
local mapFade = 255
local hudFade = 255
local lastSpawn = false
local curWorld = false
local invup = 0
local blockAction = 0
local lightCD = -1
local lightIMG = love.image.newImageData(200, 2)
local lightFogIMG = false
local lightLevelMap = false
local reloadMapOnGameFirstStart = true
local foundStaticMapLights = false
local lightMapWidth = 0
local staticMapLights = 0
local mapDropFade = 255
local mapDropDF = 350

--- Assets
local img = { }	
local animations = { }

---
--- Shaders
---
local twinkleStar = love.graphics.newShader[[
	extern number modulo;
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
		vec4 pixel = Texel(texture, texture_coords);
		if (mod(floor(texture_coords.x * 100), modulo) == 0){
			pixel.r = pixel.r * 1.25;
			pixel.g = pixel.g * 1.25;
			pixel.b = pixel.b * 1.25;
		} 
		return pixel;
	}
]]

local actorColor = love.graphics.newShader[[
	extern number x;
	extern number r;
	extern number g;
	extern number b;
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
		vec4 pixel = Texel(texture, texture_coords);
		if (pixel.r == 1 && pixel.g == 1 && pixel.b == 1){
			pixel.r = r + ((cos(x + texture_coords.y) + 1 - texture_coords.y - 0.5) / 9);
			pixel.g = g + ((cos(x + texture_coords.y) + 1 - texture_coords.y - 0.5) / 9);
			pixel.b = b + ((cos(x + texture_coords.y) + 1 - texture_coords.y - 0.5) / 9);
			//pixel.r = min(0.75, max(0.35, sin(x + texture_coords.y) + 1.2 - (texture_coords.y - 0.1)));
			//pixel.g = min(0.75, max(0.35, cos(x + texture_coords.y) + 1.2 - (texture_coords.y - 0.5)));
			//pixel.b = min(0.75, max(0.35, sin(x + texture_coords.y) + 1.2 - (texture_coords.y - 0.75)));
		}
		return pixel;
	}
]]

local actorMatterIntake = love.graphics.newShader[[
	extern number x;
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
		vec4 pixel = Texel(texture, texture_coords);
		if (pixel.r == 1 && pixel.g == 1 && pixel.b == 1){
			pixel.r = min(0.75, max(0.35, sin(x + texture_coords.y) + 1.2 - (texture_coords.y - 0.1)));
			pixel.g = min(0.45, max(0.15, cos(x + texture_coords.y) + 1.2 - (texture_coords.y - 0.5)));
			pixel.b = min(1, max(0.35, sin(x + texture_coords.y) + 1.2 - (texture_coords.y - 0.75)));
		}
		return pixel;
	}
]]

local replaceColor = love.graphics.newShader[[
	// Replaces any white pixels with passed r,g,b color values
	extern number r;
	extern number g;
	extern number b;
	//Effect
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
	vec4 pixel = Texel(texture, texture_coords );
	if (pixel.r == 1 && pixel.g == 1 && pixel.b == 1){
		pixel.r = r;
		pixel.g = g;
		pixel.b = b;
	}
	return pixel;
}
]]

local colorWhite = love.graphics.newShader[[
	//Effect
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
	vec4 pixel = Texel(texture, texture_coords );
	pixel.r = 1;
	pixel.g = 1;
	pixel.b = 1;
	return pixel;
}
]]

local fog = love.graphics.newShader[[
	extern Image map;
	extern number w;
	extern number screenwidth;
	extern number screenheight;
	extern number lightpow;
	//Effect
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
   	vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
   	vec4 mp = Texel(map, vec2(1 * 0.005, 0));
   	vec4 mc = Texel(map, vec2(1 * 0.005, 1));
   	vec4 colorr = vec4(0,0,0,0);
   	vec2 info = vec2(0, (pixel.r + pixel.g + pixel.b) * 0.33);
   	for (number i = 0; i < w; i++){
   		mp = Texel(map, vec2(i * 0.005, 0));
   		mc = Texel(map, vec2(i * 0.005, 1));
   		info.x = (mp.b * ((mp.b * 510) + 1)) * pow(sqrt(pow(((mp.r * screenwidth) - 300) - screen_coords.x, 2) + pow(((mp.g * screenheight) - 300) - screen_coords.y, 2)) / lightpow, 2);
   		colorr.x = max(-min(max(info.x * info.y, mc.r), pixel.r * 0.99) + pixel.r, colorr.x * 1);
   		colorr.y = max(-min(max(info.x * info.y, mc.g), pixel.g * 0.99) + pixel.g, colorr.y * 1);
   		colorr.z = max(-min(max(info.x * info.y, mc.b), pixel.b * 1.1) + pixel.b, colorr.z * 1);
   	}
    pixel.rgb = colorr.xyz;
   	return pixel;
 	}
]]

---
--- Love2D Callbacks
---
function game.update(dt)
	if reloadMapOnGameFirstStart then 
		map = game.loadMap(curMap)
		reloadMapOnGameFirstStart = false
	end
	mapFade = math.max(0, mapFade - 500 * dt)
	hudFade = math.max(0, hudFade - 500 * dt)
	mapDropFade = math.min(255, math.max(0, mapDropFade + mapDropDF * dt))
	if timeOut > 0 then 
		timeOut = timeOut - dt 
		return
	end
	game.playerInput(dt)
	game.updateActors(dt)
	game.updatePlayer(dt)
	game.updateProjectiles(dt)
	game.updateAnimations(dt)
	game.updateHurtbox(dt)
	game.updateCamera(dt)
	game.updateParticles(dt)
	game.playerUpdateHud(dt)
	game.updateLightPower(dt)
	game.updateBigText(dt)
	game.updateMatterShards(dt)
	game.updateMatterDrop(dt)
	game.updateResidualLights(dt)
	game.updateFog(dt)
	game.playerUpdateCursor(dt)
	game.updateMapItems(dt)
	game.updateGibs(dt)
	scarletLib.layout.update(dt)	
end

function game.draw()
	camera:attach()
	love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	game.drawBackground()
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	love.graphics.draw(mapCanvasUnder, 0, 0)
	game.drawMatterDrop()
	game.drawDecals()
	game.drawParticlesUnder()
	game.drawGibs()
	game.drawMapItems()
	game.drawActors()
	game.drawMatterShards()
	game.drawAnimations()
	game.drawProjectiles()
	game.drawParticles()
	love.graphics.draw(mapCanvasOver, 0, 0)
	game.drawMapCeilingDynamic()
	if getDEBUG() then 
		game.drawDebug()
	end
	camera:detach()
	love.graphics.setCanvas()
	local iimg, width = game.drawLight()
	--- Draw Fade
	love.graphics.setColor(0, 0, 0, mapFade)
	love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(255, 255, 255, 255)
	--- draw hud
	game.drawBossBar()
	game.drawBigText()
	scarletLib.layout.draw() 
	game.drawHudParticles()
	game.playerDrawSpellHUD()
	game.drawPickupPrompt()
	game.playerDrawCrusor()
	--- Draw Hud Fade
	love.graphics.setColor(0, 0, 0, hudFade)
	love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(255, 255, 255, 255)
	--- debug light level map
	if DEBUG then 
		love.graphics.setScissor(100, 100, width * 10, 20)
		love.graphics.draw(iimg, 100, 100, 0, 10, 10)
		love.graphics.setScissor()
	end
	--- border
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('line', 1, 1, love.graphics.getWidth() - 1, love.graphics.getHeight() - 1)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setScissor()
end

function game.keypressed(key, scancode, isrepeat)
	if getDEBUG() then game.debugKey(key, isrepeat) end
	--- item pickup
	if # itemPickupPrompt > 0 and key == 'space' and itemPickupPrompt[1].dt >= 0.15 then 
		itemPickupPrompt[1].dfade = -1
		return 
	end
	--- menu
	if player.cryopod <= 0 and key == 'c' and not isrepeat then 
		menuAction = false
		if menu == 'character' then 
			menu = false 
			game.playSound('menuclose', player.x, player.y)
			scarletLib.layout.changeElementGroup('charframe', 'disabled', true)
			scarletLib.layout.changeElementGroup('weightframe', 'disabled', true)
		else
			menu = 'character'
			game.playSound('menuopen', player.x, player.y)
			scarletLib.layout.changeElementGroup('weightframe', 'disabled', true)
			scarletLib.layout.changeElementGroup('charframe', 'disabled', false)
			scarletLib.layout.changeElementGroup('equipment', 'disabled', true)
			scarletLib.layout.changeElementGroup('inventory', 'disabled', true)
			scarletLib.layout.changeElementGroup('inv', 'disabled', true)
		end
	elseif player.cryopod <= 0 and key == 'x' and not isrepeat then 
		menuAction = false
		if menu == 'equipment' then 
			menu = false 
			game.playSound('menuclose', player.x, player.y)
			scarletLib.layout.changeElementGroup('equipment', 'disabled', true)
			scarletLib.layout.changeElementGroup('weightframe', 'disabled', true)
		else 
			menu = 'equipment'
			game.playSound('menuopen', player.x, player.y)
			scarletLib.layout.changeElementGroup('equipment', 'disabled', false)
			scarletLib.layout.changeElementGroup('weightframe', 'disabled', false)
			scarletLib.layout.changeElementGroup('charframe', 'disabled', true)
			scarletLib.layout.changeElementGroup('inventory', 'disabled', true)
			scarletLib.layout.changeElementGroup('inv', 'disabled', true)
		end
	elseif player.cryopod <= 0 and key == 'z' and not isrepeat then 
		menuAction = false
		if menu == 'inventory' then 
			menu = false 
			game.playSound('menuclose', player.x, player.y)
			scarletLib.layout.changeElementGroup('inventory', 'disabled', true)
			scarletLib.layout.changeElementGroup('inv', 'disabled', true)
			scarletLib.layout.changeElementGroup('weightframe', 'disabled', true)
		else
			menu = 'inventory'
			invFilter = false
			game.playSound('menuopen', player.x, player.y)
			scarletLib.layout.changeElementGroup('weightframe', 'disabled', true)
			scarletLib.layout.changeElementGroup('charframe', 'disabled', true)
			scarletLib.layout.changeElementGroup('equipment', 'disabled', true)
			scarletLib.layout.changeElementGroup('inventory', 'disabled', false)
			scarletLib.layout.changeElementGroup('inv', 'disabled', false)
		end
	elseif key == 'tab' and menu == 'inventory' then 
		if not menuAction or not menuAction.itemdesc then 
			if not menuAction then 
				menuAction = { } 
			end
			menuAction.itemdesc = true 
		else
			menuAction.itemdesc = false 
		end
	elseif key == 'tab' and not menu then 
		if not playerLockon then 
			playerLockon = true 
		else 
			playerLockon = false 
		end
	elseif key == 'e' then 
		player.attuneSlotFocus = player.attuneSlotFocus + 1 
		if player.attuneSlotFocus > # player.attunement then 
			player.attuneSlotFocus = 1 
		end
	end
end

function game.mousepressed(x, y, button)
	if scarletLib.layout.mousepressed(x, y, button) then 
	end
end

---
--- Load
---
function game.load()
	--- Load assets
	game.loadAssets()
	--- Turn off particles
	for k,v in pairs(particles) do
		v:stop()
	end
	--- Load libraries
	canvas = love.graphics.newCanvas(love.graphics.getWidth() * 2, love.graphics.getHeight() * 2)
	scarletLib = getScarletLib()
	camera = getCamera()(100, 100)
	camera:zoomTo(3)
	bump = getBump()
	sti = getSTI()
	world = bump.newWorld(128)
	actorCanvas = love.graphics.newCanvas(love.graphics.getWidth() * 2, love.graphics.getHeight() * 2)
	--- Load data
	local chunk = love.filesystem.load("dat/weapons.lua")
	weapons = chunk()
	chunk = love.filesystem.load("dat/spells.lua")
	spells = chunk()
	chunk = love.filesystem.load("dat/armor.lua")
	armor = chunk()
	chunk = love.filesystem.load("dat/enemyType.lua")
	enemyType = chunk()
	chunk = love.filesystem.load("dat/locations.lua")
	locations = chunk()
	chunk = love.filesystem.load("dat/ring.lua")
	rings = chunk()
	chunk = love.filesystem.load("dat/item.lua")
	items = chunk()
	chunk = love.filesystem.load("dat/particles.lua")
	particles = chunk()
	--- Classes 
	local class = {
		knight = {
			type = 'actor',
			playerType = true,
			team = 1,
			level = 10,
			acceleration = 580,
			deceleration = 500,
			maxSpeed = 60,
			player = true, 
			color = {135, 235, 255},
			healsCur = 2,
			healsMax = 2,
			darkMatter = 99,
			ai = 'none',
			vitality = 15,
			endurance = 14,
			stability = 12,
			strength = 10,
			dexterity = 12,
			intelligence = 4,
			soulpower = 6,
			wisdom = 4,
			weapon = weapons.shortsword,
			offhand = weapons.kiteshield,
			armorHead = armor.knighthelm,
			armorChest = armor.knightchest,
		},
		mercenary = {
			type = 'actor',
			playerType = true,
			team = 1,
			level = 7,
			acceleration = 580,
			deceleration = 500,
			maxSpeed = 60,
			player = true, 
			color = {244, 236, 139},
			healsCur = 2,
			healsMax = 2,
			darkMatter = 99,
			ai = 'none',
			vitality = 12,
			endurance = 11,
			stability = 12,
			strength = 15,
			dexterity = 13,
			intelligence = 4,
			soulpower = 6,
			wisdom = 5,
			weapon = weapons.battleaxe,
			armorChest = armor.leathervest,
			armorHead = armor.skullcap,
		},
		thief = {
			type = 'actor',
			playerType = true,
			team = 1,
			level = 9,
			acceleration = 580,
			deceleration = 500,
			maxSpeed = 60,
			player = true, 
			color = {153, 222, 104},
			healsCur = 2,
			healsMax = 2,
			darkMatter = 99,
			ai = 'none',
			vitality = 9,
			endurance = 12,
			stability = 10,
			strength = 10,
			dexterity = 16,
			intelligence = 5,
			soulpower = 4,
			wisdom = 5,
			weapon = weapons.rapier,
			armorChest = armor.leathervest,
			armorHead = armor.thiefmask,
		},
		sorcerer = {
			type = 'actor',
			playerType = true,
			team = 1,
			level = 5,
			acceleration = 580,
			deceleration = 500,
			maxSpeed = 60,
			player = true, 
			color = {215, 166, 255},
			healsCur = 2,
			healsMax = 2,
			darkMatter = 99,
			ai = 'none',
			vitality = 7,
			endurance = 5,
			stability = 4,
			strength = 6,
			dexterity = 8,
			intelligence = 15,
			soulpower = 6,
			wisdom = 10,
			weapon = weapons.staff,
			offhand = weapons.stiletto,
			armorChest = armor.robe,
			armorHead = armor.hood,
			attunementSlots = 0,
			attunement = {
				{spell = spells.starshard, casts = spells.starshard.casts, stackable = false, stack = 1},
				{spell = spells.heavystarshard, casts = spells.heavystarshard.casts, stackable = false, stack = 1},
			}
		},
		pyro = {
			type = 'actor',
			playerType = true,
			team = 1,
			level = 7,
			acceleration = 580,
			deceleration = 500,
			maxSpeed = 60,
			player = true, 
			color = {255, 179, 128},
			healsCur = 2,
			healsMax = 2,
			darkMatter = 99,
			ai = 'none',
			vitality = 9,
			endurance = 6,
			stability = 6,
			strength = 10,
			dexterity = 8,
			intelligence = 6,
			soulpower = 9,
			wisdom = 10,
			weapon = weapons.smallclub,
			offhand = weapons.pyroflame,
			armorChest = armor.heavycoat,
			armorHead = armor.leatherhat,
			attunementSlots = 0,
			attunement = {
				{spell = spells.fireball, casts = spells.fireball.casts, stackable = false, stack = 1},
				{spell = spells.snapfire, casts = spells.snapfire.casts, stackable = false, stack = 1},
			}
		},
		deprived = {
			type = 'actor',
			playerType = true,
			team = 1,
			level = 1,
			acceleration = 580,
			deceleration = 500,
			maxSpeed = 60,
			player = true, 
			color = {255, 133, 180},
			healsCur = 2,
			healsMax = 2,
			darkMatter = 99,
			ai = 'none',
			vitality = 10,
			endurance = 10,
			stability = 10,
			strength = 10,
			dexterity = 10,
			intelligence = 10,
			soulpower = 10,
			wisdom = 10,
			weapon = weapons.smallclub,
		},
	}
	--- Setup intial player actor
	player = game.newActor(class.thief)
	player.matter = 100000
	game.setupInventory()
	game.addActor(player)
	game.playerSetupHud()
	map = game.loadMap('test4')
end

function game.loadAssets()
	--- Load snds
	snd = { }
	snd['footStepDirt'] = love.audio.newSource("/dat/snd/footStepDirt.wav")
	snd['swing1'] = love.audio.newSource("/dat/snd/swing1.wav")
	snd['swing2'] = love.audio.newSource("/dat/snd/swing3.wav")
	snd['stab1'] = love.audio.newSource("/dat/snd/stab1.wav")
	snd['crush1'] = love.audio.newSource("/dat/snd/crush1.wav")
	snd['bowpull1'] = love.audio.newSource("/dat/snd/bowpull1.wav")
	snd['bowshoot1'] = love.audio.newSource("/dat/snd/bowshoot1.wav")
	snd['hurt1'] = love.audio.newSource("/dat/snd/hurt1.wav")
	snd['matter'] = love.audio.newSource("/dat/snd/matter.wav")
	snd['menuopen'] = love.audio.newSource("/dat/snd/menuopen.wav")
	snd['menuclose'] = love.audio.newSource("/dat/snd/menuclose.wav")
	snd['buttonpressed'] = love.audio.newSource("/dat/snd/buttonpressed.wav")
	snd['buttonpressed2'] = love.audio.newSource("/dat/snd/buttonpressed2.wav")
	snd['cryodoor'] = love.audio.newSource("/dat/snd/cryodoor.wav")
	snd['fall'] = love.audio.newSource("/dat/snd/fall.wav")
	snd['heal'] = love.audio.newSource("/dat/snd/heal.wav")
	--- Load Image data
	img['playerType'] = { }
	img.playerType['crosshair'] = love.graphics.newImage("/dat/img/playerType/crosshair.png")
	img.playerType['circlehair'] = love.graphics.newImage("/dat/img/playerType/circlehair.png")
	img.playerType['cursor'] = love.graphics.newImage("/dat/img/playerType/cursor.png")
	img.playerType['headNorth'] = love.graphics.newImage("/dat/img/playerType/playerTypeHeadNorth.png")
	img.playerType['headSouth'] = love.graphics.newImage("/dat/img/playerType/playerTypeHeadSouth.png")
	img.playerType['headEast'] = love.graphics.newImage("/dat/img/playerType/playerTypeHeadEast.png")
	img.playerType['headWest'] = love.graphics.newImage("/dat/img/playerType/playerTypeHeadWest.png")
	img.playerType['bodySouth'] = love.graphics.newImage("/dat/img/playerType/playerTypeBodySouth.png")
	img.playerType['foot1'] = love.graphics.newImage("/dat/img/playerType/playerTypeFoot.png")
	img.playerType['foot2'] = love.graphics.newImage("/dat/img/playerType/playerTypeFoot2.png")
	img.playerType['drink'] = love.graphics.newImage("/dat/img/playerType/drink.png")
	img.playerType['gibsmall'] = love.graphics.newImage("/dat/img/playerType/gibsmall.png")
	img.playerType['gibmedium'] = love.graphics.newImage("/dat/img/playerType/gibmedium.png")
	img.playerType['giblarge'] = love.graphics.newImage("/dat/img/playerType/giblarge.png")
	img.playerType['woodgibsmall'] = love.graphics.newImage("/dat/img/map/prop/woodgibsmall.png")
	img.playerType['woodgibmedium'] = love.graphics.newImage("/dat/img/map/prop/woodgibmedium.png")
	img.playerType['woodgiblarge'] = love.graphics.newImage("/dat/img/map/prop/woodgiblarge.png")
	--- prop
	img['prop'] = { }
	img.prop['table1'] = love.graphics.newImage("/dat/img/map/prop/table1.png")
	--- Weapons
	img['weapon'] = { }
	img.weapon['grapple'] = love.graphics.newImage("dat/img/playerType/grapple.png")
	img.weapon['grapplinghook'] = love.graphics.newImage("/dat/img/playerType/grapplinghook.png")
	img.weapon['grapplinghookclosed'] = love.graphics.newImage("/dat/img/playerType/grapplinghookclosed.png")
	img.weapon['shortsword'] = love.graphics.newImage("/dat/img/playerType/sword.png")
	img.weapon['gargsword'] = love.graphics.newImage("/dat/img/playerType/gargsword.png")
	img.weapon['hand'] = love.graphics.newImage("/dat/img/playerType/hand.png")
	img.weapon['club1'] = love.graphics.newImage("/dat/img/playerType/club1.png")
	img.weapon['bosshand'] = love.graphics.newImage("/dat/img/playerType/bosshand.png")
	img.weapon['rapier'] = love.graphics.newImage("/dat/img/playerType/rapier1.png")
	img.weapon['staff1'] = love.graphics.newImage("/dat/img/playerType/staff1.png")
	img.weapon['pyromancy'] = love.graphics.newImage("/dat/img/playerType/pyromancy.png")
	img.weapon['greatsword'] = love.graphics.newImage("/dat/img/playerType/greatsword.png")
	img.weapon['bosshalberd'] = love.graphics.newImage("/dat/img/playerType/bosshalberd.png")
	img.weapon['longbow'] = love.graphics.newImage("/dat/img/playerType/bow.png")
	img.weapon['arrow'] = love.graphics.newImage("/dat/img/playerType/arrow.png")
	img.weapon['fireball'] = love.graphics.newImage("/dat/img/playerType/fireball.png")
	img.weapon['lightbolt'] = love.graphics.newImage("/dat/img/playerType/lightbolt1.png")
	img.weapon['starshard'] = love.graphics.newImage("/dat/img/playerType/starshard1.png")
	img.weapon['starshard2'] = love.graphics.newImage("/dat/img/playerType/starshard2.png")
	img.weapon['spear'] = love.graphics.newImage("/dat/img/playerType/spear.png")
	img.weapon['towershield'] = love.graphics.newImage("/dat/img/playerType/towershield.png")
	img.weapon['kiteshield'] = love.graphics.newImage("/dat/img/playerType/kiteshield.png")
	img.weapon['standardshield'] = love.graphics.newImage("/dat/img/playerType/standardshield.png")
	img.weapon['stiletto'] = love.graphics.newImage("/dat/img/playerType/stiletto.png")
	img.weapon['battleaxe'] = love.graphics.newImage("/dat/img/playerType/axe1.png")
	--- Armor
	img['armor'] = { }
	img.armor['leathervest'] = {
		north = love.graphics.newImage("/dat/img/playerType/armor/leathervestnorth.png"),
		south = love.graphics.newImage("/dat/img/playerType/armor/leathervestsouth.png"),
		east = love.graphics.newImage("/dat/img/playerType/armor/leathervesteast.png"),
		west = love.graphics.newImage("/dat/img/playerType/armor/leathervestwest.png"),
	}
	img.armor['leatherhat'] = {
		north = love.graphics.newImage("/dat/img/playerType/armor/leatherhatnorth.png"),
		south = love.graphics.newImage("/dat/img/playerType/armor/leatherhatsouth.png"),
		east = love.graphics.newImage("/dat/img/playerType/armor/leatherhateast.png"),
		west = love.graphics.newImage("/dat/img/playerType/armor/leatherhatwest.png"),
	}
	img.armor['robe'] = {
		north = love.graphics.newImage("/dat/img/playerType/armor/robenorth.png"),
		south = love.graphics.newImage("/dat/img/playerType/armor/robesouth.png"),
		east = love.graphics.newImage("/dat/img/playerType/armor/robeeast.png"),
		west = love.graphics.newImage("/dat/img/playerType/armor/robewest.png"),
	}
	img.armor['heavycoat'] = {
		north = love.graphics.newImage("/dat/img/playerType/armor/heavycoatnorth.png"),
		south = love.graphics.newImage("/dat/img/playerType/armor/heavycoatsouth.png"),
		east = love.graphics.newImage("/dat/img/playerType/armor/heavycoateast.png"),
		west = love.graphics.newImage("/dat/img/playerType/armor/heavycoatwest.png"),
	}
	img.armor['longheavycoat'] = {
		north = love.graphics.newImage("/dat/img/playerType/armor/longheavycoatnorth.png"),
		south = love.graphics.newImage("/dat/img/playerType/armor/longheavycoatsouth.png"),
		east = love.graphics.newImage("/dat/img/playerType/armor/longheavycoateast.png"),
		west = love.graphics.newImage("/dat/img/playerType/armor/longheavycoatwest.png"),
	}

	img.armor['hood'] = {
		north = love.graphics.newImage("/dat/img/playerType/armor/hoodnorth.png"),
		south = love.graphics.newImage("/dat/img/playerType/armor/hoodsouth.png"),
		east = love.graphics.newImage("/dat/img/playerType/armor/hoodeast.png"),
		west = love.graphics.newImage("/dat/img/playerType/armor/hoodwest.png"),
	}
	img.armor['skullcap'] = {
		north = love.graphics.newImage("/dat/img/playerType/armor/skullcapnorth.png"),
		south = love.graphics.newImage("/dat/img/playerType/armor/skullcapsouth.png"),
		east = love.graphics.newImage("/dat/img/playerType/armor/skullcapeast.png"),
		west = love.graphics.newImage("/dat/img/playerType/armor/skullcapwest.png"),
	}
	img.armor['thiefmask'] = {
		north = love.graphics.newImage("/dat/img/playerType/armor/thiefmasknorth.png"),
		south = love.graphics.newImage("/dat/img/playerType/armor/thiefmasksouth.png"),
		east = love.graphics.newImage("/dat/img/playerType/armor/thiefmaskeast.png"),
		west = love.graphics.newImage("/dat/img/playerType/armor/thiefmaskwest.png"),
	}
	img.armor['knighthelm'] = {
		north = love.graphics.newImage("/dat/img/playerType/armor/knighthelmnorth.png"),
		south = love.graphics.newImage("/dat/img/playerType/armor/knighthelmsouth.png"),
		east = love.graphics.newImage("/dat/img/playerType/armor/knighthelmeast.png"),
		west = love.graphics.newImage("/dat/img/playerType/armor/knighthelmwest.png"),
	}
	img.armor['knightchest'] = {
		north = love.graphics.newImage("/dat/img/playerType/armor/knightchestnorth.png"),
		south = love.graphics.newImage("/dat/img/playerType/armor/knightchestsouth.png"),
		east = love.graphics.newImage("/dat/img/playerType/armor/knightchesteast.png"),
		west = love.graphics.newImage("/dat/img/playerType/armor/knightchestwest.png"),
	}
	img.armor['tutbosschest'] = {
		north = love.graphics.newImage("/dat/img/playerType/armor/tutbossnorth.png"),
		south = love.graphics.newImage("/dat/img/playerType/armor/tutbosssouth.png"),
		east = love.graphics.newImage("/dat/img/playerType/armor/tutbosseast.png"),
		west = love.graphics.newImage("/dat/img/playerType/armor/tutbosswest.png"),
	}
	img.armor['tutbosshelm'] = {
		north = love.graphics.newImage("/dat/img/playerType/armor/tutbosshelmnorth.png"),
		south = love.graphics.newImage("/dat/img/playerType/armor/tutbosshelmsouth.png"),
		east = love.graphics.newImage("/dat/img/playerType/armor/tutbosshelmeast.png"),
		west = love.graphics.newImage("/dat/img/playerType/armor/tutbosshelmwest.png"),
	}
	--- BG
	img['bg'] = { }
	img.bg['space1'] = love.graphics.newImage("/dat/img/map/spacebg.png")
	img.bg['space2'] = love.graphics.newImage("/dat/img/map/spacebg2.png")
	img.bg['space3'] = love.graphics.newImage("/dat/img/map/spacebg3.png")
	--- interactable parts
	img['part'] = {  }
	img.part['matterShardSmall'] = love.graphics.newImage("/dat/img/part/mattershardSmall.png")
	img.part['mapitem'] = love.graphics.newImage("/dat/img/item/mapitem.png")
	--- hud
	img['hud'] = { }
	img.hud['heal'] = love.graphics.newImage("/dat/img/hud/heal.png")
	img.hud['healout'] = love.graphics.newImage("/dat/img/hud/healout.png")
	img.hud['slash'] = love.graphics.newImage("/dat/img/hud/slash.png")
	img.hud['thrust'] = love.graphics.newImage("/dat/img/hud/thrust.png")
	img.hud['crush'] = love.graphics.newImage("/dat/img/hud/crush.png")
	img.hud['magic'] = love.graphics.newImage("/dat/img/hud/magic.png")
	img.hud['fire'] = love.graphics.newImage("/dat/img/hud/fire.png")
	img.hud['solar'] = love.graphics.newImage("/dat/img/hud/solar.png")
	img.hud['empty'] = love.graphics.newImage("/dat/img/hud/empty.png")
	img.hud['inv'] = love.graphics.newImage("/dat/img/hud/inv.png")
	img.hud['itemtype'] = love.graphics.newImage("/dat/img/hud/itemtype.png")
	img.hud['weapon'] = love.graphics.newImage('/dat/img/hud/weapondam.png')
	img.hud['scaling'] = love.graphics.newImage("/dat/img/hud/scaling.png")
	img.hud['strength'] = love.graphics.newImage("/dat/img/hud/strength.png")
	img.hud['dexterity'] = love.graphics.newImage("/dat/img/hud/dexterity.png")
	img.hud['intelligence'] = love.graphics.newImage("/dat/img/hud/intelligence.png")
	img.hud['soulpower'] = love.graphics.newImage("/dat/img/hud/soul.png")
	img.hud['weight'] = love.graphics.newImage("/dat/img/hud/weight.png")
	img.hud['offtype'] = love.graphics.newImage("/dat/img/hud/offhandtype.png")
	img.hud['defense'] = love.graphics.newImage("/dat/img/hud/physical.png")
	img.hud['deflines4'] = love.graphics.newImage("/dat/img/hud/deflines4.png")
	img.hud['deflines5'] = love.graphics.newImage("/dat/img/hud/deflines5.png")
	img.hud['casts'] = love.graphics.newImage("/dat/img/hud/casts.png")
	img.hud['pickup'] = love.graphics.newImage("/dat/img/hud/pickup.png")
	--- Decals
	img['decal'] = { }
	img.decal['blood1'] = love.graphics.newImage("/dat/img/decal/blood1.png")
	img.decal['blood2'] = love.graphics.newImage("/dat/img/decal/blood2.png")
	img.decal['arrow'] = love.graphics.newImage("/dat/img/decal/arrow.png")
	img.decal['wooddebris1'] = love.graphics.newImage("/dat/img/decal/wooddebris1.png")
	--- Load animation image files
	img['animation'] = { }
	img.animation['swing1'] = love.graphics.newImage("/dat/img/playerType/swing1.png")
	img.animation['swing2'] = love.graphics.newImage("/dat/img/playerType/swing2.png")
	img.animation['swordsmash1'] = love.graphics.newImage("/dat/img/playerType/swordsmash1.png")
	img.animation['largeswing1'] = love.graphics.newImage("/dat/img/playerType/largeswing1.png")
	img.animation['arrowKnock'] = love.graphics.newImage("/dat/img/playerType/arrowKnockt.png")
	img.animation['stab1'] = love.graphics.newImage("/dat/img/playerType/stab1.png")
	img.animation['stab2'] = love.graphics.newImage("/dat/img/playerType/stab2.png")
	img.animation['stab3'] = love.graphics.newImage("/dat/img/playerType/stab3.png")
	img.animation['offstab1'] = love.graphics.newImage("/dat/img/playerType/offstab1.png")
	img.animation['matterDrop'] = love.graphics.newImage("/dat/img/map/matterDrop.png")
	img.animation['crystal1'] = love.graphics.newImage("/dat/img/map/crystal1.png")
	img.animation['galaxy1'] = love.graphics.newImage("/dat/img/map/galaxy1.png")
	--- Setup animations
	animations['swing1'] = anim8.newAnimation(anim8.newGrid(48, 48, 288, 48)('1-6',1), 0.06)
	animations['swing2'] = anim8.newAnimation(anim8.newGrid(48, 48, 288, 48)('1-6',1), 0.04)
	animations['swordsmash1'] = anim8.newAnimation(anim8.newGrid(96, 96, 576, 96)('1-6',1), 0.06)
	animations['largeswing1'] = anim8.newAnimation(anim8.newGrid(96, 96, 576, 96)('1-6',1), 0.06)
	animations['arrowKnock'] = anim8.newAnimation(anim8.newGrid(48, 48, 480, 48)('1-10',1), 0.06)
	animations['stab1'] = anim8.newAnimation(anim8.newGrid(48, 48, 240, 48)('1-5',1), 0.04)
	animations['stab2'] = anim8.newAnimation(anim8.newGrid(48, 48, 240, 48)('1-5',1), 0.04)
	animations['stab3'] = anim8.newAnimation(anim8.newGrid(48, 48, 240, 48)('1-5',1), 0.04)
	animations['offstab1'] = anim8.newAnimation(anim8.newGrid(48, 48, 240, 48)('1-5',1), 0.03)
	animations['matterDrop'] = anim8.newAnimation(anim8.newGrid(32, 32, 224, 32)('1-7',1), 0.15)
	animations['crystal1'] = anim8.newAnimation(anim8.newGrid(64, 64, 768, 64)('1-12',1), 0.12)
	animations['galaxy1'] = anim8.newAnimation(anim8.newGrid(64, 64, 768, 64)('1-12',1), 0.2)
	--- Success!!!
	print('[GAME] Assets succesfully loaded.')
end

function game.reloadMap(mapp)
	actors = { }
	decals = { }
	unloadedDecals = { }
	unloadedGibs = { }
	dead = { }
	mapItems = { }
	grapplePoints = { }
	map = sti("dat/map/" .. mapp .. ".lua")
	world = bump.newWorld()
	game.addActor(player)
	foundStaticMapLights = false
	--- set perm dead
	for k,v in pairs(permDead) do 
		dead[k] = v
	end
	--- setup test walls
	for k,v in pairs(map.objects) do
		if v.layer.name == 'blockall' or v.layer.name == 'blockmove' or v.layer.name == 'bg' then 
			local o = {type = v.layer.name, x = v.x, y = v.y, w = v.width, h = v.height}
			world:add(o, v.x, v.y, v.width, v.height)
		elseif v.type == 'grapple' then 
			table.insert(grapplePoints, {x = v.x, y = v.y})
		elseif v.layer.name == 'item' then 
			game.addMapItem(v)
		elseif v.layer.name == 'enemy' and not dead[v.name] then 
			local s = { }
			for k,v in pairs(enemyType[v.type]) do
				s[k] = v 
			end
			s.x = v.x + 4
			s.y = v.y + 10	
			s.name = v.name
			if s.weapon then 
				s.weapon = weapons[s.weapon]
			end
			if s.offhand then 
				s.offhand = weapons[s.offhand]
			end
			if s.armorChest then 
				s.armorChest = armor[s.armorChest]
			end
			if s.armorHead then 
				s.armorHead = armor[s.armorHead]
			end
			for k,v in pairs(v.properties) do
				s[k] = v
			end
			game.addActor(game.newActor(s))
		end
	end
	game.batchMapCanvas()
	return map
end

function game.loadMap(mapp)
	if curMap then 
		if not unloadedDecals[curMap] then 
			unloadedDecals[curMap] = { }
		end
		if not unloadedGibs[curMap] then 
			unloadedGibs[curMap] = { }
		end
		for i = 1, # decals do 
			table.insert(unloadedDecals[curMap], decals[i])
		end
		for i = 1, # gibs do 
			table.insert(unloadedGibs[curMap], gibs[i])
		end
		gibs = { }
		decals = { }
	end
	for k,v in pairs(particles) do
		v:reset()
	end
	curMap = mapp
	map = sti("dat/map/" .. mapp .. ".lua")
	actors = { }
	decals = unloadedDecals[curMap] or { }
	gibs = unloadedGibs[curMap] or { }
	world = bump.newWorld()
	anims = { }
	mapItems = { }
	grapplePoints = { }
	mapFade = 255
	foundStaticMapLights = false
	--- setup test walls
	for k,v in pairs(map.objects) do
		if v.layer.name == 'mapinfo' then 
			if v.name == 'spawn' and not playerTran then 
				lastSpawn = curMap
				player.x = v.x + 4
				player.y = v.y + 10
				game.addActor(player)
			elseif v.type == 'grapple' then 
				table.insert(grapplePoints, {x = v.x, y = v.y})
			elseif v.type == 'transition' and playerTran and playerTran.drop == v.name then 
				player.x = v.x + v.width / 2 + v.properties.dx
				player.y = v.y + v.height / 2 + v.properties.dy
				game.addActor(player)
			elseif v.type == 'world' then 
				if not curWorld or curWorld ~= v.name then 
					curWorld = v.name 
					game.addBigText({text = locations[v.name].text, subtext = locations[v.name].subtext, location = true, oy = -256, color = {255, 255, 255}, df = 1.25, fade = -75, dt = 7})
				end
			elseif v.type == 'anim' then 
				game.addAnimation(v.name, v.x, v.y, 0, 1, 1, true, v.properties)
			elseif v.type == 'ladder'  then 
				local o = {type = 'ladder', x = v.x, y = v.y, w = v.width, h = v.height}
				world:add(o, v.x, v.y, v.width, v.height)
			end
		elseif v.layer.name == 'item' then 
			game.addMapItem(v)
		elseif v.layer.name == 'blockall' or v.layer.name == 'blockmove' or v.layer.name == 'bg' then 
			local o = {type = v.layer.name, x = v.x, y = v.y, w = v.width, h = v.height}
			world:add(o, v.x, v.y, v.width, v.height)
		elseif v.layer.name == 'enemy' and not dead[v.name] then 
			local s = { }
			for k,v in pairs(enemyType[v.type]) do
				s[k] = v 
			end
			if s.weapon then 
				s.weapon = weapons[s.weapon]
			end
			if s.offhand then 
				s.offhand = weapons[s.offhand]
			end
			if s.armorChest then 
				s.armorChest = armor[s.armorChest]
			end
			if s.armorHead then 
				s.armorHead = armor[s.armorHead]
			end
			s.x = v.x + (s.hitBoxWidth or 8) / 2
			s.y = v.y + (s.hitBoxHeight or 20) / 2
			s.name = v.name
			for k,v in pairs(v.properties) do
				s[k] = v
			end
			game.addActor(game.newActor(s))
		end
	end
	game.snapCamera()
	game.batchMapCanvas()
	return map
end

---
--- Debug
---
function game.debugKey(key, isrepeat)
	if key == 'escape' then 
		love.event.push('quit')
	end
end

function game.drawDebug()
	--- Draw collision boxes
	local items, len = world:getItems()
	if len > 0 then 
		for i = 1, # items do 
			if items[i].type == 'actor' then 
				love.graphics.setColor(0, 175, 0, 255)
				love.graphics.rectangle('line', items[i].x - items[i].hitBoxWidth / 2, items[i].y - items[i].hitBoxHeight / 2, items[i].hitBoxWidth, items[i].hitBoxHeight)
				love.graphics.setColor(0, 0, 255, 255)
				love.graphics.rectangle('line', items[i].x - 3, items[i].y + 7, 6, 6)
			else
				love.graphics.setColor(100, 0, 0, 255)
				love.graphics.rectangle('line', items[i].x, items[i].y, items[i].w or 1, items[i].h or 1)
			end		
		end
		love.graphics.setColor(255, 255, 255, 255)
	end
	--- Hurtboxes
	game.drawHurtbox()
end

---
--- Player
---
function game.playerDrawCrusor()
	local mon = game.getActorClosestToCursor()
	local wmx, wmy = camera:worldCoords(love.mouse.getX(), love.mouse.getY())
	local dx, dy = false, false
	local d = false
	local iimg = img.playerType.crosshair 
	if playerLockon then 
		iimg = img.playerType.circlehair
	end
	if not player.backstab then 
		if not menu and # itemPickupPrompt == 0 then 
			if mon then 
				dx, dy = camera:cameraCoords(mon.x, mon.y)
				d = math.sqrt((mon.x - wmx)^2 + (mon.y - wmy)^2)
				if d <= 16 then 
					if game.actorGetBackstabAble(player) then
						love.graphics.setColor(255,0,0,200)
						love.graphics.circle('fill', dx, dy, 6)
						love.graphics.setColor(255,0,0,255)
						love.graphics.circle('fill', dx, dy, 4)
						love.graphics.setColor(255,0,0,255)
						love.graphics.draw(iimg, love.mouse.getX() + 1, love.mouse.getY() + 1, 0, 3, 3, 16, 16)
					else
						love.graphics.setColor(255,255,255,150)
						--love.graphics.circle('fill', dx, dy, 4)
						love.graphics.setColor(255,255,255,200)
						--love.graphics.circle('fill', dx, dy, 3)
						love.graphics.setColor(255,255,255,150)
						love.graphics.draw(iimg, love.mouse.getX() + 1, love.mouse.getY() + 1, 0, 3, 3, 16, 16)
					end
				elseif d <= 200 then
					love.graphics.setColor(200,200,200,150)
					--love.graphics.circle('fill', dx, dy, 3)
					love.graphics.setColor(255,255,255,200)
					--love.graphics.circle('fill', dx, dy, 2)
					love.graphics.setColor(255,255,255,150)
					love.graphics.draw(iimg, love.mouse.getX(), love.mouse.getY(), 0, 3, 3, 16, 16)
				else
					love.graphics.setColor(255,255,255,150)
					love.graphics.draw(iimg, love.mouse.getX(), love.mouse.getY(), 0, 3, 3, 16, 16)
				end
			else
				love.graphics.setColor(255,255,255,150)
				love.graphics.draw(iimg, love.mouse.getX(), love.mouse.getY(), 0, 3, 3, 16, 16)
			end
		else
			if # bigText > 0 then 
				iimg = img.playerType.crosshair
			else
				iimg = img.playerType.cursor
			end
			love.graphics.draw(iimg, love.mouse.getX(), love.mouse.getY(), 0, 3, 3, 16, 16)
		end
	end
	--- Grapple
	if player.state ~= 'grapple' then 
		for i = 1, # grapplePoints do 
			if grapplePoints[i].dd and grapplePoints[i].dd <= 32 and grapplePoints[i].dp >= 90 then 
				camera:attach()
				love.graphics.setColor(0, 255, 0, 95)
				love.graphics.circle('line', grapplePoints[i].x, grapplePoints[i].y, 2)
				love.graphics.circle('fill', grapplePoints[i].x, grapplePoints[i].y, 3)
				love.graphics.setColor(255, 255, 255, 255)
				camera:detach()
			elseif grapplePoints[i].dd and grapplePoints[i].dd <= 75 and grapplePoints[i].dp >= 90  then 
				camera:attach()
				love.graphics.setLineWidth(1)
				love.graphics.setColor(0, 255, 0, 125)
				love.graphics.circle('line', grapplePoints[i].x, grapplePoints[i].y, 2)
				love.graphics.setColor(255, 255, 255, 255)
				camera:detach()
			end
		end
	end
end

function game.playerUpdateCursor(dt)
	local mon = game.getActorClosestToCursor()
	local d = false
	local a = false
	if mon then 
		dx, dy = camera:cameraCoords(mon.x, mon.y)
		d = math.sqrt((dx - love.mouse.getX())^2 + (dy - love.mouse.getY())^2)
		if playerLockon then 
			if d <= 10 then 
				love.mouse.setX(dx)
				love.mouse.setY(dy)
			elseif d <= 200 then 
				a = math.atan2(dy - love.mouse.getY(), dx - love.mouse.getX())
				love.mouse.setX(love.mouse.getX() + math.cos(a) * (500 - d) * dt)
				love.mouse.setY(love.mouse.getY() + math.sin(a) * (500 - d) * dt)
			end
		end
	end
end

function game.playerInput(dt)
	if (# itemPickupPrompt > 0 and # bigText == 0) or player.inGrapple then 
		return 
	end
	blockAction = blockAction - dt 
	--- Movement
	if player.state == 'idle' or player.state == 'shield' or player.state == 'drink' or player.state == 'cast' or player.state == 'pyro' then 
		local acc = player.acceleration 
		if player.sprint > 0 then 
			acc = acc * 1.5
		end
		if love.keyboard.isDown('w') then 
			player.dy = player.dy - acc * dt
		elseif love.keyboard.isDown('s') then 
			player.dy = player.dy + acc * dt
		end
		if love.keyboard.isDown('a') then 
			player.dx = player.dx - acc * dt 
		elseif love.keyboard.isDown('d') then 
			player.dx = player.dx + acc * dt 
		end
	end
	--- roll
	if love.keyboard.isDown('space') and player.infall <= 0 then 
		if (player.state == 'idle' or player.state == 'shield') and player.staminaCur > 0 then 
			local mob = game.actorGetMobility(player)
			local invul = 0.24
			if mob == 'slow' then 
				invul = 0.17
			elseif mob == 'normal' then 
				invul = 0.2
			end
			player.dx = 0
			player.dy = 0
			if love.keyboard.isDown('w') then 
				player.dy = -1
			elseif love.keyboard.isDown('s') then 
				player.dy = 1
			end
			if love.keyboard.isDown('a') then 
				player.dx = -1
			elseif love.keyboard.isDown('d') then 
				player.dx = 1
			end
			if player.dx == 0 and player.dy == 0 then 
				local dir = {north = {0,1}, south = {0,-1}, east = {-1,0}, west = {1,0}}
				player.dx = dir[player.dir][1]
				player.dy = dir[player.dir][2]
			end
			if player.dx ~= 0 and player.dy ~= 0 then 
				player.dx = player.dx / 1.3
				player.dy = player.dy / 1.3
			end
			if player.dx < 0 then 
				player.dir = 'west'
			elseif player.dx > 0 then 
				player.dir = 'east' 
			elseif player.dy < 0 then 
				player.dir = 'north'
			elseif player.dy > 0 then 
				player.dir = 'south'
			end
			player.staminaCur = player.staminaCur - 25
			player.staminaGainCD = 1.5
			player.state = 'dodge'
			player.invul = invul
			player.stateTimer = 0.05
			player.statePhase = 0
		end
	end
	--- Light attack
	if love.mouse.isDown(1) and player.staminaCur > 0 and not menu then 
		game.actorUseMainhand(player)
	--- offhand
	elseif love.mouse.isDown(2) and player.staminaCur > 0 and not menu and player.offhand then 
		if player.state == 'idle' then 
			player.state = player.offhand.offattack[1]
			player.staminaCur = player.staminaCur - player.offhand.staminaCost 
			player.stateTimer = 0
			player.statePhase = 1
			player.stateCombo = 1
			if player.offhand.type == 'attack' then 
				player.staminaGainCD = 1.5
			end
		end
	elseif love.keyboard.isDown('f') and player.state == 'idle' and player.healsCur > 0 and player.hasPhotonicFlask then 
		player.state = 'drink'
		player.stateTimer = 0
		player.statePhase = 0
		player.stateCombo = 1
	end			
	--- sprint
	if love.keyboard.isDown('lshift') and player.staminaCur > 0 then 
		player.sprint = math.max(0, player.sprint + dt * 1.1)
	end
	if love.keyboard.isDown('g') then 
		game.playerDarkMatterIntake()
	end
	--- Grapple
	for i = 1, # grapplePoints do 
		local mx, my = love.mouse.getPosition()
		mx, my = camera:worldCoords(mx, my)
		grapplePoints[i].dd = math.sqrt((my - grapplePoints[i].y)^2 + (mx - grapplePoints[i].x)^2)
		grapplePoints[i].dp = math.sqrt((player.y - grapplePoints[i].y)^2 + (player.x - grapplePoints[i].x)^2) 
		if grapplePoints[i].dd <= 32 and love.keyboard.isDown('r') and not player.inGrapple and grapplePoints[i].dp >= 90 then 
			player.inGrapple = {state = 1, tx = grapplePoints[i].x, ty = grapplePoints[i].y, x = player.x, y = player.y}
		end
	end
end

function game.updatePlayer(dt)
	local drop = false
	if player.inGrapple then 
		player.state = 'grapple'
		local a = math.atan2(player.inGrapple.ty - player.y, player.inGrapple.tx - player.x)
		local gd = math.sqrt((player.inGrapple.y - player.inGrapple.ty)^2 + (player.inGrapple.x - player.inGrapple.tx)^2)
		if player.inGrapple.hookLanded then 
			if math.sqrt((player.y - player.inGrapple.ty)^2 + (player.x - player.inGrapple.tx)^2) <= 64 then 
				if player.inGrapple.x > player.x then 
					player.inGrapple.x = player.inGrapple.x - 150 * dt 
				else 
					player.inGrapple.x = player.inGrapple.x + 150 * dt 
				end
				if player.inGrapple.y > player.y then 
					player.inGrapple.y = player.inGrapple.y - 150 * dt 
				else 
					player.inGrapple.y = player.inGrapple.y + 150 * dt 
				end
				player.dx = player.dx * 0.92
				player.dy = player.dy * 0.92
				if math.abs(player.dx) <= 30 and math.abs(player.dy) <= 30 then
					player.inGrapple = false
					player.state = 'idle'
				end
			else
				player.inGrapple.accel = player.inGrapple.accel + 1
				if player.inGrapple.accel < 121 then 
					player.dx = player.dx + math.cos(a) * 400 * dt 
					player.dy = player.dy + math.sin(a) * 400 * dt 
				end
			end
		else 
			local ga = math.atan2(player.inGrapple.ty - player.inGrapple.y, player.inGrapple.tx - player.inGrapple.x)
			player.dx = 0
			player.dy = 0
			player.inGrapple.accel = 0
			player.inGrapple.x = player.inGrapple.x + math.cos(ga) * 450 * dt
			player.inGrapple.y = player.inGrapple.y + math.sin(ga) * 450 * dt
			if gd <= 10 then 
				player.inGrapple.hookLanded = true
				game.emitParticlesAt('dirt', player.inGrapple.x, player.inGrapple.y, 15)
			end
		end
	end
	if player.darkMatterIntakeCD and player.darkMatterIntakeCD > 0 and player.darkMatterIntake ~= 2 and not player.dead and not player.falling then 
		local partdrop = 5
		partdrop = math.max(1, math.ceil(5 * player.darkMatterIntakeCD))
		player.darkMatterIntakeCD = player.darkMatterIntakeCD - dt 
		game.emitParticlesAt('darkmatterintake', player.x, player.y, partdrop)
		if player.darkMatterIntakeCD <= 0 then 
			player.darkMatterIntake = 2
		end
	end
	if player.darkMatterIntake == 2 and not player.dead and not player.falling then 
		player.darkMatterIntakeCD = player.darkMatterIntakeCD - dt
		if player.darkMatterIntakeCD < 0 then 
			player.darkMatterIntakeCD = 0.2
			game.emitParticlesAt('darkmatterintake', player.x, player.y, 1)
		end
	end
	if player.cryopod > 96 and menu ~= 'levelup' and # itemPickupPrompt < 1 then 
		menu = 'cryo'
		scarletLib.layout.changeElementGroup('cryo', 'disabled', false)
		scarletLib.layout.changeElementGroup('charframe', 'disabled', true)
		scarletLib.layout.changeElementGroup('equipment', 'disabled', true)
		scarletLib.layout.changeElementGroup('inventory', 'disabled', true)
		scarletLib.layout.changeElementGroup('inv', 'disabled', true)
		scarletLib.layout.changeElementGroup('levelup', 'disabled', true)
	elseif player.cryopod <= 96 then
		if menu == 'cryo' or menu == 'levelup' then 
			menu = false 
			menuAction = false
			scarletLib.layout.changeElementGroup('cryo', 'disabled', true)
			scarletLib.layout.changeElementGroup('charframe', 'disabled', true)
			scarletLib.layout.changeElementGroup('equipment', 'disabled', true)
			scarletLib.layout.changeElementGroup('inventory', 'disabled', true)
			scarletLib.layout.changeElementGroup('inv', 'disabled', true)
			scarletLib.layout.changeElementGroup('levelup', 'disabled', true)
		end
	end
	if menu == 'levelup' then 
		scarletLib.layout.changeElementGroup('charframe', 'disabled', false)
		scarletLib.layout.changeElementGroup('levelup', 'disabled', false)
	end
	--- map trans
	for k,v in pairs(map.objects) do
		if v.layer.name == 'mapinfo' and v.type == 'transition' then 
			if player.x >= v.x and player.y >= v.y and player.x <= v.x + v.width and player.y <= v.y + v.height then 
				drop = true
				if not playerTran then 
					mapFade = mapFade + 2000 * dt
					if mapFade >= 255 then 
						playerTran = {map = v.properties.map, drop = v.properties.drop, dx = v.properties.dx, dy = v.properties.dy}
						map = game.loadMap(playerTran.map)
					end
				end
			end
		elseif v.layer.name == 'mapinfo' and v.type == 'revealDrop' then 
			if player.x >= v.x and player.y >= v.y and player.x <= v.x + v.width and player.y <= v.y + v.height then 
				mapDropDF = -350
			end
		elseif v.layer.name == 'mapinfo' and v.type == 'hideDrop' then 
			if player.x >= v.x and player.y >= v.y and player.x <= v.x + v.width and player.y <= v.y + v.height then 
				mapDropDF = 350
			end
		end
	end
	if not drop then 
		playerTran = false 
	end
	if player.healthCur <= 0 and # bigText == 0 then 
		mapFade = mapFade + 625 * dt 
		hudFade = hudFade + 625 * dt 
		if mapFade >= 255 then 
			if matterDrop then 
				matterDrop.spawnCd = -1 
			end
			player.healsCur = player.healsMax
			mapFade = 255
			hudFade = 255
			curMap = false
			dead = { }
			unloadedDecals = { }
			unloadedGibs = { }
			playerTran = false 
			player.dead = false 
			player.healthCur = game.actorGetHealthMax(player)
			player.staminaCur = game.actorGetStaminaMax(player)
			player.falling = false 
			player.sx = 1
			player.sy = 1
			respawnHaze = 0.08
			game.loadMap(lastSpawn)
			for k,v in pairs(permDead) do 
				dead[k] = v
			end
		end
	end
	if respawnHaze > 0 then 
		respawnHaze = respawnHaze - dt
		for i = 1, 50 do
			game.emitParticlesAt('cryoheal', love.math.random(0, love.graphics.getWidth()), love.graphics.getHeight() / 2, 5)
		end
	end
end

function game.playerDarkMatterIntake()
	player.darkMatterIntake = true 
	player.darkMatterIntakeCD = 1
	player.healthCur = player.healthCur * 1.3
	game.addBigText({text = 'Dark Matter Intake', subtext = 'The Dark Energy of Humanity Courses Through Your Soul', intake = true, oy = -256, color = {118, 66, 138}, df = 1.25, fade = -75, dt = 7})
end

function game.drawItemDesc(delete, type, itm)
	local hi = scarletLib.layout.getHilightedElement()
	local item = false
	local x = 400
	local y = 100
	local title = 'Item'
	local desc = false
	local t = {
		mainhand = 'Main Hand',
		offhand = 'Off Hand',
		head = 'Head',
		chest = 'Chest',
		ring = 'Ring',
		consume = 'Consumable',
		spell = 'Sorecery',
		pyro = 'Pyromancy',
		key = 'Unique Item',
	}
	if menuAction and menuAction.itemdesc then 
		desc = true
	end
	if type == 'curequip' then 
		x = x + 390
		title = 'Currently Equippied'
	end
	if hi then 
		if string.sub(hi.name, 1, 3) == 'inv' then 
			item = inventory[hi.prop]
		elseif string.sub(hi.name, 1, 5) == 'equip' then 
			if string.sub(hi.name, 6) == 'mainhandframe' then 
				item = {type = 'mainhand', item = player.weapon}
			elseif string.sub(hi.name, 6) == 'offhandframe' then 
				item = {type = 'offhand', item = player.offhand}
			elseif string.sub(hi.name, 6) == 'headframe' then 
				item = {type = 'head', item = player.armorHead}
			elseif string.sub(hi.name, 6) == 'chestframe' then 
				item = {type = 'chest', item = player.armorChest}
			elseif string.sub(hi.name, 6) == 'ring1frame' then 
				item = {type = 'ring', item = player.rings[1]}
			elseif string.sub(hi.name, 6) == 'ring2frame' then 
				item = {type = 'ring', item = player.rings[2]}
			elseif string.sub(hi.name, 6) == 'ring3frame' then 
				item = {type = 'ring', item = player.rings[3]}
			end
		end
	end
	if itm then 
		item = itm
	end
	if delete then 
		scarletLib.layout.deleteByGroup('item')
		scarletLib.layout.deleteFlaggedGroups()
	end
	if menuAction and menuAction.action == 'equip' and type ~= 'curequip' and item and menu == 'inventory' then 
		if menuAction.item == 'mainhand' and player.weapon then 
			game.drawItemDesc(false, 'curequip', {item = player.weapon, type = 'mainhand'})
		elseif menuAction.item == 'offhand' and player.offhand then 
			game.drawItemDesc(false, 'curequip', {item = player.offhand, type = 'offhand'})
		elseif menuAction.item == 'head' and player.armorHead then 
			game.drawItemDesc(false, 'curequip', {item = player.armorHead, type = 'head'})
		elseif menuAction.item == 'chest' and player.armorChest then 
			game.drawItemDesc(false, 'curequip', {item = player.armorChest, type = 'chest'})
		elseif menuAction.item == 'ring' and player.rings[menuAction.ringSlot] then 
			game.drawItemDesc(false, 'curequip', {item = player.rings[menuAction.ringSlot], type = 'ring'})
		end
	end
	if item and item.item then 
		scarletLib.layout.addFrame({
			name = 'itemframe1',
			group = 'item',
			x = x, 
			y = y,
			width = 390,
			height = 128,
			z = 11,
			style = 1,
		})	
		scarletLib.layout.addFrame({
			name = 'itemframe1titleframe',
			group = 'item',
			x = x + 366 / 2 - scarletLib.layout.getTextWidth(title, 'font1') * 1.5 / 2,
			y = y - 13,
			z = 10,
			width = scarletLib.layout.getTextWidth(title, 'font1') * 1.5 + 18,
			height = 34,
			style = 1,
		})
		scarletLib.layout.addText({
			name = 'itemframe1title',
			group = 'item',
			x = x + 386 / 2 - scarletLib.layout.getTextWidth(title, 'font1') * 1.5 / 2,
			y = y - 5,
			z = 9,
			font = 'font1',
			text = title,
			zoom = 1.5,
			color = {150, 150, 150, 255}
		})
		scarletLib.layout.addImage({
			name = 'itemicon',
			group = 'item',
			x = x + 10,
			y = y + 10,
			z = 8,
			sx = 3, 
			sy = 3,
			img = item.item.icon,
		})
		scarletLib.layout.addText({
			name = 'itemname',
			group = 'item',
			x = x + 70,
			y = y + 28,
			z = 8,
			zoom = 1.5,
			text = item.item.dname, 
			font = 'font1',
			color = {150, 150, 150},
		})
		scarletLib.layout.addImage({
			name = 'itemtypeicon',
			group = 'item',
			x = x + 10,
			y = y + 64,
			z = 8,
			sx = 3,
			sy = 3,
			img = img.hud.itemtype,
		})
		scarletLib.layout.addText({
			name = 'itemtypetext',
			group = 'item',
			x = x + 70,
			y = y + 82,
			z = 8,
			zoom = 1.5,
			text = t[item.type],
			font = 'font1',
			color = {150, 150, 150},
		})
		scarletLib.layout.addFrame({
			name = 'itemframe2',
			group = 'item',
			x = x, 
			y = y + 128,
			width = 390,
			height = 449,
			z = 11,
			style = 1,
		})
		local frametext = 'Attributes'
		if desc then 
			frametext = 'Descreption'
		end
		scarletLib.layout.addFrame({
			name = 'itemframe2titleframe',
			group = 'item',
			x = x + 366 / 2 - scarletLib.layout.getTextWidth(frametext, 'font1') * 1.5 / 2,
			y = y + 115,
			z = 10,
			width = scarletLib.layout.getTextWidth(frametext, 'font1') * 1.5 + 18,
			height = 34,
			style = 1,
		})
		scarletLib.layout.addText({
			name = 'itemframe2title',
			group = 'item',
			x = x + 386 / 2 - scarletLib.layout.getTextWidth(frametext, 'font1') * 1.5 / 2,
			y = y + 123,
			z = 9,
			font = 'font1',
			text = frametext,
			zoom = 1.5,
			color = {150, 150, 150, 255}
		})
		if menu == 'inventory' then 
			scarletLib.layout.addFrame({
				name = 'itemframe3titleframe',
				group = 'item',
				x = x + 366 / 2 - scarletLib.layout.getTextWidth('[TAB] - Switch', 'font1') * 1.5 / 2,
				y = y + 559,
				z = 10,
				width = scarletLib.layout.getTextWidth('[TAB] - Switch', 'font1') * 1.5 + 18,
				height = 34,
				style = 1,
			})
			scarletLib.layout.addText({
				name = 'itemframe3title',
				group = 'item',
				x = x + 386 / 2 - scarletLib.layout.getTextWidth('[TAB] - Switch', 'font1') * 1.5 / 2,
				y = y + 568,
				z = 9,
				font = 'font1',
				text = '[TAB] - Switch',
				zoom = 1.5,
				color = {150, 150, 150, 255}
			})
		end
		local t = {}
		local xx = x + 10
		local yy = y + 138
		if not desc then 
			if item.type == 'mainhand' or (item.type == 'offhand' and item.item.type == 'attack') then 
				local bdam, sdam = game.actorGetNonEquippedWeaponDamage(player, item.item)
				local hands = 'One Handed'
				local color = {255,255,255}
				if item.item.twohand then 
					hands = 'Two Handed'
				end
				if item.type == 'offhand' then 
					hands = 'Off Hand'
				end
				if menuAction and menuAction.item == 'mainhand' and type ~= 'curequip' and player.weapon then 
					if game.actorGetNonEquippedWeaponDamage(player, item.item) > game.actorGetWeaponDamage(player) then 
						color = {50, 50, 255}
					else
						color = {255, 50, 50}
					end
				end
				t[1] = {name = 'damtype', desc = game.firstToUpper(item.item.dtype), color = color, icon = img.hud[item.item.dtype], text = bdam .. ' + ' .. math.floor(sdam) .. ' (' .. bdam + math.floor(sdam) .. ')', ox = 0}
				if menuAction and menuAction.item == 'mainhand' and type ~= 'curequip' and player.weapon then 
					if item.item.twohand and not player.weapon.twohand then 
						color = {255, 50, 50}
					elseif not item.item.twohand and player.weapon.twohand then 
						color = {50, 50, 255}
					else 
						color = {255,255,255}
					end
				end
				t[2] = {name = 'dam', desc = 'Type', color = color, icon = img.hud.weapon, text = hands, ox = 0}
				if menuAction and menuAction.item == 'mainhand' and type ~= 'curequip' and player.weapon then 
					if item.item.bdam < player.weapon.bdam then 
						color = {255, 50, 50}
					elseif item.item.bdam > player.weapon.bdam then 
						color = {50, 50, 255}
					else 
						color = {255,255,255}
					end
				end
				t[3] = {name = 'scaling', desc = 'Scaling/Balance', color = color, icon = img.hud.scaling, text = item.item.bdam, ox = 0}
				if menuAction and menuAction.item == 'mainhand' and type ~= 'curequip' and player.weapon then 
					if item.item.scaling.strength  > player.weapon.scaling.strength then 
						color = {50, 50, 255}
					elseif item.item.scaling.strength == player.weapon.scaling.strength then 
						color = {255,255,255}
					else
						color = {255, 50, 50}
					end
				end
				t[4] = {name = 'strength', desc = 'Strength', color = color, icon = img.hud.strength, text = game.actorGetScaleGrade(item.item.scaling.strength), ox = 54}
				if menuAction and menuAction.item == 'mainhand' and type ~= 'curequip' and player.weapon then 
					if item.item.scaling.dexterity  > player.weapon.scaling.dexterity then 
						color = {50, 50, 255}
					elseif item.item.scaling.dexterity == player.weapon.scaling.dexterity then 
						color = {255,255,255}
					else
						color = {255, 50, 50}
					end
				end
				t[5] = {name = 'dexterity', desc = 'Dexterity', color = color, icon = img.hud.dexterity, text = game.actorGetScaleGrade(item.item.scaling.dexterity), ox = 54}
				if menuAction and menuAction.item == 'mainhand' and type ~= 'curequip' and player.weapon then 
					if item.item.scaling.intelligence  > player.weapon.scaling.intelligence then 
						color = {50, 50, 255}
					elseif item.item.scaling.intelligence == player.weapon.scaling.intelligence then 
						color = {255,255,255}
					else
						color = {255, 50, 50}
					end
				end
				t[6] = {name = 'intelligence', desc = 'Intelligence', color = color, icon = img.hud.intelligence, text = game.actorGetScaleGrade(item.item.scaling.intelligence), ox = 54}
				if menuAction and menuAction.item == 'mainhand' and type ~= 'curequip' and player.weapon then 
					if item.item.scaling.soulpower  > player.weapon.scaling.soulpower then 
						color = {50, 50, 255}
					elseif item.item.scaling.soulpower == player.weapon.scaling.soulpower then 
						color = {255,255,255}
					else
						color = {255, 50, 50}
					end
				end
				t[7] = {name = 'soulpower', desc = 'Soulpower', color = color, icon = img.hud.soulpower, text = game.actorGetScaleGrade(item.item.scaling.soulpower), ox = 54}
				if menuAction and menuAction.item == 'mainhand' and type ~= 'curequip' and player.weapon then 
					if item.item.weight < player.weapon.weight then 
						color = {50, 50, 255}
					else
						color = {255, 50, 50}
					end
				end
				t[8] = {name = 'weight', desc = 'Weight', color = color, icon = img.hud.weight, text = item.item.weight, ox = 0}
				scarletLib.layout.addImage({
					name = 'defline',
					group = 'item',
					x = xx + 24,
					y = yy + 159,
					z = 9,
					img = img.hud.deflines4,
				})
			elseif item.type == 'offhand' and item.item.type == 'block' then 
				local color = {255,255,255}
				if menuAction and menuAction.item == 'offhand' and type ~= 'curequip' and player.offhand then 
					if item.item.type == 'block' and player.offhand.type == 'block' and item.item.stability > player.offhand.stability then 
						color = {50, 50, 255}
					elseif item.item.type == 'block' and player.offhand.type == 'block' and item.item.stability < player.offhand.stability then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[1] = {name = 'type', desc = game.firstToUpper(item.item.type) .. '/Stability', color = color, icon = img.hud.offtype, text = item.item.stability, ox = 0}
				if menuAction and menuAction.item == 'offhand' and type ~= 'curequip' and player.offhand then 
					if item.item.type == 'block' and player.offhand.type == 'block' and item.item.block.slash > player.offhand.block.slash then 
						color = {50, 50, 255}
					elseif item.item.type == 'block' and player.offhand.type == 'block' and item.item.block.slash < player.offhand.block.slash then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[2] = {name = 'slash', desc = 'Slash', color = color, icon = img.hud.slash, text = item.item.block.slash, ox = 54}
				if menuAction and menuAction.item == 'offhand' and type ~= 'curequip' and player.offhand then 
					if item.item.type == 'block' and player.offhand.type == 'block' and item.item.block.thrust > player.offhand.block.thrust then 
						color = {50, 50, 255}
					elseif item.item.type == 'block' and player.offhand.type == 'block' and item.item.block.thrust < player.offhand.block.thrust then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[3] = {name = 'thrust', desc = 'Thrust', color = color, icon = img.hud.thrust, text = item.item.block.thrust, ox = 54}
				if menuAction and menuAction.item == 'offhand' and type ~= 'curequip' and player.offhand then 
					if item.item.type == 'block' and player.offhand.type == 'block' and item.item.block.crush > player.offhand.block.crush then 
						color = {50, 50, 255}
					elseif item.item.type == 'block' and player.offhand.type == 'block' and item.item.block.crush < player.offhand.block.crush then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[4] = {name = 'crush', desc = 'Crush', color = color, icon = img.hud.crush, text = item.item.block.crush, ox = 54}
				if menuAction and menuAction.item == 'offhand' and type ~= 'curequip' and player.offhand then 
					if item.item.type == 'block' and player.offhand.type == 'block' and item.item.block.magic > player.offhand.block.magic then 
						color = {50, 50, 255}
					elseif item.item.type == 'block' and player.offhand.type == 'block' and item.item.block.magic < player.offhand.block.magic then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[5] = {name = 'magic', desc = 'Magic', color = color, icon = img.hud.magic, text = item.item.block.magic, ox = 54}
				if menuAction and menuAction.item == 'offhand' and type ~= 'curequip' and player.offhand then 
					if item.item.type == 'block' and player.offhand.type == 'block' and item.item.block.fire > player.offhand.block.fire then 
						color = {50, 50, 255}
					elseif item.item.type == 'block' and player.offhand.type == 'block' and item.item.block.fire < player.offhand.block.fire then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[6] = {name = 'fire', desc = 'Fire', color = color, icon = img.hud.fire, text = item.item.block.fire, ox = 54}
				if menuAction and menuAction.item == 'offhand' and type ~= 'curequip' and player.offhand then 
					if item.item.type == 'block' and player.offhand.type == 'block' and item.item.block.solar > player.offhand.block.solar then 
						color = {50, 50, 255}
					elseif item.item.type == 'block' and player.offhand.type == 'block' and item.item.block.solar < player.offhand.block.solar then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[7] = {name = 'solar', desc = 'Light', color = color, icon = img.hud.solar, text = item.item.block.solar, ox = 54}
				if menuAction and menuAction.item == 'offhand' and type ~= 'curequip' and player.offhand then 
					if item.item.weight < player.offhand.weight then 
						color = {50, 50, 255}
					elseif item.item.weight > player.offhand.weight then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[8] = {name = 'weight', desc = 'Weight', color = color, icon = img.hud.weight, text = item.item.weight, ox = 0}
				scarletLib.layout.addImage({
					name = 'defline',
					group = 'item',
					x = xx + 24,
					y = yy + 51,
					z = 9,
					img = img.hud.deflines5,
				})
			elseif item.type == 'head' or item.type == 'chest' then
				local color = {255,255,255}
				local e = false 
				if menuAction and menuAction.item == 'head' and player.armorHead then 
					e = player.armorHead 
				elseif menuAction and menuAction.item == 'chest' and player.armorChest then 
					e = player.armorChest 
				end
				if menuAction and (menuAction.item == 'head' or menuAction.item == 'chest') and type ~= 'curequip' and e then 
					if item.item.balance > e.balance then 
						color = {50, 50, 255}
					elseif item.item.balance < e.balance then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[1] = {name = 'defense', desc = 'Defense/Balance', color = color, icon = img.hud.defense, text = item.item.balance, ox = 0}
				if menuAction and (menuAction.item == 'head' or menuAction.item == 'chest') and type ~= 'curequip' and e then 
					if item.item.defense.slash > e.defense.slash then 
						color = {50, 50, 255}
					elseif item.item.defense.slash < e.defense.slash then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[2] = {name = 'slash', desc = 'Slash', color = color, icon = img.hud.slash, text = item.item.defense.slash, ox = 54}
				if menuAction and (menuAction.item == 'head' or menuAction.item == 'chest') and type ~= 'curequip' and e then 
					if item.item.defense.thrust > e.defense.thrust then 
						color = {50, 50, 255}
					elseif item.item.defense.thrust < e.defense.thrust then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[3] = {name = 'thrust', desc = 'Thrust', color = color, icon = img.hud.thrust, text = item.item.defense.thrust, ox = 54}
				if menuAction and (menuAction.item == 'head' or menuAction.item == 'chest') and type ~= 'curequip' and e then 
					if item.item.defense.crush > e.defense.crush then 
						color = {50, 50, 255}
					elseif item.item.defense.crush < e.defense.crush then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[4] = {name = 'crush', desc = 'Crush', color = color, icon = img.hud.crush, text = item.item.defense.crush, ox = 54}
				if menuAction and (menuAction.item == 'head' or menuAction.item == 'chest') and type ~= 'curequip' and e then 
					if item.item.defense.magic > e.defense.magic then 
						color = {50, 50, 255}
					elseif item.item.defense.magic < e.defense.magic then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[5] = {name = 'magic', desc = 'Magic', color = color, icon = img.hud.magic, text = item.item.defense.magic, ox = 54}
				if menuAction and (menuAction.item == 'head' or menuAction.item == 'chest') and type ~= 'curequip' and e then 
					if item.item.defense.fire > e.defense.fire then 
						color = {50, 50, 255}
					elseif item.item.defense.fire < e.defense.fire then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[6] = {name = 'fire', desc = 'Fire', color = color, icon = img.hud.fire, text = item.item.defense.fire, ox = 54}
				if menuAction and (menuAction.item == 'head' or menuAction.item == 'chest') and type ~= 'curequip' and e then 
					if item.item.defense.solar > e.defense.solar then 
						color = {50, 50, 255}
					elseif item.item.defense.solar < e.defense.solar then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[7] = {name = 'solar', desc = 'Light', color = color, icon = img.hud.solar, text = item.item.defense.solar, ox = 54}
				if menuAction and (menuAction.item == 'head' or menuAction.item == 'chest') and type ~= 'curequip' and e then 
					if item.item.weight < e.weight then 
						color = {50, 50, 255}
					elseif item.item.weight > e.weight then 
						color = {255, 50, 50}
					else
						color = {255,255,255}
					end
				end
				t[8] = {name = 'weight', desc = 'Weight', color = color, icon = img.hud.weight, text = item.item.weight, ox = 0}
				scarletLib.layout.addImage({
					name = 'defline',
					group = 'item',
					x = xx + 24,
					y = yy + 51,
					z = 9,
					img = img.hud.deflines5,
				})
			elseif item.type == 'spell' or item.type == 'pyro' then 
				local text = item.item.affect 
				local width, text = scarletLib.layout.getFont('font1'):getWrap(text, 225)
				local ty = yy + 20
				t[8] = {name = 'casts', desc = 'Casts', icon = img.hud.casts, text = item.item.casts, ox = 0}
				for i = 1, # text do 
					if string.len(text[i]) > 0 then 
						scarletLib.layout.addText({
							x = xx + 22,
							y = ty,
							group = 'item',
							z = 9,
							zoom = 1.5, 
							text = text[i],
							font = 'font1',
							color = {150,150,150},
						})
						scarletLib.layout.addLine({
							x1 = xx + 10,
							y1 = ty + 20,
							x2 = xx + 360,
							y2 = ty + 20,
							z = 9,
							group = 'item',
							color = {100, 100, 100},
							fade = 150,
						})
						scarletLib.layout.addLine({
							x1 = xx + 30,
							y1 = ty + 20,
							x2 = xx + 320,
							y2 = ty + 20,
							z = 9,
							group = 'item',
							color = {100, 100, 100},
							fade = 200,
						})
					end
					ty = ty + 30
				end
			elseif item.type == 'consume' or item.type == 'key' then 
				local text = item.item.affect 
				local width, text = scarletLib.layout.getFont('font1'):getWrap(text, 225)
				local ty = yy + 20
				for i = 1, # text do 
					if string.len(text[i]) > 0 then 
						scarletLib.layout.addText({
							x = xx + 22,
							y = ty,
							group = 'item',
							z = 9,
							zoom = 1.5, 
							text = text[i],
							font = 'font1',
							color = {150,150,150},
						})
						scarletLib.layout.addLine({
							x1 = xx + 10,
							y1 = ty + 20,
							x2 = xx + 360,
							y2 = ty + 20,
							z = 9,
							group = 'item',
							color = {100, 100, 100},
							fade = 150,
						})
						scarletLib.layout.addLine({
							x1 = xx + 30,
							y1 = ty + 20,
							x2 = xx + 320,
							y2 = ty + 20,
							z = 9,
							group = 'item',
							color = {100, 100, 100},
							fade = 200,
						})
					end
					ty = ty + 30
				end
			elseif item.type == 'ring' then 
				local text = item.item.affect
				local width, text = scarletLib.layout.getFont('font1'):getWrap(text, 225)
				local ty = yy + 20
				i = 7 - # item.item.effects 
				for k,v in pairs(item.item.effects) do 
					t[i] = {name = k, desc = v.name, icon = v.icon, text = v.effect, ox = 0}
					i = i + 1
				end
				t[8] = {name = 'weight', desc = 'Weight', icon = img.hud.weight, text = item.item.weight, ox = 0}
				for i = 1, # text do 
					if string.len(text[i]) > 0 then 
						scarletLib.layout.addText({
							x = xx + 22,
							y = ty,
							group = 'item',
							z = 9,
							zoom = 1.5, 
							text = text[i],
							font = 'font1',
							color = {150,150,150},
						})
						scarletLib.layout.addLine({
							x1 = xx + 10,
							y1 = ty + 20,
							x2 = xx + 360,
							y2 = ty + 20,
							z = 9,
							group = 'item',
							color = {100, 100, 100},
							fade = 150,
						})
						scarletLib.layout.addLine({
							x1 = xx + 30,
							y1 = ty + 20,
							x2 = xx + 320,
							y2 = ty + 20,
							z = 9,
							group = 'item',
							color = {100, 100, 100},
							fade = 200,
						})
					end
					ty = ty + 30
				end
			end
			for i = 1, 8 do 
				if t[i] then 
					scarletLib.layout.addImage({
						name = 'itemattimg' .. i,
						x = xx + t[i].ox, 
						y = yy,
						group = 'item',
						z = 9,
						sx = 3, 
						sy = 3,
						img = t[i].icon,
						hilightable = true,
						hilighttext = t[i].name,
						hilightfont = 'font1',
					})
					scarletLib.layout.addText({
						name = 'itematttext' .. i,
						group = 'item',
						x = xx + 60 + t[i].ox,
						y = yy + 18,
						z = 9,
						zoom = 1.5,
						text = t[i].desc,
						font = 'font1',
						color = {150, 150, 150},
					})
					scarletLib.layout.addText({
						name = 'itemattval' .. i,
						group = 'item',
						x = xx + 360 - scarletLib.layout.getTextWidth(t[i].text, 'font1') * 1.5,
						y = yy + 18,
						z = 0,
						zoom = 1.5, 
						text = t[i].text,
						font = 'font1',
						color = t[i].color or {255,255,255},
					})
				end
				yy = yy + 54
			end
		else
			local text = item.item.desc
			local width, text = scarletLib.layout.getFont('font1'):getWrap(text, 225)
			local ty = yy + 20
			for i = 1, # text do 
				if string.len(text[i]) > 0 then 
					scarletLib.layout.addText({
						x = xx + 22,
						y = ty,
						group = 'item',
						z = 9,
						zoom = 1.5, 
						text = text[i],
						font = 'font1',
						color = {150,150,150},
					})
					scarletLib.layout.addLine({
							x1 = xx + 10,
							y1 = ty + 20,
							x2 = xx + 360,
							y2 = ty + 20,
							z = 9,
							group = 'item',
							color = {100, 100, 100},
							fade = 150,
						})
						scarletLib.layout.addLine({
							x1 = xx + 30,
							y1 = ty + 20,
							x2 = xx + 320,
							y2 = ty + 20,
							z = 9,
							group = 'item',
							color = {100, 100, 100},
							fade = 200,
						})
				end
				ty = ty + 30
			end
		end
	end
end

function game.setupInventory()
	table.insert(inventory, {type = 'mainhand', item = weapons.spear, stackable = false, stack = 0})
	table.insert(inventory, {type = 'mainhand', item = weapons.longbow, stackable = false, stack = 0})
	table.insert(inventory, {type = 'mainhand', item = weapons.shortsword, stackable = false, stack = 0})
	table.insert(inventory, {type = 'mainhand', item = weapons.greatsword, stackable = false, stack = 0})
	table.insert(inventory, {type = 'mainhand', item = weapons.rapier, stackable = false, stack = 0})
	table.insert(inventory, {type = 'mainhand', item = weapons.staff, stackable = false, stack = 0})
	table.insert(inventory, {type = 'mainhand', item = weapons.smallclub, stackable = false, stack = 0})
	table.insert(inventory, {type = 'offhand', item = weapons.towershield, stackable = false, stack = 0})
	table.insert(inventory, {type = 'offhand', item = weapons.kiteshield, stackable = false, stack = 0})
	table.insert(inventory, {type = 'offhand', item = weapons.standardshield, stackable = false, stack = 0})
	table.insert(inventory, {type = 'offhand', item = weapons.stiletto, stackable = false, stack = 0})
	table.insert(inventory, {type = 'offhand', item = weapons.pyroflame, stackable = false, stack = 0})
	table.insert(inventory, {type = 'head', item = armor.knighthelm, stackable = false, stack = 0})
	table.insert(inventory, {type = 'head', item = armor.thiefmask, stackable = false, stack = 0})
	table.insert(inventory, {type = 'head', item = armor.leatherhat, stackable = false, stack = 0})
	table.insert(inventory, {type = 'head', item = armor.hood, stackable = false, stack = 0})
	table.insert(inventory, {type = 'head', item = armor.skullcap, stackable = false, stack = 0})
	table.insert(inventory, {type = 'chest', item = armor.knightchest, stackable = false, stack = 0})
	table.insert(inventory, {type = 'chest', item = armor.leathervest, stackable = false, stack = 0})
	table.insert(inventory, {type = 'chest', item = armor.robe, stackable = false, stack = 0})
	table.insert(inventory, {type = 'chest', item = armor.heavycoat, stackable = false, stack = 0})
	table.insert(inventory, {type = 'ring', item = rings.sunstone, stackable = false, stack = 0})
	table.insert(inventory, {type = 'ring', item = rings.atlas, stackable = false, stack = 0})
	table.insert(inventory, {type = 'ring', item = rings.hornet, stackable = false, stack = 0})
	table.insert(inventory, {type = 'spell', item = spells.starshard, stackable = false, stack = 1})
	table.insert(inventory, {type = 'spell', item = spells.heavystarshard, stackable = false, stack = 1})
	table.insert(inventory, {type = 'pyro', item = spells.fireball, stackable = false, stack = 1})
	table.insert(inventory, {type = 'pyro', item = spells.snapfire, stackable = false, stack = 1})
	table.insert(inventory, {type = 'key', item = items.naniteinjector, stackable = false, stack = 1})
	table.insert(inventory, {type = 'key', item = items.photonicflask, stackable = true, stack = 1})
	inventory[#inventory].item.onPickup(inventory[#inventory], player)
end

function game.playerUpdateInventory(dt)
	local k = 1
	local t = { }
	local txt = 'Inventory'
	local sort = {
		'consume',
		'mainhand',
		'offhand',
		'head',
		'chest',
		'ring',
		'spell',
		'pyro',
		'key',
	}
	if loadInv then 
		scarletLib.layout.modifyElementGroup('inv', 'disabled', false)
		loadInv = false
	end
	scarletLib.layout.modifyElementGroup('inv', 'hilightable', false)
	scarletLib.layout.modifyElementGroup('inv', 'img', love.graphics.newImage("/dat/img/hud/inv.png"))
	for i = 1, # sort do 
		for k = 1, # inventory do 
			if inventory[k].type == sort[i] then 
				table.insert(t, # t + 1, inventory[k])
			end
		end
	end
	inventory = t
	for i = 1, 70 do 
		scarletLib.layout.changeElement('invcount'..i, 'text', '')
	end
	for i = 1, # t do 
		if not invFilter or invFilter == inventory[i].type then 
			local txt = false 
			if menuAction and menuAction.action == 'equip' then 
				txt = 'Equip'
			end
			scarletLib.layout.changeElement('inv'..k, 'img', inventory[i].item.icon)
			scarletLib.layout.changeElement('inv'..k, 'hilightable', true)
			scarletLib.layout.changeElement('inv'..k, 'hilighttext', txt)
			scarletLib.layout.changeElement('inv'..k, 'prop', i)
			if inventory[i].stackable then 
				scarletLib.layout.changeElement('invcount'..k, 'text', inventory[i].stack)
			else
				scarletLib.layout.changeElement('invcount'..k, 'text', '')
			end
			k = k + 1 
		end
	end
	if invFilter then 
		txt = game.firstToUpper(invFilter)
	end
	scarletLib.layout.changeElement('inv1titleframe', 'x', 386 / 2 - scarletLib.layout.getTextWidth(txt, 'font1') * 1.5 / 2)
	scarletLib.layout.changeElement('inv1titleframe', 'width', scarletLib.layout.getTextWidth(txt, 'font1') * 1.5 + 18)
	scarletLib.layout.changeElement('inv1title', 'x', 406 / 2 - scarletLib.layout.getTextWidth(txt, 'font1') * 1.5 / 2)
	scarletLib.layout.changeElement('inv1title', 'text', txt)
end

function game.playerSetupInventory()
	scarletLib.layout.addFrame({
		name = 'invframe1',
		group = 'inventory',
		x = 0,
		y = 0,
		width = 390,
		height = 577,
		z = 8,
		style = 1,
	})
	scarletLib.layout.addFrame({
		name = 'inv1titleframe',
		group = 'inventory',
		x = 366 / 2 - scarletLib.layout.getTextWidth('Inventory', 'font1') * 1.5 / 2,
		y = -13,
		z = 7,
		width = scarletLib.layout.getTextWidth('Inventory', 'font1') * 1.5 + 18,
		height = 34	,
		style = 1,
	})
	scarletLib.layout.addText({
		name = 'inv1title',
		group = 'inventory',
		x = 386 / 2 - scarletLib.layout.getTextWidth('Inventory', 'font1') * 1.5 / 2,
		y = -5,
		z = 6,
		font = 'font1',
		text = 'Inventory',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	local x = 25
	local y = 125
	local c = 1
	local inv = img.hud.inv
	for i = 1, 70 do 
		scarletLib.layout.addText({
			name = 'invcount'..i,
			group = 'inv',
			x = x + 36,
			y = y + 30, 
			z = 6,
			zoom = 1.5,
			text = '0',
			color = {255, 255, 255}
		})
		scarletLib.layout.addButton({
			name = 'inv'..i,
			group = 'inv',
			x = x,
			y = y,
			z = 7,
			sx = 3,
			sy = 3,
			img = inv,
			hilightable = false,
			hilighttext = '',
			hilightfont = 'font1',
			buttonpressed =	function (self)
								local inv = inventory[self.prop]
								local switch = false
								if menuAction and inv and inv.type == menuAction.item then 
									game.playSound('buttonpressed2', player.x, player.y)
									if inv.type == 'mainhand' then 
										local i = false 
										if player.weapon then 
											i = {type = 'mainhand', item = weapons[player.weapon.name], stackable = false, stack = 1}
										end
										player.weapon = inv.item
										if player.weapon.twohand then 
											if player.offhand then 
												table.insert(inventory, {type = 'offhand', item = weapons[player.offhand.name], stackable = false, stack = 1})
												player.offhand = false
											end
										end
										table.remove(inventory, self.prop)
										if i then 
											table.insert(inventory, i)
										end
										switch = true
									elseif inv.type == 'offhand' then 
										if (player.weapon and not player.weapon.twohand) or not player.weapon then 
											local i = false
											if player.offhand then 
												i = {type = 'offhand', item = weapons[player.offhand.name], stackable = false, stack = 1}
											end
											player.offhand = inv.item
											table.remove(inventory, self.prop)
											if i then 
												table.insert(inventory, i)
											end
											switch = true
										end
									elseif inv.type == 'chest' then 
										local i = false
										if player.armorChest then 
											i = {type = 'chest', item = armor[player.armorChest.name], stackable = false, stack = 1}
										end
										player.armorChest = inv.item 
										table.remove(inventory, self.prop)
										if i then 
											table.insert(inventory, i)
										end
										switch = true 
									elseif inv.type == 'head' then
										local i = false 
										if player.armorHead then 
											i = {type = 'head', item = armor[player.armorHead.name], stackable = false, stack = 1}
										end
										player.armorHead = inv.item 
										table.remove(inventory, self.prop)
										if i then 
											table.insert(inventory, i)
										end 
										switch = true
									elseif inv.type == 'ring' then 
										local i = false 
										local slot = player.rings[menuAction.ringSlot]
										if slot then 
											i = {type = 'ring', item = slot, stackable = false, stack = 1}
										end
										player.rings[menuAction.ringSlot] = inv.item
										table.remove(inventory, self.prop)
										if i then 
											table.insert(inventory, i)
										end
										switch = true
									end
								end
								if switch then 
									menu = 'equipment'
									menuAction = false
									self.buttonpressedhilight = -10
									scarletLib.layout.changeElementGroup('inventory', 'disabled', true)
									scarletLib.layout.changeElementGroup('inv', 'disabled', true)
									scarletLib.layout.changeElementGroup('equipment', 'disabled', false)
								end
							end,
		})
		x = x + 51
		c = c + 1 
		if c > 7 then 
			x = 25
			y = y + 51
			c = 1
		end
	end
	scarletLib.layout.changeElementGroup('inventory', 'disabled', true)
	scarletLib.layout.changeElementGroup('inv', 'disabled', true)
end

function game.playerSetupWeightLimit()
	scarletLib.layout.addFrame({
		name = 'weightframe1',
		group = 'weightframe',
		x = 0,
		y = 0,
		width = 390,
		height = 74,
		style = 1,
	})
	scarletLib.layout.addFrame({
		name = 'weightframe2',
		group = 'weightframe',
		x = 366 / 2 - scarletLib.layout.getTextWidth('Equip Load', 'font1') * 1.5 / 2,
		y = -13,
		z = 7,
		width = scarletLib.layout.getTextWidth('Equip Load', 'font1') * 1.5 + 18,
		height = 34	,
		style = 1,
	})
	scarletLib.layout.addText({
		name = 'weightframe2title',
		group = 'weightframe',
		x = 386 / 2 - scarletLib.layout.getTextWidth('Equip Load', 'font1') * 1.5 / 2,
		y = -5,
		z = 6,
		font = 'font1',
		text = 'Equip Load',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addImage({
		name = 'weightimg',
		group = 'weightframe',
		x = 10,
		y = 10,
		sx = 3,
		sy = 3,
		z = 5,
		img = love.graphics.newImage("/dat/img/hud/weight.png"),
		hilightable = true,
		hilighttext = 'Weight',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'mobilityval',
		group = 'weightframe',
		x = 70,
		y = 28,
		zoom = 1.5,
		z = 5,
		text = 'Fast',
		font = 'font1',
		color = {255,255,255}
	})
	scarletLib.layout.addText({
		name = 'weightpercval',
		group = 'weightframe',
		x = 370 - scarletLib.layout.getTextWidth('17% (7 / 40)', 'font1') * 1.5,
		y = 28,
		zoom = 1.5,
		z = 5,
		text = '17% (7 / 40)',
		font = 'font1',
		color = {255,255,255},
	})
	scarletLib.layout.changeElementGroup('weightframe', 'disabled', true)
end

function game.playerUpdateWeightLimit()
	local item = false
	local temp = false
	local perccolor = {255, 255, 255}
	local mobcolor = {255, 255, 255}
	local hi = scarletLib.layout.getHilightedElement()
	local percval = math.ceil(game.actorGetWeightCur(player) / game.actorGetWeightMax(player) * 100) .. '% (' .. game.actorGetWeightCur(player) .. ' / ' .. game.actorGetWeightMax(player) .. ')'
	local percnum = math.ceil(game.actorGetWeightCur(player) / game.actorGetWeightMax(player) * 100)
	local opercnum = math.ceil(game.actorGetWeightCur(player) / game.actorGetWeightMax(player) * 100)
	local mobval = game.firstToUpper(game.actorGetMobility(player))
	local omob = game.firstToUpper(game.actorGetMobility(player))
	if hi then 
		if string.sub(hi.name, 1, 3) == 'inv' then 
			item = inventory[hi.prop]
		end
	end
	if item then 
		if item.type == 'mainhand' then 
			temp = player.weapon 
			player.weapon = item.item 
			game.actorUpdateWeight(player)
			game.actorUpdateMobility(player)
			percnum = math.ceil(game.actorGetWeightCur(player) / game.actorGetWeightMax(player) * 100)
			percval = math.ceil(game.actorGetWeightCur(player) / game.actorGetWeightMax(player) * 100) .. '% (' .. game.actorGetWeightCur(player) .. ' / ' .. game.actorGetWeightMax(player) .. ')'
			mobval = game.firstToUpper(game.actorGetMobility(player))
			player.weapon = temp
		elseif item.type == 'offhand' then 
			temp = player.offhand
			player.offhand = item.item 
			game.actorUpdateWeight(player)
			game.actorUpdateMobility(player)
			percnum = math.ceil(game.actorGetWeightCur(player) / game.actorGetWeightMax(player) * 100)
			percval = math.ceil(game.actorGetWeightCur(player) / game.actorGetWeightMax(player) * 100) .. '% (' .. game.actorGetWeightCur(player) .. ' / ' .. game.actorGetWeightMax(player) .. ')'
			mobval = game.firstToUpper(game.actorGetMobility(player))
			player.offhand = temp
		elseif item.type == 'head' then 
			temp = player.armorHead 
			player.armorHead = item.item 
			game.actorUpdateWeight(player)
			game.actorUpdateMobility(player)
			percnum = math.ceil(game.actorGetWeightCur(player) / game.actorGetWeightMax(player) * 100)
			percval = math.ceil(game.actorGetWeightCur(player) / game.actorGetWeightMax(player) * 100) .. '% (' .. game.actorGetWeightCur(player) .. ' / ' .. game.actorGetWeightMax(player) .. ')'
			mobval = game.firstToUpper(game.actorGetMobility(player))
			player.armorHead = temp
		elseif item.type == 'chest' then 
			temp = player.armorChest
			player.armorChest = item.item 
			game.actorUpdateWeight(player)
			game.actorUpdateMobility(player)
			percnum = math.ceil(game.actorGetWeightCur(player) / game.actorGetWeightMax(player) * 100)
			percval = math.ceil(game.actorGetWeightCur(player) / game.actorGetWeightMax(player) * 100) .. '% (' .. game.actorGetWeightCur(player) .. ' / ' .. game.actorGetWeightMax(player) .. ')'
			mobval = game.firstToUpper(game.actorGetMobility(player))
			player.armorChest = temp
		elseif item.type == 'ring' and menuAction and menuAction.ringSlot then 
			temp = player.rings[menuAction.ringSlot]
			player.rings[menuAction.ringSlot] = item.item 
			game.actorUpdateWeight(player)
			game.actorUpdateMobility(player)
			percnum = math.ceil(game.actorGetWeightCur(player) / game.actorGetWeightMax(player) * 100)
			percval = math.ceil(game.actorGetWeightCur(player) / game.actorGetWeightMax(player) * 100) .. '% (' .. game.actorGetWeightCur(player) .. ' / ' .. game.actorGetWeightMax(player) .. ')'
			mobval = game.firstToUpper(game.actorGetMobility(player))
			player.rings[menuAction.ringSlot] = temp
		end
		if percnum > opercnum then 
			perccolor = {255, 50, 50}
		elseif percnum < opercnum then 
			perccolor = {50, 50, 255}
		end
		if omob == 'Fast' and (mobval == 'Normal' or mobval == 'Slow') then 
			mobcolor = {255, 50, 50}
		elseif omob == 'Normal' and mobval == 'Fast' then 
			mobcolor = {50, 50, 255}
		elseif omob == 'Normal' and mobval == 'Slow' then 
			mobcolor = {255, 50, 50}
		elseif omob == 'Slow' and (mobval == 'Normal' or mobval == 'Fast') then 
			mobcolor = {50, 50, 255}
		end
	end
	scarletLib.layout.changeElement('mobilityval', 'text', mobval)
	scarletLib.layout.changeElement('mobilityval', 'color', mobcolor)
	scarletLib.layout.changeElement('weightpercval', 'text', percval)
	scarletLib.layout.changeElement('weightpercval', 'color', perccolor)
	scarletLib.layout.changeElement('weightpercval', 'x', 370 - scarletLib.layout.getTextWidth(percval, 'font1') * 1.5)
end

function game.playerSetupEquipment()
	game.playerSetupWeightLimit()
	scarletLib.layout.addFrame({
		name = 'equipmentframe1',
		group = 'equipment',
		x = 0,
		y = 0,
		width = 390,
		height = 577,
		z = 8,
		style = 1,
	})
	scarletLib.layout.addFrame({
		name = 'equipment1titleframe',
		group = 'equipment',
		x = 366 / 2 - scarletLib.layout.getTextWidth('Equipment', 'font1') * 1.5 / 2,
		y = -13,
		z = 7,
		width = scarletLib.layout.getTextWidth('Equipment', 'font1') * 1.5 + 18,
		height = 34	,
		style = 1,
	})
	scarletLib.layout.addText({
		name = 'equipment1title',
		group = 'equipment',
		x = 386 / 2 - scarletLib.layout.getTextWidth('Equipment', 'font1') * 1.5 / 2,
		y = -5,
		z = 6,
		font = 'font1',
		text = 'Equipment',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	local x = 10
	local y = 15
	local t = {
		{name = 'weapon', dname = 'Weapons', img = "/dat/img/hud/weapon.png", items = 
			{
				{dname = 'Main Hand', name = 'mainhand'}, 
				{dname = 'Off Hand', name = 'offhand'}
			}
		},
		{name = 'armor', dname = 'Armor', img = "/dat/img/hud/armor.png", items = 
			{
				{dname = 'Helm', name = 'head'},
				{dname = 'Chest', name = 'chest'}
			}
		},
		{name = 'rings', dname = 'Rings', img = "/dat/img/hud/ring.png", items = 
			{
				{dname = 'Ring', name = 'ring1', slot = 'ring', ringSlot = 1,},
				{dname = 'Ring', name = 'ring2', slot = 'ring', ringSlot = 2,},
				{dname = 'Ring', name = 'ring3', slot = 'ring', ringSlot = 3,},
			}
		},
	}
	for i = 1, # t do 
		scarletLib.layout.addImage({
			name = 'equip' .. t[i].name,
			group = 'equipment',
			x = x,
			y = y,
			sx = 3,
			sy = 3,
			z = 7,
			img = love.graphics.newImage(t[i].img),
			hilightable = true,
			hilighttext = t[i].dname,
			hilightfont = 'font1',
		})
		scarletLib.layout.addText({
			name = 'equip' .. t[i].name .. 'text',
			group = 'equipment',
			x = x + 60,
			y = y + 18,
			text = t[i].dname,
			zoom = 1.5,
			z = 7,
			color = {150, 150, 150, 255},
			font = 'font1',
		})
		for k = 1, # t[i].items do 
			scarletLib.layout.addImage({
				name = 'equip' .. t[i].items[k].name .. 'lines',
				group = 'equipment',
				x = x + 24,
				y = y + 54 - 32,
				z = 8,
				img = love.graphics.newImage("/dat/img/hud/deflines3.png")
			})
			scarletLib.layout.addButton({
				name = 'equip' .. t[i].items[k].name .. 'img',
				group = 'equipment',
				x = x + 61,
				y = y + 53,
				sx = 3,
				sy = 3,
				z = 7,
				img = love.graphics.newImage("/dat/img/hud/empty.png"),
				hilightable = true,
				hilighttext = 'Unequip ' .. t[i].items[k].dname,
				hilightfont = 'font1',
				prop = {slot = t[i].items[k].name, ring = t[i].items[k].ringSlot},
				buttonpressed =	function (self)
									if (self.prop.slot == 'mainhand' and player.weapon) then
										table.insert(inventory, {type = self.prop.slot, item = weapons[player.weapon.name], stackable = false, stack = 1})
										player.weapon = false
										game.playSound('buttonpressed', player.x, player.y)
									elseif (self.prop.slot == 'offhand' and player.offhand) then
										table.insert(inventory, {type = self.prop.slot, item = weapons[player.offhand.name], stackable = false, stack = 1})
										player.offhand = false
										game.playSound('buttonpressed', player.x, player.y)
									elseif (self.prop.slot == 'head' and player.armorHead) then
										table.insert(inventory, {type = self.prop.slot, item = armor[player.armorHead.name], stackable = false, stack = 1})
										player.armorHead = false
										game.playSound('buttonpressed', player.x, player.y)
									elseif (self.prop.slot == 'chest' and player.armorChest) then 
										table.insert(inventory, {type = self.prop.slot, item = armor[player.armorChest.name], stackable = false, stack = 1})
										player.armorChest = false
										game.playSound('buttonpressed', player.x, player.y)
									elseif (self.prop.ring and player.rings[self.prop.ring]) then 
										table.insert(inventory, {type = 'ring', item = player.rings[self.prop.ring], stackable = false, stack = 1})
										player.rings[self.prop.ring] = false
										game.playSound('buttonpressed', player.x, player.y)
									end
								end
			})
			scarletLib.layout.addFrame({
				name = 'equip' .. t[i].items[k].name .. 'frame',
				group = 'equipment',
				x = x + 112,
				y = y + 54,
				width = 251,
				height = 51,
				z = 7,
				buttonpressed = 	function (self)
										menu = 'inventory'
										game.playSound('menuopen', player.x, player.y)
										invFilter = t[i].items[k].slot or t[i].items[k].name
										menuAction = {action = 'equip', item = t[i].items[k].slot or t[i].items[k].name, ringSlot = t[i].items[k].ringSlot or false}
										scarletLib.layout.changeElementGroup('weightframe', 'disabled', false)
										loadInv = true
										scarletLib.layout.changeElementGroup('inventory', 'disabled', false)
										scarletLib.layout.changeElementGroup('equipment', 'disabled', true)
									end,
				hilightable = true,
				hilighttext = 'Change ' .. t[i].items[k].dname .. ' Equipment',
				hilightfont = 'font1',
			})
			scarletLib.layout.addText({
				name = 'equip' .. t[i].items[k].name .. 'text',
				group = 'equipment',
				x = x + 125,
				y = y + 70,
				text = 'Empty',
				z = 6,
				zoom = 1.5,
				font = 'font1',
				color = {150, 150, 150, 255},
			})
			y = y + 54
		end	
		y = y + 54
	end
	scarletLib.layout.changeElementGroup('equipment', 'disabled', true)
end

function game.playerSetupCryoMenu()
	scarletLib.layout.addFrame({
		name = 'cryoframe1',
		group = 'cryo',
		x = 0,
		y = 0,
		width = 390,
		height = 300,
		z = 8,
		style = 1,
	})
	scarletLib.layout.addFrame({
		name = 'cryo1titleframe',
		group = 'cryo',
		x = 366 / 2 - scarletLib.layout.getTextWidth('Cryogenic Pod', 'font1') * 1.5 / 2,
		y = -13,
		z = 7,
		width = scarletLib.layout.getTextWidth('Cryogenic Pod', 'font1') * 1.5 + 18,
		height = 34	,
		style = 1,
	})
	scarletLib.layout.addText({
		name = 'cryo1title',
		group = 'cryo',
		x = 386 / 2 - scarletLib.layout.getTextWidth('Cryogenic Pod', 'font1') * 1.5 / 2,
		y = -5,
		z = 6,
		font = 'font1',
		text = 'Cryogenic Pod',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	local x = 10
	local y = 30
	local t = {
		{dname = 'Level Up', name = 'levelup', idesc = 'Raise Your Level', desc = 'Spend Matter to Raise Level', img = love.graphics.newImage("/dat/img/hud/levelup.png"),
			func =  function (self)
						menu = 'levelup'
						menuAction = {stats = {0,0,0,0,0,0,0,0}, matter = player.matter, action = 'levelup'}
						scarletLib.layout.changeElementGroup('cryo', 'disabled', 'true')
						scarletLib.layout.changeElementGroup('charframe', 'disabled', 'false')
					end},
		{dname = 'Repair Empty Flask', name = 'offerspirit', idesc = 'Requires an Empty Flask.', desc = 'Increase Your Photonic Flask Uses.', img = love.graphics.newImage("/dat/img/hud/offer.png"),
			func =	function (self)
						if game.removeItemFromPlayer({item = items.emptyflask, stackable = true, stack = 1}) then
							scarletLib.layout.changeElementGroup('cryo', 'disabled', 'true')
							game.addItemToInventory({item = items.photonicflask, stackable = true, stack = 1})
							player.healsMax = player.healsMax + 1
						end
					end},
		{dname = 'Attune Spells', name = 'attunespells', idesc = 'Attune Your Spells', desc = 'Attune Spell Slots', img = love.graphics.newImage("/dat/img/hud/attune.png"),
			},
		{dname = 'Teleport', name = 'teleport', idesc = 'Teleport Between Cryogenic Pods', desc = 'Requires a Charged Warp Crystal to Activate.', img = love.graphics.newImage("/dat/img/hud/teleport.png"),
			},
	}
	for i = 1, # t do 
		scarletLib.layout.addImage({
			name = 'cryo' .. t[i].name .. 'img',
			group = 'cryo',
			x = x,
			y = y,
			sx = 3,
			sy = 3,
			z = 7,
			img = t[i].img or love.graphics.newImage("/dat/img/hud/empty.png"),
			hilightable = true,
			hilighttext = t[i].desc,
			hilightfont = 'font1',
		})
		scarletLib.layout.addFrame({
			name = 'cryo' .. t[i].name .. 'frame',
			group = 'cryo',
			x = x + 51,
			y = y + 1,
			width = 315,
			height = 51,
			z = 7,
			hilightable = true,
			hilighttext = t[i].idesc,
			hilightfont = 'font1',
			buttonpressed = t[i].func,
		})
		scarletLib.layout.addText({
			name = 'cryo' .. t[i].name .. 'text',
			group = 'cryo',
			x = x + 71,
			y = y + 16,
			text = t[i].dname,
			z = 6,
			zoom = 1.5,
			font = 'font1',
			color = {150, 150, 150, 255},
		})
		y = y + 64
	end
	scarletLib.layout.changeElementGroup('cryo', 'disabled', true)
end

function game.playerSetupLevelup()
	local t = {'vitality', 'endurance', 'stability', 'strength', 'dexterity', 'intelligence', 'soulpower', 'wisdom'}
	for i = 1, # t do 
		scarletLib.layout.addButton({
			name = 'add' .. t[i],
			group = 'levelup',
			img = love.graphics.newImage("/dat/img/hud/plus.png"),
			x = 240,
			y = 150 + (i - 1) * 54,
			sx = 3,
			sy = 3,
			z = 0,
			hilightable = true,
			hilighttext = 'Add level to ' .. game.firstToUpper(t[i]),
			hilightfont = 'font1',
			buttonpressed = 	function (self)
									if player.matter >= game.actorMatterNeeded(player) then 
										player.matter = player.matter - game.actorMatterNeeded(player)
										player[t[i]] = player[t[i]] + 1
										player.level = player.level + 1
									end
								end,
		})
		scarletLib.layout.addButton({
			name = 'remove' .. t[i],
			group = 'levelup',
			img = love.graphics.newImage("/dat/img/hud/minus.png"),
			x = 270,
			y = 150 + (i - 1) * 54,
			sx = 3,
			sy = 3,
			z = 0,
			hilightable = true,
			hilighttext = 'Remove level from ' .. game.firstToUpper(t[i]) ..'\nYou will only be refunded half the amount of matter needed to levelup.',
			hilightfont = 'font1',
			buttonpressed =		function (self)
									if player[t[i]] > 1 and player.level > 1 then 
										player[t[i]] = player[t[i]] - 1 
										player.level = player.level - 1
										player.matter = player.matter + game.actorMatterNeeded(player) / 2
									end
								end
		})
	end
	scarletLib.layout.changeElementGroup('levelup', 'disabled', true)
end

function game.playerSetupHud()
	local x = 0
	local y = 0
	game.playerSetupEquipment()
	game.playerSetupCryoMenu()
	game.playerSetupInventory()
	game.playerSetupLevelup()
	--- matter count
	scarletLib.layout.addImage({
		name = 'mattercount',
		group = 'matter',
		img = love.graphics.newImage("/dat/img/hud/mattercount.png"),
		x = love.graphics.getWidth() - 10,
		y = love.graphics.getHeight() - 106,
		sx = 3,
		sy = 3,
		z = 11,
	})
	scarletLib.layout.addText({
		name = 'mattercounttext',
		group = 'mattertext',
		x = love.graphics.getWidth() - 10,
		y = love.graphics.getHeight() - 10,
		zoom = 1.5,
		text = '12,350',
		font = 'font1',
		color = {150, 150, 150, 255},
	})
	scarletLib.layout.addText({
		name = 'mattertext2',
		group = 'mattertext2',
		x = love.graphics.getWidth() - 10,
		y = love.graphics.getHeight() - 10,
		zoom = 1,
		text = 'Matter',
		font = 'font1',
		color = {100, 100, 100, 255},
	})
	--- Health bar
	scarletLib.layout.addBar({
		name = 'health',
		group = 'hud',
		x = 83,
		y = 13,
		width = 300,
		height = 20,
		minval = player.healthCur,
		maxval = player.healthMax,
		color = {200, 0, 0},
		hilightable = true,
		hilighttext = 'Health',
		hilightfont = 'font1'
	})
	--- Stamina Bar
	scarletLib.layout.addBar({
		name = 'stamina',
		group = 'hud',
		x = 83,
		y = 38,
		width = 200,
		height = 20,
		minval = player.staminaCur,
		maxval = player.staminaMax,
		color = {0, 200, 0},
		hilightable = true,
		hilighttext = 'Stamina',
		hilightfont = 'font1'
	})
	--- Player Icon
	scarletLib.layout.addImage({
		name = 'playericon',
		group = 'hud',
		x = 10, 
		y = 10,
		img = love.graphics.newImage("/dat/img/hud/playerIcon.png"),
		sx = 3,
		sy = 3,
		hilightable = true,
		hilighttext = 'Phantom',
		hilightfont = 'font1',
		shader = 'replaceColor',
		shadercolor = {99, 155, 255}
	})
	--- Dark Matter
	scarletLib.layout.addText({
		name = 'darkMatterCount',
		group = 'hud',
		x = 0,
		y = 35,
		zoom = 1.5,
		font = 'font1',
		text = '99',
		color = {150, 150, 150},
	})
	--- Heals
	x = 82
	y = 64
	for i = 1, 15 do
		scarletLib.layout.addImage({
			name = 'heal' .. i,
			group = 'hud',
			x = x,
			y = y,
			img = love.graphics.newImage("/dat/img/hud/heal.png"),
			sx = 3,
			sy = 3,
			hilightable = true,
			hilighttext = 'Health Potion',
			hilightfont = 'font1',
		})
		x = x + 18
	end
	--- char sheet
	scarletLib.layout.addFrame({
		name = 'charframe6',
		group = 'charframe',
		x = 780,
		y = 128,
		width = 390,
		height = 449,
		z = 11,
		style = 1,
	})
	scarletLib.layout.addFrame({
		name = 'charframe6titleframe',
		group = 'charframe',
		x = 780 + 366 / 2 - scarletLib.layout.getTextWidth('Status', 'font1') * 1.5 / 2,
		y = 115,
		z = 10,
		width = scarletLib.layout.getTextWidth('Status', 'font1') * 1.5 + 18,
		height = 34	,
		style = 1,
	})
	scarletLib.layout.addText({
		name = 'charframe6title',
		group = 'charframe',
		x = 780 + 386 / 2 - scarletLib.layout.getTextWidth('Status', 'font1') * 1.5 / 2,
		y = 123,
		z = 9,
		font = 'font1',
		text = 'Status',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addFrame({
		name = 'charframe5',
		group = 'charframe',
		x = 780,
		y = 0,
		width = 390,
		height = 128,
		z = 11,
		style = 1,
	})
	scarletLib.layout.addFrame({
		name = 'charframe5titleframe',
		group = 'charframe',
		x = 780 + 366 / 2 - scarletLib.layout.getTextWidth('Body', 'font1') * 1.5 / 2,
		y = -13,
		z = 10,
		width = scarletLib.layout.getTextWidth('Body', 'font1') * 1.5 + 18,
		height = 34	,
		style = 1,
	})
	scarletLib.layout.addText({
		name = 'charframe5title',
		group = 'charframe',
		x = 780 + 386 / 2 - scarletLib.layout.getTextWidth('Body', 'font1') * 1.5 / 2,
		y = -5,
		z = 9,
		font = 'font1',
		text = 'Body',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addFrame({
		name = 'charframe1',
		group = 'charframe',
		x = 0, 
		y = 0,
		width = 390,
		height = 128,
		z = 11,
		style = 1,
	})
	scarletLib.layout.addFrame({
		name = 'charframe1titleframe',
		group = 'charframe',
		x = 366 / 2 - scarletLib.layout.getTextWidth('Character', 'font1') * 1.5 / 2,
		y = -13,
		z = 10,
		width = scarletLib.layout.getTextWidth('Character', 'font1') * 1.5 + 18,
		height = 34	,
		style = 1,
	})
	scarletLib.layout.addText({
		name = 'charframe1title',
		group = 'charframe',
		x = 386 / 2 - scarletLib.layout.getTextWidth('Character', 'font1') * 1.5 / 2,
		y = -5,
		z = 9,
		font = 'font1',
		text = 'Character',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addFrame({
		name = 'charframe2',
		group = 'charframe',
		x = 390, 
		y = 0,
		width = 390,
		height = 128,
		z = 11,
		style = 1,
	})
	scarletLib.layout.addFrame({
		name = 'charframe1titleframe',
		group = 'charframe',
		x = 390 + 366 / 2 - scarletLib.layout.getTextWidth('Growth', 'font1') * 1.5 / 2,
		y = -13,
		z = 10,
		width = scarletLib.layout.getTextWidth('Growth', 'font1') * 1.5 + 18,
		height = 34,
		style = 1,
	})
	scarletLib.layout.addText({
		name = 'charframe1title',
		group = 'charframe',
		x = 390 + 386 / 2 - scarletLib.layout.getTextWidth('Growth', 'font1') * 1.5 / 2,
		y = -5,
		z = 9,
		font = 'font1',
		text = 'Growth',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addFrame({
		name = 'charframe3',
		group = 'charframe',
		x = 0, 
		y = 128,
		width = 390,
		height = 449,
		z = 11,
		style = 1,
	})
	scarletLib.layout.addFrame({
		name = 'charframe1titleframe',
		group = 'charframe',
		x = 366 / 2 - scarletLib.layout.getTextWidth('Attributes', 'font1') * 1.5 / 2,
		y = 115,
		z = 10,
		width = scarletLib.layout.getTextWidth('Attributes', 'font1') * 1.5 + 18,
		height = 34,
		style = 1,
	})
	scarletLib.layout.addText({
		name = 'charframe1title',
		group = 'charframe',
		x = 386 / 2 - scarletLib.layout.getTextWidth('Attributes', 'font1') * 1.5 / 2,
		y = 123,
		z = 9,
		font = 'font1',
		text = 'Attributes',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addFrame({
		name = 'charframe4',
		group = 'charframe',
		x = 390,
		y = 128,
		width = 390,
		height = 449,
		z = 11,
		style = 1,
	})
	scarletLib.layout.addFrame({
		name = 'charframe1titleframe',
		group = 'charframe',
		x = 390 + 366 / 2 - scarletLib.layout.getTextWidth('Defenses', 'font1') * 1.5 / 2,
		y = 115,
		z = 10,
		width = scarletLib.layout.getTextWidth('Defenses', 'font1') * 1.5 + 18,
		height = 34,
		style = 1,
	})
	scarletLib.layout.addText({
		name = 'charframe1title',
		group = 'charframe',
		x = 390 + 386 / 2 - scarletLib.layout.getTextWidth('Defenses', 'font1') * 1.5 / 2,
		y = 123,
		z = 9,
		font = 'font1',
		text = 'Defenses',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addImage({
		name = 'name',
		group = 'charframe',
		x = 10,
		y = 10,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/name.png"),
		hilightable = true,
		hilighttext = 'Name',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'nametext',
		group = 'charframe',
		x = 70,
		y = 28,
		z = 9,
		font = 'font1',
		text = 'Name',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'nameval',
		group = 'charframe',
		x = 370 - scarletLib.layout.getTextWidth('Sir Teste', 'font1') * 1.5,
		y = 28,
		z = 9,
		font = 'font1',
		text = 'Sir Teste',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'class',
		group = 'charframe',
		x = 10,
		y = 64,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/class.png"),
		hilightable = true,
		hilighttext = 'Class',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'classtext',
		group = 'charframe',
		x = 70,
		y = 82,
		z = 9,
		font = 'font1',
		text = 'Class',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'classval',
		group = 'charframe',
		x = 370 - scarletLib.layout.getTextWidth('Space Knight', 'font1') * 1.5,
		y = 82,
		z = 9,
		font = 'font1',
		text = 'Space Knight',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'mainhand',
		group = 'charframe',
		x = 790,
		y = 138,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/mainhand.png"),
		hilightable = true,
		hilightfont = 'font1',
		hilighttext = 'Mainhand',
	})
	scarletLib.layout.addImage({
		name = 'physicallines',
		group = 'charframe',
		x = 814,
		y = 189,
		z = 10,
		img = love.graphics.newImage("/dat/img/hud/deflines2.png")
	})
	scarletLib.layout.addText({
		name = 'mainhandtext',
		group = 'charframe',
		x = 850,
		y = 156,
		z = 9,
		font = 'font1',
		text = 'Main Hand',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addImage({
		name = 'weapon',
		group = 'charframe',
		x = 844,
		y = 192,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/weapon.png"),
		hilightable = true,
		hilightfont = 'font1',
		hilighttext = 'Weapon',
	})
	scarletLib.layout.addText({
		name = 'weapontext',
		group = 'charframe',
		x = 908,
		y = 210,
		z = 9,
		font = 'font1',
		text = 'Short Sword',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addImage({
		name = 'weapondam',
		group = 'charframe',
		x = 844,
		y = 246,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/slash.png"),
		hilightable = true,
		hilightfont = 'font1',
		hilighttext = 'Weapon Damage Type',
	})
	scarletLib.layout.addText({
		name = 'weapondamtext',
		group = 'charframe',
		x = 908,
		y = 264,
		z = 9,
		font = 'font1',
		text = 'Slash',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'weapondamval',
		group = 'charframe',
		x = 1150 - scarletLib.layout.getTextWidth('75', 'font1') * 1.5,
		y = 264,
		z = 9,
		font = 'font1',
		text = '75',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'offhand',
		group = 'charframe',
		x = 790,
		y = 300,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/offhand.png"),
		hilightable = true,
		hilightfont = 'font1',
		hilighttext = 'Offhand',
	})
	scarletLib.layout.addImage({
		name = 'physicallines',
		group = 'charframe',
		x = 814,
		y = 351,
		z = 10,
		img = love.graphics.newImage("/dat/img/hud/deflines2.png")
	})
	scarletLib.layout.addText({
		name = 'offhandtext',
		group = 'charframe',
		x = 854,
		y = 318,
		z = 9,
		font = 'font1',
		text = 'Off Hand',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addImage({
		name = 'offhandweapon',
		group = 'charframe',
		x = 844,
		y = 354,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/towershield.png"),
		hilightable = true,
		hilightfont = 'font1',
		hilighttext = 'Offhand Weapon',
	})
	scarletLib.layout.addText({
		name = 'offhandweapontext',
		group = 'charframe',
		x = 908,
		y = 372,
		z = 9,
		font = 'font1',
		text = 'Tower Shield',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addImage({
		name = 'offhandweapontype',
		group = 'charframe',
		x = 844,
		y = 408,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/physical.png"),
		hilightable = true,
		hilightfont = 'font1',
		hilighttext = 'Offhand Weapon Ability',
	})
	scarletLib.layout.addText({
		name = 'offhandweapontypetext',
		group = 'charframe',
		x = 908,
		y = 426,
		z = 9,
		font = 'font1',
		text = 'Block',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addImage({
		name = 'weight',
		group = 'charframe',
		x = 790,
		y = 462,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/weight.png"),
		hilightable = true,
		hilightfont = 'font1',
		hilighttext = 'Weight',
	})
	scarletLib.layout.addText({
		name = 'weighttext',
		group = 'charframe',
		x = 854,
		y = 480,
		z = 9,
		font = 'font1',
		text = 'Weight',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'weightval',
		group = 'charframe',
		x = 1150 - scarletLib.layout.getTextWidth('38 / 65', 'font1') * 1.5,
		y = 480,
		z = 9,
		font = 'font1',
		text = '38 / 65',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'death',
		group = 'charframe',
		x = 790,
		y = 516,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/death.png"),
		hilightable = true,
		hilightfont = 'font1',
		hilighttext = 'Mobility',
	})
	scarletLib.layout.addText({
		name = 'deathtext',
		group = 'charframe',
		x = 854,
		y = 534,
		z = 9,
		font = 'font1',
		text = 'Mobility',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'deathval',
		group = 'charframe',
		x = 1150 - scarletLib.layout.getTextWidth('Slow', 'font1') * 1.5,
		y = 534,
		z = 9,
		font = 'font1',
		text = 'Slow',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'charhealth',
		group = 'charframe',
		x = 790,
		y = 10,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/health.png"),
		hilightable = true,
		hilightfont = 'font1',
		hilighttext = 'Health',
	})
	scarletLib.layout.addText({
		name = 'healthtext',
		group = 'charframe',
		x = 850,
		y = 28,
		z = 9,
		font = 'font1',
		text = 'Health',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'healthval',
		group = 'charframe',
		x = 1150 - scarletLib.layout.getTextWidth('350 / 350', 'font1') * 1.5,
		y = 28,
		z = 9,
		font = 'font1',
		text = '350 / 350',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'charstamina',
		group = 'charframe',
		x = 790,
		y = 64,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/stamina.png"),
		hilightable = true,
		hilightfont = 'font1',
		hilighttext = 'Stamina',
	})
	scarletLib.layout.addText({
		name = 'staminatext',
		group = 'charframe',
		x = 850,
		y = 82,
		z = 9,
		font = 'font1',
		text = 'Stamina',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'staminaval',
		group = 'charframe',
		x = 1150 - scarletLib.layout.getTextWidth('100 / 100', 'font1') * 1.5,
		y = 82,
		z = 9,
		font = 'font1',
		text = '100 / 100',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'level',
		group = 'charframe',
		x = 400,
		y = 10,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/level.png"),
		hilightable = true,
		hilighttext = 'Level',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'leveltext',
		group = 'charframe',
		x = 460,
		y = 28,
		z = 9,
		font = 'font1',
		text = 'Level',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'levelval',
		group = 'charframe',
		x = 760 - scarletLib.layout.getTextWidth('14', 'font1') * 1.5,
		y = 28,
		z = 9,
		font = 'font1',
		text = '14',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'tolevel',
		group = 'charframe',
		x = 400,
		y = 64,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/tolevel.png"),
		hilightable = true,
		hilighttext = 'Matter Required to Level',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'nexttext',
		group = 'charframe',
		x = 460,
		y = 82,
		z = 9,
		font = 'font1',
		text = 'Matter Needed',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'nextval',
		group = 'charframe',
		x = 760 - scarletLib.layout.getTextWidth('1,850', 'font1') * 1.5,
		y = 82,
		z = 9,
		font = 'font1',
		text = '1,850',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'vitality',
		group = 'charframe',
		x = 10,
		y = 138,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/vitality.png"),
		hilightable = true,
		hilighttext = 'Vitality\nDetermines how much health your character has.',
		hilightfont = 'font1',
	})
	scarletLib.layout.addImage({
		name = 'physical',
		group = 'charframe',
		x = 400,
		y = 138,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/physical.png"),
		hilightable = true,
		hilighttext = 'Physical Defense',
		hilightfont = 'font1',
	})
	scarletLib.layout.addImage({
		name = 'physicallines',
		group = 'charframe',
		x = 424,
		y = 189,
		z = 10,
		img = love.graphics.newImage("/dat/img/hud/deflines.png")
	})
	scarletLib.layout.addText({
		name = 'physicaltext',
		group = 'charframe',
		x = 460,
		y = 156,
		z = 9,
		font = 'font1',
		text = 'Physical Defense',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addImage({
		name = 'slash',
		group = 'charframe',
		x = 454,
		y = 192,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/slash.png"),
		hilightable = true,
		hilighttext = 'Slash Defense',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'slashtext',
		group = 'charframe',
		x = 514,
		y = 210,
		z = 9,
		font = 'font1',
		text = 'Slash',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'slashval',
		group = 'charframe',
		x = 760 - scarletLib.layout.getTextWidth('38', 'font1') * 1.5,
		y = 210,
		z = 9,
		font = 'font1',
		text = '38',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'thrust',
		group = 'charframe',
		x = 454,
		y = 246,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/thrust.png"),
		hilightable = true,
		hilighttext = 'Thrust Defense',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'thrusttext',
		group = 'charframe',
		x = 514,
		y = 264,
		z = 9,
		font = 'font1',
		text = 'Thrust',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'thrustval',
		group = 'charframe',
		x = 760 - scarletLib.layout.getTextWidth('35', 'font1') * 1.5,
		y = 264,
		z = 9,
		font = 'font1',
		text = '35',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'crush',
		group = 'charframe',
		x = 454,
		y = 300,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/crush.png"),
		hilightable = true,
		hilighttext = 'Crush Defense',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'crushtext',
		group = 'charframe',
		x = 514,
		y = 318,
		z = 9,
		font = 'font1',
		text = 'Crush',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'crushval',
		group = 'charframe',
		x = 760 - scarletLib.layout.getTextWidth('31', 'font1') * 1.5,
		y = 318,
		z = 9,
		font = 'font1',
		text = '31',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'magic',
		group = 'charframe',
		x = 400,
		y = 354,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/magic.png"),
		hilightable = true,
		hilighttext = 'Magic Defense',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'magictext',
		group = 'charframe',
		x = 460,
		y = 372,
		z = 9,
		font = 'font1',
		text = 'Magic Def.',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'magicval',
		group = 'charframe',
		x = 760 - scarletLib.layout.getTextWidth('18', 'font1') * 1.5,
		y = 372,
		z = 9,
		font = 'font1',
		text = '18',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'fire',
		group = 'charframe',
		x = 400,
		y = 408,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/fire.png"),
		hilightable = true,
		hilighttext = 'Fire Defense',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'firetext',
		group = 'charframe',
		x = 460,
		y = 426,
		z = 9,
		font = 'font1',
		text = 'Fire Def.',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'fireval',
		group = 'charframe',
		x = 760 - scarletLib.layout.getTextWidth('15', 'font1') * 1.5,
		y = 426,
		z = 9,
		font = 'font1',
		text = '15',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'solar',
		group = 'charframe',
		x = 400,
		y = 462,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/solar.png"),
		hilightable = true,
		hilighttext = 'Light Defense',
		hilightfont = 'font1',
	})
	scarletLib.layout.addImage({
		name = 'balance',
		group = 'charframe',
		x = 400,
		y = 516,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/balance.png"),
		hilightable = true,
		hilighttext = 'Balance',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'balancetext',
		group = 'charframe',
		x = 460,
		y = 534,
		z = 9,
		font = 'font1',
		text = 'Balance',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'balanceval',
		group = 'charframe',
		x = 760 - scarletLib.layout.getTextWidth('45', 'font1') * 1.5,
		y = 534,
		z = 9,
		font = 'font1',
		text = '45',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addText({
		name = 'solartext',
		group = 'charframe',
		x = 460,
		y = 480,
		z = 9,
		font = 'font1',
		text = 'Light Def.',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'solarval',
		group = 'charframe',
		x = 760 - scarletLib.layout.getTextWidth('16', 'font1') * 1.5,
		y = 480,
		z = 9,
		font = 'font1',
		text = '16',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addText({
		name = 'vitalitytext',
		group = 'charframe',
		x = 70,
		y = 154,
		z = 9,
		font = 'font1',
		text = 'Vitality',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'vitalityval',
		group = 'charframe',
		x = 370 - scarletLib.layout.getTextWidth('12', 'font1') * 1.5,
		y = 154,
		z = 9,
		font = 'font1',
		text = '12',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'endurance',
		group = 'charframe',
		x = 10,
		y = 192,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/endurance.png"),
		hilightable = true,
		hilighttext = 'Endurance\nDetermines how much stamina your character has.',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'endurancetext',
		group = 'charframe',
		x = 70,
		y = 208,
		z = 9,
		font = 'font1',
		text = 'Endurance',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'enduranceval',
		group = 'charframe',
		x = 370 - scarletLib.layout.getTextWidth('14', 'font1') * 1.5,
		y = 208,
		z = 9,
		font = 'font1',
		text = '14',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'stability',
		group = 'charframe',
		x = 10,
		y = 246,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/stability.png"),
		hilightable = true,
		hilighttext = 'Stability\nDetermines how much weight your character is able to carry.',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'stabilitytext',
		group = 'charframe',
		x = 70,
		y = 266,
		z = 9,
		font = 'font1',
		text = 'Stability',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'stabilityval',
		group = 'charframe',
		x = 370 - scarletLib.layout.getTextWidth('11', 'font1') * 1.5,
		y = 266,
		z = 9,
		font = 'font1',
		text = '11',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'strength',
		group = 'charframe',
		x = 10,
		y = 300,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/strength.png"),
		hilightable = true,
		hilighttext = 'Strength\nDetermines your damage done with strength based weapons.',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'strengthtext',
		group = 'charframe',
		x = 70,
		y = 318,
		z = 9,
		font = 'font1',
		text = 'Strength',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'strengthval',
		group = 'charframe',
		x = 370 - scarletLib.layout.getTextWidth('12', 'font1') * 1.5,
		y = 318,
		z = 9,
		font = 'font1',
		text = '12',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'dexterity',
		group = 'charframe',
		x = 10,
		y = 354,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/dexterity.png"),
		hilightable = true,
		hilighttext = 'Dexterity\nDetermines your damage done with dexterity based weapons.',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'dexteritytext',
		group = 'charframe',
		x = 70,
		y = 372,
		z = 9,
		font = 'font1',
		text = 'Dexterity',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'dexterityval',
		group = 'charframe',
		x = 370 - scarletLib.layout.getTextWidth('9', 'font1') * 1.5,
		y = 372,
		z = 9,
		font = 'font1',
		text = '9',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'intelligence',
		group = 'charframe',
		x = 10,
		y = 408,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/intelligence.png"),
		hilightable = true,
		hilighttext = 'Intelligence\nDetermines your apptitude with magical spells.',
		hilightfont = 'font1',
	})
	scarletLib.layout.addImage({
		name = 'wisdom',
		group = 'charframe',
		x = 10,
		y = 516,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/wisdom.png"),
		hilightable = true,
		hilighttext = 'Wisdom\nDetermines your capacity to attune spells.',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'intelligencetext',
		group = 'charframe',
		x = 70,
		y = 426,
		z = 9,
		font = 'font1',
		text = 'Intelligence',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'intelligenceval',
		group = 'charframe',
		x = 370 - scarletLib.layout.getTextWidth('4', 'font1') * 1.5,
		y = 426,
		z = 9,
		font = 'font1',
		text = '4',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addImage({
		name = 'soul',
		group = 'charframe',
		x = 10,
		y = 462,
		sx = 3,
		sy = 3,
		z = 9,
		img = love.graphics.newImage("/dat/img/hud/soul.png"),
		hilightable = true,
		hilighttext = 'Resolve\nDetermines your resolve to control your inner flame.',
		hilightfont = 'font1',
	})
	scarletLib.layout.addText({
		name = 'soultext',
		group = 'charframe',
		x = 70,
		y = 480,
		z = 9,
		font = 'font1',
		text = 'Resolve',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'soulval',
		group = 'charframe',
		x = 370 - scarletLib.layout.getTextWidth('5', 'font1') * 1.5,
		y = 480,
		z = 9,
		font = 'font1',
		text = '5',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.addText({
		name = 'wisdomtext',
		group = 'charframe',
		x = 70,
		y = 532,
		z = 9,
		font = 'font1',
		text = 'Wisdom',
		zoom = 1.5,
		color = {150, 150, 150, 255}
	})
	scarletLib.layout.addText({
		name = 'wisdomval',
		group = 'charframe',
		x = 370 - scarletLib.layout.getTextWidth('3', 'font1') * 1.5,
		y = 532,
		z = 9,
		font = 'font1',
		text = '3',
		zoom = 1.5,
		color = {200, 200, 200, 255},
	})
	scarletLib.layout.changeElementGroup('charframe', 'disabled', true)
end

function game.playerUpdateHud(dt)
	love.mouse.setVisible(false)
	--- Character
	if menu then 
		game.drawItemDesc(true, false)
		game.playerUpdateWeightLimit()
		local d = game.actorGetDefense(player)
		local wepdam = ''
		local wepname = 'Empty'
		local wepdamt = '---'
		local offtype = '---'
		local offname = 'Empty'
		if player.weapon then 
			wepdam = game.actorGetWeaponDamage(player)
			wepname = player.weapon.dname 
			wepdamt = player.weapon.dtype:gsub("^%l", string.upper)
		end
		if player.offhand then 
			offtype = player.offhand.type 
			offname = player.offhand.dname
		end
		local u = {
			nameval = {player.name,380},
			classval = {player.class, 380},
			vitalityval = {game.actorGetVitality(player),375},
			enduranceval = {game.actorGetEndurance(player),375},
			stabilityval = {game.actorGetStability(player),375},
			strengthval = {game.actorGetStrength(player),375},
			dexterityval = {game.actorGetDexterity(player),375},
			intelligenceval = {game.actorGetIntelligence(player),375},
			soulval = {game.actorGetSoulpower(player),375},
			wisdomval = {game.actorGetWisdom(player),375},
			levelval = {player.level,770},
			nextval = {game.formatNumber(game.actorMatterNeeded(player)),770},
			slashval = {d.slash,770},
			thrustval = {d.thrust,770},
			crushval = {d.crush,770},
			magicval = {d.magic,770},
			fireval = {d.fire,770},
			solarval = {d.solar,770},
			balanceval = {game.actorGetBalance(player),770},
			healthval = {player.healthCur .. ' / ' .. game.actorGetHealthMax(player), 1160},
			staminaval = {math.floor(player.staminaCur) .. ' / ' .. game.actorGetStaminaMax(player), 1160},
			weapondamval = {wepdam,1160},
			weapondamtext = {wepdamt,918},
			weapontext = {wepname, 918},
			offhandweapontypetext = {(offtype:gsub("^%l", string.upper)),918},
			offhandweapontext = {offname,918},
			weightval = {game.actorGetWeightCur(player) .. ' / ' .. game.actorGetWeightMax(player), 1160},
			deathval = {(game.actorGetMobility(player):gsub("^%l", string.upper)),1160}
		}	
		for k,v in pairs(u) do
			scarletLib.layout.changeElement(k, 'text', v[1])
			if k == 'weapondamtext' or k == 'weapontext' or k == 'offhandweapontypetext' or k == 'offhandweapontext' then 
				scarletLib.layout.changeElement(k, 'x', v[2] - scarletLib.layout.getValue(k, 'x'), true)
			else
				scarletLib.layout.changeElement(k, 'x', v[2] - scarletLib.layout.getTextWidth(v[1], 'font1') * 1.5 - scarletLib.layout.getValue(k, 'x'), true)
			end
		end
		if player.weapon then 
			scarletLib.layout.changeElement('weapondam', 'img', img.hud[player.weapon.dtype])
			scarletLib.layout.changeElement('weapon', 'img', player.weapon.icon)
		else 
			scarletLib.layout.changeElement('weapondam', 'img', img.hud.empty)
			scarletLib.layout.changeElement('weapon', 'img', img.hud.empty)
		end
		if player.offhand then 
			scarletLib.layout.changeElement('offhandweapon', 'img', player.offhand.icon)
		else
			scarletLib.layout.changeElement('offhandweapon', 'img', img.hud.empty)
		end
		u = {
			mainhand = player.weapon,
			offhand = player.offhand,
			head = player.armorHead,
			chest = player.armorChest,
			ring1 = player.rings[1],
			ring2 = player.rings[2],
			ring3 = player.rings[3],
		}
		for k,v in pairs(u) do
			if v then 
				scarletLib.layout.changeElement('equip'..k ..'img', 'img', v.icon)
				scarletLib.layout.changeElement('equip'..k ..'text', 'text', v.dname)
				scarletLib.layout.changeElement('equip'..k ..'text', 'color', {255,255,255})
			else
				scarletLib.layout.changeElement('equip'..k ..'img', 'img', img.hud.empty)
				scarletLib.layout.changeElement('equip'..k ..'text', 'text', 'Empty')
				scarletLib.layout.changeElement('equip'..k ..'text', 'color', {150,150,150})
			end
		end
		if not scarletLib.layout.getValue('inventory', 'disabled') then 
			game.playerUpdateInventory(dt)
		end
		scarletLib.layout.changeElementGroup('weightframe', 'y', 677 - scarletLib.layout.getValue('weightframe1', 'y'), true)
		scarletLib.layout.changeElementGroup('charframe', 'y', 100 - scarletLib.layout.getValue('charframe1', 'y'), true)
		scarletLib.layout.changeElementGroup('levelup', 'y', 100 - scarletLib.layout.getValue('charframe1', 'y'), true)
		scarletLib.layout.changeElementGroup('equipment', 'y', 100 - scarletLib.layout.getValue('equipmentframe1', 'y'), true)
		scarletLib.layout.changeElementGroup('cryo', 'y', 100 - scarletLib.layout.getValue('cryoframe1', 'y'), true)
		scarletLib.layout.modifyElementGroup('inventory', 'y', 100 - scarletLib.layout.getValue('invframe1', 'y'), true)
		scarletLib.layout.changeElementGroup('inv', 'y', 100 - scarletLib.layout.getValue('invframe1', 'y'), true)
		scarletLib.layout.changeElementGroup('weightframe', 'x', 10 - scarletLib.layout.getValue('weightframe1', 'x'), true)
		scarletLib.layout.changeElementGroup('charframe', 'x', 10 - scarletLib.layout.getValue('charframe1', 'x'), true)
		scarletLib.layout.changeElementGroup('levelup', 'x', 10 - scarletLib.layout.getValue('charframe1', 'x'), true)
		scarletLib.layout.changeElementGroup('equipment', 'x', 10 - scarletLib.layout.getValue('equipmentframe1', 'x'), true)
		scarletLib.layout.changeElementGroup('cryo', 'x', 10 - scarletLib.layout.getValue('cryoframe1', 'x'), true)
		scarletLib.layout.modifyElementGroup('inventory', 'x', 10 - scarletLib.layout.getValue('invframe1', 'x'), true)
		scarletLib.layout.changeElementGroup('inv', 'x', 10 - scarletLib.layout.getValue('invframe1', 'x'), true)
	else
		scarletLib.layout.deleteByGroup('item')
	end
	--- UI
	if not player.darkMatterIntake then 
		scarletLib.layout.changeElement('darkMatterCount', 'color', {150,150,150})
	else
		scarletLib.layout.changeElement('darkMatterCount', 'color', {255,255,255})
	end
	if player.darkMatterIntake then 
		scarletLib.layout.changeElement('playericon', 'shadercolor', {player.color[1], player.color[2], player.color[3]})
	else
		scarletLib.layout.changeElement('playericon', 'shadercolor', {player.color[1] * 0.7, player.color[2] * 0.7, player.color[3] * 0.7})
	end
	scarletLib.layout.changeElement('mattercounttext', 'text', game.formatNumber(player.matter))
	scarletLib.layout.changeElementGroup('matter', 'x', love.graphics.getWidth() - 63 - scarletLib.layout.getValue('mattercount', 'x'), true)
	scarletLib.layout.changeElementGroup('mattertext', 'x', love.graphics.getWidth() - 55 - scarletLib.layout.getTextWidth(scarletLib.layout.getValue('mattercounttext', 'text'), 'font1') * 1.5 - scarletLib.layout.getValue('mattercounttext', 'x'), true)
	scarletLib.layout.changeElementGroup('mattertext2', 'x', love.graphics.getWidth() - 121 - scarletLib.layout.getValue('mattertext2', 'x'), true)
	scarletLib.layout.changeElementGroup('matter', 'y', love.graphics.getHeight() - 71 - scarletLib.layout.getValue('mattercount', 'y'), true)
	scarletLib.layout.changeElementGroup('mattertext', 'y', love.graphics.getHeight() - 56 - scarletLib.layout.getValue('mattercounttext', 'y'), true)
	scarletLib.layout.changeElementGroup('mattertext2', 'y', love.graphics.getHeight() - 31 - scarletLib.layout.getValue('mattertext2', 'y'), true)
	scarletLib.layout.changeElement('darkMatterCount', 'text', player.darkMatter)
	scarletLib.layout.changeElement('darkMatterCount', 'x', (46 - (scarletLib.layout.getTextWidth(player.darkMatter, 'font1') * 1.5 / 2)) - scarletLib.layout.getValue('darkMatterCount', 'x'), true)
	scarletLib.layout.changeElement('stamina', 'width', player.staminaMax * 2)
	scarletLib.layout.changeElement('stamina', 'minval', player.staminaCur)
	scarletLib.layout.changeElement('stamina', 'maxval', player.staminaMax)
	scarletLib.layout.changeElement('stamina', 'hilighttext', 'Stamina - ' .. math.floor(player.staminaCur) .. ' / ' .. player.staminaMax)
	scarletLib.layout.changeElement('health', 'width', ((player.healthMax * 1.5) - scarletLib.layout.getValue('health', 'width')) * dt * 5, true)
	scarletLib.layout.changeElement('health', 'minval', player.healthCur)
	scarletLib.layout.changeElement('health', 'maxval', player.healthMax)
	scarletLib.layout.changeElement('health', 'hilighttext', 'Health - ' .. math.floor(player.healthCur) .. ' / ' .. player.healthMax)
	for i = 1, 15 do 
		if player.hasPhotonicFlask then 
			if player.healsCur >= i then 
				scarletLib.layout.changeElement('heal'..i, 'img', img.hud.heal)
				scarletLib.layout.changeElement('heal'..i, 'hilighttext', 'Full Health Potion')
			else
				scarletLib.layout.changeElement('heal'..i, 'img', img.hud.healout)
				scarletLib.layout.changeElement('heal'..i, 'hilighttext', 'Empty Health Potion')
			end
			if player.healsMax < i then 
				scarletLib.layout.changeElement('heal'..i, 'disabled', true)
			else
				scarletLib.layout.changeElement('heal'..i, 'disabled', false)
			end
		else
			scarletLib.layout.changeElement('heal'..i, 'disabled', true)
		end
	end
end

function game.playerDrawSpellHUD()
	local k = player.attuneSlotFocus
	if # player.attunement > 0 then 
		for i = 3, 1, -1 do 
			k = k + 1
			if k > # player.attunement then 
				k = 1
			end
			local look = player.attunement[k]
			if look then 
				love.graphics.setColor(200 + i * -50, 200 + i * -50, 200 + i * -50, 255)
				love.graphics.draw(look.spell.icon, 34 + i * 40, love.graphics.getHeight() - 65, 0, 3, 3, 8, 8)
			end
		end
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(player.attunement[player.attuneSlotFocus].spell.icon, 34, love.graphics.getHeight() - 65, 0, 3, 3, 8, 8)
		if love.keyboard.isDown('e') then 
			love.graphics.setColor(255, 255, 255, 100)
			love.graphics.rectangle('fill', 16, love.graphics.getHeight() - 83, 42, 42)
		end
		love.graphics.setFont(scarletLib.layout.getFont('font1'))
		love.graphics.setColor(150, 150, 150, 255)
		love.graphics.print(player.attunement[player.attuneSlotFocus].casts .. '. ' .. player.attunement[player.attuneSlotFocus].spell.dname, 15, love.graphics.getHeight() - 30, 0, 1.5, 1.5)
		love.graphics.setFont(love.graphics.getFont())
		love.graphics.setColor(255, 255, 255, 255)
	end
end

---
--- Actors
---
function game.updateActors(dt)
	for i = # actors, 1, -1 do 
		if actors[i].falling and not actors[i].inGrapple then 
			if actors[i].intfall then 
				if actors[i].intfall[2] > 0 then 
					actors[i].intfall[2] = actors[i].intfall[2] * 2
				end
				game.killActor(actors[i])
				actors[i].x = actors[i].x + actors[i].intfall[1] * 5
				actors[i].y = actors[i].y + actors[i].intfall[2] * 3
				actors[i].intfall = false
			end
			actors[i].dx = 0
			actors[i].dy = 0
			actors[i].dir = 'south'
			actors[i].falling.dt = actors[i].falling.dt - dt
			actors[i].falling.time = actors[i].falling.time + dt
			if actors[i].falling.dt < 0 then 
				actors[i].falling.dt = 0.08
				--actors[i].falling.dt = 0.5
				actors[i].sx = math.max(0, actors[i].sx - actors[i].falling.step)
				actors[i].sy = math.max(0, actors[i].sy - actors[i].falling.step)
				actors[i].falling.step = math.max(0.05, actors[i].falling.step - 0.05)
			end
		end
		if not actors[i].dead then 
			actors[i].balanceCur = math.min(game.actorGetBalance(actors[i]), actors[i].balanceCur + game.actorGetBalance(actors[i]) * dt / 30)
			actors[i].walkPart = actors[i].walkPart - dt
			actors[i].block = actors[i].block - dt
			actors[i].invul = actors[i].invul - dt
			actors[i].hurt = actors[i].hurt - dt
			actors[i].staminaGainCD = actors[i].staminaGainCD - dt
			actors[i].slow = math.max(0, actors[i].slow - 0.5 * dt)
			actors[i].intakeColorTimer = actors[i].intakeColorTimer + (dt * love.math.random(75, 200) / 100)
			if actors[i].sprint then 
				actors[i].sprint = actors[i].sprint - dt 
			end
			if (actors[i].intakeColorTimer >= 5.75 and actors[i].darkMatterIntake) or actors[i].intakeColorTimer >= 2 * math.pi then 
				if actors[i].darkMatterIntake then 
					actors[i].intakeColorTimer = 1
				else
					actors[i].intakeColorTimer = 0
				end
			end
			if not actors[i].disabled then 
				actors[i].lastCoords[4] = actors[i].lastCoords[3]
				actors[i].lastCoords[3] = actors[i].lastCoords[2]
				actors[i].lastCoords[2] = actors[i].lastCoords[1]
				actors[i].lastCoords[1] = {actors[i].x, actors[i].y}
				if not actors[i].dead then 
					local mob = game.actorGetMobility(actors[i])
					if not actors[i].dead then 
						game.updateActorMovement(actors[i], dt)
					end
					if actors[i].playerType then 
						game.updatePlayerTypeStats(actors[i], dt)
						game.updatePlayerType(actors[i], dt)
					end
					if actors[i].update then 
						game.updatePlayerTypeStats(actors[i], dt)
						actors[i] = actors[i].update(actors[i], game, dt)
					end
					actors[i].wepScale = math.min(actors[i].wepScale + 10 * dt, 1)
					if actors[i].staminaCur < 0 then 
						actors[i].staminaCur = 0 
						if actors[i] == player then
							actors[i].staminaGainCD = 2
						end
					end
					if not actors[i].noticed and actors[i].healthCur < actors[i].healthMax then 
						actors[i].noticed = true 
					end
					if actors[i].sprint > 0 then 
						actors[i].staminaGainCD = 0.1
						actors[i].staminaCur = actors[i].staminaCur - 15 * dt 
						if actors[i].staminaCur <= 0 then 
							actors[i].staminaCur = 0 
							actors[i].staminaGainCD = 2
						end
					end
					if actors[i].staminaGainCD <= 0 then 
						local gain = 35
						if actors[i] ~= player then 
							gain = 50
						end
						if actors[i].state == 'shield' then 
							gain = gain * 0.05
						elseif actors[i].state == 'stun' then 
							gain = gain * 0
						end
						if mob == 'slow' then 
							gain = gain * 0.8 
						elseif mob == 'fast' then 
							gain = gain * 1.1
						end
						actors[i].staminaCur = math.min(actors[i].staminaCur + gain * dt, actors[i].staminaMax)
					end
					if actors[i].ai then 
						if actors[i].ai == 'wander' then 
							game.updateActorAIWander(actors[i], dt)
						elseif actors[i].ai == 'simple' then 
							game.updateActorAISimple(actors[i], dt)
						elseif actors[i].ai == 'lost' then 
							game.updateActorAILost(actors[i], dt)
						elseif actors[i].ai == 'advlost' then 
							game.updateActorAIAdvLost(actors[i], dt)
						elseif actors[i].ai == 'tutboss' then 
							game.updateActorAITutBoss(actors[i], dt)
						end
					end
					if actors[i].backstab then 
						if actors[i].backstab.dt <= 0 then 
							actors[i].backstab.other.healthCur = actors[i].backstab.other.healthCur - 1 
						end
						actors[i].invul = 0.05
						actors[i].backstab.dt = actors[i].backstab.dt + dt
						actors[i].x = actors[i].backstab.sx 
						actors[i].y = actors[i].backstab.sy 
						actors[i].backstab.other.x = actors[i].backstab.ox 
						actors[i].backstab.other.y = actors[i].backstab.oy
						actors[i].backstab.other.state = 'idle'
						actors[i].walkPart = 1
						actors[i].backstab.other.walkPart = 1
						actors[i].dir = actors[i].backstab.dir 
						actors[i].backstab.other.dir = actors[i].backstab.dir
						actors[i].backstab.other.disabled = true
						if actors[i].backstab.dt >= 0.5 and actors[i].state == 'idle' then 
							game.actorTakeDamage(actors[i].backstab.other, game.actorGetWeaponDamage(actors[i]) * actors[i].weapon.backstabBonus, actors[i].weapon.dtype, actors[i].x, actors[i].y, 0.5, 0, -0.35)
							actors[i].backstab.other.disabled = false
							actors[i].backstab = false
						end
					end
				end
				--- update falling
				if not actors[i].inGrapple then 
					local allfall = 0
					local allfalltable = {{-5,9,-1,-1},{5,9,1,-1},{-5,15,-1,1},{5,15,1,1}}
					local falldx = 0
					local falldy = 0
					for ii = 1, 4 do 
						local it, le = world:queryPoint(actors[i].x + allfalltable[ii][1], actors[i].y + allfalltable[ii][2])
						actors[i].onLadder = false
						if le > 0 then 
							local dropped = false
							for j = 1, le do 
								if it[j].type == 'bg' and not dropped then 
									allfall = allfall + 1
									dropped = true
									falldx = falldx + allfalltable[ii][3]
									falldy = falldy + allfalltable[ii][4]
								elseif it[j].type == 'ladder' then 
									local newX = math.ceil(it[j].x + it[j].w / 2)
									local newY = actors[i].y 
									local aX, aY, cols, len = world:move(actors[i], newX, newY, function(item, other) if other.type == 'bg'or other.type == 'ladder' or other.type == 'ladder' then return false else return 'slide' end end)
									actors[i].x = aX	
									actors[i].onLadder = true
									actors[i].dir = 'north'
								end
							end
						end
					end
					if not actors[i].flying then 
						if allfall >= 4 and not actors[i].falling and actors[i].infall > 0.5 and not actors[i].inGrapple then
							actors[i].falling = {dt = 0, step = 0.2, time = 0}
							game.playSound('fall', actors[i].x, actors[i].y)
						elseif allfall > 0 then 
							if allfall == 1 then 
								falldx = falldx * 2
								falldy = falldy * 2
							end
							if not actors[i].intfall and not actors[i].falling then 
								actors[i].intfall = {falldx, falldy}
							end
							if math.floor(actors[i].infall * 100) % 7 == 0 and not actors[i].falling and not actors[i].dead and not actors[i].inGrapple then 
								game.emitParticlesAt('sweat', actors[i].x + 2, actors[i].y - 13, 1)
							end
							actors[i].infall = actors[i].infall + dt
						elseif allfall == 0 then 
							actors[i].infall = 0
							actors[i].intfall = false
						end
						actors[i].dx = actors[i].dx + (falldx * (actors[i].acceleration * math.min(0.25, actors[i].infall * 2))) * dt 
						actors[i].dy = actors[i].dy + (falldy * (actors[i].acceleration * math.min(0.25, actors[i].infall * 2))) * dt
					end
				end
			end
		end
		if i > 1 then 
			if actors[i].y < actors[i-1].y then 
				local t = actors[i]
				actors[i] = actors[i-1]
				actors[i-1] = t 
			end
		end
		if actors[i].dead and not actors[i].falling then 
			table.remove(actors, i)
		end
	end
end

function game.drawActors()
	local x, y = 0, 0
	for i = 1, # actors do 
		x, y = camera:cameraCoords(actors[i].x, actors[i].y)
		if x > -32 and y > -32 and x < love.graphics.getWidth() + 32 and y < love.graphics.getHeight() + 32 then 
			if actors[i].playerType and not actors[i].draw then 
				game.drawPlayerType(actors[i])
			elseif actors[i].draw then 
				game.actorSetColor(actors[i])
				love.graphics.setShader(replaceColor)
				actors[i] = actors[i].draw(actors[i], game)
				love.graphics.setShader()
				if actors[i] ~= player and not actors[i].dead and actors[i].healthCur < actors[i].healthMax and not actors[i].boss then 
					love.graphics.setColor(100, 100, 100, 255)
					love.graphics.rectangle('fill', actors[i].x - 12, actors[i].y - 23, 24, 1)
					love.graphics.rectangle('fill', actors[i].x - 10, actors[i].y - 20, 20, 1)
					love.graphics.setColor(200, 0, 0, 255)
					love.graphics.rectangle('fill', actors[i].x - 12, actors[i].y - 23, 24 * (actors[i].healthCur / actors[i].healthMax), 1)
					love.graphics.setColor(255, 255, 255, 255)
				end
			end
		end
	end
end

function game.drawBossBar()
	for i = 1, # actors do 
		if actors[i].boss and not actors[i].dead and actors[i].noticed then 
			love.graphics.setColor(150, 150, 150, 255)
			love.graphics.print(actors[i].dname, 200, love.graphics.getHeight() - 69, 0, 1.5, 1.5)
			love.graphics.rectangle('fill', 196, love.graphics.getHeight() - 44, (love.graphics.getWidth() - 392), 20)
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.rectangle('fill', 200, love.graphics.getHeight() - 40, (love.graphics.getWidth() - 400), 12)
			love.graphics.setColor(200, 0, 0, 255)
			love.graphics.rectangle('fill', 200, love.graphics.getHeight() - 40, (love.graphics.getWidth() - 400) * (actors[i].healthCur / actors[i].healthMax), 12)
			love.graphics.setColor(255, 255, 255, 255)
		end
	end
end

function game.updateActorAIAdvLost(actor, dt)
	if not actor.storedEquipment and not actor.noticed then 
		actor.storedEquipment = {actor.weapon, actor.offhand}
		actor.weapon = false 
		actor.offhand = false 
	elseif actor.noticed then 
		if actor.weapon ~= actor.storedEquipment[1] or actor.offhand ~= actor.storedEquipment[2] then 
			actor.wepscale = 0
		end
		actor.weapon = actor.storedEquipment[1]
		actor.offhand = actor.storedEquipment[2]
	end
	if actor.healthCur < actor.healthMax then 
		actor.ai = 'simple'
	end
end

function game.updateActorAILost(actor, dt)
	if not actor.storedEquipment and not actor.noticed then 
		actor.storedEquipment = {actor.weapon, actor.offhand}
		actor.weapon = false 
		actor.offhand = false 
	elseif actor.noticed then 
		if actor.weapon ~= actor.storedEquipment[1] or actor.offhand ~= actor.storedEquipment[2] then 
			actor.wepscale = 0
		end
		actor.weapon = actor.storedEquipment[1]
		actor.offhand = actor.storedEquipment[2]
	end
	if actor.healthCur < actor.healthMax then 
		actor.ai = 'wander'
	end
end

function game.updateActorAITutBoss(actor, dt)
	local angle = math.atan2(player.y - actor.y, player.x - actor.x)
	local atp = false
	if math.sqrt((player.y - actor.y)^2 + (player.x - actor.x)^2) <= actor.leash then 
		actor.noticed = true 
	end
	if not actor.noticed then 
		return 
	end
	if actor.state == 'idle' or actor.state == 'shield' then 
		if actor.staminaCur >= actor.staminaMax * 0.25 then 
			if math.sqrt((player.y - actor.y)^2 + (player.x - actor.x)^2) >= actor.weapon.aiAttackRange - 10 then 
				actor.dx = actor.dx + math.cos(angle) * actor.acceleration * dt
				actor.dy = actor.dy + math.sin(angle) * actor.acceleration * dt
			end
			if angle < 0 then angle = angle + 2 * math.pi end
			if angle > math.pi / 4 and angle <= 3 * math.pi / 4 then
				game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'south')
				atp = 'south'
			elseif angle > 3 * math.pi / 4 and angle <= 5 * math.pi / 4 then 
				game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'west')
				atp = 'west'
			elseif angle > 5 * math.pi / 4 and angle <= 7 * math.pi / 4 then 
				game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'north')
				atp = 'north'
			else
				game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'east')
				atp = 'east'
			end
			local atkchance = 100
			if actor.offhand and actor.offhand.offattack and actor.offhand.offattack[1] == 'shield' and actor.staminaCur > actor.staminaMax * 0.25 then 
				atkchance = 3
			end
			local toatk = false 
			local facing = false 
			if actor.dir == 'north' and atp == 'north' then 
				facing = true 
			elseif actor.dir == 'south' and atp == 'south' then 
				facing = true 
			elseif actor.dir == 'west' and atp == 'west' then 
				facing = true 
			elseif actor.dir == 'east' and atp == 'east' then 
				facing = true 
			end
			if actor.weapon.aiAttackRange >= math.sqrt( (player.x - actor.x)^2 + (player.y - actor.y)^2 ) and actor.staminaCur > 0 and love.math.random(1, 150) <= atkchance and facing then 
				toatk = true
			elseif actor.weapon.aiAttackRange >= math.sqrt( (player.x - actor.x)^2 + (player.y - actor.y)^2 ) and player.state == 'drink' and facing then 
				toatk = true
			end
			if toatk and actor.state == 'idle' then 
				game.actorUseMainhand(actor)
				if love.math.random(1, 100) <= 25 then 
					actor.state = 'largeswing1'
				elseif love.math.random(1, 100) <= 70 then 
					actor.state = 'swordsmash2'
				else 
					actor.state = 'stab3'
				end
			elseif math.sqrt((player.x - actor.x)^2 + (player.y - actor.y)^2) <= 140 and math.sqrt((player.x - actor.x)^2 + (player.y - actor.y)^2) > 80 and love.math.random(1, 200) <= 2 then 
				game.actorUseMainhand(actor)
				actor.dir = atp
				actor.state = 'swordlungesmash1'
			end
		else
			if math.sqrt( (actor.x - player.x)^2 + (actor.y - player.y)^2 ) <= 90 and actor.weapon.aiAttackRange <= 100 then 
				actor.dx = actor.dx - math.cos(angle) * actor.acceleration * dt
				actor.dy = actor.dy - math.sin(angle) * actor.acceleration * dt
				if angle < 0 then angle = angle + 2 * math.pi end
				if angle > math.pi / 4 and angle <= 3 * math.pi / 4 then
					game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'north')
					atp = 'south'
				elseif angle > 3 * math.pi / 4 and angle <= 5 * math.pi / 4 then 
					game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'east')
					atp = 'west'
				elseif angle > 5 * math.pi / 4 and angle <= 7 * math.pi / 4 then 
					game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'south')
					atp = 'north'
				else
					game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'west')
					atp = 'east'
				end
			end
		end
	end
end

function game.updateActorAISimple(actor, dt)
	local angle = math.atan2(player.y - actor.y, player.x - actor.x)
	local atp = false
	actor.attackCD = actor.attackCD - dt
	if math.sqrt((player.y - actor.y)^2 + (player.x - actor.x)^2) <= actor.leash then 
		actor.noticed = true 
	end
	if not actor.noticed then 
		return 
	end
	if actor.state == 'idle' or actor.state == 'shield' then 
		if actor.staminaCur >= actor.staminaMax * 0.25 then 
			if math.sqrt((player.y - actor.y)^2 + (player.x - actor.x)^2) >= actor.weapon.aiAttackRange - 10 then 
				actor.dx = actor.dx + math.cos(angle) * actor.acceleration * dt
				actor.dy = actor.dy + math.sin(angle) * actor.acceleration * dt
			end
			if angle < 0 then angle = angle + 2 * math.pi end
			if angle > math.pi / 4 and angle <= 3 * math.pi / 4 then
				game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'south')
				atp = 'south'
			elseif angle > 3 * math.pi / 4 and angle <= 5 * math.pi / 4 then 
				game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'west')
				atp = 'west'
			elseif angle > 5 * math.pi / 4 and angle <= 7 * math.pi / 4 then 
				game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'north')
				atp = 'north'
			else
				game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'east')
				atp = 'east'
			end
			if player.state ~= 'idle' and player.state ~= 'dodge' and player.state ~= 'shield' and actor.state ~= 'dodge' and actor.state ~= 'shield' and love.math.random(1, 100) <= 5 and actor.staminaCur > 0 and actor.dir == atp then
				actor.dx = 0
				actor.dy = 0
				if actor.dx == 0 and actor.dy == 0 then 
					local dir = {north = {1,0}, south = {-	1,0}, east = {0,-1}, west = {0,1}}
					actor.dx = dir[actor.dir][2]
					actor.dy = dir[actor.dir][1]
				end
				if actor.dx ~= 0 and actor.dy ~= 0 then 
					actor.dx = actor.dx / 1.3
					actor.dy = actor.dy / 1.3
				end
				actor.staminaCur = actor.staminaCur - 33
				actor.staminaGainCD = 1.5
				actor.state = 'dodge'
				actor.invul = 0.33
				actor.stateTimer = 0.05
				actor.statePhase = 0
			end
			local atkchance = 100
			if actor.offhand and actor.offhand.offattack and actor.offhand.offattack[1] == 'shield' and actor.staminaCur > actor.staminaMax * 0.25 then 
				atkchance = 3
			end
			local toatk = false 
			local facing = false 
			if actor.dir == 'north' and atp == 'north' then 
				facing = true 
			elseif actor.dir == 'south' and atp == 'south' then 
				facing = true 
			elseif actor.dir == 'west' and atp == 'west' then 
				facing = true 
			elseif actor.dir == 'east' and atp == 'east' then 
				facing = true 
			end
			if actor.weapon.aiAttackRange >= math.sqrt( (player.x - actor.x)^2 + (player.y - actor.y)^2 ) and actor.staminaCur > 0 and love.math.random(1, 150) <= atkchance and facing then 
				toatk = true
			elseif actor.weapon.aiAttackRange >= math.sqrt( (player.x - actor.x)^2 + (player.y - actor.y)^2 ) and player.state == 'drink' and facing then 
				toatk = true
			end
			if toatk and actor.attackCD <= 0 then 
				if actor.offhand and actor.offhand.offattack and actor.offhand.offattack[1] == 'offhandstab' and math.sqrt( (player.x - actor.x)^2 + (player.y - actor.y)^2 ) <= 40 then 
					actor.staminaCur = actor.staminaCur - actor.offhand.staminaCost
					actor.state = actor.offhand.offattack[1]
				else
					actor.staminaCur = actor.staminaCur - actor.weapon.staminaCost			
					actor.state = actor.weapon.lightattack[1]
				end
				actor.staminaGainCD = 1.5
				actor.stateTimer = 0
				actor.statePhase = 0
				actor.attackCD = actor.setAttackCD
			elseif actor.offhand and actor.offhand.offattack and actor.offhand.offattack[1] == 'shield' and actor.state ~= 'dodge' and actor.staminaCur > actor.staminaMax * 0.25 and math.sqrt((player.y - actor.y)^2 + (player.x - actor.x)^2) <= 90 then 
				if actor.state ~= 'shield' and actor.state ~= 'stun' then 
					actor.state = actor.offhand.offattack[1]
					actor.stateTimer = 0
					actor.statePhase = 1
				else 
					actor.statePhase = math.max(actor.statePhase, 3)
				end
			elseif actor.attunement and # actor.attunement > 0 and actor.attunement[actor.attuneSlotFocus].casts > 0 and love.math.random(1, 300) <= 1 then 
				actor.state = 'cast'
				actor.stateTimer = 0
				actor.statePhase = 1
			end
		else
			if math.sqrt( (actor.x - player.x)^2 + (actor.y - player.y)^2 ) <= 90 and actor.weapon.aiAttackRange <= 100 then 
				actor.dx = actor.dx - math.cos(angle) * actor.acceleration * dt
				actor.dy = actor.dy - math.sin(angle) * actor.acceleration * dt
				if angle < 0 then angle = angle + 2 * math.pi end
				if angle > math.pi / 4 and angle <= 3 * math.pi / 4 then
					game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'north')
					atp = 'south'
				elseif angle > 3 * math.pi / 4 and angle <= 5 * math.pi / 4 then 
					game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'east')
					atp = 'west'
				elseif angle > 5 * math.pi / 4 and angle <= 7 * math.pi / 4 then 
					game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'south')
					atp = 'north'
				else
					game.actorTurnTowards(actor, {x = player.x, y = player.y}, 'west')
					atp = 'east'
				end
			end
		end
	end
end

function game.updateActorAIWander(actor, dt)
	if actor.state == 'idle' then 
		if love.math.random(1, 100) <= 2 then 
			local die = love.math.random(1, 4)
			if die == 1 then 
				actor.dir = 'north'
			elseif die == 2 then 
				actor.dir = 'south'
			elseif die == 3 then 
				actor.dir = 'east' 
			else 
				actor.dir = 'west'
			end
		end
		if actor.dir == 'north' then 
			actor.dy = actor.dy - actor.acceleration * dt 
		elseif actor.dir == 'south' then 
			actor.dy = actor.dy + actor.acceleration * dt
		elseif actor.dir == 'east' then 
			actor.dx = actor.dx + actor.acceleration * dt 
		else 
			actor.dx = actor.dx - actor.acceleration * dt 
		end
		if actor.weapon and love.math.random(1, 100) <= 2 and actor.weapon.aiAttackRange >= math.sqrt( (player.x - actor.x)^2 + (player.y - actor.y)^2 ) then 
			local angle = math.atan2(player.y - actor.y, player.x - actor.x)
			if angle < 0 then angle = angle + 2 * math.pi end
			if angle > math.pi / 4 and angle <= 3 * math.pi / 4 then 
				actor.dir = 'south'
			elseif angle > 3 * math.pi / 4 and angle <= 5 * math.pi / 4 then 
				actor.dir = 'west'
			elseif angle > 5 * math.pi / 4 and angle <= 7 * math.pi / 4 then 
				actor.dir = 'north'
			else 
				actor.dir = 'east'
			end
			actor.state = actor.weapon.lightattack[1]
			actor.stateTimer = 0
			actor.statePhase = 0
		end
	end
end

function game.updateActorMovement(actor, dt)
	local mxspd = actor.maxSpeed * (1 - actor.slow)
	local dec = actor.deceleration
	local mob = game.actorGetMobility(actor)
	if actor.onLadder then 
		actor.dx = 0 
		mxspd = mxspd * 0.7
	end
	if actor.state == 'shield' then 
		mxspd = (actor.maxSpeed * ((1 - actor.slow)) * 0.4)
	elseif actor.state == 'drink' then
		mxspd = (actor.maxSpeed * ((1 - actor.slow)) * 0.25)
	elseif actor.state == 'cast' then 
		mxspd = (actor.maxSpeed * ((1 - actor.slow)) * 0.25)
	elseif actor.state == 'grapple' then 
		mxspd = 275
	end
	if actor.sprint > 0 and actor.state == 'idle' then 
		mxspd = mxspd * 1.75
		dec = dec * 1.5
	end
	if mob == 'slow' then 
		mxspd = mxspd * 0.8
	elseif mob == 'fast' then 
		mxspd = mxspd * 1
	else
		mxspd = mxspd * 0.9
	end
	if actor.infall > 0 and actor.state ~= 'grapple' then 
		if actor.state == 'dodge' then 
			actor.state = 'idle'
		end
		mxspd = actor.maxSpeed * 0.5
	end
	if actor.state == 'dodge' then 
		local dspd = 130
		local newX = 0
		local newY = 0
		local aX, aY, cols, len = 0, 0, 0, 0
		local part = 3
		local timer = actor.statePhase * 0.05 + (0.05 - actor.stateTimer)
		if mob == 'slow' then 
			dspd = 200 * -((timer * 4) - 1)^2 + 0.001 * (timer * 4) + 200
			dspd = dspd * 0.8
			dec = dec * 1.55
			part = 1
		elseif mob == 'normal' then 
			dspd = 200 * -((timer * 5) - 1)^2 + 0.001 * (timer * 5) + 200
			dspd = dspd * 1
			dec = dec * 1.35
			part = 2
		else 
			dspd = 200 * -((timer * 6) - 1)^2 + 0.001 * (timer * 6) + 200
			dspd = dspd * 1.5
			dec = dec * 1.15
			part = 3
		end
		newX = actor.x + (dspd * actor.dx) * dt 	
		newY = actor.y + (dspd * actor.dy) * dt
		aX, aY, cols, len = world:move(actor, newX, newY, function(item, other) if other.type == 'bg'or other.type == 'ladder' or other.type == 'ladder' then return false else return 'slide' end end)
		actor.x = aX
		actor.y = aY
		if actor.dy > 0 then 
			actor.dir = 'south'
		elseif actor.dy < 0 then 
			actor.dir = 'north'
		end
		if actor.dx > 0 then 
			actor.dir = 'east' 
		elseif actor.dx < 0 then
			actor.dir = 'west'
		end
		if actor.walkPart > 0.005 then 
			actor.walkPart = 0.005
		end
		if actor.walkPart <= 0 and not actor.flying then
			actor.walkPart = love.math.random(200, 300) / 10000
			game.emitParticlesAt('dodge', actor.x, actor.y, part)
		end
		return
	end
	--- Change direction of feet and cap move speed
	if actor.dy < 0 and actor.dy <= mxspd * -1 then 
		actor.dy = mxspd * -1
		actor.moveDir = 'south'
	elseif actor.dy > 0 and actor.dy > mxspd then 
		actor.dy = mxspd
		actor.moveDir = 'north'
	end
	if actor.dx < 0 and actor.dx <= mxspd * -1 then 
		actor.dx = mxspd * -1 
		actor.moveDir = 'west'
	elseif actor.dx > 0 and actor.dx > mxspd then 
		actor.dx = mxspd
		actor.moveDir = 'east'
	end
	--- increment feet animation
	if actor.dx ~= 0 or actor.dy ~= 0 and actor.playerType and not actor.flying then
		if actor.walkPart <= 0 then
			local tx, ty = map:convertPixelToTile(actor.x, actor.y)
			local part = 'smoke'
			local delay = 100
			local oy = 0
			tx, ty = math.floor(tx + 1), math.floor(ty + 1)
			if tx > 0 and ty > 0 and tx < map.width and ty < map.height then 
				part = map:getTileProperties('floor2', tx, ty).walkPart or part
				part = map:getTileProperties('wall1', tx, ty).walkPart or part
			end
			actor.walkPart = love.math.random(20, 45) / delay
			if actor.sprint > 0 then 
				actor.walkPart = love.math.random(5, 15) / delay
			end
			if part == 'waterstep' then 
				delay = 150
			end
			if player.state == 'grapple' then 
				part = 'flight'
				oy = love.math.random(-20, -2)
				actor.walkPart = love.math.random(5, 15) / delay
			end
			if not actor.flying then 
				game.emitParticlesAt(part or 'smoke', actor.x, actor.y + 12 + oy, 1)
			end
		end
		local spd = 7
		if actor.moveDir == 'north' or actor.moveDir == 'south' then 
			spd = 4
			if actor.sprint > 0 then 
				spd = 8
			end
		end
		if actor.sprint > 0 or actor.infall > 0 then 
			spd = 14
			if actor.moveDir == 'east' or actor.moveDir == 'west' then 
				spd = 18
			end
		end
		if actor.state ~= 'dodge' then 
			actor.walkAnim = actor.walkAnim + dt * spd
			if actor.walkAnim > 5 then 
				actor.walkAnim = 1 
			end
		end
	else 
		actor.walkAnim = 1
	end
	--- Attempt to move actor
	--- I'm ashamed of this if statement :(
	if (actor.state == 'idle' or actor.state == 'shield' or actor.state == 'grapple' or actor.state == 'drink' or actor.state == 'cast' or actor.state == 'pyro' or actor.state == 'walk' or actor.state == 'jump') and actor.block <= 0 then 
		local newX = actor.x + actor.dx * dt
		local newY = actor.y + actor.dy * dt	
		local aX, aY, cols, len = world:move(actor, newX - actor.hitBoxWidth / 2, newY - actor.hitBoxHeight / 2, function(item, other) if other.type == 'bg'or other.type == 'ladder' then return false else return 'slide' end end)
		actor.x = aX + actor.hitBoxWidth / 2
		actor.y = aY + actor.hitBoxHeight / 2
	end
	--- Sound
	if actor.state ~= 'grapple' then 
		if actor.dx ~= 0 or actor.dy ~= 0 then 
			if not actor.stepSoundCD then 
				actor.stepSoundCD = 0.35
			end
			actor.stepSoundCD = actor.stepSoundCD - dt 
			if actor.stepSoundCD <= 0 then
				game.playSound('footStepDirt', actor.x, actor.y)
				actor.stepSoundCD = 0.6
				if actor.sprint > 0 then 
					actor.stepSoundCD = 0.15
				end
			end
		end
	end
	--- Apply deceleration
	if actor.state ~= 'grapple' then 
		if actor.dy < 0 then 
			actor.dy = math.min(0, actor.dy + dec * dt)
		elseif actor.dy > 0 then 
			actor.dy = math.max(0, actor.dy - dec * dt)
		end
		if actor.dx < 0 then 
			actor.dx = math.min(0, actor.dx + dec * dt)
		elseif actor.dx > 0 then 
			actor.dx = math.max(0, actor.dx - dec * dt)
		end
	end
end

function game.actorTurnTowards(actor, tar, dir)
	if actor.turnCD > 0 then 
		return actor
	end
	if dir == 'north' and actor.turnCD <= 0 then 
		if actor.dir == 'south' then 
			if tar.x < actor.x then 
				actor.dir = 'west' 
			else 
				actor.dir = 'east' 
			end 
		else
			actor.dir = 'north'
		end
		actor.turnCD = actor.turnCDSet
	elseif dir == 'south' and actor.turnCD <= 0 then 
		if actor.dir == 'north' then 
			if tar.x < actor.x then 
				actor.dir = 'west'
			else 
				actor.dir = 'east'
			end
		else
			actor.dir = 'south'
		end
		actor.turnCD = actor.turnCDSet
	end
	if dir == 'west' and actor.turnCD <= 0 then 
		if actor.dir == 'east' then 
			if tar.y < actor.y then 
				actor.dir = 'north' 
			else 
				actor.dir = 'south' 
			end
		else
			actor.dir = 'west'
		end
		actor.turnCD = actor.turnCDSet
	elseif dir == 'east' and actor.turnCD <= 0 then 
		if actor.dir == 'west' then 
			if tar.y < actor.y then 
				actor.dir = 'north'
			else
				actor.dir = 'south'
			end
		else
			actor.dir = 'east'
		end
		actor.turnCD = actor.turnCDSet
	end
	return actor
end

function game.actorUpdateWeight(actor)
	--- update weight cur
	local w = 0
	if actor.weapon then 
		w = w + actor.weapon.weight 
	end
	if actor.offhand then 
		w = w + actor.offhand.weight 
	end
	if actor.armorChest then 
		w = w + actor.armorChest.weight 
	end
	if actor.armorHead then 
		w = w + actor.armorHead.weight 
	end
	for i = 1, 3 do 
		if actor.rings[i] then 
			w = w + actor.rings[i].weight 
		end
	end
	actor.weightCur = w
end

function game.actorUpdateMobility(actor)
	--- update mobility
	local wc = actor.weightCur
	local wm = game.actorGetWeightMax(actor)
	if wc <= wm * 0.25 then 
		actor.mobility = 'fast'
	elseif wc > wm * 0.25 and wc <= wm * 0.5 then 
		actor.mobility = 'normal'
	else
		actor.mobility =  'slow'
	end
end

function game.updatePlayerType(actor, dt)
	local thand = false
	actor.turnCD = actor.turnCD - dt
	if not actor.weapon then 
		thand = true 
		actor.weapon = weapons.hand 
	end
	game.actorUpdateWeight(actor)
	game.actorUpdateMobility(actor)
	if actor.offhand and actor.offhand.handPart and actor.state == 'idle' and math.floor(dt * 1000) % 2 == 0 then
		game.emitParticlesAt(actor.offhand.handPart, actor.x + actor.offhand.dx[actor.dir], actor.y + actor.offhand.dy[actor.dir], 1)
	end
	--- update player
	if actor.player then 
		if (actor.state == 'idle' or actor.state == 'drink' or actor.state == 'grapple') and not menu and not actor.falling then 
			local mx, my = love.mouse.getPosition()
			local angle = 0
			mx, my = camera:worldCoords(mx, my)
			if actor.state == 'grapple' then 
				mx, my = player.inGrapple.tx, player.inGrapple.ty
			end
			angle = math.atan2(my - actor.y, mx - actor.x)
			if angle < 0 then angle = angle + 2 * math.pi end
			if angle > math.pi / 4 and angle <= 3 * math.pi / 4 and actor.turnCD <= 0 then
				if actor.dir == 'north' then 
					if mx < player.x then 
						actor.dir = 'west' 
					else 
						actor.dir = 'east' 
					end
				else
					actor.dir = 'south'
				end
				actor.turnCD = 0.15
			elseif angle > 3 * math.pi / 4 and angle <= 5 * math.pi / 4 and actor.turnCD <= 0 then 
				if actor.dir == 'east' then 
					if my < player.y then 
						actor.dir = 'north' 
					else 
						actor.dir = 'south' 
					end
				else
					actor.dir = 'west'
				end
				actor.turnCD = 0.15
			elseif angle > 5 * math.pi / 4 and angle <= 7 * math.pi / 4 and actor.turnCD <= 0 then 
				if actor.dir == 'south' then 
					if mx < player.x then 
						actor.dir = 'west' 
					else 
						actor.dir = 'east'
					end
				else
					actor.dir = 'north'
				end
				actor.turnCD = 0.15
			elseif actor.turnCD <= 0 then
				if actor.dir == 'west' then 
					if my < player.y then 
						actor.dir = 'north' 
					else 
						actor.dir = 'south' 
					end
				else
					actor.dir = 'east'
				end
				actor.turnCD = 0.15
			end
		elseif (actor.state == 'idle' or actor.state == 'drink') and menu then 
			if actor.dy < 0 and actor.turnCD <= 0 then 
				if actor.dir == 'south' then 
					if player.x < actor.x then 
						actor.dir = 'west' 
					else 
						actor.dir = 'east' 
					end 
				else
					actor.dir = 'north'
				end
				actor.turnCD = 0.15
			elseif actor.dy > 0 and actor.turnCD <= 0 then 
				if actor.dir == 'north' then 
					if player.x < actor.x then 
						actor.dir = 'west'
					else 
						actor.dir = 'east'
					end
				else
					actor.dir = 'south'
				end
				actor.turnCD = 0.15
			end
			if actor.dx < 0 and actor.turnCD <= 0 then 
				if actor.dir == 'east' then 
					if player.y < actor.y then 
						actor.dir = 'north' 
					else 
						actor.dir = 'south' 
					end
				else
					actor.dir = 'west'
				end
				actor.turnCD = 0.15
			elseif actor.dx > 0 and actor.turnCD <= 0 then 
				if actor.dir == 'west' then 
					if player.y < actor.y then 
						actor.dir = 'north'
					else
						actor.dir = 'south'
					end
				else
					actor.dir = 'east'
				end
				actor.turnCD = 0.15
			end
		end
		player.cryopod = math.max(0, player.cryopod - 225 * dt)
		for k,v in pairs(map.objects) do
			if v.layer.name == 'cryopod' then
				local items, lens = world:querySegment(v.x, v.y, v.x + v.width, v.y + v.height)
				for i = 1, lens do 
					if items[i] == player then 
						if player.cryopod <= 0 then 
							game.reloadMap(curMap)
						elseif player.cryopod <= 94 then
							if player.cryopod <= 4 then 
								snd.cryodoor:stop()
								snd.cryodoor:play()
								game.playSound('cryodoor', player.x, player.y)
							end
							for i = 1, 50 do
								game.emitParticlesAt('cryoheal', love.math.random(0, love.graphics.getWidth()), love.graphics.getHeight() / 2, 5)
							end
						end
						--- in cryo pod!
						lastSpawn = curMap
						player.wepScale = math.max(0, player.wepScale - 15 * dt)
						player.dir = 'south'
						player.dx = 0
						player.x = math.floor(v.x + v.width / 2)
						player.walkAnim = 1
						player.cryopod = math.min(100, player.cryopod + 450 * dt)
						player.healthCur = math.min(player.healthMax, player.healthCur + 100 * dt)
						player.healsCur = player.healsMax
						for i = 1, # player.attunement do 
							player.attunement[i].casts = player.attunement[i].spell.casts
						end
					end
				end
			end
		end
	end
	if actor.state ~= 'idle' then 
		actor.stateTimer = actor.stateTimer - dt 
		if actor.state == 'swing1' then 
			local attack = false
			if actor == player and love.mouse.isDown(1) then 
				attack = true 
			elseif actor ~= player and love.math.random(1, 100) <= 15 and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 32 then 
				attack = true
			end
			game.actorStateSwing1(actor, dt, attack)
		elseif actor.state == 'swordsmash1' then 
			local attack = false
			if actor == player and love.mouse.isDown(1) then 
				attack = true 
			elseif actor ~= player and love.math.random(1, 100) <= 15 and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 32 then 
				attack = true
			end
			game.actorStateSwordSmash1(actor, dt, attack)
		elseif actor.state == 'offhandstab' then 
			local attack = false
			if actor == player and love.mouse.isDown(1) then 
				attack = true 
			elseif actor ~= player and love.math.random(1, 100) <= 15 and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 32 then 
				attack = true
			end
			game.actorStateOffhandStab(actor, dt, attack)
		elseif actor.state == 'pyro' then 
			local attack = false 
			local px, py = 0, 0
			local attack = false
			if actor.lockCoords[1] == 0 and actor.lockCoords[2] == 0 then 
				if actor == player then 
					local mx, my = love.mouse.getPosition()
					actor.lockCoords[1], actor.lockCoords[2] = camera:worldCoords(mx, my)
				else
					actor.lockCoords[1], actor.lockCoords[2] = player.x, player.y 
				end
			end
			if actor == player and love.mouse.isDown(1) then 
				attack = true 
			elseif actor ~= player and love.math.random(1, 100) <= 15 and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 32 then 
				attack = true
			end
			game.actorStatePyro(actor, dt, attack)
		elseif actor.state == 'cast' then 
			local attack = false 
			local px, py = 0, 0
			local attack = false
			if actor.lockCoords[1] == 0 and actor.lockCoords[2] == 0 then 
				if actor == player then 
					local mx, my = love.mouse.getPosition()
					actor.lockCoords[1], actor.lockCoords[2] = camera:worldCoords(mx, my)
				else
					actor.lockCoords[1], actor.lockCoords[2] = player.x, player.y 
				end
			end
			if actor == player and love.mouse.isDown(1) then 
				attack = true 
			elseif actor ~= player and love.math.random(1, 100) <= 15 and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 32 then 
				attack = true
			end
			game.actorStateCast(actor, dt, attack)
		elseif actor.state == 'largeswing1' then 
			local attack = false
			if actor == player and love.mouse.isDown(1) then 
				attack = true 
			elseif actor ~= player and love.math.random(1, 100) <= 15 and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 32 then 
				attack = true
			end
			game.actorStateLargeSwing1(actor, dt, attack)
		elseif actor.state == 'grapple' then 
			game.actorStateGrapple(actor, dt)
		elseif actor.state == 'swordlungesmash1' then 
			local attack = false
			if actor == player and love.mouse.isDown(1) then 
				attack = true 
			elseif actor ~= player and love.math.random(1, 100) <= 15 and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 32 then 
				attack = true
			end
			game.actorStateSwordLungeSmash1(actor, dt, attack)
		elseif actor.state == 'swordsmash2' then 
			local attack = false
			if actor == player and love.mouse.isDown(1) then 
				attack = true 
			elseif actor ~= player and love.math.random(1, 100) <= 15 and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 32 then 
				attack = true
			end
			game.actorStateSwordSmash2(actor, dt, attack)
		elseif actor.state == 'stab3' then 
			local attack = false
			if actor == player and love.mouse.isDown(1) then 
				attack = true 
			elseif actor ~= player and love.math.random(1, 100) <= 15 and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 32 then 
				attack = true
			end
			game.actorStateStab3(actor, dt, attack)
		elseif actor.state == 'stab2' then 
			local attack = false
			if actor == player and love.mouse.isDown(1) then 
				attack = true 
			elseif actor ~= player and love.math.random(1, 100) <= 15 and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 32 then 
				attack = true
			end
			game.actorStateStab2(actor, dt, attack)
		elseif actor.state == 'swing3' then 
			local attack = false
			if actor == player and love.mouse.isDown(1) then 
				attack = true 
			elseif actor ~= player and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 90 then 
				attack = true
			end
			game.actorStateSwing3(actor, dt, attack)
		elseif actor.state == 'swing4' then 
			local attack = false
			if actor == player and love.mouse.isDown(1) then 
				attack = true 
			elseif actor ~= player and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 90 then 
				attack = true
			end
			game.actorStateSwing4(actor, dt, attack)
		elseif actor.state == 'swing2' then 
			local attack = false
			if actor == player and love.mouse.isDown(1) then 
				attack = true 
			elseif actor ~= player and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 90 then 
				attack = true
			end
			game.actorStateSwing2(actor, dt, attack)
		elseif actor.state == 'stab1' then 
			local attack = false 
			if actor == player and love.mouse.isDown(1) then 
				attack = true 
			elseif actor ~= player and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 90 then 
				attack = true
			end
			game.actorStateStab1(actor, dt, attack)
		elseif actor.state == 'shield' then 
			local attack = false 
			if actor == player and love.mouse.isDown(2) then 
				attack = true 
			elseif actor ~= player and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 160 then 
				attack = true
			end
			game.actorStateShield(actor, dt, attack)
		elseif actor.state == 'pull' then 
			local attack = false 
			local px, py = 0, 0
			if actor.lockCoords[1] == 0 and actor.lockCoords[2] == 0 then 
				if actor == player then 
					local mx, my = love.mouse.getPosition()
					actor.lockCoords[1], actor.lockCoords[2] = camera:worldCoords(mx, my)
				else
					actor.lockCoords[1], actor.lockCoords[2] = player.x, player.y 
				end
			end
			if actor == player and love.mouse.isDown(1) then 
				attack = true 
			elseif actor ~= player and math.sqrt((actor.y-player.y)^2 + (actor.x-player.x)^2 ) <= 90 then 
				attack = true
			end
			game.actorStatePull(actor, dt, attack, actor.lockCoords[1], actor.lockCoords[2])
		elseif actor.state == 'stun' then 
			if actor.stateTimer <= 0 then 
				actor.state = 'idle'
			end
		elseif actor.state == 'dodge' then 
			if actor.stateTimer <= 0 then 
				actor.statePhase = actor.statePhase + 1
				actor.stateTimer = 0.05
				if actor.statePhase > 9 and game.actorGetMobility(actor) == 'slow' then 
					actor.state = 'idle'
					actor.turnCD = 0.2
				elseif actor.statePhase > 7 and game.actorGetMobility(actor) == 'normal' then 
					actor.state = 'idle'
					actor.turnCD = 0.2
				elseif actor.statePhase > 6 and game.actorGetMobility(actor) == 'fast' then 
					actor.state = 'idle'
					actor.turnCD = 0.2
				end 
			end
		elseif actor.state == 'drink' then 
			game.actorStateDrink(actor, dt)
		end
		if actor.stateTimer <= 0 then 
			actor.statePhase = actor.statePhase + 1 
			actor.stateTimer = 0.1
		end
	end
	if thand then 
		actor.weapon = false 
	end
end

function game.actorStateGrapple(actor, dt)
	local wep = {
		north = {x = 6, y = -12, rot = 0},
		east = {x = 12, y = -3, rot = 0},
		west = {x = -12, y = -3, rot = 0},
		south = {x = -6, y = 8, rot = 0},
	}
	local off = {
		north = {x = -6, y = 4, rot = 0},
		east = {x = -8, y = 3, rot = 0},
		west = {x = 8, y = 3, rot = 0},
		south = {x = 6, y = -4, rot = 0},
	}
	if math.abs(actor.dx) <= 15 and math.abs(actor.dy) <= 15 then 
		wep = {
			north = {x = 6, y = -8, rot = 0},
			east = {x = 8, y = -3, rot = 0},
			west = {x = -8, y = -3, rot = 0},
			south = {x = -6, y = 4, rot = 0},
		}
		off = {
			north = {x = -6, y = 0, rot = 0},
			east = {x = -4, y = 3, rot = 0},
			west = {x = 4, y = 3, rot = 0},
			south = {x = 6, y = 0, rot = 0},
		}
	end
	actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot}
	actor.offhandAction = {x = off[actor.dir].x, y = off[actor.dir].y, rot = off[actor.dir].rot}
end

function game.actorStateDrink(actor, dt)
	if actor.statePhase >= 12 then 
		actor.state = 'idle'
		actor.wepScale = 0
		actor.weaponAction = {x = 0, y = 0, rot = 0}
	elseif actor.statePhase == 1 then 
		local wep = {
			north = {x = 5, y = 2, rot = 0},
			south = {x = -7, y = 2, rot = 0},
			east = {x = 2, y = 1, rot = 0},
			west = {x = -4, y = 1, rot = 0},
		}
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot}
	elseif actor.statePhase == 2 then 
		local wep = {
			north = {x = 4, y = 0, rot = math.pi * 1.95},
			south = {x = -6, y = 0, rot = math.pi * 0.05},
			east = {x = 3, y = 0, rot = math.pi * 1.99},
			west = {x = -5, y = 0, rot = math.pi * 0.01},
		}
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot}
	elseif actor.statePhase == 3 then 
		local wep = {
			north = {x = 3, y = -1, rot = math.pi * 1.93},
			south = {x = -5, y = -1, rot = math.pi * 0.07},
			east = {x = 4, y = -1, rot = math.pi * 1.96},
			west = {x = -6, y = -1, rot = math.pi * 0.04},
		}
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot}
	elseif actor.statePhase == 4 then 
		local wep = {
			north = {x = 2, y = -2, rot = math.pi * 1.91},
			south = {x = -4, y = -2, rot = math.pi * 0.09},
			east = {x = 4, y = -2, rot = math.pi * 1.93},
			west = {x = -6, y = -2, rot = math.pi * 0.07},
		}
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot}
	elseif actor.statePhase == 5 then 
		local wep = {
			north = {x = 1, y = -2, rot = math.pi * 1.9},
			south = {x = -3, y = -2, rot = math.pi * 0.1},
			east = {x = 4, y = -2, rot = math.pi * 1.91},
			west = {x = -6, y = -2, rot = math.pi * 0.09},
		}
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot}
	elseif actor.statePhase == 6 then 
		local wep = {
			north = {x = 1, y = -2, rot = math.pi * 1.9},
			south = {x = -3, y = -2, rot = math.pi * 0.1},
			east = {x = 4, y = -2, rot = math.pi * 1.91},
			west = {x = -6, y = -2, rot = math.pi * 0.09},
		}
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot}
	elseif actor.statePhase == 7 then 
		local wep = {
			north = {x = 1, y = -2, rot = math.pi * 1.9},
			south = {x = -3, y = -2, rot = math.pi * 0.1},
			east = {x = 4, y = -2, rot = math.pi * 1.91},
			west = {x = -6, y = -2, rot = math.pi * 0.09},
		}
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot}
	elseif actor.statePhase == 8 then 
		local wep = {
			north = {x = 4, y = -2, rot = math.pi * 1.7},
			south = {x = -4, y = -4, rot = math.pi * 0.25},
			east = {x = 6, y = -2, rot = math.pi * 1.7},
			west = {x = -8, y = -4, rot = math.pi * 0.22},
		}
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot}
		if actor.stateTimer <= 0 then 
			actor.healthCur = math.min(actor.healthMax, actor.healthCur + actor.healthMax * 0.4)
			actor.healsCur = actor.healsCur - 1
			actor.slow = 1
			game.playSound('heal', actor.x, actor.y)
		end
	elseif actor.statePhase == 9 then 
		game.emitParticlesAt('healthrestored', actor.x, actor.y, 5)
	elseif actor.statePhae == 10 then 
		game.emitParticlesAt('healthrestored', actor.x, actor.y, 3)
	end
end

function game.actorStateOffhandStab(actor, dt, attack)
	if actor.statePhase < 7 then 
		actor.stateTimer = actor.stateTimer - dt * 5
	end
	local main = {
		north = {x = 4, y = 3, rot = math.pi * 0.15},
		south = {x = -6, y = 5, rot = -math.pi * 0.15},
		east = {x = 5, y = 3, rot = math.pi / 4},
		west = {x = -6, y = 3, rot = 0 - math.pi / 4},
	}
	local wep = {
		{
			north = {x = -5, y = 1, rot = math.pi * 0.5},
			south = {x = 5, y = 2, rot = -math.pi * 0.1},
			east = {x = -4, y = 1, rot = -math.pi * 0.1},
			west = {x = 4, y = 1, rot = math.pi * 0.1},
		},
		{
			north = {x = -6, y = 2, rot = math.pi * 1},
			south = {x = 6, y = -1, rot = -math.pi * 0.05},
			east = {x = -5, y = -1, rot = -math.pi * 0.2},
			west = {x = 5, y = -1, rot = math.pi * 0.2},
		},
		{
			north = {x = -7, y = 3, rot = math.pi * 1.05},
			south = {x = 7, y = -2, rot = 0},
			east = {x = -6, y = -2, rot = -math.pi * 0.3},
			west = {x = 6, y = -2, rot = math.pi * 0.3},
		},
		{
			north = {x = -6, y = 4, rot = math.pi * 1.1},
			south = {x = 6, y = -3, rot = math.pi * 0.05},
			east = {x = -7, y = -3, rot = -math.pi * 0.4},
			west = {x = 7, y = -3, rot = math.pi * 0.4},
		},
		{
			north = {x = -5, y = 4, rot = math.pi * 1.15},
			south = {x = 5, y = -4, rot = math.pi * 0.07},
			east = {x = -8, y = -4, rot = -math.pi * 0.55},
			west = {x = 8, y = -4, rot = math.pi * 0.55},
		},
		{
			north = {x = -4, y = -22, rot = math.pi * 1},
			south = {x = 4, y = 22, rot = 0},
			east = {x = 14, y = -4, rot = -math.pi * 0.5},
			west = {x = -14, y = -4, rot = math.pi * 0.5},
		},
		{
			north = {x = -5, y = -24, rot = math.pi * 1.05},
			south = {x = 5, y = 24, rot = math.pi * 0.05},
			east = {x = 16, y = -3, rot = -math.pi * 0.55},
			west = {x = -16, y = -3, rot = math.pi * 0.55},
		},
	}
	if actor.statePhase >= 8 then 
		if actor.statePhase > 9 then 
			actor.state = 'idle'
			actor.weaponAction = {x = 0, y = 0, rot = 0}
		else
			if actor.stateTimer <= 0 then 
				actor.offhandAction = {
					x = actor.offhandAction.x - (actor.offhandAction.x - actor.offhand.dx[actor.dir]) / 2, 
					y = actor.offhandAction.y - (actor.offhandAction.y - actor.offhand.dy[actor.dir]) / 2, 
					rot = actor.offhandAction.rot - (actor.offhandAction.rot - actor.offhand.rot[actor.dir]) / 2 
				}
			end
		end
	else
		if actor.statePhase == 6 and actor.stateTimer <= 0 then 
			local step = {
				north = {0, -7},
				south = {0, 7},
				east = {6, 0},
				west = {-6, 0},
			}
			local swing = {
				north = {x = -4.5, y = -19, rot = math.pi * 1.5},
				south = {x = 4.5, y = 19, rot = math.pi * 0.5},
				east = {x = 10, y = -5, rot = 0},
				west = {x = -10, y = -4, rot = math.pi},
			}
			local newX, newY = actor.x + step[actor.dir][1], actor.y + step[actor.dir][2]
			local aX, aY, cols, len = world:move(actor, newX, newY, function(item, other) if other.type == 'bg'or other.type == 'ladder' then return false else return 'slide' end end)
			actor.moveDir = actor.dir
			actor.x = newX 
			actor.y = newY 
			if actor.dir == 'north' and not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 5, actor.y - 17 + swing[actor.dir].y, 10, 30, 0.08, game.actorGetOffhandDamage(actor), actor.offhand.dtype, actor.x, actor.y, actor.offhand.stundam, actor.offhand.bdam, actor.offhand.knockback)
			elseif actor.dir == 'south' and not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 5, actor.y - 11 + swing[actor.dir].y, 10, 30, 0.08, game.actorGetOffhandDamage(actor), actor.offhand.dtype, actor.x, actor.y, actor.offhand.stundam, actor.offhand.bdam, actor.offhand.knockback)
			elseif actor.dir == 'east' and not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 12, actor.y - 5 + swing[actor.dir].y, 30, 10, 0.08, game.actorGetOffhandDamage(actor), actor.offhand.dtype, actor.x, actor.y, actor.offhand.stundam, actor.offhand.bdam, actor.offhand.knockback)
			elseif not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 18, actor.y - 6 + swing[actor.dir].y, 30, 10, 0.08, game.actorGetOffhandDamage(actor), actor.offhand.dtype, actor.x, actor.y, actor.offhand.stundam, actor.offhand.bdam, actor.offhand.knockback)
			end
			game.addAnimation('offstab1', actor.x + swing[actor.dir].x, actor.y + swing[actor.dir].y, swing[actor.dir].rot, 0.75, 0.75)
		end
		if actor.statePhase == 6 or actor.statePhase == 7 then 
			actor.walkAnim = 2
			if actor.dir == 'east' or actor.dir == 'west' then 
				actor.walkAnim = 3
			end
		end
		if wep[actor.statePhase+1] then 
			actor.offhandAction.x = wep[math.min(6, actor.statePhase+1)][actor.dir].x
			actor.offhandAction.y = wep[math.min(6, actor.statePhase+1)][actor.dir].y
			actor.offhandAction.rot = wep[math.min(6, actor.statePhase+1)][actor.dir].rot
		end
		actor.weaponAction.x = main[actor.dir].x
		actor.weaponAction.y = main[actor.dir].y
		actor.weaponAction.rot = main[actor.dir].rot
	end
end

function game.actorStateShield(actor, dt, attack)
	if actor.statePhase >= 4 then 
		actor.state = 'idle' 
		actor.weaponAction = {x = 0, y = 0, rot = 0}
		actor.offhandAction = {x = 0, y = 0, rot = 0}
	elseif actor.statePhase == 1 then 
		local off = {
			north = {x = -5, y = 0, rot = 0},
			south = {x = 4, y = 0, rot = 0},
			east = {x = 2, y = -1, rot = 0},
			west = {x = -2, y = -1, rot = 0},
		}
		actor.offhandAction = off[actor.dir]
	elseif actor.statePhase == 2 then 
		local off = {
			north = {x = -4, y = -2, rot = 0},
			south = {x = 2, y = -1, rot = 0},
			east = {x = 4, y = -2, rot = 0},
			west = {x = -4, y = -2, rot = 0},
		}
		actor.offhandAction = off[actor.dir]
	elseif actor.statePhase == 3 then 
		local off = {
			north = {x = -4, y = -4, rot = 0},
			south = {x = 2, y = -1, rot = 0},
			east = {x = 4, y = -2, rot = 0},
			west = {x = -4, y = -2, rot = 0},
		}
		actor.offhandAction = off[actor.dir]
		if attack and actor.staminaCur >= 1 then 
			actor.state = actor.offhand.offattack[1]
			actor.staminaCur = actor.staminaCur - actor.offhand.staminaCost
			actor.statePhase = 2
			actor.stateTimer = 0
		end
	end
end

function game.actorStatePyro(actor, dt, attack)
	local angle = math.atan2(actor.lockCoords[2] - actor.y, actor.lockCoords[1] - actor.x)
	if actor.statePhase < 7 then 
		actor.slow = 0.45
		actor.stateTimer = actor.stateTimer + dt * actor.attunement[actor.attuneSlotFocus].spell.castTime
	elseif actor.statePhase >= 7 then 
		actor.slow = 0.75
		actor.stateTimer = actor.stateTimer - dt * 0.25
	end
	if actor.statePhase == 8 and actor.stateTimer <= 0 then 
		actor.statePhase = 9
		actor.stateTimer = 0.55
	end
	local off = {
		{
			north = {x = -6, y = 2, rot = math.pi * 0.1},
			south = {x = 6, y = 4, rot = 0 - math.pi * 0.1},
			east = {x = -5, y = 2, rot = math.pi * 0.1},
			west = {x = 6, y = 2, rot = 0 - math.pi * 0.1},
		},
		{
			north = {x = -7, y = 1, rot = math.pi * 0.09},
			south = {x = 7, y = 3, rot = 0 - math.pi * 0.09},
			east = {x = -6, y = 1, rot = math.pi * 0.09},
			west = {x = 6, y = 1, rot = 0 - math.pi * 0.09},
		},
		{
			north = {x = -7, y = 0, rot = math.pi * 0.08},
			south = {x = 7, y = 2, rot = 0 - math.pi * 0.08},
			east = {x = -6, y = 0, rot = math.pi * 0.08},
			west = {x = 6, y = 0, rot = 0 - math.pi * 0.08},
		},
		{
			north = {x = -7, y = -1, rot = math.pi * 0.06},
			south = {x = 7, y = 1, rot = 0 - math.pi * 0.06},
			east = {x = -6, y = -1, rot = math.pi * 0.06},
			west = {x = 6, y = -1, rot = 0 - math.pi * 0.06},
		},
		{
			north = {x = -8, y = -2, rot = math.pi * 0.03},
			south = {x = 8, y = 0, rot = 0 - math.pi * 0.03},
			east = {x = -6, y = -2, rot = math.pi * 0.03},
			west = {x = 6, y = -2, rot = 0 - math.pi * 0.03},
		},
		{
			north = {x = -8, y = -3, rot = 0},
			south = {x = 8, y = -1, rot = 0},
			east = {x = -6, y = -3, rot = 0},
			west = {x = 6, y = -3, rot = 0},
		},
		{
			north = {x = -8, y = -4, rot = 0},
			south = {x = 8, y = -2, rot = 0},
			east = {x = -5, y = -4, rot = 0},
			west = {x = 5, y = -4, rot = 0},
		},
		{
			north = {x = -7, y = -7, rot = 0},
			south = {x = 7, y = 1, rot = 0},
			east = {x = -1, y = -4, rot = 0},
			west = {x = 1, y = -4, rot = 0},
		},
		{
			north = {x = -5, y = -18, rot = 0},
			south = {x = 5, y = 11, rot = 0},
			east = {x = 10, y = -4, rot = 0},
			west = {x = -10, y = -4, rot = 0},
		},
	}
	if actor.statePhase >= 11 then 
		if actor.statePhase > 12 then 
			actor.state = 'idle'
			actor.offhandAction = {x = 0, y = 0, rot = 0}
			actor.lockCoords[1], actor.lockCoords[2] = 0, 0
		else
			if actor.stateTimer <= 0 then 
				actor.offhandAction = {
					x = actor.offhandAction.x - (actor.offhandAction.x - actor.offhand.dx[actor.dir]) / 2, 
					y = actor.offhandAction.y - (actor.offhandAction.y - actor.offhand.dy[actor.dir]) / 2, 
					rot = actor.offhandAction.rot - (actor.offhandAction.rot - actor.offhand.rot[actor.dir]) / 2 
				}
			end
		end
	elseif actor.statePhase < 11 then 
		if actor.statePhase == 9 and actor.attunement[actor.attuneSlotFocus].casts > 0 then 
			actor.attunement[actor.attuneSlotFocus].spell.onCast(game, actor, angle, {img = img})
			actor.attunement[actor.attuneSlotFocus].casts = actor.attunement[actor.attuneSlotFocus].casts - 1
			actor.lockCoords[1], actor.lockCoords[2] = 0, 0
			actor.stateTimer = -1
			if actor == player then 
				game.screenShake(12)
			end
		elseif actor.statePhase < 9 then 
			local rand = 35 
			if actor.statePhase < 5 then 
				rand = 10
			end
			if actor.attunement[actor.attuneSlotFocus].spell.type == 'pyromancy' then
				for iox = actor.x + actor.offhandAction.x - 1, actor.x + actor.offhandAction.x + 1 do 
					for ioy = actor.y + actor.offhandAction.y + actor.offhand.castOy - 1, actor.y + actor.offhandAction.y + actor.offhand.castOy + 1 do
						if love.math.random(1, 100) <= rand then 
							game.emitParticlesAt(actor.attunement[actor.attuneSlotFocus].spell.castPart, iox, ioy, 1)
						end
					end
				end
			end
		end
		local wep = {
			north = {x = 7, y = 2, rot = -math.pi * 1.9},
			south = {x = -7, y = 2, rot = -math.pi * 0.1},
			east = {x = 7, y = 2, rot = -math.pi * 1.8},
			west = {x = -7, y = 2, rot = -math.pi * 0.2},
		}
		actor.weaponAction = wep[actor.dir]
		if off[actor.statePhase+1] then 
			actor.offhandAction = off[actor.statePhase+1][actor.dir]
		end
	end
end

function game.actorStateCast(actor, dt, attack)
	local angle = math.atan2(actor.lockCoords[2] - actor.y, actor.lockCoords[1] - actor.x)
	if actor.statePhase < 7 then 
		actor.stateTimer = actor.stateTimer - dt * 1.25
	elseif actor.statePhase < 9 then 
		actor.slow = 0.75
		actor.stateTimer = actor.stateTimer + dt * actor.attunement[actor.attuneSlotFocus].spell.castTime
	end
	if actor.statePhase == 8 and actor.stateTimer <= 0 then 
		actor.statePhase = 9
		actor.stateTimer = 0.55
	end
	local wep = {
		{
			north = {x = 4, y = 2, rot = math.pi * 0.1},
			south = {x = -6, y = 4, rot = 0 - math.pi * 0.1},
			east = {x = 5, y = 2, rot = math.pi * 0.1},
			west = {x = -6, y = 2, rot = 0 - math.pi * 0.1},
		},
		{
			north = {x = 3, y = 1, rot = math.pi * 0.09},
			south = {x = -5, y = 3, rot = 0 - math.pi * 0.09},
			east = {x = 6, y = 1, rot = math.pi * 0.09},
			west = {x = -6, y = 1, rot = 0 - math.pi * 0.09},
		},
		{
			north = {x = 3, y = 0, rot = math.pi * 0.08},
			south = {x = -5, y = 2, rot = 0 - math.pi * 0.08},
			east = {x = 6, y = 0, rot = math.pi * 0.08},
			west = {x = -6, y = 0, rot = 0 - math.pi * 0.08},
		},
		{
			north = {x = 3, y = -1, rot = math.pi * 0.06},
			south = {x = -5, y = 1, rot = 0 - math.pi * 0.06},
			east = {x = 6, y = -1, rot = math.pi * 0.06},
			west = {x = -6, y = -1, rot = 0 - math.pi * 0.06},
		},
		{
			north = {x = 3, y = -2, rot = math.pi * 0.03},
			south = {x = -5, y = 0, rot = 0 - math.pi * 0.03},
			east = {x = 6, y = -2, rot = math.pi * 0.03},
			west = {x = -6, y = -2, rot = 0 - math.pi * 0.03},
		},
		{
			north = {x = 3, y = -3, rot = 0},
			south = {x = -5, y = -1, rot = 0},
			east = {x = 6, y = -3, rot = 0},
			west = {x = -6, y = -3, rot = 0},
		},
		{
			north = {x = 2, y = -4, rot = 0},
			south = {x = -4, y = -2, rot = 0},
			east = {x = 5, y = -4, rot = 0},
			west = {x = -5, y = -4, rot = 0},
		},
	}
	if actor.statePhase >= 10 then 
		if actor.statePhase > 11 then 
			actor.state = 'idle'
			actor.weaponAction = {x = 0, y = 0, rot = 0}
			actor.lockCoords[1], actor.lockCoords[2] = 0, 0
		else
			if actor.stateTimer <= 0 then 
				actor.weaponAction = {
					x = actor.weaponAction.x - (actor.weaponAction.x - actor.weapon.dx[actor.dir]) / 2, 
					y = actor.weaponAction.y - (actor.weaponAction.y - actor.weapon.dy[actor.dir]) / 2, 
					rot = actor.weaponAction.rot - (actor.weaponAction.rot - actor.weapon.rot[actor.dir]) / 2 
				}
			end
		end
	elseif actor.statePhase < 10 then 
		if actor.statePhase == 9 and actor.stateTimer <= 0 and actor.attunement[actor.attuneSlotFocus].casts > 0 then 
			actor.attunement[actor.attuneSlotFocus].spell.onCast(game, actor, angle, {img = img})
			actor.attunement[actor.attuneSlotFocus].casts = actor.attunement[actor.attuneSlotFocus].casts - 1
			actor.lockCoords[1], actor.lockCoords[2] = 0, 0
			if actor == player then 
				game.screenShake(12)
			end
		elseif actor.statePhase < 9 then 
			local rand = 35 
			if actor.statePhase < 5 then 
				rand = 10
			end
			if actor.attunement[actor.attuneSlotFocus].spell.type == 'sorcery' then
				for iox = actor.x + actor.weaponAction.x - 1, actor.x + actor.weaponAction.x + 1 do 
					for ioy = actor.y + actor.weaponAction.y + actor.weapon.castOy - 1, actor.y + actor.weaponAction.y + actor.weapon.castOy + 1 do
						if love.math.random(1, 100) <= rand then 
							game.emitParticlesAt(actor.attunement[actor.attuneSlotFocus].spell.castPart, iox, ioy, 1)
						end
					end
				end
			end
			--x = actor.x + actor.weaponAction.x, y = actor.y + actor.weaponAction.y + actor.weapon.castOy
		end
		local off = {
			north = {x = -7, y = 2, rot = math.pi * 1.9},
			south = {x = 7, y = 2, rot = math.pi * 0.1},
			east = {x = -7, y = 2, rot = math.pi * 1.8},
			west = {x = 7, y = 2, rot = math.pi * 0.2},
		}
		actor.offhandAction = off[actor.dir]
		if wep[actor.statePhase+1] then 
			actor.weaponAction = wep[actor.statePhase+1][actor.dir]
		end
	end
end

function game.actorStateStab3(actor, dt, attack)
	local orot = 0
	if actor.statePhase < 4 then 
		actor.stateTimer = actor.stateTimer + dt * 0.25
	end
	if actor.weapon.name ~= 'spear' then 
		orot = (math.pi / 2)
	end
	if actor.statePhase >= 7 then 
		if actor.statePhase > 8 then 
			actor.state = 'idle'
			actor.weaponAction = {x = 0, y = 0, rot = 0}
		else
			if actor.stateTimer <= 0 then
				actor.weaponAction = {
					x = actor.weaponAction.x - (actor.weaponAction.x - actor.weapon.dx[actor.dir]) / 2, 
					y = actor.weaponAction.y - (actor.weaponAction.y - actor.weapon.dy[actor.dir]) / 2, 
					rot = actor.weaponAction.rot - (actor.weaponAction.rot - actor.weapon.rot[actor.dir]) / 2 
				}
			end
		end
	elseif actor.statePhase == 1 or actor.statePhase == 0 then 
		local wep = {
			north = {x = -6, y = 7, rot = math.pi * 1.45},
			south = {x = 6, y = -7, rot = math.pi * 0.45},
			east = {x = -6, y = 1, rot = math.pi * 0.11},
			west = {x = 6, y = 1, rot = math.pi * 0.91},
		}
		local off = {
			north = {x = -7, y = 2, rot = math.pi * 1.9},
			south = {x = 7, y = 2, rot = math.pi * 0.1},
			east = {x = -7, y = 2, rot = math.pi * 1.8},
			west = {x = 7, y = 2, rot = math.pi * 0.2},
		}
		actor.offhandAction = off[actor.dir]
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
	elseif actor.statePhase == 2 then 
		local wep = {
			north = {x = -5, y = 8, rot = math.pi * 1.44},
			south = {x = 5, y = -8, rot = math.pi * 0.44},
			east = {x = -7, y = 2, rot = math.pi * 0.10},
			west = {x = 7, y = 2, rot = math.pi * 0.90},
		}
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
	elseif actor.statePhase == 3 then 
		local wep = {
			north = {x = -4, y = 9, rot = math.pi * 1.43},
			south = {x = 4, y = -9, rot = math.pi * 0.43},
			east = {x = -9, y = 3, rot = math.pi * 0.09},
			west = {x = 9, y = 3, rot = math.pi * 0.89},
		}
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
	elseif actor.statePhase == 4 then 
		local wep = {
			north = {x = -1, y = -19, rot = math.pi * 1.5},
			south = {x = 1, y = 19, rot = math.pi * 0.5},
			east = {x = 12, y = 0, rot = 0},
			west = {x = -12, y = 0, rot = math.pi},
		}
		local swing = {
			north = {x = 2, y = -50, rot = math.pi * 1.5},
			south = {x = -2, y = 50, rot = math.pi * 0.5},
			east = {x = 45, y = 1, rot = 0},
			west = {x = -45, y = -1, rot = math.pi},
		}
		local step = {
			north = {0, -100},
			south = {0, 100},
			east = {100, 0},
			west = {-100, 0},
		}
		if actor.backstab then 
			wep = {
				north = {x = -1, y = -10, rot = math.pi * 1.5},
				south = {x = 1, y = 15, rot = math.pi * 0.5},
				east = {x = 12, y = 0, rot = 0},
				west = {x = -12, y = 0, rot = math.pi},
			}
		end
		local newX, newY = actor.x + step[actor.dir][1] * dt, actor.y + step[actor.dir][2] * dt 
		local aX, aY, cols, len = world:move(actor, newX, newY, function(item, other) if other.type == 'bg'or other.type == 'ladder' then return false else return 'slide' end end)
		actor.walkAnim = 2
		actor.moveDir = actor.dir
		if len == 0 then 
			actor.x = actor.x + step[actor.dir][1] * dt 
			actor.y = actor.y + step[actor.dir][2] * dt 
		end
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
		if actor.stateTimer <= 0 then 
			game.addAnimation('stab3', actor.x + swing[actor.dir].x, actor.y + swing[actor.dir].y, swing[actor.dir].rot, sx, sy)
			if actor.dir == 'north' and not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 10, actor.y - 17 + swing[actor.dir].y, 20, 45, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'south' and not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 10, actor.y - 28 + swing[actor.dir].y, 20, 45, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'east' and not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 28, actor.y - 10 + swing[actor.dir].y, 45, 20, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 17, actor.y - 10 + swing[actor.dir].y, 45, 20, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			end
			if actor == player then 
				game.screenShake(15)
			end
			game.playSound('stab1', actor.x, actor.y)
		end
	elseif actor.statePhase == 5 then 
		local wep = {
			north = {x = 0, y = -20, rot = math.pi * 1.52},
			south = {x = 0, y = 20, rot = math.pi * 0.52},
			east = {x = 13, y = 0, rot = 0},
			west = {x = -13, y = 0, rot = math.pi},
		}
		if actor.backstab then 
			wep = {
				north = {x = -1, y = -10, rot = math.pi * 1.5},
				south = {x = 1, y = 15, rot = math.pi * 0.5},
				east = {x = 12, y = 0, rot = 0},
				west = {x = -12, y = 0, rot = math.pi},
			}
		end
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}		
	elseif actor.statePhase == 6 then 
		local wep = {
			north = {x = 0, y = -20, rot = math.pi * 1.52},
			south = {x = 0, y = 20, rot = math.pi * 0.52},
			east = {x = 13, y = 0, rot = 0},
			west = {x = -13, y = 0, rot = math.pi},
		}
		if actor.backstab then 
			wep = {
				north = {x = -1, y = -10, rot = math.pi * 1.5},
				south = {x = 1, y = 15, rot = math.pi * 0.5},
				east = {x = 12, y = 0, rot = 0},
				west = {x = -12, y = 0, rot = math.pi},
			}
		end
		if attack and actor.staminaCur >= 1 then 
			actor.state = actor.weapon.lightattack[actor.stateCombo + 1]
			actor.stateCombo = actor.stateCombo + 1
			if not actor.state then 
				actor.state = actor.weapon.lightattack[1]
				actor.stateCombo = 1
			end
			actor.staminaCur = actor.staminaCur - actor.weapon.staminaCost
			actor.staminaGainCD = 1.5
			actor.statePhase = 0
			actor.stateTimer = 0
		end
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
	end
end

function game.actorStateStab2(actor, dt, attack)
	local orot = 0
	if actor.weapon.name ~= 'spear' then 
		orot = (math.pi / 2)
	end
	if actor.statePhase >= 7 then 
		if actor.statePhase > 8 then 
			actor.state = 'idle'
			actor.weaponAction = {x = 0, y = 0, rot = 0}
		else
			if actor.stateTimer <= 0 then
				actor.weaponAction = {
					x = actor.weaponAction.x - (actor.weaponAction.x - actor.weapon.dx[actor.dir]) / 2, 
					y = actor.weaponAction.y - (actor.weaponAction.y - actor.weapon.dy[actor.dir]) / 2, 
					rot = actor.weaponAction.rot - (actor.weaponAction.rot - actor.weapon.rot[actor.dir]) / 2 
				}
			end
		end
	elseif actor.statePhase == 1 or actor.statePhase == 0 then 
		local wep = {
			north = {x = -6, y = 7, rot = math.pi * 1.45},
			south = {x = 6, y = -7, rot = math.pi * 0.45},
			east = {x = -6, y = 1, rot = math.pi * 0.11},
			west = {x = 6, y = 1, rot = math.pi * 0.91},
		}
		local off = {
			north = {x = -7, y = 2, rot = math.pi * 1.9},
			south = {x = 7, y = 2, rot = math.pi * 0.1},
			east = {x = -7, y = 2, rot = math.pi * 1.8},
			west = {x = 7, y = 2, rot = math.pi * 0.2},
		}
		actor.offhandAction = off[actor.dir]
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
	elseif actor.statePhase == 2 then 
		local wep = {
			north = {x = -5, y = 8, rot = math.pi * 1.44},
			south = {x = 5, y = -8, rot = math.pi * 0.44},
			east = {x = -7, y = 2, rot = math.pi * 0.10},
			west = {x = 7, y = 2, rot = math.pi * 0.90},
		}
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
	elseif actor.statePhase == 3 then 
		local wep = {
			north = {x = -4, y = 9, rot = math.pi * 1.43},
			south = {x = 4, y = -9, rot = math.pi * 0.43},
			east = {x = -9, y = 3, rot = math.pi * 0.09},
			west = {x = 9, y = 3, rot = math.pi * 0.89},
		}
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
	elseif actor.statePhase == 4 then 
		local wep = {
			north = {x = -1, y = -19, rot = math.pi * 1.5},
			south = {x = 1, y = 19, rot = math.pi * 0.5},
			east = {x = 12, y = 0, rot = 0},
			west = {x = -12, y = 0, rot = math.pi},
		}
		local swing = {
			north = {x = 2, y = -40, rot = math.pi * 1.5},
			south = {x = -2, y = 40, rot = math.pi * 0.5},
			east = {x = 35, y = 1, rot = 0},
			west = {x = -35, y = -1, rot = math.pi},
		}
		local step = {
			north = {0, -100},
			south = {0, 100},
			east = {100, 0},
			west = {-100, 0},
		}
		if actor.backstab then 
			wep = {
				north = {x = -1, y = -10, rot = math.pi * 1.5},
				south = {x = 1, y = 15, rot = math.pi * 0.5},
				east = {x = 12, y = 0, rot = 0},
				west = {x = -12, y = 0, rot = math.pi},
			}
		end
		local newX, newY = actor.x + step[actor.dir][1] * dt, actor.y + step[actor.dir][2] * dt 
		local aX, aY, cols, len = world:move(actor, newX, newY, function(item, other) if other.type == 'bg'or other.type == 'ladder' then return false else return 'slide' end end)
		actor.walkAnim = 2
		actor.moveDir = actor.dir
		if len == 0 then 
			actor.x = actor.x + step[actor.dir][1] * dt 
			actor.y = actor.y + step[actor.dir][2] * dt 
		end
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
		if actor.stateTimer <= 0 then 
			game.addAnimation('stab2', actor.x + swing[actor.dir].x, actor.y + swing[actor.dir].y, swing[actor.dir].rot, sx, sy)
			if actor.dir == 'north' and not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 10, actor.y - 17 + swing[actor.dir].y, 20, 45, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'south' and not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 10, actor.y - 28 + swing[actor.dir].y, 20, 45, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'east' and not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 28, actor.y - 10 + swing[actor.dir].y, 45, 20, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 17, actor.y - 10 + swing[actor.dir].y, 45, 20, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			end
			if actor == player then 
				game.screenShake(15)
			end
			game.playSound('stab1', actor.x, actor.y)
		end
	elseif actor.statePhase == 5 then 
		local wep = {
			north = {x = 0, y = -20, rot = math.pi * 1.52},
			south = {x = 0, y = 20, rot = math.pi * 0.52},
			east = {x = 13, y = 0, rot = 0},
			west = {x = -13, y = 0, rot = math.pi},
		}
		if actor.backstab then 
			wep = {
				north = {x = -1, y = -10, rot = math.pi * 1.5},
				south = {x = 1, y = 15, rot = math.pi * 0.5},
				east = {x = 12, y = 0, rot = 0},
				west = {x = -12, y = 0, rot = math.pi},
			}
		end
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}		
	elseif actor.statePhase == 6 then 
		local wep = {
			north = {x = 0, y = -20, rot = math.pi * 1.52},
			south = {x = 0, y = 20, rot = math.pi * 0.52},
			east = {x = 13, y = 0, rot = 0},
			west = {x = -13, y = 0, rot = math.pi},
		}
		if actor.backstab then 
			wep = {
				north = {x = -1, y = -10, rot = math.pi * 1.5},
				south = {x = 1, y = 15, rot = math.pi * 0.5},
				east = {x = 12, y = 0, rot = 0},
				west = {x = -12, y = 0, rot = math.pi},
			}
		end
		if attack and actor.staminaCur >= 1 then 
			actor.state = actor.weapon.lightattack[actor.stateCombo + 1]
			actor.stateCombo = actor.stateCombo + 1
			if not actor.state then 
				actor.state = actor.weapon.lightattack[1]
				actor.stateCombo = 1
			end
			actor.staminaCur = actor.staminaCur - actor.weapon.staminaCost
			actor.staminaGainCD = 1.5
			actor.statePhase = 0
			actor.stateTimer = 0
		end
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
	end
end

function game.actorStateStab1(actor, dt, attack)
	local orot = 0
	if actor.weapon.name ~= 'spear' then 
		orot = (math.pi / 2)
	end
	if actor.statePhase >= 7 then 
		if actor.statePhase > 8 then 
			actor.state = 'idle'
			actor.weaponAction = {x = 0, y = 0, rot = 0}
		else
			if actor.stateTimer <= 0 then
				actor.weaponAction = {
					x = actor.weaponAction.x - (actor.weaponAction.x - actor.weapon.dx[actor.dir]) / 2, 
					y = actor.weaponAction.y - (actor.weaponAction.y - actor.weapon.dy[actor.dir]) / 2, 
					rot = actor.weaponAction.rot - (actor.weaponAction.rot - actor.weapon.rot[actor.dir]) / 2 
				}
			end
		end
	elseif actor.statePhase == 1 or actor.statePhase == 0 then 
		local wep = {
			north = {x = -6, y = 7, rot = math.pi * 1.45},
			south = {x = 6, y = -7, rot = math.pi * 0.45},
			east = {x = -6, y = 1, rot = math.pi * 0.11},
			west = {x = 6, y = 1, rot = math.pi * 0.91},
		}
		local off = {
			north = {x = -7, y = 2, rot = math.pi * 1.9},
			south = {x = 7, y = 2, rot = math.pi * 0.1},
			east = {x = -7, y = 2, rot = math.pi * 1.8},
			west = {x = 7, y = 2, rot = math.pi * 0.2},
		}
		actor.offhandAction = off[actor.dir]
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
	elseif actor.statePhase == 2 then 
		local wep = {
			north = {x = -5, y = 8, rot = math.pi * 1.44},
			south = {x = 5, y = -8, rot = math.pi * 0.44},
			east = {x = -7, y = 2, rot = math.pi * 0.10},
			west = {x = 7, y = 2, rot = math.pi * 0.90},
		}
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
	elseif actor.statePhase == 3 then 
		local wep = {
			north = {x = -4, y = 9, rot = math.pi * 1.43},
			south = {x = 4, y = -9, rot = math.pi * 0.43},
			east = {x = -9, y = 3, rot = math.pi * 0.09},
			west = {x = 9, y = 3, rot = math.pi * 0.89},
		}
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
	elseif actor.statePhase == 4 then 
		local wep = {
			north = {x = -1, y = -19, rot = math.pi * 1.5},
			south = {x = 1, y = 19, rot = math.pi * 0.5},
			east = {x = 12, y = 0, rot = 0},
			west = {x = -12, y = 0, rot = math.pi},
		}
		local swing = {
			north = {x = 0, y = -35, rot = math.pi * 1.5},
			south = {x = 0, y = 35, rot = math.pi * 0.5},
			east = {x = 35, y = 0, rot = 0},
			west = {x = -35, y = 0, rot = math.pi},
		}
		local step = {
			north = {0, -150},
			south = {0, 150},
			east = {150, 0},
			west = {-150, 0},
		}
		if actor.backstab then 
			wep = {
				north = {x = -1, y = -10, rot = math.pi * 1.5},
				south = {x = 1, y = 15, rot = math.pi * 0.5},
				east = {x = 12, y = 0, rot = 0},
				west = {x = -12, y = 0, rot = math.pi},
			}
		end
		local newX, newY = actor.x + step[actor.dir][1] * dt, actor.y + step[actor.dir][2] * dt 
		local aX, aY, cols, len = world:move(actor, newX, newY, function(item, other) if other.type == 'bg'or other.type == 'ladder' then return false else return 'slide' end end)
		if not actor.backStab then 
			actor.walkAnim = 2
			actor.moveDir = actor.dir
		end
		if len == 0 then 
			actor.x = actor.x + step[actor.dir][1] * dt 
			actor.y = actor.y + step[actor.dir][2] * dt 
		end
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
		if actor.stateTimer <= 0 then 
			if not actor.backstab then 
				game.addAnimation('stab1', actor.x + swing[actor.dir].x, actor.y + swing[actor.dir].y, swing[actor.dir].rot, sx, sy)
			else
				actor.backstab.other.hurt = 0.1
				game.emitParticlesAt('redblood', actor.backstab.other.x, actor.backstab.other.y, 200)
				game.addAnimation('stab2', actor.x + swing[actor.dir].x, actor.y + swing[actor.dir].y, swing[actor.dir].rot, sx, sy)
			end
			if actor.dir == 'north' and not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 10, actor.y - 24 + swing[actor.dir].y, 20, 52, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'south' and not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 10, actor.y - 28 + swing[actor.dir].y, 20, 52, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'east' and not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 28, actor.y - 10 + swing[actor.dir].y, 52, 20, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif not actor.backstab then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 24, actor.y - 10 + swing[actor.dir].y, 52, 20, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			end
			if actor == player then 
				game.screenShake(15)
			end
			game.playSound('stab1', actor.x, actor.y)
		end
	elseif actor.statePhase == 5 then 
		local wep = {
			north = {x = 0, y = -20, rot = math.pi * 1.52},
			south = {x = 0, y = 20, rot = math.pi * 0.52},
			east = {x = 13, y = 0, rot = 0},
			west = {x = -13, y = 0, rot = math.pi},
		}
		if actor.backstab then 
			wep = {
				north = {x = -1, y = -10, rot = math.pi * 1.5},
				south = {x = 1, y = 15, rot = math.pi * 0.5},
				east = {x = 12, y = 0, rot = 0},
				west = {x = -12, y = 0, rot = math.pi},
			}
		end
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
	elseif actor.statePhase == 6 then 
		local wep = {
			north = {x = 0, y = -20, rot = math.pi * 1.52},
			south = {x = 0, y = 20, rot = math.pi * 0.52},
			east = {x = 13, y = 0, rot = 0},
			west = {x = -13, y = 0, rot = math.pi},
		}
		if actor.backstab then 
			wep = {
				north = {x = -1, y = -10, rot = math.pi * 1.5},
				south = {x = 1, y = 15, rot = math.pi * 0.5},
				east = {x = 12, y = 0, rot = 0},
				west = {x = -12, y = 0, rot = math.pi},
			}
		end
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = wep[actor.dir].rot + orot}
	end
end

function game.actorStatePull(actor, dt, attack, px, py)
	local angle = math.atan2(actor.lockCoords[2] - actor.y, actor.lockCoords[1] - actor.x)
	if actor.statePhase >= 8 then 
		actor.state = 'idle' 
		actor.weaponAction = {x = 0, y = 0, rot = 0}
		actor.lockCoords[1], actor.lockCoords[2] = 0, 0
	elseif actor.statePhase == 1 then 
		local wep = {
			north = {x = 0, y = -2},
			south = {x = 0, y = 2},
			east = {x = 4, y = 0},
			west = {x = -4, y = 0},
		}	
		local off = {
			north = {x = -7, y = 2, rot = math.pi * 1.9},
			south = {x = 7, y = 2, rot = math.pi * 0.1},
			east = {x = -7, y = 2, rot = math.pi * 1.8},
			west = {x = 7, y = 2, rot = math.pi * 0.2},
		}
		actor.offhandAction = off[actor.dir]
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = angle}
		if actor == player then 
			game.screenShake(3)
		end
		if actor.stateTimer <= 0 then 
			game.addAnimation('arrowKnock', actor.x, actor.y, angle)
		end
		game.playSound('bowpull1', actor.x, actor.y)
	elseif actor.statePhase == 2 then 
		local wep = {
			north = {x = 0, y = -6},
			south = {x = 0, y = 6},
			east = {x = 6, y = -1},
			west = {x = -6, y = -1},
		}	
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = angle}
		if actor == player then 
			game.screenShake(3)
		end
	elseif actor.statePhase == 3 then 
		local wep = {
			north = {x = 0, y = -7},
			south = {x = 0, y = 7},
			east = {x = 7, y = -2},
			west = {x = -7, y = -2},
		}	
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = angle}
		if actor == player then 
			game.screenShake(3)
		end
	elseif actor.statePhase == 4 then 
		local wep = {
			north = {x = 0, y = -7},
			south = {x = 0, y = 7},
			east = {x = 7, y = -2},
			west = {x = -7, y = -2},
		}	
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = angle}
		if actor == player then 
			game.screenShake(3)
		end
	elseif actor.statePhase == 5 then 
		local wep = {
			north = {x = 0, y = -7},
			south = {x = 0, y = 7},
			east = {x = 7, y = -2},
			west = {x = -7, y = -2},
		}	
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = angle}
		if actor.stateTimer <= 0 then 
			game.addProjectile({img = img.weapon.arrow, x = actor.x, y = actor.y, tracking = true, decal = 'arrow', rot = angle, speed = 350, nohit = 0.05, dam = game.actorGetWeaponDamage(actor), dtype =  actor.weapon.dtype, team = actor.team, stun = actor.weapon.stundam, bdam = actor.weapon.bdam, knockback = actor.weapon.knockback})
			actor.lockCoords[1], actor.lockCoords[2] = 0, 0
			if actor == player then 
				game.screenShake(12)
			end
			game.playSound('bowshoot1', actor.x, actor.y)
		end
	elseif actor.statePhase == 6 then 
		local wep = {
			north = {x = 0, y = -5},
			south = {x = 0, y = 5},
			east = {x = 4, y = -1},
			west = {x = -4, y = -1},
		}	
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = angle}
		actor.lockCoords[1], actor.lockCoords[2] = 0, 0
	elseif actor.statePhase == 7 then 
		local wep = {
			north = {x = 0, y = -5},
			south = {x = 0, y = 5},
			east = {x = 4, y = -1},
			west = {x = -4, y = -1},
		}	
		actor.weaponAction = {x = wep[actor.dir].x, y = wep[actor.dir].y, rot = angle}
		actor.lockCoords[1], actor.lockCoords[2] = 0, 0
	end
end

function game.actorStateSwing2(actor, dt, attack)
	if actor.statePhase >= 7 then 
		if actor.statePhase > 8 then 
			actor.state = 'idle'
			actor.weaponAction = {x = 0, y = 0, rot = 0}
		else
			if actor.stateTimer <= 0 then
				actor.weaponAction = {
					x = actor.weaponAction.x - (actor.weaponAction.x - actor.weapon.dx[actor.dir]) / 2, 
					y = actor.weaponAction.y - (actor.weaponAction.y - actor.weapon.dy[actor.dir]) / 2, 
					rot = actor.weaponAction.rot - (actor.weaponAction.rot - actor.weapon.rot[actor.dir]) / 2 
				}
			end
		end
	elseif actor.statePhase == 1 or actor.statePhase == 0 then 
		local wep = {
			north = {x = 5, y = -3, rot = math.pi / 1.7},
			south = {x = -5, y = 3, rot = math.pi * 1.6},
			east = {x = -1, y = 3, rot = math.pi * 0.8},
			west = {x = 1, y = 3, rot = math.pi * 1.2},
		}
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 2 then 
		local wep = {
			north = {x = 6, y = -3, rot = math.pi / 1.8},
			south = {x = -6, y = 3, rot = math.pi * 1.5},
			east = {x = -1, y = 4, rot = math.pi * 0.85},
			west = {x = 1, y = 4, rot = math.pi * 1.15},
		}
		local off = {
			north = {x = -7, y = 2, rot = math.pi * 1.9},
			south = {x = 7, y = 2, rot = math.pi * 0.1},
			east = {x = -7, y = 2, rot = math.pi * 1.8},
			west = {x = 7, y = 2, rot = math.pi * 0.2},
		}
		actor.offhandAction = off[actor.dir]
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 3 then 
		local wep = {
			north = {x = 5, y = -4, rot = math.pi / 1.9},
			south = {x = -5, y = 4, rot = math.pi * 1.4},
			east = {x = -2, y = 4, rot = math.pi * 0.9},
			west = {x = 2, y = 4, rot = math.pi * 1.1},
		}
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 4 then 
		local step = {
			north = {0, -150},
			south = {0, 150},
			east = {150, 0},
			west = {-150, 0},
		}
		local wep = {
			north = {x = -8, y = -6, rot = 5 * math.pi / 3},
			south = {x = 8, y = 6, rot = 2 * math.pi / 3},
			east = {x = 9, y = -7, rot = math.pi * 0.15},
			west = {x = -9, y = -7, rot = math.pi * 1.85},
		}
		local swing = {
			north = {x = 0, y = -12, rot = 0},
			south = {x = 0, y = 12, rot = math.pi},
			east = {x = 12, y = 0, rot = math.pi / 2},
			west = {x = -12, y = 0, rot = math.pi * 1.5},
		}
		local newX, newY = actor.x + step[actor.dir][1] * dt, actor.y + step[actor.dir][2] * dt 
		local aX, aY, cols, len = world:move(actor, newX, newY, function(item, other) if other.type == 'bg'or other.type == 'ladder' then return false else return 'slide' end end)
		actor.walkAnim = 2
		actor.moveDir = actor.dir
		if len == 0 then 
			actor.x = actor.x + step[actor.dir][1] * dt 
			actor.y = actor.y + step[actor.dir][2] * dt 
		end
		if actor.stateTimer <= 0 then 
			local sy = 1
			local sx = -1
			if actor.dir == 'west' then 
				sx = 1
				sy = 1 
			end
			if actor.dir == 'north' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 12, actor.y - 6 + swing[actor.dir].y, 24, 12, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 20, actor.y - 18 + swing[actor.dir].y, 40, 14, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'south' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 12, actor.y -4 + swing[actor.dir].y, 24, 12, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 20, actor.y + 8 + swing[actor.dir].y, 40, 14, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'east' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 6, actor.y - 12 + swing[actor.dir].y, 12, 24, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x + 4, actor.y - 20 + swing[actor.dir].y, 14, 40, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			else 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 6, actor.y - 12 + swing[actor.dir].y, 12, 24, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 18, actor.y - 20 + swing[actor.dir].y, 14, 40, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			end
			if actor == player then 
				game.screenShake(15)
			end
			game.playSound('swing1', actor.x, actor.y)
			game.addAnimation('swing1', actor.x + swing[actor.dir].x, actor.y + swing[actor.dir].y, swing[actor.dir].rot, sx, sy)
		end
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 5 then 
		local wep = {
			north = {x = -10, y = -5, rot = 4.9 * math.pi / 3},
			south = {x = 10, y = 5, rot = 1.9 * math.pi / 3},
			east = {x = 10, y = -8, rot = math.pi * 0.10},
			west = {x = -10, y = -8, rot = math.pi * 1.9},
		}
		actor.weaponAction = wep[actor.dir]
		if attack and actor.staminaCur >= 1 then 
			actor.state = actor.weapon.lightattack[actor.stateCombo + 1]
			actor.stateCombo = actor.stateCombo + 1
			if not actor.state then 
				actor.state = actor.weapon.lightattack[1]
				actor.stateCombo = 1
			end
			actor.staminaCur = actor.staminaCur - actor.weapon.staminaCost
			actor.staminaGainCD = 1.5
			actor.statePhase = 0
			actor.stateTimer = 0
		end
	elseif actor.statePhase == 6 then 
		local wep = {
			north = {x = -10, y = -5, rot = 4.9 * math.pi / 3},
			south = {x = 10, y = 5, rot = 1.9 * math.pi / 3},
			east = {x = 10, y = -8, rot = math.pi * 0.10},
			west = {x = -10, y = -8, rot = math.pi * 1.9},
		}
		actor.weaponAction = wep[actor.dir]
		if attack and actor.staminaCur >= 1 then 
			actor.state = actor.weapon.lightattack[actor.stateCombo + 1]
			actor.stateCombo = actor.stateCombo + 1
			if not actor.state then 
				actor.state = actor.weapon.lightattack[1]
				actor.stateCombo = 1
			end
			actor.staminaCur = actor.staminaCur - actor.weapon.staminaCost
			actor.staminaGainCD = 1.5
			actor.statePhase = 0
			actor.stateTimer = 0
		end
	end
end

function game.actorStateSwordSmash1(actor, dt, attack)
	if actor.statePhase < 3 then
		actor.stateTimer = actor.stateTimer + dt * 0.15
	end
	local wep = {
		{
			north = {x = -4, y = -3, rot = math.pi / 2 + math.pi / 1.6 - math.pi / 4},
			south = {x = 4, y = -3, rot = math.pi / 8 - math.pi / 4},
			east = {x = 2, y = -3, rot = 2 * math.pi - math.pi / 2.6},
			west = {x = -2, y = -3, rot = math.pi / 2.6},
		},
		{
			north = {x = -3, y = -1, rot = math.pi / 2 + math.pi / 1.6 - math.pi / 3.7},
			south = {x = 3, y = -5, rot = math.pi / 8 - math.pi / 3.7},
			east = {x = -3, y = -3, rot = 2 * math.pi - math.pi / 2.3},
			west = {x = 3, y = -3, rot = math.pi / 2.3},
		},
		{
			north = {x = -3, y = 2, rot = math.pi / 2 + math.pi / 1.6 - math.pi / 3.4},
			south = {x = 3, y = -7, rot = math.pi / 8 - math.pi / 3.4},
			east = {x = -6, y = -3, rot = 2 * math.pi - math.pi / 2},
			west = {x = 6, y = -3, rot = math.pi / 2.},
		},
		{
			north = {x = -9, y = -6, rot = math.pi / 2 + math.pi / 1.6 - math.pi / 4 + math.pi * 0.75},
			south = {x = 9, y = 1, rot = math.pi * 0.35},
			east = {x = -1, y = -10, rot = 2 * math.pi - math.pi / 5.9},
			west = {x = 1, y = -10, rot = math.pi / 5.9},
		},
		{
			north = {x = 8, y = -17, rot = math.pi * 0.15},
			south = {x = -8, y = 12, rot = math.pi + math.pi * 0.15},
			east = {x = 13, y = 8, rot = math.pi / 2 + math.pi / 6},
			west = {x = -13, y = 8, rot = 2 * math.pi - (math.pi / 2 + math.pi / 6)},
		},
		{
			north = {x = 9, y = -16, rot = math.pi * 0.2},
			south = {x = -9, y = 11, rot = math.pi + math.pi * 0.2},
			east = {x = 12, y = 9, rot = math.pi / 2 + math.pi / 4},
			west = {x = -12, y = 9, rot = 2 * math.pi - (math.pi / 2 + math.pi / 4)},
		},
	}
	local swing = {
		north = {x = -40, y = -10, rot = 0},
		south = {x = 40, y = 10, rot = math.pi},
		east = {x = 0, y = -30, rot = math.pi / 2},
		west = {x = 0, y = -30, rot = math.pi * 1.5},
	}
	if actor.statePhase >= 11 then 
		if actor.statePhase > 12 then 
			actor.state = 'idle'
			actor.weaponAction = {x = 0, y = 0, rot = 0}
		else
			if actor.stateTimer <= 0 then 
				actor.weaponAction = {
					x = actor.weaponAction.x - (actor.weaponAction.x - actor.weapon.dx[actor.dir]) / 2, 
					y = actor.weaponAction.y - (actor.weaponAction.y - actor.weapon.dy[actor.dir]) / 2, 
					rot = actor.weaponAction.rot - (actor.weaponAction.rot - actor.weapon.rot[actor.dir]) / 2 
				}
			end
		end
	else
		if actor.statePhase == 3 and actor.stateTimer <= 0 then 
			local sy = 1
			local sx = 1
			if actor.dir == 'west' then 
				sx = 1
				sy = -1 
			end
			actor.walkAnim = 2
			if actor.dir == 'east' or actor.dir == 'west' then 
				actor.walkAnim = 3
			end
			actor.moveDir = actor.dir
			if actor.dir == 'north' then 
				game.addHurtbox(actor.team, actor.x - 22, actor.y - 80, 28, 80, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'south' then 
				game.addHurtbox(actor.team, actor.x - 6, actor.y, 28, 80, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'east' then 
				game.addHurtbox(actor.team, actor.x, actor.y - 6, 70, 28, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			else 
				game.addHurtbox(actor.team, actor.x - 70, actor.y - 6, 70, 28, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			end
			game.addAnimation('swordsmash1', actor.x + swing[actor.dir].x, actor.y + swing[actor.dir].y, swing[actor.dir].rot - math.pi / 2, sx, sy)
			if actor == player then 
				game.screenShake(300)
			end
			game.playSound('swing2', actor.x, actor.y)
			game.playSound('crush1', actor.x, actor.y)
		elseif actor.statePhase > 2 and actor.statePhase < 4 then 
			local step = {
				north = {0, -250},
				south = {0, 250},
				east = {250, 0},
				west = {-250, 0},
			}
			local newX, newY = actor.x + step[actor.dir][1] * dt, actor.y + step[actor.dir][2] * dt 
			local aX, aY, cols, len = world:move(actor, newX, newY, function(item, other) if other.type == 'bg'or other.type == 'ladder' then return false else return 'slide' end end)
			actor.walkAnim = 2
			if actor.dir == 'east' or actor.dir == 'west' then 
				actor.walkAnim = 3
			end
			actor.moveDir = actor.dir
			actor.x = newX 
			actor.y = newY 
		elseif actor.statePhase < 5 and actor.statePhase > 2 then 
			actor.walkAnim = 2
			if actor.dir == 'east' or actor.dir == 'west' then 
				actor.walkAnim = 3
			end
			actor.moveDir = actor.dir
		end
		if wep[actor.statePhase+1] then 
			actor.weaponAction.x = wep[math.min(6, actor.statePhase+1)][actor.dir].x
			actor.weaponAction.y = wep[math.min(6, actor.statePhase+1)][actor.dir].y
			actor.weaponAction.rot = wep[math.min(6, actor.statePhase+1)][actor.dir].rot
		end
	end
end

function game.actorStateSwordLungeSmash1(actor, dt, attack)
	if actor.statePhase < 5 then 
		local angle = math.atan2(player.y - actor.y, player.x - actor.x)
		local newX = actor.x + (math.cos(angle) * 225) * dt 
		local newY = actor.y + (math.sin(angle) * 225) * dt
		local aX, aY, cols, len = world:move(actor, newX, newY, function(item, other) if other.type == 'bg'or other.type == 'ladder' then return false else return 'slide' end end)
		actor.walkAnim = 2
		actor.lunge = true
		if actor.dir == 'east' or actor.dir == 'west' then 
			actor.walkAnim = 3
		end
		actor.sprint = 0.1
		actor.moveDir = actor.dir
		actor.x = newX 
		actor.y = newY
	else 
		actor.lunge = false
	end
	if actor.statePhase >= 10 then 
		if actor.statePhase > 11 then 
			actor.state = 'idle'
			actor.weaponAction = {x = 0, y = 0, rot = 0}
		else
			if actor.stateTimer <= 0 then
				actor.weaponAction = {
					x = actor.weaponAction.x - (actor.weaponAction.x - actor.weapon.dx[actor.dir]) / 2, 
					y = actor.weaponAction.y - (actor.weaponAction.y - actor.weapon.dy[actor.dir]) / 2, 
					rot = actor.weaponAction.rot - (actor.weaponAction.rot - actor.weapon.rot[actor.dir]) / 2 
				}
			end
		end
	elseif actor.statePhase < 3 then 
		local wep = {
			north = {x = -4, y = -3, rot = 4 * math.pi / 3},
			south = {x = 4, y = 3, rot = math.pi / 3},
			east = {x = 6, y = -3, rot = math.pi / 8},
			west = {x = -6, y = -3, rot = math.pi * 2 - math.pi / 8},
		}
		local off = {
			north = {x = -7, y = 2, rot = math.pi * 1.9},
			south = {x = 7, y = 2, rot = math.pi * 0.1},
			east = {x = -7, y = 2, rot = math.pi * 1.8},
			west = {x = 7, y = 2, rot = math.pi * 0.2},
		}
		actor.offhandAction = off[actor.dir]
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 4 then 
		local wep = {
			north = {x = -7, y = -4, rot = 5 * math.pi / 4},
			south = {x = 7, y = 4, rot = math.pi / 4},
			east = {x = 7, y = -4, rot = math.pi / 16},
			west = {x = -7, y = -4, rot = math.pi * 2 - math.pi / 16},
		}
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 5 then 
		local wep = {
			north = {x = -7, y = -3, rot = 5 * math.pi / 4},
			south = {x = 7, y = 3, rot = math.pi / 4},
			east = {x = 9, y = -5, rot = -0.02},
			west = {x = -9, y = -4, rot = 0.02},
		}
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 6 then 
		local step = {
			north = {0, -150},
			south = {0, 150},
			east = {150, 0},
			west = {-150, 0},
		}
		local newX, newY = actor.x + step[actor.dir][1] * dt, actor.y + step[actor.dir][2] * dt 
		local aX, aY, cols, len = world:move(actor, newX, newY, function(item, other) if other.type == 'bg'or other.type == 'ladder' then return false else return 'slide' end end)
		if len == 0 then 
			actor.x = actor.x + step[actor.dir][1] * dt 
			actor.y = actor.y + step[actor.dir][2] * dt 
		end
		actor.walkAnim = 2
		actor.moveDir = actor.dir
		local swing = {
			north = {x = -30, y = -10, rot = math.pi + math.pi / 2},
			south = {x = 30, y = 10, rot = math.pi / 2},
			east = {x = 10, y = -35, rot = 0},
			west = {x = -10, y = -35, rot = 0},
		}
		local wep = {
			north = {x = 9, y = -7, rot = math.pi / 3},
			south = {x = -9, y = 7, rot = 3.5 * math.pi / 3},
			east = {x = 7, y = 9, rot = 5 * math.pi / 6},
			west = {x = -7, y = 9, rot = 2 * math.pi - 5 * math.pi / 6},
		}
		if actor.stateTimer <= 0 then 
			local sy = 1
			local sx = 1
			if actor.dir == 'west' then 
				sx = -1
				sy = 1 
			end
			if actor.dir == 'north' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 10, actor.y - 60 + swing[actor.dir].y, 100, 70, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'south' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 90, actor.y - 10 + swing[actor.dir].y, 100, 70, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'east' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 10, actor.y - 20 + swing[actor.dir].y, 70, 100, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			else 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 60, actor.y - 20 + swing[actor.dir].y, 70, 100, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			end
			game.addAnimation('largeswing1', actor.x + swing[actor.dir].x, actor.y + swing[actor.dir].y, swing[actor.dir].rot, sx, sy)
			if actor == player then 
				game.screenShake(13)
			end
			game.playSound('swing1', actor.x, actor.y)
		end
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 7 then 
		actor.walkAnim = 2
		local wep = {
			north = {x = 10, y = -6, rot = math.pi / 2.5},
			south = {x = -10, y = 6, rot = 4 * math.pi / 3},
			east = {x = 8, y = 10, rot = 5.5 * math.pi / 6},
			west = {x = -8, y = 10, rot = 2 * math.pi - 5.5 * math.pi / 6},
		}
		actor.weaponAction = wep[actor.dir]
		if attack and actor.staminaCur >= 1 then 
			actor.state = actor.weapon.lightattack[actor.stateCombo + 1]
			actor.stateCombo = actor.stateCombo + 1
			if not actor.state then 
				actor.state = actor.weapon.lightattack[1]
				actor.stateCombo = 1
			end
			actor.staminaCur = actor.staminaCur - actor.weapon.staminaCost
			actor.staminaGainCD = 1.5
			actor.statePhase = 0
			actor.stateTimer = 0
		end
	elseif actor.statePhase == 8 then 
		local wep = {
			north = {x = 10, y = -6, rot = math.pi / 2.5},
			south = {x = -10, y = 6, rot = 4 * math.pi / 3},
			east = {x = 8, y = 10, rot = 5.5 * math.pi / 6},
			west = {x = -8, y = 10, rot = 2 * math.pi - 5.5 * math.pi / 6},
		}
		actor.weaponAction = wep[actor.dir]
		if attack and actor.staminaCur >= 1 then 
			actor.state = actor.weapon.lightattack[actor.stateCombo + 1]
			actor.stateCombo = actor.stateCombo + 1
			if not actor.state then 
				actor.state = actor.weapon.lightattack[1]
				actor.stateCombo = 1
			end
			actor.staminaCur = actor.staminaCur - actor.weapon.staminaCost
			actor.staminaGainCD = 1.5
			actor.statePhase = 0
			actor.stateTimer = 0
		end
	end
end

function game.actorStateSwordSmash2(actor, dt, attack)
	if actor.statePhase < 4 then
		actor.stateTimer = actor.stateTimer + dt * 0.5
	elseif actor.stateTimer > 5 then 
		actor.stateTimer = actor.stateTimer + dt * 0.45
	end
	local wep = {
		{
			north = {x = -4, y = -3, rot = math.pi / 2 + math.pi / 1.6 - math.pi / 4},
			south = {x = 4, y = -3, rot = math.pi / 8 - math.pi / 4},
			east = {x = 2, y = -3, rot = 2 * math.pi - math.pi / 2.6},
			west = {x = -2, y = -3, rot = math.pi / 2.6},
		},
		{
			north = {x = -4, y = -2, rot = math.pi / 2 + math.pi / 1.6 - math.pi / 3.9},
			south = {x = 4, y = -4, rot = math.pi / 8 - math.pi / 3.9},
			east = {x = 0, y = -3, rot = 2 * math.pi - math.pi / 2.5},
			west = {x = 0, y = -3, rot = math.pi / 2.5},
		},
		{
			north = {x = -3, y = -1, rot = math.pi / 2 + math.pi / 1.6 - math.pi / 3.7},
			south = {x = 3, y = -5, rot = math.pi / 8 - math.pi / 3.7},
			east = {x = -3, y = -3, rot = 2 * math.pi - math.pi / 2.3},
			west = {x = 3, y = -3, rot = math.pi / 2.3},
		},
		{
			north = {x = -3, y = 2, rot = math.pi / 2 + math.pi / 1.6 - math.pi / 3.4},
			south = {x = 3, y = -7, rot = math.pi / 8 - math.pi / 3.4},
			east = {x = -6, y = -3, rot = 2 * math.pi - math.pi / 2},
			west = {x = 6, y = -3, rot = math.pi / 2.},
		},
		{
			north = {x = -9, y = -6, rot = math.pi / 2 + math.pi / 1.6 - math.pi / 4 + math.pi * 0.75},
			south = {x = 9, y = 1, rot = math.pi * 0.35},
			east = {x = -1, y = -10, rot = 2 * math.pi - math.pi / 5.9},
			west = {x = 1, y = -10, rot = math.pi / 5.9},
		},
		{
			north = {x = 8, y = -17, rot = math.pi * 0.15},
			south = {x = -8, y = 12, rot = math.pi + math.pi * 0.15},
			east = {x = 13, y = 8, rot = math.pi / 2 + math.pi / 6},
			west = {x = -13, y = 8, rot = 2 * math.pi - (math.pi / 2 + math.pi / 6)},
		},
		{
			north = {x = 9, y = -16, rot = math.pi * 0.2},
			south = {x = -9, y = 11, rot = math.pi + math.pi * 0.2},
			east = {x = 12, y = 9, rot = math.pi / 2 + math.pi / 4},
			west = {x = -12, y = 9, rot = 2 * math.pi - (math.pi / 2 + math.pi / 4)},
		},
	}
	local swing = {
		north = {x = -40, y = -20, rot = 0},
		south = {x = 40, y = 20, rot = math.pi},
		east = {x = 10, y = -30, rot = math.pi / 2},
		west = {x = -10, y = -30, rot = math.pi * 1.5},
	}
	if actor.statePhase >= 12 then 
		if actor.statePhase > 13 then 
			actor.state = 'idle'
			actor.weaponAction = {x = 0, y = 0, rot = 0}
		else
			if actor.stateTimer <= 0 then 
				actor.weaponAction = {
					x = actor.weaponAction.x - (actor.weaponAction.x - actor.weapon.dx[actor.dir]) / 2, 
					y = actor.weaponAction.y - (actor.weaponAction.y - actor.weapon.dy[actor.dir]) / 2, 
					rot = actor.weaponAction.rot - (actor.weaponAction.rot - actor.weapon.rot[actor.dir]) / 2 
				}
			end
		end
	else
		if actor.statePhase == 4 and actor.stateTimer <= 0 then 
			local sy = 1
			local sx = 1
			if actor.dir == 'west' then 
				sx = 1
				sy = -1 
			end
			actor.walkAnim = 2
			if actor.dir == 'east' or actor.dir == 'west' then 
				actor.walkAnim = 3
			end
			actor.moveDir = actor.dir
			if actor.dir == 'north' then 
				game.addHurtbox(actor.team, actor.x - 22, actor.y - 95, 38, 90, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'south' then 
				game.addHurtbox(actor.team, actor.x - 14, actor.y, 38, 90, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'east' then 
				game.addHurtbox(actor.team, actor.x, actor.y - 15, 80, 42, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			else 
				game.addHurtbox(actor.team, actor.x - 70, actor.y - 15, 80, 42, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			end
			game.addAnimation('swordsmash1', actor.x + swing[actor.dir].x, actor.y + swing[actor.dir].y, swing[actor.dir].rot - math.pi / 2, sx, sy)
			if actor == player then 
				game.screenShake(300)
			end
			game.playSound('swing2', actor.x, actor.y)
			game.playSound('crush1', actor.x, actor.y)
		elseif actor.statePhase > 3 and actor.statePhase < 5 then 
			local step = {
				north = {0, -300},
				south = {0, 300},
				east = {300, 0},
				west = {-300, 0},
			}
			local newX, newY = actor.x + step[actor.dir][1] * dt, actor.y + step[actor.dir][2] * dt 
			local aX, aY, cols, len = world:move(actor, newX - actor.hitBoxWidth / 2, newY - actor.hitBoxHeight / 2, function(item, other) if other.type == 'bg'or other.type == 'ladder' then return false else return 'slide' end end)
			actor.walkAnim = 2
			if actor.dir == 'east' or actor.dir == 'west' then 
				actor.walkAnim = 3
			end
			actor.moveDir = actor.dir
			actor.x = aX + actor.hitBoxWidth / 2
			actor.y = aY + actor.hitBoxHeight / 2
		end
		if wep[actor.statePhase+1] then 
			actor.weaponAction.x = wep[math.min(6, actor.statePhase+1)][actor.dir].x
			actor.weaponAction.y = wep[math.min(6, actor.statePhase+1)][actor.dir].y
			actor.weaponAction.rot = wep[math.min(6, actor.statePhase+1)][actor.dir].rot
		end
	end
end

function game.actorStateLargeSwing1(actor, dt, attack)
	if actor.statePhase < 5 then 
		actor.stateTimer = actor.stateTimer + dt * 0.25
	end
	if actor.statePhase >= 10 then 
		if actor.statePhase > 11 then 
			actor.state = 'idle'
			actor.weaponAction = {x = 0, y = 0, rot = 0}
		else
			if actor.stateTimer <= 0 then
				actor.weaponAction = {
					x = actor.weaponAction.x - (actor.weaponAction.x - actor.weapon.dx[actor.dir]) / 2, 
					y = actor.weaponAction.y - (actor.weaponAction.y - actor.weapon.dy[actor.dir]) / 2, 
					rot = actor.weaponAction.rot - (actor.weaponAction.rot - actor.weapon.rot[actor.dir]) / 2 
				}
			end
		end
	elseif actor.statePhase < 3 then 
		local wep = {
			north = {x = -4, y = -3, rot = 4 * math.pi / 3},
			south = {x = 4, y = 3, rot = math.pi / 3},
			east = {x = 6, y = -3, rot = math.pi / 8},
			west = {x = -6, y = -3, rot = math.pi * 2 - math.pi / 8},
		}
		local off = {
			north = {x = -7, y = 2, rot = math.pi * 1.9},
			south = {x = 7, y = 2, rot = math.pi * 0.1},
			east = {x = -7, y = 2, rot = math.pi * 1.8},
			west = {x = 7, y = 2, rot = math.pi * 0.2},
		}
		actor.offhandAction = off[actor.dir]
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 4 then 
		local wep = {
			north = {x = -7, y = -4, rot = 5 * math.pi / 4},
			south = {x = 7, y = 4, rot = math.pi / 4},
			east = {x = 7, y = -4, rot = math.pi / 16},
			west = {x = -7, y = -4, rot = math.pi * 2 - math.pi / 16},
		}
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 5 then 
		local wep = {
			north = {x = -7, y = -3, rot = 5 * math.pi / 4},
			south = {x = 7, y = 3, rot = math.pi / 4},
			east = {x = 9, y = -5, rot = -0.02},
			west = {x = -9, y = -4, rot = 0.02},
		}
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 6 then 
		local step = {
			north = {0, -150},
			south = {0, 150},
			east = {150, 0},
			west = {-150, 0},
		}
		local newX, newY = actor.x + step[actor.dir][1] * dt, actor.y + step[actor.dir][2] * dt 
		local aX, aY, cols, len = world:move(actor, newX, newY, function(item, other) if other.type == 'bg'or other.type == 'ladder' then return false else return 'slide' end end)
		if len == 0 then 
			actor.x = actor.x + step[actor.dir][1] * dt 
			actor.y = actor.y + step[actor.dir][2] * dt 
		end
		actor.walkAnim = 2
		actor.moveDir = actor.dir
		local swing = {
			north = {x = -30, y = -10, rot = math.pi + math.pi / 2},
			south = {x = 30, y = 10, rot = math.pi / 2},
			east = {x = 10, y = -35, rot = 0},
			west = {x = -10, y = -35, rot = 0},
		}
		local wep = {
			north = {x = 9, y = -7, rot = math.pi / 3},
			south = {x = -9, y = 7, rot = 3.5 * math.pi / 3},
			east = {x = 7, y = 9, rot = 5 * math.pi / 6},
			west = {x = -7, y = 9, rot = 2 * math.pi - 5 * math.pi / 6},
		}
		if actor.stateTimer <= 0 then 
			local sy = 1
			local sx = 1
			if actor.dir == 'west' then 
				sx = -1
				sy = 1 
			end
			if actor.dir == 'north' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 10, actor.y - 60 + swing[actor.dir].y, 100, 70, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'south' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 90, actor.y - 10 + swing[actor.dir].y, 100, 70, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'east' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 10, actor.y - 20 + swing[actor.dir].y, 70, 100, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			else 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 60, actor.y - 20 + swing[actor.dir].y, 70, 100, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			end
			game.addAnimation('largeswing1', actor.x + swing[actor.dir].x, actor.y + swing[actor.dir].y, swing[actor.dir].rot, sx, sy)
			if actor == player then 
				game.screenShake(13)
			end
			game.playSound('swing1', actor.x, actor.y)
		end
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 7 then 
		actor.walkAnim = 2
		local wep = {
			north = {x = 10, y = -6, rot = math.pi / 2.5},
			south = {x = -10, y = 6, rot = 4 * math.pi / 3},
			east = {x = 8, y = 10, rot = 5.5 * math.pi / 6},
			west = {x = -8, y = 10, rot = 2 * math.pi - 5.5 * math.pi / 6},
		}
		actor.weaponAction = wep[actor.dir]
		if attack and actor.staminaCur >= 1 then 
			actor.state = actor.weapon.lightattack[actor.stateCombo + 1]
			actor.stateCombo = actor.stateCombo + 1
			if not actor.state then 
				actor.state = actor.weapon.lightattack[1]
				actor.stateCombo = 1
			end
			actor.staminaCur = actor.staminaCur - actor.weapon.staminaCost
			actor.staminaGainCD = 1.5
			actor.statePhase = 0
			actor.stateTimer = 0
		end
	elseif actor.statePhase == 8 then 
		local wep = {
			north = {x = 10, y = -6, rot = math.pi / 2.5},
			south = {x = -10, y = 6, rot = 4 * math.pi / 3},
			east = {x = 8, y = 10, rot = 5.5 * math.pi / 6},
			west = {x = -8, y = 10, rot = 2 * math.pi - 5.5 * math.pi / 6},
		}
		actor.weaponAction = wep[actor.dir]
		if attack and actor.staminaCur >= 1 then 
			actor.state = actor.weapon.lightattack[actor.stateCombo + 1]
			actor.stateCombo = actor.stateCombo + 1
			if not actor.state then 
				actor.state = actor.weapon.lightattack[1]
				actor.stateCombo = 1
			end
			actor.staminaCur = actor.staminaCur - actor.weapon.staminaCost
			actor.staminaGainCD = 1.5
			actor.statePhase = 0
			actor.stateTimer = 0
		end
	end
end

function game.actorStateSwing4(actor, dt, attack)
	actor.stateTimer = actor.stateTimer - dt * 0.15
	if actor.statePhase > 4 then 
		actor.stateTimer = actor.stateTimer + dt * 0.25
	end
	if actor.statePhase >= 7 then 
		if actor.statePhase > 8 then 
			actor.state = 'idle'
			actor.weaponAction = {x = 0, y = 0, rot = 0}
		else
			if actor.stateTimer <= 0 then
				actor.weaponAction = {
					x = actor.weaponAction.x - (actor.weaponAction.x - actor.weapon.dx[actor.dir]) / 2, 
					y = actor.weaponAction.y - (actor.weaponAction.y - actor.weapon.dy[actor.dir]) / 2, 
					rot = actor.weaponAction.rot - (actor.weaponAction.rot - actor.weapon.rot[actor.dir]) / 2 
				}
			end
		end
	elseif actor.statePhase == 1 or actor.statePhase == 0 then 
		local wep = {
			north = {x = -4, y = -3, rot = 4 * math.pi / 3},
			south = {x = 4, y = 3, rot = math.pi / 3},
			east = {x = 6, y = -3, rot = math.pi / 8},
			west = {x = -6, y = -3, rot = math.pi * 2 - math.pi / 8},
		}
		local off = {
			north = {x = -7, y = 2, rot = math.pi * 1.9},
			south = {x = 7, y = 2, rot = math.pi * 0.1},
			east = {x = -7, y = 2, rot = math.pi * 1.8},
			west = {x = 7, y = 2, rot = math.pi * 0.2},
		}
		actor.offhandAction = off[actor.dir]
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 2 then 
		local wep = {
			north = {x = -7, y = -4, rot = 5 * math.pi / 4},
			south = {x = 7, y = 4, rot = math.pi / 4},
			east = {x = 7, y = -4, rot = math.pi / 16},
			west = {x = -7, y = -4, rot = math.pi * 2 - math.pi / 16},
		}
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 3 then 
		local wep = {
			north = {x = -7, y = -3, rot = 5 * math.pi / 4},
			south = {x = 7, y = 3, rot = math.pi / 4},
			east = {x = 9, y = -5, rot = -0.02},
			west = {x = -9, y = -4, rot = 0.02},
		}
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 4 then 
		local step = {
			north = {0, -100},
			south = {0, 100},
			east = {100, 0},
			west = {-100, 0},
		}
		local newX, newY = actor.x + step[actor.dir][1] * dt, actor.y + step[actor.dir][2] * dt 
		local aX, aY, cols, len = world:move(actor, newX, newY, function(item, other) if other.type == 'bg'or other.type == 'ladder' then return false else return 'slide' end end)
		if len == 0 then 
			actor.x = actor.x + step[actor.dir][1] * dt 
			actor.y = actor.y + step[actor.dir][2] * dt 
		end
		actor.walkAnim = 2
		actor.moveDir = actor.dir
		local swing = {
			north = {x = 0, y = -12, rot = 0},
			south = {x = 0, y = 12, rot = math.pi},
			east = {x = 12, y = 0, rot = math.pi / 2},
			west = {x = -12, y = 0, rot = math.pi * 1.5},
		}
		local wep = {
			north = {x = 9, y = -7, rot = math.pi / 3},
			south = {x = -9, y = 7, rot = 3.5 * math.pi / 3},
			east = {x = 7, y = 9, rot = 5 * math.pi / 6},
			west = {x = -7, y = 9, rot = 2 * math.pi - 5 * math.pi / 6},
		}
		if actor.stateTimer <= 0 then 
			local sy = 1
			local sx = 1
			if actor.dir == 'west' then 
				sx = -1
				sy = 1 
			end
			if actor.dir == 'north' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 12, actor.y - 6 + swing[actor.dir].y, 24, 12, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 20, actor.y - 18 + swing[actor.dir].y, 40, 14, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'south' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 12, actor.y -4 + swing[actor.dir].y, 24, 12, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 20, actor.y + 8 + swing[actor.dir].y, 40, 14, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'east' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 6, actor.y - 12 + swing[actor.dir].y, 12, 24, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x + 4, actor.y - 20 + swing[actor.dir].y, 14, 40, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			else 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 6, actor.y - 12 + swing[actor.dir].y, 12, 24, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 18, actor.y - 20 + swing[actor.dir].y, 14, 40, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			end
			game.addAnimation('swing1', actor.x + swing[actor.dir].x, actor.y + swing[actor.dir].y, swing[actor.dir].rot, sx, sy)
			if actor == player then 
				game.screenShake(16)
			end
			game.playSound('swing1', actor.x, actor.y)
		end
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 5 then 
		actor.walkAnim = 2
		local wep = {
			north = {x = 10, y = -6, rot = math.pi / 2.5},
			south = {x = -10, y = 6, rot = 4 * math.pi / 3},
			east = {x = 8, y = 10, rot = 5.5 * math.pi / 6},
			west = {x = -8, y = 10, rot = 2 * math.pi - 5.5 * math.pi / 6},
		}
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 6 then 
		local wep = {
			north = {x = 10, y = -6, rot = math.pi / 2.5},
			south = {x = -10, y = 6, rot = 4 * math.pi / 3},
			east = {x = 8, y = 10, rot = 5.5 * math.pi / 6},
			west = {x = -8, y = 10, rot = 2 * math.pi - 5.5 * math.pi / 6},
		}
		actor.weaponAction = wep[actor.dir]
	end
end

function game.actorStateSwing3(actor, dt, attack)
	actor.stateTimer = actor.stateTimer + dt * 0.15
	if actor.statePhase >= 7 then 
		if actor.statePhase > 8 then 
			actor.state = 'idle'
			actor.weaponAction = {x = 0, y = 0, rot = 0}
		else
			if actor.stateTimer <= 0 then
				actor.weaponAction = {
					x = actor.weaponAction.x - (actor.weaponAction.x - actor.weapon.dx[actor.dir]) / 2, 
					y = actor.weaponAction.y - (actor.weaponAction.y - actor.weapon.dy[actor.dir]) / 2, 
					rot = actor.weaponAction.rot - (actor.weaponAction.rot - actor.weapon.rot[actor.dir]) / 2 
				}
			end
		end
	elseif actor.statePhase == 1 or actor.statePhase == 0 then 
		local wep = {
			north = {x = -4, y = -3, rot = 4 * math.pi / 3},
			south = {x = 4, y = 3, rot = math.pi / 3},
			east = {x = 6, y = -3, rot = math.pi / 8},
			west = {x = -6, y = -3, rot = math.pi * 2 - math.pi / 8},
		}
		local off = {
			north = {x = -7, y = 2, rot = math.pi * 1.9},
			south = {x = 7, y = 2, rot = math.pi * 0.1},
			east = {x = -7, y = 2, rot = math.pi * 1.8},
			west = {x = 7, y = 2, rot = math.pi * 0.2},
		}
		actor.offhandAction = off[actor.dir]
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 2 then 
		local wep = {
			north = {x = -7, y = -4, rot = 5 * math.pi / 4},
			south = {x = 7, y = 4, rot = math.pi / 4},
			east = {x = 7, y = -4, rot = math.pi / 16},
			west = {x = -7, y = -4, rot = math.pi * 2 - math.pi / 16},
		}
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 3 then 
		local wep = {
			north = {x = -7, y = -3, rot = 5 * math.pi / 4},
			south = {x = 7, y = 3, rot = math.pi / 4},
			east = {x = 9, y = -5, rot = -0.02},
			west = {x = -9, y = -4, rot = 0.02},
		}
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 4 then 
		local step = {
			north = {0, -100},
			south = {0, 100},
			east = {100, 0},
			west = {-100, 0},
		}
		local newX, newY = actor.x + step[actor.dir][1] * dt, actor.y + step[actor.dir][2] * dt 
		local aX, aY, cols, len = world:move(actor, newX, newY, function(item, other) if other.type == 'bg'or other.type == 'ladder' then return false else return 'slide' end end)
		if len == 0 then 
			actor.x = actor.x + step[actor.dir][1] * dt 
			actor.y = actor.y + step[actor.dir][2] * dt 
		end
		actor.walkAnim = 2
		actor.moveDir = actor.dir
		local swing = {
			north = {x = 0, y = -12, rot = 0},
			south = {x = 0, y = 12, rot = math.pi},
			east = {x = 12, y = 0, rot = math.pi / 2},
			west = {x = -12, y = 0, rot = math.pi * 1.5},
		}
		local wep = {
			north = {x = 9, y = -7, rot = math.pi / 3},
			south = {x = -9, y = 7, rot = 3.5 * math.pi / 3},
			east = {x = 7, y = 9, rot = 5 * math.pi / 6},
			west = {x = -7, y = 9, rot = 2 * math.pi - 5 * math.pi / 6},
		}
		if actor.stateTimer <= 0 then 
			local sy = 1
			local sx = 1
			if actor.dir == 'west' then 
				sx = -1
				sy = 1 
			end
			if actor.dir == 'north' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 12, actor.y - 6 + swing[actor.dir].y, 24, 12, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 20, actor.y - 18 + swing[actor.dir].y, 40, 14, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'south' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 12, actor.y -4 + swing[actor.dir].y, 24, 12, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 20, actor.y + 8 + swing[actor.dir].y, 40, 14, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'east' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 6, actor.y - 12 + swing[actor.dir].y, 12, 24, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x + 4, actor.y - 20 + swing[actor.dir].y, 14, 40, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			else 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 6, actor.y - 12 + swing[actor.dir].y, 12, 24, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 18, actor.y - 20 + swing[actor.dir].y, 14, 40, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			end
			game.addAnimation('swing2', actor.x + swing[actor.dir].x, actor.y + swing[actor.dir].y, swing[actor.dir].rot, sx, sy)
			if actor == player then 
				game.screenShake(13)
			end
			game.playSound('swing1', actor.x, actor.y)
		end
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 5 then 
		actor.walkAnim = 2
		local wep = {
			north = {x = 10, y = -6, rot = math.pi / 2.5},
			south = {x = -10, y = 6, rot = 4 * math.pi / 3},
			east = {x = 8, y = 10, rot = 5.5 * math.pi / 6},
			west = {x = -8, y = 10, rot = 2 * math.pi - 5.5 * math.pi / 6},
		}
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 6 then 
		local wep = {
			north = {x = 10, y = -6, rot = math.pi / 2.5},
			south = {x = -10, y = 6, rot = 4 * math.pi / 3},
			east = {x = 8, y = 10, rot = 5.5 * math.pi / 6},
			west = {x = -8, y = 10, rot = 2 * math.pi - 5.5 * math.pi / 6},
		}
		actor.weaponAction = wep[actor.dir]
		if attack and actor.staminaCur >= 1 then 
			actor.state = actor.weapon.lightattack[actor.stateCombo + 1]
			actor.stateCombo = actor.stateCombo + 1
			if not actor.state then 
				actor.state = actor.weapon.lightattack[1]
				actor.stateCombo = 1
			end
			actor.staminaCur = actor.staminaCur - actor.weapon.staminaCost
			actor.staminaGainCD = 1.5
			actor.statePhase = 0
			actor.stateTimer = 0
		end
	end
end

function game.actorStateSwing1(actor, dt, attack)
	if actor.statePhase >= 7 then 
		if actor.statePhase > 8 then 
			actor.state = 'idle'
			actor.weaponAction = {x = 0, y = 0, rot = 0}
		else
			if actor.stateTimer <= 0 then
				actor.weaponAction = {
					x = actor.weaponAction.x - (actor.weaponAction.x - actor.weapon.dx[actor.dir]) / 2, 
					y = actor.weaponAction.y - (actor.weaponAction.y - actor.weapon.dy[actor.dir]) / 2, 
					rot = actor.weaponAction.rot - (actor.weaponAction.rot - actor.weapon.rot[actor.dir]) / 2 
				}
			end
		end
	elseif actor.statePhase == 1 or actor.statePhase == 0 then 
		local wep = {
			north = {x = -4, y = -3, rot = 4 * math.pi / 3},
			south = {x = 4, y = 3, rot = math.pi / 3},
			east = {x = 6, y = -3, rot = math.pi / 8},
			west = {x = -6, y = -3, rot = math.pi * 2 - math.pi / 8},
		}
		local off = {
			north = {x = -7, y = 2, rot = math.pi * 1.9},
			south = {x = 7, y = 2, rot = math.pi * 0.1},
			east = {x = -7, y = 2, rot = math.pi * 1.8},
			west = {x = 7, y = 2, rot = math.pi * 0.2},
		}
		actor.offhandAction = off[actor.dir]
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 2 then 
		local wep = {
			north = {x = -7, y = -4, rot = 5 * math.pi / 4},
			south = {x = 7, y = 4, rot = math.pi / 4},
			east = {x = 7, y = -4, rot = math.pi / 16},
			west = {x = -7, y = -4, rot = math.pi * 2 - math.pi / 16},
		}
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 3 then 
		local wep = {
			north = {x = -7, y = -3, rot = 5 * math.pi / 4},
			south = {x = 7, y = 3, rot = math.pi / 4},
			east = {x = 9, y = -5, rot = -0.02},
			west = {x = -9, y = -4, rot = 0.02},
		}
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 4 then 
		local step = {
			north = {0, -150},
			south = {0, 150},
			east = {150, 0},
			west = {-150, 0},
		}
		local newX, newY = actor.x + step[actor.dir][1] * dt, actor.y + step[actor.dir][2] * dt 
		local aX, aY, cols, len = world:move(actor, newX, newY, function(item, other) if other.type == 'bg'or other.type == 'ladder' then return false else return 'slide' end end)
		if len == 0 then 
			actor.x = actor.x + step[actor.dir][1] * dt 
			actor.y = actor.y + step[actor.dir][2] * dt 
		end
		actor.walkAnim = 2
		actor.moveDir = actor.dir
		local swing = {
			north = {x = 0, y = -12, rot = 0},
			south = {x = 0, y = 12, rot = math.pi},
			east = {x = 12, y = 0, rot = math.pi / 2},
			west = {x = -12, y = 0, rot = math.pi * 1.5},
		}
		local wep = {
			north = {x = 9, y = -7, rot = math.pi / 3},
			south = {x = -9, y = 7, rot = 3.5 * math.pi / 3},
			east = {x = 7, y = 9, rot = 5 * math.pi / 6},
			west = {x = -7, y = 9, rot = 2 * math.pi - 5 * math.pi / 6},
		}
		if actor.stateTimer <= 0 then 
			local sy = 1
			local sx = 1
			if actor.dir == 'west' then 
				sx = -1
				sy = 1 
			end
			if actor.dir == 'north' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 12, actor.y - 6 + swing[actor.dir].y, 24, 12, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 20, actor.y - 18 + swing[actor.dir].y, 40, 14, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'south' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 12, actor.y -4 + swing[actor.dir].y, 24, 12, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 20, actor.y + 8 + swing[actor.dir].y, 40, 14, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			elseif actor.dir == 'east' then 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 6, actor.y - 12 + swing[actor.dir].y, 12, 24, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x + 4, actor.y - 20 + swing[actor.dir].y, 14, 40, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			else 
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 6, actor.y - 12 + swing[actor.dir].y, 12, 24, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
				game.addHurtbox(actor.team, actor.x + swing[actor.dir].x - 18, actor.y - 20 + swing[actor.dir].y, 14, 40, 0.08, game.actorGetWeaponDamage(actor), actor.weapon.dtype, actor.x, actor.y, actor.weapon.stundam, actor.weapon.bdam, actor.weapon.knockback)
			end
			game.addAnimation('swing1', actor.x + swing[actor.dir].x, actor.y + swing[actor.dir].y, swing[actor.dir].rot, sx, sy)
			if actor == player then 
				game.screenShake(13)
			end
			game.playSound('swing1', actor.x, actor.y)
		end
		actor.weaponAction = wep[actor.dir]
	elseif actor.statePhase == 5 then 
		actor.walkAnim = 2
		local wep = {
			north = {x = 10, y = -6, rot = math.pi / 2.5},
			south = {x = -10, y = 6, rot = 4 * math.pi / 3},
			east = {x = 8, y = 10, rot = 5.5 * math.pi / 6},
			west = {x = -8, y = 10, rot = 2 * math.pi - 5.5 * math.pi / 6},
		}
		actor.weaponAction = wep[actor.dir]
		if attack and actor.staminaCur >= 1 then 
			actor.state = actor.weapon.lightattack[actor.stateCombo + 1]
			actor.stateCombo = actor.stateCombo + 1
			if not actor.state then 
				actor.state = actor.weapon.lightattack[1]
				actor.stateCombo = 1
			end
			actor.staminaCur = actor.staminaCur - actor.weapon.staminaCost
			actor.staminaGainCD = 1.5
			actor.statePhase = 0
			actor.stateTimer = 0
		end
	elseif actor.statePhase == 6 then 
		local wep = {
			north = {x = 10, y = -6, rot = math.pi / 2.5},
			south = {x = -10, y = 6, rot = 4 * math.pi / 3},
			east = {x = 8, y = 10, rot = 5.5 * math.pi / 6},
			west = {x = -8, y = 10, rot = 2 * math.pi - 5.5 * math.pi / 6},
		}
		actor.weaponAction = wep[actor.dir]
		if attack and actor.staminaCur >= 1 then 
			actor.state = actor.weapon.lightattack[actor.stateCombo + 1]
			actor.stateCombo = actor.stateCombo + 1
			if not actor.state then 
				actor.state = actor.weapon.lightattack[1]
				actor.stateCombo = 1
			end
			actor.staminaCur = actor.staminaCur - actor.weapon.staminaCost
			actor.staminaGainCD = 1.5
			actor.statePhase = 0
			actor.stateTimer = 0
		end
	end
end

function game.actorTakeDamage(actor, dam, dtype, sx, sy, stun, bdam, knockback)
	if actor.invul <= 0 then 
		local shield = false 
		local def = 0
		if actor.armorChest then 
			def = def + actor.armorChest.def
		end
		dam = dam * (1 - def / 100)
		if actor.state == 'shield' then 
			if sx > actor.x and actor.dir == 'east' then 
				shield = true 
			elseif sx < actor.x and actor.dir == 'west' then 
				shield = true 
			end 
			if sy > actor.y and actor.dir == 'south' then 
				shield = true 
			elseif sy < actor.y and actor.dir == 'north' then 
				shield = true 
			end
		end
		if shield then 
			if bdam > actor.offhand.stability then 
				dam = dam * (1 - actor.offhand.block[dtype] / 125)
				actor.invul = 0.08
				actor.dx = 0
				actor.dy = 0
				actor.balanceCur = actor.balanceCur - bdam 
				if actor.balanceCur <= 0 then 
					actor.hurt = 0.15
					actor.state = 'stun' 
					actor.stateTimer = stun 
					actor.balanceCur = game.actorGetBalance(actor)
					actor.staminaCur = actor.staminaCur - actor.offhand.staminaGuard * 2.5

					dam = dam * (1 - actor.offhand.block[dtype] / 175)
				else
					actor.block = 0.3 
					actor.staminaCur = actor.staminaCur - actor.offhand.staminaGuard * 1.75
					if actor.staminaCur <= 0 then 
						actor.state = 'idle'
						actor.stamina = 0
						actor.staminaGainCD = 2
					end
				end
			else 
				dam = dam * (1 - actor.offhand.block[dtype] / 100)
				actor.block = 0.3
				actor.invul = 0.08
				actor.dx = 0
				actor.dy = 0
				actor.staminaCur = actor.staminaCur - actor.offhand.staminaGuard
				if actor.staminaCur <= 0 then 
					actor.state = 'idle' 
					actor.stamina = 0 
					actor.staminaGainCD = 2
				end
			end
		else
			actor.balanceCur = actor.balanceCur - bdam
			if actor.balanceCur <= 0 then 
				actor.state = 'stun'
				actor.stateTimer = stun
				actor.balanceCur = game.actorGetBalance(actor)
			end
			if actor.bloodType == 'animal' then 
				game.addDecal('blood2', actor.x, actor.y + 6, love.math.random(1, 630) / 360)
				actor.invul = 0.08
				actor.hurt = 0.15
				game.emitParticlesAt('redblood', actor.x, actor.y, 55)
			end
		end
		--- armor
		local d = game.actorGetDefense(actor)
		dam = dam * (1 - (d[dtype] / 100))
		actor.healthCur = actor.healthCur - dam
		game.timeOut(0.01)
		game.playSound('hurt1', actor.x, actor.y)
		local d = math.sqrt((actor.y - sy)^2 + (actor.x - sx)^2) / 50
		local newX, newY = (actor.x + (sx - actor.x) * knockback / d), (actor.y + (sy - actor.y) * knockback / d)
		local aX, aY, cols, len = world:move(actor, newX, newY, function(item, other) if other.type == 'bg'or other.type == 'ladder' then return false else return 'slide' end end)
		actor.x = aX
		actor.y = aY
		if actor.healthCur <= 0 then 
			game.killActor(actor)
		end
		if actor == player then 
			game.screenShake(15)
		end
	end
end

function game.killActor(actor)
	if not actor.dead then 
		dead[actor.name] = true
		actor.healthCur = 0 
		actor.dead = true 
		game.addGibs(actor.x, actor.y, math.floor(actor.hitBoxWidth * 0.4), math.floor(actor.hitBoxHeight * 0.4), actor.gibAmount[1], actor.gibAmount[2], actor.gibAmount[3], actor.color, actor.bloodType)
		table.insert(residualLights, {light = 14, change = 350, x = actor.x, y = actor.y, color = {1 - actor.color[1] / 255, 1 - actor.color[2] / 255, 1 - actor.color[3] / 255}})
		game.timeOut(0.01)
		world:remove(actor)
		if actor.boss or actor.permDead then 
			permDead[actor.name] = true
		end
		if not actor.falling then 
			if actor.bloodType == 'animal' then 
				game.addDecal('blood1', actor.x, actor.y + 6, love.math.random(1, 630) / 360)
				game.emitParticlesAt('redblood', actor.x-8, actor.y, 15)
				game.emitParticlesAt('redblood', actor.x+8, actor.y, 15)
				game.emitParticlesAt('redblood', actor.x, actor.y-8, 15)
				game.emitParticlesAt('redblood', actor.x, actor.y+8, 15)
			end
		end
		if actor ~= player then 
			game.addMatterShard(actor.matter, actor.x, actor.y)
			if actor.boss then 
				game.addBigText({text = 'Victory Achieved', subtext = 'An Heir of Matter Has Been Defeated', intake = true, oy = -256, color = {251, 242, 54}, df = 1.25, fade = -75, dt = 7})
			end
			if actor.dropList then 
				for i = 1, # actor.dropList do 
					game.addItemToInventory({item = items[actor.dropList[1]], type = items[actor.dropList[1]].sort, stack = 1 , stackable = false})
				end
			end
		else
			if player.matter > 0 or player.darkMatter > 0 then 
				if actor.falling then 
					matterDrop = {world = curMap, dark = player.darkMatter, spawnCd = 9, amount = player.matter, x = player.x + player.intfall[1] * -5, y = player.y + player.intfall[2] * -5}
				else
					matterDrop = {world = curMap, dark = player.darkMatter, spawnCd = 9, amount = player.matter, x = player.x, y = player.y}
				end
				player.matter = 0
				player.darkMatter = 0
			else 
				matterDrop = false 
			end
			player.darkMatterIntake = false
			player.darkMatterIntakeCD = false
			for i = 1, # player.attunement do 
				player.attunement[i].casts = player.attunement[i].spell.casts
			end
			curWorld = false
			player.inGrapple = false
			game.addBigText({text = 'You Died', color = {255, 0, 0}, size = 2, oy = -60, fade = -125, df = 1.25, dt = 7.25})
		end
	end
end

function game.actorGetBackstabAble(actor)
	local backstab = false
	for i = 1, # actors do 
		if not actor.backstab and actor.weapon ~= weapons.hand and not actors[i].dead and not actors[i].falling and actors[i].team ~= actor.team and math.sqrt((actors[i].x - actor.x)^2 + (actors[i].y - actor.y)^2) <= 32 then 
			if actors[i].dir == 'north' and actor.y > actors[i].y + 13 and actor.dir == 'north' then 
				backstab = {dt = 0, other = actors[i], sx = actors[i].x, sy = actors[i].y + 24, ox = actors[i].x, oy = actors[i].y, dir = 'north'}
			elseif actors[i].dir == 'south' and actor.y < actors[i].y - 13 and actor.dir == 'south' then 
				backstab = {dt = 0, other = actors[i], sx = actors[i].x, sy = actors[i].y - 24, ox = actors[i].x, oy = actors[i].y, dir = 'south'}
			elseif actors[i].dir == 'west' and actor.x > actors[i].x + 9 and actor.dir == 'west' then 
				if math.sqrt((actors[i].x - actor.x)^2 + (actors[i].y - actor.y)^2) <= 21 then 
					backstab = {dt = 0, other = actors[i], sx = actors[i].x + 13, sy = actors[i].y, ox = actors[i].x, oy = actors[i].y, dir = 'west'}
				end
			elseif actors[i].dir == 'east' and actor.x < actors[i].x - 9 and actor.dir == 'east' then 
				if math.sqrt((actors[i].x - actor.x)^2 + (actors[i].y - actor.y)^2) <= 21 then 
					backstab = {dt = 0, other = actors[i], sx = actors[i].x - 13, sy = actors[i].y, ox = actors[i].x, oy = actors[i].y, dir = 'east'}
				end
			end
			if backstab and backstab.other.disableBackstab then 
				backstab = false 
			end
		end
		if backstab then break end
	end
	return backstab
end

function game.actorUseMainhand(actor)
	local thand = false
	if actor.backstab then 
		return 
	end
	if not actor.weapon then 
		thand = true 
		actor.weapon = weapons.hand 
	end
	if actor.state == 'idle' and actor.weapon then 
		--- check for backstab
		actor.backstab = game.actorGetBackstabAble(actor)
		if not actor.backstab then 
			actor.weaponAction = {x = actor.weapon.dx[actor.dir], y = actor.weapon.dy[actor.dir], rot = actor.weapon.rot[actor.dir]}
			actor.state = actor.weapon.lightattack[1]
			actor.staminaCur = actor.staminaCur - actor.weapon.staminaCost
			actor.staminaGainCD = 1.5
			actor.stateTimer = 0
			actor.statePhase = 0
			actor.stateCombo = 1
		else
			actor.state = 'stab1'
			actor.statePhase = 0
			actor.stateTimer = 0
			actor.stateCombo = 0
			actor.stateNoHitBox = true
		end
	end
	if thand then 
		actor.weapon = false 
	end
end

function game.drawOffhand(actor, ox, oy, ofr, dir, sway, recur)
	local thand = false 
	local walk = math.floor(actor.walkAnim)
	if not actor.offhand then 
		if not actor.weapon or (actor.weapon and not actor.weapon.twohand) then 
			thand = true 
			actor.offhand = weapons.offhand 
		end
	end
	if actor.offhand then 
		local shade = love.graphics.getShader()
		local x = actor.x + actor.offhand.dx[dir] + sway[dir][walk][1]
		local y = actor.y + actor.offhand.dy[dir] + sway[dir][walk][2]
		local rot = actor.offhand.rot[dir]
		local sy = 1
		if actor.onLadder then 
			y = y - sway[dir][walk][2] * 4 - 4
		end
		if actor.state ~= 'idle' and actor.state ~= 'dodge' then 
			x = actor.x + actor.offhandAction.x 
			y = actor.y + actor.offhandAction.y 
			rot = actor.offhandAction.rot 
		end 
		if actor.block >= 0.25 then 
			love.graphics.setShader(colorWhite)
		end
		if actor.state == 'stun' then 
			x = actor.x + actor.offhand.stun.x 
			y = actor.y + actor.offhand.stun.y 
			rot = actor.offhand.stun.rot
		end
		if actor.state == 'dodge' then 
			if actor.state == 'dodge' then 
				local changewep = 4
				local t = {
					north = math.pi / 4,
					south = 2 * math.pi - math.pi / 4,
					east = math.pi / 4,
					west = 2 * math.pi - math.pi / 4,
				}
				local tx = {
					north = 1,
					south = -1,
					east = 1,
					west = -1,
				}
				if game.actorGetMobility(actor) == 'normal' then 
					changewep = 6
				elseif game.actorGetMobility(actor) == 'slow' then 
					changewep = 8
				end
				rot = t[actor.dir]
				ox = tx[actor.dir]
				if actor.offhand and actor.statePhase < changewep then 
					if actor.offhand.dodge then
						local z = 0
						if game.actorGetMobility(actor) == 'normal' then 
							z = 1 
						elseif game.actorGetMobility(actor) == 'slow' then 
							z = 2 
						end
						ox = actor.offhand.dodge[actor.dir][1]
						oy = actor.offhand.dodge[actor.dir][2]
						rot = actor.offhand.dodge[actor.dir][3+z]
					end
				else
					ox = 0
					oy = 0
					rot = actor.offhand.rot[actor.dir]
				end
			end
		end
		love.graphics.draw(img.weapon[actor.offhand.img], x + ox, y + oy + actor.headOffY + actor.handOY, rot + ofr, math.min(actor.sx, actor.wepScale), math.min(actor.sy, math.min(sy, actor.wepScale)), actor.offhand.ox, actor.offhand.oy)
		love.graphics.setShader(shade)
	end
	if thand then 
		actor.offhand = false 
	end
end

function game.drawWeapon(actor, ox, oy, ofr, drink, dir, sway, recur) 
	local thand = false
	local walk = math.floor(actor.walkAnim)
	if not actor.weapon then 
		thand = true 
		actor.weapon = weapons.hand
	end
	if actor.weapon then
		local x = actor.x + actor.weapon.dx[dir] + sway[dir][walk][1]
		local y = actor.y + actor.weapon.dy[dir] + sway[dir][walk][2]
		local rot = actor.weapon.rot[dir]
		local iimg = img.weapon[actor.weapon.img]
		local wox, woy = actor.weapon.ox, actor.weapon.oy
		local sy = 1
		if actor.onLadder then 
			y = y + sway[dir][walk][2] * 2 - 4
		end
		if drink then 
			iimg = img.playerType.drink 
			wox, woy = 15, 15
		end
		if actor.state == 'grapple' then 
			x = actor.x + actor.weaponAction.x 
			y = actor.y + actor.weaponAction.y 
			wox, woy = 15, 15
			rot = actor.weaponAction.rot
			iimg = img.weapon.grapple
		end
		if actor.sprint > 0 and actor.weapon and actor.weapon.sprint and not actor.onLadder then 
			x = actor.x + actor.weapon.sprint[dir].x + sway[dir][walk][1]
			y = actor.y + actor.weapon.sprint[dir].y + sway[dir][walk][2]
			rot = actor.weapon.sprint[dir].rot
		end
		if actor.state ~= 'idle' and actor.state ~= 'shield' and actor.state ~= 'dodge' then 
			x = actor.x + actor.weaponAction.x 
			y = actor.y + actor.weaponAction.y 
			rot = actor.weaponAction.rot
		end
		if actor.state == 'stun' then 
			x = actor.x + actor.weapon.stun.x 
			y = actor.y + actor.weapon.stun.y 
			rot = actor.weapon.stun.rot
		end
		if actor.state == 'dodge' then 
			--- 9, 7, 6
			local changewep = 4
			local t = {
				north = 2 * math.pi - math.pi / 4,
				south = math.pi / 4,
				east = 2 * math.pi - math.pi / 4,
				west = math.pi / 4,
			}
			local tx = {
				north = -1,
				south = 1,
				east = -1,
				west = 1,
			}
			if game.actorGetMobility(actor) == 'normal' then 
				changewep = 6
				t = {
					north = 2 * math.pi - math.pi / 10,
					south = math.pi / 10,
					east = 2 * math.pi - math.pi / 10,
					west = math.pi / 10,
				}
			elseif game.actorGetMobility(actor) == 'slow' then
				changewep = 8
				t = {
					north = 0,
					south = 0,
					east = 0,
					west = 0,
				}
			end
			rot = t[actor.dir]
			ox = tx[actor.dir]
			if actor.weapon and actor.statePhase < changewep then 
				if actor.weapon.dodge then 
					local z = 0
					if game.actorGetMobility(actor) == 'normal' then 
						z = 1 
					elseif game.actorGetMobility(actor) == 'slow' then 
						z = 2 
					end
					ox = actor.weapon.dodge[actor.dir][1]
					oy = actor.weapon.dodge[actor.dir][2]
					rot = actor.weapon.dodge[actor.dir][3+z]
				end
			else 
				ox = 0
				oy = 0
				rot = actor.weapon.rot[actor.dir]
			end
		end
		love.graphics.draw(iimg, x + ox, y + oy + actor.headOffY + actor.handOY, rot + ofr, math.min(actor.sx, actor.wepScale), math.min(actor.sy, math.min(sy, actor.wepScale)), wox, woy)
	end
	if thand then 
		actor.weapon = false 
	end
end

function game.drawPlayerType(actor, recur)
	local pcanvas = actorCanvas
	local tcan = love.graphics.getCanvas()
	local dir = actor.dir 
	local mdir = actor.moveDir
	local walk = math.floor(actor.walkAnim)
	local bob = 0
	local ox, oy, ooy = 0, 0, 0
	local ofr = 0
	local iimg = false
	local sy = 1
	local actorClosest = false
	local sway = {
			north = { {0,0},{0,-1},{0,0},{0,1}, },
			south = { {0,0},{0,-1},{0,0},{0,1}, },
			east = { {-1,0},{-1,-1},{0,-1},{0,0}, },
			west = { {1,0},{1,-1},{0,-1},{0,0}, },			
		}
	local head = { 
			north = img.playerType.headNorth,
			south = img.playerType.headSouth,
			east = img.playerType.headEast,
			west = img.playerType.headWest,
		}
	local body = {
			north = img.playerType.bodySouth,
			south = img.playerType.bodySouth,
			east = img.playerType.bodySouth,
			west = img.playerType.bodySouth,
		}
	local feet = {
			north = {{-2, 10, 2, 10},{-2, 12, 2, 8},{-2, 10, 2, 10},{-2, 8, 2, 12}},
			south = {{-2, 10, 2, 10},{-2, 12, 2, 8},{-2, 10, 2, 10},{-2, 8, 2, 12}},
			east = {{-2, 10, 3, 10},{-1, 9, 1, 10},{0, 9, 0, 10},{-2, 10, 3, 10}},
			west = {{-3, 10, 2, 10},{-1, 10, 1, 9},{0, 10, 0, 9},{-3, 10, 2, 10}},
		}
	if actor.footType == 2 then 
		feet = {
			north = {{-3, 10, 3, 10},{-3, 12, 3, 8},{-3, 10, 3, 10},{-3, 8, 3, 12}},
			south = {{-3, 10, 3, 10},{-3, 12, 3, 8},{-3, 10, 3, 10},{-3, 8, 3, 12}},
			east = {{-3, 10, 4, 10},{-2, 9, 2, 10},{-1, 9, 0, 10},{-3, 10, 4, 10}},
			west = {{-4, 10, 3, 10},{-2, 10, 2, 9},{-1, 10, 0, 9},{-4, 10, 3, 10}},
		}
	end
	if (actor.state == 'dodge' or actor.lunge) and not recur then 
		local tx = actor.x 
		local ty = actor.y 
		local tc = actor.color
		local mob = game.actorGetMobility(actor)
		local fade = 125
		if mob == 'fast' then 
			actor.x = actor.lastCoords[4][1]
			actor.y = actor.lastCoords[4][2]
			actor.color = {tc[1] * 0.5, tc[2] * 0.5, tc[3] * 0.5}
			game.drawPlayerType(actor, fade)
			fade = fade + 25
		end
		if mob == 'fast' or mob == 'normal' then 
			actor.x = actor.lastCoords[3][1]
			actor.y = actor.lastCoords[3][2]
			actor.color = {tc[1] * 0.65, tc[2] * 0.65, tc[3] * 0.65}
			game.drawPlayerType(actor, fade)
			fade = fade + 25
		end
		actor.x = actor.lastCoords[2][1]
		actor.y = actor.lastCoords[2][2]
		actor.color = {tc[1] * 0.8, tc[2] * 0.8, tc[3] * 0.8}
		game.drawPlayerType(actor, fade)
		fade = fade + 25
		actor.x = actor.lastCoords[1][1]
		actor.y = actor.lastCoords[1][2]
		actor.color = {tc[1] * 0.9, tc[2] * 0.9, tc[3] * 0.9}
		game.drawPlayerType(actor, fade)
		actor.x = tx 
		actor.y = ty
		actor.color = tc
	end
	if walk == 1 then 
		bob = 0
	elseif walk == 2 then 
		bob = -1 
	elseif welk == 3 then 
		bob = -1 
	else 
		bob = 0 
	end
	--- grappling hook
	if actor == player and player.inGrapple then 
		if math.abs(player.dx) <= 15 and math.abs(player.dy) <= 15 then 
			love.graphics.draw(img.weapon.grapplinghook, player.inGrapple.x, player.inGrapple.y, 0, 1, 1, 16, 16)
		else
			love.graphics.draw(img.weapon.grapplinghookclosed, player.inGrapple.x, player.inGrapple.y, 0, 1, 1, 16, 16)
		end
		love.graphics.setColor(100, 100, 100, 255)
		love.graphics.line(player.inGrapple.x, player.inGrapple.y, player.x + player.weaponAction.x, player.y + player.weaponAction.y)
		love.graphics.setColor(255, 255, 255, 255)
	end
	--- Draw player
	love.graphics.setCanvas(pcanvas)
	love.graphics.clear()
	game.actorSetColor(actor)
	if actor.state == 'dodge' then 
		local mob = game.actorGetMobility(actor)
		local t = { }
		if dir == 'north' or dir == 'south' then 
			if mob == 'normal' then 
				t = {1, 0.8, 0.2, -0.2, -0.8, -0.2, 0.2, 0.8, 1} 
			elseif mob == 'slow' then 
				t = {1, 0.5, 0, -0.5, 0, 0.1, 0.2, 0.6, 1} 
			else 	
				t = {1, 0.9, 0.7, 0.6, 0, -0.4, 0.2, 0.8, 1} 
			end
			sy = t[actor.statePhase + 1]
		elseif dir == 'east' then 
			if mob == 'normal' then 
				ofr = 0 + actor.statePhase / 1.25
			elseif mob == 'slow' then 
				if actor.statePhase < 3 then 
					ofr = 0 + actor.statePhase / 1
				else 
					ofr = (0 + actor.statePhase / 1) - actor.statePhase / 4.5
				end
			else 
				if actor.statePhase < 5 then 
					ofr = 0 + actor.statePhase / 1.8
				else 
					ofr = (0 + actor.statePhase / 1.8) + actor.statePhase / 4
				end
			end
		elseif dir == 'west' then 
			if mob == 'normal' then 
				ofr = 0 - actor.statePhase / 1.25
			elseif mob == 'slow' then 
				if actor.statePhase < 3 then 
					ofr = 0 - actor.statePhase / 1
				else 
					ofr = (0 - actor.statePhase / 1) + actor.statePhase / 4.5
				end
			else 
				if actor.statePhase < 5 then 
					ofr = 0 - actor.statePhase / 1.8
				else 
					ofr = (0 - actor.statePhase / 1.8) - actor.statePhase / 4
				end
			end
		end
		ofr = 0
		sy = 1
		ox = 0
		oy = 0
	elseif actor.dead and not actor.falling then 
		oy = 6
		ox = 6
		ooy = 8
		sy = 1
	end
	local flip = false 
	if actor.weapon and actor.weapon.flipWepDrawOrder then 
		flip = true 
	end
	if (dir == 'north' and not flip and (not actor.dead or actor.falling)) or (dir == 'south' and flip and (not actor.dead or actor.falling)) then 
		if actor.state ~= 'drink' then 
			game.drawWeapon(actor, ox, oy, ofr, false, dir, sway)
			
		else 
			game.drawWeapon(actor, ox, oy, ofr, true, dir, sway)
		end
	end
	if not actor.armorHead then 
		iimg = head[dir]
	else 
		iimg = img.armor[actor.armorHead.name][actor.dir]
	end
	if actor.falling then 
		oy =  oy + actor.sy * 10
	end
	love.graphics.draw(iimg, actor.x + ox, actor.y + oy + actor.headOffY + bob, 0 + ofr, math.min(actor.sx, 1), math.min(actor.sy, sy), 16, 16 - ooy)
	if actor.state == 'dodge' then 
		--oy = -2
	elseif actor.dead and not actor.falling then 
		oy = 8
		ox = 0
		ofr = math.pi * 0.5
	else
		oy = 0
	end
	if not actor.armorChest then 
		iimg = body[dir]
	else 
		iimg = img.armor[actor.armorChest.name][actor.dir]
	end
	if actor.falling then 
		oy = oy + actor.sy * 12
	end
	love.graphics.draw(iimg, actor.x + ox, actor.y + oy + bob, 0 + ofr, math.min(actor.sx, 1), math.min(actor.sy, sy), 16, 16)
	if actor.state == 'dodge' then 
		--oy = -8
	elseif actor.dead and not actor.falling then 
		oy = 0
		ox = -8
	else 
		oy = 0
	end
	if actor.falling then 
		oy = oy + 5 + (1 - actor.sy) * -12
		walk = 1
	end
	if actor.state == 'dodge' then 
		walk = 2
		mdir = actor.dir
	end
	--if actor.state ~= 'dodge' then 
		love.graphics.draw(img.playerType['foot'..actor.footType], actor.x + ox + feet[mdir][walk][1], actor.y + oy + feet[mdir][walk][2], 0 + ofr, math.min(actor.sx, 1), math.min(actor.sy, sy), 16, 16)
		love.graphics.draw(img.playerType['foot'..actor.footType], actor.x + ox + feet[mdir][walk][3], actor.y + oy + feet[mdir][walk][4], 0 + ofr, math.min(actor.sx, 1), math.min(actor.sy, sy), 16, 16)
	--end
	if (dir ~= 'north' and not flip and (not actor.dead or actor.falling)) or ((dir == 'north' or dir == 'east' or dir == 'west') and flip and (not actor.dead or actor.falling)) then 
		if actor.state ~= 'drink' then 
			if actor.falling then 
				ox = ox + (1 - actor.sy) * 5
				oy = oy + (1 - actor.sy) * 5
			end
			game.drawWeapon(actor, ox, oy, ofr, false, dir, sway)
			if actor.falling then 
				ox = ox - (1 - actor.sy) * 8
				oy = oy + (1 - actor.sy) * 2
			end
			game.drawOffhand(actor, ox, oy, ofr, dir, sway)
		else 
			game.drawWeapon(actor, ox, oy, ofr, true, dir, sway)
		end
	end
	if recur then 
		love.graphics.setColor(255, 255, 255, recur)
	end
	love.graphics.setShader()
	love.graphics.setCanvas(tcan)
	camera:detach()
	love.graphics.draw(pcanvas, 0, 0)
	camera:attach()
	love.graphics.setColor(255, 255, 255, 255)
	--- health and stamina bar
	if actor ~= player and not actor.dead and actor.healthCur < actor.healthMax and not actor.boss then 
		love.graphics.setColor(100, 100, 100, 255)
		love.graphics.rectangle('fill', actor.x - 12, actor.y - 23, 24, 1)
		love.graphics.rectangle('fill', actor.x - 10, actor.y - 20, 20, 1)
		love.graphics.setColor(200, 0, 0, 255)
		love.graphics.rectangle('fill', actor.x - 12, actor.y - 23, 24 * (actor.healthCur / actor.healthMax), 1)
		love.graphics.setColor(0, 200, 0, 255)
		love.graphics.rectangle('fill', actor.x - 10, actor.y - 20, 20 * (actor.staminaCur / actor.staminaMax), 1)
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function game.actorSetColor(actor)
	--- Set color
	if actor.hurt <= 0 and (not actor.dead or actor.falling) then 
		local r = actor.color[1] 
		local g = actor.color[2] 
		local b = actor.color[3]
		if actor.player and not actor.darkMatterIntake then 
			r = r * 0.75 
			g = g * 0.75
			b = b * 0.75
		end
		replaceColor:send('r', r / 255)
		replaceColor:send('g', g / 255)
		replaceColor:send('b', b / 255)
	elseif actor.dead and not actor.falling then 
		replaceColor:send('r', 0.4)
		replaceColor:send('g', 0)
		replaceColor:send('b', 0)
	else
		replaceColor:send('r', 1)
		replaceColor:send('g', 1)
		replaceColor:send('b', 1)
	end
	if actor.darkMatterIntake and actor.hurt < 0 then 
		actorMatterIntake:send('x', actor.intakeColorTimer)
		love.graphics.setShader(actorMatterIntake)
	else
		if actor.dead then 
			love.graphics.setShader(replaceColor)
		elseif actor.hurt > 0 then 
			replaceColor:send('r', 1)
			replaceColor:send('g', 1)
			replaceColor:send('b', 1)
			love.graphics.setShader(replaceColor)
		else
			actorColor:send('x', actor.intakeColorTimer)
			actorColor:send('r', actor.color[1] / 255)
			actorColor:send('g', actor.color[2] / 255)
			actorColor:send('b', actor.color[3] / 255)
			love.graphics.setShader(actorColor)
		end
	end
	if actor == game.getActorClosestToCursor() then 
		actorClosest = true
		actorColor:send('x', actor.intakeColorTimer)
		actorColor:send('r', actor.color[1] * 1.5 / 255)
		actorColor:send('g', actor.color[2] * 1.5 / 255)
		actorColor:send('b', actor.color[3] * 1.5 / 255)
		love.graphics.setShader(actorColor)
	end
end

function game.addActor(actor)
	table.insert(actors, actor)
	world:add(actor, actor.x - actor.hitBoxWidth / 2, actor.y - actor.hitBoxHeight / 2, actor.hitBoxWidth, actor.hitBoxHeight)
end

function game.newActor(stats)
	local a = {
		name = stats.name or 'Testing',
		dname = stats.dname or 'Null',
		type = 'actor',
		team = stats.team or 1,
		x = stats.x or 0, 
		y = stats.y or 0, 
		ox = stats.ox or 16, 
		oy = stats.oy or 16, 
		dx = stats.dx or 0,
		dy = stats.dy or 0,
		sx = stats.sx or 1,
		sy = stats.sy or 1,
		hitBoxWidth = stats.hitBoxWidth or 8,
		hitBoxHeight = stats.hitBoxHeight or 20,
		acceleration = stats.acceleration or 700,
		deceleration = stats.deceleration or 550,
		maxSpeed = stats.maxSpeed or 70,
		playerType = stats.playerType or false, 
		player = stats.player or false, 
		dir = stats.dir or 'south',
		moveDir = stats.dir or 'south',
		weapon = stats.weapon or false,
		offhand = stats.offhand or false,
		weaponAction = stats.weaponAction or {x = 0, y = 0, rot = 0},
		offhandAction = stats.offhandAction or {x = 0, y = 0, rot = 0},
		walkAnim = stats.walkAnim or 1,
		state = stats.state or 'idle',
		stateTimer = stats.stateTimer or 0,
		statePhase = stats.statePhase or 0,
		stateCombo = stats.stateCombo or 0,
		invul = stats.invul or 0,
		block = stats.block or 0,
		color = stats.color or {50, 100, 255},
		hurt = stats.hurt or 0,
		healthCur = stats.healthCur or 20,
		healthMax = stats.healthMax or 100,
		staminaCur = stats.staminaCur or 10,
		staminaMax = stats.staminaMax or 100,
		staminaGainCD = stats.staminaGainCD or 0,
		lockCoords = stats.lockCoords or {0, 0},
		wepScale = stats.wepScale or 1,
		slow = stats.slow or 0,
		ai = stats.ai or 'simple',
		armorChest = stats.armorChest or false,
		armorHead = stats.armorHead or false,
		healsCur = stats.healsCur or 5,
		healsMax = stats.healsMax or 5,
		cryopod = stats.cryopod or 0,
		walkPart = stats.walkPart or 0,
		vitality = stats.vitality or 10,
		endurance = stats.endurance or 10,
		stability = stats.stability or 10,
		strength = stats.strength or 10,
		dexterity = stats.dexterity or 10,
		intelligence = stats.intelligence or 10,
		soulpower = stats.soulpower or 10,
		wisdom = stats.wisdom or 10,
		class = stats.class or 'Star Knight',
		level = stats.level or 10,
		slashdef = stats.slashdef or 0,
		thrustdef = stats.thrustdef or 0,
		crushdef = stats.crushdef or 0,
		magicdef = stats.magicdef or 0,
		firedef = stats.firedef or 0,
		solardef = stats.solardef or 0,
		balance = stats.balance or 0,
		matter = stats.matter or 100,
		balanceCur = 1000,
		leash = stats.leash or 200,
		noticed = stats.noticed or false,
		sprint = stats.sprint or 0,
		falling = stats.falling or false,
		infall = stats.infall or 0,
		intfall = stats.intfall or false,
		backstab = stats.backstab or false,
		turnCD = stats.turnCD or 0,
		turnCDSet = stats.turnCDSet or 0.15,
		darkMatter = stats.darkMatter or 0,
		darkMatterIntake = stats.darkMatterIntake or false,
		rings = stats.rings or {false, false, false},
		intakeColorTimer = stats.intakeColorTimer or 0,
		lastCoords = {{0,0},{0,0},{0,0}},
		headOffY = stats.headOffY or 0,
		disableBackstab = stats.disableBackstab or false,
		boss = stats.boss or false,
		footType = stats.footType or 1,
		attunementSlots = stats.attunementSlots or 0,
		attunement = stats.attunement or {},
		attuneSlotFocus = stats.attuneSlotFocus or 1,
		weightCur = stats.weightCur or 0;
		dropList = stats.dropList or false,
		permDead = stats.permDead or false,
		handOY = stats.handOY or 0,
		update = stats.update or false, 
		draw = stats.draw or false, 
		onCreate = stats.onCreate or false,
		setAttackCD = stats.setAttackCD or 0,
		attackCD = 0,
		bloodType = stats.bloodType or 'animal',
		gibAmount = stats.gibAmount or {4,1,2},
		flying = stats.flying or false,
		curSpell = stats.curSpell or false,
	}
	a.healthCur = game.actorGetHealthMax(a)
	if a.attunement then 
		for k,v in pairs(a.attunement) do 
			if v.spellName then 
				v.spell = spells[v.spellName]
			end
		end
	end
	if a.onCreate then 
		a = a.onCreate(a, game)
	end
	return a
end

function game.updatePlayerTypeStats(actor, dt)
	actor.healthMax = game.actorGetHealthMax(actor)
	actor.staminaMax = game.actorGetStaminaMax(actor)
	if actor.healthCur > actor.healthMax then 
		actor.healthCur = actor.healthMax 
	end 
	if actor.staminaCur > actor.staminaMax then 
		actor.staminaCur = actor.staminaMax 
	end
end

function game.actorGetStaminaMax(actor)
	return 80 + game.actorGetEndurance(actor) * 2
end

function game.actorGetHealthMax(actor)
	--local h = 100 + game.actorGetVitality(actor) * 10
	local h = 10 * math.log(game.actorGetVitality(actor), 1.1)
	if actor.darkMatterIntake then 
		h = h * 1.3
	end
	for i = 1, 3 do 
		if actor.rings[i] and actor.rings[i].effects.healthMax then 
			h = h + actor.rings[i].effects.healthMax.effect
		end
	end
	return math.max(1, math.ceil(h))
end

function game.actorGetVitality(actor)
	return actor.vitality 
end

function game.actorGetEndurance(actor)
	return actor.endurance 
end

function game.actorGetStability(actor)
	return actor.stability
end

function game.actorGetStrength(actor)
	return actor.strength 
end

function game.actorGetDexterity(actor)
	return actor.dexterity 
end

function game.actorGetIntelligence(actor)
	return actor.intelligence 
end

function game.actorGetSoulpower(actor)
	return actor.soulpower 
end

function game.actorGetWisdom(actor)
	return actor.wisdom 
end

function game.actorGetAttunementSlots(actor)
	local wis = game.actorGetWisdom(actor)
	local att = 0
	if wis >= 5 then att = att + 1 end
	if wis >= 7 then att = att + 1 end 
	if wis >= 10 then att = att + 1 end 
	if wis >= 14 then att = att + 1 end 
	if wis >= 19 then att = att + 1 end 
	if wis >= 25 then att = att + 1 end 
	if wis >= 32 then att = att + 1 end 
	if wis >= 40 then att = att + 1 end 
	if wis >= 45 then att = att + 1 end 
	if wis >= 50 then att = att + 1 end 
	return att
end

function game.actorMatterNeeded(actor)
	return 500 + (75 * (actor.level * 2))
end

function game.actorGetBalance(actor)
	local b = 0
	if actor.armorChest then 
		b = b + actor.armorChest.balance 
	end 
	if actor.armorHead then 
		b = b + actor.armorHead.balance 
	end
	return b
end

function game.actorGetDefense(actor)
	local d = {
		slash = actor.slashdef,
		thrust = actor.thrustdef,
		crush = actor.crushdef,
		magic = actor.magicdef,
		fire = actor.firedef,
		solar = actor.solardef,
	}
	if actor.armorChest then 
		for k,v in pairs(actor.armorChest.defense) do
			d[k] = d[k] + v
		end
	end
	if actor.armorHead then 
		for k,v in pairs(actor.armorHead.defense) do
			d[k] = d[k] + v 
		end
	end
	return d
end

function game.actorGetNonEquippedWeaponDamage(actor, item)
	local bdam = 0
	local sdam = 0
	bdam = item.baseDamage 
	sdam = sdam + game.actorGetStrength(actor) * item.scaling.strength
	sdam = sdam + game.actorGetDexterity(actor) * item.scaling.dexterity
	sdam = sdam + game.actorGetIntelligence(actor) * item.scaling.intelligence
	sdam = sdam + game.actorGetSoulpower(actor) * item.scaling.soulpower
	for i = 1, 3 do
		if actor.rings[i] and actor.rings[i].effects.thrustDam and item.dtype == 'thrust' then 
			bdam = bdam + actor.rings[i].effects.thrustDam.effect
		end
	end
	return bdam, sdam
end

function game.actorGetWeaponDamage(actor)
	local dam = 0
	if actor.weapon then 
		dam = dam + actor.weapon.baseDamage 
		dam = dam + game.actorGetStrength(actor) * actor.weapon.scaling.strength
		dam = dam + game.actorGetDexterity(actor) * actor.weapon.scaling.dexterity
		dam = dam + game.actorGetIntelligence(actor) * actor.weapon.scaling.intelligence
		dam = dam + game.actorGetSoulpower(actor) * actor.weapon.scaling.soulpower
		for i = 1, 3 do
			if actor.rings[i] and actor.rings[i].effects.thrustDam and actor.weapon.dtype == 'thrust' then 
				dam = dam + actor.rings[i].effects.thrustDam.effect
			end
		end
	end
	return math.floor(dam)
end

function game.actorGetOffhandDamage(actor)
	local dam = 0
	if actor.offhand then 
		dam = dam + actor.offhand.baseDamage 
		dam = dam + game.actorGetStrength(actor) * actor.offhand.scaling.strength
		dam = dam + game.actorGetDexterity(actor) * actor.offhand.scaling.dexterity
		dam = dam + game.actorGetIntelligence(actor) * actor.offhand.scaling.intelligence
		dam = dam + game.actorGetSoulpower(actor) * actor.offhand.scaling.soulpower
		for i = 1, 3 do
			if actor.rings[i] and actor.rings[i].effects.thrustDam and actor.offhand.dtype == 'thrust' then 
				dam = dam + actor.rings[i].effects.thrustDam.effect
			end
		end
	end
	return math.floor(dam)
end

function game.actorGetWeightMax(actor)
	local w = 30 + game.actorGetStability(actor)
	for i = 1, 3 do 
		if actor.rings[i] and actor.rings[i].effects.weightMax then 
			w = w + actor.rings[i].effects.weightMax.effect 
		end
	end
	return w
end

function game.actorGetWeightCur(actor)
	return actor.weightCur
end

function game.actorGetMobility(actor)
	return actor.mobility 
end

function game.actorGetScaleGrade(scale)
	if scale <= 0 then 
		return '-'
	elseif scale <= 0.5 then 
		return 'E'
	elseif scale <= 0.75 then 
		return 'D'
	elseif scale <= 1 then 
		return 'C'
	elseif scale <= 1.25 then 
		return 'B'
	elseif scale <= 1.5 then 
		return 'A'
	else 
		return 'S'
	end
end

function game.getActorClosestToCursor()
	local t = actors[1]
	local d = 0
	local mx, my = love.mouse.getPosition()
	mx, my = camera:worldCoords(mx, my)
	d = math.sqrt((t.x - mx)^2 + (t.y - my)^2)
	if # actors > 1 then 
		for i = 1, # actors do 
			if not actors[i].player and not actors[i].dead and math.sqrt((actors[i].x - mx)^2 + (actors[i].y - my)^2) <= d and math.sqrt((actors[i].x - mx)^2 + (actors[i].y - my)^2) <= 100 then 
				t = actors[i] 
				d = math.sqrt((actors[i].x - mx)^2 + (actors[i].y - my)^2)
			end
		end
	end
	if t == player then 
		t = false
	end
	return t	
end

---
--- Decals
---
function game.drawDecals()
	local x, y = 0, 0
	for i = 1, # decals do 
		x, y = camera:cameraCoords(decals[i].x, decals[i].y)
		if x > -32 and y > -32 and x < love.graphics.getWidth() - 32 and y < love.graphics.getHeight() - 32 then 
			love.graphics.draw(img.decal[decals[i].decal], decals[i].x, decals[i].y, decals[i].rot, 1, 1, 16, 16)
		end
	end
end

function game.addDecal(decal, x, y, rot)
	table.insert(decals, {decal = decal, x = x, y = y, rot = rot})
end

---
--- Projectiles
---
function game.updateProjectiles(dt)
	for i = # projectiles, 1, -1 do 
		local p = projectiles[i]
		local hit = false
		local items, lens = world:querySegment(p.x - 10, p.y - 10, p.x + 10, p.y + 10)
		p.nohit = p.nohit - dt
		if p.update then 
			p = p.update(p, dt, {actors = actors, game = game, img = img, camera = camera})
		end
		if p.dtrot then 
			p.drot = p.drot + p.dtrot * dt
		end
		if p.tracking then 
			if not p.checkForTargetCD then 
				p.checkForTargetCD = 0
			end
			p.checkForTargetCD = p.checkForTargetCD - dt
			if not p.target and p.checkForTargetCD <= 0 then 
				if p.team == 1 then 
					p.target = game.getActorClosestToCursor()
					p.checkForTargetCD = 0.15
				else
					p.target = player 
					p.checkForTargetCD = 0.15
				end
			elseif p.target then
				local ang = math.atan2(p.target.y - p.y, p.target.x - p.x)
				local dang = math.pi / 4
				local tang = p.rot - ang 
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
				p.rot = p.rot + dang / 2 * dt
				p.drot = p.rot
			end
		end
		if lens > 0 then 
			for j = 1, # items do 
				if items[j].type == 'actor' and items[j].team ~= p.team and items[j].invul <= 0 then 
					game.actorTakeDamage(items[j], p.dam, p.dtype, p.x, p.y, p.stun, p.bdam, p.knockback)
					table.remove(projectiles, i)
					hit = true
				elseif items[j].type == 'blockall' and p.nohit <= 0 then 
					table.remove(projectiles, i)
					hit = true
				end
			end
		end
		if not hit and p.DESTROY then 
			table.remove(projectiles, i)
			hit = true
		end
		if not hit then 
			game.emitParticlesAt(p.flight or 'flight', p.x, p.y, 1)
			p.x = p.x + p.speed * math.cos(p.rot) * dt 
			p.y = p.y + p.speed * math.sin(p.rot) * dt
		else
			local color = {
				flight = {0.09,0.09,0.09},
				magicflight = {0.15,0.1,0.02},
				magicflight2 = {0.12,0.8,0.02},
				fireflight = {0.05,0.15,0.15},
				lightflight = {0.15, 0.06, 0.06},
			}
			if p.decal then 
				game.addDecal(p.decal, p.x + p.speed * math.cos(p.rot) * dt , p.y + p.speed * math.sin(p.rot) * dt, p.rot)
			end
			table.insert(residualLights, {x = p.x, y = p.y, color = color[p.flight or 'flight'], light = 20, change = 1400})
			if p.onDestroy then 
				p.onDestroy(p, dt, {actors = actors, game = game, img = img, camera = camera})
			end
			for x = p.x + p.speed * math.cos(p.rot) * dt - 6, p.x + p.speed * math.cos(p.rot) * dt + 6, 2 do 
				for y = p.y + p.speed * math.sin(p.rot) * dt - 6, p.y + p.speed * math.sin(p.rot) * dt + 6, 2 do
					game.emitParticlesAt(p.flight or 'flight', x, y, 1)
				end
			end
		end
	end
end

function game.drawProjectiles()
	local x, y = 0, 0
	for i = 1, # projectiles do 
		x, y = camera:cameraCoords(projectiles[i].x, projectiles[i].y)
		if x > -32 and y > -32 and x < love.graphics.getWidth() - 32 and y < love.graphics.getHeight() - 32 then 
			love.graphics.draw(projectiles[i].img, projectiles[i].x, projectiles[i].y, projectiles[i].drot or projectiles[i].rot, 1, 1, 16, 16)
		end
	end
end

function game.addProjectile(proj)
	table.insert(projectiles, proj)
end

---
--- Hurtbox
---
function game.updateHurtbox(dt)
	for i = # hurtbox, 1, -1 do
		local items, lens = world:queryRect(hurtbox[i].x, hurtbox[i].y, hurtbox[i].w, hurtbox[i].h)
		if lens > 0 then 
			for j = 1, # items do 
				if items[j].type == 'actor' and items[j].team ~= hurtbox[i].team then 
					game.actorTakeDamage(items[j], hurtbox[i].dam, hurtbox[i].dtype, hurtbox[i].sx, hurtbox[i].sy, hurtbox[i].stun, hurtbox[i].bdam, hurtbox[i].shieldBreaker)
				end
			end
		end
		hurtbox[i].dur = hurtbox[i].dur - dt 
		if hurtbox[i].dur <= 0 then 
			table.remove(hurtbox, i)
		end
	end
end

function game.drawHurtbox()
	for i = 1, # hurtbox do 
		love.graphics.setColor(175, 0, 0, 255)
		love.graphics.rectangle('line', hurtbox[i].x, hurtbox[i].y, hurtbox[i].w, hurtbox[i].h)
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function game.addHurtbox(team, x, y, w, h, dur, dam, dtype, sx, sy, stun, bdam, shieldBreaker)
	table.insert(hurtbox, {team = team, x = x, y = y, w = w, h = h, dur = dur, dam = dam, dtype = dtype, sx = sx, sy = sy, stun = stun, bdam = bdam, shieldBreaker = shieldBreaker})
end

---
--- Particles
---
function game.updateParticles(dt)
	for k,v in pairs(particles) do 
		v:update(dt)
	end
end

function game.drawParticlesUnder()
	love.graphics.draw(particles.smoke, 0, 0)
	love.graphics.draw(particles.dodge, 0, 0)
	love.graphics.draw(particles.waterstep, 0, 0)
	love.graphics.draw(particles.matterdropped3, 0, 0)
	love.graphics.draw(particles.matterdropped4, 0, 0)
end

function game.drawParticles()
	for k,v in pairs(particles) do 
		if k ~= 'smoke' and k ~= 'cryoheal' and k ~= 'dodge' and k ~= 'waterstep' and k ~= 'matterdropped3' and k~= 'matterdropped4' then 
			love.graphics.draw(v, 0, 0)
		end
	end
end

function game.drawHudParticles()
	love.graphics.draw(particles.cryoheal, 0, 0)
end

function game.emitParticlesAt(part, x, y, amnt)
	particles[part]:start()
	particles[part]:moveTo(x, y)
	particles[part]:emit(amnt)
	particles[part]:stop()
end

---
--- Animations
---
function game.updateAnimations(dt)
	for i = # anims, 1, -1 do
		anims[i].animation:update(dt)
		if anims[i].prop.contRot then 
			anims[i].rot = anims[i].rot + anims[i].prop.contRot 
		end
		if anims[i].animation:isLastFrame() and not anims[i].loop then 
			table.remove(anims, i)
		end
	end
end

function game.drawAnimations()
	for i = # anims, 1, -1 do
		if not anims[i].prop.bg then 
			anims[i].animation:draw(img.animation[anims[i].anim], anims[i].x, anims[i].y, anims[i].rot, anims[i].sx, anims[i].sy, 24, 24)
		else
			anims[i].animation:draw(img.animation[anims[i].anim], camera.x * 0.1 + anims[i].x * 0.95, camera.y * 0.1 + anims[i].y * 0.95, anims[i].rot, anims[i].sx, anims[i].sy, 32, 32)
		end
	end
end

function game.addAnimation(anim, x, y, rot, sx, sy, loop, prop)
	table.insert(anims, {anim = anim, animation = animations[anim]:clone(), x = x, y = y, rot = rot, sx = sx, sy = sy, loop = loop, prop = prop or {}})
end

---
--- Map
---
function game.batchMapTiles()
	map:setSpriteBatches(map.layers.floor1)
	map:setSpriteBatches(map.layers.floor2)
	map:setSpriteBatches(map.layers.floor3)
	map:setSpriteBatches(map.layers.wall1)
	map:setSpriteBatches(map.layers.wall2)
	map:setSpriteBatches(map.layers.wall3)
	map:setSpriteBatches(map.layers.ceiling1)
	map:setSpriteBatches(map.layers.ceiling2)
	map:setSpriteBatches(map.layers.ceiling3)
	if map.layers.wall4 then 
		map:setSpriteBatches(map.layers.wall4)
	end
	if map.layers.ceiling4 then 
		map:setSpriteBatches(map.layers.ceiling4)
	end
end

function game.batchMapCanvas()
	game.batchMapTiles()
	if not mapCanvasUnder then 
		mapCanvasUnder = love.graphics.newCanvas(10000, 10000)
	end
	if not mapCanvasOver then 
		mapCanvasOver = love.graphics.newCanvas(10000, 10000)
	end
	love.graphics.setCanvas(mapCanvasUnder)
	love.graphics.clear()
	game.drawMapFloor()
	game.drawMapWall()
	love.graphics.setCanvas(mapCanvasOver)
	love.graphics.clear()
	game.drawMapCeiling()
	love.graphics.setCanvas()
end

function game.drawMapFloor()
	map:drawLayer(map.layers['floor1'])
	map:drawLayer(map.layers['floor2'])
	map:drawLayer(map.layers['floor3'])
end

function game.drawBackground()
	--love.graphics.setShader(twinkleStar)
	twinkleStar:send('modulo', math.floor(love.timer.getDelta() * (100 * love.math.random(1,5))))
	for k,v in pairs(map.objects) do
		if v.layer.name == 'bg' then 
			local x = v.x
			local y = v.y 
			x, y = camera:cameraCoords(x, y)
			love.graphics.setScissor(x, y, v.width * camera.scale, v.height * camera.scale)
			love.graphics.draw(img.bg.space1, camera.x * 0.15, camera.y * 0.15)
			love.graphics.draw(img.bg.space2, camera.x * 0.12, camera.y * 0.12)
			love.graphics.draw(img.bg.space3, camera.x * 0.1, camera.y * 0.1)
			love.graphics.setScissor()
		end
	end
	love.graphics.setShader()
end

function game.drawMapWall()
	map:drawLayer(map.layers['wall1'])
	map:drawLayer(map.layers['wall2'])
	map:drawLayer(map.layers['wall3'])
	if map.layers['wall4'] then 
		map:drawLayer(map.layers['wall4'])
	end
end

function game.drawMapCeiling()
	map:drawLayer(map.layers['ceiling1'])
	map:drawLayer(map.layers['ceiling2'])
	map:drawLayer(map.layers['ceiling3'])
	if map.layers.ceiling4 then 
		map:drawLayer(map.layers['ceiling4'])
	end
end

function game.drawMapCeilingDynamic()
	--- cryo
	if player.cryopod > 0 then 
		local x = player.x - 15
		local y = 0
		for k,v in pairs(map.objects) do
			if v.layer.name == 'cryopod' then 
				y = v.y + v.height / 2 - 10
			end
		end
		x, y = camera:cameraCoords(x, y)
		love.graphics.setColor(255, 255, 255, 200)
		love.graphics.setScissor(x, y, 80, player.cryopod)
		map:drawLayer(map.layers['cryopoddoor'])
		love.graphics.setScissor()
		love.graphics.setColor(255, 255, 255, 255)
	end
	--- drop ceiling
	for i = 1, 3 do 
		if map.layers['dropceil'..i] then 
			love.graphics.setColor(255,255,255,mapDropFade)
			map:drawLayer(map.layers['dropceil'..i])
		else
			break
		end
	end
	love.graphics.setColor(255,255,255,255)
end

function game.updateMatterDrop(dt)
	if matterDrop and matterDrop.world == curMap then 
		if matterDrop.spawnCd > 0 then 
			return 
		end
		animations.matterDrop:update(dt)
		if not matterDrop.dt then 
			matterDrop.dt = 0
		end
		matterDrop.dt = matterDrop.dt - dt 
		if matterDrop.dt <= 0 then 
			game.emitParticlesAt('matterdropped2', matterDrop.x, matterDrop.y + 7, 1)
			matterDrop.dt = 1
		end
		if love.math.random(1, 100) <= 25 then 
			game.emitParticlesAt('matterdropped', matterDrop.x, matterDrop.y, 1)
		end
		if math.sqrt((player.x - matterDrop.x)^2 + (player.y - matterDrop.y)^2) <= 14 then 
			player.matter = player.matter + matterDrop.amount
			player.darkMatter = player.darkMatter + matterDrop.dark
			game.emitParticlesAt('matterdropped', matterDrop.x, matterDrop.y, 100)
			game.addBigText({text = 'Matter Restored', fade = 0, dt = 7, df = 1.25, oy = -256, color = {99, 155, 255}})
			matterDrop = false
		end
	end
end

function game.drawMatterDrop()
	if matterDrop and matterDrop.world == curMap and matterDrop.spawnCd < 0 then 
		animations.matterDrop:draw(img.animation.matterDrop, matterDrop.x, matterDrop.y, 0, 1, 1, 16, 16)
		--love.graphics.draw(img.map.matterDrop, matterDrop.x, matterDrop.y, 0, 1, 1, 16, 16)
	end
end

---
--- Lighting
---
function game.updateResidualLights(dt)
	for i = # residualLights, 1, -1 do
		if not residualLights[i].dt then 
			residualLights[i].dt = dt 
		else
			residualLights[i].dt = residualLights[i].dt + dt 
		end
		residualLights[i].light = residualLights[i].light + ((residualLights[i].change or 1400) * math.min(1, residualLights[i].dt)) * dt 
		if residualLights[i].light > 250 or residualLights[i].dt > 0.25 then 
			table.remove(residualLights, i)
		end
	end
end

function game.lightLevelMap()
	local t = { }
	local p = { }
	local dt = { }
	local img = true
	local x = 0
	local y = 0
	local num = 0
	local start = 0 
	local count = 0
	if not foundStaticMapLights then 
		start = 1
	else 
		start = staticMapLights
	end
	for k,v in pairs(map.objects) do
		if v.layer.name == 'light' then 
			count = count + 1
			table.insert(dt, {x = v.x, y = v.y, light = v.properties.lightlevel - 2, color = {v.properties.red, v.properties.green, v.properties.blue}})
		end
		staticMapLights = count
	end
	if matterDrop and matterDrop.world == curMap and matterDrop.spawnCd < 0 then 
		table.insert(dt, {x = matterDrop.x, y = matterDrop.y, light = 20, color = {0.45, 1, 0}})
	end
	for i = 1, # actors do 
		local clr = {1.08 - actors[i].color[1] / 255, 1.07 - actors[i].color[2] / 255, 1.15 - actors[i].color[3] / 255}
		if not actors[i].dead then 
			if actors[i].darkMatterIntake then 
				clr = {0.2, 0.09, 0.12}
			end
			table.insert(dt, {x = actors[i].x, y = actors[i].y, light = 12, color = clr})
		end
	end
	for i = 1, # projectiles do
		local color = {
			flight = {0.09,0.09,0.09},
			magicflight = {0.15,0.1,0.02},
			magicflight2 = {0.12,0.8,0.02},
			fireflight = {0.05,0.15,0.15},
			lightflight = {0.15, 0.06, 0.06},
		}
		table.insert(dt, {x = projectiles[i].x, y = projectiles[i].y, light = 25, color = color[projectiles[i].flight or 'flight']})
	end
	for i = 1, # matterShards do 
		table.insert(dt, {x = matterShards[i].x, y = matterShards[i].y, light = 45, color = {1 - matterShards[i].color[1] / 255, 1 - matterShards[i].color[2] / 255, 1 - matterShards[i].color[3] / 255}})
	end
	for i = 1, # mapItems do 
		table.insert(dt, {x = mapItems[i].x, y = mapItems[i].y, light = 50, color = {0.25, 0.25, 0.25}})
	end
	for i = 1, # residualLights do 
		table.insert(dt, residualLights[i])
	end
	for i = # dt, 1, -1 do
		if math.sqrt((dt[i].x - player.x)^2 + (dt[i].y - player.y)^2) < 2000 then
			x = dt[i].x 
			y = dt[i].y 
			x, y = camera:cameraCoords(x, y)
			x = math.floor(((x + 300) / (love.graphics.getWidth() + 600)) * 255)
			y = math.floor(((y + 300) / (love.graphics.getHeight() + 600)) * 255)
			if y > 255 then y = 255 elseif y < 1 then y = 1 end
			if x > 255 then x = 255 elseif x < 1 then x = 1 end
			table.insert(p, {x = x, y = y, light = dt[i].light, color = dt[i].color})
		end
	end
	for i = start, # p do
		lightIMG:setPixel(i - 1, 0, p[i].x, p[i].y, p[i].light, 255)
		lightIMG:setPixel(i - 1, 1, p[i].color[1] * 255, p[i].color[2] * 255, p[i].color[3] * 255, 255)
	end
	if not lightFogIMG then 
		lightFogIMG = love.graphics.newImage(lightIMG)
	end
	lightFogIMG:refresh()
	lightMapWidth = # p
	return lightFogIMG, lightMapWidth
end

function game.updateLightPower(dt)
	--- lightpower
	lightpowcd = lightpowcd - dt
	if lightpowcd <= 0 then
		lightpow = lightpow + lightpowdt
		lightpowcd = 0.15
		if lightpow < avglightpow - 10 then
			lightpowdt = 1 
		elseif lightpow > avglightpow + 10 then
			lightpowdt = -1 
		end
	end
end

function game.drawLight()
	--- apply fog to canvas
	local iimg, width = game.lightLevelMap()
	love.graphics.setShader(fog)
	fog:send('map', iimg)
	fog:send('w', width)
	fog:send('screenwidth', love.graphics.getWidth() + 600)
	fog:send('screenheight', love.graphics.getHeight() + 600)
	fog:send('lightpow', lightpow)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(canvas, 0, 0)
	love.graphics.setBlendMode("alpha")
	love.graphics.setShader()
	return iimg, width
end

---
--- Camera
---
function game.screenShake(amnt)
	screenShakeVal = math.min(300, screenShakeVal + amnt^2)
end

function game.updateCamera(dt)
	local mx, my = love.mouse.getPosition()
	local xval = 1
	local yval = 1
	if love.math.random(1, 2) == 2 then 
		xval = -1
	end
	if love.math.random(1, 2) == 2 then 
		yval = -1
	end
	screenShakeVal = math.max(0, screenShakeVal - 1000 * dt)
	if player.cryopod > 0 then 
		mx = love.graphics.getWidth() / 2
		my = love.graphics.getHeight() / 2
	end
	mx, my = camera:worldCoords(mx, my)
	camera:move(math.floor(screenShakeVal * xval / 100), math.floor(screenShakeVal * yval / 100))
	camera:rotateTo(0 + screenShakeVal * xval / 10000)
	if menu or # itemPickupPrompt > 0 then 
		camera:lockPosition(math.floor(player.x), math.floor(player.y), camera.smooth.damped(8))
	elseif player.dead then 
		camera:lockPosition(math.floor(player.x), math.floor(player.y - 6), camera.smooth.damped(8))
	else
		camera:lockWindow(	math.ceil(player.x - (player.x - mx) / 10),
						math.ceil(player.y - (player.y - my) / 10), 
						math.ceil(love.graphics.getWidth() / 2),
						math.ceil(love.graphics.getWidth() / 2), 
						math.ceil(love.graphics.getHeight() / 2), 
						math.ceil(love.graphics.getHeight() / 2), 
						camera.smooth.damped(8))
	end
	local minx = 1 + love.graphics.getWidth() / 2
	local maxx = map.width * 32 * 4 - love.graphics.getWidth() / 2
	local miny = 1 + love.graphics.getHeight() / 2
	local maxy = map.height * 32 * 4 - love.graphics.getHeight() / 2
	if camera.x < minx / 4 then 
		camera.x = math.floor(minx / 4)
	end
	if camera.x > maxx / 4 then 
		camera.x = math.floor(maxx / 4)
	end
	if camera.y < miny / 4 then 
		camera.y = math.floor(miny / 4)
	end 
	if camera.y > maxy / 4 then 
		camera.y = math.floor(maxy / 4)
	end
end

function game.snapCamera()
	camera:lookAt(player.x, player.y)
end

--- 
--- Map Items
---
function game.updateMapItems(dt)
	game.updatePickupPrompt(dt)
	for i = # mapItems, 1, -1 do 
		local d = math.sqrt((mapItems[i].x - player.x)^2 + (mapItems[i].y - player.y)^2)
		local cx, cy = camera:cameraCoords(mapItems[i].x, mapItems[i].y)
		if cx > -16 and cy > -16 and cx < love.graphics.getWidth() + 16 and cy < love.graphics.getHeight() + 16 then 
			mapItems[i].partCD = mapItems[i].partCD - dt 
			mapItems[i].part2CD = mapItems[i].part2CD - dt 
			if mapItems[i].partCD <= 0 then 
				game.emitParticlesAt('matterdropped4', mapItems[i].x, mapItems[i].y, 1)
				mapItems[i].partCD = 0.05
			elseif mapItems[i].part2CD <= 0 then 
				game.emitParticlesAt('matterdropped3', mapItems[i].x, mapItems[i].y, 1)
				mapItems[i].part2CD = 0.75
			end
			if d <= 16 and love.keyboard.isDown('r') then 
				if not mapItemsFound[curMap] then 
					mapItemsFound[curMap] = { }
				end
				mapItemsFound[curMap][mapItems[i].name] = true
				if mapItems[i].item.onPickup then 
					mapItems[i], player = mapItems[i].item.onPickup(mapItems[i], player)
				end
				game.addItemToInventory(mapItems[i])
				table.remove(mapItems, i)
			end
		end
	end
end

function game.addItemToInventory(item)
	if item.stackable then 
		local stacked = false
		for i = 1, # inventory do
			if inventory[i].item == item.item then 
				inventory[i].stack = inventory[i].stack + 1
				stacked = true
				table.insert(itemPickupPrompt, {item = item, style = item.item.style or 2, drawn = false, dfade = 1, dt = 0})
				break
			end
		end
		if not stacked then 
			table.insert(inventory, item)
			table.insert(itemPickupPrompt, {item = item, style = item.item.style or 2, drawn = false, dfade = 1, dt = 0})
		end
	else
		table.insert(inventory, item)
		table.insert(itemPickupPrompt, {item = item, style = item.item.style, drawn = false, dfade = 1, dt = 0})
	end
end

function game.drawMapItems()
	for i = 1, # mapItems do 
		local d = math.sqrt((mapItems[i].x - player.x)^2 + (mapItems[i].y - player.y)^2)
		local cx, cy = camera:cameraCoords(mapItems[i].x, mapItems[i].y)
		if cx > -16 and cy > -16 and cx < love.graphics.getWidth() + 16 and cy < love.graphics.getHeight() + 16 then 
			love.graphics.draw(img.part.mapitem, mapItems[i].x, mapItems[i].y, 0, 1, 1, 8, 8)
			if d <= 16 then 
				love.graphics.draw(img.hud.pickup, mapItems[i].x, mapItems[i].y - 24, 0, 0.75, 0.75, 16, 16)
			end
		end
	end
end

function game.addMapItem(mapItem)
	local stackable = false
	local types = {
		weapon = weapons,
		armor = armor,
		spell = spells,
		ring = ring,
		items = items,
	}
	if mapItem.type == 'items' then 
		stackable = true 
	end
	if not mapItemsFound[curMap] or (mapItemsFound[curMap] and not mapItemsFound[curMap][mapItem.name]) then 
		table.insert(mapItems, {name = mapItem.name, item = types[mapItem.properties.itemType][mapItem.properties.item], type = mapItem.type, x = mapItem.x, y = mapItem.y, partCD = 0.05, part2CD = 0.05, stackable = stackable, stack = 1})
	end
end

function game.updatePickupPrompt(dt)
	if # bigText > 0 then return end
	if # itemPickupPrompt > 0 then 
		itemPickupPrompt[1].dt = itemPickupPrompt[1].dt + dt
		if not itemPickupPrompt[1].drawn then 
			local text = itemPickupPrompt[1].item.item.desc
			local width, text = scarletLib.layout.getFont('font1'):getWrap(text, 225)
			local ty = love.graphics.getHeight() / 2 - 130
			local xx = love.graphics.getWidth() / 2 - 100
			itemPickupPrompt[1].drawn = true
			scarletLib.layout.addFrame({
				name = 'pickupframe1',
				group = 'pickup',
				x = love.graphics.getWidth() / 2 - 310,
				y = love.graphics.getHeight() / 2 - 240,
				width = 620,
				height = 470,
				z = 8,
				style = 1,
			})
			scarletLib.layout.addFrame({
				name = 'pickupframe2',
				group = 'pickup',
				x = love.graphics.getWidth() / 2 - 300,
				y = love.graphics.getHeight() / 2 - 230,
				width = 600,
				height = 450,
				z = 8,
				style = itemPickupPrompt[1].style or 2,
			})
			scarletLib.layout.addFrame({
				name = 'pickupframe4',
				group = 'pickup',
				x = love.graphics.getWidth() / 2 - scarletLib.layout.getTextWidth('Item Recieved', 'font1') * 1.5 / 2 - 10,
				y = love.graphics.getHeight() / 2 - 240 - 8,
				z = 5,
				width = scarletLib.layout.getTextWidth('Item Recieved', 'font1') * 1.5 + 18,
				height = 34,
				style = 1,
			})
			scarletLib.layout.addText({
				name = 'pickupframe4title',
				group = 'pickup',
				x = love.graphics.getWidth() / 2 - scarletLib.layout.getTextWidth('Item Recieved', 'font1') * 1.5 / 2,
				y = love.graphics.getHeight() / 2 - 240 - 8 + 8,
				z = 4,
				font = 'font1',
				text = 'Item Recieved',
				zoom = 1.5,
				color = {150, 150, 150, 255}
			})
			scarletLib.layout.addFrame({
				name = 'pickupframe3',
				group = 'pickup',
				x = love.graphics.getWidth() / 2 - scarletLib.layout.getTextWidth('Press SPACE to Continue', 'font1') * 1.5 / 2 - 10,
				y = love.graphics.getHeight() / 2 + 240 - 36,
				z = 5,
				width = scarletLib.layout.getTextWidth('Press SPACE to Continue', 'font1') * 1.5 + 18,
				height = 34,
				style = 1,
			})
			scarletLib.layout.addText({
				name = 'pickupframe3title',
				group = 'pickup',
				x = love.graphics.getWidth() / 2 - scarletLib.layout.getTextWidth('Press SPACE to Continue', 'font1') * 1.5 / 2,
				y = love.graphics.getHeight() / 2 + 240 - 36 + 8,
				z = 4,
				font = 'font1',
				text = 'Press SPACE to Continue',
				zoom = 1.5,
				color = {150, 150, 150, 255}
			})
			scarletLib.layout.addLine({
				name = 'pickuptextline',
				group = 'pickup',
				x1 = love.graphics.getWidth() / 2 - 200,
				x2 = love.graphics.getWidth() / 2 + 200,
				y1 = love.graphics.getHeight() / 2 - 180,
				y2 = love.graphics.getHeight() / 2 - 180,
				z = 7,
				color = {100,100,100,255}
			})
			scarletLib.layout.addText({
				name = 'pickuptext',
				group = 'pickup',
				x = love.graphics.getWidth() / 2 - scarletLib.layout.getTextWidth(itemPickupPrompt[1].item.item.dname, 'font1'),
				y = love.graphics.getHeight() / 2 - 195,
				z = 6,
				font = 'font1',
				zoom = 2,
				text = itemPickupPrompt[1].item.item.dname,
			})
			scarletLib.layout.addImage({
				name = 'pickupimg',
				group = 'pickup',
				x = xx - 115,
				y = ty,
				sx = 3,
				sy = 3,
				z = 6,
				img = itemPickupPrompt[1].item.item.icon,
			})
			for i = 1, # text do 
				if string.len(text[i]) > 0 then 
					scarletLib.layout.addText({
						x = xx + 22,
						y = ty,
						group = 'pickup',
						z = 7,
						zoom = 1.5, 
						text = text[i],
						font = 'font1',
						color = {150,150,150},
					})
					scarletLib.layout.addLine({
							x1 = xx + 10,
							y1 = ty + 20,
							x2 = xx + 360,
							y2 = ty + 20,
							z = 7,
							group = 'pickup',
							color = {100, 100, 100},
							fade = 150,
						})
						scarletLib.layout.addLine({
							x1 = xx + 30,
							y1 = ty + 20,
							x2 = xx + 320,
							y2 = ty + 20,
							z = 7,
							group = 'pickup',
							color = {100, 100, 100},
							fade = 200,
						})
				end
				ty = ty + 30
			end
			scarletLib.layout.changeElementGroup('pickup', 'fade', 0)
		else
			scarletLib.layout.changeElementGroup('pickup', 'fade', 1000 * dt * itemPickupPrompt[1].dfade, true)
			if scarletLib.layout.getValue('pickupframe1', 'fade') <= 0 and itemPickupPrompt[1].dfade == -1 then 
				table.remove(itemPickupPrompt, 1)
				scarletLib.layout.deleteByGroup('pickup')
				scarletLib.layout.deleteFlaggedGroups()
			end
		end
	end
end

function game.removeItemFromPlayer(item)
	--- If the player has the item then remove from the inventory and return true
	--- return false if the player did not have the item
	for i = 1, # inventory do 
		if inventory[i].item == item.item then 
			inventory[i].stack = inventory[i].stack - 1 
			if inventory[i].stack < 1 then 
				table.remove(inventory, i)
			end
			return true 
		end
	end
	return false
end

function game.drawPickupPrompt()

end

---
--- Matter Shards
---
function game.updateMatterShards(dt)
	for i = # matterShards, 1, -1 do 
		matterShards[i].dt = matterShards[i].dt + dt
		matterShards[i].part = matterShards[i].part - dt
		if not matterShards[i].prev then 
			matterShards[i].prev = {{matterShards[i].x, matterShards[i].y},{matterShards[i].x, matterShards[i].y}}
		end
		if matterShards[i].part <= 0 then 
			for k,v in pairs(matterShards[i].prev[1]) do 
				matterShards[i].prev[2][k] = v 
			end 
			matterShards[i].prev[1][1] = matterShards[i].x 
			matterShards[i].prev[1][2] = matterShards[i].y
			matterShards[i].part = 0.03
		end
		if matterShards[i].dt <= 0.45 then 
			local dx = math.cos(matterShards[i].rot)
			local dy = math.sin(matterShards[i].rot)
			local spd = math.max(0, 150 - (matterShards[i].dt * 20000) * dt)
			matterShards[i].x = matterShards[i].x + (dx * spd) * dt 
			matterShards[i].y = matterShards[i].y + (dy * spd) * dt
		else
			local angle = math.atan2(player.y - matterShards[i].y, player.x - matterShards[i].x)
			local spd = math.min(150, -200 + (matterShards[i].dt * 20000) * dt)
			local dx = math.cos(angle)
			local dy = math.sin(angle)
			matterShards[i].x = matterShards[i].x + (dx * spd) * dt 
			matterShards[i].y = matterShards[i].y + (dy * spd) * dt
			matterShards[i].rot = matterShards[i].rot - (matterShards[i].rot - angle) * dt
		end
		if math.sqrt((matterShards[i].x - player.x)^2 + (matterShards[i].y - player.y)^2) <= 3 then 
			player.matter = player.matter + matterShards[i].amnt
			game.playSound('matter', player.x, player.y)
			game.emitParticlesAt('matterpickup', player.x, player.y, 15)
			game.timeOut(0.01)
			table.insert(residualLights, {x = matterShards[i].x, y = matterShards[i].y, color = {1 - matterShards[i].color[1] / 255, 1 - matterShards[i].color[2] / 255, 1 - matterShards[i].color[3] / 255}, light = 35})
			table.remove(matterShards, i)
		end
	end
end

function game.drawMatterShards()
	for i = 1, # matterShards do 
		love.graphics.setColor(matterShards[i].color[1], matterShards[i].color[2], matterShards[i].color[3], 100)
		love.graphics.draw(img.part['matterShard'..matterShards[i].size], matterShards[i].prev[2][1], matterShards[i].prev[2][2], matterShards[i].rot + math.pi / 2, 1, 1, 16, 16)
		love.graphics.setColor(matterShards[i].color[1], matterShards[i].color[2], matterShards[i].color[3], 175)
		love.graphics.draw(img.part['matterShard'..matterShards[i].size], matterShards[i].prev[1][1], matterShards[i].prev[1][2], matterShards[i].rot + math.pi / 2, 1, 1, 16, 16)
		love.graphics.setColor(matterShards[i].color[1], matterShards[i].color[2], matterShards[i].color[3], 255)
		love.graphics.draw(img.part['matterShard'..matterShards[i].size], matterShards[i].x, matterShards[i].y, matterShards[i].rot + math.pi / 2, 1, 1, 16, 16)
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function game.addMatterShard(amnt, x, y)
	local rot = love.math.random(0, 627) / 100
	local drop = math.ceil(amnt / 25)
	if amnt > 500 then 
		drop = math.ceil(amnt / 100)
	end
	for i = 1, drop do 
		local color = {
			{175, 150, 255},
			{255, 175, 75},
			{75, 255, 175},
			{255, 75, 175},
			{175, 255, 75},
		}
		table.insert(matterShards, {amnt = math.ceil(amnt / drop), color = color[love.math.random(1, 3)], size = 'Small', x = x, y = y, rot = rot, dt = love.math.random(0, 10) / 100, part = 0})
		rot = rot + (627 / drop) / 100
	end
end

---
--- Big Text
---
function game.updateBigText(dt)
	if # bigText > 0 then 
		bigText[1].fade = bigText[1].fade + (100 * bigText[1].df) * dt 
		if bigText[1].fade > 350 then 
			bigText[1].fade = 350
			bigText[1].df = -1 
		end
		bigText[1].dt = bigText[1].dt - dt 
		if bigText[1].dt < 0 then 
			table.remove(bigText, 1)
		end
	end
end

function game.drawBigText()
	local s = 1
	if # bigText > 0 then 
		if bigText[1].text == 'You Died' then 
			love.graphics.setFont(scarletLib.layout.getFont('font1'))
			love.graphics.setColor(bigText[1].color[1], bigText[1].color[2], bigText[1].color[3], bigText[1].fade)
			love.graphics.setLineWidth(20)
			love.graphics.line(love.graphics.getWidth() * 0.35, love.graphics.getHeight() * 0.5 + 60 + bigText[1].oy, love.graphics.getWidth() * 0.65, love.graphics.getHeight() * 0.5 + 60 + bigText[1].oy)
			love.graphics.setLineWidth(16)
			love.graphics.line(love.graphics.getWidth() * 0.4, love.graphics.getHeight() * 0.5 + 60 + bigText[1].oy, love.graphics.getWidth() * 0.6, love.graphics.getHeight() * 0.5 + 60 + bigText[1].oy)
			love.graphics.setLineWidth(12)
			love.graphics.line(love.graphics.getWidth() * 0.20, love.graphics.getHeight() * 0.5 + 60 + bigText[1].oy, love.graphics.getWidth() * 0.8, love.graphics.getHeight() * 0.5 + 60 + bigText[1].oy)
			if not bigText[1].location or bigText[1].intake then
				love.graphics.setColor(0, 0, 0, math.min(40, bigText[1].fade))
				love.graphics.rectangle('fill', 0, math.floor(love.graphics.getHeight() * 0.5) + bigText[1].oy - 68, love.graphics.getWidth(), 300)
				love.graphics.setColor(0, 0, 0, math.min(100, bigText[1].fade))
				love.graphics.rectangle('fill', 0, math.floor(love.graphics.getHeight() * 0.5) + bigText[1].oy - 36, love.graphics.getWidth(), 180)
				love.graphics.setColor(0, 0, 0, math.min(150, bigText[1].fade))
				love.graphics.rectangle('fill', 0, math.floor(love.graphics.getHeight() * 0.5) + bigText[1].oy - 12, love.graphics.getWidth(), 100)
			end
			love.graphics.setColor(bigText[1].color[1], bigText[1].color[2], bigText[1].color[3], bigText[1].fade)
			love.graphics.printf(bigText[1].text, math.floor(love.graphics.getWidth() * (-2)), math.floor(love.graphics.getHeight() * 0.5) + bigText[1].oy, math.floor(love.graphics.getWidth() * 0.5), "center", 0, 10, 8)
			if bigText[1].subtext then 
				love.graphics.printf(bigText[1].subtext, math.floor(love.graphics.getWidth() * 0.25), math.floor(love.graphics.getHeight() * 0.5) + bigText[1].oy + 42, math.floor(love.graphics.getWidth() * 0.5), "center", 0, 1, 1)
			end
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.setFont(love.graphics.getFont())
		else
			love.graphics.setFont(scarletLib.layout.getFont('font1'))
			love.graphics.setColor(bigText[1].color[1], bigText[1].color[2], bigText[1].color[3], bigText[1].fade)
			love.graphics.setLineWidth(3)
			love.graphics.line(love.graphics.getWidth() * 0.4, love.graphics.getHeight() * 0.5 + 34 + bigText[1].oy, love.graphics.getWidth() * 0.6, love.graphics.getHeight() * 0.5 + 34 + bigText[1].oy)
			love.graphics.setLineWidth(2)
			love.graphics.line(love.graphics.getWidth() * 0.35, love.graphics.getHeight() * 0.5 + 34 + bigText[1].oy, love.graphics.getWidth() * 0.65, love.graphics.getHeight() * 0.5 + 34 + bigText[1].oy)
			love.graphics.setLineWidth(1)
			love.graphics.line(love.graphics.getWidth() * 0.25, love.graphics.getHeight() * 0.5 + 34 + bigText[1].oy, love.graphics.getWidth() * 0.75, love.graphics.getHeight() * 0.5 + 34 + bigText[1].oy)
			if not bigText[1].location or bigText[1].intake then
				love.graphics.setColor(0, 0, 0, math.min(40, bigText[1].fade))
				love.graphics.rectangle('fill', 0, math.floor(love.graphics.getHeight() * 0.5) + bigText[1].oy - 68, love.graphics.getWidth(), 200)
				love.graphics.setColor(0, 0, 0, math.min(100, bigText[1].fade))
				love.graphics.rectangle('fill', 0, math.floor(love.graphics.getHeight() * 0.5) + bigText[1].oy - 36, love.graphics.getWidth(), 128)
				love.graphics.setColor(0, 0, 0, math.min(150, bigText[1].fade))
				love.graphics.rectangle('fill', 0, math.floor(love.graphics.getHeight() * 0.5) + bigText[1].oy - 12, love.graphics.getWidth(), 74)
			end
			love.graphics.setColor(bigText[1].color[1], bigText[1].color[2], bigText[1].color[3], bigText[1].fade)
			love.graphics.printf(bigText[1].text, math.floor(love.graphics.getWidth() * (-0.25 * s * s)), math.floor(love.graphics.getHeight() * 0.5) + bigText[1].oy, math.floor(love.graphics.getWidth() * 0.5), "center", 0, 3 * s, 3 * s)
			if bigText[1].subtext then 
				love.graphics.printf(bigText[1].subtext, math.floor(love.graphics.getWidth() * 0.25), math.floor(love.graphics.getHeight() * 0.5) + bigText[1].oy + 42, math.floor(love.graphics.getWidth() * 0.5), "center", 0, 1, 1)
			end
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.setFont(love.graphics.getFont())
		end
	end
end

function game.addBigText(text)
	table.insert(bigText, {text = text.text, size = text.size or 1, subtext = text.subtext, intake = text.intake, location = text.location, color = text.color, oy = text.oy, fade = text.fade, df = text.df, dt = text.dt})
end

---
--- Gibs
---
function game.updateGibs(dt)
	for i = 1, # gibs do 
		if gibs[i].drot == 0 then 
			gibs[i].drot = 1 
		end
		if gibs[i].dt >= 0 then 
			gibs[i].x = gibs[i].x + math.cos(gibs[i].rot) * 125 * dt
			gibs[i].y = gibs[i].y + math.sin(gibs[i].rot) * 125 * dt
			gibs[i].rot = gibs[i].rot + gibs[i].drot * 1 * dt 
			gibs[i].dt = gibs[i].dt - dt
			if gibs[i].dt <= 0 then 
				if gibs[i].type == 'animal' then 
					game.emitParticlesAt('redblood', gibs[i].x, gibs[i].y, 10)
					if gibs[i].size ~= 'large' then 
						game.addDecal('blood2', gibs[i].x, gibs[i].y, gibs[i].rot)
					else
						game.addDecal('blood1', gibs[i].x, gibs[i].y, gibs[i].rot)
					end
				elseif gibs[i].type == 'wood' then 
					game.emitParticlesAt('smoke', gibs[i].x, gibs[i].y, 15)
					game.addDecal('wooddebris1', gibs[i].x, gibs[i].y, gibs[i].rot)
				end
			end
		end
	end
end

function game.drawGibs()
	for i = 1, # gibs do 
		if gibs[i].type == 'animal' then 
			love.graphics.setShader(replaceColor)
			replaceColor:send('r', gibs[i].color[1] / 255)
			replaceColor:send('g', gibs[i].color[2] / 255)
			replaceColor:send('b', gibs[i].color[3] / 255)
			love.graphics.draw(img.playerType['gib'..gibs[i].size], gibs[i].x, gibs[i].y, gibs[i].rot, 1, 1, 16, 16)
			love.graphics.setShader()
		elseif gibs[i].type == 'wood' then 
			love.graphics.draw(img.playerType['woodgib'..gibs[i].size], gibs[i].x, gibs[i].y, gibs[i].rot, 1, 1, 16, 16)
		end
	end
end

function game.addGibs(x, y, rx, ry, s, m, l, color, type)
	local t = {s, m, l}
	local s = {'small', 'medium', 'large'}
	color = {color[1] * 0.55, color[2] * 0.35, color[3] * 0.35}
	for i = 1, 3 do 
		for k = 1, t[i] do 
			table.insert(gibs, {type = type, x = x + love.math.random(0 - rx, 0 + rx), y = y + love.math.random(0 - ry, 0 + ry), rot = love.math.random(1, 314) / 100, drot = love.math.random(-1, 1), dt = love.math.random(5, 15) / 100, size = s[i], color = color})
		end
	end
end

--- 
--- Fog
---
function game.updateFog(dt)
	for k,v in pairs(map.objects) do
		if v.layer.name == 'fog' then 
			for i = 1, # actors do 
				if actors[i].name == v.name and actors[i].noticed and not actors[i].dead and not v.properties.on then 
					v.properties.on = true 
					world:add(v, v.x, v.y, v.width, v.height)
				elseif actors[i].name == v.name and actors[i].dead and v.properties.on then 
					v.properties.on = false 
					world:remove(v)
				end
			end
		end
		if v.layer.name == 'fog' and v.properties.on then 
			for i = 1, 5 do
				game.emitParticlesAt('fog', love.math.random(v.x, v.x + v.width), love.math.random(v.y, v.y + v.height), 1)
			end
		end
	end
end

---
--- Sound
---
function game.playSound(sound, x, y)
	local dist = math.sqrt((player.y - y)^2 + (player.x - x)^2)
	love.audio.setPosition(player.x, player.y)
	snd[sound]:setPitch(love.math.random(75, 125) / 100)
	snd[sound]:setRelative(true)
	snd[sound]:setVolume(1 - (dist / 250))
	snd[sound]:stop()
	snd[sound]:play()
end

---
--- Other ---
function game.formatNumber(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

function game.timeOut(amnt)
	timeOut = math.min(0.03, timeOut + amnt)
end

function game.firstToUpper(str)
	return (str:gsub("^%l", string.upper))
end
---
--- Getters
---
function game.getAnim8() return anim8 end
function game.getPlayer() return player end
function game.getSpells() return spells end

---
---
---
return game