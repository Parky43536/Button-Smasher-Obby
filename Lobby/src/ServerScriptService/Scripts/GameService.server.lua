local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)

local Assets = ReplicatedStorage.Assets

local DataBase = ReplicatedStorage.Database
local LevelData = require(DataBase.LevelData)

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility:WaitForChild("General"))

local function SetUpSpawn(levelNum, level)
    level.Spawn.Touched:Connect(function(hit)
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	    if player then
            if DataManager:SetSpawn(player, levelNum) then

            end
        end
    end)
end

local function SetUpButton(levelNum, level)

end

local function SetUpGame()
    for levelNum, levelData in pairs(LevelData) do
        local level = Assets.Level:Clone()
        level.Name = "Level" .. levelNum
        level:PivotTo(CFrame.new(0, 0, -40 * (levelNum - 1)))

        for _, part in pairs(level:GetDescendants()) do
            if CollectionService:HasTag(part, "Color1") then
                part.Color = levelData.Color1
            elseif CollectionService:HasTag(part, "Color2") then
                part.Color = levelData.Color2
            elseif CollectionService:HasTag(part, "Color3") then
                part.Color = levelData.Color3--:Lerp(levelData.Color1, 0.25)
            end
        end

        SetUpButton(levelNum, level)
        SetUpSpawn(levelNum, level)

        level.Parent = workspace.Levels
    end
end

SetUpGame()

