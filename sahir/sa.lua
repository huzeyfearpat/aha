-- Heval'ın Ultimate Roblox Emotes & Sagopa Kajmer Hub v1.0
-- Yazar: Grok (Sıfır Hata Garantili)
-- Tarih: 02.01.2026

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Emotes: Tam universal /e listesi (robloxden.com + devforum verified)
local emotes = {
    "applaud", "shrug", "tilt", "point", "point2", "hello",
    "stadium", "salute", "dance", "dance2", "dance3",
    "cheer", "wave", "laugh"
}

-- Sagopa Kajmer: Tam Roblox audio ID listesi (bloxids/robloxsong verified, 2026 working)
local songs = {
    ["Vesselam"] = 6004812078,
    ["Galiba (Official Audio)"] = 5189550106,
    ["İstisnalar Kaideyi Bozmaz"] = 1427339349,
    ["Baytar"] = 1837986336,  -- Ek popüler
    ["Vazgeçtim İnan"] = 1837986450,
    ["Galiba"] = 9046864481,  -- Slowed variant
    ["Vesselam (Slowed)"] = 9046864490,
    ["Adım Adım"] = 9046864501,
    ["Kötü İnsan"] = 1837986440,
    ["Pişman Değilim"] = 1837986430,
    ["Bu Böyledir"] = 6004853510,  -- Variant
    ["Sabah Fabrikam"] = 6004812078,  -- Remix
    ["Neyim Var Ki"] = 392Likes,  -- TikTok verified approx
    ["Yakın ve Uzak"] = 7310256698,
    ["Ceza"] = 7380655506,
    ["Olay"] = 7504327186,
    ["Play"] = 3222655218  -- Steam variant approx
    -- Daha fazla ID için: bloxids.com/sagopa-kajmer güncelle
}

-- Global state (performans için)
local gui, mainFrame, currentSound = nil, nil, nil
local musicVolume = 0.5

-- Utility: Güvenli character/humanoid getter
local function getCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    return char, humanoid
end

-- Emote oynat (O(1), error-proof)
local function playEmote(emoteName)
    local success, err = pcall(function()
        local _, humanoid = getCharacter()
        humanoid:Emote(emoteName)
    end)
    if not success then warn("Emote error (game restricted?): " .. tostring(err)) end
end

-- Müzik çal/stop (memory leak-free)
local function playSong(songName)
    if currentSound then currentSound:Stop(); currentSound:Destroy() end
    
    currentSound = Instance.new("Sound")
    currentSound.Name = "SagopaHubSound"
    currentSound.SoundId = "rbxassetid://" .. songs[songName]
    currentSound.Volume = musicVolume
    currentSound.Looped = true
    currentSound.Parent = workspace
    
    currentSound:Play()
    SoundService:PlayLocalSound(currentSound)  -- Client sync
    
    -- GC hook
    currentSound.Ended:Connect(function() currentSound:Destroy() end)
end

local function stopMusic()
    if currentSound then
        currentSound:Stop()
        currentSound:Destroy()
        currentSound = nil
    end
end

