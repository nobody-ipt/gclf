-- ============================================================
-- BLOX FRUITS HYPERDRIVE v9.1 - NEO EDITION
-- Real Game Logic | CommF_ Remotes | Quest NPC Loop
-- Aerial Farming | Mob Gathering | Neo Light Blue Theme
-- ============================================================

-- ==================== SERVICES ====================
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local StarterGui        = game:GetService("StarterGui")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local VirtualUser       = game:GetService("VirtualUser")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Wait for game to load
if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until LP and LP.Character

-- Cache game references
local Enemies = nil
pcall(function() Enemies = Workspace:WaitForChild("Enemies", 10) end)

local Remotes = nil
pcall(function() Remotes = ReplicatedStorage:WaitForChild("Remotes", 10) end)

local CommF_ = nil
pcall(function()
    if Remotes then CommF_ = Remotes:FindFirstChild("CommF_") end
end)

-- ==================== QUEST TABLE (REAL BLOX FRUITS) ====================
-- Format: { MinLevel, QuestId, QuestIndex, MobName, NpcPosition }
-- QuestId and QuestIndex are used with CommF_:InvokeServer("StartQuest", QuestId, QuestIndex)

local QuestTable = {
    -- === SEA 1 ===
    {1,    "BanditQuest1",      1, "Bandit",               CFrame.new(1060, 16, 1547)},
    {5,    "BanditQuest1",      1, "Bandit",               CFrame.new(1060, 16, 1547)},
    {10,   "JungleQuest",       1, "Monkey",               CFrame.new(-1604, 37, 154)},
    {15,   "JungleQuest",       2, "Gorilla",              CFrame.new(-1604, 37, 154)},
    {30,   "BuggyQuest1",       1, "Pirate",               CFrame.new(-1139, 5, 3830)},
    {40,   "BuggyQuest1",       2, "Brute",                CFrame.new(-1139, 5, 3830)},
    {60,   "DesertQuest",       1, "Desert Bandit",        CFrame.new(899, 6, 4389)},
    {70,   "DesertQuest",       2, "Desert Officer",       CFrame.new(899, 6, 4389)},
    {90,   "SnowQuest",         1, "Snow Bandit",          CFrame.new(1347, 88, -1298)},
    {100,  "SnowQuest",         2, "Snowman",              CFrame.new(1347, 88, -1298)},
    {120,  "MarineQuest2",      1, "Chief Petty Officer",  CFrame.new(-4846, 20, 4324)},
    {150,  "SkyQuest",          1, "Sky Bandit",           CFrame.new(-4846, 844, 4324)},
    {175,  "SkyQuest",          2, "Dark Master",          CFrame.new(-4846, 844, 4324)},
    {225,  "ColosseumQuest",    1, "Toga Warrior",         CFrame.new(-1573, 7, -2891)},
    {275,  "ColosseumQuest",    2, "Gladiator",            CFrame.new(-1573, 7, -2891)},
    {300,  "MagmaQuest",        1, "Military Soldier",     CFrame.new(-5312, 12, 8515)},
    {330,  "MagmaQuest",        2, "Military Spy",         CFrame.new(-5312, 12, 8515)},
    {375,  "FishmanQuest",      1, "Fishman Warrior",      CFrame.new(61126, 17, 1568)},
    {400,  "FishmanQuest",      2, "Fishman Commando",     CFrame.new(61126, 17, 1568)},
    {450,  "SkyExp1Quest",      1, "God's Guard",          CFrame.new(-4846, 844, 4324)},
    {475,  "SkyExp1Quest",      2, "Shanda",               CFrame.new(-4846, 844, 4324)},
    {525,  "SkyExp2Quest",      1, "Royal Squad",          CFrame.new(-7894, 5549, -380)},
    {550,  "SkyExp2Quest",      2, "Royal Soldier",        CFrame.new(-7894, 5549, -380)},
    {625,  "FountainQuest",     1, "Galley Pirate",        CFrame.new(5255, 24, 4058)},
    {675,  "FountainQuest",     2, "Galley Captain",       CFrame.new(5255, 24, 4058)},

    -- === SEA 2 ===
    {700,  "AreaQuest2",        1, "Raider",               CFrame.new(-429, 73, 1836)},
    {725,  "AreaQuest2",        2, "Mercenary",            CFrame.new(-429, 73, 1836)},
    {775,  "DressrosaQuest",    1, "Swan Pirate",          CFrame.new(986, 120, 1349)},
    {800,  "DressrosaQuest",    2, "Factory Staff",        CFrame.new(986, 120, 1349)},
    {850,  "GreenZoneQuest",    1, "Marine Commodore",     CFrame.new(-2142, 73, -3162)},
    {900,  "GreenZoneQuest",    2, "Marine Rear Admiral",  CFrame.new(-2142, 73, -3162)},
    {950,  "IceSideQuest",      1, "Snow Trooper",         CFrame.new(5669, 32, -6485)},
    {1000, "IceSideQuest",      2, "Winter Warrior",       CFrame.new(5669, 32, -6485)},
    {1050, "ForgottenQuest",    1, "Lab Subordinate",      CFrame.new(-3038, 295, -3791)},
    {1100, "ForgottenQuest",    2, "Horned Warrior",       CFrame.new(-3038, 295, -3791)},
    {1125, "FireSideQuest",     1, "Magma Ninja",          CFrame.new(-5439, 17, 8264)},
    {1175, "FireSideQuest",     2, "Lava Pirate",          CFrame.new(-5439, 17, 8264)},
    {1200, "ShipQuest2",        1, "Ship Officer",         CFrame.new(1038, 26, 32907)},
    {1250, "ShipQuest2",        2, "Ship Engineer",        CFrame.new(1038, 26, 32907)},

    -- === SEA 3 ===
    {1325, "PortTownQuest",     1, "Marine Lieutenant",    CFrame.new(-290, 45, 5474)},
    {1350, "PortTownQuest",     2, "Marine Captain",       CFrame.new(-290, 45, 5474)},
    {1375, "HauntedQuest",      1, "Zombie",               CFrame.new(-5429, 49, -784)},
    {1400, "HauntedQuest",      2, "Vampire",              CFrame.new(-5429, 49, -784)},
    {1425, "MansionQuest",      1, "Reborn Skeleton",      CFrame.new(-5087, 114, -4828)},
    {1450, "MansionQuest",      2, "Living Zombie",        CFrame.new(-5087, 114, -4828)},
    {1475, "TikiQuest",         1, "Demonic Soul",         CFrame.new(2842, 437, -6993)},
    {1500, "TikiQuest",         2, "Posessed Mummy",       CFrame.new(2842, 437, -6993)},
    {1525, "VolcanoQuest",      1, "Lava Pirate",          CFrame.new(-5348, 293, -5077)},
    {1550, "VolcanoQuest",      2, "Magma Ninja",          CFrame.new(-5348, 293, -5077)},
    {1575, "CastleQuest",       1, "Pirate Millionaire",   CFrame.new(-5234, 100, -2835)},
    {1600, "CastleQuest",       2, "Dragon Crew Warrior",  CFrame.new(-5234, 100, -2835)},
    {1625, "CastleQuest",       2, "Dragon Crew Archer",   CFrame.new(-5234, 100, -2835)},
    {1650, "GraveyardQuest",    1, "Reborn Skeleton",      CFrame.new(-5107, 49, -5084)},
    {1700, "GraveyardQuest",    2, "Undead Pirate",        CFrame.new(-5107, 49, -5084)},
    {1750, "CursedQuest",       1, "Cursed Skeleton Captain", CFrame.new(-3038, 295, -3791)},
    {1800, "ForgottenQuest2",   1, "Forgotten Pirate",     CFrame.new(-3038, 295, -3791)},
    {1850, "LeafQuest",         1, "Forest Pirate",        CFrame.new(-2842, 437, -6993)},
    {1900, "LeafQuest",         2, "Mythological Pirate",  CFrame.new(-2842, 437, -6993)},
    {1950, "IceCreamQuest",     1, "Cake Guard",           CFrame.new(-817, 50, -10971)},
    {2000, "IceCreamQuest",     2, "Baking Staff",         CFrame.new(-817, 50, -10971)},
    {2050, "CakeQuest",         1, "Cookie Crafter",       CFrame.new(-817, 50, -10971)},
    {2100, "CakeQuest",         2, "Cake Guard",           CFrame.new(-817, 50, -10971)},
    {2200, "ChocolateQuest",    1, "Cocoa Warrior",        CFrame.new(-817, 50, -10971)},
    {2300, "ChocolateQuest",    2, "Chocolate Bar Battler", CFrame.new(-817, 50, -10971)},
}

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
    SkillZ = false, SkillX = false, SkillC = false,
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
            Title = "HYPERDRIVE v9.1", Text = text, Duration = 3
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

