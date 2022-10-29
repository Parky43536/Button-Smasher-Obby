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
local EventService = require(Utility.EventService)

local GameService = {}

local levels = {}
local autoClicker = {}

local function comma_value(amount)
    local formatted = amount
    while true do
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

function GameService.PressButton(levelNum, level, player, args)
    if not args then args = {} end
    if not args.power then args.power = PlayerValues:GetValue(player, "Power") end

    if not levels[levelNum].LastPress[player] then
        levels[levelNum].LastPress[player] = tick() - General.PressedCooldown
    end
    if args.auto or tick() - levels[levelNum].LastPress[player] > General.PressedCooldown then
        levels[levelNum].LastPress[player] = tick()

        if General.playerCheck(player) and levels[levelNum].Presses > 0 then
            LevelService.PressButton(level.Floor.Button.Button)
            LevelService.ButtonEvent(levelNum, level, player)

            levels[levelNum].Presses = math.clamp(levels[levelNum].Presses - args.power, 0, 99e99)
            level.Floor.Button.Button.Top.Label.Text = comma_value(levels[levelNum].Presses)

            if levels[levelNum].Presses == 0 then
                task.spawn(function()
                    LevelService.OpenDoors(level)
                    levels[levelNum].DoorOpened = true

                    task.wait(General.DoorTime)

                    levels[levelNum].DoorOpened = false
                    levels[levelNum].Presses = General.PressesCalc(levelNum)
                    level.Floor.Button.Button.Top.Label.Text = comma_value(levels[levelNum].Presses)
                end)
            end
        end
    end
end

function GameService.SetUpButton(levelNum, level)
    level.Floor.Button.Button.ClickDetector.MouseClick:connect(function(player)
        GameService.PressButton(levelNum, level, player)

        if autoClicker[player] ~= levelNum then autoClicker[player] = nil end
        if not autoClicker[player] then
            autoClicker[player] = levelNum

            while autoClicker[player] == levelNum and General.playerCheck(player) do
                if PlayerValues:GetValue(player, "AClick") > 0 then
                    GameService.PressButton(levelNum, level, player, {auto = true, power = PlayerValues:GetValue(player, "Power") * PlayerValues:GetValue(player, "AClick")})
                end

                task.wait(1)
            end

            if autoClicker[player] == levelNum then autoClicker[player] = nil end
        end
    end)
end

function GameService.SetUpSpawn(levelNum, level)
    level.Door.Checkpoint.Touched:Connect(function(hit)
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	    if player and levels[levelNum].DoorOpened then
            DataManager:SetSpawn(player, levelNum + 1)
        end
    end)
end

function GameService.SetUpGame()
    local lastCFrame = CFrame.new(0, 0, 0)
    for levelNum = 1 , General.Levels do
        levels[levelNum] = {Presses = General.PressesCalc(levelNum), LastPress = {}, DoorOpened = false}

        local level = Assets.Levels.Level:Clone()
        local cframe, size = EventService.getBoundingBox(level)
        level.Name = levelNum
        level:PivotTo(lastCFrame)
        lastCFrame = level:GetPivot() + Vector3.new(0, 0, -size.Z)

        level.Door.Level.Front.Label.Text = levelNum
        level.Door.Level.Back.Label.Text = levelNum
        level.Floor.Button.Button.Top.Label.Text = comma_value(levels[levelNum].Presses)

        if General.Signs[levelNum] then
            level.Door.Sign.Top.Label.Text = General.Signs[levelNum]
        else
            level.Door.Sign:Destroy()
        end

        GameService.SetUpButton(levelNum, level)
        GameService.SetUpSpawn(levelNum, level)
        LevelService.SetUpLevelColor(levelNum, level)

        level.Parent = workspace.Levels
    end
end

return GameService

