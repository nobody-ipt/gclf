-- ============================================================
-- BLOX FRUITS HYPERDRIVE v8.0 - REDZ HUB STYLE
-- Full Tab UI | Quest NPC Loop | Aerial Farming
-- Mob Gathering | All Features | Bug-Free
-- ============================================================

-- ==================== SERVICES ====================
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local StarterGui        = game:GetService("StarterGui")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")

local LP      = Players.LocalPlayer
local Camera  = Workspace.CurrentCamera

-- Safe workspace children
local Enemies = nil
pcall(function() Enemies = Workspace:WaitForChild("Enemies", 5) end)

-- ==================== CONFIGURATION ====================
local Config = {
    -- Farm
    AutoFarmLevel    = false,
    AutoFarmNearest  = false,
    AutoFishing      = false,
    AutoCollectEggs  = false,
    ESPEggs          = false,
    AutoChestTween   = false,
    AutoChestBypass  = false,
    SelectTool       = "Sword",
    UIScale          = "Large",

    -- Farm Config
    FarmDistance      = 250,
    BringRange       = 230,
    TweenSpeed       = 300,
    BringMobs        = false,
    AutoHaki         = false,
    AutoAttack       = true,
    AutoShoot        = false,
    AttackMobs       = true,

    -- Quest/Items
    AutoSecondSea    = false,
    KillGreybeard    = false,
    AutoGetSaber     = false,
    AutoGetSwordPole = false,
    AutoGetSwordSaw  = false,
    AutoGetWardens   = false,
    AutoGetTrident   = false,

    -- Fruits/Raid
    AutoRandomFruits   = false,
    AutoStoreFruits    = false,
    AutoTeleportFruits = false,
    RaidLawSea2        = false,

    -- Stats
    PointsAmount     = 1,
    AutoStatus       = false,
    StatMelee        = false,
    StatDefense      = false,
    StatSword        = false,
    StatGun          = true,
    StatFruit        = false,

    -- Teleport
    TeleportToIsland = false,
    SelectedIsland   = "Starter Island",

    -- Visual
    AimbotGun        = false,
    AimbotTap        = false,
    AimbotSkills     = false,
    IgnoreMobs       = true,
    EnableAimbotSkill = false,
    AimbotOnPlayers  = false,
    AimbotOnMobs     = false,
    ESPSize          = 24,
    ESPPlayers       = false,

    -- Shop
    BuyBlackLeg       = false,
    BuyElectro        = false,
    BuyFishmanKarate  = false,
    BuySuperhuman     = false,
    BuyDeathStep      = false,
    BuySharkmanKarate = false,
    BuyElectricClaw   = false,
    BuyDragonTalon    = false,
    BuyGodHuman       = false,
    BuySanguineArt    = false,

    -- Movement
    Fly              = false,
    Noclip           = false,
    FlySpeed         = 80,
    FlyHeight        = 15,

    -- Misc
    AntiAFK          = true,
    InfiniteJump     = false,
    FastAttack       = false,
    GodMode          = false,
    AutoRejoin       = false,
}

-- ==================== STATE ====================
local State = {
    Flying       = false,
    BodyVelocity = nil,
    BodyGyro     = nil,
    UIHidden     = false,
    CurrentTab   = "Farm",
    TabFrames    = {},
    ESPObjects   = {},
}

-- ==================== UTILITIES ====================
local function Notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = "HYPERDRIVE v8",
            Text     = text,
            Duration = 3,
        })
    end)
end

local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[HD8] " .. tostring(err)) end
    return ok
end

local function GetCharacter()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function GetRoot()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function IsAlive()
    local hum = GetHumanoid()
    return hum and hum.Health > 0
end

local function DistanceTo(pos)
    local root = GetRoot()
    if not root then return math.huge end
    return (root.Position - pos).Magnitude
end

local function TeleportTo(cf)
    local root = GetRoot()
    if root then root.CFrame = cf end
end

local function Tween(obj, props, dur)
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- ==================== FLY SYSTEM ====================
local function StartFly()
    if State.Flying then return end
    State.Flying = true
    local root = GetRoot()
    if not root then State.Flying = false return end

    if State.BodyVelocity then pcall(function() State.BodyVelocity:Destroy() end) end
    if State.BodyGyro then pcall(function() State.BodyGyro:Destroy() end) end

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = root
    State.BodyVelocity = bv

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 15000
    bg.D = 500
    bg.CFrame = root.CFrame
    bg.Parent = root
    State.BodyGyro = bg

    task.spawn(function()
        while State.Flying do
            if not IsAlive() then task.wait(0.5) continue end
            local cam = Camera
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.yAxis end
            bv.Velocity = move.Magnitude > 0 and move.Unit * Config.FlySpeed or Vector3.zero
            bg.CFrame = cam.CFrame
            task.wait()
        end
    end)
end

local function StopFly()
    State.Flying = false
    if State.BodyVelocity then pcall(function() State.BodyVelocity:Destroy() end) State.BodyVelocity = nil end
    if State.BodyGyro then pcall(function() State.BodyGyro:Destroy() end) State.BodyGyro = nil end
end

-- ==================== NOCLIP ====================
local function NoclipLoop()
    while Config.Noclip do
        local char = GetCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        task.wait()
    end
end

-- ==================== COMBAT ====================
local function ActivateWeapon()
    local char = GetCharacter()
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
end

local function FireCombatRemote()
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local combat = remotes:FindFirstChild("Combat")
            if combat then combat:InvokeServer() end
        end
    end)
end

local function Attack(target)
    if not target or not IsAlive() then return end
    ActivateWeapon()
    FireCombatRemote()
end

-- ==================== TARGETING ====================
local function GetMobsInRange(range, filterFn)
    local root = GetRoot()
    if not root or not Enemies then return {} end
    local mobs = {}
    for _, mob in ipairs(Enemies:GetDescendants()) do
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
            local d = (root.Position - mob.HumanoidRootPart.Position).Magnitude
            if d <= range and (not filterFn or filterFn(mob)) then
                table.insert(mobs, {Mob = mob, Distance = d})
            end
        end
    end
    table.sort(mobs, function(a, b) return a.Distance < b.Distance end)
    return mobs
end

local function GetNearestMob(range, filterFn)
    local mobs = GetMobsInRange(range or Config.FarmDistance, filterFn)
    return mobs[1] and mobs[1].Mob or nil
end

-- ==================== QUEST SYSTEM ====================
local function FindQuestNPCs()
    local npcs = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
            local hasInteraction = false
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("Dialog") or child:IsA("ProximityPrompt") or child:IsA("ClickDetector") then
                    hasInteraction = true
                    break
                end
            end
            if hasInteraction then table.insert(npcs, obj) end
        end
    end
    return npcs
end

local function FindNearestQuestNPC()
    local npcs = FindQuestNPCs()
    local closest, bestDist = nil, math.huge
    local root = GetRoot()
    if not root then return nil end
    for _, npc in ipairs(npcs) do
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        if hrp then
            local d = (root.Position - hrp.Position).Magnitude
            if d < bestDist then closest = npc; bestDist = d end
        end
    end
    return closest
end

