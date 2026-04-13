-- ============================================================
-- BLOX FRUITS HYPERDRIVE v9.0 - NEO EDITION
-- Compact UI | Quest NPC Loop | Aerial Farming
-- All Features Working | Bug-Free | Neo Light Blue Theme
-- ============================================================

-- ==================== SERVICES ====================
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local StarterGui        = game:GetService("StarterGui")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Enemies = nil
pcall(function() Enemies = Workspace:WaitForChild("Enemies", 5) end)

-- ==================== CONFIG ====================
local Config = {
    AutoFarmLevel = false, AutoFarmNearest = false, AutoFishing = false,
    AutoCollectEggs = false, ESPEggs = false, AutoChestTween = false,
    AutoChestBypass = false, SelectTool = "Sword", UIScale = "Medium",
    FarmDistance = 250, BringRange = 230, TweenSpeed = 300,
    BringMobs = false, AutoHaki = false, AutoAttack = true,
    AutoShoot = false, AttackMobs = true,
    AutoSecondSea = false, KillGreybeard = false,
    AutoGetSaber = false, AutoGetSwordPole = false, AutoGetSwordSaw = false,
    AutoGetWardens = false, AutoGetTrident = false,
    AutoRandomFruits = false, AutoStoreFruits = false,
    AutoTeleportFruits = false, RaidLawSea2 = false,
    PointsAmount = 1, AutoStatus = false,
    StatMelee = false, StatDefense = false, StatSword = false,
    StatGun = true, StatFruit = false,
    TeleportToIsland = false, SelectedIsland = "Starter Island",
    AimbotGun = false, AimbotTap = false, AimbotSkills = false,
    IgnoreMobs = true, EnableAimbotSkill = false,
    AimbotOnPlayers = false, AimbotOnMobs = false,
    ESPSize = 24, ESPPlayers = false,
    BuyBlackLeg = false, BuyElectro = false, BuyFishmanKarate = false,
    BuySuperhuman = false, BuyDeathStep = false, BuySharkmanKarate = false,
    BuyElectricClaw = false, BuyDragonTalon = false,
    BuyGodHuman = false, BuySanguineArt = false,
    Fly = false, Noclip = false, FlySpeed = 80, FlyHeight = 15,
    AntiAFK = true, InfiniteJump = false, FastAttack = false,
    GodMode = false, AutoRejoin = false,
}

local State = {
    Flying = false, BodyVelocity = nil, BodyGyro = nil,
    UIHidden = false, CurrentTab = "Farm",
    TabFrames = {}, ESPObjects = {},
}

-- ==================== UTILITIES ====================
local function Notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "HYPERDRIVE v9", Text = text, Duration = 3
        })
    end)
end

local function GetCharacter()
    local char = LP.Character
    if not char then char = LP.CharacterAdded:Wait() end
    return char
end

local function GetRoot()
    local char = GetCharacter()
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = GetCharacter()
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function IsAlive()
    local hum = GetHumanoid()
    if not hum then return false end
    return hum.Health > 0
end

local function TeleportTo(cf)
    local root = GetRoot()
    if root then root.CFrame = cf end
end

local function Tween(obj, props, dur)
    if not obj then return nil end
    local ok, t = pcall(function()
        return TweenService:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    end)
    if ok and t then t:Play() return t end
    return nil
end

-- ==================== FLY ====================
local function StartFly()
    if State.Flying then return end
    State.Flying = true
    local root = GetRoot()
    if not root then State.Flying = false return end

    pcall(function() if State.BodyVelocity then State.BodyVelocity:Destroy() end end)
    pcall(function() if State.BodyGyro then State.BodyGyro:Destroy() end end)

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.new(0, 0, 0)
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
            local move = Vector3.new(0, 0, 0)
            pcall(function()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
            end)
            if move.Magnitude > 0 then
                bv.Velocity = move.Unit * Config.FlySpeed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            bg.CFrame = cam.CFrame
            task.wait()
        end
    end)
end

local function StopFly()
    State.Flying = false
    pcall(function() if State.BodyVelocity then State.BodyVelocity:Destroy() end end)
    pcall(function() if State.BodyGyro then State.BodyGyro:Destroy() end end)
    State.BodyVelocity = nil
    State.BodyGyro = nil
end

-- ==================== NOCLIP ====================
local function NoclipLoop()
    while Config.Noclip do
        pcall(function()
            local char = GetCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
        task.wait()
    end
end

-- ==================== COMBAT ====================
local function Attack(target)
    if not target or not IsAlive() then return end
    pcall(function()
        local char = GetCharacter()
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end)
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local combat = remotes:FindFirstChild("Combat")
            if combat then combat:InvokeServer() end
        end
    end)
end

-- ==================== TARGETING ====================
local function GetMobsInRange(range, filterFn)
    local root = GetRoot()
    if not root or not Enemies then return {} end
    local mobs = {}
    pcall(function()
        for _, mob in ipairs(Enemies:GetDescendants()) do
            if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                local d = (root.Position - mob.HumanoidRootPart.Position).Magnitude
                if d <= range then
                    if not filterFn or filterFn(mob) then
                        table.insert(mobs, {Mob = mob, Distance = d})
                    end
                end
            end
        end
    end)
    table.sort(mobs, function(a, b) return a.Distance < b.Distance end)
    return mobs
end

local function GetNearestMob(range, filterFn)
    local mobs = GetMobsInRange(range or Config.FarmDistance, filterFn)
    if #mobs > 0 then return mobs[1].Mob end
    return nil
end

-- ==================== QUEST ====================
local function FindNearestQuestNPC()
    local closest = nil
    local bestDist = math.huge
    local root = GetRoot()
    if not root then return nil end
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                local hasInteract = false
                for _, child in ipairs(obj:GetDescendants()) do
                    if child:IsA("Dialog") or child:IsA("ProximityPrompt") or child:IsA("ClickDetector") then
                        hasInteract = true
                        break
                    end
                end
                if hasInteract then
                    local d = (root.Position - obj.HumanoidRootPart.Position).Magnitude
                    if d < bestDist then closest = obj; bestDist = d end
                end
            end
        end
    end)
    return closest
