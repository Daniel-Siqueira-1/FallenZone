local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local UserInputService = game:GetService("UserInputService")

local ToolSystem = require(script.Parent)
local BackpackCodes = require(ReplicatedFirst.BackpackCodes)
local Janitor = require(ReplicatedFirst.Packages.Janitor)

local Player: Player = Players.LocalPlayer
local Backpack = Player.Backpack
local PlayerGui = Player.PlayerGui
local Character: Model = Player.Character :: Model
local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

local Inventory: ScreenGui = PlayerGui:WaitForChild("Inventory") :: ScreenGui
local Pocket: Frame = Inventory:WaitForChild("Pocket") :: Frame

local Connections = Janitor.new()

local function OnInputEnded(Input: InputObject, IsProcessed: boolean): ()
    if IsProcessed then
        return
    end

	local Index: number? = table.find(BackpackCodes, Input.KeyCode)
	if Index then
		local Slot: ImageButton? = Pocket:FindFirstChild(tostring(Index)) :: ImageButton?
		if Slot then
			local Tool: Instance? = Backpack:FindFirstChild("Pocket="..Index)
			if Tool then
				if Tool:IsA('Tool') and Humanoid.Health > 0 and Tool:FindFirstChild("Settings") then
					if not Humanoid.Sit and not Humanoid.SeatPart then
						if not ToolSystem.Equipped.Model then
							ToolSystem:Equip(Tool)

						elseif ToolSystem.Equipped.Model then
							local ToolBeingUnequipped = ToolSystem.Equipped.Tool
							ToolSystem:Unequip()
							if ToolBeingUnequipped ~= Tool then
								ToolSystem:Equip(Tool)
							end
						end
					end
				end
			end
		end
	end
end

local function OnBackpackAdded(Tool: Tool): ()
	print("Tool", Tool, "added")
	print("Tool:IsA('Tool') -",Tool:IsA('Tool'),"| Humanoid.Health > 0 -", Humanoid.Health > 0, "| not ToolSyste.Equipped -", not ToolSystem.Equipped.Model," | Tool:FindFirstChild('Settings') ~= nil -",Tool:FindFirstChild("Settings") ~= nil) 
	if Tool:IsA('Tool') and Humanoid.Health > 0 and not ToolSystem.Equipped.Model and Tool:FindFirstChild("Settings") ~= nil then
		if not Humanoid.Sit and not Humanoid.SeatPart then
			ToolSystem:Equip(Tool)
		end;
	end
end

local function OnBackpackRemoved(Tool: Tool): ()
	if Tool == ToolSystem.Equipped.Tool then
		ToolSystem:Unequip()
	end
end

local function OnDied(): ()
    Connections:Cleanup()
end

Connections:Add(Backpack.ChildAdded:Connect(OnBackpackAdded))
Connections:Add(Backpack.ChildRemoved:Connect(OnBackpackRemoved))
Connections:Add(UserInputService.InputEnded:Connect(OnInputEnded))

Humanoid.Died:Connect(OnDied)