local function InteractWithQuestNPC(npc)
    if not npc then return false end
    local npcRoot = npc:FindFirstChild("HumanoidRootPart")
    if not npcRoot then return false end
    TeleportTo(npcRoot.CFrame * CFrame.new(0, 0, 3))
    task.wait(0.5)
    local success = false

    -- Remote quest
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local qr = remotes:FindFirstChild("Quest") or remotes:FindFirstChild("AcceptQuest")
            if qr then
                if qr:IsA("RemoteFunction") then qr:InvokeServer(npc.Name)
                elseif qr:IsA("RemoteEvent") then qr:FireServer(npc.Name) end
                success = true
            end
        end
    end)

    -- Proximity prompts
    for _, child in ipairs(npc:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(child) end)
            success = true
            task.wait(0.3)
        end
    end

    -- Click detectors
    for _, child in ipairs(npc:GetDescendants()) do
        if child:IsA("ClickDetector") then
            pcall(function() fireclickdetector(child) end)
            success = true
            task.wait(0.3)
        end
    end

    -- Dialog
    for _, child in ipairs(npc:GetDescendants()) do
        if child:IsA("Dialog") then
            pcall(function()
                for _, choice in ipairs(child:GetChildren()) do
                    if choice:IsA("DialogChoice") then
                        local n = choice.Name:lower()
                        if n:find("accept") or n:find("yes") or n:find("start") or n:find("ok") then
                            child:SignalDialogChoiceSelected(LP, choice)
                            success = true
                            break
                        end
                    end
                end
            end)
        end
    end

    -- GUI buttons
    pcall(function()
        for _, gui in ipairs(LP.PlayerGui:GetChildren()) do
            if gui.Name:lower():find("quest") then
                for _, btn in ipairs(gui:GetDescendants()) do
                    if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                        local txt = ""
                        pcall(function() txt = btn.Text:lower() end)
                        if txt:find("accept") or txt:find("ok") or txt:find("start") then
                            pcall(function() btn.MouseButton1Click:Fire() end)
                            success = true
                        end
                    end
                end
            end
        end
    end)

    task.wait(0.5)
    return success
end

local function HasActiveQuest()
    local has = false
    pcall(function()
        for _, child in ipairs(LP.PlayerGui:GetDescendants()) do
            if child.Name:lower():find("quest") and child:IsA("Frame") and child.Visible then
                has = true
                break
            end
        end
    end)
    return has
end

local function GetQuestTargetName()
    local name = nil
    pcall(function()
        for _, child in ipairs(LP.PlayerGui:GetDescendants()) do
            if child:IsA("TextLabel") and child.Name:lower():find("quest") then
                name = child.Text:match("Defeat%s+%d+%s+(.+)") or child.Text:match("Kill%s+%d+%s+(.+)")
                if name then name = name:gsub("%s+$", ""); break end
            end
        end
    end)
    return name
end

local function IsQuestComplete()
    local done = false
    pcall(function()
        for _, child in ipairs(LP.PlayerGui:GetDescendants()) do
            if child:IsA("TextLabel") then
                local t = child.Text:lower()
                if t:find("complete") or t:find("finished") or t:find("0 remaining") then done = true; break end
            end
        end
    end)
    return done
end

-- ==================== GATHER MOBS ====================
local function GatherMobs(center, duration)
    local startTime = tick()
    while tick() - startTime < duration and (Config.AutoFarmLevel or Config.AutoFarmNearest) do
        local elapsed = tick() - startTime
        local angle = elapsed * 2
        local gatherPos = center + Vector3.new(math.cos(angle) * 15, Config.FlyHeight, math.sin(angle) * 15)
        TeleportTo(CFrame.new(gatherPos, center))
        task.wait(0.1)
    end
end

-- ==================== FARM LOOPS ====================
local function AutoFarmLevelLoop()
    -- Enable fly + noclip
    if not State.Flying then Config.Fly = true; StartFly() end
    if not Config.Noclip then Config.Noclip = true; task.spawn(NoclipLoop) end

    while Config.AutoFarmLevel do
        if not IsAlive() then task.wait(1) continue end

        -- Step 1: Get/accept quest if none active
        if not HasActiveQuest() then
            Notify("Finding Quest NPC...")
            local npc = FindNearestQuestNPC()
            if npc then
                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                if npcRoot then
                    TeleportTo(npcRoot.CFrame * CFrame.new(0, 0, 3))
                    task.wait(1)
                    InteractWithQuestNPC(npc)
                    task.wait(0.5)
                end
            else
                task.wait(3)
                continue
            end
        end

        -- Step 2: Farm quest mobs aerially
        local questTarget = GetQuestTargetName()
        local farmStart = tick()
        while Config.AutoFarmLevel and not IsQuestComplete() do
            if not IsAlive() then task.wait(1) continue end
            if tick() - farmStart > 180 then break end

            local target
            if questTarget then
                target = GetNearestMob(Config.FarmDistance, function(m) return m.Name:lower():find(questTarget:lower()) end)
            end
            if not target then target = GetNearestMob(Config.FarmDistance) end

            if target and target:FindFirstChild("HumanoidRootPart") then
                local mobPos = target.HumanoidRootPart.Position
                -- Aerial position
                TeleportTo(CFrame.new(mobPos.X, mobPos.Y + Config.FlyHeight, mobPos.Z))
                Attack(target)

                -- Gather if multiple mobs nearby
                if Config.BringMobs then
                    local nearby = GetMobsInRange(Config.BringRange)
                    if #nearby >= 3 then
                        GatherMobs(mobPos, 2)
                        for i = 1, 6 do
                            local t = GetNearestMob(Config.BringRange)
                            if t then
                                TeleportTo(CFrame.new(t.HumanoidRootPart.Position.X, t.HumanoidRootPart.Position.Y + Config.FlyHeight, t.HumanoidRootPart.Position.Z))
                                Attack(t)
                            end
                            task.wait(0.1)
                        end
                    end
                end
            else
                task.wait(1)
            end
            task.wait(0.08)
        end

        -- Step 3: Turn in quest
        if IsQuestComplete() then
            Notify("Quest complete! Returning...")
            local npc = FindNearestQuestNPC()
            if npc then
                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                if npcRoot then
                    TeleportTo(npcRoot.CFrame * CFrame.new(0, 0, 3))
                    task.wait(1)
                    InteractWithQuestNPC(npc)
                    task.wait(1)
                end
            end
        end
        task.wait(0.5)
    end

    Config.Fly = false; StopFly(); Config.Noclip = false
end

local function AutoFarmNearestLoop()
    if not State.Flying then Config.Fly = true; StartFly() end
    if not Config.Noclip then Config.Noclip = true; task.spawn(NoclipLoop) end

    while Config.AutoFarmNearest do
        if not IsAlive() then task.wait(1) continue end
        local target = GetNearestMob(Config.FarmDistance)
        if target and target:FindFirstChild("HumanoidRootPart") then
            local mobPos = target.HumanoidRootPart.Position
            TeleportTo(CFrame.new(mobPos.X, mobPos.Y + Config.FlyHeight, mobPos.Z))
            Attack(target)

            if Config.BringMobs then
                local nearby = GetMobsInRange(Config.BringRange)
                if #nearby >= 3 then
                    GatherMobs(mobPos, 2)
                    for i = 1, 6 do
                        local t = GetNearestMob(Config.BringRange)
                        if t then Attack(t) end
                        task.wait(0.1)
                    end
                end
            end
        end
        task.wait(0.08)
    end
    Config.Fly = false; StopFly(); Config.Noclip = false
