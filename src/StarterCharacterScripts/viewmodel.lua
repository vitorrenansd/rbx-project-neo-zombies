---------------------------------------------------------------------------------------------

-- EasyFirstPerson by yellowfats 2021.
-- Place in StarterCharacterScripts

---------------------------------------------------------------------------------------------


--/////////// CONFIGURATIONS \\\\\\\\\\\\\\\\\


local sensitivity = 1 -- how quick/snappy the sway movements are. Don't go above 2
local swaysize = 1 -- how large/powerful the sway is. Don't go above 2
local includestrafe = false -- if true the fps arms will sway when the character is strafing
local includewalksway = true -- if true, fps arms will sway when you are walking
local includecamerasway = true -- if true, fps arms will sway when you move the camera
local includejumpsway = true -- if true, jumping will have an effect on the viewmodel
local headoffset = Vector3.new(0,0,0) -- the offset from the default camera position of the head. (0,1,0) will put the camera one stud above the head.
local firstperson_arm_transparency = 0 -- the transparency of the arms in first person; set to 1 for invisible and set to 0 for fully visible.
local firstperson_waist_movements_enabled = false -- if true, animations will affect the Uppertorso. If false, the uppertorso stays still while in first person (applies to R15 only)


--//////// DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU'RE DOING \\\\\\\\\\\\\\\\\\\\\\\\\



local uis = game:GetService("UserInputService")
local runservice = game:GetService("RunService")
local tweenservice = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
repeat runservice.Heartbeat:Wait() until script.Parent:IsA("Model") -- yield until character
local character = player.Character
local rootpart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local aimoffset = script:WaitForChild("AimOffset") -- a property for other scripts to use to influence the viewmodel offset (such as a gun aim system)
local torso
local roothip
local lowertorso
local oldc0
local leftshoulder
local rightshoulder
local larm
local rarm
local armparts = {}
local rigtype = nil

local isrunning = false
local armsvisible = true -- whether the arms are visible in first person
local armtransparency = firstperson_arm_transparency
local isfirstperson = false
local sway = Vector3.new(0,0,0)
local walksway = CFrame.new(0,0,0)
local strafesway = CFrame.Angles(0,0,0)
local jumpsway = CFrame.new(0,0,0)
local jumpswaygoal = Instance.new("CFrameValue")

-- create the viewmodel
local viewmodel = Instance.new("Model")
local fakeroot = Instance.new("Part")
viewmodel.Name = "Viewmodel"
fakeroot.Name = "HumanoidRootPart"
fakeroot.CanCollide = false
fakeroot.CanTouch = false
fakeroot.Anchored = true
--fakeroot.Massless = true
fakeroot.Transparency = 1
fakeroot.Parent = viewmodel
local faketorso = Instance.new("Part")
faketorso.Name = "Torso"
faketorso.CanCollide = false
faketorso.CanTouch = false
faketorso.Transparency = 1
--faketorso.Massless = true
faketorso.Parent = viewmodel
viewmodel.PrimaryPart = fakeroot
viewmodel.WorldPivot = fakeroot.CFrame+fakeroot.CFrame.UpVector*5
viewmodel.Parent = nil
local fakelowertorso = nil
local waistclone = nil
local leftshoulderclone = nil
local rightshoulderclone = nil
local roothipclone = nil


--// SETUP \\-----------------------------------------------------


