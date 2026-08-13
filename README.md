# Orion ライブラリ 
このドキュメントは、Orion ライブラリの安定リリースに関するものです。

## ライブラリの起動
```lua
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
```



## ウィンドウの作成
```lua
local Window = OrionLib:MakeWindow({Name = "Title of the library", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

--[[
Name = <string> - The name of the UI.
HidePremium = <bool> - Whether or not the user details shows Premium status or not.
SaveConfig = <bool> - Toggles the config saving in the UI.
ConfigFolder = <string> - The name of the folder where the configs are saved.
IntroEnabled = <bool> - Whether or not to show the intro animation.
IntroText = <string> - Text to show in the intro animation.
IntroIcon = <string> - URL to the image you want to use in the intro animation.
Icon = <string> - URL to the image you want displayed on the window.
CloseCallback = <function> - Function to execute when the window is closed.
]]
```

## タブの作成
```lua
local Tab = Window:MakeTab({
	Name = "Tab 1",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

--[[
Name = <string> - The name of the tab.
Icon = <string> - The icon of the tab.
PremiumOnly = <bool> - Makes the tab accessible to Sirus Premium users only.
]]
```

## セクションの作成
```lua
local Section = Tab:AddSection({
	Name = "Section"
})

--[[
Name = <string> - The name of the section.
]]
```
通常タブに要素を追加するのと同じ方法で、セクションに要素を追加できます。

