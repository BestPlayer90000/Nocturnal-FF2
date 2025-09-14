-- // UI Library Setup
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "Nocturnal",
	Footer = "by NG",
	Icon = 95816097006870,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

-- // Services
local Services = setmetatable({}, {
    __index = function(_, Service)
        return cloneref(game:GetService(Service))
    end
})

local Players = Services.Players
local Workspace = Services.Workspace
local ReplicatedStorage = Services.ReplicatedStorage
local TweenService = Services.TweenService
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local VirtualInputManager = Services.VirtualInputManager

-- // Variables
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = LocalPlayer:GetMouse()

-- // Instances
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character and Character:FindFirstChild("Humanoid")
local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CharacterSoundEvent")

local Camera = workspace.CurrentCamera

local ThrowingDirection = Vector3.new(0, 0, 0)

local ClosestPlayer

--local ThrowType = "Dot"
local ThrowAngle = 45
local BulletAngle = 5
local NormalPower = 0
local AutoPower = true
local AutoAngle = true
local HighestPowerMode = false
local CustomLead = 0 --// 0 is none
local PredictionColor = Color3.fromRGB(21, 25, 255)

local currentBeam = nil
local currentAttachment0 = nil
local currentAttachment1 = nil

local Part = Instance.new("Part")
Part.Transparency = 0.5
Part.Anchored = true
Part.CanCollide = false
Part.CastShadow = false

local PartV2 = Instance.new("Part")
PartV2.Transparency = 0.5
PartV2.Anchored = true
PartV2.CanCollide = false
PartV2.CastShadow = false

-- // Utilities
local Nocturnal = {
    ACBypass = {
        Callback = 0
    },

    Catching = {
        Magnets = false,
        ShowMagHitbox = false,
        FakeBall = false,

        CustomizableRadius = 60,
        CustomizableDelay = 0,
        TweenSpeed = 0,

        PullVector = false,
        PullVectorSpeed = 0,
        PullVectorRadius = 0,

        MagnetsV2 = false,
        ShowMagHitboxV2 = false,
        CustomizableRadiusV2 = 15,
        CustomizableDelayV2 = 0,

        PullVectorV2 = false,
        PullVectorTypeV2 = "Drag",
        PullVectorSpeedV2 = 3,
        PullVectorRadiusV2 = 25,

        DiveVector = false,
        DiveVectorRadius = 0,
    },

    Player = {
        JumpPower = false,
        JP = 50,

        AngleEnhancer = false,
        AngleEnhancerValue = 50,

        WalkSpeed = false,
        WSSpeed = 20,

        CFrameSpeed = false,
        CFSpeed = 0,

        Fly = false,
        FlySpeed = 0,
    },

    Physics = {
        ClickTackleAimbot = false,
        ClickTackleAimbotRadius = 15,

        QuickTP = false,
        QuickTPSpeed = 0,

        ThrowPredictions = false,
        JumpPredictions = false,

        AntiBlock = false,
        AntiJam = false,
        NoJumpCooldown = false,

        BigHead = false,
        BigHeadSize = 0,

        AntiOOB = false,
        NoFreeze = false,

        BlockExtender = false,
        BlockExtenderReach = 0,
        BlockExtenderTransparency = 1,

        ResetOnCatch = false,
        ResetOnCatchDuration = 0.5,
    },

    Automatics = {
        AutoQB = false,
        AutoQBType = "Legit",

        AutoCaptain = false,
        AutoCatch = false,
        AutoCatchRadius = 0,

        AutoSwat = false,
        AutoSwatRadius = 0,

        AutoKick = false,
        AutoKickPower = 0,
        AutoKickAccuracy = 0,

        AutoRush = false,
        AutoRushDelay = 0,

        AutoBoost = false,
        AutoBoostPower = 0,
    },

    Visuals = {
        NoTextures = false,
        CameraZoom = false,
    },

    QBAimbot = {
        Enabled = false,
        AutoAngle = true,
        BeamMode = false,
        AutoChooseThrowType = false,
        Use95PowerMode = false,

        ThrowAngle = 45,
        BulletAngle = 25,
        NormalPower = 0,
        AutoPower = true,
        HighestPowerMode = false,
        CustomLead = 0, -- // 0 is none
        PredictionColor = Color3.fromRGB(21, 25, 255)
    }
}

local Threads = {}
local Hooks = {}
local HandshakeIntegers = {}

-- // AC Bypass
if game.PlaceId == 8204899140 then
    -- // Services
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- // Variables
    local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()

    -- // Instances
    local RemotesFolder   = ReplicatedStorage:WaitForChild("Remotes")
    local HandshakeRemote = RemotesFolder:WaitForChild("CharacterSoundEvent")

    -- // Utilities
    local AnticheatString
    local HandshakeTable

    local Whitelisted = {
        {668, 670, 671, 751, 791, 976},
        {686, 788, 880, 811, 785, 787},
        {764, 699, 671, 751, 774, 978}
    }

    -- // Functions
    local function TableEquality(x, y)
        if rawlen(x) ~= rawlen(y) then
            return false
        end

        for Index = 1, rawlen(x) do
            if rawget(x, Index) ~= rawget(y, Index) then
                return false
            end
        end

        return true
    end

    -- // Metatable Hook
    local MT = getrawmetatable(game)
    setreadonly(MT, false)

    local OldNamecall = MT.__namecall

    MT.__namecall = newcclosure(function(self, ...)
        local Method = getnamecallmethod()
        local Args   = { ... }

        if not checkcaller()
            and self == HandshakeRemote
            and (Method == "FireServer" or Method == "fireServer")
            and rawequal(type(Args[2]), "table")
            and rawlen(Args[2]) == 19
        then
            local Metatable = getrawmetatable(Args[2])
            if Metatable and rawget(Metatable, "__tostring") then
                rawset(Metatable, "__tostring", nil)
            end 

            AnticheatString = Args[1]
            HandshakeTable  = Args[2]
        end

        return OldNamecall(self, ...)
    end)

    -- // Disable functions in PlayerModule.LocalScript
    task.wait()

    for _, fn in pairs(getgc(true)) do
        if type(fn) == "function" then
            local FNInfo = debug.info(fn, "s")
            if FNInfo and FNInfo:find("PlayerModule.LocalScript") then
                local Constants = getconstants(fn)

                if table.find(Constants, 4000002) then
                    hookfunction(fn, function(...)

                    end)
                end
            end
        elseif type(fn) == "table" and rawlen(fn) == 19 and type(rawget(fn, 19)) == "userdata" then
            local Metatable = getrawmetatable(fn)

            if Metatable and rawget(Metatable, "__call") then
                local __call
                __call = hookfunction(rawget(Metatable, "__call"), newcclosure(function(self, ...)
                    local Arguments = { ... }
                    if not (
                        TableEquality(Whitelisted[1], Arguments) or
                        TableEquality(Whitelisted[2], Arguments) or
                        TableEquality(Whitelisted[3], Arguments)
                    ) then
                        return
                    end
                    return __call(self, ...)
                end))
            end
        end
    end

    -- // Replicate handshake
    HandshakeRemote.OnClientEvent:Connect(function(...)
        local Arguments = { ... }
        if Arguments[1] == AnticheatString and HandshakeTable then
            print("Replicated handshake.")
            HandshakeRemote:FireServer(AnticheatString, HandshakeTable, nil)
        end
    end)
end

task.wait()

