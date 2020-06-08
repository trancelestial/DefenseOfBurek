local M={}
M.astar = require("astar")

M.map = {}

M.map.width = 0
M.map.height = 0
M.canBuild = true
-- globalne predefinisane boje
M.color = {}
M.color.r = 255
M.color.g = 255
M.color.b = 255
M.color.a = 100

M.const={}
M.const.empty=0
M.const.rock=1
M.const.turret=2

M.colorHover = {}
M.colorHover.r = 0
M.colorHover.g = 100
M.colorHover.b = 200
M.colorHover.a = 100

function M.newTurret(i, j, type)
    if M.map[i][j].val ~= M.const.empty or type == 0 or
    not M.canBuild or --odkomentarisati kada ne debagujemo
       gui.gold - turret[type].cost < 0 then
       return
    end
    M.map[i][j].val = M.const.turret

    M.map[i][j].ttype = type
    newTurret = {}
    newTurret.hp = 100
    newTurret.x = i
    newTurret.y = j
    newTurret.dmg = turret[type].dmg
    newTurret.cooldown = turret[type].cooldown
    newTurret.currCooldown = turret[type].cooldown
    newTurret.range = turret[type].range
    newTurret.targetNum = turret[type].targetNum
    newTurret.drawingTime = 0.2 --ovo bi moglo da se mune u turrets.lua
    newTurret.currDrawingTime = newTurret.drawingTime

    newTurret.effects = {}
    for effect,val in pairs(turret[type].effects) do
        newTurret.effects[effect] = val
    end

    newTurret.type = type
    table.insert(M.turrets, newTurret)
    gui.gold = gui.gold - turret[type].cost
end

function M.removeTurret(i, j, free)
    if map.map[i][j].val ~= map.const.turret then
        return
    end
    map.map[i][j].val = map.const.empty
    for k, v in pairs(M.turrets) do
        if v.x == i and v.y == j then
            M.turrets[k] = nil --ovako se brise entry iz tabele
            if free then
              gui.gold = gui.gold + turret[M.map[i][j].ttype].cost
            else
              gui.gold = gui.gold + turret[M.map[i][j].ttype].cost/2
            end
        end
    end
end

M.turrets = {}

turrets = require("turrets")
turret = turrets.turret

spawnHole = {}
spawnHole.img = love.graphics.newImage("img/hole.png")
rock = {}
rock.img = love.graphics.newImage("img/rock.png")
background = {}
background.img = love.graphics.newImage("img/sand.jpg")
burek = {}
burek.img = love.graphics.newImage("img/burek.png")
burek.holylight= {}
burek.holylight.img = love.graphics.newImage("img/holylight.png")
burek.holylight.alphaBack = 255
burek.holylight.alphaFront = 155
burek.hp = 1000
burek.fullHp = 1000
screen = {}

--update vars pri resize
function M.updateSize(topBar, bottomBar)
    --print(turret)
    screen.width = love.graphics.getWidth()
    screen.height = love.graphics.getHeight() - gui.topBarHeight - gui.bottomBarHeight
    background.scalex = 1/(background.img:getWidth()/screen.width)
    background.scaley = 1/(background.img:getHeight()/screen.height)
    -- print(screen.width, screen.height)
    chunkW = screen.width / M.map.width
    chunkH = screen.height / M.map.height
    --kolko se slicica skalira. kada ubacimo resize ovo treba update
    --da ne bismo bas svaki frame za svaku kulu racunali
    local turretToChunkHeight = 1.5
    local rockToChunkHeight = 1.2
    rock.scalex = 1/(rock.img:getWidth()/chunkW)
    rock.scaley = 1/(rock.img:getHeight()/chunkH)*rockToChunkHeight
    rock.offsety = gui.topBarHeight - rock.img:getHeight()*rock.scaley

    turret.scalex = 1/(turret[1].img:getWidth()/chunkW)
    turret.scaley = 1/(turret[1].img:getHeight()/chunkH)*turretToChunkHeight
    turret.offsety = gui.topBarHeight - turret[1].img:getHeight()*turret.scaley

    burek.scalex = 1/(burek.img:getWidth()/chunkW) * 2
    burek.scaley = 1/(burek.img:getHeight()/chunkH)*rockToChunkHeight * turretToChunkHeight
    burek.offsetx = -burek.scalex*burek.img:getWidth() / 2
    burek.offsety = gui.topBarHeight - burek.img:getHeight()*burek.scaley
    burek.holylight.scalex = 1/(burek.holylight.img:getWidth()/chunkW) * 3
    burek.holylight.scaley = 1/(burek.holylight.img:getHeight()/chunkH)*rockToChunkHeight * 2.5
    burek.holylight.offsetx = -burek.holylight.scalex*burek.holylight.img:getWidth() / 2
    burek.holylight.offsety = gui.topBarHeight - burek.holylight.img:getHeight()*burek.holylight.scaley * 0.8
    burek.holylight.backoffsety = gui.topBarHeight - burek.holylight.img:getHeight()*burek.holylight.scaley * 0.6

    spawnHole.scalex = 1/(spawnHole.img:getWidth()/chunkW)
    spawnHole.scaley = 1/(spawnHole.img:getHeight()/chunkH)
    spawnHole.offsety = gui.topBarHeight - spawnHole.img:getHeight()*spawnHole.scaley