## ユーザーへの通知
```lua
OrionLib:MakeNotification({
	Name = "Title!",
	Content = "Notification content... what will it say??",
	Image = "rbxassetid://4483345998",
	Time = 5
})

--[[
Title = <string> - The title of the notification.(`lua
Content = <string> - The content of the notification.
Image = <string> - The icon of the notification.
Time = <number> - The duration of the notfication.
]]
```
## ユーザーへの通知はたくさんの種類があります。
```lua
task.wait(2)
OrionLib:MakeNotification({
    Name = "ようこそ",
    Content = "スクリプトが正常に読み込まれました",
    Image = "rbxassetid://4384403532",
    Time = 5
})
task.wait(2)
-- 成功通知（緑色）
OrionLib:MakeNotification({
    Name = "成功",
    Content = "アイテムが正常に追加されました",
    Image = "rbxassetid://4384403532",
    Time = 3,
    AccentColor = Color3.fromRGB(0, 255, 100),
    AnimationStyle = "Bounce"
})
task.wait(2)
-- エラー通知（赤色・振動付き）
OrionLib:MakeNotification({
    Name = "エラー",
    Content = "接続に失敗しました。もう一度お試しください。",
    Image = "rbxassetid://4384403532",
    Time = 5,
    AccentColor = Color3.fromRGB(255, 50, 50),
    ShakeIntensity = 5,
    AnimationStyle = "Elastic"
})
task.wait(2)
-- 警告通知（黄色）
OrionLib:MakeNotification({
    Name = "警告",
    Content = "この操作は元に戻せません",
    Image = "rbxassetid://4384403532",
    Time = 4,
    AccentColor = Color3.fromRGB(255, 200, 0),
    BorderAnimation = true
})
task.wait(2)
-- 情報通知（青色・ガラスモーフィズム）
OrionLib:MakeNotification({
    Name = "情報",
    Content = "新しいアップデートが利用可能です",
    Image = "rbxassetid://4384403532",
    Time = 6,
    AccentColor = Color3.fromRGB(100, 150, 255),
    Glassmorphism = true,
    FluidMotion = true
})
task.wait(2)
-- ホログラフィック通知（虹色効果）
OrionLib:MakeNotification({
    Name = "プレミアム機能",
    Content = "プレミアム機能がアンロックされました！",
    Image = "rbxassetid://4384403532",
    Time = 8,
    Holographic = true,
    ParticleStyle = "Rainbow",
    ParticleCount = 25,
    GlowIntensity = 1,
    IconAnimation = "Spin",
    BorderAnimation = true
})
task.wait(2)
-- レベルアップ通知（星パーティクル）
OrionLib:MakeNotification({
    Name = "レベルアップ！",
    Content = "レベル50に到達しました",
    Image = "rbxassetid://4384403532",
    Time = 7,
    AccentColor = Color3.fromRGB(255, 215, 0),
    ParticleStyle = "Star",
    ParticleCount = 30,
    AnimationStyle = "Bounce",
    GlowIntensity = 0.8,
    IconAnimation = "Elastic"
})
task.wait(2)
-- ハート通知（ピンク色）
OrionLib:MakeNotification({
    Name = "いいね！",
    Content = "フレンドリクエストが承認されました",
    Image = "rbxassetid://4384403532",
    Time = 5,
    AccentColor = Color3.fromRGB(255, 100, 150),
    ParticleStyle = "Heart",
    ParticleCount = 20,
    AnimationStyle = "Spring",
    SpringEffect = true
})
task.wait(2)
-- グラデーション通知
OrionLib:MakeNotification({
    Name = "特別なイベント",
    Content = "限定イベントが開始されました！",
    Image = "rbxassetid://4384403532",
    Time = 10,
    GradientEnabled = true,
    GradientColors = {
        Color3.fromRGB(138, 43, 226),
        Color3.fromRGB(75, 0, 130),
        Color3.fromRGB(138, 43, 226)
    },
    ParticleStyle = "Rainbow",
    ParticleCount = 15,
    BorderAnimation = true
})
task.wait(2)
-- ネオモーフィズム通知
OrionLib:MakeNotification({
    Name = "モダンデザイン",
    Content = "これはネオモーフィズムスタイルの通知です",
    Image = "rbxassetid://4384403532",
    Time = 6,
    Neomorphism = true,
    AccentColor = Color3.fromRGB(150, 150, 150),
    FluidMotion = true
})
task.wait(2)
-- パルス効果通知
OrionLib:MakeNotification({
    Name = "重要な通知",
    Content = "すぐに行動が必要です",
    Image = "rbxassetid://4384403532",
    Time = 8,
    AccentColor = Color3.fromRGB(255, 0, 0),
    PulseEffect = true,
    BorderAnimation = true,
    GlowIntensity = 0.7
})
task.wait(2)
-- テキストシャドウ付き通知
OrionLib:MakeNotification({
    Name = "読みやすい通知",
    Content = "テキストに影がついて読みやすくなっています",
    Image = "rbxassetid://4384403532",
    Time = 5,
    TextShadow = true,
    AccentColor = Color3.fromRGB(100, 200, 255)
})
task.wait(2)
-- 上からスライドイン
OrionLib:MakeNotification({
    Name = "上から登場",
    Content = "この通知は上からスライドインします",
    Image = "rbxassetid://4384403532",
    Time = 5,
    Position = "TopRight",
    SlideDirection = "Down",
    AccentColor = Color3.fromRGB(0, 255, 150)
})
task.wait(2)
-- 左からスライドイン
OrionLib:MakeNotification({
    Name = "左から登場",
    Content = "この通知は左からスライドインします",
    Image = "rbxassetid://4384403532",
    Time = 5,
    Position = "BottomLeft",
    SlideDirection = "Left",
    AccentColor = Color3.fromRGB(255, 150, 0)
})
task.wait(2)
-- 中央配置の通知
OrionLib:MakeNotification({
    Name = "中央通知",
    Content = "画面中央に表示される重要なメッセージ",
    Image = "rbxassetid://4384403532",
    Time = 6,
    Position = "MiddleCenter",
    AccentColor = Color3.fromRGB(255, 0, 255),
    GlowIntensity = 1,
    ScaleEffect = 1.1
})
task.wait(2)
-- 波効果付き通知
OrionLib:MakeNotification({
    Name = "波動効果",
    Content = "タイマーバーに波のような効果があります",
    Image = "rbxassetid://4384403532",
    Time = 7,
    WaveEffect = true,
    AccentColor = Color3.fromRGB(0, 200, 255),
    FluidMotion = true
})
task.wait(2)
-- グリッチ効果通知
OrionLib:MakeNotification({
    Name = "グリッチ",
    Content = "サイバーパンクスタイルの通知",
    Image = "rbxassetid://4384403532",
    Time = 5,
    GlitchEffect = true,
    AccentColor = Color3.fromRGB(0, 255, 0)
})
task.wait(2)
-- 回転効果付き通知
OrionLib:MakeNotification({
    Name = "回転登場",
    Content = "回転しながら登場・退場します",
    Image = "rbxassetid://4384403532",
    Time = 6,
    RotationEffect = true,
    AccentColor = Color3.fromRGB(255, 100, 255),
    AnimationStyle = "Elastic"
})
task.wait(2)
-- スケール効果通知（ホバーで拡大）
OrionLib:MakeNotification({
    Name = "インタラクティブ",
    Content = "マウスを乗せると拡大します",
    Image = "rbxassetid://4384403532",
    Time = 8,
    ScaleEffect = 1.15,
    MicroInteractions = true,
    HoverEffects = true,
    AccentColor = Color3.fromRGB(150, 100, 255)
})
task.wait(2)
-- 全部盛り通知（すべてのエフェクト）
OrionLib:MakeNotification({
    Name = "究極の通知",
    Content = "すべてのエフェクトを組み合わせた派手な通知です！",
    Image = "rbxassetid://4384403532",
    Time = 12,
    Holographic = true,
    ParticleStyle = "Rainbow",
    ParticleCount = 40,
    GlowIntensity = 1,
    BorderAnimation = true,
    IconAnimation = "Spin",
    TextShadow = true,
    FluidMotion = true,
    WaveEffect = true,
    MicroInteractions = true,
    HoverEffects = true,
    ScaleEffect = 1.2,
    AnimationStyle = "Elastic",
    BounceIntensity = 1.5
})
task.wait(2)
-- シンプルでエレガントな通知
OrionLib:MakeNotification({
    Name = "シンプル",
    Content = "装飾を抑えたシンプルで洗練された通知",
    Image = "rbxassetid://4384403532",
    Time = 4,
    Glassmorphism = true,
    AccentColor = Color3.fromRGB(200, 200, 200),
    FluidMotion = true
})
task.wait(2)
-- ダークモード通知
OrionLib:MakeNotification({
    Name = "ダークテーマ",
    Content = "ダークモードに最適化された通知",
    Image = "rbxassetid://4384403532",
    Time = 5,
    BackgroundColor = Color3.fromRGB(20, 20, 20),
    AccentColor = Color3.fromRGB(100, 150, 255),
    TextShadow = true
})
task.wait(2)
-- 長文通知
OrionLib:MakeNotification({
    Name = "詳細情報",
    Content = "この通知には長いテキストが含まれています。複数行にわたる情報を表示することができ、自動的にサイズが調整されます。重要な情報をユーザーに伝えるのに最適です。",
    Image = "rbxassetid://4384403532",
    Time = 10,
    AccentColor = Color3.fromRGB(100, 200, 150)
})
```


## ボタンの作成
```lua
Tab:AddButton({
	Name = "Button!",
	Callback = function()
      		print("button pressed")
  	end    
})

