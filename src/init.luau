local RunService = game:GetService("RunService")

if RunService:IsServer() then
	local event = Instance.new("RemoteEvent")
	event.Parent = script
	event.Name = "Replicate"
end

return require(script.PlayerIndexer)