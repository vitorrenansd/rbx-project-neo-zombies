local ReplicatedStorage = game:GetService("ReplicatedStorage")

local updateWaveHUD = Instance.new("RemoteEvent")
updateWaveHUD.Name = "UpdateWaveHUD"
updateWaveHUD.Parent = ReplicatedStorage

local updateZombieHUD = Instance.new("RemoteEvent")
updateZombieHUD.Name = "updateZombieHUD"
updateZombieHUD.Parent = ReplicatedStorage