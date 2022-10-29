local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local EventService = {}

--Variables---------------------------------------------

EventService.TouchCooldown = 1

--Functions---------------------------------------------

local obstacleSpawners = {}

function EventService.toggleObstacleSpawner(levelNum, obstacleSpawner, toggle)
    if not obstacleSpawners[levelNum] then obstacleSpawners[levelNum] = {} end
    obstacleSpawners[levelNum][obstacleSpawner] = toggle
end

function EventService.checkObstacleSpawner(levelNum, obstacleSpawner)
    if obstacleSpawners[levelNum] and obstacleSpawners[levelNum][obstacleSpawner] then
        return false
    end

    return true
end

function EventService.randomObstacleSpawner(levelNum, level)
    local rng = Random.new()
    local obstacleSpawnerList = {}

    for _, part in pairs(level:GetDescendants()) do
        if part.Name == "ObstacleSpawner" then
            table.insert(obstacleSpawnerList, part)
        end
    end

    local pickedSpawner
    repeat
        local num = rng:NextInteger(1, #obstacleSpawnerList)
        if EventService.checkObstacleSpawner(levelNum, obstacleSpawnerList[num]) then
            pickedSpawner = obstacleSpawnerList[num]
        else
            table.remove(obstacleSpawnerList, num)
        end
    until pickedSpawner or #obstacleSpawnerList == 0

    if pickedSpawner then
        EventService.toggleObstacleSpawner(levelNum, pickedSpawner, true)
    end

    return pickedSpawner
end

function EventService.getBoundingBox(model, orientation)
	if typeof(model) == "Instance" then
		model = model:GetDescendants()
	end
	if not orientation then
		orientation = CFrame.new()
	end
	local abs = math.abs
	local inf = math.huge

	local minx, miny, minz = inf, inf, inf
	local maxx, maxy, maxz = -inf, -inf, -inf

	for _, obj in pairs(model) do
		if obj:IsA("BasePart") then
			local cf = obj.CFrame
			cf = orientation:toObjectSpace(cf)
			local size = obj.Size
			local sx, sy, sz = size.X, size.Y, size.Z

			local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:components()

			local wsx = 0.5 * (abs(R00) * sx + abs(R01) * sy + abs(R02) * sz)
			local wsy = 0.5 * (abs(R10) * sx + abs(R11) * sy + abs(R12) * sz)
			local wsz = 0.5 * (abs(R20) * sx + abs(R21) * sy + abs(R22) * sz)

			if minx > x - wsx then
				minx = x - wsx
			end
			if miny > y - wsy then
				miny = y - wsy
			end
			if minz > z - wsz then
				minz = z - wsz
			end

			if maxx < x + wsx then
				maxx = x + wsx
			end
			if maxy < y + wsy then
				maxy = y + wsy
			end
			if maxz < z + wsz then
				maxz = z + wsz
			end
		end
	end

	local omin, omax = Vector3.new(minx, miny, minz), Vector3.new(maxx, maxy, maxz)
	local omiddle = (omax+omin)/2
	local wCf = orientation - orientation.p + orientation:pointToWorldSpace(omiddle)
	local size = (omax-omin)

    --[[local part = Instance.new("Part")
    part.CanCollide = false
    part.Transparency = 0.5
    part.Size = size
    part.CFrame = wCf
    part.Anchored = true
    part.Parent = workspace]]

	return wCf, size
end

function EventService.randomLevelPoint(level)
    local rng = Random.new()
    local cframe, size = EventService.getBoundingBox(level.Floor)

    local x = cframe.Position.X + rng:NextInteger(-size.X/2, size.X/2)
    local z = cframe.Position.Z + rng:NextInteger(-size.Z/2, size.Z/2)
    local pos = Vector3.new(x, 10, z)

    local RayOrigin = pos
    local RayDirection = Vector3.new(0, -100, 0)

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Whitelist
    Params.FilterDescendantsInstances = {level.Floor:GetChildren()}

    local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
    return Result
end

function EventService.getPlayersInRadius(position, radius, players)
    local currentPlayers = Players:GetChildren()
    local playersInRadius = {}

    for _, player in pairs(players or currentPlayers) do
        if General.playerCheck(player) then
            if (player.Character.PrimaryPart.Position - position).Magnitude <= radius then
                table.insert(playersInRadius, player)
            end
        end
    end

    return playersInRadius
end

function EventService.getPlayersInSize(cframe, size, players)
    local currentPlayers = Players:GetChildren()
    local playersInSize = {}

    for _,player in pairs(players or currentPlayers) do
        if General.playerCheck(player) then
            local relativePoint = cframe:Inverse() * player.Character.PrimaryPart.Position
            local isInsideHitbox = true
            for _,axis in ipairs{"X","Y","Z"} do
                if math.abs(relativePoint[axis]) > size[axis]/2 then
                    isInsideHitbox = false
                    break
                end
            end

            if isInsideHitbox then
                table.insert(playersInSize, player)
            end
        end
    end

    return playersInSize
end

function EventService.getClosestPlayer(position, players)
    local currentPlayers = Players:GetChildren()
    local closestPlayer

    for _, player in pairs(players or currentPlayers) do
        if General.playerCheck(player) then
            if not closestPlayer then
                closestPlayer = player
            elseif not General.playerCheck(closestPlayer) then
                closestPlayer = player
            elseif (player.Character.PrimaryPart.Position - position).Magnitude < (closestPlayer.Character.PrimaryPart.Position - position).Magnitude then
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

return EventService