--[[
Name = <string> - The name of the button.
Callback = <function> - The function of the button.
]]
```


## チェックボックストグルの作成
```lua
Tab:AddToggle({
	Name = "This is a toggle!",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})

--[[
Name = <string> - The name of the toggle.
Default = <bool> - The default value of the toggle.
Callback = <function> - The function of the toggle.
]]
```

### 既存のトグルの値を変更する
```lua
CoolToggle:Set(true)
```



## カラーピッカーの作成
```lua
Tab:AddColorpicker({
	Name = "Colorpicker",
	Default = Color3.fromRGB(255, 0, 0),
	Callback = function(Value)
		print(Value)
	end	  
})

--[[
Name = <string> - The name of the colorpicker.
Default = <color3> - The default value of the colorpicker.
Callback = <function> - The function of the colorpicker.
]]
```

### カラーピッカーの値を設定する
```lua
ColorPicker:Set(Color3.fromRGB(255,255,255))
```


## スライダーの作成
```lua
Tab:AddSlider({
	Name = "Slider",
	Min = 0,
	Max = 20,
	Default = 5,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "bananas",
	Callback = function(Value)
		print(Value)
	end    
})

--[[
Name = <string> - The name of the slider.
Min = <number> - The minimal value of the slider.
Max = <number> - The maxium value of the slider.
Increment = <number> - How much the slider will change value when dragging.
Default = <number> - The default value of the slider.
ValueName = <string> - The text after the value number.
Callback = <function> - The function of the slider.
]]
```

### スライダーの値を変更する
```lua
Slider:Set(2)
```
これが機能するには、スライダーを変数 (local CoolSlider = Tab:AddSlider...) にしてください。


## ラベルの作成
```lua
Tab:AddLabel("Label")
```

### 既存のラベルの値を変更する
```lua
CoolLabel:Set("Label New!")
```


## 段落の作成
```lua
Tab:AddParagraph("Paragraph","Paragraph Content")
```

### 既存の段落を変更する
```lua
CoolParagraph:Set("Paragraph New!", "New Paragraph Content!")
```


## PlayerParagraph の作成
```lua
local PlayerParagraph = Tab:AddPlayerParagraph(123456789) -- UserIdを指定
```
## ImageParagraph の作成
```lua
local ItemInfo = Tab:AddImageParagraph(
    "rbxassetid://7072706796",
    "伝説の剣: 攻撃力+50、クリティカル率+20%"
)

