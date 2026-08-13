local service = setmetatable({}, {
    __index = function(t, k)
        local s = game:GetService(k)
        t[k] = s
        return s
    end
})

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/rpx-jp/ORion-aaaa/refs/heads/main/orion?t=" .. tostring(tick())))()

OrionLib:AddTheme("Yooo!", {
    Main = Color3.fromRGB(10, 13, 15),
    Second = Color3.fromRGB(18, 23, 25),
    Stroke = Color3.fromRGB(0, 220, 150),
    Divider = Color3.fromRGB(35, 55, 50),
    Text = Color3.fromRGB(245, 250, 250),
    TextDark = Color3.fromRGB(140, 175, 165)
})

OrionLib:SetTheme("Yooo!")

local function getGradientText(text, startColor, endColor)
    local result = ""
    local len = #text
    for i = 1, len do
        local t = (len > 1) and (i - 1) / (len - 1) or 0
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, text:sub(i, i))
    end
    return result
end

-- 外国語自動翻訳関数
local function translateToEnglish(text)
    if not text or text == "" or text == "Loading..." then return text end
    if not text:find("[^\1-\127]") then return text end
    
    local success, res = pcall(function()
        local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=en&dt=t&q=" .. service.HttpService:UrlEncode(text)
        local response = game:HttpGet(url)
        local decoded = service.HttpService:JSONDecode(response)
        if decoded and decoded[1] and decoded[1][1] and decoded[1][1][1] then
            return decoded[1][1][1]
        end
    end)
    
    if success and res and res ~= "" then return res end
    return text
end

local NotificationSettings={
    EnableImage="rbxassetid://14562122532",
    DisableImage="rbxassetid://17829927053",
    CheckImage="rbxassetid://16210234931",
    EnableSound="rbxassetid://6647898215",
    DisableSound="rbxassetid://17582299860",
    CheckSound="rbxassetid://18595195017",
    Time=4,
    Volume=1
}

local function ShowNotification(title, content, image, soundId)
    OrionLib:MakeNotification({
        Name = title or "Notification",
        Content = content or "",
        Image = image or NotificationSettings.CheckImage,
        Time = NotificationSettings.Time
    })
    if soundId then
        local sound = Instance.new("Sound")
        sound.Parent = service.SoundService
        sound.Volume = NotificationSettings.Volume
        sound.SoundId = soundId
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end
end

local function Notify(title, text, mode)
    local modes = {
        Yes = {img = NotificationSettings.EnableImage, sound = NotificationSettings.EnableSound},
        No = {img = NotificationSettings.DisableImage, sound = NotificationSettings.DisableSound},
        Check = {img = NotificationSettings.CheckImage, sound = NotificationSettings.CheckSound}
    }
    local data = modes[mode] or {}
    ShowNotification(title, text, data.img, data.sound)
end

local function ShowToggleNotification(title, enabled)
    if enabled then
        Notify(title, "Enabled", "Yes")
    else
        Notify(title, "Disabled", "No")
    end
end

local currentPlaceId = game.PlaceId
local isLobby = (currentPlaceId == 70411440483149)

local Window = OrionLib:MakeWindow({
    Name = "Xunzn Hub", 
    HidePremium = true, 
    SaveConfig = true, 
    ConfigFolder = "XunznHub", 
    IntroEnabled = true, 
    IntroText = "Loading... Please wait :3",
    Keybind = "RightShift", 
    FreeMouse = false
})

if isLobby then
    Window:MakeTabGroup({ Name = "Others", Title = "Others" })
else
    Window:MakeTabGroup({ Name = "Main", Title = "Main" })
    Window:MakeTabGroup({ Name = "Others", Title = "Others" })
end