local function TweenMove(target, duration)
    local root = GetRoot()
    if not root then return end
    local tw = TweenService:Create(root, TweenInfo.new(duration or 1, Enum.EasingStyle.Linear), {CFrame = target})
    tw:Play()
    tw.Completed:Wait()
end

-- ==================== PLAYER LEVEL ====================
local function GetPlayerLevel()
    local level = 0
    pcall(function()
        -- Try reading from PlayerGui stats display
        for _, child in ipairs(LP.PlayerGui:GetDescendants()) do
            if child:IsA("TextLabel") then
                local txt = child.Text or ""
                local lv = txt:match("Lv%.%s*(%d+)") or txt:match("Level%s*(%d+)")
                if lv then level = tonumber(lv); break end
            end
        end
    end)
    -- Fallback: try Data folder
    if level == 0 then
        pcall(function()
            local data = LP:FindFirstChild("Data")
            if data then
                local lv = data:FindFirstChild("Level")
                if lv then level = lv.Value end
            end
        end)
    end
    -- Fallback: try leaderstats
    if level == 0 then
        pcall(function()
            local ls = LP:FindFirstChild("leaderstats")
            if ls then
                local lv = ls:FindFirstChild("Level") or ls:FindFirstChild("Lv")
                if lv then level = lv.Value end
            end
        end)
    end
    return level