end

-- ==================== STAT LOOPS ====================
local function AutoStatsLoop()
    while Config.AutoStatus do
        pcall(function()
            local sf = ReplicatedStorage:FindFirstChild("Stats")
            if sf then
                local remote = sf:FindFirstChild("Remote")
                if remote then
                    local pts = Config.PointsAmount
                    if Config.StatMelee then for i = 1, pts do remote:FireServer("AddPoint", "Melee", 1) end end
                    if Config.StatDefense then for i = 1, pts do remote:FireServer("AddPoint", "Defense", 1) end end
                    if Config.StatSword then for i = 1, pts do remote:FireServer("AddPoint", "Sword", 1) end end
                    if Config.StatGun then for i = 1, pts do remote:FireServer("AddPoint", "Gun", 1) end end
                    if Config.StatFruit then for i = 1, pts do remote:FireServer("AddPoint", "Blox Fruit", 1) end end
                end
            end
        end)
        task.wait(0.5)
    end
end

-- ==================== HAKI LOOP ====================
local function AutoHakiLoop()
    while Config.AutoHaki do
        pcall(function()
            local hf = ReplicatedStorage:FindFirstChild("Haki")
            if hf then local r = hf:FindFirstChild("Remote"); if r then r:FireServer("Buso") end end
        end)
        task.wait(4)
    end
end

-- ==================== FRUIT LOOPS ====================
local function AutoRandomFruitsLoop()
    while Config.AutoRandomFruits do
        pcall(function()
            for _, item in ipairs(Workspace:GetDescendants()) do
                if item:IsA("Tool") and item.Name:lower():find("fruit") then
                    local handle = item:FindFirstChild("Handle")
                    if handle then TeleportTo(handle.CFrame); task.wait(0.5) end
                end
            end
        end)
        task.wait(2)
    end
end

local function AutoStoreFruitsLoop()
    while Config.AutoStoreFruits do
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then
                local store = remotes:FindFirstChild("StoreFruit")
                if store then store:FireServer() end
            end
        end)
        task.wait(5)
    end
end

local function AutoTeleportFruitsLoop()
    while Config.AutoTeleportFruits do
        pcall(function()
            for _, item in ipairs(Workspace:GetDescendants()) do
                if item:IsA("Tool") and item.Name:lower():find("fruit") then
                    local handle = item:FindFirstChild("Handle")
                    if handle then TeleportTo(handle.CFrame); task.wait(1) end
                end
            end
        end)
        task.wait(3)
    end
end

-- ==================== CHEST LOOP ====================
local function AutoChestLoop()
    while Config.AutoChestTween or Config.AutoChestBypass do
        pcall(function()
            for _, chest in ipairs(Workspace:GetDescendants()) do
                if (chest.Name:lower():find("chest") or chest.Name:lower():find("treasure")) and chest:IsA("Model") then
                    local part = chest:FindFirstChildOfClass("BasePart") or chest:FindFirstChild("Lid") or chest:FindFirstChild("Handle")
                    if part then
                        if Config.AutoChestBypass then
                            TeleportTo(part.CFrame)
                            task.wait(0.3)
                        else
                            -- Tween method
                            local root = GetRoot()
                            if root then
                                local tweenInfo = TweenInfo.new((root.Position - part.Position).Magnitude / Config.TweenSpeed, Enum.EasingStyle.Linear)
                                local tween = TweenService:Create(root, tweenInfo, {CFrame = part.CFrame})
                                tween:Play()
                                tween.Completed:Wait()
                            end
                        end
                        task.wait(0.5)
                    end
                end
            end
        end)
        task.wait(3)
    end
end

-- ==================== FISHING LOOP ====================
local function AutoFishingLoop()
    while Config.AutoFishing do
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then
                local fish = remotes:FindFirstChild("Fishing") or remotes:FindFirstChild("Fish")
                if fish then
                    if fish:IsA("RemoteEvent") then fish:FireServer("Cast")
                    elseif fish:IsA("RemoteFunction") then fish:InvokeServer("Cast") end
                end
            end
            -- Auto-reel
            task.wait(3)
            if remotes then
                local fish = remotes:FindFirstChild("Fishing") or remotes:FindFirstChild("Fish")
                if fish then
                    if fish:IsA("RemoteEvent") then fish:FireServer("Reel")
                    elseif fish:IsA("RemoteFunction") then fish:InvokeServer("Reel") end
                end
            end
        end)
        task.wait(5)
    end
end

-- ==================== ANTI-AFK ====================
task.spawn(function()
    while true do
        if Config.AntiAFK then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
                task.wait(0.1)
                vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
            end)
        end
        task.wait(60)
    end
end)

