-- Builds and runs the forest horror game entirely from server-side parts.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local PAPER_COUNT = 8
local MAP_SIZE = 440
local random = Random.new()

local oldMap = Workspace:FindFirstChild("ForestGame")
if oldMap then oldMap:Destroy() end
local map = Instance.new("Folder")
map.Name = "ForestGame"
map.Parent = Workspace

local event = ReplicatedStorage:FindFirstChild("ForestGameEvent")
if not event then
    event = Instance.new("RemoteEvent")
    event.Name = "ForestGameEvent"
    event.Parent = ReplicatedStorage
end

local function makePart(parent, name, size, cf, color, material, anchored)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cf
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    part.Anchored = anchored ~= false
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

-- A broad, dim forest floor with a winding trail.
makePart(map, "ForestFloor", Vector3.new(MAP_SIZE, 2, MAP_SIZE), CFrame.new(0, -1, 0), Color3.fromRGB(31, 43, 32), Enum.Material.Grass)
local spawn = Instance.new("SpawnLocation")
spawn.Name = "ForestStart"
spawn.Size = Vector3.new(12, 1, 12)
spawn.CFrame = CFrame.new(0, 0, -190)
spawn.Anchored = true
spawn.Neutral = true
spawn.Color = Color3.fromRGB(67, 74, 62)
spawn.Material = Enum.Material.Slate
spawn.Parent = map

for i = 0, 15 do
    local z = -190 + i * 25
    local x = math.sin(i * 0.7) * 18
    makePart(map, "Trail", Vector3.new(18, 0.15, 27), CFrame.new(x, 0.05, z), Color3.fromRGB(77, 70, 55), Enum.Material.Ground)
end

local paperTrees = {}
for i = 1, 84 do
    local x, z
    repeat
        x = random:NextNumber(-205, 205)
        z = random:NextNumber(-205, 205)
    until (Vector2.new(x, z).Magnitude > 25 and not (math.abs(x - math.sin(((z + 190) / 25) * 0.7) * 18) < 13 and z > -205 and z < 205))
    local height = random:NextNumber(20, 33)
    local tree = Instance.new("Model")
    tree.Name = "PineTree"
    tree.Parent = map
    makePart(tree, "Trunk", Vector3.new(3.2, height, 3.2), CFrame.new(x, height / 2, z), Color3.fromRGB(74, 48, 34), Enum.Material.Wood)
    for layer = 0, 2 do
        local cone = makePart(tree, "EvergreenCanopy", Vector3.new(16 - layer * 3, 13, 16 - layer * 3), CFrame.new(x, height * 0.53 + layer * 6, z), Color3.fromRGB(18, 43 + random:NextInteger(0, 12), 31), Enum.Material.Grass)
        cone.Shape = Enum.PartType.Ball
    end
    if i <= PAPER_COUNT then table.insert(paperTrees, {x = x, z = z, height = height}) end
end

local collected = {}
local totalCollected = 0
local finished = {}
local function updatePlayer(player)
    event:FireClient(player, "Progress", totalCollected, PAPER_COUNT)
end

for index, tree in ipairs(paperTrees) do
    local note = makePart(map, "ForestNote" .. index, Vector3.new(2.4, 3.2, 0.18), CFrame.new(tree.x + 1.8, tree.height * 0.43, tree.z - 1.7) * CFrame.Angles(0, math.rad(-25), math.rad(4)), Color3.fromRGB(222, 211, 177), Enum.Material.Paper)
    note.CanCollide = false
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Take paper"
    prompt.ObjectText = "Torn note"
    prompt.HoldDuration = 0.35
    prompt.MaxActivationDistance = 10
    prompt.Parent = note
    prompt.Triggered:Connect(function(player)
        if collected[index] then return end
        collected[index] = true
        totalCollected += 1
        note:Destroy()
        for _, currentPlayer in ipairs(Players:GetPlayers()) do updatePlayer(currentPlayer) end
        if totalCollected == PAPER_COUNT then
            event:FireAllClients("AllFound")
        end
    end)
end