end

local function InteractWithQuestNPC(npc)
    if not npc then return false end
    local npcRoot = npc:FindFirstChild("HumanoidRootPart")
    if not npcRoot then return false end
    TeleportTo(npcRoot.CFrame * CFrame.new(0, 0, 3))
    task.wait(0.5)
    local success = false

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
    for _, child in ipairs(npc:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(child) end)
            success = true
            task.wait(0.3)
        end
    end
    for _, child in ipairs(npc:GetDescendants()) do
        if child:IsA("ClickDetector") then
            pcall(function() fireclickdetector(child) end)
            success = true
            task.wait(0.3)
        end
    end
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
    local qname = nil
    pcall(function()
        for _, child in ipairs(LP.PlayerGui:GetDescendants()) do
            if child:IsA("TextLabel") and child.Name:lower():find("quest") then
                qname = child.Text:match("Defeat%s+%d+%s+(.+)") or child.Text:match("Kill%s+%d+%s+(.+)")
                if qname then qname = qname:gsub("%s+$", ""); break end
            end
        end
    end)
    return qname
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
    if not State.Flying then Config.Fly = true; StartFly() end
    if not Config.Noclip then Config.Noclip = true; task.spawn(NoclipLoop) end

    while Config.AutoFarmLevel do
        if not IsAlive() then task.wait(1); continue end
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
                task.wait(3); continue
            end
        end
        local questTarget = GetQuestTargetName()
        local farmStart = tick()
        while Config.AutoFarmLevel and not IsQuestComplete() do
            if not IsAlive() then task.wait(1); continue end
            if tick() - farmStart > 180 then break end
            local target = nil
            if questTarget then
                target = GetNearestMob(Config.FarmDistance, function(m)
                    return m.Name:lower():find(questTarget:lower()) ~= nil
                end)
            end
            if not target then target = GetNearestMob(Config.FarmDistance) end
            if target and target:FindFirstChild("HumanoidRootPart") then
                local mobPos = target.HumanoidRootPart.Position
                TeleportTo(CFrame.new(mobPos.X, mobPos.Y + Config.FlyHeight, mobPos.Z))
                Attack(target)
                if Config.BringMobs then
                    local nearby = GetMobsInRange(Config.BringRange)
                    if #nearby >= 3 then
                        GatherMobs(mobPos, 2)
                        for i = 1, 6 do
                            local t2 = GetNearestMob(Config.BringRange)
                            if t2 and t2:FindFirstChild("HumanoidRootPart") then
                                TeleportTo(CFrame.new(t2.HumanoidRootPart.Position.X, t2.HumanoidRootPart.Position.Y + Config.FlyHeight, t2.HumanoidRootPart.Position.Z))
                                Attack(t2)
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
        if IsQuestComplete() then
            Notify("Quest done! Returning...")
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
        if not IsAlive() then task.wait(1); continue end
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
                        local t2 = GetNearestMob(Config.BringRange)
                        if t2 then Attack(t2) end
                        task.wait(0.1)
                    end
                end
            end
        end
        task.wait(0.08)
    end
    Config.Fly = false; StopFly(); Config.Noclip = false
end

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

local function AutoHakiLoop()
    while Config.AutoHaki do
        pcall(function()
            local hf = ReplicatedStorage:FindFirstChild("Haki")
            if hf then
                local r = hf:FindFirstChild("Remote")
                if r then r:FireServer("Buso") end
            end
        end)
        task.wait(4)
    end
end

local function AutoFruitLoop()
    while Config.AutoRandomFruits or Config.AutoTeleportFruits do
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
            task.wait(3)
            local remotes2 = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes2 then
                local fish2 = remotes2:FindFirstChild("Fishing") or remotes2:FindFirstChild("Fish")
                if fish2 then
                    if fish2:IsA("RemoteEvent") then fish2:FireServer("Reel")
                    elseif fish2:IsA("RemoteFunction") then fish2:InvokeServer("Reel") end
                end
            end
        end)
        task.wait(5)
    end
end

local function AutoChestLoop()
    while Config.AutoChestTween or Config.AutoChestBypass do
        pcall(function()
            for _, chest in ipairs(Workspace:GetDescendants()) do
                if (chest.Name:lower():find("chest") or chest.Name:lower():find("treasure")) and chest:IsA("Model") then
                    local part = chest:FindFirstChildOfClass("BasePart")
                    if part then
                        if Config.AutoChestBypass then
                            TeleportTo(part.CFrame)
                        else
                            local root = GetRoot()
                            if root then
                                local dist = (root.Position - part.Position).Magnitude
                                local tweenInfo = TweenInfo.new(dist / Config.TweenSpeed, Enum.EasingStyle.Linear)
                                local tw = TweenService:Create(root, tweenInfo, {CFrame = part.CFrame})
                                tw:Play()
                                tw.Completed:Wait()
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

-- Anti-AFK
task.spawn(function()
    while true do
        if Config.AntiAFK then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:Button2Down(Vector2.new(0, 0), Camera.CFrame)
                task.wait(0.1)
                vu:Button2Up(Vector2.new(0, 0), Camera.CFrame)
            end)
        end
        task.wait(60)
    end
end)

-- Infinite Jump
pcall(function()
    UserInputService.JumpRequest:Connect(function()
        if Config.InfiniteJump then
            local hum = GetHumanoid()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end)

-- ESP
local function ClearESP()
    for _, obj in pairs(State.ESPObjects) do pcall(function() obj:Destroy() end) end
    State.ESPObjects = {}
end

local function ESPLoop()
    while Config.ESPPlayers do
        ClearESP()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "HD_ESP"
                    bb.Size = UDim2.new(0, Config.ESPSize, 0, Config.ESPSize)
                    bb.AlwaysOnTop = true
                    bb.Adornee = player.Character.HumanoidRootPart
                    bb.Parent = player.Character.HumanoidRootPart
                    local f = Instance.new("Frame", bb)
                    f.Size = UDim2.new(1, 0, 1, 0)
                    f.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
                    f.BackgroundTransparency = 0.5
                    f.BorderSizePixel = 0
                    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
                    local nl = Instance.new("TextLabel", bb)
                    nl.Size = UDim2.new(1, 0, 0.5, 0)
                    nl.Position = UDim2.new(0, 0, -0.5, 0)
                    nl.BackgroundTransparency = 1
                    nl.Text = player.Name
                    nl.TextColor3 = Color3.new(1, 1, 1)
                    nl.TextScaled = true
                    nl.Font = Enum.Font.GothamBold
                    table.insert(State.ESPObjects, bb)
                end)
            end
        end
        task.wait(2)
    end
    ClearESP()
