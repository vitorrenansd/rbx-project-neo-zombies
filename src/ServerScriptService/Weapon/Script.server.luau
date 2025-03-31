local Weapon = require(game.ReplicatedStorage.Classes.Weapon) 
local FireEvent = game.ReplicatedStorage:WaitForChild("fireEvent")
local playersWeapons = {}


FireEvent.OnServerEvent:Connect(function(plr, posicaoMouse,action)

	local character = plr.Character or plr.CharacterAdded:Wait()

	local Tool = character:FindFirstChildOfClass("Tool")
	if not playersWeapons[plr] then
		playersWeapons[plr] = Weapon.new(Tool)
	end

	local Gun = playersWeapons[plr]
	if action == "start" then
		Gun:startAutoFire(plr)
	elseif action == "stop" then
		Gun:stopAutoFire()
	elseif action == "single" then
		Gun:fire(plr, posicaoMouse)
	end
end)

game.Players.PlayerRemoving:Connect(function(plr)
	playersWeapons[plr] = nil
end)