local ObjectTab
if not isLobby then
    local CombatTab = Window:MakeTab({Name = "Combat", Icon = "hand-fist", Group = "Main", PremiumOnly = false})
    local InvincibilityTab = Window:MakeTab({Name = "Invincibility", Icon = "shield", Group = "Main", PremiumOnly = false})
    local PlayerTab = Window:MakeTab({Name = "Player", Icon = "user", Group = "Main", PremiumOnly = false})
    local ESPTab = Window:MakeTab({Name = "ESP", Icon = "eye", Group = "Main", PremiumOnly = false})
    local TeleportTab = Window:MakeTab({Name = "Teleport", Icon = "footprints", Group = "Main", PremiumOnly = false})
    ObjectTab = Window:MakeTab({Name = "Objects", Icon = "rbxassetid://105880397565283", Group = "Main", PremiumOnly = false})
    local KeybindsTab = Window:MakeTab({Name = "Keybinds", Icon = "keyboard", Group = "Main", PremiumOnly = false})
    local AutoTab = Window:MakeTab({Name = "Automation", Icon = "infinity", Group = "Main", PremiumOnly = false})
end

local InfoTab = Window:MakeTab({Name = "Information", Icon = "info", Group = "Others", PremiumOnly = false})

if not isLobby then
    local MiscTab = Window:MakeTab({Name = "Misc", Icon = "box", Group = "Others", PremiumOnly = false})
    local ConfigTab = Window:MakeTab({Name = "Settings", Icon = "settings", Group = "Others", PremiumOnly = false})
    local PremiumInfoTab = Window:MakeTab({Name = "Premium Info", Icon = "crown", Group = "Others", PremiumOnly = false})
    local CreditsTab = Window:MakeTab({Name = "Credits", Icon = "user-round-check", Group = "Others", PremiumOnly = false})
end

local LocalPlayer = service.Players.LocalPlayer
local startTime = os.clock()
local fps = 0

local emeraldGreen = Color3.fromRGB(0, 220, 150)
local shinySilver  = Color3.fromRGB(240, 245, 255)

-- ==========================================
-- ★ DebrisField ESP システム構築部分 ★
-- ==========================================
local ESP_DebrisEnabled = false
local DebrisESPContainer = {}

local function clearDebrisESP()
    for model, elements in pairs(DebrisESPContainer) do
        if elements.Highlight then elements.Highlight:Destroy() end
        if elements.Billboard then elements.Billboard:Destroy() end
    end
    table.clear(DebrisESPContainer)
end

local function getModelMeshName(model)
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("MeshPart") or desc:IsA("SpecialMesh") then
            if desc.Name ~= "" and desc.Name ~= "Part" and desc.Name ~= "Mesh" then
                return desc.Name
            end
        end
    end
    return model.Name
end

local function createDebrisESP(model)
    if not ESP_DebrisEnabled then return end
    if DebrisESPContainer[model] then return end

    local primaryPart = model:IsA("Model") and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or (model:IsA("BasePart") and model)
    if not primaryPart then return end

    local displayName = getModelMeshName(model)

    -- Highlight (外形発光線)
    local highlight = Instance.new("Highlight")
    highlight.Name = "Xunzn_DebrisHighlight"
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(0, 220, 150)
    highlight.FillTransparency = 0.65
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = primaryPart

    -- BillboardGui (名前・距離ネームタグ)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Xunzn_DebrisBillboard"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 160, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 14
    nameLabel.Text = displayName

    billboard.Parent = primaryPart

    DebrisESPContainer[model] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = nameLabel,
        Part = primaryPart,
        DisplayName = displayName
    }
end

-- ESPループ（距離のリアルタイム更新）
task.spawn(function()
    while task.wait(0.3) do
        if ESP_DebrisEnabled then
            local debrisFolder = workspace:FindFirstChild("DebrisField")
            if debrisFolder then
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")

                for _, model in ipairs(debrisFolder:GetChildren()) do
                    if not DebrisESPContainer[model] then
                        createDebrisESP(model)
                    end
                    
                    local espData = DebrisESPContainer[model]
                    if espData and espData.Label and espData.Part and rootPart then
                        local dist = math.round((rootPart.Position - espData.Part.Position).Magnitude)
                        espData.Label.Text = string.format("%s [%dm]", espData.DisplayName, dist)
                    end
                end
            end
        else
            if next(DebrisESPContainer) then
                clearDebrisESP()
            end
        end
    end
end)