-- setup based on rig type (r15 or r6)
if humanoid.RigType == Enum.HumanoidRigType.R15 then
	rigtype = "R15"
	torso = character:WaitForChild("UpperTorso")
	lowertorso = character:WaitForChild("LowerTorso")
	larm = character:WaitForChild("LeftUpperArm")
	rarm = character:WaitForChild("RightUpperArm")
	-- setup variables
	waist = torso:WaitForChild("Waist")
	oldc0 = waist.C0
	leftshoulder = character:WaitForChild("LeftUpperArm"):WaitForChild("LeftShoulder")
	rightshoulder = character:WaitForChild("RightUpperArm"):WaitForChild("RightShoulder")
	-- make fake lower torso
	fakelowertorso = Instance.new("Part")
	fakelowertorso.Name = "LowerTorso"
	fakelowertorso.CanCollide = false
	fakelowertorso.Anchored = false
	fakelowertorso.CanTouch = false
	fakelowertorso.Transparency = 1
	--fakelowertorso.Massless = true
	fakelowertorso.Parent = viewmodel
	--
	faketorso.Size = torso.Size
	fakeroot.Size = rootpart.Size
	fakelowertorso.Size = lowertorso.Size
	faketorso.CFrame = fakeroot.CFrame
	roothipclone = lowertorso:WaitForChild("Root"):Clone()
	roothipclone.Parent = fakelowertorso
	roothipclone.Part0 = fakeroot
	roothipclone.Part1 = fakelowertorso
	--
	if firstperson_waist_movements_enabled then
		waistclone = torso:WaitForChild("Waist"):Clone()
		waistclone.Parent = faketorso
		waistclone.Part0 = fakelowertorso
		waistclone.Part1 = faketorso
	else
		-- waist movements not enabled, replace waist joint with a weld
		waistclone = Instance.new("Weld")
		waistclone.Parent = faketorso
		waistclone.Part0 = fakelowertorso
		waistclone.Part1 = faketorso
		waistclone.C0 = waist.C0
		waistclone.C1 = waist.C1
	end
	--
	leftshoulderclone = leftshoulder:Clone()
	leftshoulderclone.Name = "LeftShoulderClone"
	leftshoulderclone.Parent = faketorso
	leftshoulderclone.Part0 = larm
	--
	rightshoulderclone = rightshoulder:Clone()
	rightshoulderclone.Name = "RightShoulderClone"
	rightshoulderclone.Parent = faketorso
	rightshoulderclone.Part0 = rarm
	-- add the arms
	table.insert(armparts, character:WaitForChild("RightLowerArm"))
	table.insert(armparts, character:WaitForChild("LeftUpperArm"))
	table.insert(armparts, character:WaitForChild("RightUpperArm"))
	table.insert(armparts, character:WaitForChild("LeftLowerArm"))
	table.insert(armparts, character:WaitForChild("RightLowerArm"))
	table.insert(armparts,character:WaitForChild("LeftHand"))
	table.insert(armparts,character:WaitForChild("RightHand"))
else
	rigtype = "R6"
	torso = character:WaitForChild("Torso")
	-- add the arms
	table.insert(armparts, character:WaitForChild("Right Arm"))
	table.insert(armparts, character:WaitForChild("Left Arm"))
	-- setup variables
	roothip = rootpart:FindFirstChildOfClass("Motor6D")
	oldc0 = roothip.C0
	leftshoulder = torso:WaitForChild("Left Shoulder")
	rightshoulder = torso:WaitForChild("Right Shoulder")
	--
	faketorso.Size = torso.Size
	fakeroot.Size = rootpart.Size
	faketorso.CFrame = fakeroot.CFrame
	roothipclone = roothip:Clone()
	roothipclone.Parent = fakeroot
	roothipclone.Part0 = fakeroot
	roothipclone.Part1 = faketorso
	--
	leftshoulderclone = leftshoulder:Clone()
	leftshoulderclone.Name = "LeftShoulderClone"
	leftshoulderclone.Parent = torso
	leftshoulderclone.Part0 = torso
	--
	rightshoulderclone = rightshoulder:Clone()
	rightshoulderclone.Name = "RightShoulderClone"
	rightshoulderclone.Parent = torso
	rightshoulderclone.Part0 = torso
	--
	larm = character:WaitForChild("Left Arm")
	rarm = character:WaitForChild("Right Arm")
end

if firstperson_arm_transparency >= 1 then
	armsvisible = false
end


--// FUNCTIONS \\----------------------------------------------------



-- loop through all the arm parts and make them visible in first person
local function visiblearms(bool)
	if armsvisible then
		local castshadow = not bool
		for i, part in ipairs(armparts) do
			part.LocalTransparencyModifier = armtransparency
			part.CastShadow = castshadow
		end
	end
end

