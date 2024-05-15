local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Buffer = require(ReplicatedFirst.Packages.Reliability.Buffer)
local Types = require(ReplicatedFirst.Packages.Reliability.Server.Types)
local Server = {}
Server.__index = Server

type ServerRemote = Types.ServerRemote

local Remotes = Instance.new("Folder")
Remotes.Name = "UnreliableRemotes"
Remotes.Parent = ReplicatedFirst

local ToInformation: ((...any) -> ()) -> () = Buffer.ToInformation
local ToBuffer: ((...any) -> ()) -> () = Buffer.ToBuffer

function Server.ServerRemote(Identifier: string): ServerRemote
    local self: any = {
        __remote = Instance.new("UnreliableRemoteEvent")
    }

    self.__remote.Name = Identifier
    self.__remote.Parent = Remotes

    return setmetatable(self, Server) :: ServerRemote
end

function Server:Send(Player: Player, ...:any): ()
    self.__remote:FireClient(Player, ToBuffer(...))
end

function Server:Connect(Callback: (...any)->()): RBXScriptConnection
    return self.__remote:Connect(ToInformation(Callback))
end

return Server