local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

function easeInExpo(x: number): number
    return x ^ 4
end

local function FallingTreeAnimation(Tree: Model): ()
    local OriginalPivot: CFrame = Tree:GetPivot()
    local Direction: number = Tree:GetAttribute("Direction")
    local Sign: number = Tree:GetAttribute("Sign")
    for i = 0,1,.005 do
        i = easeInExpo(i)
        i = 90 * i
        i = math.rad(i)
        Tree:PivotTo(OriginalPivot * CFrame.Angles(Direction == 1 and i * Sign or 0, 0, Direction == 2 and i * Sign or 0))
        RunService.Heartbeat:Wait()
    end
    task.wait(3)
    for _, Part: Instance in Tree:GetDescendants() do
        if Part:IsA("BasePart") then
            task.spawn(function()
                local Transparency: number = Part.Transparency
                for i = Transparency, 1,.02 do
                    Part.Transparency = i
                    RunService.Heartbeat:Wait()
                end
            end)
        end
    end

    Debris:AddItem(Tree,3)
end

CollectionService:GetInstanceAddedSignal("TreeFalling"):Connect(FallingTreeAnimation)