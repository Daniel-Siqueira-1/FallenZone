local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Building = require(ReplicatedStorage.Classes.Building)
local CurrentBuilding: Building.Building?;

local function Preview(): ()
    if CurrentBuilding then
        CurrentBuilding:Cancel()
    end

    CurrentBuilding = Building.new(Players.LocalPlayer:GetAttribute("Build"))
end

local function Build(Input: InputObject, IsProcessed: boolean): ()
    if IsProcessed then
        return
    end

    if Input.UserInputType == Enum.UserInputType.MouseButton1 and CurrentBuilding then
        CurrentBuilding:Place()
    end
end

Players.LocalPlayer:SetAttribute("Build", "")
Players.LocalPlayer:GetAttributeChangedSignal("Build"):Connect(Preview)

UserInputService.InputEnded:Connect(Build)