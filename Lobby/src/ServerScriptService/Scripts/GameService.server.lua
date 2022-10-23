local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)

local SerScripts = ServerScriptService.Scripts
local VisualService = require(SerScripts.VisualService)

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local TweenService = require(Utility.TweenService)

local levels = {}

local function SetUpSpawn(levelNum, level)
    level.Checkpoint.Touched:Connect(function(hit)
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	    if player and levels[levelNum].DoorOpened then
            DataManager:SetSpawn(player, levelNum + 1)
        end
    end)
end

local function SetUpButton(levelNum, level)
    local button = level.Button

    button.ClickDetector.MouseClick:connect(function(player)
        if not levels[levelNum].LastPress[player] then
            levels[levelNum].LastPress[player] = tick() - General.PressedCooldown
        end
        if tick() - levels[levelNum].LastPress[player] > General.PressedCooldown then
            levels[levelNum].LastPress[player] = tick()

            if levels[levelNum].Presses > 0 then
                VisualService.PressButton(button)

                levels[levelNum].Presses = math.clamp(levels[levelNum].Presses - PlayerValues:GetValue(player, "Power"), 0, 99e99)
                button.Top.Label.Text = levels[levelNum].Presses

                if levels[levelNum].Presses == 0 then
                    VisualService.OpenDoors(level)
                    levels[levelNum].DoorOpened = true

                    task.wait(General.DoorTime)

                    levels[levelNum].DoorOpened = false
                    levels[levelNum].Presses = General.PressesCalc(levelNum)
                    button.Top.Label.Text = levels[levelNum].Presses
                end
            end
        end
    end)
end

local function SetUpGame()
    for levelNum = 1 , General.Levels do
        levels[levelNum] = {Presses = General.PressesCalc(levelNum), LastPress = {}, DoorOpened = false}

        local level = Assets.Level:Clone()
        level.Name = levelNum
        level:PivotTo(CFrame.new(0, 0, -General.FloorSize * (levelNum - 1)))

        level.Sign.Front.Label.Text = levelNum
        level.Sign.Back.Label.Text = levelNum
        level.Button.Top.Label.Text = levels[levelNum].Presses

        SetUpSpawn(levelNum, level)
        SetUpButton(levelNum, level)
        VisualService.SetUpLevelColor(levelNum, level)

        level.Parent = workspace.Levels
    end
end

SetUpGame()

