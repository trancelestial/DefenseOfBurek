local M={}

M.img = love.graphics.newImage("img/enemy.png")
M.burn = love.graphics.newImage("img/burn.png")
M.creeps = {}
M.rows = {} -- IDs in each row
M.step = 0.1
local creep={}
creep.health=500
--coords chunka
creep.posx=1
creep.posy=10 -- TODO sredi negde drugo
--pozicija u chunku
creep.x = 0
creep.y = 0
creep.dmg=10
creep.path={}
creep.effects={}
creep.chIndex=1
numCreeps=0
creepValue = 10
M.creepStartx = 10
M.creepStarty = 1
M.waveSize = 10
beginSpawnAt = 0
numLeftToSpawn = 0
hp = creep.health
M.checkSpawning = -1
M.spawnTimeDelta = 0.5
function M.spawnCreepWave(currTime, n)
    local TIME_APART = M.spawnTimeDelta

    --ako se samo proverava da li se spawn, i treba da se stvore
    if n == M.checkSpawning then
        if beginSpawnAt + TIME_APART <= currTime and numLeftToSpawn > 0 then
            beginSpawnAt = beginSpawnAt + TIME_APART
            numLeftToSpawn = numLeftToSpawn - 1
            spawnCreepAndInitAstar(hp)
        end
    else --inace se inicijalizuje spawnovanje
        beginSpawnAt = currTime
        minSum = math.floor(n/3)
        numLeftToSpawn = minSum + math.ceil(math.random()*(n-minSum))
        hp = creep.health * math.sqrt(n/10) * (n/numLeftToSpawn)-- skaliraju se da budu jaci sto ih je manje
        map.canBuild = false
    end
end

function M.updateWaveSize()
    M.waveSize = M.waveSize + math.floor(M.waveSize / 2.5 )
end
--iscrtava nisan od kule do neprijatelja
function M.targetEnemies(dt)

    for _, turr in pairs(map.turrets) do
		local i, j = turr.x, turr.y
		local creeps = enemy.inRange(i,j,turr.range,turr.targetNum)

        turr.targets = {} --Racuna targete svaki put
        turr.currCooldown = turr.currCooldown - dt
        turr.currDrawingTime = turr.currDrawingTime - dt

        for _,v in pairs(creeps) do
            turr.targets[v] = true

            if turr.currCooldown <= 0 then
                turr.currDrawingTime = turr.drawingTime

                --add effects
                for effect,val in pairs(turr.effects) do
                    if M.creeps[v].effects[effect] == nil then
                        M.creeps[v].effects[effect] = {}
                    end
                    for a,b in pairs(val) do
                        M.creeps[v].effects[effect][a] = b
                    end
                end

                --inflict damage
                local dead = M.creeps[v]:inflictDamage(turr.dmg)
                if dead then
                     M.rows[M.creeps[v].posy][v] = nil
                     M.creeps[v] = nil
                     numCreeps = numCreeps - 1
                     if numCreeps == 0 then
                        levelEnded()
                     end
                     gui.gold = gui.gold + creepValue
                end
            end
        end
        if turr.currCooldown <= 0 then
            turr.currCooldown = turr.cooldown
        end
	end
end

function creep:inflictDamage(dmg)
    self.health = self.health - dmg
    return self.health <= 0
end

function M.drawRays()
    for index,turr in pairs(map.turrets) do
        if turr.currDrawingTime >= 0 then
            local i, j = turr.x, turr.y

            local offsetx = chunkW / 2
            local offsetStarty = - chunkH / 4 + gui.topBarHeight
            local offsety = chunkH / 2 + gui.topBarHeight

            local startx = (i-1)*chunkW + offsetx
            local starty = (j-1)*chunkH + offsetStarty

            col = turret[turr.type]
            love.graphics.setColor(col.rayr, col.rayg, col.rayb)

            for v,target in pairs(turr.targets) do
                if M.creeps[v] ~= nil then
                    local endx = (M.creeps[v].posx-1 + M.creeps[v].x/2)*chunkW + offsetx
                    local endy = (M.creeps[v].posy-1 + M.creeps[v].y/2)*chunkH + offsety
                    love.graphics.line(startx, starty,endx, endy)
                end
            end
        end
    end
end

-- shallow-copy tabele, samo copy paste vrednosti
function copy (t)
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do target[k] = v end
    setmetatable(target, meta)
    return target
end

--prolazi kroz sve kripove i gleda da l su blizu kule
--moze se optimizovati ako se cuvaju svi kripovi u odredjenom polju
function M.inRange(i,j,range,n)
    local result = {}
    for k,v in pairs(M.creeps) do
        if math.abs(v.posx - i) <=range and math.abs(v.posy - j) <=range then
            table.insert(result, k)
            n = n-1
        end
        if n == 0 then
            break;
        end
    end
    return result
