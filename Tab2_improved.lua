-- // Bring Parts v2 - Improved
-- // Toggle GUI: RightControl

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local Workspace      = game:GetService("Workspace")
local LocalPlayer    = Players.LocalPlayer

-- ── CONFIG ─────────────────────────────────────────────────────────────────
local CFG = {
    MaxForce        = math.huge,          -- forza illimitata
    MaxVelocity     = math.huge,          -- velocità illimitata
    Responsiveness  = 200,                -- reattività AlignPosition (max = 200)
    TorquePower     = math.huge,          -- torque illimitato (era 100k)
    NetworkVelocity = Vector3.new(9e8, 9e8, 9e8), -- velocità network massima (era ~14)
    ToggleKey       = Enum.KeyCode.RightControl,

    -- OP extras
    ForceMultiplier = 1,                  -- moltiplicatore extra (1 = default)
    UseBodyForce    = true,               -- aggiunge BodyForce in più di AlignPosition
    BodyForcePower  = 1e9,                -- forza BodyForce aggiuntiva (newton)
    UseLinearVelocity = true,             -- aggiunge LinearVelocity per pull istantaneo
    LinearVelocityMax = math.huge,        -- max speed del LinearVelocity
}

-- ── COLORI ─────────────────────────────────────────────────────────────────
local C = {
    BG       = Color3.fromRGB(18, 18, 24),
    Header   = Color3.fromRGB(28, 28, 38),
    Accent   = Color3.fromRGB(100, 80, 220),
    AccentON = Color3.fromRGB(60, 200, 120),
    Surface  = Color3.fromRGB(32, 32, 44),
    Text     = Color3.fromRGB(230, 230, 255),
    Muted    = Color3.fromRGB(130, 130, 160),
}

-- ── GUI ────────────────────────────────────────────────────────────────────
local Gui = Instance.new("ScreenGui")
Gui.Name           = "BringPartsV2"
Gui.ResetOnSpawn   = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(Gui)
        Gui.Parent = game:GetService("CoreGui")
    else
        Gui.Parent = game:GetService("CoreGui")
    end
end)
if not Gui.Parent or not Gui:IsDescendantOf(game) then
    Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end
local function makePadding(parent, px)
    local p = Instance.new("UIPadding", parent)
    local u = UDim.new(0, px)
    p.PaddingLeft = u; p.PaddingRight = u
    p.PaddingTop  = u; p.PaddingBottom = u
    return p
end
local function makeStroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color     = color or C.Accent
    s.Thickness = thickness or 1.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

-- Frame principale
local Main = Instance.new("Frame", Gui)
Main.Name             = "Main"
Main.BackgroundColor3 = C.BG
Main.BorderSizePixel  = 0
Main.Position         = UDim2.new(0.5, -130, 0.5, -80)
Main.Size             = UDim2.new(0, 260, 0, 160)
Main.Active           = true
Main.Draggable        = true
makeCorner(Main, 12)
makeStroke(Main, C.Accent, 1.5)