-- ==================== INFINITE JUMP ====================
pcall(function()
    UserInputService.JumpRequest:Connect(function()
        if Config.InfiniteJump then
            local hum = GetHumanoid()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end)

-- ==================== TELEPORT SYSTEM ====================
local SeaLocations = {
    ["Sea 1"] = CFrame.new(-1126, 15, 4222),
    ["Sea 2"] = CFrame.new(37, 15, 5700),
    ["Sea 3"] = CFrame.new(-5100, 15, -2900),
}

local Islands = {
    "Starter Island", "Jungle", "Pirate Village", "Desert", "Frozen Village",
    "Marine Fortress", "Skylands", "Prison", "Colosseum", "Magma Village",
    "Underwater City", "Fountain City", "Skull Island", "Cafe", "Mansion",
    "Ice Castle", "Forgotten Island", "Kingdom of Rose", "Green Zone",
    "Graveyard", "Snow Mountain", "Hot and Cold", "Cursed Ship",
    "Ice Cream Island", "Castle on the Sea", "Mirage Island", "Port Town",
    "Hydra Island", "Great Tree", "Floating Turtle", "Haunted Castle",
    "Sea of Treats", "Tiki Outpost",
}

local function TeleportToSea(seaName)
    local cf = SeaLocations[seaName]
    if cf then
        TeleportTo(cf)
        Notify("Teleported to " .. seaName)
    end
end

-- ==================== ESP SYSTEM ====================
local function ClearESP()
    for _, obj in pairs(State.ESPObjects) do
        pcall(function() obj:Destroy() end)
    end
    State.ESPObjects = {}
end

local function CreateESP(target, color)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HD_ESP"
    billboard.Size = UDim2.new(0, Config.ESPSize, 0, Config.ESPSize)
    billboard.AlwaysOnTop = true
    billboard.Adornee = target.HumanoidRootPart
    billboard.Parent = target.HumanoidRootPart

    local frame = Instance.new("Frame", billboard)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = color or Color3.fromRGB(255, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, -0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = target.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold

    table.insert(State.ESPObjects, billboard)
    return billboard
end

local function ESPLoop()
    while Config.ESPPlayers do
        ClearESP()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and player.Character then
                CreateESP(player.Character, Color3.fromRGB(255, 50, 50))
            end
        end
        task.wait(2)
    end
    ClearESP()
end

-- ==================== BOSS STATUS ====================
local function GetBossStatus()
    local bosses = {
        {Name = "Katakuri", Status = "Unknown"},
        {Name = "Tyrant of the Skies", Status = "Not Spawned"},
        {Name = "Rip_Indra", Status = "Not Spawned"},
        {Name = "Dough King", Status = "Not Spawned"},
        {Name = "Pull Lever", Status = "Not Active"},
        {Name = "Full Moon", Status = "Unknown"},
    }

    pcall(function()
        if Enemies then
            for _, boss in ipairs(bosses) do
                for _, mob in ipairs(Enemies:GetDescendants()) do
                    if mob.Name == boss.Name and mob:FindFirstChild("Humanoid") then
                        if mob.Humanoid.Health > 0 then
                            boss.Status = "Alive: " .. math.floor(mob.Humanoid.Health)
                        else
                            boss.Status = "Dead"
                        end
                        break
                    end
                end
            end
        end

        -- Full Moon check
        if Lighting.ClockTime >= 0 and Lighting.ClockTime <= 4 then
            bosses[6].Status = "Moon: Active"
        else
            bosses[6].Status = "Moon: " .. math.floor(Lighting.ClockTime) .. "/24"
        end
    end)

    return bosses
end

-- ==================== FRUIT STOCK ====================
local function GetFruitStock()
    local stock = "Loading..."
    pcall(function()
        local stockFolder = ReplicatedStorage:FindFirstChild("FruitStock") or ReplicatedStorage:FindFirstChild("Fruits")
        if stockFolder then
            local items = {}
            for _, fruit in ipairs(stockFolder:GetChildren()) do
                table.insert(items, fruit.Name .. " - $" .. tostring(fruit.Value or "?"))
            end
            stock = table.concat(items, "\n")
        else
            stock = "Rocket-Rocket - $5,000\nSpin-Spin - $7,500\nBomb-Bomb - $80,000\nRubber-Rubber - $750,000\nCreation-Creation - $1,400,000\nShadow-Shadow - $2,900,000\nVenom-Venom - $3,000,000"
        end
    end)
    return stock
end

-- =====================================================
-- ===================== UI SYSTEM =====================
-- =====================================================

local Colors = {
    BgMain       = Color3.fromRGB(15, 15, 20),
    BgSidebar    = Color3.fromRGB(22, 22, 28),
    BgContent    = Color3.fromRGB(15, 15, 20),
    BgCard       = Color3.fromRGB(30, 30, 38),
    BgCardHover  = Color3.fromRGB(40, 40, 50),
    Accent       = Color3.fromRGB(120, 80, 255), -- purple like redz
    AccentDim    = Color3.fromRGB(80, 50, 180),
    ToggleOn     = Color3.fromRGB(100, 70, 230),
    ToggleOff    = Color3.fromRGB(50, 50, 65),
    ToggleKnobOn = Color3.fromRGB(200, 200, 255),
    ToggleKnobOff= Color3.fromRGB(100, 100, 120),
    SliderFill   = Color3.fromRGB(100, 70, 230),
    SliderBg     = Color3.fromRGB(50, 50, 65),
    TextWhite    = Color3.fromRGB(235, 235, 240),
    TextDim      = Color3.fromRGB(140, 140, 160),
    TextSection  = Color3.fromRGB(220, 220, 230),
    Red          = Color3.fromRGB(220, 55, 55),
    Green        = Color3.fromRGB(50, 200, 80),
    SidebarSel   = Color3.fromRGB(35, 35, 48),
    SidebarHover = Color3.fromRGB(30, 30, 40),
    Circle       = Color3.fromRGB(120, 80, 255),
    Border       = Color3.fromRGB(45, 45, 58),
}

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HyperDriveV8"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- ==================== CIRCLE BUTTON ====================
local CircleBtn = Instance.new("TextButton")
CircleBtn.Name = "CircleToggle"
CircleBtn.Size = UDim2.new(0, 50, 0, 50)
CircleBtn.Position = UDim2.new(0, 15, 0.5, -25)
CircleBtn.BackgroundColor3 = Colors.Circle
CircleBtn.Text = "HD"
CircleBtn.TextColor3 = Colors.TextWhite
CircleBtn.TextSize = 14
CircleBtn.Font = Enum.Font.GothamBold
CircleBtn.AutoButtonColor = false
CircleBtn.Visible = false
CircleBtn.ZIndex = 100
CircleBtn.Parent = ScreenGui
Instance.new("UICorner", CircleBtn).CornerRadius = UDim.new(1, 0)

local circleStroke = Instance.new("UIStroke", CircleBtn)
circleStroke.Color = Colors.TextWhite
circleStroke.Thickness = 2
circleStroke.Transparency = 0.5

-- Circle pulse
task.spawn(function()
    while true do
        if CircleBtn.Visible then
            Tween(CircleBtn, {Size = UDim2.new(0, 55, 0, 55)}, 0.8)
            task.wait(0.8)
            Tween(CircleBtn, {Size = UDim2.new(0, 50, 0, 50)}, 0.8)
            task.wait(0.8)
        else
            task.wait(0.5)
        end
    end
end)

-- Circle drag
local circleDragging, circleDragStart, circleStartPos = false, nil, nil
local circleDragMoved = false

CircleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        circleDragging = true
        circleDragMoved = false
        circleDragStart = input.Position
        circleStartPos = CircleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then circleDragging = false end
        end)
    end
end)

CircleBtn.InputChanged:Connect(function(input)
    if circleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - circleDragStart
        if delta.Magnitude > 5 then circleDragMoved = true end
        CircleBtn.Position = UDim2.new(circleStartPos.X.Scale, circleStartPos.X.Offset + delta.X, circleStartPos.Y.Scale, circleStartPos.Y.Offset + delta.Y)
    end
end)

-- ==================== MAIN FRAME ====================
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 850, 0, 500)
Main.Position = UDim2.new(0.5, -425, 0.5, -250)
Main.BackgroundColor3 = Colors.BgMain
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Colors.Border
mainStroke.Thickness = 1

-- ==================== TITLE BAR ====================
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Colors.BgSidebar
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

-- Title text
local titleLabel = Instance.new("TextLabel", TitleBar)
titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "HYPERDRIVE v8 : Blox Fruits"
titleLabel.TextColor3 = Colors.TextWhite
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local subtitleLabel = Instance.new("TextLabel", TitleBar)
subtitleLabel.Size = UDim2.new(0, 100, 1, 0)
subtitleLabel.Position = UDim2.new(0, 215, 0, 0)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "by HYPERDRIVE"
subtitleLabel.TextColor3 = Colors.TextDim
subtitleLabel.TextSize = 11
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Logo
local logo = Instance.new("TextLabel", TitleBar)
logo.Size = UDim2.new(0, 35, 0, 25)
logo.Position = UDim2.new(0, 12, 0, 5)
logo.BackgroundColor3 = Colors.Red
logo.Text = "HD"
logo.TextColor3 = Colors.TextWhite
logo.TextSize = 11
logo.Font = Enum.Font.GothamBold
logo.Parent = Main
logo.Position = UDim2.new(0, 12, 0, 42)
logo.ZIndex = 5
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 4)