-- ObjectsタブにESPトグルボタンを追加
if ObjectTab then
    ObjectTab:AddSection({Name = getGradientText("DebrisField Detector", emeraldGreen, shinySilver)})
    ObjectTab:AddToggle({
        Name = "DebrisField Items ESP",
        Default = false,
        Callback = function(Value)
            ESP_DebrisEnabled = Value
            ShowToggleNotification("DebrisField ESP", Value)
            if not Value then
                clearDebrisESP()
            end
        end
    })
end

-- FPS計測
do
    local frames = 0
    local last = os.clock()
    service.RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if os.clock() - last >= 1 then
            fps = frames
            frames = 0
            last = os.clock()
        end
    end)
end

local gameName = "Loading..."
task.spawn(function()
    pcall(function()
        local rawName = service.MarketplaceService:GetProductInfo(game.PlaceId).Name
        gameName = translateToEnglish(rawName)
    end)
end)

-- ShiftLock検出通知
task.spawn(function()
    task.wait(1.5)
    if LocalPlayer.DevEnableMouseLock then
        OrionLib:MakeNotification({
            Name = "ShiftLock Notice",
            Content = "ShiftLock is enabled in this server. RightShift GUI keybind may not work.",
            Image = "rbxassetid://4384403532",
            Time = 6,
            AccentColor = Color3.fromRGB(100, 150, 255),
            Glassmorphism = true,
            FluidMotion = true
        })
    end
end)

local function formatTime(sec)
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local sTime = math.floor(sec % 60)
    return string.format("%02d:%02d:%02d", h, m, sTime)
end

if isLobby then
    InfoTab:AddSection({Name = getGradientText("Lobby Warning", emeraldGreen, shinySilver)})
    InfoTab:AddParagraph(
        getGradientText("Warning", emeraldGreen, shinySilver),
        "<font color=\"#FF4500\"><b>[WARNING]</b></font> You are currently in the Lobby.\nPlease enter the game server to use all features."
    )
end

InfoTab:AddSection({Name = getGradientText("System Notice", emeraldGreen, shinySilver)})

InfoTab:AddParagraph(
    getGradientText("Notice", emeraldGreen, shinySilver),
    "Press <font color=\"#00FF99\"><b>RightShift</b></font> to toggle GUI window."
)

InfoTab:AddSection({Name = getGradientText("Session Statistics", emeraldGreen, shinySilver)})

local StatsParagraph = InfoTab:AddParagraph(getGradientText("Live Metrics", emeraldGreen, shinySilver), "Calculating session metrics...")

