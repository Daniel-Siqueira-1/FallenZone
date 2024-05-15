local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Remotes = ReplicatedFirst:WaitForChild("UnreliableRemotes")

local Buffer = require(ReplicatedFirst.Packages.Reliability.Buffer)
local Types = require(ReplicatedFirst.Packages.Reliability.Client.Types)
local Client = {}
Client.__index = Client

type ClientRemote = Types.ClientRemote

local ToInformation: ((...any) -> ()) -> () = Buffer.ToInformation
local ToBuffer: ((...any) -> ()) -> () = Buffer.ToBuffer

function Client.ClientRemote(Identifier: string): ClientRemote
    local self: any = {
        __remote = Remotes:FindFirstChild(Identifier)
    }

    return setmetatable(self, Client) :: ClientRemote
end

function Client:Send(Player: Player, ...:any): ()
    self.__remote:FireClient(Player, ToBuffer(...))
end

function Client:Connect(Callback: (...any)->()): RBXScriptConnection
    return self.__remote:Connect(ToInformation(Callback))
end

return Client