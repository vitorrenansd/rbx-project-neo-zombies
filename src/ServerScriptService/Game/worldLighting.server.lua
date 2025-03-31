local Lighting = game:GetService("Lighting")

--Configuracao de brilho global
Lighting.Brightness = 0.7
Lighting.ExposureCompensation = 0
Lighting.Ambient = Color3.fromRGB(0, 0, 0)
Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)

-- Boniteza
Lighting.GlobalShadows = 1
Lighting.ShadowSoftness = 1
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 1

--Configracao de neblina
Lighting.FogColor = Color3.fromRGB(0, 0, 0)
Lighting.FogStart = 30
Lighting.FogEnd = 50