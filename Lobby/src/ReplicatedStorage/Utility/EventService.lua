local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local EventService = {}

--Variables---------------------------------------------

EventService.TouchCooldown = 1

--Functions---------------------------------------------

function EventService.randomLevelPoint(level, offset)
    local rng = Random.new()
    local floor = level.Floor
    if not offset then offset = 2 end

    local x = floor.Position.X + rng:NextInteger((-floor.Size.X/2) + offset, (floor.Size.X/2) - offset)
    local z = floor.Position.Z + rng:NextInteger((-floor.Size.Z/2) + offset, (floor.Size.Z/2) - offset)
    local pos = Vector3.new(x, 10, z)

    local RayOrigin = pos
    local RayDirection = Vector3.new(0, -100, 0)

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Whitelist
    Params.FilterDescendantsInstances = {floor}

    local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
    return Result
end

function EventService.getPlayersInRadius(position, radius)
    local currentPlayers = Players:GetChildren()
    local playersInRadius = {}

    for _,player in pairs(currentPlayers) do
        if General.playerCheck(player) then
            if (player.Character.PrimaryPart.Position - position).Magnitude <= radius then
                table.insert(playersInRadius, player)
            end
        end
    end

    return playersInRadius
end

return EventService