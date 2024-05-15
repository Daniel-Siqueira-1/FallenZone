local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Models = ReplicatedStorage:WaitForChild("Items")

local BridgeNet2 = require(ReplicatedFirst.Packages.BridgeNet2)
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Inventory = PlayerGui:WaitForChild("Inventory")
local Pocket = Inventory:WaitForChild("Pocket")

local ItemAdded, ItemRemoved = BridgeNet2.ClientBridge("ItemAdded"),BridgeNet2.ClientBridge("ItemRemoved")

local PocketData = {};

local function InsertItemToSlot(Item: Model, Slot: ImageButton): ()
    Slot:SetAttribute("Current", Item.Name)
    local SlotUIView: ViewportFrame = Slot:WaitForChild("ViewportFrame") :: ViewportFrame

    local Camera = Instance.new("Camera")
    Camera.Parent = SlotUIView
    SlotUIView.CurrentCamera = Camera
    
    local CameraCF: CFrame = Camera.CFrame
    local Box: Vector3 = Item:GetBoundingBox().Position
    local Pivot: CFrame = Item:GetPivot()

    local OffsetFromCenter: Vector3 = Pivot.Position - Box

    Item:PivotTo(CameraCF * CFrame.new(-.1,-.1,-1.3) + OffsetFromCenter)
    Item.Parent = SlotUIView
end

local function OnItemAdded(Item: Tool): ()
    local Name: string = Item.Name
    local Slot = ItemAdded:InvokeServerAsync(Item)
    local SlotUI: ImageButton? = Pocket:FindFirstChild(Slot)
    if SlotUI then
        local Model: Model? = Models:FindFirstChild(Name)
        if Model then
            Model = Model:Clone()
            Model.Name = Name
            InsertItemToSlot(Model, SlotUI)
        end
    end
end

local function OnItemRemoved(Item: Tool): ()
    
end

Player.Backpack.ChildAdded:Connect(OnItemAdded)
Player.Backpack.ChildRemoved:Connect(OnItemRemoved)
