local DataStoreService = game:GetService("DataStoreService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")

local InstanceUtils = require(ServerScriptService.DataController.InstanceUtils)
local Config = require(script.Configuration)
local DataMethods = require(script.DataMethods)
local Promise = require(ReplicatedFirst.Packages.Promise)

local Saving: {[string]: Promise.PromiseChain<any>} = {}
local DataController = {}
DataController.__index = DataController

export type DataController = {
    Object: Folder;
    Cache: {any};

    Destroy: (self: DataController)->();
    Load: (self: DataController, DataStoreName: string?, Key: string?, CallbackData: any)->Promise.PromiseChain<any>;
    Import: (self: DataController, Cache: any, FolderName: string)->boolean;
    Write: (self: DataController, Path: string, Value: any, Function: string)->boolean
}

local function WaitForBudget(Budget: Enum.DataStoreRequestType, Lenience: number?): Promise.PromiseChain<nil>
    return Promise.new(function(resolve: Promise.resolve<nil>,reject: Promise.reject<nil>): ()
        Lenience  = Lenience or 10
        local TimePassed: number = 0

        repeat
            local WaitTime: number = .5
            TimePassed += WaitTime
            
            task.wait(WaitTime)
        until 
            DataStoreService:GetRequestBudgetForRequestType(Budget) or
            TimePassed >= Lenience

        if TimePassed >= Lenience then
            reject()
        else
            resolve()
        end

        return
    end)
end

function DataController.new(Scope: string?): DataController
    local self: any = {
        Cache = {},
        Scope = Scope or "global",
        Object = Instance.new("Folder");
        MaxAttempts = 3;
    }

    self.Object.Name = "Cache"

    return setmetatable(self,DataController) :: DataController
end

function DataController:GetList(PageSize: number?): DataStoreKeyPages
    local Budget: number = DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.ListAsync)
    if Budget then
        local Success: boolean, KeyPages: DataStoreKeyPages = pcall(
            DataStoreService.ListKeysAsync, 
            DataStoreService, 
            self.Scope,
            PageSize or 10
        )

        if Success then
            return KeyPages
        else
            return DataController:GetList(PageSize)
        end
    else
        WaitForBudget(Enum.DataStoreRequestType.ListAsync):await()

        return DataController:GetList(PageSize)
    end
end

function DataController:Load<LoadedData>(DataStoreName: string?,Key: string?, CallbackData: LoadedData, __attempt: number?): Promise.PromiseChain<LoadedData>
    return Promise.new(function(resolve: Promise.resolve<LoadedData>, reject: Promise.reject<string>): ()
        if not self.Scope then
            reject("No scope defined")
            return
        end

        local Budget: number = DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)

        local DataStoreOptions = Instance.new("DataStoreOptions")
        DataStoreOptions.AllScopes = true

        if DataStoreName and Key then
            local DataStore = DataStoreService:GetDataStore(DataStoreName, "", DataStoreOptions)
            if Budget then
                local Success: boolean, LoadedData: LoadedData = pcall(DataStore.GetAsync, DataStore, self.Scope.."/"..Key) 
                if Success then
                    if not LoadedData then
                        LoadedData = CallbackData
                    end

                    if type(LoadedData) == "table" then
                        setmetatable(LoadedData :: any, DataMethods)
                    end

                    resolve(LoadedData)
                else
                    

                    reject(LoadedData :: any)
                    return
                end
            else
                if __attempt > self.MaxAttempts then
                    reject("Attempt failed")
                end

                WaitForBudget(Enum.DataStoreRequestType.GetAsync):andThen(function(): ()
                    local Success: boolean, LoadedData: LoadedData = self:Load(
                        DataStoreName,
                        Key,
                        CallbackData,
                        __attempt and __attempt+1 or 1
                    ):await()

                    if Success then
                        resolve(LoadedData)
                    else
                        reject(LoadedData :: any)
                    end
                end, reject)
            end
        else
            resolve(CallbackData)
        end
    end)
end

function DataController:Import<Data>(Data: Data, Name: string): boolean
    if self.Cache then
        self.Cache[Name] = Data
        local NewCacheFolder: Folder = Instance.new("Folder")
        NewCacheFolder.Name = Name
        NewCacheFolder.Parent = self.Object

        InstanceUtils.Instantiate(Data :: any, NewCacheFolder)
        return true
    else
        return false
    end
end

function DataController:Write(Path: string, Value: any, Function: string): boolean
    if not self.Cache then
        return false
    end

    local LastPath, LastPathObject, LastIndex, Nodes = nil, nil, nil, string.split(Path,".")

    for Index: number, value: string in pairs(Nodes) do 
        if #Nodes == Index then 
            LastIndex = value
            break
        end

        LastPathObject = (LastPathObject or self.Instance):FindFirstChild(value)
        LastPath = (LastPath or self.Cache)[value]
    end

    if LastPath and LastPath[LastIndex] ~= nil then 
        local LastPathType: string = type(LastPath[LastIndex])
        if LastPathType == "table" then 
            local Object: Folder = LastPathObject:FindFirstChild(LastIndex) or InstanceUtils.NewDirectory(LastIndex, LastPathObject)
            if Function == "Update" then 
                InstanceUtils.InstantiateAndLink(Value, Object, LastPath, LastIndex)
                return true
            else 
                if Value == nil then
                    Object:Destroy()
                    return false
                else
                    Object:ClearAllChildren()
                    InstanceUtils.InstantiateAndLink(Value, Object, LastPath, LastIndex)
                    return true
                end
            end
        else 
            if Function == "Increment" then 
                LastPathObject[LastIndex].Value += Value
                return LastPathObject[LastIndex]
            elseif Function == "Decrement" then
                LastPathObject[LastIndex].Value -= Value
                return LastPathObject[LastIndex]
            elseif Function == "Change" or Function == nil then 
                if Value == nil then
                    LastPathObject[LastIndex]:Destroy()
                    return false
                else
                    LastPathObject[LastIndex].Value = Value
                    return true
                end
            end
        end
    elseif LastPath and LastPath[LastIndex] == nil then
        InstanceUtils.InstantiateAndLink(Value, LastPathObject, LastPath, LastIndex)
        return true
    end

    return false
end

function DataController:Save(Cache: any, DataStoreName: string, Key: string): ()
    if Saving[self.Scope] then 
        return Saving[self.Scope]
    end 

    Saving[self.Scope] = Promise.new(function(resolve: Promise.resolve<string>,reject: Promise.reject<string>): () 
        if Config.IS_STUDIO and Config.STUDIO_SAVE == false or not Config.IS_STUDIO and Config.GAME_SAVE == false then
            reject("Failed to use method, not allowed in this PlayMode")
            return
        end

        local DataStorage: DataStore = DataStoreService:GetDataStore(DataStoreName, self.Scope)
        local Success: boolean,Message: any = pcall(
            DataStorage.SetAsync,
            DataStorage, 
            Key,
            Cache
        )

        Saving[self.Scope] = nil

        if Success then 
            resolve(Message)
            return
        else
            reject(Message)
            return
        end
    end)

    return Saving[self.Scope]
end

function DataController:Destroy(): ()
    self.Object:Destroy()

    if Saving[self.Scope] then
        Saving[self.Scope]:cancel()
    end

    Saving[self.Scope] = nil
    table.clear(self)
end

return DataController