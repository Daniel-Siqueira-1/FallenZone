local ReplicatedFirst = game:GetService("ReplicatedFirst")

local RunService = game:GetService("RunService")

local ClientTypes = require(ReplicatedFirst.Packages.Reliability.Client.Types)
local ServerTypes = require(ReplicatedFirst.Packages.Reliability.Server.Types)

export type ClientRemote = ClientTypes.ClientRemote
export type ServerRemote = ServerTypes.ServerRemote

if RunService:IsServer() then
    return require(script:WaitForChild("Server"))
else
    return require(script:WaitForChild("Client"))
end
