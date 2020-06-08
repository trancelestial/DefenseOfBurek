local M={}

M.path = {}
M.nodes = {}
M.heap = {}
M.maxDist = 100000

function copy (t)
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do target[k] = v end
    setmetatable(target, meta)
    return target
end
-- u mainu kao parametar map
function M.init(map, endX, endY)
	for i=1, map.map.height do
		M.nodes[i] = {}
		for j=1, map.map.width do
			M.nodes[i][j]=copy(map.map[j][i])
    --   io.write(M.nodes[i][j].val)
    --   io.write(" ")
		end
    -- print()
	end
	M.nodes.height = map.map.height
	M.nodes.width = map.map.width
	--M.nodes = copy(map.map)
	for i=1, M.nodes.height do
		for j=1, M.nodes.width do
			M.nodes[i][j].dist = M.maxDist
		end
	end
	M.walkable = map.const.empty
	heuristic(endX, endY)
end

function M.print()
	for i=1, M.nodes.height do
		for j=1, M.nodes.width do
			io.write(M.nodes[i][j].h+M.nodes[i][j].dist)
			io.write(" ")
		end
		print()
	end
end

function heuristic(endX, endY)
	for i=1, M.nodes.height do
        for j=1, M.nodes.width do
			if M.nodes[i][j].val == M.walkable then
				M.nodes[i][j].h = math.abs(endX - i) + math.abs(endY - j)
			else
				M.nodes[i][j].h = -1;
			end
		end
    end
end

function neighbours(x, y)
	local nNodes = {}
	local i = 1
	if x-1 >= 1 then
		if M.nodes[x-1][y].val == M.walkable then
			--print("usao")
			nNodes[i] = {}
			nNodes[i].x = x-1
			nNodes[i].y = y
			nNodes[i].h = M.nodes[x-1][y].h
			nNodes[i].parentX = x
			nNodes[i].parentY = y
			nNodes[i].dist = M.nodes[x-1][y].dist
      nNodes[i].val = M.nodes[x-1][y].val
			i = i+1
		end
	end
	if y-1 >= 1 then
		if M.nodes[x][y-1].val == M.walkable then
			nNodes[i] = {}
			nNodes[i].x = x
			nNodes[i].y = y-1
			nNodes[i].h = M.nodes[x][y-1].h
			nNodes[i].parentX = x
			nNodes[i].parentY = y
			nNodes[i].dist = M.nodes[x][y-1].dist
      nNodes[i].val = M.nodes[x][y-1].val
			i = i+1
		end
	end
	if x+1 <= M.nodes.height then
		if M.nodes[x+1][y].val == M.walkable then
			nNodes[i] = {}
			nNodes[i].x = x+1
			nNodes[i].y = y
			nNodes[i].h = M.nodes[x+1][y].h
			nNodes[i].parentX = x
			nNodes[i].parentY = y
			nNodes[i].dist = M.nodes[x+1][y].dist
      nNodes[i].val = M.nodes[x+1][y].val
			i = i+1
		end
	end
	if y+1 <= M.nodes.width then
		if M.nodes[x][y+1].val == M.walkable then
			nNodes[i] = {}
			nNodes[i].x = x
			nNodes[i].y = y+1
			nNodes[i].h = M.nodes[x][y+1].h
			nNodes[i].parentX = x
			nNodes[i].parentY = y
			nNodes[i].dist = M.nodes[x][y+1].dist
      nNodes[i].val = M.nodes[x][y+1].val
			i = i+1
		end
	end

	return nNodes
end


function insertHeap(list, n, element)
	n = n+1
	list[n] = copy(element)
	local p={}
	local i = n
	while i > 1 do
		--io.write(("INSERT I = %d \n"):format(i))
		i2 = math.floor(i/2)
        eq = math.random()<=.5
		if list[i].h + list[i].dist > list[i2].h + list[i2].dist or
           (list[i].h + list[i].dist == list[i2].h + list[i2].dist and eq)  then
            break
		end
		p = copy(list[i])
		list[i] = copy(list[i2])
		list[i2] = copy(p)
		p = nil
		i = i2
	end

	return n
end