-- Ombra
local Shadow = Instance.new("ImageLabel", Main)
Shadow.Name              = "Shadow"
Shadow.BackgroundTransparency = 1
Shadow.Position          = UDim2.new(0, -15, 0, -15)
Shadow.Size              = UDim2.new(1, 30, 1, 30)
Shadow.ZIndex            = -1
Shadow.Image             = "rbxassetid://6014261993"
Shadow.ImageColor3       = Color3.fromRGB(0,0,0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType         = Enum.ScaleType.Slice
Shadow.SliceCenter       = Rect.new(49,49,450,450)

-- Header bar
local Header = Instance.new("Frame", Main)
Header.Name             = "Header"
Header.BackgroundColor3 = C.Header
Header.BorderSizePixel  = 0
Header.Size             = UDim2.new(1, 0, 0, 34)
makeCorner(Header, 12)
-- Fix angoli inferiori header
local HeaderFix = Instance.new("Frame", Header)
HeaderFix.BackgroundColor3 = C.Header
HeaderFix.BorderSizePixel  = 0
HeaderFix.Position         = UDim2.new(0, 0, 0.5, 0)
HeaderFix.Size             = UDim2.new(1, 0, 0.5, 0)

local Title = Instance.new("TextLabel", Header)
Title.BackgroundTransparency = 1
Title.Size        = UDim2.new(1, -10, 1, 0)
Title.Position    = UDim2.new(0, 10, 0, 0)
Title.Font        = Enum.Font.GothamBold
Title.Text        = "⬡  Bring Parts"
Title.TextColor3  = C.Text
Title.TextSize    = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Dot status
local StatusDot = Instance.new("Frame", Header)
StatusDot.Name             = "Dot"
StatusDot.BackgroundColor3 = C.Muted
StatusDot.BorderSizePixel  = 0
StatusDot.Position         = UDim2.new(1, -20, 0.5, -5)
StatusDot.Size             = UDim2.new(0, 10, 0, 10)
makeCorner(StatusDot, 5)

-- TextBox player
local Box = Instance.new("TextBox", Main)
Box.Name             = "Box"
Box.BackgroundColor3 = C.Surface
Box.BorderSizePixel  = 0
Box.Position         = UDim2.new(0.05, 0, 0, 44)
Box.Size             = UDim2.new(0.90, 0, 0, 34)
Box.Font             = Enum.Font.GothamSemibold
Box.PlaceholderText  = "Nome giocatore..."
Box.PlaceholderColor3 = C.Muted
Box.Text             = ""
Box.TextColor3       = C.Text
Box.TextSize         = 14
Box.ClearTextOnFocus = false
makeCorner(Box, 7)
makeStroke(Box, C.Accent, 1)
makePadding(Box, 8)

-- Label status giocatore
local PlayerLabel = Instance.new("TextLabel", Main)
PlayerLabel.BackgroundTransparency = 1
PlayerLabel.Position    = UDim2.new(0.05, 0, 0, 82)
PlayerLabel.Size        = UDim2.new(0.90, 0, 0, 16)
PlayerLabel.Font        = Enum.Font.Gotham
PlayerLabel.Text        = "Nessun giocatore selezionato"
PlayerLabel.TextColor3  = C.Muted
PlayerLabel.TextSize    = 11
PlayerLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Bottone toggle
local Button = Instance.new("TextButton", Main)
Button.Name             = "Button"
Button.BackgroundColor3 = C.Accent
Button.BorderSizePixel  = 0
Button.Position         = UDim2.new(0.05, 0, 0, 104)
Button.Size             = UDim2.new(0.90, 0, 0, 40)
Button.Font             = Enum.Font.GothamBold
Button.Text             = "▶  ATTIVA"
Button.TextColor3       = Color3.fromRGB(255, 255, 255)
Button.TextSize         = 14
Button.AutoButtonColor  = false
makeCorner(Button, 8)

-- Hint tasto
local HintLabel = Instance.new("TextLabel", Main)
HintLabel.BackgroundTransparency = 1
HintLabel.Position    = UDim2.new(0, 0, 1, 2)
HintLabel.Size        = UDim2.new(1, 0, 0, 14)
HintLabel.Font        = Enum.Font.Gotham
HintLabel.Text        = "RightCtrl = nascondi GUI"
HintLabel.TextColor3  = C.Muted
HintLabel.TextSize    = 10
HintLabel.TextXAlignment = Enum.TextXAlignment.Center

-- ── LOGICA ─────────────────────────────────────────────────────────────────

-- Network control (run once)
if not getgenv().BPNetwork then
    getgenv().BPNetwork = {
        BaseParts = {},
        Velocity  = CFG.NetworkVelocity,
    }
    -- FIX: NON usare Workspace come ReplicationFocus.
    -- Con Workspace come focus il client simula tutto, compreso il proprio
    -- personaggio → il LocalPlayer veniva "attirato" come una BasePart qualsiasi.
    -- Usiamo l'HRP del proprio personaggio (comportamento default di Roblox).
    local function updateReplicationFocus()
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then LocalPlayer.ReplicationFocus = hrp end
        end
    end
    updateReplicationFocus()
    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart", 5)
        updateReplicationFocus()
    end)

    RunService.Heartbeat:Connect(function()
        -- FIX: SimulationRadius NON deve essere math.huge.
        -- math.huge faceva simulare l'intero world lato client, il personaggio
        -- locale veniva incluso nella simulazione fisica → si muoveva come un blocco.
        -- 256 studs è più che sufficiente per controllare le parti attorno al target.
        pcall(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", 256)
        end)
        local localChar2 = LocalPlayer.Character
        for _, v in pairs(getgenv().BPNetwork.BaseParts) do
            if v and v:IsDescendantOf(Workspace) then
                -- FIX: non applicare velocità network al personaggio locale
                if not localChar2 or not v:IsDescendantOf(localChar2) then
                    v.Velocity = getgenv().BPNetwork.Velocity
                end
            end
        end
    end)