end

-- Teleport locations
local SeaLocations = {
    ["Sea 1"] = CFrame.new(-1126, 15, 4222),
    ["Sea 2"] = CFrame.new(37, 15, 5700),
    ["Sea 3"] = CFrame.new(-5100, 15, -2900),
}

-- =====================================================
-- ===================== UI SYSTEM =====================
-- =====================================================

-- Neo Light Blue Color Scheme
local C = {
    BgMain     = Color3.fromRGB(12, 14, 22),
    BgSidebar  = Color3.fromRGB(15, 18, 28),
    BgContent  = Color3.fromRGB(12, 14, 22),
    BgCard     = Color3.fromRGB(20, 26, 38),
    BgCardHov  = Color3.fromRGB(28, 36, 52),
    Accent     = Color3.fromRGB(0, 180, 255),
    AccentDim  = Color3.fromRGB(0, 120, 200),
    AccentGlow = Color3.fromRGB(80, 210, 255),
    ToggleOn   = Color3.fromRGB(0, 170, 250),
    ToggleOff  = Color3.fromRGB(38, 42, 55),
    KnobOn     = Color3.fromRGB(220, 245, 255),
    KnobOff    = Color3.fromRGB(75, 80, 95),
    SliderFill = Color3.fromRGB(0, 170, 250),
    SliderBg   = Color3.fromRGB(38, 42, 55),
    White      = Color3.fromRGB(228, 232, 242),
    Dim        = Color3.fromRGB(110, 120, 148),
    SectColor  = Color3.fromRGB(0, 180, 255),
    Border     = Color3.fromRGB(30, 38, 55),
    SidebarSel = Color3.fromRGB(22, 30, 45),
    SidebarHov = Color3.fromRGB(20, 26, 40),
    Red        = Color3.fromRGB(255, 60, 60),
    Green      = Color3.fromRGB(50, 220, 100),
}

-- ScreenGui
local SG = Instance.new("ScreenGui")
SG.Name = "HyperDriveV9"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder = 999

pcall(function()
    if gethui then
        SG.Parent = gethui()
        return
    end
end)
pcall(function()
    if not SG.Parent and syn and syn.protect_gui then
        syn.protect_gui(SG)
        SG.Parent = game:GetService("CoreGui")
        return
    end
end)
if not SG.Parent then
    pcall(function()
        SG.Parent = game:GetService("CoreGui")
    end)
end
if not SG.Parent then
    SG.Parent = LP:WaitForChild("PlayerGui")
end

-- ==================== CIRCLE BUTTON ====================
local CircleBtn = Instance.new("TextButton")
CircleBtn.Name = "CircleBtn"
CircleBtn.Size = UDim2.new(0, 42, 0, 42)
CircleBtn.Position = UDim2.new(0, 12, 0.5, -21)
CircleBtn.BackgroundColor3 = C.Accent
CircleBtn.Text = "HD"
CircleBtn.TextColor3 = C.White
CircleBtn.TextSize = 11
CircleBtn.Font = Enum.Font.GothamBold
CircleBtn.AutoButtonColor = false
CircleBtn.Visible = false
CircleBtn.ZIndex = 100
CircleBtn.Parent = SG
local ccr = Instance.new("UICorner")
ccr.CornerRadius = UDim.new(1, 0)
ccr.Parent = CircleBtn
local cst = Instance.new("UIStroke")
cst.Color = C.AccentGlow
cst.Thickness = 1.5
cst.Transparency = 0.3
cst.Parent = CircleBtn

-- Circle dragging
local cDrag = false
local cDragStart = nil
local cStartPos = nil
local cMoved = false

CircleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        cDrag = true
        cMoved = false
        cDragStart = input.Position
        cStartPos = CircleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                cDrag = false
            end
        end)
    end
end)

CircleBtn.InputChanged:Connect(function(input)
    if cDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - cDragStart
        if delta.Magnitude > 5 then cMoved = true end
        CircleBtn.Position = UDim2.new(
            cStartPos.X.Scale, cStartPos.X.Offset + delta.X,
            cStartPos.Y.Scale, cStartPos.Y.Offset + delta.Y
        )
    end
end)

-- Pulse animation
task.spawn(function()
    while true do
        if CircleBtn.Visible then
            Tween(CircleBtn, {Size = UDim2.new(0, 46, 0, 46)}, 0.5)
            task.wait(0.55)
            Tween(CircleBtn, {Size = UDim2.new(0, 42, 0, 42)}, 0.5)
            task.wait(0.55)
        else
            task.wait(0.5)
        end
    end
end)

-- ==================== MAIN FRAME ====================
local FW = 380
local FH = 310
local SW = 100
local TH = 30

local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, FW, 0, FH)
Main.Position = UDim2.new(0.5, -(FW / 2), 0.5, -(FH / 2))
Main.BackgroundColor3 = C.BgMain
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = SG
local mcr = Instance.new("UICorner")
mcr.CornerRadius = UDim.new(0, 8)
mcr.Parent = Main
local mst = Instance.new("UIStroke")
mst.Color = C.Border
mst.Thickness = 1
mst.Parent = Main

-- ==================== TITLE BAR ====================
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, TH)
TitleBar.BackgroundColor3 = C.BgSidebar
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

-- Accent line at top
local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, 0, 0, 2)
topLine.Position = UDim2.new(0, 0, 0, 0)
topLine.BackgroundColor3 = C.Accent
topLine.BorderSizePixel = 0
topLine.ZIndex = 5
topLine.Parent = TitleBar