-- Window Buttons
local function CreateWindowBtn(text, pos, color)
    local btn = Instance.new("TextButton", TitleBar)
    btn.Size = UDim2.new(0, 30, 0, 25)
    btn.Position = pos
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Colors.TextDim
    btn.TextSize = 18
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.MouseEnter:Connect(function() btn.TextColor3 = color end)
    btn.MouseLeave:Connect(function() btn.TextColor3 = Colors.TextDim end)
    return btn
end

local MinBtn = CreateWindowBtn("-", UDim2.new(1, -70, 0, 5), Colors.TextWhite)
local CloseBtn = CreateWindowBtn("X", UDim2.new(1, -38, 0, 5), Colors.Red)

-- Dragging
local dragging, dragStart, startPos = false, nil, nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==================== SIDEBAR ====================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 180, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Colors.BgSidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local sidebarScroll = Instance.new("ScrollingFrame", Sidebar)
sidebarScroll.Size = UDim2.new(1, 0, 1, -40)
sidebarScroll.Position = UDim2.new(0, 0, 0, 40)
sidebarScroll.BackgroundTransparency = 1
sidebarScroll.ScrollBarThickness = 0
sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local sidebarLayout = Instance.new("UIListLayout", sidebarScroll)
sidebarLayout.Padding = UDim.new(0, 2)
local sidebarPad = Instance.new("UIPadding", sidebarScroll)
sidebarPad.PaddingLeft = UDim.new(0, 6)
sidebarPad.PaddingRight = UDim.new(0, 6)
sidebarPad.PaddingTop = UDim.new(0, 4)

-- Tab definitions
local Tabs = {
    {Name = "Farm",        Icon = "H"},
    {Name = "Fishing",     Icon = "F"},
    {Name = "Quest/Items", Icon = "Q"},
    {Name = "Fruits/Raid", Icon = "R"},
    {Name = "Stats",       Icon = "S"},
    {Name = "Teleport",    Icon = "T"},
    {Name = "Status",      Icon = "B"},
    {Name = "Visual",      Icon = "V"},
    {Name = "Shop",        Icon = "P"},
    {Name = "Misc",        Icon = "M"},
}

local tabButtons = {}

local function SelectTab(tabName)
    State.CurrentTab = tabName
    for name, btn in pairs(tabButtons) do
        if name == tabName then
            btn.BackgroundColor3 = Colors.SidebarSel
            btn.indicator.Visible = true
        else
            btn.BackgroundColor3 = Color3.new(0, 0, 0)
            btn.BackgroundTransparency = 1
            btn.indicator.Visible = false
        end
    end
    for name, frame in pairs(State.TabFrames) do
        frame.Visible = (name == tabName)
    end
end

for i, tab in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Name = tab.Name
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Colors.SidebarSel
    btn.BackgroundTransparency = tab.Name == "Farm" and 0 or 1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.LayoutOrder = i
    btn.Parent = sidebarScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    -- Active indicator (left bar)
    local indicator = Instance.new("Frame", btn)
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 3, 0.6, 0)
    indicator.Position = UDim2.new(0, 0, 0.2, 0)
    indicator.BackgroundColor3 = Colors.Accent
    indicator.BorderSizePixel = 0
    indicator.Visible = (tab.Name == "Farm")
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 2)

    -- Icon
    local icon = Instance.new("TextLabel", btn)
    icon.Size = UDim2.new(0, 25, 0, 25)
    icon.Position = UDim2.new(0, 12, 0.5, -12)
    icon.BackgroundTransparency = 1
    icon.Text = tab.Icon
    icon.TextColor3 = Colors.TextDim
    icon.TextSize = 12
    icon.Font = Enum.Font.GothamBold

    -- Label
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -45, 1, 0)
    label.Position = UDim2.new(0, 42, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = tab.Name
    label.TextColor3 = Colors.TextWhite
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left

    btn.indicator = indicator
    tabButtons[tab.Name] = btn

    btn.MouseButton1Click:Connect(function() SelectTab(tab.Name) end)
    btn.MouseEnter:Connect(function()
        if State.CurrentTab ~= tab.Name then
            Tween(btn, {BackgroundTransparency = 0, BackgroundColor3 = Colors.SidebarHover}, 0.15)
        end
    end)
    btn.MouseLeave:Connect(function()
        if State.CurrentTab ~= tab.Name then
            Tween(btn, {BackgroundTransparency = 1}, 0.15)
        end
    end)
end

-- ==================== CONTENT AREA ====================
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -180, 1, -35)
ContentArea.Position = UDim2.new(0, 180, 0, 35)
ContentArea.BackgroundColor3 = Colors.BgContent
ContentArea.BorderSizePixel = 0
ContentArea.Parent = Main

-- Separator line
local sep = Instance.new("Frame", ContentArea)
sep.Size = UDim2.new(0, 1, 1, 0)
sep.BackgroundColor3 = Colors.Border
sep.BorderSizePixel = 0

-- ==================== UI COMPONENT BUILDERS ====================
local function CreateTabContent(tabName)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = tabName .. "Content"
    scroll.Size = UDim2.new(1, -10, 1, -10)
    scroll.Position = UDim2.new(0, 5, 0, 5)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Colors.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = (tabName == "Farm")
    scroll.Parent = ContentArea

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 4)
    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)

    State.TabFrames[tabName] = scroll
    return scroll
end

local function AddSection(parent, text, order)
    local label = Instance.new("TextLabel")
    label.Name = "Section_" .. text
    label.Size = UDim2.new(1, 0, 0, 28)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.TextSection
    label.TextSize = 15
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = order
    label.Parent = parent
    return label
end

local function AddToggle(parent, text, subtitle, configKey, order, callback)
    local row = Instance.new("TextButton")
    row.Name = "Toggle_" .. configKey
    row.Size = UDim2.new(1, 0, 0, subtitle and 48 or 42)
    row.BackgroundColor3 = Colors.BgCard
    row.AutoButtonColor = false
    row.Text = ""
    row.LayoutOrder = order
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Position = UDim2.new(0, 14, 0, subtitle and 8 or 11)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.TextWhite
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left

    if subtitle then
        local sub = Instance.new("TextLabel", row)
        sub.Size = UDim2.new(0.7, 0, 0, 14)
        sub.Position = UDim2.new(0, 14, 0, 28)
        sub.BackgroundTransparency = 1
        sub.Text = subtitle
        sub.TextColor3 = Colors.TextDim
        sub.TextSize = 10
        sub.Font = Enum.Font.Gotham
        sub.TextXAlignment = Enum.TextXAlignment.Left
    end

    -- Toggle switch (pill shape)
    local toggleBg = Instance.new("Frame", row)
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.Position = UDim2.new(1, -55, 0.5, -10)
    toggleBg.BackgroundColor3 = Config[configKey] and Colors.ToggleOn or Colors.ToggleOff
    toggleBg.BorderSizePixel = 0
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", toggleBg)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = Config[configKey] and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Config[configKey] and Colors.ToggleKnobOn or Colors.ToggleKnobOff
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function UpdateToggle()
        local on = Config[configKey]
        Tween(toggleBg, {BackgroundColor3 = on and Colors.ToggleOn or Colors.ToggleOff}, 0.2)
        Tween(knob, {
            Position = on and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2),
            BackgroundColor3 = on and Colors.ToggleKnobOn or Colors.ToggleKnobOff,
        }, 0.2)
    end

    row.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        UpdateToggle()
        Notify(text .. (Config[configKey] and " ON" or " OFF"))
        if callback then callback(Config[configKey]) end
    end)

    row.MouseEnter:Connect(function() Tween(row, {BackgroundColor3 = Colors.BgCardHover}, 0.15) end)
    row.MouseLeave:Connect(function() Tween(row, {BackgroundColor3 = Colors.BgCard}, 0.15) end)

    return row, UpdateToggle
