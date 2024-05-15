local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedFirst.Packages.BridgeNet2)

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Building = {}
Building.__index = Building

type ClientBridge<send,receive> = BridgeNet2.ClientBridge<send, receive>
export type Building = {
    Model: Model;

    Place: (self: Building)->();
    Cancel: (self: Building)->();
}

local Buildings: Folder = ReplicatedStorage:WaitForChild("Buildings")
local PlaceBuilding: ClientBridge<any, any> = BridgeNet2.ClientBridge("PlaceBuilding")

function Building.new(Name: string): Building
    local Model: Model? = Buildings:FindFirstChild(Name, true) :: Model?
    if Model then
        local self: any = {
            Name = Name;
            Model = Model:Clone();
        };

        for _, Part: Instance in self.Model:GetDescendants() do
            if Part:IsA("BasePart") then
                if Part:IsA("MeshPart") then
                    Part.TextureID = ""
                end

                Part.CanCollide = false
                Part.CanTouch = false
            elseif Part:IsA("SurfaceAppearance") then
                Part:Destroy()
            end
        end

        self.Model:AddTag("PlacementPreview")
        self.Model:AddTag("Previewable")
        self.Model:SetAttribute("BuildingType", (Model.Parent :: Folder).Name)
        self.Model.Parent = workspace

        return setmetatable(self, Building) :: Building
    end

    return setmetatable({}, Building) :: any
end

function Building:Place(): ()
    local Position: CFrame = self.Model:GetPivot()
    local Type: string = self.Model:GetAttribute("BuildingType")

    PlaceBuilding:Fire({
        Type = Type;
        Name = self.Name;
        Position = Position;
        Mouse = {Hit=Mouse.Hit;Target=Mouse.Target};
    })

    Player:SetAttribute("Build", "")
    self:Cancel()
end

function Building:Cancel(): ()
    if self.Model then
        self.Model:RemoveTag("PlacementPreview")
        Debris:AddItem(self.Model,0)
    end

    table.clear(self)
end

return Building