end

-- ==================== QUEST SYSTEM (REAL BLOX FRUITS) ====================

-- Get the best quest for current level
local function GetQuestForLevel()
    local playerLevel = GetPlayerLevel()
    local best = nil
    for _, q in ipairs(QuestTable) do
        if playerLevel >= q[1] then
            best = q
        else
            break
        end
    end
    return best
end

-- Start a quest using the real CommF_ remote
local function StartQuest(questId, questIndex)
    if not CommF_ then
        pcall(function()
            if Remotes then CommF_ = Remotes:FindFirstChild("CommF_") end
        end)
    end
    if not CommF_ then return false end
    local ok, result = pcall(function()
        return CommF_:InvokeServer("StartQuest", questId, questIndex)
    end)
    return ok
end

-- Check if player has an active quest
local function HasActiveQuest()
    local has = false
    pcall(function()
        -- Check via PlayerGui quest tracker
        local pg = LP:FindFirstChild("PlayerGui")
        if pg then
            local main = pg:FindFirstChild("Main")
            if main then
                local quest = main:FindFirstChild("Quest")
                if quest and quest.Visible then has = true end
            end
        end
    end)
    -- Fallback: scan for any visible quest frame
    if not has then
        pcall(function()
            for _, child in ipairs(LP.PlayerGui:GetDescendants()) do
                if child.Name == "QuestFrame" or child.Name == "Quest" or child.Name == "QuestGui" then
                    if child:IsA("Frame") and child.Visible then
                        has = true; break
                    end
                end
            end
        end)
    end
    return has
end

-- Get quest progress text
local function GetQuestProgress()
    local progress = nil
    pcall(function()
        for _, child in ipairs(LP.PlayerGui:GetDescendants()) do
            if child:IsA("TextLabel") then
                local txt = child.Text or ""
                -- Look for patterns like "Defeat 5 Bandit" or "3/5"
                if txt:match("Defeat%s+%d+") or txt:match("%d+/%d+") then
                    progress = txt
                    break
                end
            end
        end
    end)
    return progress
end

-- Check if quest is complete
local function IsQuestComplete()
    local done = false
    pcall(function()
        local progress = GetQuestProgress()
        if progress then
            -- Check for "0 remaining" pattern
            if progress:match("0%s*remaining") then done = true end
            -- Check for matching numbers like "5/5"
            local current, total = progress:match("(%d+)/(%d+)")
            if current and total and tonumber(current) >= tonumber(total) then done = true end
        end
        -- Also check for "Complete" text
        for _, child in ipairs(LP.PlayerGui:GetDescendants()) do
            if child:IsA("TextLabel") then
                local t = (child.Text or ""):lower()
                if t:find("complete") or t:find("finished") then done = true; break end
            end
        end
    end)
    return done
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