-- enable the viewmodel system
local function enableviewmodel()
	isfirstperson = true
	viewmodel.Parent = workspace.CurrentCamera
	if rigtype == "R15" then
		-- disable character joints, enable viewmodel joints
		rightshoulderclone.Enabled = true
		leftshoulderclone.Enabled = true
		-- disable real shoulders
		leftshoulder.Enabled = false
		rightshoulder.Enabled = false
		--
		rightshoulderclone.Part1 = rarm
		rightshoulderclone.Part0 = faketorso
		rightshoulderclone.Parent = faketorso
		--
		leftshoulderclone.Part1 = larm
		leftshoulderclone.Part0 = faketorso
		leftshoulderclone.Parent = faketorso
		--
		armtransparency = firstperson_arm_transparency
	else
		--
		rightshoulderclone.Enabled = true
		leftshoulderclone.Enabled = true
		-- disable real shoulders
		leftshoulder.Enabled = false
		rightshoulder.Enabled = false
		--
		rightshoulderclone.Part1 = rarm
		rightshoulderclone.Part0 = faketorso
		rightshoulderclone.Parent = faketorso
		--
		leftshoulderclone.Part1 = larm
		leftshoulderclone.Part0 = faketorso
		leftshoulderclone.Parent = faketorso
		--
		armtransparency = firstperson_arm_transparency
	end
end


-- turn off the viewmodel system
local function disableviewmodel()
	isfirstperson = false
	viewmodel.Parent = nil
	if rigtype == "R15" then
		-- disable viewmodel joints, enable real character joints
		rightshoulderclone.Enabled = false
		leftshoulderclone.Enabled = false
		viewmodel.Parent = nil
		-- reset shoulder joints to normal
		leftshoulder.Parent = larm
		leftshoulder.Part0 = torso
		leftshoulder.Part1 = larm
		rightshoulder.Parent = rarm
		rightshoulder.Part0 = torso
		rightshoulder.Part1 = rarm
		--
		leftshoulder.Enabled = true
		rightshoulder.Enabled = true
		--
		armtransparency = 0
		visiblearms(false)
	else
		rightshoulderclone.Enabled = false
		leftshoulderclone.Enabled = false
		viewmodel.Parent = nil
		-- reset shoulder joints to normal, anchor the arms
		leftshoulder.Parent = torso
		leftshoulder.Part0 = torso
		leftshoulder.Part1 = larm
		rightshoulder.Parent = torso
		rightshoulder.Part0 = torso
		rightshoulder.Part1 = rarm
		--
		leftshoulder.Enabled = true
		rightshoulder.Enabled = true
		--
		armtransparency = 0
		visiblearms(false)
	end
end

-- check if camera is zoomed into first person
local function checkfirstperson()
	if isfirstperson == false then -- not in first person
		if ((camera.focus.p - camera.CFrame.p).magnitude <= 1) then
			enableviewmodel()
		end
	elseif ((camera.focus.p - camera.CFrame.p).magnitude > 1.1) then
		disableviewmodel()
	end
end



--// CONNECTIONS \\--------------------------------------------------


-- update whether the character is running or not
humanoid.Running:Connect(function(speed)
	if speed <= .3 then
		isrunning = false
	else
		isrunning = true
	end
end)

