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
    if not text or text == "" or text:find("Fetching") then return text end
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

-- ★ 通知設定 ★
local NotificationsEnabled = true
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
    if not NotificationsEnabled then return end
    local imgId = image or NotificationSettings.CheckImage
    
    OrionLib:MakeNotification({
        Name = title or "Notification",
        Content = content or "",
        Image = imgId,
        Time = NotificationSettings.Time
    })
    
    task.spawn(function()
        task.wait(0.05)
        local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
        local OrionGui = CoreGui:FindFirstChild("OrionBliz")
        if OrionGui then
            for _, desc in ipairs(OrionGui:GetDescendants()) do
                if desc:IsA("ImageLabel") and (desc.Image == imgId or desc.Image:find("16210234931")) then
                    if not desc:GetAttribute("SpinningActive") then
                        desc:SetAttribute("SpinningActive", true)
                        task.spawn(function()
                            local angle = 0
                            while desc and desc.Parent do
                                angle = (angle + 5) % 360
                                desc.Rotation = angle
                                task.wait(0.02)
                            end
                        end)
                    end
                end
            end
        end
    end)

    if soundId and NotificationSettings.Volume > 0 then
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
    IntroText = "Loading... Please wait", 
    Keybind = "RightShift", 
    FreeMouse = false
})

if isLobby then
    Window:MakeTabGroup({ Name = "Others", Title = "Others" })
else
    Window:MakeTabGroup({ Name = "Main", Title = "Main" })
    Window:MakeTabGroup({ Name = "Others", Title = "Others" })
end

local LocalPlayer = service.Players.LocalPlayer
local startTime = os.clock()
local fps = 0

local emeraldGreen = Color3.fromRGB(0, 220, 150)
local shinySilver  = Color3.fromRGB(240, 245, 255)

local UNKNOWN_ITEM_MSG = "Unknown Item"

local foodKeywords = {
    "sushi", "stew", "potato", "biscuit", "orange", "apple", "bread",
    "meat", "fish", "fruit", "food", "drink", "water", "cheese", "cake",
    "pie", "soup", "carrot", "berry", "banana", "corn", "rice"
}

local function isFoodItem(name)
    if not name or name == "" or name == UNKNOWN_ITEM_MSG then return false end
    local lowerName = name:lower()
    for _, kw in ipairs(foodKeywords) do
        if lowerName:find(kw) then
            return true
        end
    end
    return false
end

-- ==========================================
-- ★ 全機能 変数定義 ★
-- ==========================================
local AutoCollectItemsEnabled = false
local AutoCollectChestsEnabled = false
local AutoCollectDistance = 200

local AutoFarmCreaturesEnabled = false
local AutoFarmDistanceBehind = 4
local AutoAttackToolEnabled = true

local MaxESPDistance = 500

local ESP_PlayerEnabled = false
local selectedPlayerItem = "All Players"
local playersList = {"All Players"}
local PlayerESPContainer = {}
local PlayerDropdown = nil

local ESP_ChestsEnabled = false
local selectedChestItem = "All Chests"
local chestsList = {"All Chests"}
local ChestsESPContainer = {}
local ChestDropdown = nil

local ESP_IslandsEnabled = false
local selectedIslandItem = "All Islands"
local islandsList = {"All Islands"}
local IslandsESPContainer = {}
local IslandDropdown = nil

local ESP_CreaturesEnabled = false
local selectedCreatureItem = "All Creatures"
local creaturesList = {"All Creatures"}
local CreaturesESPContainer = {}
local CreatureDropdown = nil

local ESP_MaterialsEnabled = false
local selectedMaterialItem = "All Materials"
local materialsList = {"All Materials"}

local ESP_FoodEnabled = false
local selectedFoodItem = "All Foods"
local foodList = {"All Foods"}

local DebrisESPContainer = {}
local MaterialDropdown = nil
local FoodDropdown = nil

-- 超軽量テキスト更新ヘルパー関数
local function updateESPLabel(espData, newText, isVisible)
    if not espData then return end
    
    if espData.Highlight and espData.Highlight.Enabled ~= isVisible then
        espData.Highlight.Enabled = isVisible
    end
    if espData.Billboard and espData.Billboard.Enabled ~= isVisible then
        espData.Billboard.Enabled = isVisible
    end

    if isVisible and espData.Label then
        if espData.LastText ~= newText then
            espData.Label.Text = newText
            espData.LastText = newText
        end
    end
end

