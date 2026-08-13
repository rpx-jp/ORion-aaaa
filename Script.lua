local ScriptURL = getgenv().ScriptURL or ""

local service = setmetatable({}, {
    __index = function(t, k)
        local s = game:GetService(k)
        t[k] = s
        return s
    end
})

local queueOnTeleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or queueonteleport

if queueOnTeleport and ScriptURL ~= "" then
    pcall(function()
        queueOnTeleport(string.format([[
            repeat task.wait() until game:IsLoaded()
            loadstring(game:HttpGet("%s?t=" .. tostring(tick())))()
        ]], ScriptURL))
    end)
end

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

if not isLobby then
    local CombatTab = Window:MakeTab({Name = "Combat", Icon = "hand-fist", Group = "Main", PremiumOnly = false})
    local InvincibilityTab = Window:MakeTab({Name = "Invincibility", Icon = "shield", Group = "Main", PremiumOnly = false})
    local PlayerTab = Window:MakeTab({Name = "Player", Icon = "user", Group = "Main", PremiumOnly = false})
    local ESPTab = Window:MakeTab({Name = "ESP", Icon = "eye", Group = "Main", PremiumOnly = false})
    local TeleportTab = Window:MakeTab({Name = "Teleport", Icon = "footprints", Group = "Main", PremiumOnly = false})
    local ObjectTab = Window:MakeTab({Name = "Objects", Icon = "rbxassetid://105880397565283", Group = "Main", PremiumOnly = false})
    local KeybindsTab = Window:MakeTab({Name = "Keybinds", Icon = "keyboard", Group = "Main", PremiumOnly = false})
    local AutoTab = Window:MakeTab({Name = "Automation", Icon = "infinity", Group = "Main", PremiumOnly = false})
end

local InfoTab = Window:MakeTab({Name = "Information", Icon = "info", Group = "Others", PremiumOnly = false})

if not isLobby then
    local MiscTab = Window:MakeTab({Name = "Misc", Icon = "box", Group = "Others", PremiumOnly = false})
    local DiscordServerTab = Window:MakeTab({Name = "Discord Server", Icon = "rbxassetid://12058969055", Group = "Others", PremiumOnly = false})
    local ConfigTab = Window:MakeTab({Name = "Settings", Icon = "settings", Group = "Others", PremiumOnly = false})
    local PremiumInfoTab = Window:MakeTab({Name = "Premium Info", Icon = "crown", Group = "Others", PremiumOnly = false})
    local CreditsTab = Window:MakeTab({Name = "Credits", Icon = "user-round-check", Group = "Others", PremiumOnly = false})
end

local LocalPlayer = service.Players.LocalPlayer
local startTime = os.clock()
local fps = 0

local emeraldGreen = Color3.fromRGB(0, 220, 150)
local shinySilver  = Color3.fromRGB(240, 245, 255)

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
        gameName = service.MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)
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
    "All systems operational and loaded.\n" ..
    "Press <font color=\"#00FF99\"><b>RightShift</b></font> to toggle GUI window.\n" ..
    "Please use script features responsibly."
)

InfoTab:AddSection({Name = getGradientText("Session Statistics", emeraldGreen, shinySilver)})

local StatsParagraph = InfoTab:AddParagraph(getGradientText("Live Metrics", emeraldGreen, shinySilver), "Calculating session metrics...")

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
        
        StatsParagraph:Set(statsText)
    end
end)

InfoTab:AddSection({Name = getGradientText("Discord Community", emeraldGreen, shinySilver)})

local inviteCode = "uA35WWXpsu"
local discordDesc = "<font color=\"#E0E6ED\"><b>Server Name:</b></font> ---\n<font color=\"#E0E6ED\"><b>Member Count:</b></font> ---\n<font color=\"#E0E6ED\"><b>Online Count:</b></font> ---"

local successApi, result = pcall(function()
    local apiURL = "https://discord.com/api/v9/invites/" .. inviteCode .. "?with_counts=true"
    return service.HttpService:JSONDecode(game:HttpGet(apiURL))
end)

if successApi and result and result.guild then
    local guildName = result.guild.name
    local memberCount = tostring(result.approximate_member_count)
    local onlineCount = tostring(result.approximate_presence_count)
    discordDesc = string.format(
        "<font color=\"#E0E6ED\"><b>Server Name:</b></font> <font color=\"#00E5FF\"><b>%s</b></font>\n" ..
        "<font color=\"#E0E6ED\"><b>Member Count:</b></font> <font color=\"#00FF99\"><b>%s</b></font>\n" ..
        "<font color=\"#E0E6ED\"><b>Online Count:</b></font> <font color=\"#FFD700\"><b>%s</b></font>",
        guildName,
        memberCount,
        onlineCount
    )
end

InfoTab:AddImageParagraph("rbxassetid://12058969055", discordDesc)

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
                    local speed = 1.2
                    while desc and desc.Parent and titleGradient and titleGradient.Parent do
                        local offset = math.sin(tick() * speed) * 0.35
                        titleGradient.Offset = Vector2.new(offset, 0)
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
