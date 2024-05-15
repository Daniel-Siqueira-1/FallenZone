local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

local Player: Player = Players.LocalPlayer
local Character: Model = Player.Character :: Model
local Camera = workspace.CurrentCamera

local ActionHandler = require(StarterPlayer.StarterCharacterScripts.ToolSystem.ActionHandler)
local BridgeNet2 = require(ReplicatedFirst.Packages.BridgeNet2)
local Utils = require(ReplicatedStorage.Libraries.Utils)

local ToolStateChangedEvent = BridgeNet2.ClientBridge("ToolStateChanged")

local ViewmodelPreset = ReplicatedStorage:WaitForChild("Viewmodels"):WaitForChild("Arms")

local System = {
    Springs = {};

    Equipped = {
        Settings = {
            SlideEx = CFrame.new();
            BoltEx = CFrame.new();
            camRecoil = {};
            AimRecoilReduction = 0;
            CanFire = false;
            CanAim = false;
            Ammo = 0;
            Type = "";
        };
        Animations = {
            AimOffset = CFrame.new();
        };

        Name = "";
        Type = "";

        Model = nil;
        Tool = nil;

        Firing = false;
        Aiming = false;
    };

    Variables = {
        MainCFrame = CFrame.new();

        GunCFrame = CFrame.new();
        GunBobCFrame = CFrame.new();

        LeftArmCFrame = CFrame.new();
        RightArmCFrame = CFrame.new();

        RecoilCFrame = CFrame.new();

        SlideEx = CFrame.new();

        BSpread = 0;
        RecoilPower = 0;

        Zoom = 0;
        Zoom2 = 0;
        InfraRed = false;

        BulletSpread = 0;
    };

    Viewmodel = nil;
    Welds = {};
}

ActionHandler.ToolSystem = System

local ToolStorage = ReplicatedStorage:WaitForChild("Items")

function System:CanFire(): ()
    local Equipped = System.Equipped
    local Ammo: number = Equipped.Settings.Type == "Gun" and Equipped.Settings.Ammo or 1
    return Equipped.Model ~= nil and System.Viewmodel and Equipped.Settings.CanFire and Ammo > 0
end

function System:GetToolName(Tool: Tool): string
    if not Tool then 
        return "" 
    end

    return Tool:GetAttribute("Name") or Tool.Name
end

function System:Equip(Tool: Tool): ()
    local ToolName: string = System:GetToolName(Tool)
    local ToolModel: Model = ToolStorage:FindFirstChild(ToolName)

    if ToolModel then
        ToolModel = ToolModel:Clone()
        ToolStateChangedEvent:Fire({State = "Equip", Info = Tool})

        UserInputService.MouseIconEnabled = false
        Player.CameraMode = Enum.CameraMode.LockFirstPerson

        local ToolSettings = require(Tool:WaitForChild("Settings"))
        local ToolAnimations = require(Tool:WaitForChild("Animations"))

        System.Equipped = {
            Settings = ToolSettings;
            Animations = ToolAnimations;

            Name = ToolName;
            Type = ToolSettings.Type;

            Model = ToolModel;
            Tool = Tool;
        }

        System:SetupVariables()
        System:BuildViewmodel()
        System:BindActions(true)
        System:Animate("EquipAnim")
    end
end

function System:Unequip(): ()
    if System.Equipped.Model then
        System:BindActions(false)
        
        ToolStateChangedEvent:Fire({State = "Unequip"})

        System.Equipped.Model:Destroy()
        System.Viewmodel:Destroy()

        System.Viewmodel = nil
        System.Equipped.Model = nil
    end
end

function System:LoadAttachments(): ()
    local Item: Model = System.Equipped.Model
    local Nodes: Folder? = Item:FindFirstChild("Nodes") :: Folder?
    if Nodes then
        print("No attachments to load currently")
    end
end

function System:WeldGunParts(): ()
    local Item: Model = System.Equipped.Model
    local Handle: BasePart = Item:WaitForChild("Handle") :: BasePart

    for _, ItemPart: Instance in pairs(Item:GetChildren()) do
		if ItemPart:IsA('BasePart') and ItemPart ~= Handle then
            ItemPart.CanCollide = false
            ItemPart.Anchored = false

			if ItemPart.Name ~= "Bolt" and ItemPart.Name ~= 'Lid' and ItemPart.Name ~= "Slide" then
				Utils.Weld(Handle, ItemPart)
			end

			if ItemPart.Name == "Bolt" or ItemPart.Name == "Slide" then
				Utils.WeldComplex(Handle, ItemPart, ItemPart.Name)
			end;

			if ItemPart.Name == "Lid" then
                local LidHinge: Instance = Item:WaitForChild("LidHinge")
				if LidHinge then
					Utils.Weld(ItemPart, LidHinge)
				else
					Utils.Weld(ItemPart, Handle)
				end
			end
		end
	end;

    if Item:FindFirstChild("Nodes") then
        local Nodes: Instance? = Item:FindFirstChild("Nodes")
        if Nodes then
            for _, Node: Instance in pairs(Nodes:GetChildren()) do
                if Node:IsA('BasePart') then
                    Utils.Weld(Handle, Node)

                    Node.Anchored = false
                    Node.CanCollide = false
                end
            end
        end
	end

    Handle.CanCollide = false
    Handle.Anchored = false
