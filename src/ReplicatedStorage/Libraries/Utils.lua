local Utilities = {}

Utilities.Weld = function(Part0, Part1, C0, C1)
	local Motor6D: Motor6D = Instance.new("Motor6D")
    Motor6D.Name = Part1.Name

	Motor6D.Part0 = Part0
	Motor6D.Part1 = Part1
	Motor6D.C0 = C0 or Part1.CFrame:Inverse() * Part1.CFrame

    Motor6D.Parent = Part1

	return Motor6D
end

Utilities.WeldComplex = function(Part0: BasePart,Part1: BasePart,Name: string): Motor6D
	local Motor6D: Motor6D = Instance.new("Motor6D")
	Motor6D.Name = Name

	Motor6D.Part0 = Part0
	Motor6D.Part1 = Part1
	local CJ: CFrame = CFrame.new(Part0.Position)
	local C0: CFrame = Part0.CFrame:Inverse()*CJ
	local C1: CFrame = Part1.CFrame:Inverse()*CJ
	Motor6D.C0 = C0
	Motor6D.C1 = C1
	Motor6D.Parent = Part0

	return Motor6D
end

Utilities.CheckForHumanoid = function(ObjectToSearch: Model): (boolean,Humanoid?)
	local Humanoid: Humanoid?;

	if ObjectToSearch and ObjectToSearch.Parent and ObjectToSearch.Parent.Parent then
        Humanoid = ObjectToSearch.Parent:FindFirstChildOfClass("Humanoid")
        if not Humanoid then
            Humanoid = ObjectToSearch.Parent.Parent:FindFirstChildOfClass("Humanoid")
        end
	end
	return Humanoid ~= nil, Humanoid
end

return Utilities