-- listen for jumping and landing and apply sway and camera mvoement to the viewmodel
humanoid.StateChanged:connect(function(oldstate, newstate)
	if isfirstperson == true and includejumpsway == true then -- dont apply camera/viewmodel changes if we aren't in first person
		if newstate == Enum.HumanoidStateType.Landed then
			-- animate the camera's landing "thump"
			--
			-- tween a dummy cframe value for camera recoil
			local camedit = Instance.new("CFrameValue")
			camedit.Value = CFrame.new(0,0,0)*CFrame.Angles(math.rad(-0.75)*swaysize,0,0)
			local landedrecoil = tweenservice:Create(camedit, TweenInfo.new((0.03*6)/sensitivity, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Value = CFrame.new(0,0,0)}) ; landedrecoil:Play() ; game.Debris:AddItem(landedrecoil, 2)
			landedrecoil.Completed:Connect(function()
				camedit.Value = CFrame.new(0,0,0)*CFrame.Angles(math.rad(0.225)*swaysize,0,0)
				local landedrecovery = tweenservice:Create(camedit, TweenInfo.new((0.03*24)/sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Value = CFrame.new(0,0,0)}) ; landedrecovery:Play(); game.Debris:AddItem(landedrecovery, 3)
			end)
			-- apply the camera adjustments
			spawn(function()
				for i = 1,60 do
					camera.CFrame = camera.CFrame*camedit.Value
					runservice.Heartbeat:Wait()
				end
			end)
			-- animate the jump sway to make the viewmodel thump down on landing
			local viewmodelrecoil = tweenservice:Create(jumpswaygoal, TweenInfo.new(0.15/sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Value = CFrame.new(0,0,0)*CFrame.Angles(-math.rad(5)*swaysize,0,0)}) ; viewmodelrecoil:Play(); game.Debris:AddItem(viewmodelrecoil, 2)
			viewmodelrecoil.Completed:Connect(function()
				local viewmodelrecovery = tweenservice:Create(jumpswaygoal, TweenInfo.new(0.7/sensitivity, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Value = CFrame.new(0,0,0)}) ; viewmodelrecovery:Play() ; game.Debris:AddItem(viewmodelrecovery, 2)
			end)
		elseif newstate == Enum.HumanoidStateType.Freefall then
			-- animate jump sway when the character is falling or jumping
			local viewmodeljump = tweenservice:Create(jumpswaygoal, TweenInfo.new(0.5/sensitivity, Enum.EasingStyle.Sine), {Value = CFrame.new(0,0,0)*CFrame.Angles(math.rad(7.5)*swaysize,0,0)}) ; viewmodeljump:Play() ; game.Debris:AddItem(viewmodeljump, 2)
		end	
	end
end)

-- detect if they lock first person mode during a live game
local playerchanged_con = nil
playerchanged_con = player.Changed:Connect(function(property)
	if property == "CameraMaxZoomDistance" or property == "CameraMode" then
		if player.CameraMaxZoomDistance <= 0.5 or player.CameraMode == Enum.CameraMode.LockFirstPerson then
			enableviewmodel()
		end
	end
end)

-- shut down the script when we die and reset things
humanoid.Died:Connect(function()
	stepped_con:Disconnect()
	leftshoulderclone:Destroy()
	rightshoulderclone:Destroy()
	viewmodel:Destroy()
	if rigtype == "R15" then
		if torso:FindFirstChild("Waist") then
			torso.Waist.Enabled = true
			torso.Anchored = false
		end
		armtransparency = 0
		visiblearms(false)
	else
		if rightshoulder then
			rightshoulder.Enabled = true
		end
		if leftshoulder then
			leftshoulder.Enabled = true
		end
		larm.Anchored = false
		rarm.Anchored = false
		armtransparency = 0
		visiblearms(false)
	end
end)


--// INITIAL CHECK \\-----------------------------------------------
-- we are checking to see if they've locked first person view
if (game.StarterPlayer.CameraMode == Enum.CameraMode.LockFirstPerson) or (game.StarterPlayer.CameraMaxZoomDistance <= 0.5) then
	enableviewmodel() -- theyve locked first person, so enable viewmodel from the start
end
---------------------------------------------------------------------


stepped_con = nil


