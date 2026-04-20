local Weapon = require(game.ReplicatedStorage.Classes.Weapon)
local FireEvent = game.ReplicatedStorage:WaitForChild("fireEvent")
local playersWeapons = {}

FireEvent.OnServerEvent:Connect(function(plr, posicaoMouse, action)
	local character = plr.Character or plr.CharacterAdded:Wait()
	local tool = character:FindFirstChildOfClass("Tool")
	if not tool then return end

	-- valida tipo antes de usar
	if typeof(posicaoMouse) ~= "Vector3" then return end

	if not playersWeapons[plr] then
		playersWeapons[plr] = Weapon.new(tool)
	end

	local gun = playersWeapons[plr]
	if action == "single" then
		gun:fire(plr, posicaoMouse)
	end
end)

game.Players.PlayerRemoving:Connect(function(plr)
	playersWeapons[plr] = nil
end)