local function UpdateStatsParagraph(paragraphObj, newTitleText, newContentText)
    if not paragraphObj then return end
    
    local frame = nil
    if typeof(paragraphObj) == "Instance" then
        frame = paragraphObj
    elseif typeof(paragraphObj) == "table" then
        frame = paragraphObj.Frame or paragraphObj.Instance or paragraphObj.Container
    end

    if frame and typeof(frame) == "Instance" then
        local labels = {}
        for _, desc in ipairs(frame:GetDescendants()) do
            if desc:IsA("TextLabel") then
                table.insert(labels, desc)
            end
        end
        
        if #labels >= 2 then
            table.sort(labels, function(a, b)
                return a.AbsolutePosition.Y < b.AbsolutePosition.Y
            end)
            labels[1].Text = newTitleText
            labels[2].Text = newContentText
            return
        elseif #labels == 1 then
            labels[1].Text = newContentText
            return
        end
    end

    local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
    local OrionGui = CoreGui:FindFirstChild("OrionBliz")
    if OrionGui then
        for _, desc in ipairs(OrionGui:GetDescendants()) do
            if desc:IsA("TextLabel") and (desc.Text:find("Live Metrics") or desc.Text:find("Calculating")) then
                local parentFrame = desc:FindFirstAncestorWhichIsA("Frame")
                if parentFrame then
                    local labels = {}
                    for _, child in ipairs(parentFrame:GetDescendants()) do
                        if child:IsA("TextLabel") then
                            table.insert(labels, child)
                        end
                    end
                    if #labels >= 2 then
                        table.sort(labels, function(a, b)
                            return a.AbsolutePosition.Y < b.AbsolutePosition.Y
                        end)
                        labels[1].Text = newTitleText
                        labels[2].Text = newContentText
                        return
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(1) do
        local uptime = formatTime(os.clock() - startTime)
        local pingVal = math.round(LocalPlayer:GetNetworkPing() * 1000)
        local pingText = (pingVal > 0) and (pingVal .. " ms") or "Calculating..."
        local jobId = (game.JobId ~= "") and (game.JobId:sub(1, 8) .. "...") or "Solo/Studio"
        local accountAge = LocalPlayer.AccountAge .. " Days"
        
        local statsText = string.format(
            "<font color=\"#E0E6ED\"><b>Script Version:</b></font> <font color=\"#00FF99\"><b>3.0.9</b></font>\n" ..
            "<font color=\"#E0E6ED\"><b>Game Name:</b></font> <font color=\"#00E5FF\"><b>%s</b></font>\n" ..
            "<font color=\"#E0E6ED\"><b>Place ID:</b></font> <font color=\"#AAAAAA\">%d</font>\n" ..
            "<font color=\"#E0E6ED\"><b>Server Job ID:</b></font> <font color=\"#AAAAAA\">%s</font>\n" ..
            "<font color=\"#E0E6ED\"><b>Ping:</b></font> <font color=\"#00FF99\"><b>%s</b></font>  |  <font color=\"#E0E6ED\"><b>FPS:</b></font> <font color=\"#00E5FF\"><b>%d</b></font>\n" ..
            "<font color=\"#E0E6ED\"><b>Uptime:</b></font> <font color=\"#FFD700\"><b>%s</b></font>  |  <font color=\"#E0E6ED\"><b>Account Age:</b></font> <font color=\"#E0E0E0\"><b>%s</b></font>",
            gameName,
            game.PlaceId,
            jobId,
            pingText,
            fps,
            uptime,
            accountAge
        )
        
        UpdateStatsParagraph(StatsParagraph, getGradientText("Live Metrics", emeraldGreen, shinySilver), statsText)
    end
end)

InfoTab:AddSection({Name = getGradientText("Discord Community", emeraldGreen, shinySilver)})

local inviteCode = "uA35WWXpsu"
local discordDesc = "<font color=\"#E0E6ED\"><b>Server Name:</b></font> ---\n<font color=\"#E0E6ED\"><b>Member Count:</b></font> ---\n<font color=\"#E0E6ED\"><b>Online Count:</b></font> ---"
local discordServerIcon = "rbxassetid://10709791437"

local successApi, result = pcall(function()
    local apiURL = "https://discord.com/api/v9/invites/" .. inviteCode .. "?with_counts=true"
    return service.HttpService:JSONDecode(game:HttpGet(apiURL))
end)

if successApi and result and result.guild then
    local guild = result.guild
    local guildName = translateToEnglish(guild.name)
    local memberCount = tostring(result.approximate_member_count or "---")
    local onlineCount = tostring(result.approximate_presence_count or "---")
    
    discordDesc = string.format(
        "<font color=\"#E0E6ED\"><b>Server Name:</b></font> <font color=\"#00E5FF\"><b>%s</b></font>\n" ..
        "<font color=\"#E0E6ED\"><b>Member Count:</b></font> <font color=\"#00FF99\"><b>%s</b></font>\n" ..
        "<font color=\"#E0E6ED\"><b>Online Count:</b></font> <font color=\"#FFD700\"><b>%s</b></font>",
        guildName,
        memberCount,
        onlineCount
    )

    if guild.icon then
        local getasset = getcustomasset or getsynasset
        local req = request or http_request or (syn and syn.request)
        if getasset and writefile then
            local proxyUrl = string.format("https://wsrv.nl/?url=https://cdn.discordapp.com/icons/%s/%s.png", guild.id, guild.icon)
            local successImg, imgData = pcall(function()
                if req then
                    local res = req({Url = proxyUrl, Method = "GET"})
                    return res.Body
                else
                    return game:HttpGet(proxyUrl)
                end
            end)

            if successImg and imgData and #imgData > 100 then
                local fileName = "Xunzn_Discord_" .. tostring(guild.id) .. ".png"
                pcall(function()
                    writefile(fileName, imgData)
                    discordServerIcon = getasset(fileName)
                end)
            end
        end
    end