-- クリア関数群
local function clearPlayerESP()
    for player, elements in pairs(PlayerESPContainer) do
        if elements.Highlight then elements.Highlight:Destroy() end
        if elements.Billboard then elements.Billboard:Destroy() end
    end
    table.clear(PlayerESPContainer)
end

local function clearChestsESP()
    for model, elements in pairs(ChestsESPContainer) do
        if elements.Highlight then elements.Highlight:Destroy() end
        if elements.Billboard then elements.Billboard:Destroy() end
    end
    table.clear(ChestsESPContainer)
end

local function clearIslandsESP()
    for model, elements in pairs(IslandsESPContainer) do
        if elements.Highlight then elements.Highlight:Destroy() end
        if elements.Billboard then elements.Billboard:Destroy() end
    end
    table.clear(IslandsESPContainer)
end

local function clearCreaturesESP()
    for model, elements in pairs(CreaturesESPContainer) do
        if elements.Highlight then elements.Highlight:Destroy() end
        if elements.Billboard then elements.Billboard:Destroy() end
    end
    table.clear(CreaturesESPContainer)
end

local function clearDebrisESP()
    for model, elements in pairs(DebrisESPContainer) do
        if elements.Highlight then elements.Highlight:Destroy() end
        if elements.Billboard then elements.Billboard:Destroy() end
    end
    table.clear(DebrisESPContainer)
end

-- オブジェクト生成関数群
local function createPlayerESP(player)
    if player == LocalPlayer then return end
    if not ESP_PlayerEnabled then return end
    if PlayerESPContainer[player] then return end

    local char = player.Character
    if not char then return end

    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid then return end

    local displayName = player.DisplayName or player.Name

    local highlight = Instance.new("Highlight")
    highlight.Name = "Xunzn_PlayerHighlight"
    highlight.Adornee = char
    highlight.FillColor = Color3.fromRGB(255, 50, 80)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Enabled = false
    highlight.Parent = char

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Xunzn_PlayerBillboard"
    billboard.Adornee = rootPart
    billboard.Size = UDim2.new(0, 180, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 80, 100)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 14
    nameLabel.Text = displayName

    billboard.Parent = char

    PlayerESPContainer[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = nameLabel,
        Root = rootPart,
        Humanoid = humanoid,
        Player = player,
        DisplayName = displayName,
        LastText = ""
    }
end

local function createChestESP(model)
    if not ESP_ChestsEnabled then return end
    if ChestsESPContainer[model] then return end

    local primaryPart = model:IsA("Model") and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or (model:IsA("BasePart") and model)
    if not primaryPart then return end

    local displayName = model.Name

    local highlight = Instance.new("Highlight")
    highlight.Name = "Xunzn_ChestHighlight"
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(255, 215, 0)
    highlight.FillTransparency = 0.6
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Enabled = false
    highlight.Parent = primaryPart

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Xunzn_ChestBillboard"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 160, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 220, 50)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 14
    nameLabel.Text = displayName

    billboard.Parent = primaryPart

    ChestsESPContainer[model] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = nameLabel,
        Part = primaryPart,
        DisplayName = displayName,
        LastText = ""
    }
end

local function createIslandESP(model)
    if not ESP_IslandsEnabled then return end
    if IslandsESPContainer[model] then return end

    local primaryPart = model:IsA("Model") and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or (model:IsA("BasePart") and model)
    if not primaryPart then return end

    local displayName = model.Name

    local highlight = Instance.new("Highlight")
    highlight.Name = "Xunzn_IslandHighlight"
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(0, 180, 255)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Enabled = false
    highlight.Parent = primaryPart

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Xunzn_IslandBillboard"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 180, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(0, 210, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 15
    nameLabel.Text = displayName

    billboard.Parent = primaryPart

    IslandsESPContainer[model] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = nameLabel,
        Part = primaryPart,
        DisplayName = displayName,
        LastText = ""
    }
end

local function createCreatureESP(model)
    if not ESP_CreaturesEnabled then return end
    if CreaturesESPContainer[model] then return end

    local primaryPart = model:IsA("Model") and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or (model:IsA("BasePart") and model)
    if not primaryPart then return end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local displayName = model.Name

    local highlight = Instance.new("Highlight")
    highlight.Name = "Xunzn_CreatureHighlight"
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(220, 0, 220)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Enabled = false
    highlight.Parent = primaryPart

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Xunzn_CreatureBillboard"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 170, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 14
    nameLabel.Text = displayName

    billboard.Parent = primaryPart

    CreaturesESPContainer[model] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = nameLabel,
        Part = primaryPart,
        Humanoid = humanoid,
        DisplayName = displayName,
        LastText = ""
    }