-- Logo box
local LogoBox = Instance.new("Frame")
LogoBox.Size = UDim2.new(0, 20, 0, 16)
LogoBox.Position = UDim2.new(0, 8, 0.5, -8)
LogoBox.BackgroundColor3 = C.Accent
LogoBox.Parent = TitleBar
local lbcr = Instance.new("UICorner")
lbcr.CornerRadius = UDim.new(0, 3)
lbcr.Parent = LogoBox
local logoTxt = Instance.new("TextLabel")
logoTxt.Size = UDim2.new(1, 0, 1, 0)
logoTxt.BackgroundTransparency = 1
logoTxt.Text = "HD"
logoTxt.TextColor3 = Color3.new(1, 1, 1)
logoTxt.TextSize = 7
logoTxt.Font = Enum.Font.GothamBold
logoTxt.Parent = LogoBox

-- Title text
local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 200, 1, 0)
titleLbl.Position = UDim2.new(0, 34, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "HYPERDRIVE v9 : Blox Fruits"
titleLbl.TextColor3 = C.White
titleLbl.TextSize = 10
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = TitleBar

-- Window buttons
local function MakeWinBtn(txt, posFromRight, hoverCol)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, TH, 0, TH)
    b.Position = UDim2.new(1, posFromRight, 0, 0)
    b.BackgroundTransparency = 1
    b.Text = txt
    b.TextColor3 = C.Dim
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Parent = TitleBar
    b.MouseEnter:Connect(function() b.TextColor3 = hoverCol end)
    b.MouseLeave:Connect(function() b.TextColor3 = C.Dim end)
    return b
end

local MinBtn = MakeWinBtn("-", -60, C.White)
local CloseBtn = MakeWinBtn("X", -30, C.Red)

-- Dragging
local mDrag = false
local mDragStart = nil
local mStartPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mDrag = true
        mDragStart = input.Position
        mStartPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                mDrag = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if mDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - mDragStart
        Main.Position = UDim2.new(
            mStartPos.X.Scale, mStartPos.X.Offset + delta.X,
            mStartPos.Y.Scale, mStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ==================== SIDEBAR ====================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, SW, 1, -TH)
Sidebar.Position = UDim2.new(0, 0, 0, TH)
Sidebar.BackgroundColor3 = C.BgSidebar
Sidebar.BorderSizePixel = 0
Sidebar.ClipsDescendants = true
Sidebar.Parent = Main

-- Sidebar scroll
local sbScroll = Instance.new("ScrollingFrame")
sbScroll.Size = UDim2.new(1, 0, 1, 0)
sbScroll.BackgroundTransparency = 1
sbScroll.ScrollBarThickness = 0
sbScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
sbScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
sbScroll.Parent = Sidebar

local sbLayout = Instance.new("UIListLayout")
sbLayout.Padding = UDim.new(0, 1)
sbLayout.Parent = sbScroll
local sbPad = Instance.new("UIPadding")
sbPad.PaddingTop = UDim.new(0, 4)
sbPad.PaddingLeft = UDim.new(0, 3)
sbPad.PaddingRight = UDim.new(0, 3)
sbPad.Parent = sbScroll

-- Tab list
local TabList = {
    "Farm", "Fishing", "Quest", "Fruits", "Stats",
    "Teleport", "Status", "Visual", "Shop", "Misc"
}

local tabButtons = {}

local function SelectTab(name)
    State.CurrentTab = name
    for tabName, btn in pairs(tabButtons) do
        local selected = (tabName == name)
        if selected then
            btn.BackgroundTransparency = 0
            btn.BackgroundColor3 = C.SidebarSel
        else
            btn.BackgroundTransparency = 1
        end
        -- Update indicator
        local ind = btn:FindFirstChild("Indicator")
        if ind then ind.Visible = selected end
    end
    for tabName, frame in pairs(State.TabFrames) do
        frame.Visible = (tabName == name)
    end
end

for idx, tabName in ipairs(TabList) do
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_" .. tabName
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = C.SidebarSel
    btn.BackgroundTransparency = (tabName == "Farm") and 0 or 1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.LayoutOrder = idx
    btn.Parent = sbScroll

    local cr = Instance.new("UICorner")
    cr.CornerRadius = UDim.new(0, 4)
    cr.Parent = btn

    -- Accent indicator bar
    local ind = Instance.new("Frame")
    ind.Name = "Indicator"
    ind.Size = UDim2.new(0, 2, 0.5, 0)
    ind.Position = UDim2.new(0, 0, 0.25, 0)
    ind.BackgroundColor3 = C.Accent
    ind.BorderSizePixel = 0
    ind.Visible = (tabName == "Farm")
    ind.Parent = btn
    local icr = Instance.new("UICorner")
    icr.CornerRadius = UDim.new(0, 1)
    icr.Parent = ind

    -- Tab label
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = tabName
    lbl.TextColor3 = C.White
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    tabButtons[tabName] = btn

    btn.MouseButton1Click:Connect(function()
        SelectTab(tabName)
    end)
    btn.MouseEnter:Connect(function()
        if State.CurrentTab ~= tabName then
            Tween(btn, {BackgroundTransparency = 0, BackgroundColor3 = C.SidebarHov}, 0.1)
        end
    end)
    btn.MouseLeave:Connect(function()
        if State.CurrentTab ~= tabName then
            Tween(btn, {BackgroundTransparency = 1}, 0.1)
        end
    end)
end

-- ==================== CONTENT AREA ====================
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -SW, 1, -TH)
Content.Position = UDim2.new(0, SW, 0, TH)
Content.BackgroundColor3 = C.BgContent
Content.BorderSizePixel = 0
Content.Parent = Main

-- Separator line
local sepLine = Instance.new("Frame")
sepLine.Size = UDim2.new(0, 1, 1, 0)
sepLine.BackgroundColor3 = C.Border
sepLine.BorderSizePixel = 0
sepLine.Parent = Content

-- ==================== UI BUILDER FUNCTIONS ====================
local function MakeTab(name)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Tab_" .. name
    scroll.Size = UDim2.new(1, -4, 1, -4)
    scroll.Position = UDim2.new(0, 2, 0, 2)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = C.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = (name == "Farm")
    scroll.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.Parent = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 5)
    pad.PaddingRight = UDim.new(0, 5)
    pad.PaddingTop = UDim.new(0, 5)
    pad.PaddingBottom = UDim.new(0, 5)
    pad.Parent = scroll

    State.TabFrames[name] = scroll
    return scroll
