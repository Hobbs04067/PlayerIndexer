local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Utils = script.Parent.Utils
local Networking = require(Utils.Networking)
local Enums = require(Utils.Enums)

local ReplicationEvent = script.Parent.Replicate

local idCount = 256

local _availableIndices = {}
local _idKeySet = {}
local _playerKeySet = {}

for i = 0, idCount - 1, 1 do
	table.insert(_availableIndices, i)
end

local function addPlayer(player: Player, startId: number?)
	if #_availableIndices > 0 then
		local id = startId or _availableIndices[#_availableIndices]
		if startId then
			table.remove(_availableIndices, startId + 1)
		else
			table.remove(_availableIndices, #_availableIndices)
		end

		_idKeySet[id] = player
		_playerKeySet[player] = id

		return true
	else
		error("PlayerIndexer error: hit max capacity!")
	end
end

local function removePlayer(id: number)
	local player = _idKeySet[id]
	_idKeySet[id] = nil

	if player and _playerKeySet[player] == id then
		_playerKeySet[player] = nil

		table.insert(_availableIndices, id)

		return true
	end

	return false
end

local module = {}

function module.toPlayer(id: number): Player?
	return _idKeySet[id]
end

function module.toId(player: Player): number?
	return _playerKeySet[player]
end

if RunService:IsServer() then
	local function handleAddPlayer(player: Player)
		if addPlayer(player) then
			ReplicationEvent:FireAllClients(
				Networking.bitPack({
					replicationAction = Enums.ReplicationAction.Assign,
					id = module.toId(player),
				}),
				player
			)
		end

		for id: number, iPlayer: Player in pairs(_idKeySet) do
			if iPlayer ~= player then
				ReplicationEvent:FireClient(
					player,
					Networking.bitPack({
						replicationAction = Enums.ReplicationAction.Assign,
						id = id,
					}),
					iPlayer
				)
			end
		end
	end

	local function handleRemovePlayer(player: Player)
		local id = module.toId(player)
		if removePlayer(id) then
			ReplicationEvent:FireAllClients(Networking.bitPack({
				replicationAction = Enums.ReplicationAction.Deassign,
				id = id,
			}))
		end
	end
	Players.PlayerAdded:Connect(handleAddPlayer)
	Players.PlayerRemoving:Connect(handleRemovePlayer)

	for _, player: Player in pairs(Players:GetPlayers()) do
		handleAddPlayer(player)
	end
else
	ReplicationEvent.OnClientEvent:Connect(function(buff: buffer, ...)
		local replicationAction, id = Networking.bitUnpack(buff)

		local args = { ... }

		if replicationAction == Enums.ReplicationAction.Assign then
			addPlayer(args[1], id)
		elseif replicationAction == Enums.ReplicationAction.Deassign then
			removePlayer(id)
		end
	end)
end

return module