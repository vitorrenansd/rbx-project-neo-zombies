local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local fireEvent = ReplicatedStorage:WaitForChild("fireEvent")

local holding = false
local canFire = true

local function getFireRate()
    local character = player.Character
    if not character then return 0.1 end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return 0.1 end
    local config = tool:FindFirstChild("Config")
    if not config then return 0.1 end
    local fr = config:FindFirstChild("fireRate")
    return fr and fr.Value or 0.1
end

local function tryFire()
    local character = player.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end

    if canFire then
        canFire = false
        fireEvent:FireServer(mouse.Hit.Position, "single")
        task.delay(getFireRate(), function()
            canFire = true
        end)
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        holding = true
        tryFire()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        holding = false
    end
end)

-- disparo automático contínuo enquanto segurar
RunService.Heartbeat:Connect(function()
    if holding then
        tryFire()
    end
end)