local ServerStorage = game:GetService("ServerStorage")

local DroppableItems = ServerStorage:WaitForChild("DroppableItems")

local Item = {}
Item.__index = Item

local Items: Model = Instance.new("Model")
Items.Name = "Items"
Items.Parent = workspace

export type Item = {
     Destroy: (self: Item)->()
}

function Item.new(Type: string, Name: string, Position: CFrame): Item
    local Storage: Instance? = DroppableItems:FindFirstChild(Type)
    if Storage then
        local Model: Model? = Storage:FindFirstChild(Name, true) :: Model?
        if Model then
            local self: any = {
                Model = Model:Clone()
            }

            local Prompt: ProximityPrompt = Instance.new("ProximityPrompt")
            Prompt.ActionText = "Pick"
            Prompt.Style = Enum.ProximityPromptStyle.Custom
            Prompt.HoldDuration = 2
            Prompt.Enabled = true
            Prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
            Prompt.KeyboardKeyCode = Enum.KeyCode.E
            Prompt.MaxActivationDistance = 10

            local ObjectValue = Instance.new("ObjectValue")
            ObjectValue.Name = "ItemInstance"
            ObjectValue.Value = self.Model
            ObjectValue.Parent = Prompt

            Prompt:SetAttribute("ItemName", Name)
            Prompt:SetAttribute("ItemType", Type)

            Prompt.Parent = self.Model.PrimaryPart

            self.Model:PivotTo(Position)
            print("dropping",self.Model)
            self.Model.Parent = Items

            return setmetatable(self,Item) :: Item
        end
    end

    return setmetatable({}, Item) :: any
end

function Item:Destroy(): ()
    if self.Model then
        self.Model:Destroy()
    end
    
    table.clear(self)
end

return Item