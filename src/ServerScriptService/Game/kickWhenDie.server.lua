local PlayerClass = require(game.ReplicatedStorage.Classes.Player)

local PlayersService = game:GetService("Players")

-- Connect do metodo kickPlayer
PlayersService.PlayerAdded:Connect(function(player)
	
	local player = PlayerClass.new(player) 
	player:kickWhenDie() 
	
end)