-- The exit is visibly sealed until every note has been collected.
local exit = Instance.new("Model")
exit.Name = "ForestExit"
exit.Parent = map
makePart(exit, "LeftPost", Vector3.new(3, 20, 3), CFrame.new(-7, 10, 211), Color3.fromRGB(49, 45, 39), Enum.Material.Wood)
makePart(exit, "RightPost", Vector3.new(3, 20, 3), CFrame.new(7, 10, 211), Color3.fromRGB(49, 45, 39), Enum.Material.Wood)
local gate = makePart(exit, "SealedGate", Vector3.new(17, 15, 2), CFrame.new(0, 8, 211), Color3.fromRGB(29, 34, 31), Enum.Material.Metal)
local exitPrompt = Instance.new("ProximityPrompt")
exitPrompt.ActionText = "Leave the forest"
exitPrompt.ObjectText = "Forest gate"
exitPrompt.HoldDuration = 1
exitPrompt.MaxActivationDistance = 12
exitPrompt.Parent = gate
exitPrompt.Triggered:Connect(function(player)
    if totalCollected < PAPER_COUNT then
        event:FireClient(player, "NeedMore", PAPER_COUNT - totalCollected)
        return
    end
    if finished[player] then return end
    finished[player] = true
    event:FireClient(player, "Won")
end)

-- A shadow creature pursues the nearest living player and attacks at close range.
local monster = Instance.new("Model")
monster.Name = "TheHollow"
monster.Parent = map
local body = makePart(monster, "Body", Vector3.new(5, 9, 3), CFrame.new(0, 4.5, 185), Color3.fromRGB(8, 9, 12), Enum.Material.Slate)
body.Shape = Enum.PartType.Block
body.CanCollide = false
local head = makePart(monster, "Head", Vector3.new(4, 4, 4), CFrame.new(0, 11, 185), Color3.fromRGB(5, 5, 7), Enum.Material.Slate)
head.Shape = Enum.PartType.Ball
head.CanCollide = false
local eyes = {}
for _, x in ipairs({-0.85, 0.85}) do
    local eye = makePart(monster, "GlowingEye", Vector3.new(0.45, 0.35, 0.2), CFrame.new(x, 11.2, 182.85), Color3.fromRGB(255, 35, 20), Enum.Material.Neon)
    eye.CanCollide = false
    table.insert(eyes, eye)
end
local monsterPosition = Vector3.new(0, 0, 185)
local attackTimes = {}
local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    if elapsed < 0.18 then return end
    local step = elapsed
    elapsed = 0
    local target, bestDistance
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if humanoid and root and humanoid.Health > 0 and not finished[player] then
            local distance = (root.Position - monsterPosition).Magnitude
            if not bestDistance or distance < bestDistance then target, bestDistance = root, distance end
        end
    end
    if not target then return end
    local offset = target.Position - monsterPosition
    local flat = Vector3.new(offset.X, 0, offset.Z)
    if flat.Magnitude > 0.1 then
        monsterPosition += flat.Unit * math.min(flat.Magnitude, 8.5 * step)
        local facing = CFrame.lookAt(monsterPosition, Vector3.new(target.Position.X, 0, target.Position.Z))
        body.CFrame = facing * CFrame.new(0, 4.5, 0)
        head.CFrame = facing * CFrame.new(0, 11, 0)
        eyes[1].CFrame = facing * CFrame.new(-0.85, 11.2, -2.05)
        eyes[2].CFrame = facing * CFrame.new(0.85, 11.2, -2.05)
    end
    if bestDistance < 7 then
        local player = Players:GetPlayerFromCharacter(target.Parent)
        local humanoid = target.Parent:FindFirstChildOfClass("Humanoid")
        if player and humanoid and os.clock() - (attackTimes[player] or 0) > 2.5 then
            attackTimes[player] = os.clock()
            humanoid:TakeDamage(35)
            event:FireClient(player, "Attacked")
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    task.delay(1, function()
        if player.Parent then
            updatePlayer(player)
            event:FireClient(player, "Objective")
        end
    end)
end)
for _, player in ipairs(Players:GetPlayers()) do
    task.defer(function() updatePlayer(player) end)
end
