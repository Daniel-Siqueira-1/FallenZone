local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Item = require(ServerScriptService.Classes.Item)
local BridgeNet2 = require(ReplicatedFirst.Packages.BridgeNet2)
local PickItemEvent = BridgeNet2.ServerBridge("PickItem")

local Items = ServerStorage:WaitForChild("Items")

Item.new("Weapon", "Stone Axe", CFrame.new(20,20,0))
Item.new("Weapon", "HK33", CFrame.new(0,20,0))
Item.new("Weapon", "USP", CFrame.new(15,20,5))
Item.new("Weapon", "Knife", CFrame.new(10,20,0))

local function OnPickItemRequest(Player: Player, Prompt: ProximityPrompt): ()
    local Character: Model? = Player.Character
    if Character and Prompt then
        local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
        local Root: BasePart = Character:WaitForChild("HumanoidRootPart") :: BasePart
        if Humanoid and Humanoid.Health > 0 then
            local ItemInstance: ObjectValue = Prompt:FindFirstChild("ItemInstance") :: ObjectValue
            local ItemDropped: Model? = ItemInstance.Value :: Model?

            if ItemDropped and (Root.Position - ItemDropped:GetPivot().Position).Magnitude <= Prompt.MaxActivationDistance then
                local ItemName = Prompt:GetAttribute("ItemName")
                local ItemType = Prompt:GetAttribute("ItemType")
                ItemDropped:Destroy()

                local Storage: Instance? = Items:FindFirstChild(ItemType)
                if Storage then
                    local Item: Instance? = Storage:FindFirstChild(ItemName)
                    if Item then
                        Item:Clone().Parent = Player.Backpack
                    end
                end
            end
        end
    end
end

PickItemEvent:Connect(OnPickItemRequest)