end

local function getModelMeshName(model)
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("MeshPart") or desc:IsA("SpecialMesh") then
            if desc.Name ~= "" and desc.Name ~= "Part" and desc.Name ~= "Mesh" and not desc.Name:match("^%-?%d+$") then
                return desc.Name
            end
        end
    end
    if model.Name:match("^%-?%d+$") or tonumber(model.Name) then
        return UNKNOWN_ITEM_MSG
    end
    return model.Name
end

local function createDebrisESP(model)
    if not (ESP_MaterialsEnabled or ESP_FoodEnabled) then return end
    if DebrisESPContainer[model] then return end

    local primaryPart = model:IsA("Model") and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or (model:IsA("BasePart") and model)
    if not primaryPart then return end

    local displayName = getModelMeshName(model)
    local isFood = isFoodItem(displayName)

    local highlight = Instance.new("Highlight")
    highlight.Name = "Xunzn_DebrisHighlight"
    highlight.Adornee = model
    highlight.FillColor = isFood and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(0, 220, 150)
    highlight.FillTransparency = 0.65
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Enabled = false
    highlight.Parent = primaryPart

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Xunzn_DebrisBillboard"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 160, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = isFood and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(0, 255, 180)
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
        DisplayName = displayName,
        IsFood = isFood,
        LastText = ""
    }
end