end

-- Anchor point
local Folder = Instance.new("Folder", Workspace)
local AnchorPart = Instance.new("Part", Folder)
AnchorPart.Anchored      = true
AnchorPart.CanCollide    = false
AnchorPart.Transparency  = 1
AnchorPart.Size          = Vector3.new(0.1, 0.1, 0.1)
local Attachment1 = Instance.new("Attachment", AnchorPart)

local blackHoleActive          = false
local DescendantAddedConnection = nil
local RenderConnection          = nil
local targetPlayer              = nil
local targetCharacter           = nil
local targetHRP                 = nil

local function cleanPart(v)
    for _, x in ipairs(v:GetChildren()) do
        if x:IsA("BodyMover") or x:IsA("RocketPropulsion")
            or x:IsA("AlignPosition") or x:IsA("Torque") then
            x:Destroy()
        end
    end
end

local function getDirectionTo(v)
    if Attachment1 then
        return (Attachment1.WorldPosition - v.Position).Unit
    end
    return Vector3.new(0,0,0)
end

local function ForcePart(v)
    if not v or not v:IsDescendantOf(Workspace) then return end
    if not v:IsA("BasePart") then return end
    if v.Anchored then return end
    if v.Name == "Handle" then return end

    local parent = v.Parent
    if parent then
        if parent:FindFirstChildOfClass("Humanoid") then return end
        if parent:FindFirstChild("Head") then return end
    end
    -- FIX: escludi il personaggio del LocalPlayer
    -- (causa principale del teletrasporto / comportamento da blocco unanchored)
    local localChar = LocalPlayer.Character
    if localChar and v:IsDescendantOf(localChar) then return end
    -- Escludi anche il personaggio del target
    if targetCharacter and v:IsDescendantOf(targetCharacter) then return end

    cleanPart(v)
    v.CanCollide    = false
    v.AssemblyLinearVelocity  = Vector3.zero -- azzera velocità residua
    v.AssemblyAngularVelocity = Vector3.zero

    local att2 = Instance.new("Attachment", v)

    -- 1) AlignPosition — position constraint principale
    local alignPos = Instance.new("AlignPosition", v)
    alignPos.MaxForce      = CFG.MaxForce
    alignPos.MaxVelocity   = CFG.MaxVelocity
    alignPos.Responsiveness = CFG.Responsiveness
    alignPos.Attachment0   = att2
    alignPos.Attachment1   = Attachment1
    alignPos.ApplyAtCenterOfMass = true

    -- 2) Torque — impedisce rotazione/fuga angolare
    local torque = Instance.new("Torque", v)
    torque.Torque      = Vector3.new(CFG.TorquePower, CFG.TorquePower, CFG.TorquePower)
    torque.Attachment0 = att2

    -- 3) BodyForce aggiuntiva — spinge direttamente verso il target
    if CFG.UseBodyForce then
        local bf = Instance.new("BodyForce", v)
        local dir = getDirectionTo(v)
        bf.Force = dir * CFG.BodyForcePower
        -- aggiorna la direzione ogni heartbeat
        RunService.Heartbeat:Connect(function()
            if not blackHoleActive or not v:IsDescendantOf(Workspace) then
                bf:Destroy()
                return
            end
            bf.Force = getDirectionTo(v) * CFG.BodyForcePower
        end)
    end

    -- 4) LinearVelocity — forza lo spostamento puro verso il punto
    if CFG.UseLinearVelocity then
        local lv = Instance.new("LinearVelocity", v)
        lv.Attachment0     = att2
        lv.MaxForce        = CFG.LinearVelocityMax
        lv.VectorVelocity  = Vector3.zero
        RunService.Heartbeat:Connect(function()
            if not blackHoleActive or not v:IsDescendantOf(Workspace) then
                lv:Destroy()
                return
            end
            local dir = getDirectionTo(v)
            local dist = (Attachment1.WorldPosition - v.Position).Magnitude
            -- velocità proporzionale alla distanza, cap a 9999 per parti vicine
            lv.VectorVelocity = dir * math.min(dist * 80, 9999)
        end)
    end

    table.insert(getgenv().BPNetwork.BaseParts, v)
