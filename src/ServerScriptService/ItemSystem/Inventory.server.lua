local ReplicatedFirst = game:GetService("ReplicatedFirst")

local BridgeNet2 = require(ReplicatedFirst.Packages.BridgeNet2)
local ItemAdded, ItemRemoved = BridgeNet2.ServerBridge("ItemAdded"),BridgeNet2.ServerBridge("ItemRemoved")

type Pocket = {[number]: false | {Name: string}}

local OnPocket = {};

local function CheckSlotsAvailable(Pocket: Pocket): ()
    local Available: {number} = {};

    for Index: number,Value in Pocket do
        if Value == false then
            table.insert(Available,Index)
        end
    end

    return Available
end

local function OnItemAdded(Player: Player, Item: Tool): ()
    if not OnPocket[Player] then
        OnPocket[Player] = table.create(6,false);
    end

    local Available = CheckSlotsAvailable(OnPocket[Player])
    if Available == 0 then
        Item:Destroy()

        return -1
    else
        local AvailablePocket: number = Available[1]

        local ItemName: string = Item.Name
        Item:SetAttribute("Name", ItemName)
        Item.Name = "Pocket="..AvailablePocket

        OnPocket[Player][AvailablePocket] = ItemName

        return AvailablePocket
    end
end

local function OnItemRemoved(Player: Player, Item: Tool): ()

end

ItemAdded.OnServerInvoke = OnItemAdded
ItemRemoved:Connect(OnItemRemoved)