-- perform the update loop
if rigtype == "R15" then
	
	-- do the r15 update loop
	stepped_con = game:GetService("RunService").RenderStepped:connect(function()
		-- checkfirstperson() checks if camera is first person and enables/disables the viewmodel accordingly
		checkfirstperson()
		-- update loop
		if isfirstperson == true then
			-- make arms visible
			visiblearms(true)
			-- update walk sway if we are walking
			if isrunning == true and includewalksway and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and humanoid:GetState() ~= Enum.HumanoidStateType.Landed then
				walksway = walksway:lerp(
					CFrame.new(

						(0.1*swaysize) * math.sin(tick() * (2 * humanoid.WalkSpeed/4)),
						(0.1*swaysize) * math.cos(tick() * (4 * humanoid.WalkSpeed/4)),
						0

					)*
						CFrame.Angles(

							0,
							0,
							(-.05*swaysize) * math.sin(tick() * (2 * humanoid.WalkSpeed/4))

						)
					,0.1*sensitivity)
			else
				walksway = walksway:Lerp(CFrame.new(), 0.05*sensitivity)
			end
			--
			local delta = uis:GetMouseDelta()
			if includecamerasway then
				sway = sway:Lerp(Vector3.new(delta.X,delta.Y,delta.X/2), 0.1*sensitivity)
			end
			--
			if includestrafe then
				strafesway = strafesway:Lerp(CFrame.Angles(0,0,-rootpart.CFrame.rightVector:Dot(humanoid.MoveDirection)/(10/swaysize)), 0.1*sensitivity)
			end
			--
			if includejumpsway then
				jumpsway = jumpswaygoal.Value
			end
			-- update animation transform for viewmodel
			rightshoulderclone.Transform = rightshoulder.Transform
			leftshoulderclone.Transform = leftshoulder.Transform
			if firstperson_waist_movements_enabled then
				waistclone.Transform = waist.Transform
			end
			-- cframe the viewmodel
			local finalcf = (camera.CFrame*walksway*jumpsway*strafesway*CFrame.Angles(math.rad(sway.Y*swaysize),math.rad(sway.X*swaysize)/10,math.rad(sway.Z*swaysize)/2))+(camera.CFrame.UpVector*(-1.7-(headoffset.Y+(aimoffset.Value.Y))))+(camera.CFrame.LookVector*(headoffset.Z+(aimoffset.Value.Z)))+(camera.CFrame.RightVector*(-headoffset.X-(aimoffset.Value.X)+(-(sway.X*swaysize)/75)))
			viewmodel:SetPrimaryPartCFrame(finalcf)
		end
	end)
elseif rigtype == "R6" then
	
	-- do the R6 update loop
	stepped_con = game:GetService("RunService").RenderStepped:connect(function()
		-- checkfirstperson() checks if camera is first person and enables/disables the viewmodel accordingly
		checkfirstperson()
		-- update loop
		if isfirstperson == true then
			-- make arms visible
			visiblearms(true)
			-- update walk sway if we are walking
			if isrunning == true and includewalksway and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and humanoid:GetState() ~= Enum.HumanoidStateType.Landed then
				walksway = walksway:lerp(
					CFrame.new(

						(0.07*swaysize) * math.sin(tick() * (2 * humanoid.WalkSpeed/4)),
						(0.07*swaysize) * math.cos(tick() * (4 * humanoid.WalkSpeed/4)),
						0

					)*
						CFrame.Angles(

							0,
							0,
							(-.03*swaysize) * math.sin(tick() * (2 * humanoid.WalkSpeed/4))

						)
					,0.2*sensitivity)
			else
				walksway = walksway:Lerp(CFrame.new(), 0.05*sensitivity)
			end
			--
			local delta = uis:GetMouseDelta()
			--
			if includecamerasway then
				sway = sway:Lerp(Vector3.new(delta.X,delta.Y,delta.X/2), 0.1*sensitivity)
			end
			--
			if includestrafe then
				strafesway = strafesway:Lerp(CFrame.Angles(0,0,-rootpart.CFrame.rightVector:Dot(humanoid.MoveDirection)/(20/swaysize)), 0.1*sensitivity)
			end
			--
			if includejumpsway == true then
				jumpsway = jumpswaygoal.Value
			end
			-- update animation transform for viewmodel
			rightshoulderclone.Transform = rightshoulder.Transform
			leftshoulderclone.Transform = leftshoulder.Transform
			-- cframe the viewmodel
			local finalcf = (camera.CFrame*walksway*jumpsway*strafesway*CFrame.Angles(math.rad(sway.Y*swaysize),math.rad(sway.X*swaysize)/10,math.rad(sway.Z*swaysize)/2))+(camera.CFrame.UpVector*(-1.7-(headoffset.Y+(aimoffset.Value.Y))))+(camera.CFrame.LookVector*(headoffset.Z+(aimoffset.Value.Z)))+(camera.CFrame.RightVector*(-headoffset.X-(aimoffset.Value.X)+(-(sway.X*swaysize)/75)))
			viewmodel:SetPrimaryPartCFrame(finalcf)
		end
	end)
end