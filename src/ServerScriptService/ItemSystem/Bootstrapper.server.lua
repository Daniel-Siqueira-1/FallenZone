local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local BridgeNet2 = require(ReplicatedFirst.Packages.BridgeNet2)
local Server = require(ReplicatedFirst.Packages.Reliability.Server)
local Item = BridgeNet2.ServerBridge("EquipItem")
local Item = BridgeNet2.ServerBridge("ItemAdded")
local Item = BridgeNet2.ServerBridge("ItemRemoved")
local Item = BridgeNet2.ServerBridge("ChangeStance")
local Item = BridgeNet2.ServerBridge("GunShoot")
local ToolStateChanged = BridgeNet2.ServerBridge("ToolStateChanged")

local Models = ReplicatedStorage:WaitForChild("Items")
local ToolConfigs = ServerStorage:WaitForChild("Items")

local ToolInformation = {};

local function OnUnequip(Player: Player): ()
    local Character: Model = Player.Character :: Model
    ToolInformation[Player].CurrentTool:Destroy()
    ToolInformation[Player].CurrentTool = nil

    local Torso: BasePart? = Character:FindFirstChild('Torso') :: BasePart?
    if Torso then
       local RightShoulder: Motor6D? = Torso:FindFirstChild("Right Shoulder") :: Motor6D?
        local LeftShoulder: Motor6D? = Torso:FindFirstChild("Left Shoulder") :: Motor6D?

        if RightShoulder and LeftShoulder then
            RightShoulder.Enabled = true
            LeftShoulder.Enabled = true
        end
    end
end

local function OnEquip(Player: Player, Tool: Tool): ()
    local Character: Model = Player.Character :: Model

    if not ToolInformation[Player] then
        ToolInformation[Player] = {}
    end

    if ToolInformation[Player].CurrentTool then
        return
    end

    if Tool.Parent ~= Player.Backpack then 
        return
    end

    local ToolName = Tool:GetAttribute("Name") or Tool.Name
    local ToolConfiguration = ToolConfigs:FindFirstChild(ToolName,true)

    local Animations = require(ToolConfiguration:WaitForChild("Animations"))

    local Head = Character:FindFirstChild('Head')
	local Torso = Character:FindFirstChild('Torso')
	local LeftArm = Character:FindFirstChild('Left Arm')
	local RightArm = Character:FindFirstChild('Right Arm')

	local RightShoulder: Motor6D? = Torso:FindFirstChild("Right Shoulder")
	local LeftShoulder: Motor6D? = Torso:FindFirstChild("Left Shoulder")

	local ToolModel: Model = Models:FindFirstChild(ToolName) :: Model
	if ToolModel and LeftShoulder and RightShoulder then
        local ServerTool: Model = ToolModel:Clone() :: Model
        ServerTool.Name = ToolName

        local AnimBase = Instance.new("Part")
        AnimBase.FormFactor = "Custom"
        AnimBase.CanCollide = false
        AnimBase.Transparency = 1
        AnimBase.Anchored = false
        AnimBase.Name = "AnimBase"
        AnimBase.Size = Vector3.new(0.1, 0.1, 0.1)

        local AnimBaseW = Instance.new("Motor6D")
        AnimBaseW.Part0 = Head
        AnimBaseW.Part1 = AnimBase
        AnimBaseW.Parent = AnimBase
        AnimBaseW.Name = "AnimBaseW"

        local ruaw: Motor6D = Instance.new("Motor6D")
        ruaw.Name = "RAW"
        ruaw.Part0 = RightArm
        ruaw.Part1 = AnimBase
        ruaw.Parent = AnimBase
        ruaw.C0 = Animations.SV_RightArmPos
        RightShoulder.Enabled = false

        local luaw: Motor6D = Instance.new("Motor6D")
        luaw.Name = "LAW"
        luaw.Part0 = LeftArm
        luaw.Part1 = AnimBase
        luaw.Parent = AnimBase
        luaw.C0 = Animations.SV_LeftArmPos
        LeftShoulder.Enabled = false

        local Handle: BasePart? = ServerTool:FindFirstChild("Handle") :: BasePart?
        if Handle then
            local SKP_004: Motor6D = Instance.new('Motor6D')
            SKP_004.Name = 'Handle'
            SKP_004.Parent = Handle
            SKP_004.Part0 = RightArm
            SKP_004.Part1 = Handle
            SKP_004.C1 = Animations.SV_GunPos:Inverse()
        end

        ToolInformation[Player].CurrentTool = ServerTool

        AnimBase.Parent = Character
        ServerTool.Parent = Character
    end
end

local function OnToolStateChanged(Player: Player, Data: {State: string,Info: any}): ()
    if Player.Character then
        if Data.State == "Equip" then
            OnEquip(Player, Data.Info)
        elseif Data.State == "Unequip" then
            OnUnequip(Player)
        end
    end
end

ToolStateChanged:Connect(OnToolStateChanged)