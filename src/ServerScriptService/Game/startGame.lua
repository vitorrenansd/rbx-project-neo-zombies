local WaveManager = require(game.ReplicatedStorage.Classes.WaveManager)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local startGame = game.ReplicatedStorage.startGame

-- Variaveis para a instancia de WaveManager
local Map = workspace:WaitForChild("Map") -- Mapa onde os zumbis sao spawnados
local SpawnLocation = Map:WaitForChild("SpawnLocation") -- Local de spawn dos zumbis
local Config = Map:WaitForChild("Config") -- Config do mapa (wave, maxWave, etc)
local ZombieModels = ReplicatedStorage.ZombieModels:GetChildren() -- Modelos de zumbis disponíveis


-- coonect do remote event startGame
startGame.OnServerEvent:Connect(function(player)
	
	-- Locka a camera
	ReplicatedStorage.startGame:FireClient(player)
	
	
	local waveManager = WaveManager.new(Map, Config, ZombieModels, player)
	-- Comeca o loop de wave
	waveManager:startWaveLoop()
	
end)