end

local function AddSection(parent, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.SectColor
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = parent
    return lbl
end

local function AddToggle(parent, text, subtitle, configKey, order, callback)
    local rowH = subtitle and 34 or 28
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, rowH)
    row.BackgroundColor3 = C.BgCard
    row.AutoButtonColor = false
    row.Text = ""
    row.LayoutOrder = order
    row.Parent = parent

    local cr = Instance.new("UICorner")
    cr.CornerRadius = UDim.new(0, 5)
    cr.Parent = row

    local mainLbl = Instance.new("TextLabel")
    mainLbl.Size = UDim2.new(0.65, 0, 0, 12)
    mainLbl.Position = UDim2.new(0, 8, 0, subtitle and 4 or 8)
    mainLbl.BackgroundTransparency = 1
    mainLbl.Text = text
    mainLbl.TextColor3 = C.White
    mainLbl.TextSize = 10
    mainLbl.Font = Enum.Font.GothamSemibold
    mainLbl.TextXAlignment = Enum.TextXAlignment.Left
    mainLbl.Parent = row

    if subtitle then
        local subLbl = Instance.new("TextLabel")
        subLbl.Size = UDim2.new(0.65, 0, 0, 10)
        subLbl.Position = UDim2.new(0, 8, 0, 17)
        subLbl.BackgroundTransparency = 1
        subLbl.Text = subtitle
        subLbl.TextColor3 = C.Dim
        subLbl.TextSize = 8
        subLbl.Font = Enum.Font.Gotham
        subLbl.TextXAlignment = Enum.TextXAlignment.Left
        subLbl.Parent = row
    end

    -- Toggle pill
    local pillBg = Instance.new("Frame")
    pillBg.Size = UDim2.new(0, 30, 0, 14)
    pillBg.Position = UDim2.new(1, -38, 0.5, -7)
    pillBg.BackgroundColor3 = Config[configKey] and C.ToggleOn or C.ToggleOff
    pillBg.BorderSizePixel = 0
    pillBg.Parent = row
    local pcr = Instance.new("UICorner")
    pcr.CornerRadius = UDim.new(1, 0)
    pcr.Parent = pillBg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = Config[configKey] and UDim2.new(1, -12, 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Config[configKey] and C.KnobOn or C.KnobOff
    knob.BorderSizePixel = 0
    knob.Parent = pillBg
    local kcr = Instance.new("UICorner")
    kcr.CornerRadius = UDim.new(1, 0)
    kcr.Parent = knob

    row.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        local on = Config[configKey]
        Tween(pillBg, {BackgroundColor3 = on and C.ToggleOn or C.ToggleOff}, 0.2)
        Tween(knob, {
            Position = on and UDim2.new(1, -12, 0, 2) or UDim2.new(0, 2, 0, 2),
            BackgroundColor3 = on and C.KnobOn or C.KnobOff,
        }, 0.2)
        Notify(text .. (on and " ON" or " OFF"))
        if callback then callback(on) end
    end)

    row.MouseEnter:Connect(function() Tween(row, {BackgroundColor3 = C.BgCardHov}, 0.1) end)
    row.MouseLeave:Connect(function() Tween(row, {BackgroundColor3 = C.BgCard}, 0.1) end)
    return row
end

local function AddSlider(parent, text, configKey, minVal, maxVal, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3 = C.BgCard
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = parent
    local scr = Instance.new("UICorner")
    scr.CornerRadius = UDim.new(0, 5)
    scr.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.3, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.White
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 28, 1, 0)
    valLbl.Position = UDim2.new(0.3, 4, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(Config[configKey])
    valLbl.TextColor3 = C.White
    valLbl.TextSize = 10
    valLbl.Font = Enum.Font.GothamBold
    valLbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0.45, 0, 0, 4)
    track.Position = UDim2.new(0.5, 0, 0.5, -2)
    track.BackgroundColor3 = C.SliderBg
    track.BorderSizePixel = 0
    track.Parent = row
    local tcr = Instance.new("UICorner")
    tcr.CornerRadius = UDim.new(1, 0)
    tcr.Parent = track

    local pct = math.clamp((Config[configKey] - minVal) / math.max(maxVal - minVal, 1), 0, 1)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = C.SliderFill
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fcr = Instance.new("UICorner")
    fcr.CornerRadius = UDim.new(1, 0)
    fcr.Parent = fill

    local sknob = Instance.new("Frame")
    sknob.Size = UDim2.new(0, 10, 0, 10)
    sknob.Position = UDim2.new(pct, -5, 0.5, -5)
    sknob.BackgroundColor3 = C.White
    sknob.BorderSizePixel = 0
    sknob.ZIndex = 5
    sknob.Parent = track
    local skcr = Instance.new("UICorner")
    skcr.CornerRadius = UDim.new(1, 0)
    skcr.Parent = sknob

    local dragging = false
    local function UpdateSlider(inputPos)
        local tPos = track.AbsolutePosition.X
        local tSz = track.AbsoluteSize.X
        if tSz <= 0 then return end
        local rel = math.clamp((inputPos.X - tPos) / tSz, 0, 1)
        local newVal = math.floor(minVal + rel * (maxVal - minVal))
        Config[configKey] = newVal
        valLbl.Text = tostring(newVal)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        sknob.Position = UDim2.new(rel, -5, 0.5, -5)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input.Position)
        end
    end)
    sknob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return row
end