end

local function AddSlider(parent, text, configKey, min, max, order)
    local row = Instance.new("Frame")
    row.Name = "Slider_" .. configKey
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = Colors.BgCard
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.TextWhite
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel", row)
    valueLabel.Size = UDim2.new(0, 40, 1, 0)
    valueLabel.Position = UDim2.new(0.4, 10, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(Config[configKey])
    valueLabel.TextColor3 = Colors.TextWhite
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold

    -- Slider track
    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(0.45, 0, 0, 6)
    track.Position = UDim2.new(0.5, 0, 0.5, -3)
    track.BackgroundColor3 = Colors.SliderBg
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    local pct = math.clamp((Config[configKey] - min) / (max - min), 0, 1)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Colors.SliderFill
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    -- Knob
    local sliderKnob = Instance.new("Frame", track)
    sliderKnob.Size = UDim2.new(0, 14, 0, 14)
    sliderKnob.Position = UDim2.new(pct, -7, 0.5, -7)
    sliderKnob.BackgroundColor3 = Colors.TextWhite
    sliderKnob.BorderSizePixel = 0
    sliderKnob.ZIndex = 5
    Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

    -- Interaction
    local sliderDragging = false

    local function UpdateSlider(inputPos)
        local trackAbsPos = track.AbsolutePosition.X
        local trackAbsSize = track.AbsoluteSize.X
        local relX = math.clamp((inputPos.X - trackAbsPos) / trackAbsSize, 0, 1)
        local value = math.floor(min + relX * (max - min))
        Config[configKey] = value
        valueLabel.Text = tostring(value)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        sliderKnob.Position = UDim2.new(relX, -7, 0.5, -7)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliderDragging = true
            UpdateSlider(input.Position)
        end
    end)

    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliderDragging = true
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input.Position)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliderDragging = false
        end
    end)

    return row
end

local function AddDropdown(parent, text, subtitle, options, configKey, order)
    local row = Instance.new("Frame")
    row.Name = "Dropdown_" .. configKey
    row.Size = UDim2.new(1, 0, 0, 45)
    row.BackgroundColor3 = Colors.BgCard
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.ClipsDescendants = false
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.5, 0, 0, 20)
    label.Position = UDim2.new(0, 14, 0, subtitle and 6 or 12)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.TextWhite
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left

    if subtitle then
        local sub = Instance.new("TextLabel", row)
        sub.Size = UDim2.new(0.5, 0, 0, 12)
        sub.Position = UDim2.new(0, 14, 0, 26)
        sub.BackgroundTransparency = 1
        sub.Text = subtitle
        sub.TextColor3 = Colors.TextDim
        sub.TextSize = 10
        sub.Font = Enum.Font.Gotham
        sub.TextXAlignment = Enum.TextXAlignment.Left
    end

    -- Arrow
    local arrow = Instance.new("TextLabel", row)
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.Position = UDim2.new(0.5, 10, 0.5, -10)
    arrow.BackgroundTransparency = 1
    arrow.Text = "^"
    arrow.Rotation = 180
    arrow.TextColor3 = Colors.TextDim
    arrow.TextSize = 14
    arrow.Font = Enum.Font.GothamBold

    -- Current value
    local valLabel = Instance.new("TextLabel", row)
    valLabel.Size = UDim2.new(0.35, 0, 1, 0)
    valLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(Config[configKey])
    valLabel.TextColor3 = Colors.TextWhite
    valLabel.TextSize = 14
    valLabel.Font = Enum.Font.GothamBold

    -- Dropdown items (hidden by default)
    local expanded = false
    local dropList = Instance.new("Frame", row)
    dropList.Size = UDim2.new(0.5, 0, 0, #options * 30)
    dropList.Position = UDim2.new(0.48, 0, 1, 2)
    dropList.BackgroundColor3 = Colors.BgCard
    dropList.BorderSizePixel = 0
    dropList.Visible = false
    dropList.ZIndex = 50
    Instance.new("UICorner", dropList).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", dropList).Color = Colors.Border

    local dlLayout = Instance.new("UIListLayout", dropList)
    dlLayout.Padding = UDim.new(0, 1)

    for _, option in ipairs(options) do
        local optBtn = Instance.new("TextButton", dropList)
        optBtn.Size = UDim2.new(1, 0, 0, 30)
        optBtn.BackgroundColor3 = Colors.BgCard
        optBtn.BackgroundTransparency = 0
        optBtn.Text = option
        optBtn.TextColor3 = Colors.TextWhite
        optBtn.TextSize = 12
        optBtn.Font = Enum.Font.Gotham
        optBtn.AutoButtonColor = false
        optBtn.ZIndex = 51

        optBtn.MouseButton1Click:Connect(function()
            Config[configKey] = option
            valLabel.Text = option
            dropList.Visible = false
            expanded = false
            arrow.Rotation = 180
        end)
        optBtn.MouseEnter:Connect(function() optBtn.BackgroundColor3 = Colors.BgCardHover end)
        optBtn.MouseLeave:Connect(function() optBtn.BackgroundColor3 = Colors.BgCard end)
    end

    -- Toggle dropdown
    local clickBtn = Instance.new("TextButton", row)
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 3

    clickBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        dropList.Visible = expanded
        arrow.Rotation = expanded and 0 or 180
    end)

    return row
end

local function AddButton(parent, text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Name = "Btn_" .. text
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Colors.BgCard
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.LayoutOrder = order
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(0.85, 0, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.TextWhite
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left

    local chevron = Instance.new("TextLabel", btn)
    chevron.Size = UDim2.new(0, 20, 1, 0)
    chevron.Position = UDim2.new(1, -30, 0, 0)
    chevron.BackgroundTransparency = 1
    chevron.Text = ">"
    chevron.TextColor3 = Colors.TextDim
    chevron.TextSize = 16
    chevron.Font = Enum.Font.GothamBold

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Colors.BgCardHover}, 0.15) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = Colors.BgCard}, 0.15) end)

    return btn
end