-- ==================== COMBAT (REAL BLOX FRUITS) ====================
local function EquipWeapon()
    pcall(function()
        local char = GetCharacter()
        if not char then return end
        -- Check if weapon already equipped
        if char:FindFirstChildOfClass("Tool") then return end
        -- Equip from backpack
        local backpack = LP:FindFirstChild("Backpack")
        if not backpack then return end
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                local sel = Config.SelectTool:lower()
                if sel == "sword" and (name:find("sword") or name:find("blade") or name:find("katana") or name:find("cutlass") or name:find("saber")) then
                    char.Humanoid:EquipTool(tool); return
                elseif sel == "melee" and (name:find("combat") or name:find("fist") or name:find("karate") or name:find("leg") or name:find("human") or name:find("step") or name:find("claw") or name:find("talon")) then
                    char.Humanoid:EquipTool(tool); return
                elseif sel == "blox fruit" and (name:find("fruit") or name:find("blox")) then
                    char.Humanoid:EquipTool(tool); return
                elseif sel == "gun" and (name:find("gun") or name:find("pistol") or name:find("rifle") or name:find("musket") or name:find("cannon")) then
                    char.Humanoid:EquipTool(tool); return
                end
            end
        end
        -- If no matching type found, equip first available tool
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                char.Humanoid:EquipTool(tool); return
            end
        end
    end)
end

local function Attack(target)
    if not target or not IsAlive() then return end

    EquipWeapon()

    -- Method 1: Use VirtualUser to click (simulates left click attack)
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new())
    end)

    -- Method 2: Activate the equipped tool
    pcall(function()
        local char = GetCharacter()
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
                -- Fire skills if enabled
                if tool:FindFirstChild("RemoteFunction") then
                    if Config.SkillZ then
                        pcall(function()
                            local pos = CFrame.new(GetRoot().CFrame.p, target.HumanoidRootPart.Position)
                            tool.RemoteFunction:InvokeServer("Z", pos)
                        end)
                    end
                    if Config.SkillX then
                        pcall(function() tool.RemoteFunction:InvokeServer("X") end)
                    end
                    if Config.SkillC then
                        pcall(function() tool.RemoteFunction:InvokeServer("C") end)
                    end
                end
            end
        end
    end)

    -- Method 3: Try combat remote
    pcall(function()
        if CommF_ then
            CommF_:InvokeServer("Combat")
        end
    end)
end