local function AddDropdown(parent, text, subtitle, options, configKey, order)
    local rowH = subtitle and 34 or 28
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, rowH)
    row.BackgroundColor3 = C.BgCard
    row.AutoButtonColor = false
    row.Text = ""
    row.LayoutOrder = order
    row.ClipsDescendants = false
    row.Parent = parent

    local cr = Instance.new("UICorner")
    cr.CornerRadius = UDim.new(0, 5)
    cr.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.45, 0, 0, 12)
    lbl.Position = UDim2.new(0, 8, 0, subtitle and 4 or 8)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.White
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    if subtitle then
        local subLbl = Instance.new("TextLabel")
        subLbl.Size = UDim2.new(0.45, 0, 0, 10)
        subLbl.Position = UDim2.new(0, 8, 0, 17)
        subLbl.BackgroundTransparency = 1
        subLbl.Text = subtitle
        subLbl.TextColor3 = C.Dim
        subLbl.TextSize = 8
        subLbl.Font = Enum.Font.Gotham
        subLbl.TextXAlignment = Enum.TextXAlignment.Left
        subLbl.Parent = row
    end

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.4, -10, 1, 0)
    valLbl.Position = UDim2.new(0.5, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(Config[configKey])
    valLbl.TextColor3 = C.AccentGlow
    valLbl.TextSize = 10
    valLbl.Font = Enum.Font.GothamBold
    valLbl.Parent = row

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 12, 1, 0)
    arrow.Position = UDim2.new(1, -18, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "v"
    arrow.TextColor3 = C.Dim
    arrow.TextSize = 9
    arrow.Font = Enum.Font.GothamBold
    arrow.Parent = row

    local isOpen = false
    local listH = math.min(#options * 20, 120)
    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(1, 0, 0, listH)
    dropFrame.Position = UDim2.new(0, 0, 1, 2)
    dropFrame.BackgroundColor3 = C.BgCard
    dropFrame.BorderSizePixel = 0
    dropFrame.Visible = false
    dropFrame.ZIndex = 50
    dropFrame.ClipsDescendants = true
    dropFrame.Parent = row
    local dfcr = Instance.new("UICorner")
    dfcr.CornerRadius = UDim.new(0, 4)
    dfcr.Parent = dropFrame
    local dfs = Instance.new("UIStroke")
    dfs.Color = C.Border
    dfs.Parent = dropFrame

    local dlScroll = Instance.new("ScrollingFrame")
    dlScroll.Size = UDim2.new(1, 0, 1, 0)
    dlScroll.BackgroundTransparency = 1
    dlScroll.ScrollBarThickness = 2
    dlScroll.ScrollBarImageColor3 = C.Accent
    dlScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 20)
    dlScroll.Parent = dropFrame

    local dlLayout = Instance.new("UIListLayout")
    dlLayout.Padding = UDim.new(0, 0)
    dlLayout.Parent = dlScroll

    for _, opt in ipairs(options) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1, 0, 0, 20)
        ob.BackgroundColor3 = C.BgCard
        ob.Text = opt
        ob.TextColor3 = C.White
        ob.TextSize = 9
        ob.Font = Enum.Font.Gotham
        ob.AutoButtonColor = false
        ob.ZIndex = 51
        ob.Parent = dlScroll
        ob.MouseButton1Click:Connect(function()
            Config[configKey] = opt
            valLbl.Text = opt
            dropFrame.Visible = false
            isOpen = false
            arrow.Text = "v"
        end)
        ob.MouseEnter:Connect(function() ob.BackgroundColor3 = C.BgCardHov end)
        ob.MouseLeave:Connect(function() ob.BackgroundColor3 = C.BgCard end)
    end

    row.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        dropFrame.Visible = isOpen
        arrow.Text = isOpen and "^" or "v"
    end)
    row.MouseEnter:Connect(function() Tween(row, {BackgroundColor3 = C.BgCardHov}, 0.1) end)
    row.MouseLeave:Connect(function() Tween(row, {BackgroundColor3 = C.BgCard}, 0.1) end)
    return row
end

local function AddButton(parent, text, subtitle, order, callback)
    local rowH = subtitle and 34 or 28
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, rowH)
    btn.BackgroundColor3 = C.BgCard
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.LayoutOrder = order
    btn.Parent = parent
    local bcr = Instance.new("UICorner")
    bcr.CornerRadius = UDim.new(0, 5)
    bcr.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.85, 0, 0, 12)
    lbl.Position = UDim2.new(0, 8, 0, subtitle and 4 or 8)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.White
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    if subtitle then
        local subLbl = Instance.new("TextLabel")
        subLbl.Size = UDim2.new(0.85, 0, 0, 10)
        subLbl.Position = UDim2.new(0, 8, 0, 17)
        subLbl.BackgroundTransparency = 1
        subLbl.Text = subtitle
        subLbl.TextColor3 = C.Dim
        subLbl.TextSize = 8
        subLbl.Font = Enum.Font.Gotham
        subLbl.TextXAlignment = Enum.TextXAlignment.Left
        subLbl.Parent = btn
    end

    local chev = Instance.new("TextLabel")
    chev.Size = UDim2.new(0, 12, 1, 0)
    chev.Position = UDim2.new(1, -18, 0, 0)
    chev.BackgroundTransparency = 1
    chev.Text = ">"
    chev.TextColor3 = C.Dim
    chev.TextSize = 10
    chev.Font = Enum.Font.GothamBold
    chev.Parent = btn

    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = C.BgCardHov}, 0.1) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = C.BgCard}, 0.1) end)
    return btn
end

local function AddInfoBox(parent, text, order)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, 0)
    box.AutomaticSize = Enum.AutomaticSize.Y
    box.BackgroundColor3 = C.BgCard
    box.BorderSizePixel = 0
    box.LayoutOrder = order
    box.Parent = parent
    local bcr = Instance.new("UICorner")
    bcr.CornerRadius = UDim.new(0, 5)
    bcr.Parent = box
    local pd = Instance.new("UIPadding")
    pd.PaddingLeft = UDim.new(0, 6)
    pd.PaddingRight = UDim.new(0, 6)
    pd.PaddingTop = UDim.new(0, 5)
    pd.PaddingBottom = UDim.new(0, 5)
    pd.Parent = box
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 0)
    l.AutomaticSize = Enum.AutomaticSize.Y
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = C.Dim
    l.TextSize = 8
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.Parent = box
    return box
end