end

creepId = 1
function M.spawnCreeps(path,hp)
    local newCreep = copy(creep)
    M.creeps[creepId] = newCreep
	M.creeps[creepId].path = copy(path)
    M.creeps[creepId].effects = {}
    M.creeps[creepId].health = hp
    M.creeps[creepId].maxHp = hp

    if M.rows[creep.posy] == nil then
      M.rows[creep.posy] = {}
    end

    M.rows[creep.posy][creepId] = true

    creepId = creepId + 1
    numCreeps = numCreeps + 1
end

function M.moveCreeps(dt)
    local mul = dt / 0.0167 --odnos dt i idealnog dt
    local step = M.step * mul

    for index,i in pairs(M.creeps) do
		if i.chIndex <= i.path.len then
			if i.path[i.chIndex].y > i.posx then
				dx = step
			elseif i.path[i.chIndex].y < i.posx then
				dx = -step
			else
				dx = 0
			end

			if i.path[i.chIndex].x > i.posy then
				dy = step
			elseif i.path[i.chIndex].x < i.posy then
				dy = -step
			else
				dy = 0
			end

            if i.effects["freeze"]~=nil then
                if i.effects["freeze"]["duration"] > 0 then
                    dx = dx*i.effects["freeze"]["slow"]
                    dy = dy*i.effects["freeze"]["slow"]
                    i.effects["freeze"]["duration"] = i.effects["freeze"]["duration"] - dt
                end
            end

			local tryx = i.x + dx
			local tryy = i.y + dy

			if tryx >= 2 or tryx <= -2 then
				if tryx >= 2 then
                    i.posx = i.posx+1
                else
                    i.posx = i.posx-1
                end
                tryx = 0
				i.chIndex = i.chIndex+1
            end
			i.x = tryx

			if tryy >= 2 or tryy <= -2 then
                -- brise se creep iz starog reda
                M.rows[M.creeps[index].posy][index] = nil

                if tryy >= 2 then
                    i.posy = i.posy+1
                else
                    i.posy = i.posy-1
                end
                tryy = 0

                -- upisuje se u novi red
                if M.rows[i.posy] == nil then
                  M.rows[i.posy] = {}
                end
                M.rows[i.posy][index] = true

				i.chIndex = i.chIndex+1
			end
			i.y = tryy

            if i.effects["burn"]~=nil then
                if i.effects["burn"]["duration"] > 0 then
                    i.effects["burn"]["duration"] = i.effects["burn"]["duration"] - dt
                    dead = i:inflictDamage(i.effects["burn"]["dot"])

                    if dead then
                         M.rows[M.creeps[index].posy][index] = nil
                         M.creeps[index] = nil
                         numCreeps = numCreeps - 1
                         if numCreeps == 0 then
                            levelEnded()
                         end
                         gui.gold = gui.gold + creepValue

                    end
                end
            end
            damageBurek(i,index)
		end
    end
end

function damageBurek(creep,index)
    if (creep.posx == burek.posx or creep.posx == burek.posx-1) and
       (creep.posy == burek.posy or creep.posy == burek.posy+1) then

        burek.hp = burek.hp - 100
        M.rows[creep.posy] [index] = nil
        M.creeps[index] = nil
        numCreeps = numCreeps - 1
        if burek.hp <=0 then
            resetGame()
        end
        if numCreeps == 0 then
            levelEnded()
        end
    end
end

function M.drawCreeps(row)
    local hpBarAbove = 5
    local hpBarWidth = 30
    local scalex, scaley = 0.2, 0.2

    if M.rows[row] == nil then
        return
    end
    for index,a in pairs(M.rows[row]) do
        i = M.creeps[index]
        if i == nil then
            return
        end

        local x = (i.posx-1 + i.x/2)*chunkW
        local y = gui.topBarHeight + (i.posy-1 + i.y/2)*chunkH

        --draw creep
        love.graphics.setColor(255,255,255)
        if i.effects["freeze"]~=nil then
            if i.effects["freeze"]["duration"] > 0 then
                love.graphics.setColor(155,155,255)
            end
        end

        if i.effects["burn"]~=nil then
            if i.effects["burn"]["duration"] > 0 then
                love.graphics.draw(M.burn, x-10, y-35, 0, 1, 1)
            end
        end
        love.graphics.draw(M.img, x, y, 0, scalex, scaley)

        --draw hp bar
        local hpPercent = i.health / i.maxHp
        love.graphics.setColor(255*(1-hpPercent),255*hpPercent,0)
        love.graphics.line(x, y + hpBarAbove, x + hpBarWidth * hpPercent, y+ hpBarAbove)
    end
end
return M
