local M={}

M.color = {}
M.color.r = 255
M.color.g = 255
M.color.b = 255
M.color.a = 255

M.topBarHeight = 50
M.bottomBarHeight = 150

goldIcon = love.graphics.newImage("img/gold.png")
M.gold = 300

enemyImg = love.graphics.newImage("img/enemy.png")

turrets = require("turrets")

M.buttons = {}

for index, turret in pairs(turrets.turret) do

    M.buttons[index] = {}
    M.buttons[index].img = turret.img
    M.buttons[index].cursor = turret.img
    M.buttons[index].hover = false
    buttonNum = index
end
buttonNum = buttonNum+1

M.buttons[buttonNum] = {}
M.buttons[buttonNum].img = enemyImg
M.buttons[buttonNum].cursor = enemyImg
M.buttons[buttonNum].hover = false

-- TODO samo jedan moze biti hoverovan, nema potreba za ovoliko boolova

M.selectedTurretType = 0
buttonMargin = 10
buttonPadding = 10

buttonSize = M.bottomBarHeight - 2 * buttonMargin
buttonInnerSize = buttonSize - 2 * buttonPadding

function drawButton(n,img)
    love.graphics.setColor(55,55,55, 100)
    love.graphics.rectangle("fill", buttonMargin + (n-1)*(buttonSize+buttonMargin),  love.graphics.getHeight() - buttonSize - buttonMargin, buttonSize, buttonSize)

    local scale = 1/(img:getHeight()/buttonInnerSize)

    offsetx =  - (buttonSize/scale - img:getWidth())/2

    local alpha
    if M.buttons[n].hover == true or M.selectedTurretType == n then
        alpha = 255
    else
        alpha = 200
    end
    love.graphics.setColor(255,255,255,alpha)
    love.graphics.draw(img, buttonMargin + (n-1)*(buttonSize+buttonMargin),  love.graphics.getHeight() - buttonSize - buttonMargin + buttonPadding, 0, scale, scale, offsetx, 0)
end
function drawBurek()
    love.graphics.setColor(255, 255, 255, burek.holylight.alphaBack)
    love.graphics.draw(burek.holylight.img, (map.map.width-1)*chunkW + burek.holylight.offsetx,
    (2)*chunkH + burek.holylight.backoffsety, 0, burek.holylight.scalex, burek.holylight.scaley)

    love.graphics.setColor(255,255,255, 255)
    love.graphics.draw(burek.img, (map.map.width-1)*chunkW + burek.offsetx,
    (2)*chunkH + burek.offsety, 0, burek.scalex, burek.scaley)

    love.graphics.setColor(255, 255, 100, burek.holylight.alphaFront)
    love.graphics.draw(burek.holylight.img, (map.map.width-1)*chunkW + burek.holylight.offsetx,
    (2)*chunkH + burek.holylight.offsety, 0, burek.holylight.scalex, burek.holylight.scaley)

    --draw hp
    local hpBarAbove = 5
    local hpBarWidth = 100
    local hpPercent = burek.hp / burek.fullHp
    local x = (burek.posx-1)*chunkW + burek.offsetx
    local y = burek.posy*1.9*chunkH + burek.offsety
    love.graphics.setColor(255*(1-hpPercent), 255*hpPercent, 0)
    love.graphics.line(x, y + hpBarAbove, x + hpBarWidth * hpPercent, y+ hpBarAbove)
end

function drawTopBar()
    love.graphics.setColor(M.color.r, M.color.g, M.color.b, M.color.a)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), M.topBarHeight)

    local scale = 1/(goldIcon:getHeight()/M.topBarHeight)
    love.graphics.draw(goldIcon, 0 , 0 , 0, scale, scale, 0, 0)
    love.graphics.setColor(155,155,0)
    love.graphics.setNewFont(35)
    love.graphics.print(tostring(M.gold), 50 , 5, 0 )

    drawBurek()

end

function drawBottomBar()
    love.graphics.setColor(M.color.r, M.color.g, M.color.b, M.color.a)
    love.graphics.rectangle("fill", 0, love.graphics.getHeight() - M.bottomBarHeight, love.graphics.getWidth(), M.bottomBarHeight)
end

function M.draw()
    drawTopBar()
    drawBottomBar()
    for i,_ in pairs(M.buttons) do
        drawButton(i,M.buttons[i].img)
    end
end

function M.mouseMoved(x, y)
    mouseX, mouseY = x, y
    isy = mouseY > love.graphics.getHeight() - buttonSize - buttonMargin and mouseY < love.graphics.getHeight() - buttonMargin
    for i=1, buttonNum do
        isx = mouseX > buttonMargin + (i-1)*(buttonSize+buttonMargin) and mouseX < (i)*(buttonSize+buttonMargin)
        if isx and isy then
            M.buttons[i].hover = true
        else
            M.buttons[i].hover = false
        end
    end
end

function M.mousePressed(x, y, button)
    mouseX, mouseY = x, y
    isy = mouseY > love.graphics.getHeight() - buttonSize - buttonMargin and mouseY < love.graphics.getHeight() - buttonMargin
    for i=1, buttonNum do
        isx = mouseX > buttonMargin + (i-1)*(buttonSize+buttonMargin) and mouseX < (i)*(buttonSize+buttonMargin)

        if isx and isy then
            M.buttons[i].hover = true
            local leftClick = button == 1
            if leftClick == true then
                M.selectedTurretType = i
            end
        else
            M.buttons[i].hover = false
        end
    end

    --ako je kliknuto na enemy
    if M.selectedTurretType == buttonNum then
        enemy.spawnTimeDelta = 0.4
        -- function try()--ovo samo da fix da ne moze spam dugme, kad mogu da idu
    	-- 	astar.calculatePath(creep, 1,19)
    	-- end
        astar.init(map, 1, 19)
        --astar.print()
        local status, err = pcall(try)
        --print()
        --astar.print()
        --print()
        if status and map.canBuild then--ovo je retardirano, prvi put udje ovde iako ne treba
            enemy.spawnCreepWave(totalTime, enemy.waveSize)
            enemy.updateWaveSize()
        else
            --ignore
            print(("ignoring spawn"))
        end

        M.selectedTurretType = 0
    end
end

return M