-- ==================== TARGETING ====================
local function GetMobsInRange(range, filterFn)
    local root = GetRoot()
    if not root then return {} end
    local mobs = {}

    -- Search in Workspace.Enemies
    if Enemies then
        pcall(function()
            for _, mob in ipairs(Enemies:GetChildren()) do
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
    end

    -- Also search in ReplicatedStorage for quest mobs (some are stored there)
    pcall(function()
        for _, mob in ipairs(ReplicatedStorage:GetChildren()) do
            if mob:IsA("Model") and mob.Name ~= "BusoTemplate" then
                if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                    local d = (root.Position - mob.HumanoidRootPart.Position).Magnitude
                    if d <= range then
                        if not filterFn or filterFn(mob) then
                            table.insert(mobs, {Mob = mob, Distance = d})
                        end
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

-- ==================== AUTO FARM LEVEL (REAL QUEST LOOP) ====================
local function AutoFarmLevelLoop()
    -- Enable fly and noclip for aerial farming
    if not State.Flying then Config.Fly = true; StartFly() end
    if not Config.Noclip then Config.Noclip = true; task.spawn(NoclipLoop) end

    while Config.AutoFarmLevel do
        if not IsAlive() then task.wait(2); continue end

        -- Step 1: Get quest for current level
        local questInfo = GetQuestForLevel()
        if not questInfo then
            Notify("No quest for your level!")
            task.wait(5); continue
        end

        local minLv, questId, questIdx, mobName, npcPos = questInfo[1], questInfo[2], questInfo[3], questInfo[4], questInfo[5]

        -- Step 2: Accept quest if not active
        if not HasActiveQuest() then
            Notify("Getting quest: " .. mobName)

            -- Teleport to quest NPC
            TeleportTo(npcPos)
            task.wait(1)

            -- Accept quest via CommF_ remote
            local accepted = StartQuest(questId, questIdx)
            if accepted then
                Notify("Quest accepted: " .. mobName)
            else
                Notify("Failed to accept quest, retrying...")
            end
            task.wait(1)
        end

        -- Step 3: Farm the quest mobs aerially
        local farmStart = tick()
        while Config.AutoFarmLevel and not IsQuestComplete() do
            if not IsAlive() then task.wait(2); continue end
            if tick() - farmStart > 300 then
                Notify("Quest timeout, getting new quest...")
                break
            end

            -- Find quest target mob
            local target = GetNearestMob(Config.FarmDistance, function(m)
                return m.Name == mobName or m.Name:find(mobName)
            end)

            -- If no matching mob, try any nearby mob
            if not target then
                target = GetNearestMob(Config.FarmDistance)
            end

            if target and target:FindFirstChild("HumanoidRootPart") then
                local mobPos = target.HumanoidRootPart.Position

                -- Position above mob for aerial farming (avoid melee damage)
                TeleportTo(CFrame.new(mobPos.X, mobPos.Y + Config.FlyHeight, mobPos.Z))
                Attack(target)

                -- Mob gathering: if enough mobs nearby, fly in circles to group them
                if Config.BringMobs then
                    local nearby = GetMobsInRange(Config.BringRange)
                    if #nearby >= 3 then
                        GatherMobs(mobPos, 2)
                        -- Burst attack gathered mobs
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
                -- No mob found, teleport near NPC area
                TeleportTo(npcPos * CFrame.new(0, Config.FlyHeight, 0))
                task.wait(1)
            end
            task.wait(0.08)
        end

        -- Step 4: Quest complete - loop back to step 1
        if IsQuestComplete() then
            Notify("Quest done! " .. mobName)
        end
        task.wait(0.5)
    end

    Config.Fly = false; StopFly(); Config.Noclip = false
end

-- ==================== AUTO FARM NEAREST ====================
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

-- ==================== AUTO STATS (REAL CommF_) ====================
local function AutoStatsLoop()
    while Config.AutoStatus do
        pcall(function()
            if not CommF_ then return end
            local pts = Config.PointsAmount
            if Config.StatMelee then for i = 1, pts do CommF_:InvokeServer("AddPoint", "Melee", 1) end end
            if Config.StatDefense then for i = 1, pts do CommF_:InvokeServer("AddPoint", "Defense", 1) end end
            if Config.StatSword then for i = 1, pts do CommF_:InvokeServer("AddPoint", "Sword", 1) end end
            if Config.StatGun then for i = 1, pts do CommF_:InvokeServer("AddPoint", "Gun", 1) end end
            if Config.StatFruit then for i = 1, pts do CommF_:InvokeServer("AddPoint", "Blox Fruit", 1) end end
        end)
        task.wait(0.5)
    end
end

-- ==================== AUTO HAKI (REAL CommF_) ====================
local function AutoHakiLoop()
    while Config.AutoHaki do
        pcall(function()
            if CommF_ then
                CommF_:InvokeServer("Buso")
            end
        end)
        task.wait(4)
    end
end

-- ==================== AUTO FRUIT (REAL) ====================
local function AutoFruitLoop()
    while Config.AutoRandomFruits or Config.AutoTeleportFruits do
        pcall(function()
            -- Method 1: Grab fruits from workspace (fruits spawn as models with Handle)
            for _, item in ipairs(Workspace:GetChildren()) do
                local name = item.Name or ""
                if name:find("Fruit") then
                    local handle = item:FindFirstChild("Handle")
                    if handle then
                        local root = GetRoot()
                        if root then
                            handle.CFrame = root.CFrame
                            task.wait(0.3)
                        end
                    end
                end
            end
            -- Method 2: Check for dropped tools on the ground
            for _, item in ipairs(Workspace:GetChildren()) do
                if item:IsA("Tool") and (item.Name:find("Fruit") or item.Name:find("fruit")) then
                    local handle = item:FindFirstChild("Handle")
                    if handle then
                        local root = GetRoot()
                        if root then
                            handle.CFrame = root.CFrame
                            task.wait(0.3)
                        end
                    end
                end
            end
        end)
        task.wait(2)
    end
end

-- ==================== AUTO STORE FRUITS (REAL CommF_) ====================
local function AutoStoreFruitsLoop()
    while Config.AutoStoreFruits do
        pcall(function()
            if CommF_ then
                CommF_:InvokeServer("StoreFruit")
            end
        end)
        task.wait(5)
    end
end

-- ==================== AUTO FISHING (REAL) ====================
local function AutoFishingLoop()
    while Config.AutoFishing do
        pcall(function()
            if CommF_ then
                -- Cast fishing line
                CommF_:InvokeServer("Fishing", "Cast")
                task.wait(3)
                -- Reel in
                CommF_:InvokeServer("Fishing", "Reel")
            end
        end)
        task.wait(5)
    end
end

-- ==================== AUTO CHEST (REAL) ====================
local function AutoChestLoop()
    while Config.AutoChestTween or Config.AutoChestBypass do
        pcall(function()
            -- Search for chests in Workspace and _WorldOrigin
            local chestContainers = {Workspace}
            pcall(function()
                local wo = Workspace:FindFirstChild("_WorldOrigin")
                if wo then
                    local loc = wo:FindFirstChild("Locations")
                    if loc then table.insert(chestContainers, loc) end
                end
            end)

            for _, container in ipairs(chestContainers) do
                for _, chest in ipairs(container:GetDescendants()) do
                    if (chest.Name:find("Chest") or chest.Name:find("chest") or chest.Name:find("Treasure")) and chest:IsA("Model") then
                        local part = chest:FindFirstChildOfClass("BasePart") or chest:FindFirstChild("Lid") or chest:FindFirstChild("Handle")
                        if part then
                            if Config.AutoChestBypass then
                                TeleportTo(part.CFrame)
                            else
                                local root = GetRoot()
                                if root then
                                    local dist = (root.Position - part.Position).Magnitude
                                    local tweenTime = math.clamp(dist / Config.TweenSpeed, 0.1, 10)
                                    local tw = TweenService:Create(root, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = part.CFrame})
                                    tw:Play()
                                    tw.Completed:Wait()
                                end
                            end
                            -- Touch chest to open it
                            pcall(function() firetouchinterest(GetRoot(), part, 0) end)
                            pcall(function() firetouchinterest(GetRoot(), part, 1) end)
                            task.wait(0.5)
                        end
                    end
                end
            end
        end)
        task.wait(3)
    end
end

-- ==================== ANTI-AFK ====================
task.spawn(function()
    while true do
        if Config.AntiAFK then
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
            end)
            -- Also disconnect idle connections
            pcall(function()
                for _, v in pairs(getconnections(LP.Idled)) do
                    v:Disable()
                end
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

-- ==================== ESP ====================
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

-- ==================== TELEPORT LOCATIONS ====================
local SeaLocations = {
    ["Sea 1"] = CFrame.new(-1126, 15, 4222),
    ["Sea 2"] = CFrame.new(37, 15, 5700),
    ["Sea 3"] = CFrame.new(-5100, 15, -2900),
}

-- Island locations (Sea 1)
local IslandLocations = {
    ["Starter Island"] = CFrame.new(1060, 16, 1547),
    ["Jungle"] = CFrame.new(-1604, 37, 154),
    ["Pirate Village"] = CFrame.new(-1139, 5, 3830),
    ["Desert"] = CFrame.new(899, 6, 4389),
    ["Frozen Village"] = CFrame.new(1347, 88, -1298),
    ["Marine Fortress"] = CFrame.new(-4846, 20, 4324),
    ["Skylands"] = CFrame.new(-4846, 844, 4324),
    ["Prison"] = CFrame.new(4872, 17, 734),
    ["Colosseum"] = CFrame.new(-1573, 7, -2891),
    ["Magma Village"] = CFrame.new(-5312, 12, 8515),
    ["Fountain City"] = CFrame.new(5255, 24, 4058),
    ["Skull Island"] = CFrame.new(-5234, 100, -2835),
}

-- ==================== BUY FIGHTING STYLES (REAL CommF_) ====================
local function BuyFightingStyle(styleName)
    pcall(function()
        if CommF_ then
            CommF_:InvokeServer("BuyFightingStyle", styleName)
        end
    end)
end

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
titleLbl.Text = "HYPERDRIVE v9.1 : Blox Fruits"
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

    btn.MouseButton1Click:Connect(function() SelectTab(tabName) end)
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
    local pcr2 = Instance.new("UICorner")
    pcr2.CornerRadius = UDim.new(1, 0)
    pcr2.Parent = pillBg

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
AddToggle(farmTab, "Auto Farm Level", "CommF_ quest loop + aerial", "AutoFarmLevel", 3, function(v)
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
AddToggle(fishTab, "Auto Fishing", "Cast & Reel via CommF_", "AutoFishing", 2, function(v)
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
AddToggle(fruitsTab, "Auto Random Fruits", "Grab from workspace", "AutoRandomFruits", 2, function(v)
    if v then task.spawn(AutoFruitLoop) end
end)
AddToggle(fruitsTab, "Auto Store Fruits", "CommF_ StoreFruit", "AutoStoreFruits", 3, function(v)
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
AddToggle(statsTab, "Auto Status", "CommF_ AddPoint", "AutoStatus", 2, function(v)
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
AddButton(tpTab, "TP To Island", "Go to selected island", 7, function()
    local loc = IslandLocations[Config.SelectedIsland]
    if loc then TeleportTo(loc); Notify("TP: " .. Config.SelectedIsland) end
end)

-- === STATUS TAB ===
local statusTab = MakeTab("Status")
AddStatusRow(statusTab, "Katakuri", "Unknown", 1)
AddStatusRow(statusTab, "Tyrant of the Skies", "Not Spawned", 2)
AddStatusRow(statusTab, "Rip_Indra", "Not Spawned", 3)
AddStatusRow(statusTab, "Dough King", "Not Spawned", 4)
AddStatusRow(statusTab, "Pull Lever", "Not Active", 5)
AddStatusRow(statusTab, "Full Moon", "Unknown", 6)
AddSection(statusTab, "Player Info", 7)
AddInfoBox(statusTab, "Level: " .. tostring(GetPlayerLevel()) .. " | Sea: Auto-detect", 8)

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
AddButton(shopTab, "Buy Black Leg", "$150K", 2, function() BuyFightingStyle("Black Leg"); Notify("Buying Black Leg") end)
AddButton(shopTab, "Buy Electro", "$500K", 3, function() BuyFightingStyle("Electro"); Notify("Buying Electro") end)
AddButton(shopTab, "Buy Fishman Karate", "$750K", 4, function() BuyFightingStyle("Fishman Karate"); Notify("Buying Fishman Karate") end)
AddButton(shopTab, "Buy Superhuman", "$3M", 5, function() BuyFightingStyle("Superhuman"); Notify("Buying Superhuman") end)
AddButton(shopTab, "Buy Death Step", "$5M", 6, function() BuyFightingStyle("Death Step"); Notify("Buying Death Step") end)
AddButton(shopTab, "Buy Sharkman", "$5M", 7, function() BuyFightingStyle("Sharkman Karate"); Notify("Buying Sharkman Karate") end)
AddButton(shopTab, "Buy Electric Claw", "$5M", 8, function() BuyFightingStyle("Electric Claw"); Notify("Buying Electric Claw") end)
AddButton(shopTab, "Buy Dragon Talon", "$5M", 9, function() BuyFightingStyle("Dragon Talon"); Notify("Buying Dragon Talon") end)
AddButton(shopTab, "Buy God Human", "$5M", 10, function() BuyFightingStyle("Godhuman"); Notify("Buying God Human") end)
AddButton(shopTab, "Buy Sanguine Art", "$5M", 11, function() BuyFightingStyle("Sanguine Art"); Notify("Buying Sanguine Art") end)

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
AddToggle(miscTab, "Auto Haki", "CommF_ Buso", "AutoHaki", 11, function(v)
    if v then task.spawn(AutoHakiLoop) end
end)
AddToggle(miscTab, "Auto Attack", nil, "AutoAttack", 12, nil)
AddToggle(miscTab, "Auto Shoot", nil, "AutoShoot", 13, nil)
AddToggle(miscTab, "Attack Mobs", nil, "AttackMobs", 14, nil)
AddSection(miscTab, "Skills", 15)
AddToggle(miscTab, "Skill Z", "Use Z skill in combat", "SkillZ", 16, nil)
AddToggle(miscTab, "Skill X", "Use X skill in combat", "SkillX", 17, nil)
AddToggle(miscTab, "Skill C", "Use C skill in combat", "SkillC", 18, nil)
AddSection(miscTab, "Other", 19)
AddToggle(miscTab, "Anti-AFK", nil, "AntiAFK", 20, nil)
AddToggle(miscTab, "Infinite Jump", nil, "InfiniteJump", 21, nil)
AddToggle(miscTab, "Fast Attack", nil, "FastAttack", 22, nil)
AddToggle(miscTab, "God Mode", nil, "GodMode", 23, nil)
AddToggle(miscTab, "Auto Rejoin", nil, "AutoRejoin", 24, nil)

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
Notify("HYPERDRIVE v9.1 Loaded!")
Notify("Real CommF_ quest logic active")
Notify("Press RightShift to toggle UI")
