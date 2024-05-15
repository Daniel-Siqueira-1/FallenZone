local Debris = game:GetService("Debris")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerStorage = game:GetService("ServerStorage")

local BridgeNet2 = require(ReplicatedFirst.Packages.BridgeNet2)

type ServerBridge<type> = BridgeNet2.ServerBridge<type>

local DamageTree: ServerBridge<{Tree: Model, WeaponName: string}> = BridgeNet2.ServerBridge("DamageTree")
local Items = ServerStorage:WaitForChild("Items")

local Trees: Model = workspace:WaitForChild("Trees") :: Model

for _, Tree: Model in Trees:GetChildren() :: any do
    if not Tree.PrimaryPart then
        continue
    end

    Tree:AddTag("Tree")
    Tree:SetAttribute("Health", 300)
    for _, Part: Instance in Tree:GetDescendants() do
        if Part ~= Tree.PrimaryPart then
            Part:AddTag("Leaf")
        end
    end
end

local function OnDamageTreeRequest(Player: Player, Info: {Tree: Model, WeaponName: string}):()
    local Tree: Model, WeaponName: string = Info.Tree, Info.WeaponName
    local Character: Model? = Player.Character
    if Character then
        local Humanoid: Humanoid, Root: BasePart = Character:WaitForChild("Humanoid") :: Humanoid, Character:WaitForChild("HumanoidRootPart") :: BasePart
        if Humanoid and Root then
            if (Root.Position - Tree:GetPivot().Position).Magnitude < 5 then
                local SettingsModule: ModuleScript = Items:FindFirstChild(WeaponName,true):WaitForChild("ACS_Settings")
                if SettingsModule then
                    local Settings = require(SettingsModule).TreeDamage or {10,50}
                    local Damage: number = math.random(Settings[1], Settings[2])
                    local TreeHealth = Tree:GetAttribute("Health")
                    local UpdatedHealth: number = math.clamp(TreeHealth - Damage,0,math.huge)

                    if UpdatedHealth == 0 then
                        for _, Object in Tree:GetDescendants() do
                            if Object:IsA("BasePart") then
                                Object.CanCollide = false
                                Object.CanTouch = false
                                Object.CanQuery = false
                                Object.Anchored = true
                            end
                        end

                        local Direction: number = math.random(1,2)
                        local Sign: number = math.random(1,2)
                        Sign = Sign == 1 and -1 or 1

                        Tree:SetAttribute("Direction", Direction)
                        Tree:SetAttribute("Sign", Sign)
                        Tree:AddTag("TreeFalling")
                        Debris:AddItem(Tree,10)
                    end

                    Tree:SetAttribute("Health", UpdatedHealth)
                end
            end
        end
    end
end

DamageTree:Connect(OnDamageTreeRequest)