function popHeap(list, n)
	local p={}
	local i = 1
	list[1] = copy(list[n])
	list[n] = nil
	n = n-1
	while i <= math.floor(n/2) do
		--print("vrti!")
		if list[i].h + list[i].dist <= list[i*2].h + list[i*2].dist then --and list[i].h <= list[i*2+1].h then
			if i*2+1 <= n then
				if list[i].h + list[i].dist <= list[i*2+1].h + list[i*2+1].dist then
					break
				else
					p = copy(list[i])
					list[i] = copy(list[i*2+1])
					list[i*2+1] = copy(p)
					p = nil
					i = i*2+1
				end
			else
				break
			end
		else --i*2+1 <= n then
			if i*2+1 <= n then
				if list[i*2].h + list[i*2].dist < list[i*2+1].h + list[i*2+1].dist then
					p = copy(list[i])
					list[i] = copy(list[i*2])
					list[i*2] = copy(p)
					p = nil
					i = i*2
				else
					p = copy(list[i])
					list[i] = copy(list[i*2+1])
					list[i*2+1] = copy(p)
					p = nil
					i = i*2+1
				end
			else
				p = copy(list[i])
				list[i] = copy(list[i*2])
				list[i*2] = copy(p)
				p = nil
				i = i*2
			end
		end
	end

	return n
end

function inHeap(list, element)
	for k, v in pairs(list) do
		if v.x == element.x and v.y == element.y then
			return k
		end
	end
	return -1
end

function M.calculatePath(creep, endX, endY)
	local closedList = {}
	local currentList = {}
	local i, p
	n=0
	for i=1, M.nodes.height do
		closedList[i] = {}
		for j=1, M.nodes.width do
			closedList[i][j] = 0
		end
	end
	node = {}
	node.x = creep.posx
	node.y = creep.posy
	node.h = M.nodes[node.x][node.y].h
	node.parentX = -1
	node.parentY = -1
	node.dist = 0
  node.val = M.nodes[node.x][node.y].val
  --M.nodes[node.x][node.y].dist = 0
	n = insertHeap(currentList, n, node)
	while currentList[1].x ~= endX or currentList[1].y ~= endY do

		node = copy(currentList[1])
		M.nodes[node.x][node.y] = copy(node)
		n = popHeap(currentList, n)

		if closedList[node.x][node.y] ~= 1 then
			closedList[node.x][node.y] = 1

			for k, v in pairs(neighbours(node.x, node.y)) do
				if closedList[v.x][v.y] ~= 1 then
					i = inHeap(currentList, v)
					if i ~= -1 then --and currentList[i].dist > M.nodes[curX][curY].dist + 1 then
						if node.dist + 1 < currentList[i].dist then--if currentList[i].dist > M.nodes[node.x][node.y].dist + 1 then
							currentList[i].dist = node.dist + 1 --M.nodes[node.x][node.x].dist + 1
							currentList[i].parentX = node.x
							currentList[i].parentY = node.y

						--rebalance
							while i > 1 do

								i2 = math.floor(i/2)
								if currentList[i].dist + currentList[i].h > currentList[i2].dist + currentList[i2].h then
									break
								end
								p = copy(currentList[i])
								currentList[i] = copy(currentList[i2])
								currentList[i2] = copy(p)
								i = i2
							end
						end
					else
						v.parentX = node.x
						v.parentY = node.y
						v.dist = node.dist + 1 --M.nodes[node.x][node.y].dist + 1
						n = insertHeap(currentList, n, v)
					end
				end
			end
		end
	end
	-- print("------------------------------------------------------------------------")
	M.nodes[endX][endY].dist = currentList[1].dist
	M.nodes[endX][endY].parentX = currentList[1].parentX
	M.nodes[endX][endY].parentY = currentList[1].parentY
	--print(("X: %d, Y: %d"):format(M.nodes[endX][endY].x, M.nodes[endX][endY].y))
	n = popHeap(currentList, n)

	path = {}
	pathR = {}
	i = 1
	pX = endX
	pY = endY
	--print(("px : %d, py : %d"):format(pX,pY))
	--pravi path
	while pX ~= creep.posx or pY ~= creep.posy do
		path[i] = {}
		path[i].x = pX
		path[i].y = pY
		pX = M.nodes[pX][pY].parentX
		pY = M.nodes[path[i].x][pY].parentY
		i = i+1
	end

-- 	for j=1, i-1 do
-- 		--print(("I : %d"):format(j))
-- 		print(("X: %d, Y: %d"):format(path[j].x, path[j].y))
-- 	end
	for j=1, i-1 do
		pathR[j] = copy(path[i-j])
		--print(("X: %d, Y: %d"):format(pathR[j].x, pathR[j].y))
	end

	pathR.len = i-1

	return pathR
end


return M