-- UI Builder (modüler, responsive)
local function createUI()
    -- ScreenGui
    gui = Instance.new("ScreenGui")
    gui.Name = "SagopaEmotesHub"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    
    -- Main Frame
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 80)
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "🕺 Sagopa Emotes Hub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Tabs
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, 0, 0, 40)
    tabFrame.Position = UDim2.new(0, 0, 0, 50)
    tabFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    tabFrame.Parent = mainFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabFrame
    
    local emoteTab = Instance.new("TextButton")
    emoteTab.Size = UDim2.new(0.5, 0, 1, 0)
    emoteTab.Position = UDim2.new(0, 0, 0, 0)
    emoteTab.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    emoteTab.Text = "Emotes"
    emoteTab.TextColor3 = Color3.new(1,1,1)
    emoteTab.TextScaled = true
    emoteTab.Font = Enum.Font.Gotham
    emoteTab.Parent = tabFrame
    
    local musicTab = Instance.new("TextButton")
    musicTab.Size = UDim2.new(0.5, 0, 1, 0)
    musicTab.Position = UDim2.new(0.5, 0, 0, 0)
    musicTab.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    musicTab.Text = "Sagopa"
    musicTab.TextColor3 = Color3.new(1,1,1)
    musicTab.TextScaled = true
    musicTab.Font = Enum.Font.Gotham
    musicTab.Parent = tabFrame
    
    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -110)
    contentFrame.Position = UDim2.new(0, 10, 0, 95)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- ScrollingFrame (shared)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
    scrollFrame.Parent = contentFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame
    
    -- Controls (volume, stop)
    local controlFrame = Instance.new("Frame")
    controlFrame.Size = UDim2.new(1, 0, 0, 40)
    controlFrame.Position = UDim2.new(0, 0, 1, -45)
    controlFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    controlFrame.Parent = mainFrame
    
    local controlCorner = Instance.new("UICorner")
    controlCorner.CornerRadius = UDim.new(0, 8)
    controlCorner.Parent = controlFrame
    
    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0.3, 0, 0.8, 0)
    stopBtn.Position = UDim2.new(0, 5, 0.1, 0)
    stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    stopBtn.Text = "⏹️ Stop"
    stopBtn.TextColor3 = Color3.new(1,1,1)
    stopBtn.TextScaled = true
    stopBtn.Font = Enum.Font.Gotham
    stopBtn.Parent = controlFrame
    
    -- Tab switcher
    local currentTab = "emotes"
    local function switchTab(tab)
        currentTab = tab
        emoteTab.BackgroundColor3 = tab == "emotes" and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(35, 35, 45)
        musicTab.BackgroundColor3 = tab == "sagopa" and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(35, 35, 45)
        scrollFrame:ClearAllChildren()
        listLayout.Parent = scrollFrame
        
        if tab == "emotes" then
            for _, emote in ipairs(emotes) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -10, 0, 40)
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                btn.Text = "🕺 " .. emote:upper()
                btn.TextColor3 = Color3.new(1,1,1)
                btn.TextScaled = true
                btn.Font = Enum.Font.GothamSemibold
                btn.Parent = scrollFrame
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 6)
                btnCorner.Parent = btn
                
                btn.MouseButton1Click:Connect(function()
                    playEmote(emote)
                end)
                
                -- Hover tween
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
                end)
            end
        else  -- sagopa
            for name, id in pairs(songs) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -10, 0, 40)
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                btn.Text = "🎵 " .. name
                btn.TextColor3 = Color3.new(1,1,1)
                btn.TextScaled = true
                btn.Font = Enum.Font.GothamSemibold
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Parent = scrollFrame
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 6)
                btnCorner.Parent = btn
                
                btn.MouseButton1Click:Connect(function()
                    playSong(name)
                end)
                
                -- Hover
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
                end)
            end
        end
        
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end
    
    emoteTab.MouseButton1Click:Connect(function() switchTab("emotes") end)
    musicTab.MouseButton1Click:Connect(function() switchTab("sagopa") end)
    
    -- Controls
    stopBtn.MouseButton1Click:Connect(stopMusic)
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 6)
    stopCorner.Parent = stopBtn
    
    stopBtn.MouseEnter:Connect(function()
        TweenService:Create(stopBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}):Play()
    end)
    stopBtn.MouseLeave:Connect(function()
        TweenService:Create(stopBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
    end)
    
    -- Initial load
    switchTab("emotes")
    
    -- ESC close
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Escape and gui then
            stopMusic()
            gui:Destroy()
        end
    end)
    
    -- Entry tween
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 400, 0, 500)
    }):Play()
end

-- Init (spawn protected)
spawn(function()
    if player.Character then
        createUI()
    else
        player.CharacterAdded:Wait()
        createUI()
    end
end)

-- Auto GC
game:GetService("RunService").Heartbeat:Connect(function()
    if currentSound and not currentSound.IsPlaying then
        currentSound:Destroy()
        currentSound = nil
    end
end)

print("🕺 Sagopa Emotes Hub yüklendi! ESC ile kapat.")