end

function System:Animate(AnimationName: string): ()
    if System.Viewmodel and System.Equipped.Animations[AnimationName] then
        local Welds = System.Welds
        local Success, ErrorMessage = pcall(
            System.Equipped.Animations[AnimationName], -- Function
            {Welds.RightArmWeld,Welds.LeftArmWeld,Welds.GunWeld,System.Equipped.Model,System.Viewmodel} -- Parameters
        )

        if not Success then
            warn(ErrorMessage)
        end

        if AnimationName ~= "IdleAnim" then
            System:Animate("IdleAnim")
        end
    end
end

function System:BindActions(State: boolean): ()
    if State then
        ContextActionService:BindAction("Fire", ActionHandler.Handle, true, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
	    ContextActionService:BindAction("Reload", ActionHandler.Handle, true, Enum.KeyCode.R, Enum.KeyCode.ButtonB)
	    ContextActionService:BindAction("CycleFiremode", ActionHandler.Handle, false, Enum.KeyCode.V)
    else
        ContextActionService:UnbindAction("Fire")
	    ContextActionService:UnbindAction("Reload")
	    ContextActionService:UnbindAction("CycleFiremode")
    end
end

function System:SetupVariables(): ()
    local Animations = System.Equipped.Animations
    local ItemSettings = System.Equipped.Settings
    print(ItemSettings)
    for Index: string, _ in System.Variables :: any do
        local NewValue = ItemSettings[Index] or Animations[Index]
        if NewValue ~= nil then
            System.Variables[Index] = NewValue
        end
    end
end

function System:BuildViewmodel(): ()
    local Viewmodel: Model = ViewmodelPreset:Clone()

    local ItemModel = System.Equipped.Model

    local BodyColors: Instance? = Character:FindFirstChild("Body Colors")
    local Shirt: Instance? = Character:FindFirstChild("Shirt")

    if BodyColors then
		if BodyColors then
            BodyColors:Clone().Parent = Viewmodel
        end
	end

	if Shirt then
        if Shirt then
		    Shirt:Clone().Parent = Viewmodel
        end
	end
    
    local AnimationPart = Instance.new("Part")
	AnimationPart.Size = Vector3.new(0.1,0.1,0.1)
	AnimationPart.Anchored = true
	AnimationPart.CanCollide = false
	AnimationPart.Transparency = RunService:IsStudio() and 0.8 or 1
    AnimationPart.CFrame = Viewmodel:GetPivot()
    AnimationPart.Parent = Viewmodel

	Viewmodel.PrimaryPart = AnimationPart

	local LArmWeld: Motor6D = Instance.new("Motor6D")
	LArmWeld.Name = "LeftArm"
	LArmWeld.Part0 = AnimationPart

	local RArmWeld: Motor6D = Instance.new("Motor6D")
	RArmWeld.Name = "RightArm"
	RArmWeld.Part0 = AnimationPart

	local GunWeld: Motor6D = Instance.new("Motor6D")
	GunWeld.Name = "Handle"

    local LArm: BasePart = Viewmodel:WaitForChild("Left Arm") :: BasePart
	LArmWeld.Part1 = LArm
	LArmWeld.C0 = CFrame.new()
	LArmWeld.C1 = CFrame.new(1,-1,-5) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0)):Inverse()

	local RArm: BasePart = Viewmodel:WaitForChild("Right Arm") :: BasePart
	RArmWeld.Part1 = RArm
	RArmWeld.C0 = CFrame.new()
	RArmWeld.C1 = CFrame.new(-1,-1,-5) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0)):Inverse()

	LArm.Anchored = false
	RArm.Anchored = false

    System.Welds = {
        LeftArmWeld = LArmWeld,
        RightArmWeld = RArmWeld,
        GunWeld = GunWeld
    }

    System:LoadAttachments()

    GunWeld.Part0 = RArm
    GunWeld.Part1 = ItemModel.Handle
    GunWeld.C1 = System.Variables.GunCFrame

    GunWeld.Parent, RArmWeld.Parent, LArmWeld.Parent = AnimationPart, AnimationPart, AnimationPart
    AnimationPart.CFrame = Camera.CFrame

    if System.Equipped.Settings.Ammo <= 0 then
        local Handle: BasePart? = ItemModel:FindFirstChild("Handle")
        if Handle then
            local Slide: Motor6D? = Handle:FindFirstChild("Slide") :: Motor6D?
            if Slide and Slide:IsA("Motor6D") then
                Slide.C1 = System.Equipped.Settings.SlideEx
            end

            local Bolt: Motor6D? = Handle:FindFirstChild("Bolt") :: Motor6D?
            if Bolt and Bolt:IsA("Motor6D") then
                Bolt.C1 = System.Equipped.Settings.BoltEx
            end
        end
    end

    ItemModel.Parent = Viewmodel
    Viewmodel.Parent = Camera
    System.Viewmodel = Viewmodel
end

function System:GetBullets(): number
    return System.Equipped.Settings.Ammo
end

function System:GetType(): string
    return System.Equipped.Settings.Type
end

return System