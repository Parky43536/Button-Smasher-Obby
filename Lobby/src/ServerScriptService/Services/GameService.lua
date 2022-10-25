local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)
local LevelService = require(SerServices.LevelService)

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local TweenService = require(Utility.TweenService)

local GameService = {}

local levels = {}

function GameService.PressButton(levelNum, level, player, power)
    local button = level.Button

    if not levels[levelNum].LastPress[player] then
        levels[levelNum].LastPress[player] = tick() - General.PressedCooldown
    end
    if tick() - levels[levelNum].LastPress[player] > General.PressedCooldown then
        levels[levelNum].LastPress[player] = tick()

        if levels[levelNum].Presses > 0 then
            LevelService.PressButton(button)
            LevelService.ButtonEvent(levelNum, level, player)

            levels[levelNum].Presses = math.clamp(levels[levelNum].Presses - power, 0, 99e99)
            button.Top.Label.Text = levels[levelNum].Presses

            if levels[levelNum].Presses == 0 then
                task.spawn(function()
                    LevelService.OpenDoors(level)
                    levels[levelNum].DoorOpened = true

                    task.wait(General.DoorTime)

                    levels[levelNum].DoorOpened = false
                    levels[levelNum].Presses = General.PressesCalc(levelNum)
                    button.Top.Label.Text = levels[levelNum].Presses
                end)
            end
        end
    end
end

function GameService.SetUpSpawn(levelNum, level)
    level.Checkpoint.Touched:Connect(function(hit)
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	    if player and levels[levelNum].DoorOpened then
            DataManager:SetSpawn(player, levelNum + 1)
        end
    end)
end

function GameService.SetUpGame()
    for levelNum = 1 , General.Levels do
        levels[levelNum] = {Presses = General.PressesCalc(levelNum), LastPress = {}, DoorOpened = false}

        local level = Assets.Levels.Level:Clone()
        level.Name = levelNum
        level:PivotTo(CFrame.new(0, 0, -44 * (levelNum - 1)))

        level.Level.Front.Label.Text = levelNum
        level.Level.Back.Label.Text = levelNum
        level.Button.Top.Label.Text = levels[levelNum].Presses

        if General.Signs[levelNum] then
            level.Sign.Top.Label.Text = General.Signs[levelNum]
        else
            level.Sign:Destroy()
        end

        level.Button.ClickDetector.MouseClick:connect(function(player)
            GameService.PressButton(levelNum, level, player, PlayerValues:GetValue(player, "Power"))
        end)

        GameService.SetUpSpawn(levelNum, level)
        LevelService.SetUpLevelColor(levelNum, level)

        level.Parent = workspace.Levels
    end
end

return GameService