-- 全ESPカテゴリ自動スキャン＆ドロップダウン自動リフレッシュ関数
local function scanAndRefreshDropdowns()
    -- 1. Players
    local currentPlayers = {}
    for _, plr in ipairs(service.Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(currentPlayers, plr.DisplayName or plr.Name)
        end
    end
    table.sort(currentPlayers)
    local newPlayerList = {"All Players"}
    for _, pName in ipairs(currentPlayers) do table.insert(newPlayerList, pName) end

    if #newPlayerList ~= #playersList then
        playersList = newPlayerList
        if PlayerDropdown then
            local cur = selectedPlayerItem or "All Players"
            PlayerDropdown:Refresh(playersList, true)
            pcall(function() PlayerDropdown:Set(cur) end)
        end
    end

    -- 2. Chests
    local chestsFolder = workspace:FindFirstChild("Chests")
    local foundChestsMap = {}
    local currentChests = {}
    if chestsFolder then
        for _, model in ipairs(chestsFolder:GetChildren()) do
            local cName = model.Name
            if cName and not foundChestsMap[cName] then
                foundChestsMap[cName] = true
                table.insert(currentChests, cName)
            end
        end
    end
    table.sort(currentChests)
    local newChestList = {"All Chests"}
    for _, cName in ipairs(currentChests) do table.insert(newChestList, cName) end

    if #newChestList ~= #chestsList then
        chestsList = newChestList
        if ChestDropdown then
            local cur = selectedChestItem or "All Chests"
            ChestDropdown:Refresh(chestsList, true)
            pcall(function() ChestDropdown:Set(cur) end)
        end
    end

    -- 3. Islands
    local islandsFolder = workspace:FindFirstChild("IslandContainer")
    local foundIslandsMap = {}
    local currentIslands = {}
    if islandsFolder then
        for _, model in ipairs(islandsFolder:GetChildren()) do
            local iName = model.Name
            if iName and not foundIslandsMap[iName] then
                foundIslandsMap[iName] = true
                table.insert(currentIslands, iName)
            end
        end
    end
    table.sort(currentIslands)
    local newIslandList = {"All Islands"}
    for _, iName in ipairs(currentIslands) do table.insert(newIslandList, iName) end

    if #newIslandList ~= #islandsList then
        islandsList = newIslandList
        if IslandDropdown then
            local cur = selectedIslandItem or "All Islands"
            IslandDropdown:Refresh(islandsList, true)
            pcall(function() IslandDropdown:Set(cur) end)
        end
    end

    -- 4. Creatures
    local creaturesFolder = workspace:FindFirstChild("CreatureContainer")
    local foundCreaturesMap = {}
    local currentCreatures = {}
    if creaturesFolder then
        for _, model in ipairs(creaturesFolder:GetChildren()) do
            local crName = model.Name
            if crName and not foundCreaturesMap[crName] then
                foundCreaturesMap[crName] = true
                table.insert(currentCreatures, crName)
            end
        end
    end
    table.sort(currentCreatures)
    local newCreatureList = {"All Creatures"}
    for _, crName in ipairs(currentCreatures) do table.insert(newCreatureList, crName) end

    if #newCreatureList ~= #creaturesList then
        creaturesList = newCreatureList
        if CreatureDropdown then
            local cur = selectedCreatureItem or "All Creatures"
            CreatureDropdown:Refresh(creaturesList, true)
            pcall(function() CreatureDropdown:Set(cur) end)
        end
    end

    -- 5. Debris & Food
    local debrisFolder = workspace:FindFirstChild("DebrisField")
    local foundMaterialsMap = {}
    local foundFoodsMap = {}
    local currentMaterials = {}
    local currentFoods = {}

    if debrisFolder then
        for _, model in ipairs(debrisFolder:GetChildren()) do
            local name = getModelMeshName(model)
            if name then
                if isFoodItem(name) then
                    if not foundFoodsMap[name] then
                        foundFoodsMap[name] = true
                        table.insert(currentFoods, name)
                    end
                else
                    if not foundMaterialsMap[name] then
                        foundMaterialsMap[name] = true
                        table.insert(currentMaterials, name)
                    end
                end
            end
        end
    end

    table.sort(currentMaterials, function(a, b)
        if a == UNKNOWN_ITEM_MSG then return false end
        if b == UNKNOWN_ITEM_MSG me
            return true
        end
        return a < b
    end)
    table.sort(currentFoods)

    local newMatList = {"All Materials"}
    for _, name in ipairs(currentMaterials) do table.insert(newMatList, name) end

    local newFoodList = {"All Foods"}
    for _, name in ipairs(currentFoods) do table.insert(newFoodList, name) end

    if #newMatList ~= #materialsList then
        materialsList = newMatList
        if MaterialDropdown then
            local cur = selectedMaterialItem or "All Materials"
            MaterialDropdown:Refresh(materialsList, true)
            pcall(function() MaterialDropdown:Set(cur) end)
        end
    end

    if #newFoodList ~= #foodList then
        foodList = newFoodList
        if FoodDropdown then
            local cur = selectedFoodItem or "All Foods"
            FoodDropdown:Refresh(foodList, true)
            pcall(function() FoodDropdown:Set(cur) end)
        end
    end
end

-- ==========================================
-- ★ ウィンドウ & タブ UI 構築 (完全直結化) ★
-- ==========================================
if not isLobby then
    local CombatTab = Window:MakeTab({Name = "Combat", Icon = "hand-fist", Group = "Main", PremiumOnly = false})
    local InvincibilityTab = Window:MakeTab({Name = "Invincibility", Icon = "shield", Group = "Main", PremiumOnly = false})
    local PlayerTab = Window:MakeTab({Name = "Player", Icon = "user", Group = "Main", PremiumOnly = false})
    
    -- ★ 1. ESP タブ構築 ★
    ESPTab = Window:MakeTab({Name = "ESP", Icon = "eye", Group = "Main", PremiumOnly = false})
    
    ESPTab:AddSection({
        Name = getGradientText("ESP General Settings", emeraldGreen, shinySilver)
    })

    ESPTab:AddSlider({
        Name = "Max ESP Distance",
        Min = 50,
        Max = 3000,
        Default = 500,
        Color = emeraldGreen,
        Increment = 50,
        ValueName = "m",
        Callback = function(Value)
            MaxESPDistance = Value
        end
    })

    ESPTab:AddSection({
        Name = getGradientText("Player ESP", emeraldGreen, shinySilver)
    })

    ESPTab:AddToggle({
        Name = "Enable Player ESP",
        Default = false,
        Callback = function(Value)
            ESP_PlayerEnabled = Value
            ShowToggleNotification("Player ESP", Value)
            if not Value then clearPlayerESP() end
        end
    })

    PlayerDropdown = ESPTab:AddDropdown({
        Name = "Filter Target Player",
        Default = "All Players",
        Options = playersList,
        Callback = function(Value)
            selectedPlayerItem = Value
            ShowNotification("Player Filter", "Selected: " .. tostring(Value), NotificationSettings.CheckImage)
        end
    })

    ESPTab:AddSection({
        Name = getGradientText("Chests ESP", emeraldGreen, shinySilver)
    })

    ESPTab:AddToggle({
        Name = "Enable Chests ESP",
        Default = false,
        Callback = function(Value)
            ESP_ChestsEnabled = Value
            ShowToggleNotification("Chests ESP", Value)
            if not Value then clearChestsESP() end
        end
    })

    ChestDropdown = ESPTab:AddDropdown({
        Name = "Filter Target Chest",
        Default = "All Chests",
        Options = chestsList,
        Callback = function(Value)
            selectedChestItem = Value
            ShowNotification("Chest Filter", "Selected: " .. tostring(Value), NotificationSettings.CheckImage)
        end
    })

    ESPTab:AddSection({
        Name = getGradientText("Islands ESP", emeraldGreen, shinySilver)
    })

    ESPTab:AddToggle({
        Name = "Enable Islands ESP",
        Default = false,
        Callback = function(Value)
            ESP_IslandsEnabled = Value
            ShowToggleNotification("Islands ESP", Value)
            if not Value then clearIslandsESP() end
        end
    })

    IslandDropdown = ESPTab:AddDropdown({
        Name = "Filter Target Island",
        Default = "All Islands",
        Options = islandsList,
        Callback = function(Value)
            selectedIslandItem = Value
            ShowNotification("Island Filter", "Selected: " .. tostring(Value), NotificationSettings.CheckImage)
        end
    })

    ESPTab:AddSection({
        Name = getGradientText("Creatures ESP", emeraldGreen, shinySilver)
    })

    ESPTab:AddToggle({
        Name = "Enable Creatures ESP",
        Default = false,
        Callback = function(Value)
            ESP_CreaturesEnabled = Value
            ShowToggleNotification("Creatures ESP", Value)
            if not Value then clearCreaturesESP() end
        end
    })

    CreatureDropdown = ESPTab:AddDropdown({
        Name = "Filter Target Creature",
        Default = "All Creatures",
        Options = creaturesList,
        Callback = function(Value)
            selectedCreatureItem = Value
            ShowNotification("Creature Filter", "Selected: " .. tostring(Value), NotificationSettings.CheckImage)
        end
    })

    ESPTab:AddSection({
        Name = getGradientText("Debris & Materials ESP", emeraldGreen, shinySilver)
    })

    ESPTab:AddToggle({
        Name = "Enable Materials ESP",
        Default = false,
        Callback = function(Value)
            ESP_MaterialsEnabled = Value
            ShowToggleNotification("Materials ESP", Value)
            if not Value and not ESP_FoodEnabled then clearDebrisESP() end
        end
    })

    MaterialDropdown = ESPTab:AddDropdown({
        Name = "Filter Material Item",
        Default = "All Materials",
        Options = materialsList,
        Callback = function(Value)
            selectedMaterialItem = Value
            ShowNotification("Material Filter", "Selected: " .. tostring(Value), NotificationSettings.CheckImage)
        end
    })

    ESPTab:AddSection({
        Name = getGradientText("Food & Consumables ESP", emeraldGreen, shinySilver)
    })

    ESPTab:AddToggle({
        Name = "Enable Food ESP",
        Default = false,
        Callback = function(Value)
            ESP_FoodEnabled = Value
            ShowToggleNotification("Food ESP", Value)
            if not Value and not ESP_MaterialsEnabled then clearDebrisESP() end
        end
    })

    FoodDropdown = ESPTab:AddDropdown({
        Name = "Filter Food Item",
        Default = "All Foods",
        Options = foodList,
        Callback = function(Value)
            selectedFoodItem = Value
            ShowNotification("Food Filter", "Selected: " .. tostring(Value), NotificationSettings.CheckImage)
        end
    })

    local TeleportTab = Window:MakeTab({Name = "Teleport", Icon = "footprints", Group = "Main", PremiumOnly = false})
    local ObjectTab = Window:MakeTab({Name = "Objects", Icon = "rbxassetid://105880397565283", Group = "Main", PremiumOnly = false})
    local KeybindsTab = Window:MakeTab({Name = "Keybinds", Icon = "keyboard", Group = "Main", PremiumOnly = false})

    -- ★ 2. Automation タブ構築 ★
    AutoTab = Window:MakeTab({Name = "Automation", Icon = "infinity", Group = "Main", PremiumOnly = false})

    AutoTab:AddSection({
        Name = getGradientText("Item Auto Collection", emeraldGreen, shinySilver)
    })

    AutoTab:AddToggle({
        Name = "Auto Collect Debris / Items",
        Default = false,
        Callback = function(Value)
            AutoCollectItemsEnabled = Value
            ShowToggleNotification("Auto Collect Items", Value)
        end
    })

    AutoTab:AddToggle({
        Name = "Auto Collect Chests",
        Default = false,
        Callback = function(Value)
            AutoCollectChestsEnabled = Value
            ShowToggleNotification("Auto Collect Chests", Value)
        end
    })

    AutoTab:AddSlider({
        Name = "Collection Range",
        Min = 50,
        Max = 1000,
        Default = 200,
        Color = emeraldGreen,
        Increment = 25,
        ValueName = "m",
        Callback = function(Value)
            AutoCollectDistance = Value
        end
    })

    AutoTab:AddSection({
        Name = getGradientText("Creature Auto Farm", emeraldGreen, shinySilver)
    })

    AutoTab:AddToggle({
        Name = "Auto Farm Creatures",
        Default = false,
        Callback = function(Value)
            AutoFarmCreaturesEnabled = Value
            ShowToggleNotification("Auto Farm Creatures", Value)
        end
    })

    AutoTab:AddToggle({
        Name = "Auto Attack (Swing Tool)",
        Default = true,
        Callback = function(Value)
            AutoAttackToolEnabled = Value
        end
    })

    AutoTab:AddSlider({
        Name = "Position Behind Distance",
        Min = 2,
        Max = 10,
        Default = 4,
        Color = emeraldGreen,
        Increment = 1,
        ValueName = "studs",
        Callback = function(Value)
            AutoFarmDistanceBehind = Value
        end
    })
end

local InfoTab = Window:MakeTab({Name = "Information", Icon = "info", Group = "Others", PremiumOnly = false})

if not isLobby then
    local MiscTab = Window:MakeTab({Name = "Misc", Icon = "box", Group = "Others", PremiumOnly = false})
    
    -- ★ 3. Settings タブ構築 ★
    ConfigTab = Window:MakeTab({Name = "Settings", Icon = "settings", Group = "Others", PremiumOnly = false})

    ConfigTab:AddSection({
        Name = getGradientText("Notification Settings", emeraldGreen, shinySilver)
    })

    ConfigTab:AddToggle({
        Name = "Enable Notifications",
        Default = true,
        Callback = function(Value)
            NotificationsEnabled = Value
            if Value then
                Notify("Notifications", "Notifications are now ENABLED", "Yes")
            end
        end
    })

    ConfigTab:AddSlider({
        Name = "Notification Duration",
        Min = 1,
        Max = 10,
        Default = 4,
        Color = emeraldGreen,
        Increment = 1,
        ValueName = "sec",
        Callback = function(Value)
            NotificationSettings.Time = Value
        end
    })

    ConfigTab:AddSlider({
        Name = "Notification Volume",
        Min = 0,
        Max = 1,
        Default = 1,
        Color = emeraldGreen,
        Increment = 0.1,
        ValueName = "Vol",
        Callback = function(Value)
            NotificationSettings.Volume = Value
        end
    })

    local PremiumInfoTab = Window:MakeTab({Name = "Premium Info", Icon = "crown", Group = "Others", PremiumOnly = false})
    local CreditsTab = Window:MakeTab({Name = "Credits", Icon = "user-round-check", Group = "Others", PremiumOnly = false})
end

-- ★ 1. 自動回収（Auto Collect）実行ロジック ★
task.spawn(function()
    while task.wait(0.1) do
        if AutoCollectItemsEnabled or AutoCollectChestsEnabled then
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local targetCF = rootPart.CFrame * CFrame.new(0, 0, -3)

                if AutoCollectItemsEnabled then
                    local debrisFolder = workspace:FindFirstChild("DebrisField")
                    if debrisFolder then
                        for _, model in ipairs(debrisFolder:GetChildren()) do
                            local primaryPart = model:IsA("Model") and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or (model:IsA("BasePart") and model)
                            if primaryPart then
                                local dist = (rootPart.Position - primaryPart.Position).Magnitude
                                if dist <= AutoCollectDistance then
                                    for _, prompt in ipairs(model:GetDescendants()) do
                                        if prompt:IsA("ProximityPrompt") then
                                            pcall(function() fireproximityprompt(prompt) end)
                                        end
                                    end
                                    pcall(function()
                                        if model:IsA("Model") then
                                            model:PivotTo(targetCF)
                                        elseif model:IsA("BasePart") then
                                            model.CFrame = targetCF
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end

                if AutoCollectChestsEnabled then
                    local chestsFolder = workspace:FindFirstChild("Chests")
                    if chestsFolder then
                        for _, model in ipairs(chestsFolder:GetChildren()) do
                            local primaryPart = model:IsA("Model") and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or (model:IsA("BasePart") and model)
                            if primaryPart then
                                local dist = (rootPart.Position - primaryPart.Position).Magnitude
                                if dist <= AutoCollectDistance then
                                    for _, prompt in ipairs(model:GetDescendants()) do
                                        if prompt:IsA("ProximityPrompt") then
                                            pcall(function() fireproximityprompt(prompt) end)
                                        end
                                    end
                                    pcall(function()
                                        if model:IsA("Model") then
                                            model:PivotTo(targetCF)
                                        elseif model:IsA("BasePart") then
                                            model.CFrame = targetCF
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ★ 2. クリーチャー自動ファーム（Auto Farm）実行ロジック ★
task.spawn(function()
    while task.wait(0.05) do
        if AutoFarmCreaturesEnabled then
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            local myHumanoid = character and character:FindFirstChildOfClass("Humanoid")

            if rootPart and myHumanoid and myHumanoid.Health > 0 then
                local creaturesFolder = workspace:FindFirstChild("CreatureContainer")
                if creaturesFolder then
                    local closestCreature = nil
                    local shortestDist = math.huge

                    for _, model in ipairs(creaturesFolder:GetChildren()) do
                        local hum = model:FindFirstChildOfClass("Humanoid")
                        local enemyRoot = model:IsA("Model") and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or (model:IsA("BasePart") and model)
                        
                        if enemyRoot and hum and hum.Health > 0 then
                            local dist = (rootPart.Position - enemyRoot.Position).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                closestCreature = {
                                    Model = model,
                                    Root = enemyRoot,
                                    Humanoid = hum
                                }
                            end
                        end
                    end

                    if closestCreature then
                        local enemyCF = closestCreature.Root.CFrame
                        local targetPos = enemyCF * CFrame.new(0, 0, AutoFarmDistanceBehind)
                        rootPart.CFrame = targetPos

                        if AutoAttackToolEnabled then
                            local tool = character:FindFirstChildOfClass("Tool")
                            if not tool then
                                local backpackTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                                if backpackTool then
                                    myHumanoid:EquipTool(backpackTool)
                                    tool = backpackTool
                                end
                            end

                            if tool then
                                pcall(function() tool:Activate() end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- バックグラウンド全自動スキャン (5秒間隔)
task.spawn(function()
    while task.wait(5) do
        scanAndRefreshDropdowns()
    end
end)

-- ★ 超高速・60FPS固定 ESPリアルタイム描画ループ ★
task.spawn(function()
    while task.wait(0.2) do
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if rootPart then
            local myPos = rootPart.Position

            -- 1. Player ESP 更新
            if ESP_PlayerEnabled then
                for _, plr in ipairs(service.Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        if not PlayerESPContainer[plr] or not PlayerESPContainer[plr].Highlight.Parent then
                            createPlayerESP(plr)
                        end

                        local espData = PlayerESPContainer[plr]
                        if espData and espData.Root and espData.Humanoid then
                            local dist = math.round((myPos - espData.Root.Position).Magnitude)
                            local isVisible = (dist <= MaxESPDistance) and (selectedPlayerItem == "All Players" or selectedPlayerItem == espData.DisplayName)
                            
                            if isVisible then
                                local hpPct = math.round((espData.Humanoid.Health / math.max(1, espData.Humanoid.MaxHealth)) * 100)
                                local newText = string.format("%s [%dm] [%d%%]", espData.DisplayName, dist, hpPct)
                                updateESPLabel(espData, newText, true)
                            else
                                updateESPLabel(espData, "", false)
                            end
                        end
                    end
                end
            else
                if next(PlayerESPContainer) then clearPlayerESP() end
            end

            -- 2. Chests ESP 更新
            if ESP_ChestsEnabled then
                local chestsFolder = workspace:FindFirstChild("Chests")
                if chestsFolder then
                    for _, model in ipairs(chestsFolder:GetChildren()) do
                        if not ChestsESPContainer[model] then
                            createChestESP(model)
                        end

                        local espData = ChestsESPContainer[model]
                        if espData and espData.Part then
                            local dist = math.round((myPos - espData.Part.Position).Magnitude)
                            local isVisible = (dist <= MaxESPDistance) and (selectedChestItem == "All Chests" or selectedChestItem == espData.DisplayName)
                            
                            if isVisible then
                                local newText = string.format("%s [%dm]", espData.DisplayName, dist)
                                updateESPLabel(espData, newText, true)
                            else
                                updateESPLabel(espData, "", false)
                            end
                        end
                    end
                end
            else
                if next(ChestsESPContainer) then clearChestsESP() end
            end

            -- 3. Islands ESP 更新
            if ESP_IslandsEnabled then
                local islandsFolder = workspace:FindFirstChild("IslandContainer")
                if islandsFolder then
                    for _, model in ipairs(islandsFolder:GetChildren()) do
                        if not IslandsESPContainer[model] then
                            createIslandESP(model)
                        end

                        local espData = IslandsESPContainer[model]
                        if espData and espData.Part then
                            local dist = math.round((myPos - espData.Part.Position).Magnitude)
                            local isVisible = (dist <= MaxESPDistance) and (selectedIslandItem == "All Islands" or selectedIslandItem == espData.DisplayName)
                            
                            if isVisible then
                                local newText = string.format("%s [%dm]", espData.DisplayName, dist)
                                updateESPLabel(espData, newText, true)
                            else
                                updateESPLabel(espData, "", false)
                            end
                        end
                    end
                end
            else
                if next(IslandsESPContainer) then clearIslandsESP() end
            end

            -- 4. Creatures ESP 更新
            if ESP_CreaturesEnabled then
                local creaturesFolder = workspace:FindFirstChild("CreatureContainer")
                if creaturesFolder then
                    for _, model in ipairs(creaturesFolder:GetChildren()) do
                        if not CreaturesESPContainer[model] then
                            createCreatureESP(model)
                        end

                        local espData = CreaturesESPContainer[model]
                        if espData and espData.Part then
                            local dist = math.round((myPos - espData.Part.Position).Magnitude)
                            local isVisible = (dist <= MaxESPDistance) and (selectedCreatureItem == "All Creatures" or selectedCreatureItem == espData.DisplayName)
                            
                            if isVisible then
                                local newText
                                if espData.Humanoid then
                                    local hpPct = math.round((espData.Humanoid.Health / math.max(1, espData.Humanoid.MaxHealth)) * 100)
                                    newText = string.format("%s [%dm] [%d%%]", espData.DisplayName, dist, hpPct)
                                else
                                    newText = string.format("%s [%dm]", espData.DisplayName, dist)
                                end
                                updateESPLabel(espData, newText, true)
                            else
                                updateESPLabel(espData, "", false)
                            end
                        end
                    end
                end
            else
                if next(CreaturesESPContainer) then clearCreaturesESP() end
            end

            -- 5. Debris & Food ESP 更新
            if ESP_MaterialsEnabled or ESP_FoodEnabled then
                local debrisFolder = workspace:FindFirstChild("DebrisField")
                if debrisFolder then
                    for _, model in ipairs(debrisFolder:GetChildren()) do
                        if not DebrisESPContainer[model] then
                            createDebrisESP(model)
                        end
                        
                        local espData = DebrisESPContainer[model]
                        if espData and espData.Part then
                            local dist = math.round((myPos - espData.Part.Position).Magnitude)
                            local isVisible = false

                            if dist <= MaxESPDistance then
                                if espData.IsFood then
                                    if ESP_FoodEnabled then
                                        isVisible = (selectedFoodItem == "All Foods" or selectedFoodItem == espData.DisplayName)
                                    end
                                else
                                    if ESP_MaterialsEnabled then
                                        isVisible = (selectedMaterialItem == "All Materials" or selectedMaterialItem == espData.DisplayName)
                                    end
                                end
                            end

                            if isVisible then
                                local newText = string.format("%s [%dm]", espData.DisplayName, dist)
                                updateESPLabel(espData, newText, true)
                            else
                                updateESPLabel(espData, "", false)
                            end
                        end
                    end
                end
            else
                if next(DebrisESPContainer) then clearDebrisESP() end
            end
        end
    end
end)

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

-- ゲーム名読み込み初期表記
local gameName = "Fetching Game Info..."
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
        Notify("ShiftLock Notice", "ShiftLock is enabled in this server. RightShift keybind may be affected.", "Check")
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

local StatsParagraph = InfoTab:AddParagraph(getGradientText("Live Metrics", emeraldGreen, shinySilver), "Calculating Session Metrics...")

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

-- UIアニメーション装飾処理
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
        if desc:IsA("TextLabel") and desc.Text ~= "..." then
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
