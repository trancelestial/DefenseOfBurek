astar = require("astar")
function love.load()
	love.window.setTitle("Defense of the Burek")
	defaultWidth, defaultHeight = 1024, 768
	love.window.setMode( defaultWidth, defaultHeight )
	math.randomseed(os.time())
	--ucitavanje modula
	gui = require("gui")
	map = require("map")
	enemy = require("enemy")


	numRocks = 19
	map.generateEmpty(19,10, numRocks)
	map.generateRocks(19, 10, numRocks)
	astar.init(map, 1, 19)

	creep = {}
	creep.posx = enemy.creepStartx
	creep.posy = enemy.creepStarty
	function try()
		astar.calculatePath(creep, 1,19)
	end
	if pcall(try) == false then
		map.generateRocks(19, 10, numRocks)
	end


	love.mouse.setVisible(false)
	defaultCursor = love.graphics.newImage("img/mouse_cursor.png")
	mouseImg = defaultCursor

	music = love.audio.newSource("img/music.mp3")
	music:play()
	musicVolume = 0 --da ne slusamo stalno
	love.audio.setVolume(musicVolume)
	love.keyboard.setKeyRepeat(true)
	love.graphics.setLineWidth(5)

	level = 1
	totalTime = 0
end

function love.update(dt)
	--total time meri ukupno vreme od pokreanja igre
	totalTime = totalTime + dt
	--print(dt) neki idealan dt = 1/60 = 0.0167
	enemy.spawnCreepWave(totalTime, enemy.checkSpawning)
	enemy.targetEnemies(dt)
	enemy.moveCreeps(dt)

end

function love.draw()
	map.draw()
	enemy.drawRays()
	gui.draw()
	drawMouse(mouseImg)
end

function drawMouse(mouseImg)
	mousex,mousey=love.mouse.getPosition()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(mouseImg, mousex, mousey, 0, 0.5)
end

function love.mousemoved(x, y, dx, dy, istouch)
	gui.mouseMoved(x, y)
	map.mouse(x, y)
end

function love.mousepressed(x, y, button, istouch)
	gui.mousePressed(x, y, button)
	if gui.selectedTurretType ~= 0 then
		mouseImg = gui.buttons[gui.selectedTurretType].cursor
	else
		mouseImg = defaultCursor
	end

	local x, y = map.mouse(x, y)
	local leftClick = button == 1
	--kliknuto x,y polje, postavi tu turret
	if leftClick then --jer nema lenjog izracunavanja
		if ( x > 0 and y > 0) then
			map.newTurret(x, y, gui.selectedTurretType)
		end
	end
	local rightClick = button == 2
	if rightClick then
		if ( x > 0 and y > 0 ) then
			map.removeTurret(x, y, false)
		end
	end
end

function updateMouse()
	gui.mouse()
	if gui.selectedTurretType ~= 0 then
		mouseImg = gui.buttons[gui.selectedTurretType].cursor
	else
		mouseImg = defaultCursor
	end

	local x,y = map.mouse()
	local leftClick = love.mouse.isDown(1)
	--kliknuto x,y polje, postavi tu turret
	if leftClick then --jer nema lenjog izracunavanja
		if ( x > 0 and y > 0) then
			map.newTurret(x, y, gui.selectedTurretType)
		end
	end
	local rightClick = love.mouse.isDown(2)
	if rightClick then
		if ( x > 0 and y > 0 ) then
			map.removeTurret(x, y)
		end
	end
end

--callbacks koje updateuju da li je dugme pritisnuto ili ne
function love.keypressed( key )
   if key == "m" then
	   musicVolume = -musicVolume  + 1
	   print(musicVolume)
	   love.audio.setVolume(musicVolume)
   end

   if key == "escape" then
	   love.event.quit()
   end

   --for testing
   if key == "space" then
	   spawnCreepAndInitAstar(1000)
   end

   if key == "g" then
	   enemy.spawnTimeDelta = 0.5
	   numOfCreeps = 10
	   enemy.spawnCreepWave(totalTime, numOfCreeps)
   end
end

function spawnCreepAndInitAstar(hp)
	astar.init(map, 1, 19)
	creep = {}
	creep.posx = enemy.creepStartx
	creep.posy = enemy.creepStarty
	creep.health = hp
	function try()
		path = astar.calculatePath(creep, 1,19)
	end
	if pcall(try) then
		enemy.spawnCreeps(path,hp)
	else
		--nadaaaaaa
	end
end

--callback na resize
function love.resize(w, h)
	print(("Window resized to width: %d and height: %d."):format(w, h))
	map.updateSize()
end

function tableSize(tab)
	c = 0
	for k,v in pairs(tab) do
		c = c + 1
	end
	return c
end

function levelEnded()
	level = level + 1
	map.canBuild = true
end

function resetGame()
	for index,i in pairs(enemy.creeps) do
		enemy.rows[enemy.creeps[index].posy][index] = nil
		enemy.creeps[index] = nil
	end
	astar.path = {}
	astar.nodes = {}
	astar.heap = {}
	map.generateEmpty(19,10, numRocks)
	map.generateRocks(19, 10, numRocks)
	astar.init(map, 1, 19)
	function try()
		astar.calculatePath(creep, 1,19)
	end
	if pcall(try) == false then
		map.generateRocks(19, 10, numRocks)
	end
	burek.hp = burek.fullHp
	level = 1
	totalTime = 0
	gui.gold = 300
	map.canBuild = true
	enemy.waveSize = 10
	numCreeps=0
	beginSpawnAt = 0
	numLeftToSpawn = 0
	for k, v in pairs(map.turrets) do
		map.turrets[k] = nil
	end
end