-- URLの画像を使用
local WebImage = Tab:AddImageParagraph(
    "https://example.com/image.png",
    "Web上の画像も表示できます"
)
```

## 適応型入力の作成
```lua
Tab:AddTextbox({
	Name = "Textbox",
	Default = "default box input",
	TextDisappear = true,
	Callback = function(Value)
		print(Value)
	end	  
})

--[[
Name = <string> - The name of the textbox.
Default = <string> - The default value of the textbox.
TextDisappear = <bool> - Makes the text disappear in the textbox after losing focus.
Callback = <function> - The function of the textbox.
]]
```


## キーバインドの作成
```lua
Tab:AddBind({
	Name = "Bind",
	Default = Enum.KeyCode.E,
	Hold = false,
	Callback = function()
		print("press")
	end    
})

--[[
Name = <string> - The name of the bind.
Default = <keycode> - The default value of the bind.
Hold = <bool> - Makes the bind work like: Holding the key > The bind returns true, Not holding the key > Bind returns false.
Callback = <function> - The function of the bind.
]]
```

### バインドの値を変更する
```lua
Bind:Set(Enum.KeyCode.E)
```


## ドロップダウンメニューの作成
```lua
Tab:AddDropdown({
	Name = "Dropdown",
	Default = "1",
	Options = {"1", "2"},
	Callback = function(Value)
		print(Value)
	end    
})

--[[
Name = <string> - The name of the dropdown.
Default = <string> - The default value of the dropdown.
Options = <table> - The options in the dropdown.
Callback = <function> - The function of the dropdown.
]]
```
## PlayerDropdown メニューの作成
```lua
local PlayerDropdown = Tab:AddPlayersDropdown({
    Name = "プレイヤーを選択",
    MultipleSelection = true, -- 複数選択可能
    SearchEnabled = true, -- 検索機能を有効化
    ShowPlayerCount = true, -- プレイヤー数を表示
    ShowAvatars = true, -- アバター画像を表示
    SortPlayers = true, -- プレイヤーを名前順にソート
    Callback = function(SelectedPlayers)
        if type(SelectedPlayers) == "table" then
            print("選択されたプレイヤー:", table.concat(SelectedPlayers, ", "))
        else
            print("選択されたプレイヤー:", SelectedPlayers)
        end
    end,
    Flag = "SelectedPlayers",
    Save = false
})
```
### 既存のメニューに新しいドロップダウンボタンのセットを追加する
```lua
Dropdown:Refresh(List<table>,true)
```

上記のブール値「true」は、現在のボタンが削除されるかどうかを示します。
### ドロップダウンオプションの選択
```lua
Dropdown:Set("dropdown option")
```

# スクリプトの完成（必須）
以下の関数をコードの最後に追加する必要があります。
```lua
OrionLib:Init()
```

### フラグの動作方法。
UIのフラグ機能は、一部の方にとって分かりにくいかもしれません。これは設定ファイル内の要素のIDとして機能し、コード内のどこからでも要素の値にアクセスできるようにします。以下はフラグの使用例です。
```lua
Tab1:AddToggle({
    Name = "Toggle",
    Default = true,
    Save = true,
    Flag = "toggle"
})

print(OrionLib.Flags["toggle"].Value) -- prints the value of the toggle.
```
フラグは、トグル、スライダー、ドロップダウン、バインド、カラーピッカーでのみ機能します。

### インターフェースをconfigsで動作させる。インターフェースでconfigs関数を使用するには、まずウィンドウ関数に`SaveConfig`と`ConfigFolder`引数を追加する必要があります。これらの引数の説明は上記にあります。次に、configファイルに含めたいすべてのトグル、スライダー、ドロップダウン、バインド、カラーピッカーに`Flag`と`Save`の値を追加する必要があります。`Flag =<string> `引数は設定ファイル内の要素のIDです。`Save =<bool> ` 引数には設定ファイル内の要素が含まれます。設定ファイルは、ライブラリが起動されるゲームごとに作成されます。

## インターフェースの破壊
```lua
OrionLib:Destroy()
```