-- // Functions
local function GetRandomCatchPart()
    local CatchParts = {
        [1] = "CatchRight",
        [2] = "CatchLeft"
    }

    return Character:FindFirstChild(CatchParts[math.random(1, #CatchParts)])
end

local function GetClosestFootball()
    local ClosestFootball = nil
    local ClosestDistance = math.huge

    for _, Object in next, Workspace:GetChildren() do
        if Object.Name == "Football" and Object:IsA("BasePart") then
            local Distance = (Object.Position - HumanoidRootPart.Position).Magnitude

            if Distance < ClosestDistance then
                ClosestFootball = Object
                ClosestDistance = Distance
            end
        end
    end

    return ClosestFootball
end

local function IsBot(Name)
	return string.find(Name, "bot 1") or string.find(Name, "bot 3")
end

local function IsVector3Valid(Position)
	return Position.X == Position.X and Position.Y == Position.Y and Position.Z == Position.Z
end

local function GetScreenPosition(Object)
	local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(Object.Position)
	return Vector2.new(ScreenPoint.X, ScreenPoint.Y), OnScreen
end

local function GetFieldOrientation(PlayerPosition)
	return (PlayerPosition.Z > 0) and 1 or -1
end

local function GetFieldOrientationX(PlayerPosition)
	return (PlayerPosition.X > 0) and 1 or -1
end

local function GetPower(Range, Gravity)
	return math.sqrt(Range * Gravity)
end

local function beamProjectile(g, v0, x0, t1)
    local c = 0.5 * 0.5 * 0.5
    local p3 = 0.5 * g * t1 * t1 + v0 * t1 + x0
    local p2 = p3 - (g * t1 * t1 + v0 * t1) / 3
    local p1 = (c * g * t1 * t1 + 0.5 * v0 * t1 + x0 - c * (x0 + p3)) / (3 * c) - p2

    local curve0 = (p1 - x0).magnitude
    local curve1 = (p2 - p3).magnitude

    local b = (x0 - p3).unit
    local r1 = (p1 - x0).unit
    local u1 = r1:Cross(b).unit
    local r2 = (p2 - p3).unit
    local u2 = r2:Cross(b).unit
    b = u1:Cross(r1).unit

    local cf1 = CFrame.new(
        x0.x, x0.y, x0.z,
        r1.x, u1.x, b.x,
        r1.y, u1.y, b.y,
        r1.z, u1.z, b.z
    )

    local cf2 = CFrame.new(
        p3.x, p3.y, p3.z,
        r2.x, u2.x, b.x,
        r2.y, u2.y, b.y,
        r2.z, u2.z, b.z
    )

    return curve0, -curve1, cf1, cf2
end

function CreateBeamFromCFrames(cf1, cf2, curve0, curve1, color)
    if currentBeam then
        currentBeam:Destroy()
        currentBeam = nil
    end
    if currentAttachment0 then
        currentAttachment0:Destroy()
        currentAttachment0 = nil
    end
    if currentAttachment1 then
        currentAttachment1:Destroy()
        currentAttachment1 = nil
    end

	local a0 = Instance.new("Attachment")
	a0.WorldCFrame = cf1
	a0.Name = "Attachment0"
	a0.Parent = workspace.Terrain

	local a1 = Instance.new("Attachment")
	a1.WorldCFrame = cf2
	a1.Name = "Attachment1"
	a1.Parent = workspace.Terrain

	local beam = Instance.new("Beam")
	beam.Attachment0 = a0
	beam.Attachment1 = a1
	beam.Color = ColorSequence.new(color or Color3.fromRGB(48, 69, 255))
	beam.Width0 = 5
	beam.Width1 = 5
	beam.CurveSize0 = curve0
	beam.CurveSize1 = curve1
	beam.FaceCamera = true
	beam.Segments = 1750
	beam.LightEmission = 10
	beam.Brightness = 10
	beam.Texture = "rbxassetid://18527302693"
	beam.Name = "PredictionBeam"
	beam.Parent = workspace.Terrain

	currentBeam = beam
	currentAttachment0 = a0
	currentAttachment1 = a1

	return beam, a0, a1
end

local function CreateBillboard(text, position)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Adornee = nil
	billboard.AlwaysOnTop = true

	local label = Instance.new("TextLabel", billboard)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Text = text
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position
	part.Transparency = 1
	part.Name = "BillboardPart"
	part.Parent = workspace

	billboard.Adornee = part
	billboard.Parent = part

	return part
end

local function BeamProjectile(g, v0, x0, t1)
	local c = 0.5 * 0.5 * 0.5
	local p3 = 0.5 * g * t1 * t1 + v0 * t1 + x0
	local p2 = p3 - (g * t1 * t1 + v0 * t1) / 3
	local p1 = (c * g * t1 * t1 + 0.5 * v0 * t1 + x0 - c * (x0 + p3)) / (3 * c) - p2

	local curve0 = (p1 - x0).Magnitude
	local curve1 = (p2 - p3).Magnitude

	local b = (x0 - p3).Unit
	local r1 = (p1 - x0).Unit
	local u1 = r1:Cross(b).Unit
	local r2 = (p2 - p3).Unit
	local u2 = r2:Cross(b).Unit
	b = u1:Cross(r1).Unit

	local cf1 = CFrame.new(
		x0.X, x0.Y, x0.Z,
		r1.X, u1.X, b.X,
		r1.Y, u1.Y, b.Y,
		r1.Z, u1.Z, b.Z
	)

	local cf2 = CFrame.new(
		p3.X, p3.Y, p3.Z,
		r2.X, u2.X, b.X,
		r2.Y, u2.Y, b.Y,
		r2.Z, u2.Z, b.Z
	)

	return curve0, -curve1, cf1, cf2
end

local function GetClosestPlayerToMouse()
	local MousePosition = Vector2.new(Mouse.X, Mouse.Y)
	local ClosestPlayer
	local ClosestDistance = math.huge

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= Players.LocalPlayer and player.Team == Players.LocalPlayer.Team then
			local Character = player.Character
			if Character then
				local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
				if HumanoidRootPart then
					local ScreenPosition, onScreen = GetScreenPosition(HumanoidRootPart)
					local Distance = (ScreenPosition - MousePosition).Magnitude
					if Distance < ClosestDistance then
						ClosestPlayer = player
						ClosestDistance = Distance
					end
				end
			end
		end
	end


	for _, bot in pairs(workspace:GetChildren()) do
		if bot.Name == "npcwr" then
			local stationA = bot:FindFirstChild("a")
			local stationB = bot:FindFirstChild("b")

			if stationA and stationB then
				local bot1 = stationA:FindFirstChild("bot 1")
				local bot2 = stationB:FindFirstChild("bot 3")

				if bot1 then
					local bot1HumanoidRootPart = bot1:FindFirstChild("HumanoidRootPart")
					if bot1HumanoidRootPart then
						local bot1ScreenPosition, onScreen = GetScreenPosition(bot1HumanoidRootPart)
						local bot1Distance = (bot1ScreenPosition - MousePosition).Magnitude
						if bot1Distance < ClosestDistance then
							ClosestPlayer = bot1
							ClosestDistance = bot1Distance
						end
					end
				end

				if bot2 then
					local bot2HumanoidRootPart = bot2:FindFirstChild("HumanoidRootPart")
					if bot2HumanoidRootPart then
						local bot2ScreenPosition, onScreen = GetScreenPosition(bot2HumanoidRootPart)
						local bot2Distance = (bot2ScreenPosition - MousePosition).Magnitude
						if bot2Distance < ClosestDistance then
							ClosestPlayer = bot2
							ClosestDistance = bot2Distance
						end
					end
				end
			end
		end
	end

	return ClosestPlayer
end

local function HorizontalRangeOfProjectile(ClosestPlayer)
	local ClosestPlayerRootPart
	if IsBot(ClosestPlayer.Name) then
		ClosestPlayerRootPart = ClosestPlayer:WaitForChild("Head")
	else
		ClosestPlayerRootPart = ClosestPlayer.Character:WaitForChild("Head")
	end

	local HumanoidRootPart = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
	local ProjectileRange = (HumanoidRootPart.Position - ClosestPlayerRootPart.Position)
	local HorizontalRange = Vector2.new(ProjectileRange.X, ProjectileRange.Z).Magnitude
	return HorizontalRange
end

local function CalculateHighSpeedLowAngle(Gravity, Speed)
	local ProjectileRange = HorizontalRangeOfProjectile(ClosestPlayer)
	local Route = CalculateRouteOfPlayer(ClosestPlayer)
	local Equation

	if Route == "Comeback" then
		if ProjectileRange < 150 then
			Equation = 0.43 * math.asin((ProjectileRange * Gravity) / (Speed ^ 2))
		else
			Equation = 0.39 * math.asin((ProjectileRange * Gravity) / (Speed ^ 2))
		end
	elseif Route == "Still" then
		Equation = 0.5 * math.asin((ProjectileRange * Gravity) / (Speed ^ 2))
	elseif Route == "Post" then
		if ProjectileRange < 150 then
			Equation = 0.8 * math.asin((ProjectileRange * Gravity) / (Speed ^ 2))
		else
			Equation = 0.84 * math.asin((ProjectileRange * Gravity) / (Speed ^ 2))
		end
	else
		if ProjectileRange < 150 then
			Equation = 0.82 * math.asin((ProjectileRange * Gravity) / (Speed ^ 2))
		else
			Equation = 0.85 * math.asin((ProjectileRange * Gravity) / (Speed ^ 2))
		end
	end

	return Equation
end

local function CalculateRouteOfPlayer(Player)
	local RouteType
	if not IsBot(Player.Name) then
		local LocalCharacter = LocalPlayer.Character
		local LocalHumanoidRootPart = LocalCharacter:WaitForChild("HumanoidRootPart")

		local Character = Player.Character
		local Humanoid = Character:WaitForChild("Humanoid")
		local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

		local DirectionMoving = Humanoid.MoveDirection
		local DirectionMovingLeftRight = DirectionMoving.X
		local DirectionMovingForward = DirectionMoving.Z

		local Distance = (HumanoidRootPart.Position - LocalHumanoidRootPart.Position)
		local Direction = Distance.Unit
		local Magnitude = Distance.Magnitude

		local X = (Direction * Vector3.new(1, 0, 0))
		local X2 = (Direction * Vector3.new(-1, 0, 0))
		local Z = (Direction * Vector3.new(0, 0, 1))

		local DirectionDot = DirectionMoving:Dot(Distance)
		local Z2

		if GetFieldOrientation(DirectionMoving) == -1 then
			Z2 = (Direction * Vector3.new(0, 0, -1))
		else
			Z2 = (Direction * Vector3.new(0, 0, 1))
		end

		local XZ = (Direction * Vector3.new(1, 0, 1))
		local StreakingRoutesDotProduct = DirectionMoving:Dot(Z2)

		if StreakingRoutesDotProduct >= 0.8 or StreakingRoutesDotProduct <= -0.8 then
			RouteType = "Straight"
		elseif StreakingRoutesDotProduct >= 0.45 or StreakingRoutesDotProduct <= -0.45 then
			RouteType = "Post"
		elseif StreakingRoutesDotProduct >= 0.2 or StreakingRoutesDotProduct <= -0.2  then
			RouteType = "Slant"
		elseif StreakingRoutesDotProduct == 0 then
			RouteType = "Still"
		end

		if DirectionDot < 0 then
			RouteType = "Comeback"
		end
	else
		RouteType = "Straight" --// The bots always run straight
	end

	return RouteType
end

local function CalculateLaunchAngleBullet(Gravity, InitialVelocity)
	local MaxAngle = 40
	local ProjectileRange = HorizontalRangeOfProjectile(ClosestPlayer)
	local Route = CalculateRouteOfPlayer(ClosestPlayer)

	if InitialVelocity <= 0 then
		return
	end

	local SinToTheta = (ProjectileRange * Gravity) / (InitialVelocity ^ 2)

	if SinToTheta > 1 or SinToTheta < -1 then
		return
	end

	local AngleRadians = math.asin(SinToTheta) / 2
	local AngleDegrees = math.deg(AngleRadians)

	if AngleDegrees > MaxAngle then
		return MaxAngle
	end

	return AngleRadians
end

local function CalculateLaunchAngle(Gravity, InitialVelocity)
	local ProjectileRange = HorizontalRangeOfProjectile(ClosestPlayer)
	local LaunchAngle = 0.75 * math.asin(Gravity * ProjectileRange / (InitialVelocity ^ 2))
	return LaunchAngle
end

local function GetTimeOfFlightProjectile(InitialVelocity, RequiredAngle, Gravity)
	local TimeOfFlight = (2 * InitialVelocity * math.sin(RequiredAngle)) / Gravity
	return TimeOfFlight
end

local function KeepPositionInBounds(TargetPosition, MinX, MinZ)
	local ClampedX, ClampedZ

	if TargetPosition.X < -MinX then
		ClampedX = -70.5
	elseif TargetPosition.X > MinX then
		ClampedX = 70.5
	elseif TargetPosition.X > -MinX and TargetPosition.X < MinX then
		ClampedX = TargetPosition.X
	end

	if TargetPosition.Z < -MinZ then
		ClampedZ = -175.5
	elseif TargetPosition.Z > MinZ then
		ClampedZ = 175.5
	elseif TargetPosition.Z > -MinZ and TargetPosition.Z < MinZ then
		ClampedZ = TargetPosition.Z
	end

	local ClampedVector = Vector3.new(ClampedX, TargetPosition.Y, ClampedZ)
	return ClampedVector
end

local function IsMoving(OtherPlayer)
	local Character = OtherPlayer.Character
	local Humanoid = Character:WaitForChild("Humanoid")
	return Humanoid.MoveDirection.Magnitude > 0
end

local function IsBotMoving(BotSpeed)
	return BotSpeed ~= Vector3.new(0, 0, 0)
end

local function GetThrowType(ClosestPlay)
    local RP = HorizontalRangeOfProjectile(ClosestPlay)
    local r = CalculateRouteOfPlayer(ClosestPlay)
    local calculatedThrowType = ""
    if ClosestPlay.Name == "bot 1" or ClosestPlay.Name == "bot 3" then
        calculatedThrowType = "Dime"
        -- //.Text =  calculatedThrowType
    else
        if RP <= 100 and r == "Slant" then
            calculatedThrowType = "Bullet"
            -- //.Text =  calculatedThrowType
        elseif RP > 100 and r == "Slant" then
            calculatedThrowType = "Dive"
            -- //.Text =  calculatedThrowType
        elseif RP <= 150 and r == "Straight" then
            calculatedThrowType = "Dive"
            -- //.Text =  calculatedThrowType
        elseif RP > 150 and r == "Straight" then
            calculatedThrowType = "Dime"
            -- //.Text =  calculatedThrowType
        elseif RP <= 150 and r == "Post" then
            calculatedThrowType = "Dive"
            -- //.Text =  calculatedThrowType
        elseif RP > 150 and r == "Post" then
            calculatedThrowType = "Dime"
            -- //.Text =  calculatedThrowType
        elseif RP <= 100 and r == "Still" then
            calculatedThrowType = "Dot"
            -- //.Text =  calculatedThrowType
        elseif RP > 100 and r == "Still" then
            calculatedThrowType = "Dime"
            -- //.Text =  calculatedThrowType
        elseif RP <= 150 and r == "Comeback" then
            calculatedThrowType = "Dime"
            -- //.Text =  calculatedThrowType
        elseif RP > 150 and r == "Comeback" then
            calculatedThrowType = "Dive"
            -- //.Text =  calculatedThrowType
        end
    end
end

local ThrowTypeOffsets = {
	["Dime"] = Vector3.new(0, 10, 0),
	["Mag"] = Vector3.new(0, 7, 0),
	["Dive"] = Vector3.new(0, 3, 0),
	["Dot"] = Vector3.new(0, 2, 0),
	["Fade"] = Vector3.new(0, 9, -2),
	["Bullet"] = Vector3.new(0, 5, 0),
	["Jump"] = Vector3.new(0, 5, 0),
}

local ThrowType = GetThrowType(GetClosestPlayerToMouse())

--[[local function EstimatedBotVelocity(TimeOfFlight, Bot)
	local HumanoidRootPart = Bot:WaitForChild("HumanoidRootPart")
	local Velocity = HumanoidRootPart.Velocity
	local BotEquation
	local Bot1LeadNumber
	local Bot3LeadNumber

	if IsBotMoving(Velocity) then
		Bot3LeadNumber = {
			["Dime"] = Vector3.new(-1, 1.25, -6),
			["Mag"] = Vector3.new(-2, 2, -11),
			["Dive"] = Vector3.new(-1.25, 1.5, -9),
			["Dot"] = Vector3.new(-0.09, 0.09, -4),
			["Fade"] = Vector3.new(0, 0, 0),
			["Bullet"] = Vector3.new(-5, -1, -1.25),
			["Jump"] = Vector3.new(-1, 2.25, -5)
		}

		Bot1LeadNumber = {
			["Dime"] = Vector3.new(1, 1.25, 6),
			["Mag"] = Vector3.new(2, 2, 11),
			["Dive"] = Vector3.new(1.25, 1.5, 9),
			["Dot"] = Vector3.new(0.09, 0.09, 4),
			["Fade"] = Vector3.new(0, 0, 0),
			["Bullet"] = Vector3.new(5, 1, 1.25),
			["Jump"] = Vector3.new(1, 2, 5)
		}
	else
		Bot3LeadNumber = {
			["Dime"] = Vector3.new(0, 0, 0),
			["Mag"] = Vector3.new(0, 0, 0),
			["Dive"] = Vector3.new(0, 0, 0),
			["Dot"] = Vector3.new(0, 0, 0),
			["Fade"] = Vector3.new(0, 0, 0),
			["Bullet"] = Vector3.new(0, 0, 0),
			["Jump"] = Vector3.new(0, 4, 0)
		}

		Bot1LeadNumber = {
			["Dime"] = Vector3.new(0, 0, 0),
			["Mag"] = Vector3.new(0, 0, 0),
			["Dive"] = Vector3.new(0, 0, 0),
			["Dot"] = Vector3.new(0, 0, 0),
			["Fade"] = Vector3.new(0, 0, 0),
			["Bullet"] = Vector3.new(0, 0, 0),
			["Jump"] = Vector3.new(0, 5, 0)
		}
	end

	local TimeAccount = Velocity * TimeOfFlight
	if Bot.Name == "bot 3" and IsBotMoving(Velocity) then
		BotEquation = HumanoidRootPart.Position + TimeAccount + Bot3LeadNumber[ThrowType]
	elseif Bot.Name == "bot 1" and IsBotMoving(Velocity) then
		BotEquation = HumanoidRootPart.Position + TimeAccount + Bot1LeadNumber[ThrowType]
	elseif Bot.Name == "bot 3" and not IsBotMoving(Velocity) then
		BotEquation = HumanoidRootPart.Position + Bot3LeadNumber[ThrowType]
	elseif Bot.Name == "bot 1" and not IsBotMoving(Velocity) then
		BotEquation = HumanoidRootPart.Position
	end

	return BotEquation
end--]]

local function isBotMoving(SpeedOFBot)
    if SpeedOFBot == Vector3.new(0,0,0) then
        return false
    else
        return true
    end
end

local function BotEstimatedVel(Time, Bot)
    local Speed = Bot:FindFirstChild("HumanoidRootPart").Velocity
    local TOFF = Time
    local TypeThroww = ThrowType
    local Botequation;
    local LeadNumtabBot3;
    local LeadNumtabBot1;
    if isBotMoving(Bot:FindFirstChild("HumanoidRootPart").Velocity) then
        LeadNumtabBot3 = {
            ["Dime"] = Vector3.new(-1, 1.25, -6),
            ["Mag"] = Vector3.new(-2, 2, -11),
            ["Dive"] = Vector3.new(-1.25, 1.5, -9),
            ["Dot"] = Vector3.new(-0.09, 0.09, -4),
            ["Fade"] = Vector3.new(0, 0, 0),
            ["Bullet"] = Vector3.new(-5, -1, -1.25),
            ["Jump"] = Vector3.new(-1, 2.25, -5)
        }
        LeadNumtabBot1 = {
            ["Dime"] = Vector3.new(1, 1.25, 6),
            ["Mag"] = Vector3.new(2, 2, 11),
            ["Dive"] = Vector3.new(1.25, 1.5, 9),
            ["Dot"] = Vector3.new(0.09, 0.09, 4),
            ["Fade"] = Vector3.new(0, 0, 0),
            ["Bullet"] = Vector3.new(5, 1, 1.25),
            ["Jump"] = Vector3.new(1, 2, 5)
        }
    else
        LeadNumtabBot3 = {
            ["Dime"] = Vector3.new(0, 0, 0),
            ["Mag"] = Vector3.new(0, 0, 0),
            ["Dive"] = Vector3.new(0, 0, 0),
            ["Dot"] = Vector3.new(0, 0, 0),
            ["Fade"] = Vector3.new(0, 0, 0),
            ["Bullet"] = Vector3.new(0, 0, 0),
            ["Jump"] = Vector3.new(0, 4, 0)
        }
        LeadNumtabBot1 = {
            ["Dime"] = Vector3.new(0, 0, 0),
            ["Mag"] = Vector3.new(0, 0, 0),
            ["Dive"] = Vector3.new(0, 0, 0),
            ["Dot"] = Vector3.new(0, 0, 0),
            ["Fade"] = Vector3.new(0, 0, 0),
            ["Bullet"] = Vector3.new(0, 0, 0),
            ["Jump"] = Vector3.new(0, 5, 0)
        }
    end
    local TimeAccount = (Speed * Time)
    if Bot.Name == "bot 3"  and isBotMoving(Bot:FindFirstChild("HumanoidRootPart").Velocity) then
        Botequation = Bot:FindFirstChild("HumanoidRootPart").Position + (TimeAccount) +  LeadNumtabBot3[TypeThroww]
    elseif Bot.Name == "bot 1"  and isBotMoving(Bot:FindFirstChild("HumanoidRootPart").Velocity) then
        Botequation = Bot:FindFirstChild("HumanoidRootPart").Position + (TimeAccount) +  LeadNumtabBot1[TypeThroww]
    elseif Bot.Name == "bot 3" and not isBotMoving(Bot:FindFirstChild("HumanoidRootPart").Velocity) then
        Botequation = Bot:FindFirstChild("HumanoidRootPart").Position + LeadNumtabBot3[TypeThroww]
    elseif Bot.Name == "bot 1" and not isBotMoving(Bot:FindFirstChild("HumanoidRootPart").Velocity) then
        Botequation = Bot:FindFirstChild("HumanoidRootPart").Position
    end
        
    return Botequation
end

local function GetReceiverTargetPosition(TimeOfFlight, Receiver)
    local Character = Receiver.Character
    if not Character then return end

    local Humanoid = Character:WaitForChild("Humanoid")
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local Head = Character:WaitForChild("Head")

    local Velocity = Humanoid.MoveDirection
    local Velocity2 = HumanoidRootPart.Velocity


    local HighestPowerMode = HighestPowerMode or false
    local CustomLead = Nocturnal.QBAimbot.CustomLead or 0

    local FieldOrientation = GetFieldOrientation(Velocity)
    local FieldOrientationX = GetFieldOrientationX(Velocity)

    local LeadNumber

    if IsMoving(Receiver) then
        if FieldOrientation == 1 and FieldOrientationX == 1 then
            LeadNumber = {
                Dime = Vector3.new(1, 1.25, 6),
                Mag = Vector3.new(2, 2, 11),
                Dive = Vector3.new(1.25, 1.5, 9),
                Dot = Vector3.new(0.09, 0.09, 4),
                Fade = Vector3.new(0, 0, 0),
                Bullet = Vector3.new(5, 1, 1.25),
                Jump = Vector3.new(1, 2.25, 5)
            }
        elseif FieldOrientation == -1 and FieldOrientationX == -1 then
            LeadNumber = {
                Dime = Vector3.new(-1, 1.25, -6),
                Mag = Vector3.new(-2, 2, -11),
                Dive = Vector3.new(-1.25, 1.5, -9),
                Dot = Vector3.new(-0.09, 0.09, -4),
                Fade = Vector3.new(0, 0, 0),
                Bullet = Vector3.new(-5, -1, -1.25),
                Jump = Vector3.new(-1, 2.25, -5)
            }
        elseif FieldOrientation == 1 and FieldOrientationX == -1 then
            LeadNumber = {
                Dime = Vector3.new(-1, 1.25, 6),
                Mag = Vector3.new(-2, 2, 11),
                Dive = Vector3.new(-1.25, 1.5, 9),
                Dot = Vector3.new(-0.09, 0.09, 4),
                Fade = Vector3.new(0, 0, 0),
                Bullet = Vector3.new(-5, -1, 1.25),
                Jump = Vector3.new(-1, 2.25, 5)
            }
        elseif FieldOrientation == -1 and FieldOrientationX == 1 then
            LeadNumber = {
                Dime = Vector3.new(1, 1.25, -6),
                Mag = Vector3.new(2, 2, -11),
                Dive = Vector3.new(1.25, 1.5, -9),
                Dot = Vector3.new(0.09, 0.09, -4),
                Fade = Vector3.new(0, 0, 0),
                Bullet = Vector3.new(5, -1, -1.25),
                Jump = Vector3.new(1, 2.25, -5)
            }
        else
            LeadNumber = {
                Dime = Vector3.new(0, 0, 0),
                Mag = Vector3.new(0, 0, 0),
                Dive = Vector3.new(0, 0, 0),
                Dot = Vector3.new(0, 0, 0),
                Fade = Vector3.new(0, 0, 0),
                Bullet = Vector3.new(0, 0, 0),
                Jump = Vector3.new(0, 5, 0)
            }
        end
    else
        LeadNumber = {
            Dime = Vector3.new(0, 0, 0),
            Mag = Vector3.new(0, 0, 0),
            Dive = Vector3.new(0, 0, 0),
            Dot = Vector3.new(0, 0, 0),
            Fade = Vector3.new(0, 0, 0),
            Bullet = Vector3.new(0, 0, 0),
            Jump = Vector3.new(0, 5, 0)
        }
    end

    local ThrowTypeAccountability
    if HighestPowerMode then
        ThrowTypeAccountability = Velocity2 * TimeOfFlight
    else
        if CustomLead ~= 0 then
            if ThrowType == "Bullet" then
                ThrowTypeAccountability = Vector3.new(Velocity.X, 0, Velocity.Z) * CustomLead * TimeOfFlight
            else
                ThrowTypeAccountability = Velocity * CustomLead * TimeOfFlight
            end
        else
            if ThrowType == "Bullet" then
                ThrowTypeAccountability = Vector3.new(Velocity.X, 0, Velocity.Z) * TimeOfFlight
            else
                ThrowTypeAccountability = Velocity2 * TimeOfFlight
            end
        end
    end

    local Equation
    if Nocturnal.QBAimbot.HighestPowerMode then
        if IsMoving(Receiver) then
            Equation = HumanoidRootPart.Position + ThrowTypeAccountability + (LeadNumber[ThrowType] or Vector3.new())
        elseif not IsMoving(Receiver) and ThrowType == "Jump" then
            Equation = HumanoidRootPart.Position + ThrowTypeAccountability + Vector3.new(0, 6, 0)
        else
            Equation = HumanoidRootPart.Position
        end
    else
        if IsMoving(Receiver) then
            Equation = Head.Position + ThrowTypeAccountability + (LeadNumber[ThrowType] or Vector3.new())
        elseif not IsMoving(Receiver) and ThrowType == "Jump" then
            Equation = Head.Position + ThrowTypeAccountability + Vector3.new(0, 6, 0)
        else
            Equation = Head.Position
        end
    end

    return Equation
end


local function VelocityNeededToReachPosition(Angle, StartPosition, EndPosition, Gravity, Time)
	local VelocityNeeded = (EndPosition - StartPosition - 0.5 * Gravity * Time ^ 2) / Time
	local Y = (EndPosition - StartPosition)
	local XZ1 = (Y * Vector3.new(0.25, 0, 0.25))
	local XZ2 = Vector2.new(Y.X, Y.Z).Magnitude
	local VelocityOverTime = XZ2 / Time
	local NotVector = XZ1 / XZ1.Magnitude
	local EquationDerived = NotVector * VelocityOverTime
	local EstimatedVelocity = EquationDerived + Vector3.new(0, VelocityNeeded.Y, 0)
	local TotalVelocity = StartPosition + EstimatedVelocity
	local Direction = (TotalVelocity - StartPosition).Unit
	local Power = EstimatedVelocity.Magnitude + 0.05

	if Nocturnal.QBAimbot.HighestPowerMode then
		return EstimatedVelocity, Direction, math.clamp(math.round(Power), 85, 95)
	else
		return EstimatedVelocity, Direction, math.clamp(math.round(Power), 0, 95)
	end
end

local function ThrowFootball(Football, StartPosition, Direction, Power)
	local ThrowRemote = Football.Handle.RemoteEvent

	local FakeRemoteEvent = Instance.new("RemoteEvent")
	FakeRemoteEvent.Name = "RemoteEvent"
	FakeRemoteEvent.Parent = Football.Handle

	if (game.PlaceId == 8204899140) then
		ThrowRemote:FireServer("Clicked", StartPosition, Direction, 1, Power)
	elseif (game.PlaceId == 8206123457) then
		ThrowRemote:FireServer("Clicked", StartPosition, Direction, Power)
	end

	FakeRemoteEvent:Destroy()
end


--[[local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local BallCarrier = ReplicatedStorage.Values.Carrier.Value
local LocalPlayer = Players.LocalPlayer
local charplr = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp2 = charplr:FindFirstChild("HumanoidRootPart")
local hum2 = charplr:FindFirstChild("Humanoid")
local aRushOn = Nocturnal.Automatics.AutoRush
local agDist = 20
LocalPlayer.CharacterAdded:Connect(function(character)
    charplr = character
end)

local function doGuarding()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player == BallCarrier and BallCarrier ~= nil then
            local car = player.Character
            if car and car:FindFirstChild("Football") then
                local hrp = car:FindFirstChild("HumanoidRootPart")
                local hum = car:FindFirstChild("Humanoid")
                if hrp and hrp2 and hum and hum2 then
                    local WS = 20
                    local distance = (hrp.Position - hrp2.Position).magnitude
                    local TimeToGet = distance / WS
                    if distance <= agDis then
                        local equation = hrp.Position + (hum.MoveDirection * TimeToGet * WS)
                        hum2:MoveTo(equation)
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait() do
        if aRushOn then
            doGuarding()
        end
    end
end)--]]


local function GetBallCarrier()
    for Index, Player in next, Players:GetPlayers() do
        if Player and Player.Character and Player.Team ~= LocalPlayer.Team then
            local Tool = Player.Character:FindFirstChildWhichIsA("Tool")

            if Tool then
                return Player.Character
            end
        end
    end
end



local function CharacterHasFootball()
    if Character:FindFirstChild("Football") then
        return true
    end

    return false
end

-- // Loops
Threads.FootballMagnets = task.spawn(function()
    while task.wait() do
        local Football = GetClosestFootball()

        if not Football or not Nocturnal.Catching.Magnets then
            continue
        end

        local MinimumTeleportations = 10
        local MaximumTeleportations = 30

        local CatchPart = GetRandomCatchPart()

        if not CatchPart then
            continue
        end

        local Distance = (Football.Position - CatchPart.Position).Magnitude
        local NormalizedDistance = Distance / Nocturnal.Catching.CustomizableRadius
        local DistanceFactor = math.clamp(1 - NormalizedDistance, 0, 1)

        local Speed = Football.Velocity.Magnitude
        local SpeedFactor = math.clamp(Speed / 100, 0, 1)

        local Calculations = math.ceil(
            math.pow(DistanceFactor * SpeedFactor, 2) * 
            (MaximumTeleportations - MinimumTeleportations) + 
            MinimumTeleportations
        )

        local Delay = Nocturnal.Catching.CustomizableDelay * (1 - SpeedFactor) * (1 + NormalizedDistance)

        local Direction = (Football.Position - CatchPart.Position).Unit
        local AngleFactor = math.abs(Direction:Dot(CatchPart.CFrame.LookVector))

        for Index = 1, Calculations do
            firetouchinterest(CatchPart, Football, 0)
            firetouchinterest(CatchPart, Football, 0)
            task.wait(Delay)
            firetouchinterest(CatchPart, Football, 1)
            firetouchinterest(CatchPart, Football, 1)
        end
    end
end)

Threads.AutoRushQB = task.spawn(function()
    while task.wait() do
        if not Nocturnal.Automatics.AutoRush then
            continue
        end

        local BallCarrier = GetBallCarrier()

        if BallCarrier and BallCarrier:FindFirstChild("HumanoidRootPart") then
            local Delay = tonumber(Nocturnal.Automatics.AutoRushDelay) or 0.1

            task.wait(Delay)

            if Humanoid and BallCarrier:FindFirstChild("HumanoidRootPart") then
                local Carrier = not game.PlaceId == 8206123457 and ReplicatedStorage.Flags.Carrier.Value

                if Carrier and Carrier.Team ~= LocalPlayer.Team then
                    Humanoid:MoveTo(Carrier.Character.Torso.Position)
                end
            end
        end
    end
end)

Threads.WalkSpeed = task.spawn(function()
    while task.wait(0.1) do
        if Nocturnal.Player.WalkSpeed and Humanoid then
            Humanoid.WalkSpeed = Nocturnal.Player.WSSpeed
        end
    end
end)

Threads.JumpPower = task.spawn(function()
    while task.wait(0.1) do
        if Nocturnal.Player.JumpPower and Humanoid then
            Humanoid.JumpPower = Nocturnal.Player.JP
        end
    end
end)

Threads.CFrameSpeed = task.spawn(function()
    while task.wait(0.1) do
        if Nocturnal.Player.CFrameSpeed and Humanoid then
            if Humanoid.MoveDirection.Magnitude > 0 then
                HumanoidRootPart.CFrame += Humanoid.MoveDirection * (Nocturnal.Player.CFSpeed / 58.5)
            end
        end
    end
end)

Threads.PullVector = task.spawn(function()
    while task.wait(0.1) do
        local Football = GetClosestFootball()
        
        if Football and Nocturnal.Catching.PullVector then
            local Distance = (HumanoidRootPart.Position - Football.Position).Magnitude
            local Direction = (HumanoidRootPart.Position - Football.Position).Unit

            if Distance <= Nocturnal.Catching.PullVectorRadius then
                HumanoidRootPart.Velocity = Direction * math.min((Nocturnal.Catching.PullVectorSpeed * 25), Distance)
            end
        end
    end
end)

Threads.NoJumpCooldown = task.spawn(function()
    while task.wait() do
        if Nocturnal.Physics.NoJumpCooldown then
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end
    end
end)

Threads.AntiJam = task.spawn(function()
    while task.wait() do
        if Nocturnal.Physics.AntiJam and Character then
            local Head = Character:FindFirstChild("Head")
            local Torso = Character:FindFirstChild("Torso")
            local IsRunning = Humanoid:GetState() == Enum.HumanoidStateType.Running

            if Head and Torso then
                local CanCollide = not Nocturnal.Physics.AntiJam
                if not IsRunning then
                    CanCollide = true
                end

                Head.CanCollide = CanCollide
                Torso.CanCollide = CanCollide
            end
        end
    end
end)

Mouse.Button1Down:Connect(function()
    if Nocturnal.Physics.ClickTackleAimbot then
        local BallCarrier = GetBallCarrier()

        if BallCarrier then
            local Distance = (BallCarrier.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude

            if Distance <= Nocturnal.Physics.ClickTackleAimbotRadius then
                HumanoidRootPart.CFrame = BallCarrier.HumanoidRootPart.CFrame
            end
        end
    end
end)

local QuickTPCooldown = tick()

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
    if GameProcessedEvent then
        return
    end

    if Input.KeyCode ~= Enum.KeyCode.F then
        return
    end

    if not Humanoid or not HumanoidRootPart then
        return
    end

    if Nocturnal.Physics.QuickTP then
        if (tick() - QuickTPCooldown) >= 0.1 then
            local Acceleration = 2 + (Nocturnal.Physics.QuickTPSpeed / 4)
            HumanoidRootPart.CFrame += Humanoid.MoveDirection * Acceleration
            QuickTPCooldown = tick()
        end
    end
end)

Threads.ResetOnCatch = task.spawn(function()
    while task.wait() do 
        if Nocturnal.Physics.ResetOnCatch and CharacterHasFootball() then
            task.wait(Nocturnal.Physics.ResetOnCatchDuration)

            Humanoid.Health = 0
        end
    end
end)

Threads.AutoCatch = task.spawn(function()
    while task.wait() do
        if Nocturnal.Automatics.AutoCatch then
            local Football = GetClosestFootball()

            if Football and HumanoidRootPart then
                local Distance = (HumanoidRootPart.Position - Football.Position).Magnitude

                if Distance <= Nocturnal.Automatics.AutoCatchRadius then
                    Remote:fireServer(unpack({
                        [1] = "PlayerActions",
                        [2] = "catch"
                    }))
                end
            end
        end
    end
end)

Threads.AutoSwat = task.spawn(function()
    while task.wait() do
        if Nocturnal.Automatics.AutoSwat then
            local Football = GetClosestFootball()

            if Football and HumanoidRootPart then
                local Distance = (HumanoidRootPart.Position - Football.Position).Magnitude

                if Distance <= Nocturnal.Automatics.AutoSwatRadius then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                end
            end
        end
    end
end)

Threads.CameraZoomIncreasement = task.spawn(function()
    while task.wait() do
        if Nocturnal.Visuals.CameraZoom then
            LocalPlayer.CameraMaxZoomDistance = 1000
        end
    end
end)

local Boundaries = {}

if not game.PlaceId == 8206123457 then
    for Index, Object in next, Workspace.Models.Boundaries:GetChildren() do
        Boundaries[#Boundaries + 1] = Object
    end
end

Threads.AngleEnhancer = task.spawn(function()
    local AngleTick = os.clock()
    local OldLookVector = Vector3.zero
    local ShiftLockEnabled = false
    local LastEnabled = false

    UserInputService:GetPropertyChangedSignal("MouseBehavior"):Connect(function()
        ShiftLockEnabled = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
    end)

    Humanoid.Jumping:Connect(function()
        if Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then return end
        if os.clock() - AngleTick > 0.2 then return end
        if not Nocturnal.Player.AngleEnhancer then return end
        task.wait(0.05)

        HumanoidRootPart.AssemblyLinearVelocity += Vector3.new(0, Nocturnal.Player.AngleEnhancerValue - 50, 0)
    end)

    while true do
        task.wait()

        local Character = LocalPlayer.Character
        if not Character then continue end

        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if not HumanoidRootPart then continue end

        local Humanoid = Character:FindFirstChild("Humanoid")
        if not Humanoid then continue end

        local LookVector = HumanoidRootPart.CFrame.LookVector
        local Difference = (OldLookVector - LookVector).Magnitude

        if not ShiftLockEnabled and LastEnabled then
            AngleTick = os.clock()
        end
        
        if (os.clock() - AngleTick < 0.2) and Nocturnal.Player.AngleEnhancer then
            Humanoid.JumpPower = (Nocturnal.Player.JumpPower and Nocturnal.Player.JP or 50) + (Nocturnal.Player.AngleEnhancerValue - 50)
        elseif not Nocturnal.Player.AngleEnhancer then
            Humanoid.JumpPower = (Nocturnal.Player.JumpPower and Nocturnal.Player.JP or 50)
        end

        OldLookVector = LookVector
        LastEnabled = ShiftLockEnabled
    end
end)

Character.DescendantAdded:Connect(function(Child)
    if Nocturnal.Physics.AntiBlock and string.find(Child.Name, "FFmover") then
        Child:Destroy()
    end
end)

local Blacklisted = { "KICKOFF", "PUNT", "PAT" }

Threads.AutoQB = task.spawn(function()
    while task.wait() do
        if Nocturnal.Automatics.AutoQB then
            local StatusValue = (game.PlaceId ~= 8206123457) and ReplicatedStorage:FindFirstChild("Flags") and ReplicatedStorage.Flags:FindFirstChild("Status")
            local PossessionTag = ReplicatedStorage:FindFirstChild("Flags") and ReplicatedStorage.Flags:FindFirstChild("PossessionTag")
            local StatusTag = ReplicatedStorage.Flags:FindFirstChild("StatusTag")
            local Football = Workspace:FindFirstChild("Football")

            if HumanoidRootPart and StatusValue and StatusValue.Value == "PrePlay"
                and Football
                and PossessionTag and PossessionTag.Value == LocalPlayer.Team.Name
                and StatusTag and not table.find(Blacklisted, StatusTag.Value) then

                local TargetPosition = Football.Position + Vector3.new(0, 0, 0)

                if Nocturnal.Automatics.AutoQBType == "Legit" then
                    Humanoid:MoveTo(TargetPosition)
                elseif Nocturnal.Automatics.AutoQBType == "Precise" then
                    HumanoidRootPart.CFrame = CFrame.new(TargetPosition + Vector3.new(0, 2, -0.5))
                elseif Nocturnal.Automatics.AutoQBType == "Rage" then
                    HumanoidRootPart.CFrame = CFrame.new(TargetPosition + Vector3.new(0, 2, 0))
                end
            end
        end
    end
end)

local FinishLine = not game.PlaceId == 8206123457 and Workspace.Models.LockerRoomA.FinishLine or Instance.new('Part')

FinishLine:GetPropertyChangedSignal("CFrame"):Connect(function()
    if Nocturnal.Automatics.AutoCaptain and FinishLine.Position.Y > 0 then
        for Index = 1, 7, 1 do
            task.wait(0.20)
            HumanoidRootPart.CFrame = FinishLine.CFrame + Vector3.new(0, 2, 0)
        end
    end
end)

LocalPlayer.PlayerGui.ChildAdded:Connect(function(Child)
    if Child.Name == "KickerGui" and Nocturnal.Automatics.AutoKick then
        local Cursor = Child:FindFirstChild("Cursor", true)

        repeat task.wait() until Cursor.Position.Y.Scale < 0.01 + ((100 - Nocturnal.Automatics.AutoKickPower) * 0.012)
        mouse1click()
        repeat task.wait() until Cursor.Position.Y.Scale > 0.9 - ((100 - Nocturnal.Automatics.AutoKickAccuracy) * 0.001)
        mouse1click()
    end
end)

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
	local Character = LocalPlayer.Character
	if GameProcessed or (Input.KeyCode ~= Enum.KeyCode.Q) or not Character or not Nocturnal.QBAimbot.Enabled then
		return
	end

	local Football = Character:FindFirstChildOfClass("Tool")
	if not Football then return end

    local ThrowType

	local StartPosition = Character:WaitForChild("Head").Position
    local ThrowType = GetThrowType(ClosestPlayer)

	if not ClosestPlayer or not ClosestPlayer:IsA("Player") then
		return
	end

	local ReceiverRoute = CalculateRouteOfPlayer(ClosestPlayer)
	local N = (ReceiverRoute == "Straight") and 4.3 or 5.5

	local Initial = math.clamp(math.round(GetPower(HorizontalRangeOfProjectile(ClosestPlayer), 28)), 0, 95) + N
	local Angle
	if ThrowType == "Fade" then
		Angle = 85
	elseif ThrowType == "Bullet" then
		Angle = BulletAngle
	else
		Angle = ThrowAngle
	end

	if Nocturnal.QBAimbot.HighestPowerMode then
		Initial = math.clamp(GetPower(HorizontalRangeOfProjectile(ClosestPlayer), 28), 85, 95)
	else
		if Nocturnal.QBAimbot.AutoPower then
			Initial = math.clamp(math.round(GetPower(HorizontalRangeOfProjectile(ClosestPlayer), 28)), 0, 95) + N
		else
			Initial = NormalPower
		end
	end

	if ThrowType == "Bullet" then
		Initial = 95
	end

	if ThrowType == "Fade" then
		Initial = 65
	end

	local ToLaunchAngle
	if Nocturnal.QBAimbot.HighestPowerMode then
		if Nocturnal.QBAimbot.AutoAngle then
			ToLaunchAngle = CalculateHighSpeedLowAngle(28, Initial)
		else
			ToLaunchAngle = math.rad(Angle)
		end
	else
		if Nocturnal.QBAimbot.AutoAngle then
			if ThrowType == "Fade" then
				ToLaunchAngle = math.rad(85)
			elseif ThrowType == "Bullet" then
				ToLaunchAngle = math.clamp(CalculateLaunchAngleBullet(28, Initial), 0, 1)
			else
				ToLaunchAngle = math.clamp(CalculateLaunchAngle(28, Initial), 0, 2.61799388)
			end
		else
			ToLaunchAngle = math.rad(Angle)
		end
	end

	local TimeOfFlight = GetTimeOfFlightProjectile(Initial, ToLaunchAngle, 28)
	local EndPosition

	if IsBot(ClosestPlayer.Name) then
		EndPosition = BotEstimatedVel(TimeOfFlight, ClosestPlayer)
	else
		EndPosition = GetReceiverTargetPosition(TimeOfFlight, ClosestPlayer)
	end

	local Velocity, DirectionToThrow, Power = VelocityNeededToReachPosition(ToLaunchAngle, StartPosition, EndPosition, Vector3.new(0, -28, 0), TimeOfFlight)

	if AutoPower then
		if ThrowType == "Fade" then
			Power = 65
		elseif ThrowType == "Bullet" then
			Power = 95
		end
	else
		Power = NormalPower
	end

	ThrowFootball(Football, StartPosition, StartPosition + ThrowingDirection * 10000, Power)
end)

RunService.Heartbeat:Connect(function()
    if Nocturnal.QBAimbot.Enabled then
        ClosestPlayer = GetClosestPlayerToMouse()
        local ThrowType = GetThrowType(ClosestPlayer)

        for _, Object in pairs(Workspace:GetChildren()) do
            if Object.Name == "BeamVisual" or Object.Name == "BillboardPart" or Object.Name == "PredictionBeam" then
                Object:Destroy()
            end
        end

        if not ClosestPlayer then return end

        local Character = LocalPlayer.Character
        if not Character then return end

        local Head = Character:FindFirstChild("Head")
        if not Head then return end

        local Football = Character:FindFirstChild("Football")
        if not Football then return end

        local ReceiverRoute = CalculateRouteOfPlayer(ClosestPlayer)
        local N = (ReceiverRoute == "Straight") and 4.3 or 5.5

        local Power
        local Initial = math.clamp(math.round(GetPower(HorizontalRangeOfProjectile(ClosestPlayer), 28)), 0, 95) + N

        if Nocturnal.QBAimbot.HighestPowerMode then
            Initial = math.clamp(GetPower(HorizontalRangeOfProjectile(ClosestPlayer), 28), 85, 95)
        else
            if Nocturnal.QBAimbot.AutoPower then
                if Power then
                    Initial = Power
                else
                    Initial = math.clamp(math.round(GetPower(HorizontalRangeOfProjectile(ClosestPlayer), 28)), 0, 95) + N
                end
            else
                Initial = NormalPower
            end
        end

        local Angle
        if ThrowType == "Fade" then
            Angle = 85
        elseif ThrowType == "Bullet" then
            Angle = 5
        else
            Angle = 45
        end

        local LaunchAngle
        if Nocturnal.QBAimbot.HighestPowerMode then
            if Nocturnal.QBAimbot.AutoAngle then
                LaunchAngle = CalculateHighSpeedLowAngle(28, Initial)
            else
                LaunchAngle = math.rad(Angle)
            end
        else
            if Nocturnal.QBAimbot.AutoAngle then
                if ThrowType == "Fade" then
                    LaunchAngle = math.rad(85)
                elseif ThrowType == "Bullet" then
                    LaunchAngle = math.clamp(CalculateLaunchAngleBullet(28, Initial), 0, 1)
                else
                    LaunchAngle = math.clamp(CalculateLaunchAngle(28, Initial), 0, 2.61799388)
                end
            else
                LaunchAngle = math.rad(Angle)
            end
        end

        local TimeOfFlight = GetTimeOfFlightProjectile(Initial, LaunchAngle, 28)
        local StartPosition = Head.Position
        local TargetPosition

        if IsBot(ClosestPlayer.Name) then
            TargetPosition = BotEstimatedVel(TimeOfFlight, ClosestPlayer)
        else
            TargetPosition = GetReceiverTargetPosition(TimeOfFlight, ClosestPlayer)
        end

        local Velocity, Direction, Power = VelocityNeededToReachPosition(LaunchAngle, StartPosition, TargetPosition, Vector3.new(0, -28, 0), TimeOfFlight)

        if IsVector3Valid(Direction) and IsVector3Valid(TargetPosition) then
            if Nocturnal.QBAimbot.BeamMode then
                ThrowingDirection = Direction
                local curve0, curve1, cf1, cf2 = BeamProjectile(Vector3.new(0, -28, 0), Velocity, StartPosition, TimeOfFlight)
                CreateBeamFromCFrames(cf1, cf2, curve0, curve1, Color3.fromRGB(21, 25, 255))

                CreateBillboard("Power: " .. tostring(Power), StartPosition)
                CreateBillboard("Angle: " .. tostring(math.deg(LaunchAngle)), StartPosition + Vector3.new(0, 2, 0))
                CreateBillboard("Target", TargetPosition)
                -- >CreateBillboard("ThrowType: " .. ThrowType, StartPosition + Vector3.new(0, 4, 0))
            end
        end
    end
end)

task.wait()

-- // AC Bypass Section

-- // Create six main tabs
local CatchingTab = Window:AddTab("Catching", "user")
local PlayerTab = Window:AddTab("Player", "user")
local PhysicsTab = Window:AddTab("Physics", "user")
local AutomaticsTab = Window:AddTab("Automatics", "user")
local VisualsTab = Window:AddTab("Visuals", "user")
local QBAimbotTab = Window:AddTab("QB Aimbot", "user")
local MiscTab = Window:AddTab("Misc", "user")

-- // ============================
-- // Catching Tab Controls
-- // ============================
local CatchingGB = CatchingTab:AddLeftGroupbox("Catching")
CatchingGB:AddToggle("MagnetsToggle", {
    Text = "Magnets",
    Default = Nocturnal.Catching.Magnets,
    Callback = function(Value) Nocturnal.Catching.Magnets = Value end
})
CatchingGB:AddToggle("ShowMagHitboxToggle", {
    Text = "Show Magnet Hitbox",
    Default = Nocturnal.Catching.ShowMagHitbox,
    Callback = function(Value) Nocturnal.Catching.ShowMagHitbox = Value end
})
CatchingGB:AddToggle("FakeBallToggle", {
    Text = "Fake Ball",
    Default = Nocturnal.Catching.FakeBall,
    Callback = function(Value) Nocturnal.Catching.FakeBall = Value end
})
CatchingGB:AddSlider("MagRadiusSlider", {
    Text = "Magnet Radius",
    Default = Nocturnal.Catching.CustomizableRadius,
    Min = 0, Max = 100, Rounding = 0,
    Callback = function(Value) Nocturnal.Catching.CustomizableRadius = Value end
})
CatchingGB:AddSlider("MagDelaySlider", {
    Text = "Magnet Delay",
    Default = Nocturnal.Catching.CustomizableDelay,
    Min = 0, Max = 5, Rounding = 1,
    Callback = function(Value) Nocturnal.Catching.CustomizableDelay = Value end
})
CatchingGB:AddSlider("TweenSpeedSlider", {
    Text = "Tween Speed",
    Default = Nocturnal.Catching.TweenSpeed,
    Min = 0, Max = 20, Rounding = 1,
    Callback = function(Value) Nocturnal.Catching.TweenSpeed = Value end
})
CatchingGB:AddToggle("PullVectorToggle", {
    Text = "Pull Vector",
    Default = Nocturnal.Catching.PullVector,
    Callback = function(Value) Nocturnal.Catching.PullVector = Value end
})
CatchingGB:AddSlider("PullVectorSpeedSlider", {
    Text = "Pull Vector Speed",
    Default = Nocturnal.Catching.PullVectorSpeed,
    Min = 0, Max = 20, Rounding = 1,
    Callback = function(Value) Nocturnal.Catching.PullVectorSpeed = Value end
})
CatchingGB:AddSlider("PullVectorRadiusSlider", {
    Text = "Pull Vector Radius",
    Default = Nocturnal.Catching.PullVectorRadius,
    Min = 0, Max = 100, Rounding = 0,
    Callback = function(Value) Nocturnal.Catching.PullVectorRadius = Value end
})

-- // V2 Magnet controls
CatchingGB:AddToggle("MagnetsV2Toggle", {
    Text = "Magnets V2",
    Default = Nocturnal.Catching.MagnetsV2,
    Callback = function(Value) Nocturnal.Catching.MagnetsV2 = Value end
})
CatchingGB:AddToggle("ShowMagHitboxV2Toggle", {
    Text = "Show Magnet Hitbox V2",
    Default = Nocturnal.Catching.ShowMagHitboxV2,
    Callback = function(Value) Nocturnal.Catching.ShowMagHitboxV2 = Value end
})
CatchingGB:AddSlider("MagRadiusV2Slider", {
    Text = "Magnet Radius V2",
    Default = Nocturnal.Catching.CustomizableRadiusV2,
    Min = 0, Max = 100, Rounding = 0,
    Callback = function(Value) Nocturnal.Catching.CustomizableRadiusV2 = Value end
})
CatchingGB:AddSlider("MagDelayV2Slider", {
    Text = "Magnet Delay V2",
    Default = Nocturnal.Catching.CustomizableDelayV2,
    Min = 0, Max = 5, Rounding = 1,
    Callback = function(Value) Nocturnal.Catching.CustomizableDelayV2 = Value end
})
CatchingGB:AddToggle("PullVectorV2Toggle", {
    Text = "Pull Vector V2",
    Default = Nocturnal.Catching.PullVectorV2,
    Callback = function(Value) Nocturnal.Catching.PullVectorV2 = Value end
})
CatchingGB:AddDropdown("PullVectorTypeV2Dropdown", {
    Text = "Pull Vector Type V2",
    Values = { "Drag", "Push", "Pull" },
    Default = Nocturnal.Catching.PullVectorTypeV2,
    Callback = function(Value) Nocturnal.Catching.PullVectorTypeV2 = Value end
})
CatchingGB:AddSlider("PullVectorSpeedV2Slider", {
    Text = "Pull Vector Speed V2",
    Default = Nocturnal.Catching.PullVectorSpeedV2,
    Min = 0, Max = 20, Rounding = 1,
    Callback = function(Value) Nocturnal.Catching.PullVectorSpeedV2 = Value end
})

-- // ============================
-- // Player Tab Controls
-- // ============================
local PlayerGB = PlayerTab:AddLeftGroupbox("Player")
PlayerGB:AddToggle("JumpPowerToggle", {
    Text = "Jump Power",
    Default = Nocturnal.Player.JumpPower,
    Callback = function(Value) Nocturnal.Player.JumpPower = Value end
})
PlayerGB:AddSlider("JumpPowerSlider", {
    Text = "Jump Power Value",
    Default = Nocturnal.Player.JP,
    Min = 0, Max = 100, Rounding = 0,
    Callback = function(Value) Nocturnal.Player.JP = Value end
})
PlayerGB:AddToggle("AngleEnhancerToggle", {
    Text = "Angle Enhancer",
    Default = Nocturnal.Player.AngleEnhancer,
    Callback = function(Value) Nocturnal.Player.AngleEnhancer = Value end
})
PlayerGB:AddSlider("AngleEnhancerValueSlider", {
    Text = "Angle Enhancer Value",
    Default = Nocturnal.Player.AngleEnhancerValue,
    Min = 0, Max = 100, Rounding = 0,
    Callback = function(Value) Nocturnal.Player.AngleEnhancerValue = Value end
})
PlayerGB:AddToggle("WalkSpeedToggle", {
    Text = "Walk Speed",
    Default = Nocturnal.Player.WalkSpeed,
    Callback = function(Value) Nocturnal.Player.WalkSpeed = Value end
})
PlayerGB:AddSlider("WSSpeedSlider", {
    Text = "Speed Value",
    Default = Nocturnal.Player.WSSpeed,
    Min = 0, Max = 100, Rounding = 0,
    Callback = function(Value) Nocturnal.Player.WSSpeed = Value end
})
PlayerGB:AddToggle("CFrameSpeedToggle", {
    Text = "CFrame Speed",
    Default = Nocturnal.Player.CFrameSpeed,
    Callback = function(Value) Nocturnal.Player.CFrameSpeed = Value end
})
PlayerGB:AddSlider("CFSpeedSlider", {
    Text = "CFrame Speed Value",
    Default = Nocturnal.Player.CFSpeed,
    Min = 0, Max = 100, Rounding = 0,
    Callback = function(Value) Nocturnal.Player.CFSpeed = Value end
})
PlayerGB:AddToggle("FlyToggle", {
    Text = "Fly",
    Default = Nocturnal.Player.Fly,
    Callback = function(Value) Nocturnal.Player.Fly = Value end
})
PlayerGB:AddSlider("FlySpeedSlider", {
    Text = "Fly Speed",
    Default = Nocturnal.Player.FlySpeed,
    Min = 0, Max = 100, Rounding = 0,
    Callback = function(Value) Nocturnal.Player.FlySpeed = Value end
})

-- // ============================
-- // Physics Tab Controls
-- // ============================
local PhysicsGB = PhysicsTab:AddLeftGroupbox("Physics")
PhysicsGB:AddToggle("ClickTackleAimbotToggle", {
    Text = "Click Tackle Aimbot",
    Default = Nocturnal.Physics.ClickTackleAimbot,
    Callback = function(Value) Nocturnal.Physics.ClickTackleAimbot = Value end
})
PhysicsGB:AddSlider("TackleAimbotRadiusSlider", {
    Text = "Tackle Radius",
    Default = Nocturnal.Physics.ClickTackleAimbotRadius,
    Min = 0, Max = 50, Rounding = 0,
    Callback = function(Value) Nocturnal.Physics.ClickTackleAimbotRadius = Value end
})
PhysicsGB:AddToggle("QuickTPToggle", {
    Text = "Quick TP",
    Default = Nocturnal.Physics.QuickTP,
    Callback = function(Value) Nocturnal.Physics.QuickTP = Value end
})
PhysicsGB:AddSlider("QuickTPSpeedSlider", {
    Text = "Quick TP Speed",
    Default = Nocturnal.Physics.QuickTPSpeed,
    Min = 0, Max = 50, Rounding = 0,
    Callback = function(Value) Nocturnal.Physics.QuickTPSpeed = Value end
})
PhysicsGB:AddToggle("ThrowPredictionsToggle", {
    Text = "Throw Predictions",
    Default = Nocturnal.Physics.ThrowPredictions,
    Callback = function(Value) Nocturnal.Physics.ThrowPredictions = Value end
})
PhysicsGB:AddToggle("JumpPredictionsToggle", {
    Text = "Jump Predictions",
    Default = Nocturnal.Physics.JumpPredictions,
    Callback = function(Value) Nocturnal.Physics.JumpPredictions = Value end
})
PhysicsGB:AddToggle("AntiBlockToggle", {
    Text = "Anti Block",
    Default = Nocturnal.Physics.AntiBlock,
    Callback = function(Value) Nocturnal.Physics.AntiBlock = Value end
})
PhysicsGB:AddToggle("AntiJamToggle", {
    Text = "Anti Jam",
    Default = Nocturnal.Physics.AntiJam,
    Callback = function(Value) Nocturnal.Physics.AntiJam = Value end
})
PhysicsGB:AddToggle("NoJumpCooldownToggle", {
    Text = "No Jump Cooldown",
    Default = Nocturnal.Physics.NoJumpCooldown,
    Callback = function(Value) Nocturnal.Physics.NoJumpCooldown = Value end
})
PhysicsGB:AddToggle("BigHeadToggle", {
    Text = "Big Head",
    Default = Nocturnal.Physics.BigHead,
    Callback = function(Value) Nocturnal.Physics.BigHead = Value end
})
PhysicsGB:AddSlider("BigHeadSizeSlider", {
    Text = "Head Size",
    Default = Nocturnal.Physics.BigHeadSize,
    Min = 0, Max = 10, Rounding = 1,
    Callback = function(Value) Nocturnal.Physics.BigHeadSize = Value end
})
PhysicsGB:AddToggle("AntiOOBToggle", {
    Text = "Anti OOB",
    Default = Nocturnal.Physics.AntiOOB,
    Callback = function(Value) 
        Nocturnal.Physics.AntiOOB = Value 

        for Index, Boundary in next, Boundaries do
            Boundary.Parent = not Nocturnal.Physics.AntiOOB and Workspace.Models.Boundaries or nil
        end
    end
})
PhysicsGB:AddToggle("NoFreezeToggle", {
    Text = "No Freeze",
    Default = Nocturnal.Physics.NoFreeze,
    Callback = function(Value) Nocturnal.Physics.NoFreeze = Value end
})
PhysicsGB:AddToggle("BlockExtenderToggle", {
    Text = "Block Extender",
    Default = Nocturnal.Physics.BlockExtender,
    Callback = function(Value) Nocturnal.Physics.BlockExtender = Value end
})
PhysicsGB:AddSlider("BlockExtenderReachSlider", {
    Text = "Block Extender Reach",
    Default = Nocturnal.Physics.BlockExtenderReach,
    Min = 0, Max = 50, Rounding = 0,
    Callback = function(Value) Nocturnal.Physics.BlockExtenderReach = Value end
})
PhysicsGB:AddSlider("BlockExtenderTransparencySlider", {
    Text = "Block Extender Transparency",
    Default = Nocturnal.Physics.BlockExtenderTransparency,
    Min = 0, Max = 1, Rounding = 2,
    Callback = function(Value) Nocturnal.Physics.BlockExtenderTransparency = Value end
})
PhysicsGB:AddToggle("ResetOnCatchToggle", {
    Text = "Reset On Catch",
    Default = Nocturnal.Physics.ResetOnCatch,
    Callback = function(Value) Nocturnal.Physics.ResetOnCatch = Value end
})
PhysicsGB:AddSlider("ResetOnCatchDurationSlider", {
    Text = "Reset On Catch Duration",
    Default = Nocturnal.Physics.ResetOnCatchDuration,
    Min = 0, Max = 5, Rounding = 1,
    Callback = function(Value) Nocturnal.Physics.ResetOnCatchDuration = Value end
})

-- // ============================
-- // Automatics Tab Controls
-- // ============================
local AutoGB = AutomaticsTab:AddLeftGroupbox("Main Automatics")
AutoGB:AddToggle("AutoQB", {
    Text = "Auto QB",
    Default = Nocturnal.Automatics.AutoQB,
    Callback = function(Value) Nocturnal.Automatics.AutoQB = Value end
})
AutoGB:AddDropdown("AutoQBTypeDropdown", {
    Text = "Auto QB Type",
    Values = { "Legit", "Rage", "Precise" },
    Default = Nocturnal.Automatics.AutoQBType,
    Callback = function(Value) Nocturnal.Automatics.AutoQBType = Value end
})
AutoGB:AddToggle("AutoCaptain", {
    Text = "Auto Captain",
    Default = Nocturnal.Automatics.AutoCaptain,
    Callback = function(Value) Nocturnal.Automatics.AutoCaptain = Value end
})
AutoGB:AddToggle("AutoCatch", {
    Text = "Auto Catch",
    Default = Nocturnal.Automatics.AutoCatch,
    Callback = function(Value) Nocturnal.Automatics.AutoCatch = Value end
})
AutoGB:AddSlider("AutoCatchRadius", {
    Text = "Catch Radius",
    Default = Nocturnal.Automatics.AutoCatchRadius,
    Min = 0, Max = 100, Rounding = 0,
    Callback = function(Value) Nocturnal.Automatics.AutoCatchRadius = Value end
})
local AutoSwat = AutomaticsTab:AddRightGroupbox("Swat")
AutoSwat:AddToggle("AutoSwat", {
    Text = "Auto Swat",
    Default = Nocturnal.Automatics.AutoSwat,
    Callback = function(Value) Nocturnal.Automatics.AutoSwat = Value end
})
AutoSwat:AddSlider("AutoSwatRadius", {
    Text = "Swat Radius",
    Default = Nocturnal.Automatics.AutoSwatRadius,
    Min = 0, Max = 100, Rounding = 0,
    Callback = function(Value) Nocturnal.Automatics.AutoSwatRadius = Value end
})
local AutoKick = AutomaticsTab:AddRightGroupbox("Kick")
AutoKick:AddToggle("AutoKick", {
    Text = "Auto Kick",
    Default = Nocturnal.Automatics.AutoKick,
    Callback = function(Value) Nocturnal.Automatics.AutoKick = Value end
})
AutoKick:AddSlider("AutoKickPower", {
    Text = "Kick Power",
    Default = Nocturnal.Automatics.AutoKickPower,
    Min = 0, Max = 100, Rounding = 0,
    Callback = function(Value) Nocturnal.Automatics.AutoKickPower = Value end
})
AutoKick:AddSlider("AutoKickAccuracy", {
    Text = "Kick Accuracy",
    Default = Nocturnal.Automatics.AutoKickAccuracy,
    Min = 0, Max = 100, Rounding = 0,
    Callback = function(Value) Nocturnal.Automatics.AutoKickAccuracy = Value end
})
local AutoRush = AutomaticsTab:AddLeftGroupbox("Rush")
AutoRush:AddToggle("AutoRush", {
    Text = "Auto Rush",
    Default = Nocturnal.Automatics.AutoRush,
    Callback = function(Value) Nocturnal.Automatics.AutoRush = Value end
})
AutoRush:AddSlider("AutoRushDelay", {
    Text = "Rush Delay",
    Default = Nocturnal.Automatics.AutoRushDelay,
    Min = 0, Max = 10, Rounding = 1,
    Callback = function(Value) Nocturnal.Automatics.AutoRushDelay = Value end
})
local AutoBoost = AutomaticsTab:AddLeftGroupbox("Boost")
AutoBoost:AddToggle("AutoBoost", {
    Text = "Auto Boost",
    Default = Nocturnal.Automatics.AutoBoost,
    Callback = function(Value) Nocturnal.Automatics.AutoBoost = Value end
})
AutoBoost:AddSlider("AutoBoostPower", {
    Text = "Boost Power",
    Default = Nocturnal.Automatics.AutoBoostPower,
    Min = 0, Max = 100, Rounding = 0,
    Callback = function(Value) Nocturnal.Automatics.AutoBoostPower = Value end
})

-- // ============================
-- // Visuals Tab Controls
-- // ============================
local VisualsGB = VisualsTab:AddLeftGroupbox("Visuals")
VisualsGB:AddToggle("NoTexturesToggle", {
    Text = "No Textures",
    Default = Nocturnal.Visuals.NoTextures,
    Callback = function(State)
        Nocturnal.Visuals.NoTextures = State

        if Nocturnal.Visuals.NoTextures then
            for Index, Part in next, Workspace:GetDescendants() do
                if Part:IsA("BasePart") then
                    Part:SetAttribute("OriginalMaterial", Part.Material.Name)
                    Part.Material = Enum.Material.SmoothPlastic
                end
            end

            Workspace.DescendantAdded:Connect(function(Part)
                if Part:IsA("BasePart") then
                    Part:SetAttribute("OriginalMaterial", Part.Material.Name)
                    Part.Material = Enum.Material.SmoothPlastic
                end
            end)
        else
            for Index, Part in next, Workspace:GetDescendants() do
                if Part:IsA("BasePart") and Part:GetAttribute("OriginalMaterial") then
                    Part.Material = Enum.Material[Part:GetAttribute("OriginalMaterial")]
                end
            end
        end
    end
})
VisualsGB:AddToggle("CameraZoomToggle", {
    Text = "Camera Zoom",
    Default = Nocturnal.Visuals.CameraZoom,
    Callback = function(Value) Nocturnal.Visuals.CameraZoom = Value end
})
VisualsGB:AddLabel("Hitbox Color"):AddColorPicker("HitboxColorPicker", {
    Default = Color3.new(1, 0, 0),
    Title = "Hitbox Color",
    Callback = function(Value)
        
    end,
})

-- // ============================
-- // QB Aimbot Tab Controls
-- // ============================
local QBGB = QBAimbotTab:AddLeftGroupbox("QB Aimbot")
QBGB:AddToggle("QBAimbot", {
    Text = "QB Aimbot",
    Default = Nocturnal.QBAimbot.Enabled,
    Callback = function(Value) Nocturnal.QBAimbot.Enabled = Value end
})
QBGB:AddToggle("AutoAngle", {
    Text = "Auto Angle",
    Default = Nocturnal.QBAimbot.AutoAngle,
    Callback = function(Value) Nocturnal.QBAimbot.AutoAngle = Value end
})
QBGB:AddToggle("AutoPower", {
    Text = "Auto Power",
    Default = Nocturnal.QBAimbot.AutoPower,
    Callback = function(Value) Nocturnal.QBAimbot.AutoPower = Value end
})
QBGB:AddToggle("HighestPowerMode", {
    Text = "Highest Power Mode",
    Default = Nocturnal.QBAimbot.HighestPowerMode,
    Callback = function(Value) Nocturnal.QBAimbot.HighestPowerMode = Value end
})
QBGB:AddToggle("BeamMode", {
    Text = "Beam Mode",
    Default = Nocturnal.QBAimbot.BeamMode,
    Callback = function(Value) Nocturnal.QBAimbot.BeamMode = Value end
})
QBGB:AddSlider("CustomLead", {
    Text = "Custom Lead",
    Default = Nocturnal.QBAimbot.CustomLead,
    Min = 0, Max = 100, Rounding = 0,
    Callback = function(Value) Nocturnal.QBAimbot.CustomLead = Value end
})

-- // Misc Groupbox
local MiscGroupbox = MiscTab:AddLeftGroupbox("Menu Keybind", "wrench")

MiscGroupbox:AddDivider()
MiscGroupbox:AddLabel("Menu Bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MiscGroupbox:AddButton("Unload", function()
    Library:Unload()
end)

-- // Set the library toggle keybind
Library.ToggleKeybind = Options.MenuKeybind

-- // Setup Managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- // Ignore Theme Data In Configs
SaveManager:IgnoreThemeSettings()

-- // Ignore Menu Keybind In Configs
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

-- // Set Folders
ThemeManager:SetFolder("Nocturnal/FF2")
SaveManager:SetFolder("Nocturnal/FF2")
SaveManager:SetSubFolder("Universal")

-- // Apply Theme UI
ThemeManager:ApplyToTab(MiscTab)

-- // Build Config UI
SaveManager:BuildConfigSection(MiscTab)

-- // Load Autoload Config
SaveManager:LoadAutoloadConfig()

-- // ============================
-- // End of setup
-- // ============================
