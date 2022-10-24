local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Assets = ReplicatedStorage.Assets

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local SideFrame = PlayerUi:WaitForChild("SideFrame")
local LevelsUi = PlayerGui:WaitForChild("LevelsUi")
local ShopUi = PlayerGui:WaitForChild("ShopUi")
local Levels = LevelsUi.LevelsFrame.ScrollingFrame

local function levelsUiEnable()
    if LevelsUi.Enabled == true then
        LevelsUi.Enabled = false
    else
        LevelsUi.Enabled = true
        ShopUi.Enabled = false
    end
end

SideFrame.Levels.Activated:Connect(function()
    levelsUiEnable()
end)

LevelsUi.LevelsFrame.TopFrame.Close.Activated:Connect(function()
    levelsUiEnable()
end)

local function onKeyPress(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.X and gameProcessedEvent == false then
		levelsUiEnable()
	end
end

------------------------------------------------------------------

local function levelsUi()
    local currentLevel = PlayerValues:GetValue(LocalPlayer, "Level")

    for levelNum = 1 , General.Levels do
        if not Levels:FindFirstChild(levelNum) then
            local level = Assets.Ui.Level:Clone()
            level.Name = levelNum
            level.Text = levelNum
            level.Parent = Levels

            level.Activated:Connect(function()
                local character = LocalPlayer.Character
                if character and character.Parent ~= nil then
                    character:PivotTo(workspace.Levels[levelNum].Spawn.CFrame)
                end
            end)
        end
    end
end

levelsUi()

PlayerValues:SetCallback("Level", function()
    levelsUi()
end)

UserInputService.InputBegan:Connect(onKeyPress)

