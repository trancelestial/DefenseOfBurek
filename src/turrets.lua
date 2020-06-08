local M = {}

fireTurretImg = love.graphics.newImage("img/turret.png")
frostTurretImg = love.graphics.newImage("img/frostTurret.png")
greenTurretImg = love.graphics.newImage("img/greenTurret.png")
enemyImg = love.graphics.newImage("img/enemy.png")

M.turret = {}
index = 1

M.turret[index] = {}
M.turret[index].img = fireTurretImg
M.turret[index].cost = 40
M.turret[index].dmg = 100
M.turret[index].cooldown = 0.6
M.turret[index].range = 2
M.turret[index].targetNum = 1
M.turret[index].rayr = 255
M.turret[index].rayg = 0
M.turret[index].rayb = 0
M.turret[index].effects = {}
M.turret[index].effects["burn"] = {}
    M.turret[index].effects["burn"]["duration"] = 2
    M.turret[index].effects["burn"]["dot"] = 1
index = index + 1

M.turret[index] = {}
M.turret[index].img = frostTurretImg
M.turret[index].cost = 60
M.turret[index].dmg = 1
M.turret[index].cooldown = 0.2 --mora neki cd, inace ce je dmg povezan sa delta time
M.turret[index].range = 2
M.turret[index].targetNum = 2
M.turret[index].rayr = 150
M.turret[index].rayg = 200
M.turret[index].rayb = 255
M.turret[index].effects = {}
M.turret[index].effects["freeze"] = {}
    M.turret[index].effects["freeze"]["duration"] = 1
    M.turret[index].effects["freeze"]["slow"] = .5
index = index + 1

M.turret[index] = {}
M.turret[index].img = greenTurretImg
M.turret[index].cost = 100
M.turret[index].dmg = 45
M.turret[index].cooldown = .3
M.turret[index].range = 1
M.turret[index].targetNum = -1 -- inf
M.turret[index].rayr = 0
M.turret[index].rayg = 255
M.turret[index].rayb = 0
M.turret[index].effects = {}
index = index + 1

-- M.turret[index] = {}
-- M.turret[index].img = fireTurretImg -- split
-- M.turret[index].cost = 0
-- M.turret[index].dmg = 0
-- M.turret[index].cooldown = .30
-- M.turret[index].range = 1
-- M.turret[index].targetNum = -1 -- inf
-- M.turret[index].rayr = 0
-- M.turret[index].rayg = 255
-- M.turret[index].rayb = 0
-- M.turret[index].effects = {}
-- index = index + 1





return M
