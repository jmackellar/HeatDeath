local items = { }

items.emptyflask = {
	name = 'emptyflask',
	dname = 'Empty Flask',
	icon = love.graphics.newImage("/dat/img/item/emptyflask.png"),
	sort = 'key',
	style = 4,
	affect = 'An empty flask that can be converted into an additional Photonic Flask by a Cryogenic Pod.',
	desc = 'A discarded flask fitted with a modular nanite cap.  Such flasks were often tooled to be used as Photonic Flasks, although only few still exist today.\n\nCan be converted into a Photonic Flask at a Cryogenic Pod.'
}

items.photonicflask = {
	name = 'photonicflask',
	dname = 'Photonic Flask',
	icon = love.graphics.newImage("/dat/img/item/photonicflask.png"),
	sort = 'key',
	style = 3,
	onPickup = 	function (self, actor)
					self.stack = 2
					actor.hasPhotonicFlask = true 
					return self, actor
				end,
	affect = 'Restores health when drunk.  Photonic Flasks are refilled when inside a Cryogenic Pod.',
	desc = 'A small flask that is capable of conducting photons to regenerate damages to the physical body.  The study of photonics has been lost, and the flasks are a relic of an older time.\n\nFlasks are refilled by Cryogenic Pods.'
}

items.naniteinjector = {
	name = 'naniteinjector',
	dname = 'Nanite Material Injector',
	icon = love.graphics.newImage("/dat/img/item/naniteinjector.png"),
	sort = 'key',
	style = 3,
	affect = 'Allows one to level up and increase attributes at any Cryogenic Pod.',
	desc = 'An ancient machine with a micron injection needle.  Matter can be condensed through a power source and injected into the mind and body, strengthing both.\n\nUse at a Cryogenic Pod to level up and increase attributes.',
}

items.mattermeager = {
	name = 'matterpitiful',
	dname = 'Matter of a Meager Being',
	icon = love.graphics.newImage("/dat/img/item/mattermeager.png"),
	sort = 'consume',
	affect = 'Use to gain 250 Matter.  Matter can be spent to levelup or used as currency for merchants.\n\nAll forms of Matter are affected by entropy, being scattered upon death.  Dropped Matter can be recovered before dying a second time.',
	desc = 'The collective matter of a being who lived a meager life, never amounting to anything.\n\nMatter shards can be absorbed into the body to further increase your potential.',
}

items.matterpitiful = {
	name = 'matterpitiful',
	dname = 'Matter of a Pitiful Being',
	icon = love.graphics.newImage("/dat/img/item/matterpitiful.png"),
	sort = 'consume',
	affect = 'Use to gain 100 Matter.  Matter can be spent to levelup or used as currency for merchants.\n\nAll forms of Matter are affected by entropy, being scattered upon death.  Dropped Matter can be recovered before dying a second time.',
	desc = 'The collective matter of a frail being who faded away long ago.\n\nMatter shards can be absorbed into the body to further increase your potential.',
}

items.darkmatter = {
	name = 'darkmatter',
	dname = 'Dark Matter',
	icon = love.graphics.newImage("/dat/img/item/darkmattericon.png"),
	sort = 'consume',
	affect = 'Use to absorb the power of dark matter, increasing maximum health until death.\n\nAll forms of Matter are affected by entropy, being scattered upon death.',
	desc = 'Condensed strings of Dark Matter can be absorbed into the body, increasing physical fortitude.\n\nDark Matter is thought to originate from within the human soul.  Without it, one can not truly be human.'
}

return items