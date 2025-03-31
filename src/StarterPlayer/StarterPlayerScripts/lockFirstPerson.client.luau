local Player = require(game.ReplicatedStorage.Classes.Player)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Player.new()

-- Remote event para travar a camera
ReplicatedStorage.startGame.OnClientEvent:Connect(function()
	player:lockFirstPerson()
end)