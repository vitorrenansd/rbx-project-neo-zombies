local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Criar o RemoteEvent
local updateWaveHUD = Instance.new("RemoteEvent")
updateWaveHUD.Name = "UpdateWaveHUD"
updateWaveHUD.Parent = ReplicatedStorage