end

-- Generise praznu mapu
-- postavlja chunkW i chunkH, sto je visina i sirina svakog pravougaonika
function M.generateEmpty(width, height, numRocks)
    for i=1, width do
        M.map[i] = {}
        for j=1, height do
            M.map[i][j] = {}
            --val je tip objekta
            M.map[i][j].val = M.const.empty
            M.map[i][j].hover = false
        end
    end
    begin = {}
  	begin.posx = 10
  	begin.posy = 1
    M.map.width = width
    M.map.height = height
    burek.posx = width
    burek.posy = 1

    M.updateSize()
end

function M.generateRocks(w, h, n)
    for i=1, n do
      local x = math.random(w)
        local y = math.random(h)
		    if not ((x==1 or x==2) and (y==h or y==h-1)) and not ((x==w or x==w-1 or x==w-2) and (y==1 or y==2 or y==3)) then
    			M.map[x][y].val = M.const.rock
    		end
    end
    M.updateSize()
end
-- Promeni boju chunka na hover
-- moze matematicki da se izracuna u kom je polju, umesto for petlje
-- mada nije mnogo bitno jer je mali grid
function M.mouse(x, y)
    local mouseX, mouseY = x, y
    local selectedX = -1
    local selectedY = -1
    for i=1 , M.map.width do
        isx = mouseX > (i-1)*chunkW and mouseX < i*chunkW
        for j=1 , M.map.height do
            isy = mouseY > 50 + (j-1)*chunkH and mouseY < gui.topBarHeight + j*chunkH
            if isx and isy then
                M.map[i][j].hover = true
                selectedX, selectedY = i , j
            else
                M.map[i][j].hover = false
            end
        end
    end
    return selectedX, selectedY
end

-- Iscrtava mapu
function M.draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(background.img, 0, gui.topBarHeight, 0, background.scalex, background.scaley )

    local highlight=255

    for j=1 , M.map.height do
        for i=1 , M.map.width do
            if M.map[i][j].hover == false then
                love.graphics.setColor(M.color.r, M.color.g, M.color.b, M.color.a)
            else
                love.graphics.setColor(M.colorHover.r, M.colorHover.g,
                    M.colorHover.b, M.colorHover.a)
            end
            love.graphics.rectangle("fill", (i-1)*chunkW, gui.topBarHeight + (j-1)*chunkH, chunkW-1, chunkH-1)
        end
    end
    love.graphics.setColor(255,255,255)
    love.graphics.draw(spawnHole.img,  (enemy.creepStarty-1)*chunkW,
    enemy.creepStartx*chunkH + spawnHole.offsety, 0, spawnHole.scalex, spawnHole.scaley)

    for j=1 , M.map.height do
      -- draw row of creeps
      enemy.drawCreeps(j)
        for i=1 , M.map.width do
            --draw turret
            if M.map[i][j].val == M.const.turret then
                local img = turret[M.map[i][j].ttype].img
                love.graphics.setColor(255,255,255)
                love.graphics.draw(img,  (i-1)*chunkW, j*chunkH + turret.offsety,
                    0, turret.scalex, turret.scaley)
            --draw rock
            elseif M.map[i][j].val == M.const.rock then
                love.graphics.setColor(255,255,255)
                love.graphics.draw(rock.img,  (i-1)*chunkW, j*chunkH + rock.offsety,
                    0, rock.scalex, rock.scaley)
            end
        end
        enemy.drawCreeps(j)
    end
end

--returning the module
return M
