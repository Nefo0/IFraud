local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.min.lua"))() or INSui

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local player     = Players.LocalPlayer

local win = Lib:CreateWindow({
    title       = "Identity Fraud",
    subtitle    = "ESP & Teleport",
    size        = Vector2.new(700, 540),
    accentA     = Color3.fromRGB(122, 134, 255),
    accentB     = Color3.fromRGB(189, 130, 255),
    menuKey     = "p",
    startOpen   = true,
    smartFps    = true,
})

win:AddSettingsTab("cog")

local maze1Locs = {
    { label = "Mirror",      pos = Vector3.new(-366.4, 3.4, -171.1) },
    { label = "Maze 1 Exit", pos = Vector3.new(541.3, 3.4, -555.0) },
}

local maze2Locs = {
    { label = "Maze 2 Camp 1",       pos = Vector3.new(954.3, -6.6, -417.0) },
    { label = "Maze 2 Camp 2",       pos = Vector3.new(1211.6, -6.6, -490.6) },
    { label = "Maze 2 Camp 3",       pos = Vector3.new(825.2, -6.6, -107.6) },
    { label = "Bridge to Camp 2",    pos = Vector3.new(1146.0, -6.6, -1105.5) },
    { label = "Maze 2 False Wall 1", pos = Vector3.new(1300.0, -6.6, -96.3) },
    { label = "Maze 2 False Wall 2", pos = Vector3.new(1218.5, -6.6, -75.4) },
    { label = "Maze 2 Exit",         pos = Vector3.new(1279.5, -6.6, -43.0) },
}

local maze3Locs = {
    { label = "Maze 3 Entrance",      pos = Vector3.new(1807.6, -13.4, -316.9) },
    { label = "Maze 3 Checkpoint A",  pos = Vector3.new(2054.9, -33.6, 70.6) },
    { label = "Maze 3 Checkpoint B",  pos = Vector3.new(2291.7, -29.6, 72.1) },
    { label = "Maze 3 Storage Start", pos = Vector3.new(2431.9, -29.6, 523.8) },
    { label = "Maze 3 Storage Code",  pos = Vector3.new(2357.3, -37.6, 620.2) },
    { label = "Maze 3 Storage End",   pos = Vector3.new(2144.5, -29.6, 523.4) },
    { label = "Maze 3 Checkpoint C",  pos = Vector3.new(1970.6, -29.6, 332.2) },
    { label = "Maze 3 Exit",          pos = Vector3.new(1785.9, 3.8, 310.6) },
}

local function getHRP()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function createDrawingESP(color)
    local esp = {}
    esp.lines = {}
    for i = 1, 4 do
        local line = Drawing.new("Line")
        line.Color = color
        line.Thickness = 2
        line.Transparency = 1
        line.Visible = false
        esp.lines[i] = line
    end
    esp.nameText = Drawing.new("Text")
    esp.nameText.Color = color
    esp.nameText.Size = 14
    esp.nameText.Center = true
    esp.nameText.Outline = true
    esp.nameText.Visible = false
    esp.nameText.Text = ""
    esp.distText = Drawing.new("Text")
    esp.distText.Color = color
    esp.distText.Size = 12
    esp.distText.Center = true
    esp.distText.Outline = true
    esp.distText.Visible = false
    esp.distText.Text = ""
    return esp
end

local function updateDrawingESP(esp, worldPos, name, visible)
    if not visible or not worldPos then
        for _, line in ipairs(esp.lines) do line.Visible = false end
        esp.nameText.Visible = false
        esp.distText.Visible = false
        return
    end
    local screenPos, onScreen = WorldToScreen(worldPos)
    if not onScreen then
        for _, line in ipairs(esp.lines) do line.Visible = false end
        esp.nameText.Visible = false
        esp.distText.Visible = false
        return
    end
    local myHRP = getHRP()
    local dist = 0
    if myHRP then
        dist = math.floor((myHRP.Position - worldPos).Magnitude)
    end
    local scale = math.clamp(1000 / math.max(dist, 1), 15, 250)
    local boxW = scale
    local boxH = scale * 1.6
    local cx = screenPos.X
    local cy = screenPos.Y
    local x1 = cx - boxW / 2
    local y1 = cy - boxH / 2
    local x2 = cx + boxW / 2
    local y2 = cy + boxH / 2
    esp.lines[1].From = Vector2.new(x1, y1); esp.lines[1].To = Vector2.new(x2, y1)
    esp.lines[2].From = Vector2.new(x1, y2); esp.lines[2].To = Vector2.new(x2, y2)
    esp.lines[3].From = Vector2.new(x1, y1); esp.lines[3].To = Vector2.new(x1, y2)
    esp.lines[4].From = Vector2.new(x2, y1); esp.lines[4].To = Vector2.new(x2, y2)
    for _, line in ipairs(esp.lines) do line.Visible = true end
    esp.nameText.Text = name
    esp.nameText.Position = Vector2.new(cx, y1 - 28)
    esp.nameText.Visible = true
    esp.distText.Text = dist .. " studs"
    esp.distText.Position = Vector2.new(cx, y1 - 14)
    esp.distText.Visible = true