end

InfoTab:AddImageParagraph(discordServerIcon, discordDesc)

InfoTab:AddButton({
    Name = "Copy & Join Discord",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/" .. inviteCode)
            Notify("Discord", "Invite link copied to clipboard!", "Yes")
        end
    end
})

task.spawn(function()
    local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")

    local OrionGui = CoreGui:WaitForChild("OrionBliz", 5)
    if not OrionGui then return end

    local frames = {}
    for _, child in ipairs(OrionGui:GetChildren()) do
        if child:IsA("Frame") then
            table.insert(frames, child)
        end
    end

    local targetFrame = frames[2] or frames[1]
    if not targetFrame then return end

    for _, desc in ipairs(OrionGui:GetDescendants()) do
        local badGradient = desc:FindFirstChild("ExternalRainbow") or desc:FindFirstChild("RainbowGradient")
        if badGradient then badGradient:Destroy() end
        if desc:IsA("TextLabel") then
            desc.RichText = true
        end
    end

    local emeraldSilverSequence = ColorSequence.new({
        ColorSequenceKeypoint.new(0, emeraldGreen),
        ColorSequenceKeypoint.new(0.25, shinySilver),
        ColorSequenceKeypoint.new(0.5, emeraldGreen),
        ColorSequenceKeypoint.new(0.75, shinySilver),
        ColorSequenceKeypoint.new(1, emeraldGreen)
    })

    for _, desc in ipairs(targetFrame:GetDescendants()) do
        if desc:IsA("TextLabel") and (desc.Text == "Xunzn Hub" or desc.Parent.Name == "TopBar") then
            desc.TextColor3 = Color3.fromRGB(255, 255, 255)
            desc.TextStrokeTransparency = 1

            if not desc:GetAttribute("ColorLocked") then
                desc:SetAttribute("ColorLocked", true)
                desc:GetPropertyChangedSignal("TextColor3"):Connect(function()
                    if desc.TextColor3 ~= Color3.fromRGB(255, 255, 255) then
                        desc.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                end)
            end

            local titleGradient = desc:FindFirstChild("TitleGradient") or Instance.new("UIGradient")
            titleGradient.Name = "TitleGradient"
            titleGradient.Color = emeraldSilverSequence
            titleGradient.Rotation = 0
            titleGradient.Parent = desc

            if not desc:GetAttribute("TitleGradientActive") then
                desc:SetAttribute("TitleGradientActive", true)
                task.spawn(function()
                    local speed = 0.6
                    while desc and desc.Parent and titleGradient and titleGradient.Parent do
                        local offset = (tick() * speed) % 1
                        titleGradient.Offset = Vector2.new(-offset, 0)
                        task.wait()
                    end
                end)
            end
        end
    end

    local stroke = targetFrame:FindFirstChild("EmeraldStroke") or Instance.new("UIStroke")
    stroke.Name = "EmeraldStroke"
    stroke.Thickness = 2.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Parent = targetFrame

    local strokeGradient = stroke:FindFirstChild("EmeraldGradient") or Instance.new("UIGradient")
    strokeGradient.Name = "EmeraldGradient"
    strokeGradient.Color = emeraldSilverSequence
    strokeGradient.Parent = stroke

    if not stroke:GetAttribute("StrokeActive") then
        stroke:SetAttribute("StrokeActive", true)
        task.spawn(function()
            while stroke and stroke.Parent and strokeGradient and strokeGradient.Parent do
                strokeGradient.Rotation = 0
                local tween = TweenService:Create(
                    strokeGradient,
                    TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
                    {Rotation = 360}
                )
                tween:Play()
                tween.Completed:Wait()
            end
        end)
    end
end)