end

local function setButtonState(on)
    local color = on and C.AccentON or C.Accent
    local text  = on and "■  DISATTIVA" or "▶  ATTIVA"
    TweenService:Create(Button,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad),
        {BackgroundColor3 = color}
    ):Play()
    Button.Text = text
    StatusDot.BackgroundColor3 = on and C.AccentON or C.Muted
end

local function stopBlackHole()
    blackHoleActive = false
    setButtonState(false)

    if DescendantAddedConnection then
        DescendantAddedConnection:Disconnect()
        DescendantAddedConnection = nil
    end
    if RenderConnection then
        RenderConnection:Disconnect()
        RenderConnection = nil
    end
    table.clear(getgenv().BPNetwork.BaseParts)
end

local function startBlackHole()
    blackHoleActive = true
    setButtonState(true)

    -- Parti già presenti
    for _, v in ipairs(Workspace:GetDescendants()) do
        ForcePart(v)
    end

    -- Nuove parti
    DescendantAddedConnection = Workspace.DescendantAdded:Connect(function(v)
        if blackHoleActive then
            ForcePart(v)
        end
    end)

    -- Aggiorna posizione anchor ogni frame
    RenderConnection = RunService.RenderStepped:Connect(function()
        if not blackHoleActive then return end
        if targetHRP and targetHRP:IsDescendantOf(Workspace) then
            Attachment1.WorldCFrame = targetHRP.CFrame
        end
    end)
end

local function toggleBlackHole()
    if blackHoleActive then
        stopBlackHole()
    else
        startBlackHole()
    end
end

-- ── Ricerca giocatore ──────────────────────────────────────────────────────
local function getPlayer(name)
    local lowerName = string.lower(name)
    for _, p in pairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), lowerName)
            or string.find(string.lower(p.DisplayName), lowerName) then
            return p
        end
    end
end

local function bindCharacter(plr)
    -- Aggiorna HRP quando il personaggio cambia
    local function onCharAdded(char)
        targetCharacter = char
        targetHRP = char:WaitForChild("HumanoidRootPart", 5)
    end
    if plr.Character then onCharAdded(plr.Character) end
    plr.CharacterAdded:Connect(onCharAdded)
end

-- ── Input TextBox ──────────────────────────────────────────────────────────
Box.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local found = getPlayer(Box.Text)
        if found then
            targetPlayer = found
            Box.Text = found.Name
            PlayerLabel.Text      = "✓  " .. found.DisplayName .. " (@" .. found.Name .. ")"
            PlayerLabel.TextColor3 = C.AccentON
            bindCharacter(found)
        else
            PlayerLabel.Text      = "✗  Giocatore non trovato"
            PlayerLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
        end
    end
end)

-- ── Bottone ────────────────────────────────────────────────────────────────
Button.MouseButton1Click:Connect(function()
    if not targetPlayer then
        PlayerLabel.Text      = "⚠  Inserisci un giocatore prima"
        PlayerLabel.TextColor3 = Color3.fromRGB(255, 180, 0)
        return
    end
    if not targetHRP then
        PlayerLabel.Text      = "⚠  Personaggio non trovato"
        PlayerLabel.TextColor3 = Color3.fromRGB(255, 180, 0)
        return
    end
    toggleBlackHole()
end)

-- Hover effect
Button.MouseEnter:Connect(function()
    local hoverColor = blackHoleActive
        and Color3.fromRGB(40, 170, 100)
        or  Color3.fromRGB(80, 60, 180)
    TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
end)
Button.MouseLeave:Connect(function()
    local baseColor = blackHoleActive and C.AccentON or C.Accent
    TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = baseColor}):Play()
end)

-- ── Toggle GUI (RightControl) ──────────────────────────────────────────────
local guiVisible = true
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == CFG.ToggleKey then
        guiVisible = not guiVisible
        TweenService:Create(Main, TweenInfo.new(0.2), {
            BackgroundTransparency = guiVisible and 0 or 1
        }):Play()
        Main.Visible = guiVisible
    end
end)

-- ── Cleanup su rimozione GUI ───────────────────────────────────────────────
Gui.AncestryChanged:Connect(function()
    if not Gui:IsDescendantOf(game) then
        stopBlackHole()
        Folder:Destroy()
    end
end)
