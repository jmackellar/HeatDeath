--- libraries
local ScarletLib = require('lib/ScarletLib')
local ProFi = require('/lib/profi')
local camera = require('lib/camera')
local anim8 = require('lib/anim8')
local bump = require('lib/bump')
local ser = require('lib/ser')
local sti = require('lib/sti')

--- globals
DEBUG = false

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest', 1)
	ScarletLib.layout.load()
	ScarletLib.gamestate.registerGameState('game')
	ScarletLib.gamestate.switchGameState('game')
	love.keyboard.setKeyRepeat(true)
	love.window.setMode(1440, 900, {resizable = false, fullscreen = false, minwidth = 1440, minheight = 900})
end

function love.update(dt)
	love.window.setTitle('Heat Death - FPS:'..love.timer.getFPS())
	if ScarletLib.gamestate.getGameState().update then
		ScarletLib.gamestate.getGameState().update(dt)
	end
end

function love.draw()
	if ScarletLib.gamestate.getGameState().draw then
		ScarletLib.gamestate.getGameState().draw()
	end
end

function love.mousepressed(x, y, button)
	if ScarletLib.gamestate.getGameState().mousepressed then
		ScarletLib.gamestate.getGameState().mousepressed(x, y, button)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if ScarletLib.gamestate.getGameState().keypressed then
		ScarletLib.gamestate.getGameState().keypressed(key, scancode, isrepeat)
	end
	if key == 'escape' and DEBUG then 
		love.event.push('quit')
	elseif key == '1' and DEBUG then 
		ProFi:start()
	elseif key == '2' and DEBUG then 
		ProFi:stop()
		ProFi:writeReport( 'MyProfilingReport.txt' )
	end
end

function getScarletLib() return ScarletLib end
function getCamera() return camera end
function getBump() return bump end
function getAnim8() return anim8 end
function getSTI() return sti end
function getDEBUG() return DEBUG end