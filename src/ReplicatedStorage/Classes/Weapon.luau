local Weapon = {}
Weapon.__index = Weapon

function Weapon.new(tool)
	local self = setmetatable({}, Weapon)

	self.tool = tool
	self.config = tool:WaitForChild("Config")
	self.fireRate = self.config:WaitForChild("fireRate").Value
	self.handle = tool:WaitForChild("Handle")
	self.canFire = true
	self.holdMouse = false

	self.SoundClass = require(game.ReplicatedStorage.Classes.Sound)
	self.sound = self.SoundClass.new()

	-- fireEvent só é usado no servidor para receber e processar o tiro
	self.fireEvent = game.ReplicatedStorage:WaitForChild("fireEvent")

	return self
end

-- Aplica dano via raycast — chamado apenas pelo servidor
function Weapon:fire(player, posicaoMouse)
	local SFX = game.ReplicatedStorage.Sounds.SFX
	self.sound:playSound(SFX.fire, 0.5, false)

	local RCparams = RaycastParams.new()
	RCparams.FilterDescendantsInstances = {self.tool.Parent}
	local rayDirection = (posicaoMouse - self.handle.Position).Unit * self.config.range.Value
	local RaycastResult = workspace:Raycast(self.handle.Position, rayDirection, RCparams)

	if RaycastResult and RaycastResult.Instance then
		local hitInstance = RaycastResult.Instance
		if hitInstance.Parent:FindFirstChild("Humanoid") then
			local zombieHumanoid = hitInstance.Parent:FindFirstChildWhichIsA("Humanoid")
			local baseDamage = self.config.damage.Value

			if hitInstance.Name == "Head" then
				self.sound:playSound(SFX.headshot, 0.5, false)
				zombieHumanoid:TakeDamage(baseDamage * 2)
			else
				zombieHumanoid:TakeDamage(baseDamage)
			end
		end
	end
end

function Weapon:stopAutoFire()
	self.holdMouse = false
end

function Weapon:startAutoFire(player)
	self.holdMouse = true
	-- loop de disparo automático no servidor, alimentado por eventos do cliente
	-- não tem loop aqui — o cliente envia evento a cada tiro via fireEvent
end

return Weapon