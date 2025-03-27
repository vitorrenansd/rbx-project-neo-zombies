local LeaderboardClass = require(game.ReplicatedStorage.Classes.Leaderboard)
local playerLeaderboards = {}

-- Quando o jogador entra no jogo
game.Players.PlayerAdded:Connect(function(player)
	-- Cria uma instancia do Leaderboard
	local leaderboard = LeaderboardClass.new(player)
	playerLeaderboards[player.UserId] = leaderboard
end)

-- Quando o jogador sair do jogo
game.Players.PlayerRemoving:Connect(function(player)
	-- Salva as estatisticas dele
	local leaderboard = playerLeaderboards[player.UserId]
	if leaderboard then
		leaderboard:SavePlayerStats()
		playerLeaderboards[player.UserId] = nil
	end
end)