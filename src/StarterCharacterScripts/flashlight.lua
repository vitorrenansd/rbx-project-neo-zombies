local PlayerClass = require(game:GetService("ReplicatedStorage").Classes.Player)
local localPlayer = game.Players.LocalPlayer

local player = PlayerClass.new(localPlayer)

player:createFlashlight(3, 25, 50)