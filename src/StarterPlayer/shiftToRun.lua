local PlayerClass = require(game.ReplicatedStorage.Classes.Player) 

local localPlayer = game.Players.LocalPlayer
local player = PlayerClass.new(localPlayer) 

-- Aqui fica o valor de speed com shift pressionado
local runningSpeed = 26

player:shiftToRun(runningSpeed)