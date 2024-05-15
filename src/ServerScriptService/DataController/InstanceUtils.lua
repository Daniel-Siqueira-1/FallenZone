export type PlayerData = {
    [any]: any
}

export type BaseValue = ValueBase & {Value: any}

export type DataCache = {
    [number]: PlayerData
}

type dict<K,v> = {[K]: v}

local function NewDir(Name: string, Parent: Instance): Folder
    local NewFolder: Folder = Instance.new("Folder")
    NewFolder.Name = Name
    NewFolder.Parent = Parent 

    return NewFolder
end

local function ToObject(Type: string): BaseValue | Folder
    if Type == "table" then
        return Instance.new("Folder")
    end
    if Type == "boolean" then 
        return Instance.new("BoolValue") :: BaseValue
    end
	Type = string.sub(Type,1,1):upper()..string.sub(Type,2,-1).."Value"

	return Instance.new(Type) :: BaseValue
end

local function UpdateStructure(Data: PlayerData, comparisonData: PlayerData): PlayerData
    for Index: string,Value: any in pairs(comparisonData) do 
        if not Data[Index] then
            Data[Index] = Value
        else 
            if type(Value) == "table" then
                UpdateStructure(Data[Index], Value)
            end
        end
    end

    return Data
end

local function ToTable(Objects: {Folder | BaseValue}): PlayerData
    local ConvertedData: PlayerData = {} :: PlayerData
    for _, Object: any in pairs(Objects) do
        if Object:IsA("Folder") then
            ConvertedData[Object.Name] = ToTable(Object:GetChildren())
        elseif Object:IsA("ValueBase") then
            ConvertedData[Object.Name] = Object.Value
        end
    end

    return ConvertedData
end

local function Instantiate(Data: {[string]: any},Parent: Folder): BaseValue | Folder
	for i: string,v: any in pairs(Data) do
		local PrimitiveType: string = typeof(v)
		if PrimitiveType == "userdata" then continue end

		if PrimitiveType == "table" then
            local Dir: Folder = NewDir(i, Parent)
			Instantiate(Data[i],Dir)

            Dir.Destroying:Connect(function()
				Data[i] = nil
			end)

            Dir.ChildAdded:Connect(function(child: any): ()
                if child:IsA("Folder") then
                    local Children: {BaseValue | Folder} = child:GetChildren() :: any
                    v[child.Name] = ToTable(Children)
                else
                    v[child.Name] = child.Value :: BaseValue
                end 
            end)

            Dir.ChildRemoved:Connect(function(child: any): ()
                Data[child.Name] = nil
            end)
		else
			local ObjectValue: BaseValue? = ToObject(PrimitiveType) :: any
			if ObjectValue then
                ObjectValue.Name = tostring(i)
                ObjectValue.Value = v
                ObjectValue.Changed:Connect(function(NewValue: string): ()
                    --print("CHANGED", Data, i, NewValue)
                    Data[i] = NewValue
                end)
                
                ObjectValue.Destroying:Connect(function(): ()
                    Data[i] = nil
                end)

                ObjectValue.Parent = Parent
            end
		end
	end

    return Parent
end

local function InstantiateAndLink(Data: {[string]: any},Parent: Folder, LinkData: {[string]: any}, IndexToLink: string): BaseValue | Folder
    if type(Data) == "table" then
        for i: string,value: any in pairs(Data) do
            local PrimitiveType: string = typeof(value)

            local TrueData = LinkData[IndexToLink]

            if PrimitiveType == 'table' then
                local Dir: Folder = NewDir(i, Parent)
                Instantiate(TrueData[i],Dir)

                Dir.Destroying:Connect(function()
                    TrueData[i] = nil
                end)
    
                Dir.ChildAdded:Connect(function(child: any): ()
                    if child:IsA("Folder") then
                        local Children: {BaseValue | Folder} = child:GetChildren() :: any
                        TrueData[i][child.Name] = ToTable(Children)
                    else
                        TrueData[i][child.Name] = child.Value :: BaseValue
                    end 
                end)

                Dir.ChildRemoved:Connect(function(child: any): ()
                    TrueData[i][child.Name] = nil
                end)

                return Dir
            else
                local ObjectValue: BaseValue? = ToObject(PrimitiveType) :: any
                if ObjectValue then
                    ObjectValue.Name = tostring(i)
                    ObjectValue.Value = value
                    ObjectValue.Changed:Connect(function(NewValue: string)
                        TrueData[i] = NewValue
                    end)
                    
                    ObjectValue.Destroying:Connect(function()
                        TrueData[i] = nil
                    end)

                    ObjectValue.Parent = Parent

                    return ObjectValue
                end
            end
        end
    end

    return Parent
end


return {NewDirectory = NewDir, ToObject = ToObject, Instantiate = Instantiate, InstantiateAndLink = InstantiateAndLink, UpdateStructure = UpdateStructure}