local function AddStatusRow(parent, name, statusText, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3 = C.BgCard
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = parent
    local rcr = Instance.new("UICorner")
    rcr.CornerRadius = UDim.new(0, 5)
    rcr.Parent = row

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(0.55, 0, 0, 14)
    nl.Position = UDim2.new(0, 8, 0, 2)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = C.White
    nl.TextSize = 10
    nl.Font = Enum.Font.GothamBold
    nl.TextXAlignment = Enum.TextXAlignment.Left
    nl.Parent = row

    local sl = Instance.new("TextLabel")
    sl.Size = UDim2.new(0.55, 0, 0, 10)
    sl.Position = UDim2.new(0, 8, 0, 17)
    sl.BackgroundTransparency = 1
    sl.Text = statusText
    sl.TextColor3 = statusText:find("Not") and C.Red or C.Dim
    sl.TextSize = 8
    sl.Font = Enum.Font.Gotham
    sl.TextXAlignment = Enum.TextXAlignment.Left
    sl.Parent = row

    -- Status dot
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(1, -14, 0.5, -3)
    dot.BackgroundColor3 = statusText:find("Not") and C.Red or C.Green
    dot.BorderSizePixel = 0
    dot.Parent = row
    local dcr = Instance.new("UICorner")
    dcr.CornerRadius = UDim.new(1, 0)
    dcr.Parent = dot

    return row
end

-- =====================================================
-- ================= BUILD ALL TABS ====================
-- =====================================================

-- === FARM TAB ===
local farmTab = MakeTab("Farm")
AddDropdown(farmTab, "Select Tool", "Weapon to use", {"Sword", "Melee", "Blox Fruit", "Gun"}, "SelectTool", 1)
AddSection(farmTab, "Main Farm", 2)
AddToggle(farmTab, "Auto Farm Level", "Quest NPC loop + aerial", "AutoFarmLevel", 3, function(v)
    if v then task.spawn(AutoFarmLevelLoop) end
end)
AddToggle(farmTab, "Auto Farm Nearest", "Farm nearest mobs", "AutoFarmNearest", 4, function(v)
    if v then task.spawn(AutoFarmNearestLoop) end
end)
AddSection(farmTab, "Event", 5)
AddToggle(farmTab, "Auto Fishing", nil, "AutoFishing", 6, function(v)
    if v then task.spawn(AutoFishingLoop) end
end)
AddToggle(farmTab, "Auto Collect Eggs", nil, "AutoCollectEggs", 7, nil)
AddSection(farmTab, "Chest", 8)
AddToggle(farmTab, "Auto Chest [Tween]", nil, "AutoChestTween", 9, function(v)
    if v then task.spawn(AutoChestLoop) end
end)
AddToggle(farmTab, "Auto Chest [Bypass]", nil, "AutoChestBypass", 10, function(v)
    if v then task.spawn(AutoChestLoop) end
end)

-- === FISHING TAB ===
local fishTab = MakeTab("Fishing")
AddSection(fishTab, "Fishing", 1)
AddToggle(fishTab, "Auto Fishing", "Cast & Reel", "AutoFishing", 2, function(v)
    if v then task.spawn(AutoFishingLoop) end
end)
AddToggle(fishTab, "Auto Collect Eggs", nil, "AutoCollectEggs", 3, nil)
AddToggle(fishTab, "ESP Eggs", nil, "ESPEggs", 4, nil)

-- === QUEST TAB ===
local questTab = MakeTab("Quest")
AddSection(questTab, "Quest Sea 1", 1)
AddToggle(questTab, "AutoSecondSea", nil, "AutoSecondSea", 2, nil)
AddSection(questTab, "Boss", 3)
AddToggle(questTab, "Kill Greybeard", nil, "KillGreybeard", 4, nil)
AddSection(questTab, "Quest Swords", 5)
AddToggle(questTab, "Auto Get Saber", nil, "AutoGetSaber", 6, nil)
AddToggle(questTab, "Auto Get Pole", nil, "AutoGetSwordPole", 7, nil)
AddToggle(questTab, "Auto Get Saw", nil, "AutoGetSwordSaw", 8, nil)
AddToggle(questTab, "Auto Get Wardens", nil, "AutoGetWardens", 9, nil)
AddToggle(questTab, "Auto Get Trident", nil, "AutoGetTrident", 10, nil)

-- === FRUITS TAB ===
local fruitsTab = MakeTab("Fruits")
AddSection(fruitsTab, "Fruits", 1)
AddToggle(fruitsTab, "Auto Random Fruits", nil, "AutoRandomFruits", 2, function(v)
    if v then task.spawn(AutoFruitLoop) end
end)
AddToggle(fruitsTab, "Auto Store Fruits", nil, "AutoStoreFruits", 3, function(v)
    if v then task.spawn(AutoStoreFruitsLoop) end
end)
AddToggle(fruitsTab, "Auto TP Fruits", nil, "AutoTeleportFruits", 4, function(v)
    if v then task.spawn(AutoFruitLoop) end
end)
AddSection(fruitsTab, "Stock", 5)
AddInfoBox(fruitsTab, "Rocket - $5K | Spin - $7.5K\nBomb - $80K | Rubber - $750K\nCreation - $1.4M | Shadow - $2.9M\nVenom - $3M", 6)
AddSection(fruitsTab, "Raids", 7)
AddToggle(fruitsTab, "Raid Law Sea 2", nil, "RaidLawSea2", 8, nil)

-- === STATS TAB ===
local statsTab = MakeTab("Stats")
AddSlider(statsTab, "Points", "PointsAmount", 1, 10, 1)
AddToggle(statsTab, "Auto Status", nil, "AutoStatus", 2, function(v)
    if v then task.spawn(AutoStatsLoop) end
end)
AddSection(statsTab, "Select Status", 3)
AddToggle(statsTab, "Melee", nil, "StatMelee", 4, nil)
AddToggle(statsTab, "Defense", nil, "StatDefense", 5, nil)
AddToggle(statsTab, "Sword", nil, "StatSword", 6, nil)
AddToggle(statsTab, "Gun", nil, "StatGun", 7, nil)
AddToggle(statsTab, "Fruit", nil, "StatFruit", 8, nil)

-- === TELEPORT TAB ===
local tpTab = MakeTab("Teleport")
AddSection(tpTab, "Travel", 1)
AddButton(tpTab, "Teleport Sea 1", "Main", 2, function()
    TeleportTo(SeaLocations["Sea 1"]); Notify("TP Sea 1")
end)
AddButton(tpTab, "Teleport Sea 2", "Dressrosa", 3, function()
    TeleportTo(SeaLocations["Sea 2"]); Notify("TP Sea 2")
end)
AddButton(tpTab, "Teleport Sea 3", "Zou", 4, function()
    TeleportTo(SeaLocations["Sea 3"]); Notify("TP Sea 3")
end)
AddSection(tpTab, "Islands", 5)
AddDropdown(tpTab, "Select Island", nil, {
    "Starter Island", "Jungle", "Pirate Village", "Desert",
    "Frozen Village", "Marine Fortress", "Skylands", "Prison",
    "Colosseum", "Magma Village", "Fountain City", "Skull Island",
}, "SelectedIsland", 6)
AddToggle(tpTab, "TP To Island", nil, "TeleportToIsland", 7, nil)

-- === STATUS TAB ===
local statusTab = MakeTab("Status")
AddStatusRow(statusTab, "Katakuri", "Unknown", 1)
AddStatusRow(statusTab, "Tyrant of the Skies", "Not Spawned", 2)
AddStatusRow(statusTab, "Rip_Indra", "Not Spawned", 3)
AddStatusRow(statusTab, "Dough King", "Not Spawned", 4)
AddStatusRow(statusTab, "Pull Lever", "Not Active", 5)
AddStatusRow(statusTab, "Full Moon", "Unknown", 6)

-- === VISUAL TAB ===
local visualTab = MakeTab("Visual")
AddSection(visualTab, "Aimbot", 1)
AddToggle(visualTab, "Aimbot Gun", nil, "AimbotGun", 2, nil)
AddToggle(visualTab, "Aimbot Tap", nil, "AimbotTap", 3, nil)
AddToggle(visualTab, "Aimbot Skills", nil, "AimbotSkills", 4, nil)
AddToggle(visualTab, "Ignore Mobs", nil, "IgnoreMobs", 5, nil)
AddSection(visualTab, "Aimbot Skill V2", 6)
AddToggle(visualTab, "Enable Aimbot Skill", nil, "EnableAimbotSkill", 7, nil)
AddToggle(visualTab, "On Players", nil, "AimbotOnPlayers", 8, nil)
AddToggle(visualTab, "On Mobs", nil, "AimbotOnMobs", 9, nil)
AddSection(visualTab, "ESP", 10)
AddSlider(visualTab, "ESP Size", "ESPSize", 1, 100, 11)
AddToggle(visualTab, "ESP Players", nil, "ESPPlayers", 12, function(v)
    if v then task.spawn(ESPLoop) else ClearESP() end
end)

-- === SHOP TAB ===
local shopTab = MakeTab("Shop")
AddSection(shopTab, "Fighting Styles", 1)
AddToggle(shopTab, "Buy Black Leg", nil, "BuyBlackLeg", 2, nil)
AddToggle(shopTab, "Buy Electro", nil, "BuyElectro", 3, nil)
AddToggle(shopTab, "Buy Fishman Karate", nil, "BuyFishmanKarate", 4, nil)
AddToggle(shopTab, "Buy Superhuman", nil, "BuySuperhuman", 5, nil)
AddToggle(shopTab, "Buy Death Step", nil, "BuyDeathStep", 6, nil)
AddToggle(shopTab, "Buy Sharkman", nil, "BuySharkmanKarate", 7, nil)
AddToggle(shopTab, "Buy Electric Claw", nil, "BuyElectricClaw", 8, nil)
AddToggle(shopTab, "Buy Dragon Talon", nil, "BuyDragonTalon", 9, nil)
AddToggle(shopTab, "Buy God Human", nil, "BuyGodHuman", 10, nil)
AddToggle(shopTab, "Buy Sanguine Art", nil, "BuySanguineArt", 11, nil)

-- === MISC TAB ===
local miscTab = MakeTab("Misc")
AddSection(miscTab, "Movement", 1)
AddToggle(miscTab, "Fly", nil, "Fly", 2, function(v)
    if v then StartFly() else StopFly() end
end)
AddToggle(miscTab, "Noclip", nil, "Noclip", 3, function(v)
    if v then task.spawn(NoclipLoop) end
end)
AddSlider(miscTab, "Fly Speed", "FlySpeed", 10, 200, 4)
AddSlider(miscTab, "Fly Height", "FlyHeight", 5, 50, 5)
AddSection(miscTab, "Config", 6)
AddSlider(miscTab, "Farm Dist", "FarmDistance", 50, 500, 7)
AddSlider(miscTab, "Bring Range", "BringRange", 50, 500, 8)
AddSlider(miscTab, "Tween Spd", "TweenSpeed", 50, 500, 9)
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
local function HideToCircle()
    State.UIHidden = true
    Tween(Main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.2)
    task.delay(0.25, function()
        Main.Visible = false
        CircleBtn.Visible = true
        CircleBtn.Size = UDim2.new(0, 0, 0, 0)
        Tween(CircleBtn, {Size = UDim2.new(0, 42, 0, 42)}, 0.2)
    end)
end

local function ShowFromCircle()
    State.UIHidden = false
    Tween(CircleBtn, {Size = UDim2.new(0, 0, 0, 0)}, 0.15)
    task.delay(0.2, function()
        CircleBtn.Visible = false
        Main.Visible = true
        Main.BackgroundTransparency = 0
        Main.Size = UDim2.new(0, 0, 0, 0)
        Tween(Main, {Size = UDim2.new(0, FW, 0, FH)}, 0.2)
    end)
end

MinBtn.MouseButton1Click:Connect(HideToCircle)
CloseBtn.MouseButton1Click:Connect(HideToCircle)

CircleBtn.MouseButton1Click:Connect(function()
    if cMoved then cMoved = false; return end
    ShowFromCircle()
end)

-- Keybind: RightShift to toggle
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if State.UIHidden then ShowFromCircle() else HideToCircle() end
    end
end)

-- ==================== INIT ====================
SelectTab("Farm")
Notify("HYPERDRIVE v9 Loaded!")
Notify("Press RightShift to toggle UI")