end

local function destroyDrawingESP(esp)
    for _, line in ipairs(esp.lines) do pcall(function() line:Remove() end) end
    pcall(function() esp.nameText:Remove() end)
    pcall(function() esp.distText:Remove() end)
end

local function makeLocationESP(locations, color)
    local esps = {}
    local conn
    local on = false
    local function clear()
        on = false
        if conn then conn:Disconnect(); conn = nil end
        for _, d in ipairs(esps) do destroyDrawingESP(d.esp) end
        esps = {}
    end
    local function start()
        clear()
        on = true
        for _, info in ipairs(locations) do
            local esp = createDrawingESP(color)
            local fixedPos = info.pos
            table.insert(esps, { esp = esp, name = info.label, getPos = function() return fixedPos end })
        end
        conn = RunService.RenderStepped:Connect(function()
            if not on then return end
            for _, d in ipairs(esps) do
                updateDrawingESP(d.esp, d.getPos(), d.name, true)
            end
        end)
        Lib:Notify("ESP", "Tracking " .. #esps .. " locations", 2, "success")
    end
    return start, clear
end

local espTab = win:Tab("ESP", "eye")
local espSec = espTab:Section("ESP Toggles", "Full", "Highlight key objects through walls")

-- Monster ESP
local monsterESPs = {}
local monsterConn
local monsterOn = false

local function clearMonsterESP()
    monsterOn = false
    if monsterConn then monsterConn:Disconnect(); monsterConn = nil end
    for _, d in ipairs(monsterESPs) do destroyDrawingESP(d.esp) end
    monsterESPs = {}
end

local function startMonsterESP()
    clearMonsterESP()
    monsterOn = true
    local npcs = game.Workspace:FindFirstChild("NPCs")
    if not npcs then
        Lib:Notify("ESP", "NPCs folder not found", 3, "error")
        return
    end
    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") then
            local esp = createDrawingESP(Color3.fromRGB(255, 255, 255))
            local npcName = npc.Name
            local npcRef = npc
            table.insert(monsterESPs, {
                esp = esp,
                name = npcName,
                getPos = function()
                    if not npcRef or not npcRef.Parent then return nil end
                    local hrp = npcRef:FindFirstChild("HumanoidRootPart")
                             or npcRef:FindFirstChild("Torso")
                             or npcRef:FindFirstChild("Head")
                    return hrp and hrp.Position or nil
                end,
            })
        end
    end
    monsterConn = RunService.RenderStepped:Connect(function()
        if not monsterOn then return end
        for _, d in ipairs(monsterESPs) do
            local pos = d.getPos()
            updateDrawingESP(d.esp, pos, d.name, pos ~= nil)
        end
    end)
    Lib:Notify("ESP", "Monster ESP ON - tracking " .. #monsterESPs .. " NPCs", 3, "success")
end

espSec:Toggle("Monster ESP", false, function(on)
    if on then startMonsterESP() else clearMonsterESP() end
end)

-- Maze 1 ESP (includes Mirror)
local startMaze1ESP, clearMaze1ESP = makeLocationESP(maze1Locs, Color3.fromRGB(0, 170, 255))
espSec:Toggle("Maze 1 ESP", false, function(on)
    if on then startMaze1ESP() else clearMaze1ESP() end
end)

-- Maze 2 ESP
local startMaze2ESP, clearMaze2ESP = makeLocationESP(maze2Locs, Color3.fromRGB(0, 170, 255))
espSec:Toggle("Maze 2 ESP", false, function(on)
    if on then startMaze2ESP() else clearMaze2ESP() end
end)

local startMaze3ESP, clearMaze3ESP = makeLocationESP(maze3Locs, Color3.fromRGB(0, 170, 255))
espSec:Toggle("Maze 3 ESP", false, function(on)
    if on then startMaze3ESP() else clearMaze3ESP() end
end)

local playerESPs = {}
local playerConn
local playerOn = false

local function clearPlayerESP()
    playerOn = false
    if playerConn then playerConn:Disconnect(); playerConn = nil end
    for _, d in ipairs(playerESPs) do destroyDrawingESP(d.esp) end
    playerESPs = {}
end

local function startPlayerESP()
    clearPlayerESP()
    playerOn = true
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local esp = createDrawingESP(Color3.fromRGB(0, 255, 100))
            local plrRef = plr
            table.insert(playerESPs, {
                esp = esp,
                name = plr.Name,
                getPos = function()
                    local char = plrRef.Character
                    if not char then return nil end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    return hrp and hrp.Position or nil
                end,
            })
        end
    end
    playerConn = RunService.RenderStepped:Connect(function()
        if not playerOn then return end
        for _, d in ipairs(playerESPs) do
            local pos = d.getPos()
            updateDrawingESP(d.esp, pos, d.name, pos ~= nil)
        end
    end)
    Lib:Notify("ESP", "Player ESP ON - tracking " .. #playerESPs .. " players", 3, "success")
end

espSec:Toggle("Players", false, function(on)
    if on then startPlayerESP() else clearPlayerESP() end
end)

local tpTab = win:Tab("Teleport", "compass")

local function teleportTo(pos)
    local hrp = getHRP()
    if not hrp then
        Lib:Notify("Teleport", "Character not found", 2, "error")
        return
    end
    hrp.CFrame = CFrame.new(pos.X, pos.Y, pos.Z)
    Lib:Notify("Teleport", "Teleported!", 2, "success")
end

local tp4 = tpTab:Section("Player Teleports", "Full")

local selectedPlayer = nil
local tpDelay = 0

local function getPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(names, plr.Name)
        end
    end
    return names
end

local playerDropdown = tp4:Dropdown("Target Player", {}, getPlayerNames(), false, function(v)
    selectedPlayer = v[1]
end, nil, true)

tp4:Button("Refresh Players", function()
    playerDropdown:UpdateChoices(getPlayerNames())
    Lib:Notify("Players", "Player list refreshed", 2, "success")
end)

tp4:Slider("Teleport Delay", 0, 1, 0, 15, "s", function(v)
    tpDelay = v
end)

tp4:Button("Teleport to Player", function()
    if not selectedPlayer then
        Lib:Notify("Teleport", "No player selected", 2, "error")
        return
    end
    local targetPlr = Players:FindFirstChild(selectedPlayer)
    if not targetPlr then
        Lib:Notify("Teleport", "Player not found", 2, "error")
        return
    end
    local targetChar = targetPlr.Character
    if not targetChar then
        Lib:Notify("Teleport", "Player has no character", 2, "error")
        return
    end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHRP then
        Lib:Notify("Teleport", "Player HRP not found", 2, "error")
        return
    end
    -- Capture position NOW (before delay)
    local capturedPos = targetHRP.Position
    if tpDelay == 0 then
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = CFrame.new(capturedPos.X, capturedPos.Y, capturedPos.Z)
            Lib:Notify("Teleport", "Teleported to " .. selectedPlayer, 2, "success")
        end
    else
        Lib:Notify("Teleport", "Teleporting to " .. selectedPlayer .. " in " .. tpDelay .. "s", 2, "info")
        task.spawn(function()
            local remaining = tpDelay
            while remaining > 0 do
                wait(1)
                remaining = remaining - 1
                if remaining > 0 then
                    Lib:Notify("Teleport", remaining .. "s remaining...", 1, "warning")
                end
            end
            local hrp = getHRP()
            if hrp then
                hrp.CFrame = CFrame.new(capturedPos.X, capturedPos.Y, capturedPos.Z)
                Lib:Notify("Teleport", "Teleported to " .. selectedPlayer .. "'s previous location", 2, "success")
            end
        end)
    end
end)

local tp1 = tpTab:Section("Maze 1 Teleports", "Full")
for _, loc in ipairs(maze1Locs) do
    tp1:Button(loc.label, function() teleportTo(loc.pos) end)
end

local tp2 = tpTab:Section("Maze 2 Teleports", "Full")
for _, loc in ipairs(maze2Locs) do
    tp2:Button(loc.label, function() teleportTo(loc.pos) end)
end

-- Maze 3 Teleports
local tp3 = tpTab:Section("Maze 3 Teleports", "Full")
for _, loc in ipairs(maze3Locs) do
    tp3:Button(loc.label, function() teleportTo(loc.pos) end)
end

local puzzleTab = win:Tab("Puzzles", "code")
local partySec = puzzleTab:Section("Party Room", "Full", "Base64 door code solver")

partySec:Button("Solve Code", function()
    local sd = game.Workspace:FindFirstChild("Secret Doors")
    if not sd then
        Lib:Notify("Puzzle", "Secret Doors not found", 3, "error")
        return
    end
    local pad = sd:FindFirstChild("Pad")
    if not pad then
        Lib:Notify("Puzzle", "Pad not found", 3, "error")
        return
    end
    local sg = pad:FindFirstChild("SurfaceGui")
    if not sg then
        Lib:Notify("Puzzle", "SurfaceGui not found", 3, "error")
        return
    end
    local tl = sg:FindFirstChild("TextLabel")
    if not tl then
        Lib:Notify("Puzzle", "TextLabel not found", 3, "error")
        return
    end

    local raw = tl.Text
    if not raw or raw == "" then
        Lib:Notify("Puzzle", "No base64 text found", 3, "error")
        return
    end

    local decoded = base64decode(raw)
    if not decoded or decoded == "" then
        Lib:Notify("Puzzle", "Failed to decode base64", 3, "error")
        return
    end

    local code = ""
    for i = 1, #decoded do
        local c = decoded:sub(i, i)
        if c >= "0" and c <= "9" then
            code = code .. c
        end
    end

    if code == "" then
        Lib:Notify("Puzzle", "No code found in: " .. decoded, 5, "error")
    else
        Lib:Notify("Code: " .. code, decoded, 30, "success")
    end
end)