local function AddInfoBox(parent, text, order)
    local box = Instance.new("Frame")
    box.Name = "Info"
    box.Size = UDim2.new(1, 0, 0, 0)
    box.AutomaticSize = Enum.AutomaticSize.Y
    box.BackgroundColor3 = Colors.BgCard
    box.BorderSizePixel = 0
    box.LayoutOrder = order
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local pad = Instance.new("UIPadding", box)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)

    local label = Instance.new("TextLabel", box)
    label.Size = UDim2.new(1, 0, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.TextDim
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.RichText = true

    return box, label
end

local function AddStatusRow(parent, name, status, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = Colors.BgCard
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local nameLabel = Instance.new("TextLabel", row)
    nameLabel.Size = UDim2.new(0.6, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 14, 0, 4)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Colors.TextWhite
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local statusLabel = Instance.new("TextLabel", row)
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(0.6, 0, 0, 14)
    statusLabel.Position = UDim2.new(0, 14, 0, 24)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status : " .. status
    statusLabel.TextColor3 = status:find("Not") and Colors.Red or Colors.TextDim
    statusLabel.TextSize = 10
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left

    return row
end

-- =====================================================
-- ================= BUILD ALL TABS ====================
-- =====================================================

-- ==================== FARM TAB ====================
local farmTab = CreateTabContent("Farm")

AddDropdown(farmTab, "Select Tool", "Choose the tool you want to use", {"Sword", "Melee", "Blox Fruit", "Gun"}, "SelectTool", 1)
AddDropdown(farmTab, "UI Scale", "Adjust the user interface size", {"Small", "Medium", "Large"}, "UIScale", 2)

AddSection(farmTab, "Main Farm", 3)
AddToggle(farmTab, "Auto Farm Level", "Farm Level", "AutoFarmLevel", 4, function(v)
    if v then task.spawn(AutoFarmLevelLoop) end
end)
AddToggle(farmTab, "Auto Farm Nearest", "Auto Farm Nearest Mobs", "AutoFarmNearest", 5, function(v)
    if v then task.spawn(AutoFarmNearestLoop) end
end)

AddSection(farmTab, "Event", 6)
AddToggle(farmTab, "Auto Fishing", "Auto Fish to get eggs", "AutoFishing", 7, function(v)
    if v then task.spawn(AutoFishingLoop) end
end)
AddToggle(farmTab, "Auto Collect Eggs", nil, "AutoCollectEggs", 8, nil)
AddToggle(farmTab, "ESP Eggs", nil, "ESPEggs", 9, nil)

AddSection(farmTab, "Chest", 10)
AddToggle(farmTab, "Auto Chest [ Tween ]", nil, "AutoChestTween", 11, function(v)
    if v then task.spawn(AutoChestLoop) end
end)
AddToggle(farmTab, "Auto Chest [ Bypass ]", nil, "AutoChestBypass", 12, function(v)
    if v then task.spawn(AutoChestLoop) end
end)

-- ==================== FISHING TAB ====================
local fishTab = CreateTabContent("Fishing")
AddSection(fishTab, "Fishing Settings", 1)
AddToggle(fishTab, "Auto Fishing", "Automatically cast and reel", "AutoFishing", 2, function(v)
    if v then task.spawn(AutoFishingLoop) end
end)
AddToggle(fishTab, "Auto Collect Eggs", nil, "AutoCollectEggs", 3, nil)
AddToggle(fishTab, "ESP Eggs", nil, "ESPEggs", 4, nil)

-- ==================== QUEST/ITEMS TAB ====================
local questTab = CreateTabContent("Quest/Items")

AddSection(questTab, "Quest Sea 1", 1)
AddToggle(questTab, "AutoSecondSea", nil, "AutoSecondSea", 2, nil)

AddSection(questTab, "Boss Greybeard", 3)
AddToggle(questTab, "Kill Greybeard", nil, "KillGreybeard", 4, nil)

AddSection(questTab, "Quest Sword", 5)
AddToggle(questTab, "Auto Get Saber", nil, "AutoGetSaber", 6, nil)
AddToggle(questTab, "Auto Get Sword Pole", nil, "AutoGetSwordPole", 7, nil)
AddToggle(questTab, "Auto Get Sword Saw", nil, "AutoGetSwordSaw", 8, nil)
AddToggle(questTab, "Auto Get Sword Wardens", nil, "AutoGetWardens", 9, nil)
AddToggle(questTab, "Auto Get Sword Trident", nil, "AutoGetTrident", 10, nil)

-- ==================== FRUITS/RAID TAB ====================
local fruitTab = CreateTabContent("Fruits/Raid")

AddSection(fruitTab, "Fruits", 1)
AddToggle(fruitTab, "Auto Random Fruits", nil, "AutoRandomFruits", 2, function(v)
    if v then task.spawn(AutoRandomFruitsLoop) end
end)
AddToggle(fruitTab, "Auto Store Fruits", nil, "AutoStoreFruits", 3, function(v)
    if v then task.spawn(AutoStoreFruitsLoop) end
end)
AddToggle(fruitTab, "Auto Teleport Fruits", nil, "AutoTeleportFruits", 4, function(v)
    if v then task.spawn(AutoTeleportFruitsLoop) end
end)

AddSection(fruitTab, "Check Stock Fruits", 5)
local stockText = GetFruitStock()
AddInfoBox(fruitTab, stockText, 6)

AddSection(fruitTab, "Raids", 7)
AddInfoBox(fruitTab, "Raids only works in Sea 2 and 3", 8)
AddToggle(fruitTab, "Raid Law Only Sea 2", nil, "RaidLawSea2", 9, nil)

-- ==================== STATS TAB ====================
local statsTab = CreateTabContent("Stats")

AddSlider(statsTab, "Points Amount", "PointsAmount", 1, 10, 1)
AddToggle(statsTab, "Auto Status", nil, "AutoStatus", 2, function(v)
    if v then task.spawn(AutoStatsLoop) end
end)

AddSection(statsTab, "Select Status", 3)
AddToggle(statsTab, "Melee", nil, "StatMelee", 4, nil)
AddToggle(statsTab, "Defense", nil, "StatDefense", 5, nil)
AddToggle(statsTab, "Sword", nil, "StatSword", 6, nil)
AddToggle(statsTab, "Gun", nil, "StatGun", 7, nil)
AddToggle(statsTab, "Fruit", nil, "StatFruit", 8, nil)

-- ==================== TELEPORT TAB ====================
local tpTab = CreateTabContent("Teleport")

AddSection(tpTab, "Travel", 1)
AddButton(tpTab, "Teleport to Sea 1\nMain", 2, function() TeleportToSea("Sea 1") end)
AddButton(tpTab, "Teleport to Sea 2\nDressrosa", 3, function() TeleportToSea("Sea 2") end)
AddButton(tpTab, "Teleport to Sea 3\nZou", 4, function() TeleportToSea("Sea 3") end)

AddSection(tpTab, "Islands", 5)
AddDropdown(tpTab, "Select Island", nil, Islands, "SelectedIsland", 6)
AddToggle(tpTab, "Teleport To Island", nil, "TeleportToIsland", 7, nil)

-- ==================== STATUS TAB ====================
local statusTab = CreateTabContent("Status")

local bosses = GetBossStatus()
for i, boss in ipairs(bosses) do
    AddStatusRow(statusTab, boss.Name, boss.Status, i)
end

-- Update boss status periodically
task.spawn(function()
    while true do
        task.wait(10)
        if State.CurrentTab == "Status" then
            local newBosses = GetBossStatus()
            -- Update labels
            pcall(function()
                for _, child in ipairs(statusTab:GetChildren()) do
                    if child:IsA("Frame") then
                        local sl = child:FindFirstChild("Status")
                        if sl then
                            for _, b in ipairs(newBosses) do
                                if child:FindFirstChild("TextLabel") and child.TextLabel then
                                    -- Match by name
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ==================== VISUAL TAB ====================
local visualTab = CreateTabContent("Visual")

AddSection(visualTab, "Aimbot Nearest", 1)
AddToggle(visualTab, "Aimbot Gun", nil, "AimbotGun", 2, nil)
AddToggle(visualTab, "Aimbot Tap", nil, "AimbotTap", 3, nil)
AddToggle(visualTab, "Aimbot Skills", nil, "AimbotSkills", 4, nil)
AddToggle(visualTab, "Ignore Mobs", nil, "IgnoreMobs", 5, nil)

AddSection(visualTab, "Aimbot skill V2", 6)
AddToggle(visualTab, "Enable Aimbot Skill", nil, "EnableAimbotSkill", 7, nil)
AddToggle(visualTab, "Aimbot on Players", nil, "AimbotOnPlayers", 8, nil)
AddToggle(visualTab, "Aimbot on Mobs", nil, "AimbotOnMobs", 9, nil)

AddSection(visualTab, "Esp", 10)
AddSlider(visualTab, "ESP Size", "ESPSize", 1, 100, 11)
AddToggle(visualTab, "ESP Players", nil, "ESPPlayers", 12, function(v)
    if v then task.spawn(ESPLoop) else ClearESP() end
end)

-- ==================== SHOP TAB ====================
local shopTab = CreateTabContent("Shop")

AddSection(shopTab, "Fighting Style", 1)
AddToggle(shopTab, "Buy Black Leg", nil, "BuyBlackLeg", 2, nil)
AddToggle(shopTab, "Buy Electro", nil, "BuyElectro", 3, nil)
AddToggle(shopTab, "Buy Fishman Karate", nil, "BuyFishmanKarate", 4, nil)
AddToggle(shopTab, "Buy Superhuman", nil, "BuySuperhuman", 5, nil)
AddToggle(shopTab, "Buy Death Step", nil, "BuyDeathStep", 6, nil)
AddToggle(shopTab, "Buy Sharkman Karate", nil, "BuySharkmanKarate", 7, nil)
AddToggle(shopTab, "Buy Electric Claw", nil, "BuyElectricClaw", 8, nil)
AddToggle(shopTab, "Buy Dragon Talon", nil, "BuyDragonTalon", 9, nil)
AddToggle(shopTab, "Buy God Human", nil, "BuyGodHuman", 10, nil)
AddToggle(shopTab, "Buy Sanguine Art", nil, "BuySanguineArt", 11, nil)

AddSection(shopTab, "Buy Sea Event Crafting", 12)

-- ==================== MISC TAB ====================
local miscTab = CreateTabContent("Misc")

AddSection(miscTab, "Movement", 1)
AddToggle(miscTab, "Fly", nil, "Fly", 2, function(v)
    if v then StartFly() else StopFly() end
end)
AddToggle(miscTab, "Noclip", nil, "Noclip", 3, function(v)
    if v then task.spawn(NoclipLoop) end
end)
AddSlider(miscTab, "Fly Speed", "FlySpeed", 10, 200, 4)
AddSlider(miscTab, "Fly Height", "FlyHeight", 5, 50, 5)

AddSection(miscTab, "Config.", 6)
AddSlider(miscTab, "Farm Distance", "FarmDistance", 50, 500, 7)
AddSlider(miscTab, "Bring Range", "BringRange", 50, 500, 8)
AddSlider(miscTab, "Tween Speed", "TweenSpeed", 50, 500, 9)
AddToggle(miscTab, "Bring Mobs", nil, "BringMobs", 10, nil)
AddToggle(miscTab, "Auto Haki", nil, "AutoHaki", 11, function(v)
    if v then task.spawn(AutoHakiLoop) end
end)
AddToggle(miscTab, "Auto Attack", nil, "AutoAttack", 12, nil)
AddToggle(miscTab, "Auto Shoot", nil, "AutoShoot", 13, nil)
AddToggle(miscTab, "Attack Mobs", nil, "AttackMobs", 14, nil)

AddSection(miscTab, "Other", 15)
AddToggle(miscTab, "Anti-AFK", nil, "AntiAFK", 16, nil)
AddToggle(miscTab, "Infinite Jump", nil, "InfiniteJump", 17, nil)
AddToggle(miscTab, "Fast Attack", nil, "FastAttack", 18, nil)
AddToggle(miscTab, "God Mode", nil, "GodMode", 19, nil)
AddToggle(miscTab, "Auto Rejoin", nil, "AutoRejoin", 20, nil)

-- ==================== MINIMIZE / HIDE ====================
MinBtn.MouseButton1Click:Connect(function()
    State.UIHidden = true
    Tween(Main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
    task.wait(0.35)
    Main.Visible = false
    CircleBtn.Visible = true
    CircleBtn.Size = UDim2.new(0, 0, 0, 0)
    Tween(CircleBtn, {Size = UDim2.new(0, 50, 0, 50)}, 0.3)
end)

CloseBtn.MouseButton1Click:Connect(function()
    State.UIHidden = true
    Tween(Main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
    task.wait(0.35)
    Main.Visible = false
    CircleBtn.Visible = true
    CircleBtn.Size = UDim2.new(0, 0, 0, 0)
    Tween(CircleBtn, {Size = UDim2.new(0, 50, 0, 50)}, 0.3)
end)

CircleBtn.MouseButton1Click:Connect(function()
    if circleDragMoved then circleDragMoved = false return end
    State.UIHidden = false
    Tween(CircleBtn, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
    task.wait(0.25)
    CircleBtn.Visible = false
    Main.Visible = true
    Main.BackgroundTransparency = 0
    Main.Size = UDim2.new(0, 0, 0, 0)
    Tween(Main, {Size = UDim2.new(0, 850, 0, 500)}, 0.3)
end)

-- ==================== KEYBIND: LeftControl to toggle ====================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        if State.UIHidden then
            State.UIHidden = false
            CircleBtn.Visible = false
            Main.Visible = true
            Main.BackgroundTransparency = 0
            Main.Size = UDim2.new(0, 0, 0, 0)
            Tween(Main, {Size = UDim2.new(0, 850, 0, 500)}, 0.3)
        else
            State.UIHidden = true
            Tween(Main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
            task.wait(0.35)
            Main.Visible = false
            CircleBtn.Visible = true
            Tween(CircleBtn, {Size = UDim2.new(0, 50, 0, 50)}, 0.2)
        end
    end
end)

-- ==================== STARTUP ====================
SelectTab("Farm") -- Default tab

Notify("HYPERDRIVE v8 Loaded!")
Notify("LeftControl to minimize.")
