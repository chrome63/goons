
local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local SoundService: SoundService = cloneref(game:GetService("SoundService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local Teams: Teams = cloneref(game:GetService("Teams"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local getgenv = getgenv or function()
    return shared
end
local setclipboard = setclipboard or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}
local Tooltips = {}

local BaseURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    TransparencyTexture = {
        RobloxId = 139785960036434,
        Path = "Obsidian/assets/TransparencyTexture.png",
        URL = BaseURL .. "assets/TransparencyTexture.png",

        Id = nil,
    },

    SaturationMap = {
        RobloxId = 4155801252,
        Path = "Obsidian/assets/SaturationMap.png",
        URL = BaseURL .. "assets/SaturationMap.png",

        Id = nil,
    },

    LoadingIcon = {
        RobloxId = 97544096941083,
        Path = "Obsidian/assets/LoadingIcon.png",
        URL = BaseURL .. "assets/LoadingIcon.png",

        Id = nil,
    },

    CheckIcon = {
        RobloxId = 97682394690683,
        Path = "Obsidian/assets/CheckIcon.png",
        URL = BaseURL .. "assets/CheckIcon.png",

        Id = nil,
    },
}
do
    local function RecursiveCreatePath(Path: string, IsFile: boolean?)
        if not isfolder or not makefolder then
            return
        end

        local Segments = Path:split("/")
        local TraversedPath = ""

        if IsFile then
            table.remove(Segments, #Segments)
        end

        for _, Segment in ipairs(Segments) do
            if not isfolder(TraversedPath .. Segment) then
                makefolder(TraversedPath .. Segment)
            end

            TraversedPath = TraversedPath .. Segment .. "/"
        end

        return TraversedPath
    end

    function CustomImageManager.AddAsset(
        AssetName: string,
        RobloxAssetId: number,
        URL: string,
        ForceRedownload: boolean?
    )
        if CustomImageManagerAssets[AssetName] ~= nil then
            error(string.format("Asset %q already exists", AssetName))
        end

        assert(typeof(RobloxAssetId) == "number", "RobloxAssetId must be a number")

        CustomImageManagerAssets[AssetName] = {
            RobloxId = RobloxAssetId,
            Path = string.format("Obsidian/custom_assets/%s", AssetName),
            URL = URL,

            Id = nil,
        }

        CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
    end

    function CustomImageManager.GetAsset(AssetName: string)
        if not CustomImageManagerAssets[AssetName] then
            return nil
        end

        local AssetData =
            CustomImageManagerAssets[
                AssetName
            ]

        if AssetData.Id then
            return AssetData.Id
        end

        local RobloxAssetId =
            tonumber(
                AssetData.RobloxId
            )
            or 0

        local AssetID = ""

        if RobloxAssetId > 0 then

            AssetID =
                string.format(
                    "rbxassetid://%s",
                    RobloxAssetId
                )

        elseif getcustomasset then

            local Success,
                NewID =
                pcall(
                    getcustomasset,
                    AssetData.Path
                )

            if Success == true
            and type(NewID) == "string"
            and NewID ~= "" then

                AssetID =
                    NewID
            end
        end

        AssetData.Id =
            AssetID

        return AssetID
    end

    function CustomImageManager.DownloadAsset(AssetName: string, ForceRedownload: boolean?)
        if not getcustomasset or not writefile or not isfile then
            return false, "missing functions"
        end

        local AssetData = CustomImageManagerAssets[AssetName]

        RecursiveCreatePath(AssetData.Path, true)

        if ForceRedownload ~= true and isfile(AssetData.Path) then
            return true, nil
        end

        local success, errorMessage = pcall(function()
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)

        return success, errorMessage
    end

    for AssetName, _ in CustomImageManagerAssets do
        CustomImageManager.DownloadAsset(AssetName)
    end
end

local Library = {
    LocalPlayer = LocalPlayer,
    DevicePlatform = nil,
    IsMobile = false,
    IsRobloxFocused = true,

    ScreenGui = nil,

    SearchText = "",
    Searching = false,
    GlobalSearch = false,
    LastSearchTab = nil,

    ActiveTab = nil,
    Tabs = {},
    TabButtons = {},
    DependencyBoxes = {},

    KeybindFrame = nil,
    KeybindContainer = nil,
    KeybindToggles = {},

    Notifications = {},
    Dialogues = {},
    ActiveLoading = nil,
    ActiveDialog = nil,

    Corners = {},

    ToggleKeybind = Enum.KeyCode.RightControl,
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    Toggled = false,
    Unloaded = false,

    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,

    NotifySide = "Right",
    ShowCustomCursor = true,
    ForceCheckbox = false,
    ShowToggleFrameInKeybinds = true,
    NotifyOnError = false,

    CantDragForced = false,

    -- Groupbox reorder
    -- Drag groupbox header, preview drop slot, commit order on release.
    GroupboxDragEnabled = true,
    GroupboxDragMode = "Release",
    GroupboxDragThreshold = 9,
    GroupboxDragDebug = false,
    GroupboxGhostEnabled = true,
    GroupboxDropIndicatorEnabled = true,
    GroupboxOrders = {},
    GroupboxOrderChanged = nil,
    GroupboxDragGhost = nil,
    GroupboxDropIndicator = nil,

    Signals = {},
    UnloadSignals = {},

    OriginalMinSize = Vector2.new(480, 360),
    MinSize = Vector2.new(480, 360),
    DPIScale = 1,

    CornerRadius = 14,
    CornerRadiusDropdown = true,

    SharpStyle = true,

    StrokeRegistry = {},

    SurfaceTransparencyMultipliers = {
        Window = 0.18,
        Chrome = 0.08,
        Panel = 0.06,
        Groupbox = 0.03,
        Control = 0.02,
        Overlay = 0.01,
    },

    IsLightTheme = false,
    ThemeName = "HOLY Red",

    InterfaceTransparency = 0,
    SurfaceRegistry = {},

    Animations = {
        ToggleWindow = false,
        TabSwitch = true,
        Groupbox = false,
        Dropdown = false,
        KeyPicker = false,
    },

    TabTransitionTime = 0.16,
    TabSwipeOffset = 12,
    TabSwipeFrom = "bottom",

    Scheme = {
        BackgroundColor =
            Color3.fromRGB(
                3,
                4,
                6
            ),

        MainColor =
            Color3.fromRGB(
                10,
                12,
                16
            ),

        AccentColor =
            Color3.fromRGB(
                238,
                43,
                68
            ),

        OutlineColor =
            Color3.fromRGB(
                28,
                31,
                38
            ),

        OuterRimColor =
            Color3.fromRGB(
                0,
                0,
                0
            ),

        InnerBorderColor =
            Color3.fromRGB(
                34,
                38,
                46
            ),

        ControlBorderColor =
            Color3.fromRGB(
                31,
                35,
                43
            ),

        SeparatorColor =
            Color3.fromRGB(
                18,
                20,
                25
            ),

        FontColor =
            Color3.fromRGB(
                248,
                249,
                251
            ),

        Font =
            Font.fromEnum(
                Enum.Font.GothamMedium
            ),

        SuccessColor =
            Color3.fromRGB(
                96,
                225,
                151
            ),

        WarningColor =
            Color3.fromRGB(
                245,
                194,
                86
            ),

        MutedColor =
            Color3.fromRGB(
                166,
                171,
                182
            ),

        RedColor =
            Color3.fromRGB(
                255,
                63,
                87
            ),

        DestructiveColor =
            Color3.fromRGB(
                216,
                35,
                55
            ),

        DarkColor =
            Color3.fromRGB(
                1,
                2,
                3
            ),

        WhiteColor =
            Color3.fromRGB(
                255,
                255,
                255
            ),
    },

    Registry = {},
	Scales = {},
	ScalesOffset = {},

    ImageManager = CustomImageManager,
    ShowCursorBinding = string.sub(tostring({}), 10),
}

if RunService:IsStudio() then
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        Library.IsMobile = true
        Library.OriginalMinSize = Vector2.new(480, 240)
    else
        Library.IsMobile = false
        Library.OriginalMinSize = Vector2.new(480, 360)
    end
else
    pcall(function()
        Library.DevicePlatform = UserInputService:GetPlatform()
    end)
    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
    Library.OriginalMinSize = Library.IsMobile and Vector2.new(480, 240) or Vector2.new(480, 360)
end

local Templates = {
    --// UI \\-
    Frame = {
        BorderSizePixel = 0,
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    },
    ImageButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
    },
    ScrollingFrame = {
        BorderSizePixel = 0,
    },
    TextLabel = {
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextBox = {
        BorderSizePixel = 0,
        FontFace = "Font",
        PlaceholderColor3 = function()
            local H, S, V = Library.Scheme.FontColor:ToHSV()
            return Color3.fromHSV(H, S, V / 2)
        end,
        Text = "",
        TextColor3 = "FontColor",
    },
    UIListLayout = {
        SortOrder = Enum.SortOrder.LayoutOrder,
    },
    UIStroke = {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Round,
    },

    --// Library \\--
    Window = {
        Title = "No Title",
        Footer = "No Footer",
        Position = UDim2.fromOffset(6, 6),
    	Size = UDim2.fromOffset(780, 610),
        IconSize = UDim2.fromOffset(28, 28),
        AutoShow = true,
        Center = true,
        Resizable = true,
        SearchbarSize = UDim2.fromScale(1, 1),
        GlobalSearch = false,

        AccountPrivacyMode =
            "Hidden Until Clicked",

        Animations = {
            ToggleWindow = false,
            TabSwitch = true,
            Groupbox = false,
            Dropdown = false,
            KeyPicker = false,
        },

        TabTransitionTime = 0.16,
        TabSwipeOffset = 12,
        TabSwipeFrom = "bottom",

        CornerRadius = 14,
        NotifySide = "Right",
        ShowCustomCursor = true,
        Font = Enum.Font.GothamMedium,
        ToggleKeybind = Enum.KeyCode.RightControl,
        
        ShowMobileButtons = true,
        MobileButtonsSide = "Left",

        UnlockMouseWhileOpen = true,

        EnableSidebarResize = false,
        EnableCompacting = true,
        DisableCompactingSnap = false,
        SidebarCompacted = false,
        MinContainerWidth = 256,

        --// Snapping \\--
        MinSidebarWidth = 128,
        SidebarCompactWidth = 48,
        SidebarCollapseThreshold = 0.5,

        --// Dragging \\--
        CompactWidthActivation = 128,
    },
    Dialog = {
        Title = "Dialog",
        Description = "Description",
        AutoDismiss = true,
        OutsideClickDismiss = true,
        FooterButtons = {}
    },
    Loading = {
        Title = "mspaint",
        Icon = 95816097006870,
        IconSize = UDim2.fromOffset(30, 30),

        LoadingIcon = CustomImageManager.GetAsset("LoadingIcon"),
        LoadingIconColor = nil,
        LoadingIconTweenTime = 1,

        CurrentStep = 0,
        TotalSteps = 10,

        ShowSidebar = false,
        AutoResizeHeight = false,

        WindowWidth = 450,
        WindowHeight = 275,

        ContentWidth = 450,
        SidebarWidth = 250,
    },
    Toggle = {
        Text = "Toggle",
        Default = false,

        Callback = function() end,
        Changed = function() end,

        Risky = false,
        Disabled = false,
        Visible = true,
    },
    Input = {
        Text = "Input",
        Default = "",
        Finished = false,
        Numeric = false,
        ClearTextOnFocus = true,
        ClearTextOnBlur = false,
        Placeholder = "",
        AllowEmpty = true,
        EmptyReset = "---",

        Callback = function() end,
        Changed = function() end,
        VerifyValue = nil,

        Disabled = false,
        Visible = true,
    },
    Slider = {
        Text = "Slider",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,

        Prefix = "",
        Suffix = "",

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    Dropdown = {
        Values = {},
        DisabledValues = {},
        ValueImages = {},
        ValueMetadata = {},

        Multi = false,
        MaxVisibleDropdownItems = 8,
        Popout = nil,
        PopoutThreshold = 8,
        PickerTitle = nil,
        RichPicker = false,
        MasterValue = nil,
        MasterText = nil,
        PickerState = {},
        PickerWorlds = {},
        PickerRarities = {},
        PickerSorts = {},
        CurrentWorld = nil,
        GetLiveStock = nil,
        OnPickerStateChanged = nil,

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    Viewport = {
        Object = nil,
        Camera = nil,
        Clone = true,
        AutoFocus = true,
        Interactive = false,
        Height = 200,
        Visible = true,
    },
    Image = {
        Image = "",
        Transparency = 0,
        BackgroundTransparency = 0,
        Color = Color3.new(1, 1, 1),
        RectOffset = Vector2.zero,
        RectSize = Vector2.zero,
        ScaleType = Enum.ScaleType.Fit,
        Height = 200,
        Visible = true,
    },
    Video = {
        Video = "",
        Looped = false,
        Playing = false,
        Volume = 1,
        Height = 200,
        Visible = true,
    },
    UIPassthrough = {
        Instance = nil,
        Height = 24,
        Visible = true,
    },

    --// Addons \\-
    KeyPicker = {
        Text = "KeyPicker",

        Default = "None",
        DefaultModifiers = {},

        Blacklisted = {},
        BlacklistedModifiers = {},
        Whitelisted = {},
        WhitelistedModifiers = {},

        Mode = "Toggle",
        Modes = { "Always", "Toggle", "Hold" },
        SyncToggleState = false,

        Callback = function() end,
        ChangedCallback = function() end,
        Changed = function() end,
        Clicked = function() end,
    },
    ColorPicker = {
        Default = Color3.new(1, 1, 1),

        Callback = function() end,
        Changed = function() end,
    },
}

local Places = {
    Bottom = { 0, 1 },
    Right = { 1, 0 },
}
local Sizes = {
    Left = { 0.5, 1 },
    Right = { 0.5, 1 },
}

--// Scheme Functions \\--
local SchemeReplaceAlias = {
    RedColor = "Red",
    WhiteColor = "White",
    DarkColor = "Dark"
}

local SchemeAlias = {
    Red = "RedColor",
    White = "WhiteColor",
    Dark = "DarkColor"
}

local function GetSchemeValue(Index)
    if not Index then
        return nil
    end

    local ReplaceAliasIndex = SchemeReplaceAlias[Index]
    if ReplaceAliasIndex and Library.Scheme[ReplaceAliasIndex] ~= nil then
        Library.Scheme[Index] = Library.Scheme[ReplaceAliasIndex]
        Library.Scheme[ReplaceAliasIndex] = nil

        return Library.Scheme[Index]
    end

    local AliasIndex = SchemeAlias[Index]
    if AliasIndex and Library.Scheme[AliasIndex] ~= nil then
        warn(string.format("Scheme Value %q is deprecated, please use %q instead.", Index, AliasIndex))
        return Library.Scheme[AliasIndex]
    end

    return Library.Scheme[Index]
end

Library.ThemeOrder = {
    "HOLY Red",
    "Midnight",
    "Amethyst",
    "Emerald",
    "Arctic",
    "Graphite",
}

Library.Themes = {
    ["HOLY Red"] = {
        BackgroundColor =
            Color3.fromRGB(
                3,
                4,
                6
            ),

        MainColor =
            Color3.fromRGB(
                10,
                12,
                16
            ),

        AccentColor =
            Color3.fromRGB(
                238,
                43,
                68
            ),

        OutlineColor =
            Color3.fromRGB(
                28,
                31,
                38
            ),

        OuterRimColor =
            Color3.fromRGB(
                0,
                0,
                0
            ),

        InnerBorderColor =
            Color3.fromRGB(
                34,
                38,
                46
            ),

        ControlBorderColor =
            Color3.fromRGB(
                31,
                35,
                43
            ),

        SeparatorColor =
            Color3.fromRGB(
                18,
                20,
                25
            ),

        FontColor =
            Color3.fromRGB(
                248,
                249,
                251
            ),

        SuccessColor =
            Color3.fromRGB(
                96,
                225,
                151
            ),

        WarningColor =
            Color3.fromRGB(
                245,
                194,
                86
            ),

        MutedColor =
            Color3.fromRGB(
                166,
                171,
                182
            ),

        RedColor =
            Color3.fromRGB(
                255,
                63,
                87
            ),

        DestructiveColor =
            Color3.fromRGB(
                216,
                35,
                55
            ),

        DarkColor =
            Color3.fromRGB(
                1,
                2,
                3
            ),

        WhiteColor =
            Color3.fromRGB(
                255,
                255,
                255
            ),

        IsLight =
            false,
    },

    Midnight = {
        BackgroundColor = Color3.fromRGB(3, 7, 15),
        MainColor = Color3.fromRGB(9, 16, 29),
        AccentColor = Color3.fromRGB(74, 137, 255),
        OutlineColor = Color3.fromRGB(30, 31, 35),
        FontColor = Color3.fromRGB(239, 244, 255),

        SuccessColor = Color3.fromRGB(91, 220, 158),
        WarningColor = Color3.fromRGB(244, 194, 92),
        MutedColor = Color3.fromRGB(137, 151, 177),

        RedColor = Color3.fromRGB(255, 86, 106),
        DestructiveColor = Color3.fromRGB(211, 53, 72),
        DarkColor = Color3.fromRGB(0, 2, 8),
        WhiteColor = Color3.fromRGB(255, 255, 255),

        IsLight = false,
    },

    Amethyst = {
        BackgroundColor = Color3.fromRGB(7, 4, 13),
        MainColor = Color3.fromRGB(18, 11, 29),
        AccentColor = Color3.fromRGB(161, 92, 255),
        OutlineColor = Color3.fromRGB(30, 31, 35),
        FontColor = Color3.fromRGB(247, 241, 255),

        SuccessColor = Color3.fromRGB(104, 226, 166),
        WarningColor = Color3.fromRGB(249, 195, 103),
        MutedColor = Color3.fromRGB(158, 145, 177),

        RedColor = Color3.fromRGB(255, 83, 115),
        DestructiveColor = Color3.fromRGB(207, 51, 79),
        DarkColor = Color3.fromRGB(2, 0, 5),
        WhiteColor = Color3.fromRGB(255, 255, 255),

        IsLight = false,
    },

    Emerald = {
        BackgroundColor = Color3.fromRGB(3, 10, 8),
        MainColor = Color3.fromRGB(8, 23, 18),
        AccentColor = Color3.fromRGB(43, 203, 132),
        OutlineColor = Color3.fromRGB(30, 31, 35),
        FontColor = Color3.fromRGB(237, 252, 246),

        SuccessColor = Color3.fromRGB(73, 229, 151),
        WarningColor = Color3.fromRGB(244, 197, 92),
        MutedColor = Color3.fromRGB(133, 163, 151),

        RedColor = Color3.fromRGB(255, 82, 103),
        DestructiveColor = Color3.fromRGB(205, 49, 66),
        DarkColor = Color3.fromRGB(0, 4, 3),
        WhiteColor = Color3.fromRGB(255, 255, 255),

        IsLight = false,
    },

    Arctic = {
        BackgroundColor = Color3.fromRGB(2, 9, 13),
        MainColor = Color3.fromRGB(7, 22, 29),
        AccentColor = Color3.fromRGB(52, 205, 232),
        OutlineColor = Color3.fromRGB(30, 31, 35),
        FontColor = Color3.fromRGB(237, 251, 255),

        SuccessColor = Color3.fromRGB(90, 227, 167),
        WarningColor = Color3.fromRGB(247, 201, 103),
        MutedColor = Color3.fromRGB(133, 160, 169),

        RedColor = Color3.fromRGB(255, 84, 107),
        DestructiveColor = Color3.fromRGB(207, 52, 72),
        DarkColor = Color3.fromRGB(0, 3, 5),
        WhiteColor = Color3.fromRGB(255, 255, 255),

        IsLight = false,
    },

    Graphite = {
        BackgroundColor = Color3.fromRGB(5, 5, 6),
        MainColor = Color3.fromRGB(16, 16, 18),
        AccentColor = Color3.fromRGB(183, 188, 198),
        OutlineColor = Color3.fromRGB(30, 31, 35),
        FontColor = Color3.fromRGB(246, 246, 248),

        SuccessColor = Color3.fromRGB(104, 220, 154),
        WarningColor = Color3.fromRGB(239, 191, 93),
        MutedColor = Color3.fromRGB(145, 147, 154),

        RedColor = Color3.fromRGB(255, 76, 96),
        DestructiveColor = Color3.fromRGB(204, 47, 63),
        DarkColor = Color3.fromRGB(0, 0, 0),
        WhiteColor = Color3.fromRGB(255, 255, 255),

        IsLight = false,
    },
}

function Library:GetThemeNames()

    local output = {}

    for _, themeName in ipairs(
        Library.ThemeOrder
    ) do

        output[#output + 1] =
            themeName
    end

    return output
end

function Library:SetTheme(themeName)

    themeName =
        tostring(
            themeName
            or "HOLY Red"
        )

    if themeName == "Obsidian Red" then

        themeName =
            "HOLY Red"
    end

    local theme =
        Library.Themes[
            themeName
        ]

    if type(theme) ~= "table" then

        themeName =
            "HOLY Red"

        theme =
            Library.Themes[
                themeName
            ]
    end

    for key, value in pairs(theme) do

        if key ~= "IsLight" then

            Library.Scheme[key] =
                value
        end
    end

    Library.ThemeName =
        themeName

    Library.IsLightTheme =
        theme.IsLight == true

    if type(Library.UpdateColorsUsingRegistry) == "function" then

        Library:UpdateColorsUsingRegistry()
    end

    return themeName
end

function Library:SetAnimations(
    animations,
    transitionTime,
    swipeOffset,
    swipeFrom
)

    animations =
        type(animations) == "table"
        and animations
        or {}

    for key, currentValue in pairs(
        Library.Animations
    ) do

        if type(animations[key]) == "boolean" then

            Library.Animations[key] =
                animations[key]

        else

            Library.Animations[key] =
                currentValue
        end
    end

    if tonumber(transitionTime) then

        Library.TabTransitionTime =
            math.clamp(
                tonumber(transitionTime),
                0.05,
                0.5
            )
    end

    if tonumber(swipeOffset) then

        Library.TabSwipeOffset =
            math.clamp(
                tonumber(swipeOffset),
                0,
                50
            )
    end

    local allowedDirections = {
        left = true,
        right = true,
        top = true,
        bottom = true,
    }

    swipeFrom =
        tostring(
            swipeFrom
            or Library.TabSwipeFrom
        ):lower()

    if allowedDirections[swipeFrom] == true then

        Library.TabSwipeFrom =
            swipeFrom
    end

    return Library.Animations
end

function Library:ApplyTransparencyToSurface(instance)

    local data =
        Library.SurfaceRegistry[
            instance
        ]

    if type(data) ~= "table" then
        return false
    end

    if typeof(instance) ~= "Instance"
    or instance.Parent == nil then

        Library.SurfaceRegistry[
            instance
        ] =
            nil

        return false
    end

    local success =
        pcall(function()

            local role =
                tostring(
                    data.Role
                    or "Panel"
                )

            local multiplier =
                Library.SurfaceTransparencyMultipliers[
                    role
                ]
                or Library.SurfaceTransparencyMultipliers.Panel
                or 0.30

            if (
                tonumber(
                    instance.ZIndex
                )
                or 0
            ) >= 9000 then

                multiplier =
                    math.min(
                        multiplier,
                        Library.SurfaceTransparencyMultipliers.Overlay
                        or 0.08
                    )
            end

            local amount =
                math.clamp(
                    tonumber(
                        Library.InterfaceTransparency
                    )
                    or 0,
                    0,
                    70
                )
                / 100

            local baseTransparency =
                math.clamp(
                    tonumber(
                        data.BaseTransparency
                    )
                    or 0,
                    0,
                    1
                )

            local appliedAmount =
                amount
                * multiplier

            instance.BackgroundTransparency =
                1
                - (
                    (
                        1
                        - baseTransparency
                    )
                    * (
                        1
                        - appliedAmount
                    )
                )
        end)

    return success
end

function Library:RegisterSurface(
    instance,
    role,
    baseTransparency
)

    if typeof(instance) ~= "Instance"
    or instance:IsA("GuiObject") ~= true then

        return false
    end

    Library.SurfaceRegistry[instance] = {
        Role =
            tostring(
                role
                or "Panel"
            ),

        BaseTransparency =
            math.clamp(
                tonumber(
                    baseTransparency
                )
                or instance.BackgroundTransparency
                or 0,
                0,
                1
            ),
    }

    Library:ApplyTransparencyToSurface(
        instance
    )

    return true
end

function Library:ApplyInterfaceTransparency()

    for instance in pairs(
        Library.SurfaceRegistry
    ) do

        Library:ApplyTransparencyToSurface(
            instance
        )
    end

    return true
end

function Library:SetInterfaceTransparency(value)

    Library.InterfaceTransparency =
        math.clamp(
            tonumber(value)
            or 0,
            0,
            70
        )

    Library:ApplyInterfaceTransparency()

    return Library.InterfaceTransparency
end

--// Basic Functions \\--
local function WaitForEvent(Event, Timeout, Condition)
    local Bindable = Instance.new("BindableEvent")
    local Connection = Event:Once(function(...)
        if not Condition or typeof(Condition) == "function" and Condition(...) then
            Bindable:Fire(true)
        else
            Bindable:Fire(false)
        end
    end)
    task.delay(Timeout, function()
        Connection:Disconnect()
        Bindable:Fire(false)
    end)

    local Result = Bindable.Event:Wait()
    Bindable:Destroy()

    return Result
end

local function IsMouseInput(Input: InputObject, IncludeM2: boolean?)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or (IncludeM2 == true and Input.UserInputType == Enum.UserInputType.MouseButton2)
        or Input.UserInputType == Enum.UserInputType.Touch
end
local function IsClickInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and Input.UserInputState == Enum.UserInputState.Begin
        and Library.IsRobloxFocused
end
local function IsHoverInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Input.UserInputState == Enum.UserInputState.Change
end
local function IsDragInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change)
        and Library.IsRobloxFocused
end

local function GetTableSize(Table: { [any]: any })
    local Size = 0

    for _, _ in Table do
        Size = Size + 1
    end

    return Size
end
local function StopTween(Tween: TweenBase)
    if not (Tween and Tween.PlaybackState == Enum.PlaybackState.Playing) then
        return
    end

    Tween:Cancel()
end
local function Trim(Text: string)
    return Text:match("^%s*(.-)%s*$")
end
local function Round(Value, Rounding)
    assert(Rounding >= 0, "Invalid rounding number.")

    if Rounding == 0 then
        return math.floor(Value)
    end

    return tonumber(string.format("%." .. Rounding .. "f", Value))
end

local function GetPlayers(ExcludeLocalPlayer: boolean?)
    local PlayerList = Players:GetPlayers()

    if ExcludeLocalPlayer then
        local Idx = table.find(PlayerList, LocalPlayer)
        if Idx then
            table.remove(PlayerList, Idx)
        end
    end

    table.sort(PlayerList, function(Player1, Player2)
        return Player1.Name:lower() < Player2.Name:lower()
    end)

    return PlayerList
end
local function GetTeams()
    local TeamList = Teams:GetTeams()

    table.sort(TeamList, function(Team1, Team2)
        return Team1.Name:lower() < Team2.Name:lower()
    end)

    return TeamList
end

function Library:UpdateDependencyBoxes()
    for _, Depbox in Library.DependencyBoxes do
        Depbox:Update(true)
    end

    if Library.Searching then
        Library:UpdateSearch(Library.SearchText)
    end
end

local function CheckDepbox(Box, Search)
    local VisibleElements = 0

    for _, ElementInfo in Box.Elements do
        if ElementInfo.Type == "Divider" then
            ElementInfo.Holder.Visible = false
            continue
        elseif ElementInfo.SubButton then
            --// Check if any of the Buttons Name matches with Search
            local Visible = false

            --// Check if Search matches Element's Name and if Element is Visible
            if ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                Visible = true
            else
                ElementInfo.Base.Visible = false
            end
            if ElementInfo.SubButton.Text:lower():match(Search) and ElementInfo.SubButton.Visible then
                Visible = true
            else
                ElementInfo.SubButton.Base.Visible = false
            end
            ElementInfo.Holder.Visible = Visible
            if Visible then
                VisibleElements = VisibleElements + 1
            end

            continue
        end

        --// Check if Search matches Element's Name and if Element is Visible
        if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
            ElementInfo.Holder.Visible = true
            VisibleElements = VisibleElements + 1
        else
            ElementInfo.Holder.Visible = false
        end
    end

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        VisibleElements = VisibleElements + CheckDepbox(Depbox, Search)
    end

    Box.Holder.Visible = VisibleElements > 0
    return VisibleElements
end
local function RestoreDepbox(Box)
    for _, ElementInfo in Box.Elements do
        ElementInfo.Holder.Visible = typeof(ElementInfo.Visible) == "boolean" and ElementInfo.Visible or true

        if ElementInfo.SubButton then
            ElementInfo.Base.Visible = ElementInfo.Visible
            ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
        end
    end

    Box:Resize()
    Box.Holder.Visible = true

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        RestoreDepbox(Depbox)
    end
end

local function ApplySearchToTab(Tab, Search)
    if not Tab then
        return
    end

    local HasVisible = false

    --// Loop through Groupboxes to get Elements Info
    for _, Groupbox in Tab.Groupboxes do
        local VisibleElements = 0

        for _, ElementInfo in Groupbox.Elements do
            if ElementInfo.Type == "Divider" then
                ElementInfo.Holder.Visible = false
                continue
            elseif ElementInfo.SubButton then
                --// Check if any of the Buttons Name matches with Search
                local Visible = false

                --// Check if Search matches Element's Name and if Element is Visible
                if ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                    Visible = true
                else
                    ElementInfo.Base.Visible = false
                end
                if ElementInfo.SubButton.Text:lower():match(Search) and ElementInfo.SubButton.Visible then
                    Visible = true
                else
                    ElementInfo.SubButton.Base.Visible = false
                end
                ElementInfo.Holder.Visible = Visible
                if Visible then
                    VisibleElements = VisibleElements + 1
                end

                continue
            end

            --// Check if Search matches Element's Name and if Element is Visible
            if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                ElementInfo.Holder.Visible = true
                VisibleElements = VisibleElements + 1
            else
                ElementInfo.Holder.Visible = false
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            VisibleElements = VisibleElements + CheckDepbox(Depbox, Search)
        end

        --// Update Groupbox Size and Visibility if found any element
        if VisibleElements > 0 then
            Groupbox:Resize()
            HasVisible = true
        end
        Groupbox.BoxHolder.Visible = VisibleElements > 0
    end

    for _, Tabbox in Tab.Tabboxes do
        local VisibleTabs = 0
        local VisibleElements = {}

        for _, SubTab in Tabbox.Tabs do
            VisibleElements[SubTab] = 0

            for _, ElementInfo in SubTab.Elements do
                if ElementInfo.Type == "Divider" then
                    ElementInfo.Holder.Visible = false
                    continue
                elseif ElementInfo.SubButton then
                    --// Check if any of the Buttons Name matches with Search
                    local Visible = false

                    --// Check if Search matches Element's Name and if Element is Visible
                    if ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                        Visible = true
                    else
                        ElementInfo.Base.Visible = false
                    end
                    if ElementInfo.SubButton.Text:lower():match(Search) and ElementInfo.SubButton.Visible then
                        Visible = true
                    else
                        ElementInfo.SubButton.Base.Visible = false
                    end
                    ElementInfo.Holder.Visible = Visible
                    if Visible then
                        VisibleElements[SubTab] = VisibleElements[SubTab] + 1
                    end

                    continue
                end

                --// Check if Search matches Element's Name and if Element is Visible
                if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                    ElementInfo.Holder.Visible = true
                    VisibleElements[SubTab] = VisibleElements[SubTab] + 1
                else
                    ElementInfo.Holder.Visible = false
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                VisibleElements[SubTab] = VisibleElements[SubTab] + CheckDepbox(Depbox, Search)
            end
        end

        for SubTab, Visible in VisibleElements do
            SubTab.ButtonHolder.Visible = Visible > 0
            if Visible > 0 then
                VisibleTabs = VisibleTabs + 1
                HasVisible = true

                if Tabbox.ActiveTab == SubTab then
                    SubTab:Resize()
                elseif Tabbox.ActiveTab and VisibleElements[Tabbox.ActiveTab] == 0 then
                    SubTab:Show()
                end
            end
        end

        --// Update Tabbox Visibility if any visible
        Tabbox.BoxHolder.Visible = VisibleTabs > 0
    end

    return HasVisible
end
local function ResetTab(Tab)
    if not Tab then
        return
    end

    for _, Groupbox in Tab.Groupboxes do
        for _, ElementInfo in Groupbox.Elements do
            ElementInfo.Holder.Visible = typeof(ElementInfo.Visible) == "boolean" and ElementInfo.Visible or true

            if ElementInfo.SubButton then
                ElementInfo.Base.Visible = ElementInfo.Visible
                ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            RestoreDepbox(Depbox)
        end

        Groupbox:Resize()
        Groupbox.BoxHolder.Visible = true
    end

    for _, Tabbox in Tab.Tabboxes do
        for _, SubTab in Tabbox.Tabs do
            for _, ElementInfo in SubTab.Elements do
                ElementInfo.Holder.Visible = typeof(ElementInfo.Visible) == "boolean" and ElementInfo.Visible or true

                if ElementInfo.SubButton then
                    ElementInfo.Base.Visible = ElementInfo.Visible
                    ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                RestoreDepbox(Depbox)
            end

            SubTab.ButtonHolder.Visible = true
        end

        if Tabbox.ActiveTab then
            Tabbox.ActiveTab:Resize()
        end
        Tabbox.BoxHolder.Visible = true
    end
end

function Library:UpdateSearch(SearchText)
    Library.SearchText = SearchText

    local TabsToReset = {}

    if Library.GlobalSearch then
        for _, Tab in Library.Tabs do
            if typeof(Tab) == "table" and not Tab.IsKeyTab then
                table.insert(TabsToReset, Tab)
            end
        end
    elseif Library.LastSearchTab and typeof(Library.LastSearchTab) == "table" then
        table.insert(TabsToReset, Library.LastSearchTab)
    end

    for _, Tab in ipairs(TabsToReset) do
        ResetTab(Tab)
    end

    local Search = SearchText:lower()
    if Trim(Search) == "" then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end
    if not Library.GlobalSearch and Library.ActiveTab and Library.ActiveTab.IsKeyTab then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end

    Library.Searching = true

    local TabsToSearch = {}

    if Library.GlobalSearch then
        TabsToSearch = TabsToReset
        if #TabsToSearch == 0 then
            for _, Tab in Library.Tabs do
                if typeof(Tab) == "table" and not Tab.IsKeyTab then
                    table.insert(TabsToSearch, Tab)
                end
            end
        end
    elseif Library.ActiveTab then
        table.insert(TabsToSearch, Library.ActiveTab)
    end

    local FirstVisibleTab = nil
    local ActiveHasVisible = false

    for _, Tab in ipairs(TabsToSearch) do
        local HasVisible = ApplySearchToTab(Tab, Search)
        if HasVisible then
            if not FirstVisibleTab then
                FirstVisibleTab = Tab
            end
            if Tab == Library.ActiveTab then
                ActiveHasVisible = true
            end
        end
    end

    if Library.GlobalSearch then
        if ActiveHasVisible and Library.ActiveTab then
            Library.ActiveTab:RefreshSides()
        elseif FirstVisibleTab then
            local SearchMarker = SearchText
            task.defer(function()
                if Library.SearchText ~= SearchMarker then
                    return
                end

                if Library.ActiveTab ~= FirstVisibleTab then
                    FirstVisibleTab:Show()
                end
            end)
        end
        Library.LastSearchTab = nil
    else
        Library.LastSearchTab = Library.ActiveTab
    end
end

function Library:AddToRegistry(Instance, Properties)
    Library.Registry[Instance] = Properties
end

function Library:RemoveFromRegistry(Instance)

    Library.Registry[Instance] =
        nil

    Library.SurfaceRegistry[Instance] =
        nil

    Library.StrokeRegistry[Instance] =
        nil
end

function Library:UpdateColorsUsingRegistry()

    for Instance, Properties in Library.Registry do

        for Property, Index in Properties do

            local SchemeValue =
                GetSchemeValue(
                    Index
                )

            if SchemeValue
            or typeof(Index) == "function" then

                Instance[Property] =
                    SchemeValue
                    or Index()
            end
        end
    end

    Library:ApplyInterfaceTransparency()
end

function Library:SetDPIScale(DPIScale: number)

    Library.DPIScale =
        math.clamp(
            tonumber(DPIScale)
            or 100,
            30,
            110
        )
        / 100

    Library.MinSize =
        Library.OriginalMinSize
        * Library.DPIScale

    for _, UIScale in ipairs(
        Library.Scales
    ) do

        UIScale.Scale =
            Library.DPIScale
            - (
                tonumber(
                    Library.ScalesOffset[
                        UIScale
                    ]
                )
                or 0
            )
    end

    for stroke, baseThickness in pairs(
        Library.StrokeRegistry
    ) do

        if typeof(stroke) ~= "Instance"
        or stroke.Parent == nil then

            Library.StrokeRegistry[
                stroke
            ] =
                nil

        else

            pcall(function()

                stroke.Thickness =
                    math.clamp(
                        baseThickness
                        / math.max(
                            Library.DPIScale,
                            0.05
                        ),
                        baseThickness,
                        baseThickness * 2
                    )
            end)
        end
    end

    for _, option in pairs(
        Options
    ) do

        if option.Type == "Dropdown"
        and type(option.RecalculateListSize) == "function" then

            option:RecalculateListSize()
        end
    end

    for _, notification in pairs(
        Library.Notifications
    ) do

        if type(notification.Resize) == "function" then

            notification:Resize()
        end
    end
end

function Library:GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
    local ConnectionType = typeof(Connection)
    if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
        table.insert(Library.Signals, Connection)
    end

    return Connection
end

function IsValidCustomIcon(Icon: string)
    return typeof(Icon) == "string" and (Icon:match("rbxasset") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

type Icon = {
    Url: string,
    Id: number,
    IconName: string,
    ImageRectOffset: Vector2,
    ImageRectSize: Vector2,
}

type IconModule = {
    Icons: { string },
    GetAsset: (Name: string) -> Icon?,
}

local FetchIcons, Icons = pcall(function()
    local IconSource =
        game:HttpGet(
            "https://gitlab.com/upio/lucide-roblox-direct/-/raw/main/source.lua",
            true
        )

    local PatchedIconSource,
        InitialFlagReplacements =
        IconSource:gsub(
            "local IS_GETCUSTOMASSET_BROKEN = false",
            "local IS_GETCUSTOMASSET_BROKEN = true",
            1
        )

    local DetectionFlagReplacements

    PatchedIconSource,
        DetectionFlagReplacements =
        PatchedIconSource:gsub(
            "IS_GETCUSTOMASSET_BROKEN = not Success",
            "IS_GETCUSTOMASSET_BROKEN = true",
            1
        )

    assert(
        InitialFlagReplacements == 1
        and DetectionFlagReplacements == 1,
        "Could not force Lucide public asset fallback"
    )

    local IconChunk,
        CompileError =
        loadstring(
            PatchedIconSource
        )

    assert(
        type(IconChunk) == "function",
        tostring(
            CompileError
        )
    )

    return (IconChunk :: () -> IconModule)()
end)

function Library:GetIcon(IconName: string)
    if not FetchIcons then
        return
    end

    local Success, Icon = pcall(Icons.GetAsset, IconName)
    if not Success then
        return
    end
    return Icon
end

function Library:GetCustomIcon(IconName: string): any
    if not IconName then
        return nil
    end

    if tonumber(IconName) then
        IconName = string.format("rbxassetid://%s", tostring(IconName))
    end

    local CustomIcon = IsValidCustomIcon(IconName)
    if CustomIcon then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
            Custom = true,
        }
    end

    local LucideIcon = Library:GetIcon(IconName)
    if LucideIcon then
        return LucideIcon
    end

    return nil
end

function Library:Validate(Table: { [string]: any }, Template: { [string]: any }): { [string]: any }
    if typeof(Table) ~= "table" then
        return Template
    end

    for k, v in Template do
        if typeof(k) == "number" then
            continue
        end

        if typeof(v) == "table" then
            Table[k] = Library:Validate(Table[k], v)
        elseif Table[k] == nil then
            Table[k] = v
        end
    end

    return Table
end

--// Creator Functions \\--
local function FillInstance(Table: { [string]: any }, Instance: GuiObject)
    local ThemeProperties = Library.Registry[Instance] or {}

    for key, value in Table do
        if key ~= "Text" then
            local SchemeValue = GetSchemeValue(value)

            if SchemeValue or typeof(value) == "function" then
                ThemeProperties[key] = value
                value = SchemeValue or value()
            else
                ThemeProperties[key] = nil
            end
        end

        Instance[key] = value
    end

    if GetTableSize(ThemeProperties) > 0 then
        Library.Registry[Instance] = ThemeProperties
    end
end

local function New(ClassName: string, Properties: { [string]: any }): any
    local Instance = Instance.new(ClassName)

    if Templates[ClassName] then
        FillInstance(Templates[ClassName], Instance)
    end
    FillInstance(Properties, Instance)

    if Instance:IsA("UIStroke")
    and Instance.ApplyStrokeMode
        == Enum.ApplyStrokeMode.Border then

        local baseThickness =
            tonumber(
                Instance.Thickness
            )
            or 1

        Library.StrokeRegistry[
            Instance
        ] =
            baseThickness

        Instance.Thickness =
            math.clamp(
                baseThickness
                / math.max(
                    tonumber(
                        Library.DPIScale
                    )
                    or 1,
                    0.05
                ),
                baseThickness,
                baseThickness * 2
            )
    end

    if Properties["Parent"]
    and not Properties["ZIndex"] then

        pcall(function()

            Instance.ZIndex =
                Properties.Parent.ZIndex
        end)
    end

    if Instance:IsA("GuiObject") then

        local themeProperties =
            Library.Registry[
                Instance
            ]

        local backgroundSource =
            type(themeProperties) == "table"
            and themeProperties.BackgroundColor3
            or nil

        local surfaceRole =
            nil

        if backgroundSource == "BackgroundColor"
        or typeof(backgroundSource) == "function" then

            surfaceRole =
                "Panel"

        elseif backgroundSource == "MainColor" then

            surfaceRole =
                "Control"
        end

        if surfaceRole ~= nil then

            Library:RegisterSurface(
                Instance,
                surfaceRole,
                Instance.BackgroundTransparency
            )
        end
    end

    return Instance
end

--// Main Instances \\-
local function SafeParentUI(Instance: Instance, Parent: Instance | () -> Instance)
    local success, _error = pcall(function()
        if not Parent then
            Parent = CoreGui
        end

        local DestinationParent
        if typeof(Parent) == "function" then
            DestinationParent = Parent()
        else
            DestinationParent = Parent
        end

        Instance.Parent = DestinationParent
    end)

    if not (success and Instance.Parent) then
        Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local function ParentUI(UI: Instance, SkipHiddenUI: boolean?)

    local PlayerGui =
        Library.LocalPlayer:FindFirstChildOfClass(
            "PlayerGui"
        )
        or Library.LocalPlayer:WaitForChild(
            "PlayerGui",
            30
        )

    if PlayerGui then

        SafeParentUI(
            UI,
            PlayerGui
        )

        return
    end

    SafeParentUI(
        UI,
        CoreGui
    )
end

local ScreenGui = New("ScreenGui", {
    Name = "HolyLibrary",

    DisplayOrder =
        1000000,

    ResetOnSpawn =
        false,

    ZIndexBehavior =
        Enum.ZIndexBehavior.Sibling,
})
ParentUI(ScreenGui)
Library.ScreenGui = ScreenGui

ScreenGui.DescendantRemoving:Connect(function(Instance)
    Library:RemoveFromRegistry(Instance)
end)

local ModalElement = New("TextButton", {
    BackgroundTransparency = 1,
    Modal = false,
    Size = UDim2.fromScale(0, 0),
    AnchorPoint = Vector2.zero,
    Text = "",
    ZIndex = -999,
    Parent = ScreenGui,
})

--// Cursor
local Cursor, CursorCustomImage
do
    Cursor = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Size = UDim2.fromOffset(9, 1),
        Visible = false,
        ZIndex = 11000,
        Parent = ScreenGui,
    })
    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 2, 1, 2),
        ZIndex = 10999,
        Parent = Cursor,
    })

    local CursorV = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(1, 9),
        ZIndex = 11000,
        Parent = Cursor,
    })
    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 2, 1, 2),
        ZIndex = 10999,
        Parent = CursorV,
    })

    CursorCustomImage = New("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(20, 20),
        ZIndex = 11000,
        Visible = false,
        Parent = Cursor
    })
end

--// Notification
local NotificationArea
local NotificationList
do
    NotificationArea = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -6, 0, 6),
        Size = UDim2.new(0, 300, 1, -6),
        Parent = ScreenGui,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = NotificationArea,
        })
    )

    NotificationList = New("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8),
        Parent = NotificationArea,
    })
end

--// Lib Functions \\--
function Library:ResetCursorIcon()
    CursorCustomImage.Visible = false
    CursorCustomImage.Size = UDim2.fromOffset(20, 20)
end

function Library:ChangeCursorIcon(ImageId: string)
    if not ImageId or ImageId == "" then
        Library:ResetCursorIcon()
        return
    end

    local Icon = Library:GetCustomIcon(ImageId)
    assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

    CursorCustomImage.Visible = true
    CursorCustomImage.Image = Icon.Url
    CursorCustomImage.ImageRectOffset = Icon.ImageRectOffset
    CursorCustomImage.ImageRectSize = Icon.ImageRectSize
end

function Library:ChangeCursorIconSize(Size: UDim2)
    assert(typeof(Size) == "UDim2", "UDim2 expected.")
    CursorCustomImage.Size = Size
end

function Library:GetBetterColor(Color: Color3, Add: number): Color3
    Add = Add * (Library.IsLightTheme and -4 or 2)
    return Color3.fromRGB(
        math.clamp(Color.R * 255 + Add, 0, 255),
        math.clamp(Color.G * 255 + Add, 0, 255),
        math.clamp(Color.B * 255 + Add, 0, 255)
    )
end

function Library:GetLighterColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, math.max(0, S - 0.1), math.min(1, V + 0.1))
end

function Library:GetDarkerColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, S, V / 2)
end

function Library:GetKeyString(KeyCode: Enum.KeyCode)
    if KeyCode.EnumType == Enum.KeyCode and KeyCode.Value > 33 and KeyCode.Value < 127 then
        return string.char(KeyCode.Value)
    end

    return KeyCode.Name
end

function Library:GetTextBounds(Text: string, Font: Font, Size: number, Width: number?): (number, number)

    Text =
        tostring(Text or "")

    Size =
        math.clamp(
            tonumber(Size)
            or 14,
            1,
            100
        )

    local viewportWidth =
        1280

    pcall(function()

        if workspace.CurrentCamera then

            viewportWidth =
                tonumber(
                    workspace.CurrentCamera.ViewportSize.X
                )
                or viewportWidth
        end
    end)

    Width =
        math.clamp(
            tonumber(Width)
            or (
                viewportWidth
                - 32
            ),
            1,
            100000
        )

    local ok,
        Bounds =
        pcall(function()

            local Params =
                Instance.new(
                    "GetTextBoundsParams"
                )

            Params.Text =
                Text

            Params.RichText =
                true

            if typeof(Font) == "Font" then

                Params.Font =
                    Font

            elseif typeof(Font) == "EnumItem" then

                Params.Font =
                    Font.fromEnum(
                        Font
                    )

            elseif typeof(Library.Scheme.Font) == "Font" then

                Params.Font =
                    Library.Scheme.Font

            else

                Params.Font =
                    Font.fromEnum(
                        Enum.Font.GothamMedium
                    )
            end

            Params.Size =
                Size

            Params.Width =
                Width

            return TextService:GetTextBoundsAsync(
                Params
            )
        end)

    if ok == true
    and typeof(Bounds) == "Vector2" then

        return math.max(
            1,
            math.floor(Bounds.X + 0.5)
        ),
        math.max(
            1,
            math.floor(Bounds.Y + 0.5)
        )
    end

    local plainText =
        Text:gsub(
            "<[^>]->",
            ""
        )

    plainText =
        plainText:gsub(
            "&nbsp;",
            " "
        )

    local longestLine =
        0

    local lineCount =
        0

    for line in tostring(plainText):gmatch("[^\n]*") do

        lineCount =
            lineCount + 1

        longestLine =
            math.max(
                longestLine,
                #line
            )

        if line == ""
        and lineCount > 1 then
            break
        end
    end

    lineCount =
        math.max(
            1,
            lineCount
        )

    longestLine =
        math.max(
            1,
            longestLine
        )

    local estimatedWidth =
        longestLine
        * Size
        * 0.58

    local wrappedLines =
        math.max(
            1,
            math.ceil(
                estimatedWidth
                / Width
            )
        )

    local finalWidth =
        math.clamp(
            estimatedWidth,
            Size,
            Width
        )

    local finalHeight =
        math.max(
            Size * 1.35,
            (
                wrappedLines
                + lineCount
                - 1
            )
            * Size
            * 1.35
        )

    return math.max(
        1,
        math.floor(finalWidth + 0.5)
    ),
    math.max(
        1,
        math.floor(finalHeight + 0.5)
    )
end

function Library:MouseIsOverFrame(Frame: GuiObject, Mouse: Vector2): boolean
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    return Mouse.X >= AbsPos.X
        and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y
        and Mouse.Y <= AbsPos.Y + AbsSize.Y
end

function Library:SafeCallback(Func: (...any) -> ...any, ...: any)
    if not (Func and typeof(Func) == "function") then
        return
    end

    local Result = table.pack(xpcall(Func, function(Error)
        task.defer(error, debug.traceback(Error, 2))
        if Library.NotifyOnError then
            Library:Notify(Error)
        end

        return Error
    end, ...))

    if not Result[1] then
        return nil
    end

    return table.unpack(Result, 2, Result.n)
end

function Library:MakeDraggable(UI: GuiObject, DragFrame: GuiObject, IgnoreToggled: boolean?, IsMainWindow: boolean?)
    local StartPos
    local FramePos
    local Dragging = false
    local Changed
    DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) or IsMainWindow and Library.CantDragForced then
            return
        end

        StartPos = Input.Position
        FramePos = UI.Position
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)
    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
        if
            (not IgnoreToggled and not Library.Toggled)
            or (IsMainWindow and Library.CantDragForced)
            or not (ScreenGui and ScreenGui.Parent)
        then
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            UI.Position =
                UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
        end
    end))
end

function Library:MakeResizable(UI: GuiObject, DragFrame: GuiObject, Callback: () -> ()?)
    local StartPos
    local FrameSize
    local Dragging = false
    local Changed

    DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        StartPos = Input.Position
        FrameSize = UI.Size
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
        if not UI.Visible or not (ScreenGui and ScreenGui.Parent) then
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            UI.Size = UDim2.new(
                FrameSize.X.Scale,
                math.clamp(FrameSize.X.Offset + Delta.X, Library.MinSize.X, math.huge),
                FrameSize.Y.Scale,
                math.clamp(FrameSize.Y.Offset + Delta.Y, Library.MinSize.Y, math.huge)
            )
            if Callback then
                Library:SafeCallback(Callback)
            end
        end
    end))
end

function Library:GetGroupboxSideList(Tab, SideName)
    if type(Tab) ~= "table" then
        return nil
    end

    Tab.GroupboxOrder =
        Tab.GroupboxOrder
        or {
            Left = {},
            Right = {},
        }

    SideName =
        tostring(SideName or "Left")

    if SideName ~= "Right" then
        SideName =
            "Left"
    end

    Tab.GroupboxOrder[SideName] =
        Tab.GroupboxOrder[SideName]
        or {}

    return Tab.GroupboxOrder[SideName]
end

function Library:GetGroupboxOrderBucket(Tab, SideName)
    if type(Tab) ~= "table" then
        return nil, ""
    end

    local TabName =
        tostring(Tab.Name or "Tab")

    SideName =
        tostring(SideName or "Left")

    if SideName ~= "Right" then
        SideName =
            "Left"
    end

    local Key =
        TabName
        .. "/"
        .. SideName

    local Orders =
        Library.GroupboxOrders

    if type(Orders) ~= "table" then
        Library.GroupboxOrders = {}
        Orders = Library.GroupboxOrders
    end

    if type(Orders[Key]) ~= "table" then
        Orders[Key] = {}
    end

    return Orders[Key],
        Key
end

function Library:RefreshGroupboxOrder(Tab, SideName)
    local SideList =
        Library:GetGroupboxSideList(
            Tab,
            SideName
        )

    if type(SideList) ~= "table" then
        return
    end

    local SavedList =
        Library:GetGroupboxOrderBucket(
            Tab,
            SideName
        )

    local SavedIndex =
        {}

    if type(SavedList) == "table" then
        for Index, Name in ipairs(SavedList) do
            SavedIndex[tostring(Name)] =
                Index
        end
    end

    table.sort(SideList, function(A, B)
        local AName =
            tostring(A and A.Name or "")

        local BName =
            tostring(B and B.Name or "")

        local AIndex =
            SavedIndex[AName]
            or (
                1000000
                + tonumber(A and A.CreatedOrder or 0)
            )

        local BIndex =
            SavedIndex[BName]
            or (
                1000000
                + tonumber(B and B.CreatedOrder or 0)
            )

        if AIndex ~= BIndex then
            return AIndex < BIndex
        end

        return AName < BName
    end)

    for Index, Groupbox in ipairs(SideList) do
        if Groupbox
        and Groupbox.BoxHolder then
            Groupbox.BoxHolder.LayoutOrder =
                Index * 10
        end
    end
end

function Library:SaveGroupboxOrderFor(Tab, SideName)
    local SideList =
        Library:GetGroupboxSideList(
            Tab,
            SideName
        )

    if type(SideList) ~= "table" then
        return
    end

    table.sort(SideList, function(A, B)
        return tonumber(
            A
            and A.BoxHolder
            and A.BoxHolder.LayoutOrder
            or A.CreatedOrder
            or 0
        )
        < tonumber(
            B
            and B.BoxHolder
            and B.BoxHolder.LayoutOrder
            or B.CreatedOrder
            or 0
        )
    end)

    local Bucket =
        Library:GetGroupboxOrderBucket(
            Tab,
            SideName
        )

    table.clear(Bucket)

    for _, Groupbox in ipairs(SideList) do
        if Groupbox
        and tostring(Groupbox.Name or "") ~= "" then
            table.insert(
                Bucket,
                tostring(Groupbox.Name)
            )
        end
    end

    if type(Library.GroupboxOrderChanged) == "function" then
        Library:SafeCallback(
            Library.GroupboxOrderChanged,
            Library.GroupboxOrders
        )
    end
end

function Library:GetGroupboxDropPreview(Groupbox, MouseY)
    if type(Groupbox) ~= "table" then
        return nil
    end

    local Tab =
        Groupbox.Tab

    local SideName =
        tostring(Groupbox.SideName or "Left")

    local SideList =
        Library:GetGroupboxSideList(
            Tab,
            SideName
        )

    if type(SideList) ~= "table"
    or #SideList <= 1 then
        return nil
    end

    local Ordered =
        {}

    for _, OtherGroupbox in ipairs(SideList) do
        if OtherGroupbox ~= Groupbox then
            table.insert(
                Ordered,
                OtherGroupbox
            )
        end
    end

    table.sort(Ordered, function(A, B)
        return tonumber(
            A
            and A.BoxHolder
            and A.BoxHolder.LayoutOrder
            or A.CreatedOrder
            or 0
        )
        < tonumber(
            B
            and B.BoxHolder
            and B.BoxHolder.LayoutOrder
            or B.CreatedOrder
            or 0
        )
    end)

    local InsertIndex =
        #Ordered + 1

    MouseY =
        tonumber(MouseY)
        or 0

    for Index, OtherGroupbox in ipairs(Ordered) do
        local Holder =
            OtherGroupbox
            and OtherGroupbox.BoxHolder

        if Holder then
            local MidY =
                Holder.AbsolutePosition.Y
                + (
                    Holder.AbsoluteSize.Y / 2
                )

            if MouseY < MidY then
                InsertIndex =
                    Index

                break
            end
        end
    end

    local ReferenceHolder =
        nil

    local IndicatorY =
        nil

    if InsertIndex <= #Ordered then

        ReferenceHolder =
            Ordered[InsertIndex]
            and Ordered[InsertIndex].BoxHolder

        if ReferenceHolder then

            IndicatorY =
                ReferenceHolder.AbsolutePosition.Y
                - 5
        end

    elseif #Ordered > 0 then

        ReferenceHolder =
            Ordered[#Ordered]
            and Ordered[#Ordered].BoxHolder

        if ReferenceHolder then

            IndicatorY =
                ReferenceHolder.AbsolutePosition.Y
                + ReferenceHolder.AbsoluteSize.Y
                + 5
        end
    end

    local SourceHolder =
        Groupbox.BoxHolder

    if not SourceHolder then
        return nil
    end

    if not IndicatorY then
        IndicatorY =
            SourceHolder.AbsolutePosition.Y
    end

    return {
        InsertIndex = InsertIndex,
        SideName = SideName,
        X = SourceHolder.AbsolutePosition.X + 8,
        Y = IndicatorY,
        Width = math.max(
            24,
            SourceHolder.AbsoluteSize.X - 16
        ),
    }
end

function Library:GetGroupboxDropIndicator()
    if Library.GroupboxDropIndicator
    and Library.GroupboxDropIndicator.Parent then
        return Library.GroupboxDropIndicator
    end

    local Indicator =
        New("Frame", {
            BackgroundColor3 = "AccentColor",
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromOffset(100, 2),
            Visible = false,
            ZIndex = 12000,
            Parent = ScreenGui,
        })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Indicator,
        })
    )

    Library.GroupboxDropIndicator =
        Indicator

    return Indicator
end

function Library:ShowGroupboxDropIndicator(Groupbox, MouseY)
    if Library.GroupboxDropIndicatorEnabled ~= true then
        return
    end

    local Preview =
        Library:GetGroupboxDropPreview(
            Groupbox,
            MouseY
        )

    local Indicator =
        Library:GetGroupboxDropIndicator()

    if not Preview
    or not Indicator then

        if Indicator then
            Indicator.Visible =
                false
        end

        return
    end

    Indicator.Position =
        UDim2.fromOffset(
            math.floor(Preview.X),
            math.floor(Preview.Y)
        )

    Indicator.Size =
        UDim2.fromOffset(
            math.floor(Preview.Width),
            2
        )

    Indicator.Visible =
        true
end

function Library:HideGroupboxDropIndicator()
    if Library.GroupboxDropIndicator then
        Library.GroupboxDropIndicator.Visible =
            false
    end
end

function Library:CreateGroupboxDragGhost(Groupbox, StartPosition)
    if Library.GroupboxGhostEnabled ~= true then
        return
    end

    if Library.GroupboxDragGhost
    and Library.GroupboxDragGhost.Parent then
        Library.GroupboxDragGhost:Destroy()
    end

    local SourceHolder =
        Groupbox
        and Groupbox.BoxHolder

    local Width =
        SourceHolder
        and SourceHolder.AbsoluteSize.X
        or 220

    local Ghost =
        New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            BackgroundTransparency = 0.04,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(
                math.floor(StartPosition.X + 12),
                math.floor(StartPosition.Y + 10)
            ),
            Size = UDim2.fromOffset(
                math.max(180, math.floor(Width)),
                34
            ),
            ZIndex = 12001,
            Parent = ScreenGui,
        })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Ghost,
        })
    )

    Library:AddOutline(
        Ghost
    )

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Text =
            "☰ "
            .. tostring(
                Groupbox
                and Groupbox.Name
                or "Groupbox"
            ),
        TextSize = 14,
        TextTransparency = 0.05,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = Ghost.ZIndex + 1,
        Parent = Ghost,
    })

    Library.GroupboxDragGhost =
        Ghost
end

function Library:UpdateGroupboxDragGhost(Position)
    local Ghost =
        Library.GroupboxDragGhost

    if not Ghost
    or not Ghost.Parent then
        return
    end

    Ghost.Position =
        UDim2.fromOffset(
            math.floor(Position.X + 12),
            math.floor(Position.Y + 10)
        )
end

function Library:DestroyGroupboxDragGhost()
    if Library.GroupboxDragGhost then

        pcall(function()

            Library.GroupboxDragGhost:Destroy()
        end)

        Library.GroupboxDragGhost =
            nil
    end
end

function Library:CommitGroupboxDrop(Groupbox, MouseY)
    local Changed =
        Library:MoveGroupboxInSide(
            Groupbox,
            MouseY,
            true
        )

    if Changed == true
    and Library.GroupboxDragDebug == true then

        print(
            "[OBSIDIAN GROUPBOX DRAG]",
            "committed",
            tostring(Groupbox and Groupbox.Name),
            tostring(Groupbox and Groupbox.SideName)
        )
    end

    return Changed
end

function Library:MoveGroupboxInSide(Groupbox, MouseY, SaveNow)
    if type(Groupbox) ~= "table" then
        return false
    end

    local Tab =
        Groupbox.Tab

    local SideName =
        tostring(Groupbox.SideName or "Left")

    local SideList =
        Library:GetGroupboxSideList(
            Tab,
            SideName
        )

    if type(SideList) ~= "table"
    or #SideList <= 1 then
        return false
    end

    table.sort(SideList, function(A, B)
        return tonumber(
            A
            and A.BoxHolder
            and A.BoxHolder.LayoutOrder
            or A.CreatedOrder
            or 0
        )
        < tonumber(
            B
            and B.BoxHolder
            and B.BoxHolder.LayoutOrder
            or B.CreatedOrder
            or 0
        )
    end)

    local CurrentIndex =
        nil

    for Index, OtherGroupbox in ipairs(SideList) do
        if OtherGroupbox == Groupbox then
            CurrentIndex =
                Index

            table.remove(
                SideList,
                Index
            )

            break
        end
    end

    if not CurrentIndex then
        return false
    end

    local InsertIndex =
        #SideList + 1

    MouseY =
        tonumber(MouseY)
        or 0

    for Index, OtherGroupbox in ipairs(SideList) do
        local Holder =
            OtherGroupbox
            and OtherGroupbox.BoxHolder

        if Holder then
            local MidY =
                Holder.AbsolutePosition.Y
                + (
                    Holder.AbsoluteSize.Y / 2
                )

            if MouseY < MidY then
                InsertIndex =
                    Index

                break
            end
        end
    end

    table.insert(
        SideList,
        InsertIndex,
        Groupbox
    )

    local Changed =
        CurrentIndex ~= InsertIndex

    for Index, OrderedGroupbox in ipairs(SideList) do
        if OrderedGroupbox
        and OrderedGroupbox.BoxHolder then

            OrderedGroupbox.BoxHolder.LayoutOrder =
                Index * 10
        end
    end

    if Changed == true
    and Library.GroupboxDragDebug == true then

        print(
            "[OBSIDIAN GROUPBOX DRAG]",
            "moved",
            tostring(Groupbox.Name),
            "| side:",
            tostring(SideName),
            "| from:",
            tostring(CurrentIndex),
            "| to:",
            tostring(InsertIndex)
        )
    end

    if SaveNow ~= false then

        Library:SaveGroupboxOrderFor(
            Tab,
            SideName
        )
    end

    if Tab
    and type(Tab.RefreshSides) == "function" then

        task.defer(function()

            Tab:RefreshSides()
        end)
    end

    return Changed
end

function Library:SetGroupboxSideScrolling(Tab, Enabled)
    if type(Tab) ~= "table"
    or type(Tab.Sides) ~= "table" then
        return
    end

    for _, Side in Tab.Sides do
        if Side
        and Side:IsA("ScrollingFrame") then
            Side.ScrollingEnabled =
                Enabled == true
        end
    end
end

function Library:EnableGroupboxReorder(Groupbox)
    if type(Groupbox) ~= "table" then
        return
    end

    if Groupbox.__ReorderEnabled == true then
        return
    end

    local HeaderButton =
        Groupbox.HeaderButton

    if not HeaderButton then
        return
    end

    Groupbox.__ReorderEnabled =
        true

    HeaderButton.Active =
        true

    HeaderButton.Selectable =
        false

    HeaderButton.AutoButtonColor =
        false

    HeaderButton.InputBegan:Connect(function(Input)
        if Library.GroupboxDragEnabled ~= true then
            return
        end

        if Library.Searching == true then
            return
        end

        if not IsClickInput(Input) then
            return
        end

        local StartPosition =
            Input.Position

        local CurrentPosition =
            StartPosition

        local CurrentY =
            StartPosition.Y

        local Dragging =
            true

        local Moved =
            false

        local LastPreviewAt =
            0

        local InputChangedConnection =
            nil

        local InputEndedConnection =
            nil

        local function StartDragPreview()
            if Moved == true then
                return
            end

            Moved =
                true

            Groupbox.__DraggingMoved =
                true

            Library:SetGroupboxSideScrolling(
                Groupbox.Tab,
                false
            )

            if Groupbox.Holder then
                Groupbox.Holder.BackgroundTransparency =
                    0.16
            end

            Library:CreateGroupboxDragGhost(
                Groupbox,
                CurrentPosition
            )

            Library:ShowGroupboxDropIndicator(
                Groupbox,
                CurrentY
            )

            if Library.GroupboxDragDebug == true then

                print(
                    "[OBSIDIAN GROUPBOX DRAG]",
                    "preview started",
                    tostring(Groupbox.Name),
                    tostring(Groupbox.SideName)
                )
            end
        end

        local function StopDrag()
            if Dragging ~= true then
                return
            end

            Dragging =
                false

            if InputChangedConnection
            and InputChangedConnection.Connected then
                InputChangedConnection:Disconnect()
            end

            if InputEndedConnection
            and InputEndedConnection.Connected then
                InputEndedConnection:Disconnect()
            end

            Library:SetGroupboxSideScrolling(
                Groupbox.Tab,
                true
            )

            if Groupbox.Holder then
                Groupbox.Holder.BackgroundTransparency =
                    0
            end

            Library:HideGroupboxDropIndicator()
            Library:DestroyGroupboxDragGhost()

            if Moved == true then

                Groupbox.__DraggingMoved =
                    true

                Library:CommitGroupboxDrop(
                    Groupbox,
                    CurrentY
                )

                if Library.GroupboxDragDebug == true then

                    print(
                        "[OBSIDIAN GROUPBOX DRAG]",
                        "released",
                        tostring(Groupbox.Name),
                        "| y:",
                        tostring(math.floor(CurrentY))
                    )
                end
            end

            task.delay(0.10, function()

                if Groupbox then
                    Groupbox.__DraggingMoved =
                        false
                end
            end)
        end

        InputChangedConnection =
            UserInputService.InputChanged:Connect(function(ChangedInput)
                if Dragging ~= true then
                    return
                end

                if not IsHoverInput(ChangedInput) then
                    return
                end

                CurrentPosition =
                    ChangedInput.Position

                CurrentY =
                    ChangedInput.Position.Y

                local Distance =
                    (
                        Vector2.new(
                            ChangedInput.Position.X,
                            ChangedInput.Position.Y
                        )
                        - Vector2.new(
                            StartPosition.X,
                            StartPosition.Y
                        )
                    ).Magnitude

                if Moved ~= true
                and Distance >= tonumber(Library.GroupboxDragThreshold or 9) then

                    StartDragPreview()
                end

                if Moved == true
                and os.clock() - LastPreviewAt >= 0.015 then

                    LastPreviewAt =
                        os.clock()

                    Library:UpdateGroupboxDragGhost(
                        CurrentPosition
                    )

                    Library:ShowGroupboxDropIndicator(
                        Groupbox,
                        CurrentY
                    )
                end
            end)

        InputEndedConnection =
            UserInputService.InputEnded:Connect(function(EndedInput)
                if Dragging ~= true then
                    return
                end

                if EndedInput.UserInputType == Enum.UserInputType.MouseButton1
                or EndedInput.UserInputType == Enum.UserInputType.Touch then

                    StopDrag()
                end
            end)

        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                StopDrag()
            end
        end)
    end)
end

function Library:MakeCover(Holder: GuiObject, Place: string)
    local Pos = Places[Place] or { 0, 0 }
    local Size = Sizes[Place] or { 1, 0.5 }

    local Cover = New("Frame", {
        AnchorPoint = Vector2.new(Pos[1], Pos[2]),
        BackgroundColor3 = Holder.BackgroundColor3,
        Position = UDim2.fromScale(Pos[1], Pos[2]),
        Size = UDim2.fromScale(Size[1], Size[2]),
        Parent = Holder,
    })

    return Cover
end

function Library:MakeLine(Frame: GuiObject, Info)

    local Line =
        New(
            "Frame",
            {
                AnchorPoint =
                    Info.AnchorPoint
                    or Vector2.zero,

                BackgroundColor3 =
                    "SeparatorColor",

                Position =
                    Info.Position,

                Size =
                    Info.Size,

                ZIndex =
                    Info.ZIndex
                    or Frame.ZIndex,

                Parent =
                    Frame,
            }
        )

    return Line
end

function Library:AddOutline(Frame: GuiObject)

    local OuterRim =
        New(
            "UIStroke",
            {
                ApplyStrokeMode =
                    Enum.ApplyStrokeMode.Border,

                Color =
                    "OuterRimColor",

                LineJoinMode =
                    Enum.LineJoinMode.Round,

                Thickness =
                    1,

                Transparency =
                    1,

                ZIndex =
                    1,

                Parent =
                    Frame,
            }
        )

    local InnerBorder =
        New(
            "UIStroke",
            {
                ApplyStrokeMode =
                    Enum.ApplyStrokeMode.Border,

                Color =
                    "InnerBorderColor",

                LineJoinMode =
                    Enum.LineJoinMode.Round,

                Thickness =
                    1,

                Transparency =
                    0.12,

                ZIndex =
                    2,

                Parent =
                    Frame,
            }
        )

    return InnerBorder,
        OuterRim
end

function Library:AddBlank(Frame: GuiObject, Size: UDim2)
    return New("Frame", {
        BackgroundTransparency = 1,
        Size = Size or UDim2.fromScale(0, 0),
        Parent = Frame,
    })
end

--// Deprecated \\--
function Library:MakeOutline(Frame: GuiObject, Corner: number?, ZIndex: number?)
    warn("Obsidian:MakeOutline is deprecated, please use Obsidian:AddOutline instead.")
    local Holder = New("Frame", {
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromOffset(-2, -2),
        Size = UDim2.new(1, 4, 1, 4),
        ZIndex = ZIndex,
        Parent = Frame,
    })

    local Outline = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = ZIndex,
        Parent = Holder,
    })

    if Corner and Corner > 0 then
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner + 1),
            Parent = Holder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner),
            Parent = Outline,
        })
    end

    return Holder, Outline
end

function Library:AddDraggableLabel(Text: string)
    local Table = {}

    local Label = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(6, 6),
        Text = Text,
        TextSize = 15,
        ZIndex = 10,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Corners, 
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Label,
        })
    )
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        Parent = Label,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Label,
        })
    )
    Library:AddOutline(Label)

    Library:MakeDraggable(Label, Label, true)

    Table.Label = Label

    function Table:SetText(Text: string)
        Label.Text = Text
    end

    function Table:SetVisible(Visible: boolean)
        Label.Visible = Visible
    end

    return Table
end

function Library:AddDraggableButton(
    Text: string,
    Func,
    ExcludeScaling: boolean?
)

    local Table =
        {}

    local ElectricStart =
        Color3.fromRGB(
            57,
            91,
            255
        )

    local ElectricEnd =
        Color3.fromRGB(
            42,
            222,
            255
        )

    local NormalBackground =
        Color3.fromRGB(
            8,
            9,
            12
        )

    local HoverBackground =
        Color3.fromRGB(
            12,
            14,
            20
        )

    local PressedBackground =
        Color3.fromRGB(
            6,
            8,
            12
        )

    local NormalStroke =
        Color3.fromRGB(
            33,
            35,
            42
        )

    local DisplayText =
        tostring(
            Text
            or "HOLY"
        )

    local BaseFont =
        Font.fromEnum(
            Enum.Font.Gotham
        )

    local ToggleFont =
        Font.new(
            BaseFont.Family,
            Enum.FontWeight.ExtraBold,
            Enum.FontStyle.Normal
        )

    local InitialTextSize =
        #DisplayText <= 1
        and 27
        or 24

    local Holder =
        New(
            "Frame",
            {
                Name =
                    "HolyToggleHolder",

                Active =
                    true,

                BackgroundTransparency =
                    1,

                ClipsDescendants =
                    false,

                Position =
                    UDim2.fromOffset(
                        6,
                        6
                    ),

                Size =
                    UDim2.fromOffset(
                        112,
                        42
                    ),

                ZIndex =
                    10,

                Parent =
                    ScreenGui,
            }
        )

    local VisualHolder =
        New(
            "Frame",
            {
                Name =
                    "HolyToggleVisual",

                AnchorPoint =
                    Vector2.new(
                        0.5,
                        0.5
                    ),

                BackgroundTransparency =
                    1,

                ClipsDescendants =
                    false,

                Position =
                    UDim2.fromScale(
                        0.5,
                        0.5
                    ),

                Size =
                    UDim2.fromOffset(
                        112,
                        42
                    ),

                ZIndex =
                    10,

                Parent =
                    Holder,
            }
        )

    local VisualScale =
        New(
            "UIScale",
            {
                Scale =
                    1,

                Parent =
                    VisualHolder,
            }
        )

    local Shadow =
        New(
            "Frame",
            {
                Name =
                    "HolyToggleShadow",

                BackgroundColor3 =
                    Color3.fromRGB(
                        0,
                        0,
                        0
                    ),

                BackgroundTransparency =
                    0.56,

                BorderSizePixel =
                    0,

                Position =
                    UDim2.fromOffset(
                        0,
                        3
                    ),

                Size =
                    UDim2.fromScale(
                        1,
                        1
                    ),

                ZIndex =
                    10,

                Parent =
                    VisualHolder,
            }
        )

    New(
        "UICorner",
        {
            CornerRadius =
                UDim.new(
                    0,
                    14
                ),

            Parent =
                Shadow,
        }
    )

    local Button =
        New(
            "TextButton",
            {
                Name =
                    "HolyToggleButton",

                Active =
                    true,

                AutoButtonColor =
                    false,

                BackgroundColor3 =
                    NormalBackground,

                BackgroundTransparency =
                    0,

                BorderSizePixel =
                    0,

                ClipsDescendants =
                    false,

                FontFace =
                    ToggleFont,

                Position =
                    UDim2.fromOffset(
                        0,
                        0
                    ),

                Size =
                    UDim2.fromScale(
                        1,
                        1
                    ),

                Text =
                    DisplayText,

                TextTransparency =
                    1,

                TextWrapped =
                    false,

                ZIndex =
                    11,

                Parent =
                    VisualHolder,
            }
        )

    New(
        "UICorner",
        {
            CornerRadius =
                UDim.new(
                    0,
                    14
                ),

            Parent =
                Button,
        }
    )

    local ButtonStroke =
        New(
            "UIStroke",
            {
                ApplyStrokeMode =
                    Enum.ApplyStrokeMode.Border,

                Color =
                    NormalStroke,

                LineJoinMode =
                    Enum.LineJoinMode.Round,

                Thickness =
                    1,

                Transparency =
                    0.05,

                Parent =
                    Button,
            }
        )

    local TextShadow =
        New(
            "TextLabel",
            {
                BackgroundTransparency =
                    1,

                FontFace =
                    ToggleFont,

                Position =
                    UDim2.fromOffset(
                        0,
                        1
                    ),

                Size =
                    UDim2.fromScale(
                        1,
                        1
                    ),

                Text =
                    DisplayText,

                TextColor3 =
                    Color3.fromRGB(
                        0,
                        0,
                        0
                    ),

                TextSize =
                    InitialTextSize,

                TextTransparency =
                    0.18,

                TextWrapped =
                    false,

                ZIndex =
                    12,

                Parent =
                    Button,
            }
        )

    local MainText =
        New(
            "TextLabel",
            {
                BackgroundTransparency =
                    1,

                FontFace =
                    ToggleFont,

                Position =
                    UDim2.fromOffset(
                        0,
                        0
                    ),

                Size =
                    UDim2.fromScale(
                        1,
                        1
                    ),

                Text =
                    DisplayText,

                TextColor3 =
                    Color3.fromRGB(
                        255,
                        255,
                        255
                    ),

                TextSize =
                    InitialTextSize,

                TextStrokeColor3 =
                    Color3.fromRGB(
                        0,
                        0,
                        0
                    ),

                TextStrokeTransparency =
                    0.72,

                TextWrapped =
                    false,

                ZIndex =
                    13,

                Parent =
                    Button,
            }
        )

    local TextGradient =
        New(
            "UIGradient",
            {
                Color =
                    ColorSequence.new({
                        ColorSequenceKeypoint.new(
                            0,
                            ElectricStart
                        ),

                        ColorSequenceKeypoint.new(
                            1,
                            ElectricEnd
                        ),
                    }),

                Rotation =
                    0,

                Parent =
                    MainText,
            }
        )

    if not ExcludeScaling then

        table.insert(
            Library.Scales,
            New(
                "UIScale",
                {
                    Parent =
                        Holder,
                }
            )
        )
    end

    local Hovering =
        false

    local Pressing =
        false

    local PressInput =
        nil

    local PressStart =
        nil

    local HolderStart =
        nil

    local Moved =
        false

    local function AnimateButton(
        Scale,
        BackgroundColor,
        StrokeColor,
        StrokeTransparency,
        ShadowTransparency
    )

        if not VisualHolder
        or not VisualHolder.Parent then
            return
        end

        TweenService:Create(
            VisualScale,
            TweenInfo.new(
                0.11,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Scale =
                    Scale,
            }
        ):Play()

        TweenService:Create(
            Button,
            TweenInfo.new(
                0.11,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                BackgroundColor3 =
                    BackgroundColor,
            }
        ):Play()

        TweenService:Create(
            ButtonStroke,
            TweenInfo.new(
                0.11,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Color =
                    StrokeColor,

                Transparency =
                    StrokeTransparency,
            }
        ):Play()

        TweenService:Create(
            Shadow,
            TweenInfo.new(
                0.11,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                BackgroundTransparency =
                    ShadowTransparency,
            }
        ):Play()
    end

    local function FinishPress()

        if Pressing ~= true then
            return
        end

        Pressing =
            false

        local ShouldClick =
            Moved ~= true
            and Holder.Parent ~= nil
            and Library.Unloaded ~= true

        if Hovering then

            AnimateButton(
                1.04,
                HoverBackground,
                ElectricStart,
                0.25,
                0.48
            )

        else

            AnimateButton(
                1,
                NormalBackground,
                NormalStroke,
                0.05,
                0.56
            )
        end

        PressInput =
            nil

        PressStart =
            nil

        HolderStart =
            nil

        if ShouldClick then

            Library:SafeCallback(
                Func,
                Table
            )
        end

        task.defer(function()

            Moved =
                false
        end)
    end

    Library:GiveSignal(
        Button.MouseEnter:Connect(function()

            Hovering =
                true

            if Pressing then
                return
            end

            AnimateButton(
                1.04,
                HoverBackground,
                ElectricStart,
                0.25,
                0.48
            )
        end)
    )

    Library:GiveSignal(
        Button.MouseLeave:Connect(function()

            Hovering =
                false

            if Pressing then
                return
            end

            AnimateButton(
                1,
                NormalBackground,
                NormalStroke,
                0.05,
                0.56
            )
        end)
    )

    Library:GiveSignal(
        Button.InputBegan:Connect(function(Input)

            if not IsClickInput(
                Input
            ) then
                return
            end

            Pressing =
                true

            Moved =
                false

            PressInput =
                Input

            PressStart =
                Input.Position

            HolderStart =
                Holder.Position

            AnimateButton(
                0.94,
                PressedBackground,
                ElectricEnd,
                0.10,
                0.62
            )

            local ChangedConnection

            ChangedConnection =
                Input.Changed:Connect(function()

                    if Input.UserInputState
                        ~= Enum.UserInputState.End then
                        return
                    end

                    FinishPress()

                    if ChangedConnection
                    and ChangedConnection.Connected then

                        ChangedConnection:Disconnect()
                    end
                end)
        end)
    )

    Library:GiveSignal(
        UserInputService.InputChanged:Connect(function(Input)

            if Pressing ~= true
            or not PressInput
            or not PressStart
            or not HolderStart then

                return
            end

            if PressInput.UserInputType
                == Enum.UserInputType.Touch then

                if Input ~= PressInput then
                    return
                end

            elseif Input.UserInputType
                ~= Enum.UserInputType.MouseMovement then

                return
            end

            local Delta =
                Input.Position
                - PressStart

            if Moved ~= true
            and Delta.Magnitude < 7 then

                return
            end

            Moved =
                true

            Holder.Position =
                UDim2.new(
                    HolderStart.X.Scale,
                    HolderStart.X.Offset
                    + Delta.X,

                    HolderStart.Y.Scale,
                    HolderStart.Y.Offset
                    + Delta.Y
                )
        end)
    )

    Library:GiveSignal(
        UserInputService.InputEnded:Connect(function(Input)

            if Pressing ~= true
            or not PressInput then

                return
            end

            if PressInput.UserInputType
                == Enum.UserInputType.Touch then

                if Input ~= PressInput then
                    return
                end

            elseif Input.UserInputType
                ~= Enum.UserInputType.MouseButton1 then

                return
            end

            FinishPress()
        end)
    )

    Table.Holder =
        Holder

    Table.VisualHolder =
        VisualHolder

    Table.Button =
        Button

    Table.Shadow =
        Shadow

    Table.Stroke =
        ButtonStroke

    Table.TextLabel =
        MainText

    Table.TextShadow =
        TextShadow

    Table.Gradient =
        TextGradient

    Table.Scale =
        VisualScale

    function Table:SetText(NewText: string)

        local Value =
            tostring(
                NewText
                or "HOLY"
            )

        local NewTextSize =
            #Value <= 1
            and 27
            or 24

        Button.Text =
            Value

        MainText.Text =
            Value

        MainText.TextSize =
            NewTextSize

        TextShadow.Text =
            Value

        TextShadow.TextSize =
            NewTextSize
    end

    function Table:SetVisible(Visible: boolean)

        Holder.Visible =
            Visible == true
    end

    return Table
end

function Library:AddDraggableMenu(Name: string)
    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 10,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    Library:MakeLine(Holder, {
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(1, 0, 0, 1),
    })

    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        Text = Name,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = Label,
    })

    local Container = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 7),
        Parent = Container,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 7),
        Parent = Container,
    })

    Library:MakeDraggable(Holder, Label, true)
    return Holder, Container
end

function Library:CreateServerFinderHUD(Info)

    Info =
        Info
        or {}

    local Hud = {
        Rows = {},
        FilteredRows = {},
        SearchText = "",

        HideFull = Info.HideFull ~= false,
        AutoRefresh = Info.AutoRefresh == true,
        AutoJoinMode = tostring(Info.AutoJoinMode or "Off"),
        RefreshDelay = math.clamp(
            tonumber(Info.RefreshDelay)
            or 5,
            1,
            60
        ),

        SelectedPets = {},
        SelectedRarities = {},
        SelectedSizes = {},
        SelectedVariants = {},

        FilterPets = {},
        FilterRarities = {},
        FilterSizes = {},
        FilterVariants = {},

        Visible = false,
        Minimized = false,
        FiltersVisible = false,

        SimpleMode =
            Info.SimpleMode == true,

        Scale =
            math.clamp(
                tonumber(Info.Scale)
                or (
                    tonumber(Info.HudScale)
                    and tonumber(Info.HudScale) / 100
                )
                or 0.80,
                0.60,
                1.10
            ),

        OnRefresh = Info.OnRefresh,
        OnJoin = Info.OnJoin,
        OnVisibleChanged = Info.OnVisibleChanged,
        OnSettingsChanged = Info.OnSettingsChanged,
        OnAutoJoinModeChanged = Info.OnAutoJoinModeChanged,
        OnOpenAutoJoinRules = Info.OnOpenAutoJoinRules,
    }

    local Width =
        tonumber(Info.Width)
        or 304

    local Height =
        tonumber(Info.Height)
        or 414

    local CollapsedHeight =
        33

    local RowHeight =
        tonumber(Info.RowHeight)
        or 52

    local FilterWidth =
        tonumber(Info.FilterWidth)
        or 330

    local FilterHeight =
        tonumber(Info.FilterHeight)
        or 356

    local function Clean(value)

        return tostring(value or "")
            :gsub("^%s+", "")
            :gsub("%s+$", "")
    end

    local function AddUnique(list, seen, value)

        value =
            Clean(
                value
            )

        if value == "" then
            return false
        end

        local key =
            value:lower()

        if seen[key] == true then
            return false
        end

        seen[key] =
            true

        table.insert(
            list,
            value
        )

        return true
    end

	    local function NormalizeAutoJoinMode(value)

        local text =
            Clean(
                value
            )
            :lower()

        if text:find("notify", 1, true) then
            return "Notify"
        end

        if text:find("join", 1, true)
        or text:find("best", 1, true) then
            return "Join Best"
        end

        return "Off"
    end

    local function NextAutoJoinMode(value)

        value =
            NormalizeAutoJoinMode(
                value
            )

        if value == "Off" then
            return "Notify"
        end

        if value == "Notify" then
            return "Join Best"
        end

        return "Off"
    end

    local function NormalizeList(list)

        local output =
            {}

        local seen =
            {}

        if type(list) == "table" then

            for _, value in ipairs(list) do

                AddUnique(
                    output,
                    seen,
                    value
                )
            end
        end

        table.sort(output, function(a, b)

            return tostring(a):lower()
                < tostring(b):lower()
        end)

        return output
    end

	    local function SelectionMapFromList(list)

        local output =
            {}

        if type(list) ~= "table" then
            return output
        end

        for key, enabled in pairs(list) do

            local text =
                ""

            if type(key) == "number" then

                text =
                    Clean(
                        enabled
                    )

            elseif enabled == true then

                text =
                    Clean(
                        key
                    )
            end

            if text ~= "" then

                output[text] =
                    true
            end
        end

        return output
    end

    local function SelectionListFromMap(map)

        local output =
            {}

        if type(map) ~= "table" then
            return output
        end

        for key, enabled in pairs(map) do

            if enabled == true then

                local text =
                    Clean(
                        key
                    )

                if text ~= "" then

                    table.insert(
                        output,
                        text
                    )
                end
            end
        end

        table.sort(output, function(a, b)

            return tostring(a):lower()
                < tostring(b):lower()
        end)

        return output
    end

    local function ReadSavedPosition(value)

        if type(value) ~= "table" then
            return nil
        end

        local x =
            tonumber(
                value.X
                or value.x
                or value[1]
            )

        local y =
            tonumber(
                value.Y
                or value.y
                or value[2]
            )

        if not x
        or not y then
            return nil
        end

        return {
            X =
                math.floor(x + 0.5),

            Y =
                math.floor(y + 0.5),
        }
    end

    local function ApplySavedPosition(frame, value)

        if typeof(frame) ~= "Instance" then
            return false
        end

        value =
            ReadSavedPosition(
                value
            )

        if type(value) ~= "table" then
            return false
        end

        frame.Position =
            UDim2.fromOffset(
                value.X,
                value.Y
            )

        return true
    end

    local function GetFramePosition(frame)

        if typeof(frame) ~= "Instance" then
            return nil
        end

        return {
            X =
                math.floor(
                    frame.Position.X.Offset + 0.5
                ),

            Y =
                math.floor(
                    frame.Position.Y.Offset + 0.5
                ),
        }
    end

    local function PositionKey(frame)

        local position =
            GetFramePosition(
                frame
            )

        if type(position) ~= "table" then
            return ""
        end

        return tostring(position.X)
            .. ","
            .. tostring(position.Y)
    end

    local function CountSelected(map)

        local count =
            0

        for _ in pairs(map or {}) do

            count =
                count
                + 1
        end

        return count
    end

    local function CountAllFilters()

        return CountSelected(
            Hud.SelectedPets
        )
        + CountSelected(
            Hud.SelectedRarities
        )
        + CountSelected(
            Hud.SelectedSizes
        )
        + CountSelected(
            Hud.SelectedVariants
        )
    end

    local function RowPetName(row)

        return Clean(
            row.Pet
            or row.petName
            or row.PetName
            or row.DisplayName
            or row.Name
            or row.name
        )
    end

    local function RowRarity(row)

        return Clean(
            row.Rarity
            or row.rarity
        )
    end

    local function RowSizeValues(row)

        local values =
            {}

        local function add(value)

            value =
                Clean(
                    value
                )

            if value ~= "" then

                if value == "Mega" then
                    value =
                        "Huge"
                end

                if value == "Regular" then
                    value =
                        "Normal"
                end

                table.insert(
                    values,
                    value
                )
            end
        end

        add(row.Size or row.size)

        local display =
            Clean(
                row.DisplayName
                or row.Name
                or row.Pet
                or row.petName
            )
            :lower()

        if display:find("big", 1, true) then
            add("Big")
        end

        if display:find("huge", 1, true)
        or display:find("mega", 1, true) then
            add("Huge")
        end

        return values
    end

    local function RowVariantValues(row)

        local values =
            {}

        local function add(value)

            value =
                Clean(
                    value
                )

            if value ~= "" then

                if value == "Normal" then
                    value =
                        "Regular"
                end

                table.insert(
                    values,
                    value
                )
            end
        end

        add(row.Variant or row.variant)
        add(row.Mutation or row.mutation)

        local display =
            Clean(
                row.DisplayName
                or row.Name
                or row.Pet
                or row.petName
            )
            :lower()

        if display:find("rainbow", 1, true) then
            add("Rainbow")
        end

        return values
    end

    local function RowHaystack(row)

        local parts = {
            tostring(row.DisplayName or ""),
            tostring(row.Name or ""),
            tostring(row.Pet or ""),
            tostring(row.petName or ""),
            tostring(row.PetName or ""),
            tostring(row.BestPet or ""),
            tostring(row.BestDisplayName or ""),
            tostring(row.Rarity or ""),
            tostring(row.rarity or ""),
            tostring(row.Size or ""),
            tostring(row.size or ""),
            tostring(row.Variant or ""),
            tostring(row.variant or ""),
            tostring(row.Mutation or ""),
            tostring(row.mutation or ""),
        }

        if type(row.Pets) == "table" then

            for _, pet in ipairs(row.Pets) do

                if type(pet) == "table" then

                    table.insert(parts, tostring(pet.DisplayName or ""))
                    table.insert(parts, tostring(pet.Name or ""))
                    table.insert(parts, tostring(pet.Pet or ""))
                    table.insert(parts, tostring(pet.PetName or ""))
                    table.insert(parts, tostring(pet.Rarity or ""))
                    table.insert(parts, tostring(pet.Size or ""))
                    table.insert(parts, tostring(pet.Variant or ""))
                    table.insert(parts, tostring(pet.Mutation or ""))
                end
            end
        end

        return table.concat(
            parts,
            " "
        ):lower()
    end

    local function ShortJob(value)

        value =
            Clean(
                value
            )

        if #value <= 12 then
            return value
        end

        return value:sub(1, 8)
            .. "..."
    end

    local HudInitialPosition =
        typeof(Info.Position) == "UDim2"
        and Info.Position
        or UDim2.fromOffset(92, 92)

    local HudFrame = New("Frame", {
        BackgroundColor3 = "BackgroundColor",
        BackgroundTransparency = 0.18,
        Position = HudInitialPosition,
        Size = UDim2.fromOffset(Width, Height),
        Visible = false,
        ZIndex = 9000,
        Parent = ScreenGui,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = HudFrame,
        })
    )

    local ServerFinderHudScale =
        New("UIScale", {
            Scale =
                Hud.Scale,

            Parent =
                HudFrame,
        })

    Library:AddOutline(
        HudFrame
    )

    local Header = New("TextButton", {
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 0.36,
        Size = UDim2.new(1, 0, 0, 32),
        Text = "",
        ZIndex = HudFrame.ZIndex + 1,
        Parent = HudFrame,
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -76, 1, 0),
        Text = tostring(Info.Title or "HOLY Server Finder"),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 0.02,
        ZIndex = Header.ZIndex + 1,
        Parent = Header,
    })

    local MinimizeButton = New("TextButton", {
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 0.20,
        Position = UDim2.new(1, -53, 0, 6),
        Size = UDim2.fromOffset(20, 20),
        Text = "−",
        TextSize = 16,
        TextTransparency = 0.20,
        ZIndex = Header.ZIndex + 2,
        Parent = Header,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = MinimizeButton,
        })
    )

    New("UIStroke", {
        Color = "OutlineColor",
        Transparency = 0.24,
        Parent = MinimizeButton,
    })

    local CloseButton = New("TextButton", {
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 0.20,
        Position = UDim2.new(1, -29, 0, 6),
        Size = UDim2.fromOffset(20, 20),
        Text = "×",
        TextSize = 16,
        TextTransparency = 0.20,
        ZIndex = Header.ZIndex + 2,
        Parent = Header,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = CloseButton,
        })
    )

    New("UIStroke", {
        Color = "OutlineColor",
        Transparency = 0.24,
        Parent = CloseButton,
    })

    Library:MakeLine(
        HudFrame,
        {
            Position = UDim2.fromOffset(0, 32),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = HudFrame.ZIndex + 1,
        }
    )

    local Body = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 33),
        Size = UDim2.new(1, 0, 1, -33),
        ZIndex = HudFrame.ZIndex + 1,
        Parent = HudFrame,
    })

    local InfoLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 5),
        Size = UDim2.new(1, -20, 0, 18),
        Text = "Current: --- · 0/0 servers",
        TextSize = 12,
        TextTransparency = 0.42,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = Body.ZIndex + 1,
        Parent = Body,
    })

    local SearchBox = New("TextBox", {
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 0.24,
        ClearTextOnFocus = false,
        PlaceholderText = "Filter pets, blank = all",
        Position = UDim2.fromOffset(10, 31),
        Size = UDim2.new(1, -91, 0, 25),
        Text = "",
        TextSize = 12,
        TextTransparency = 0.06,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = Body.ZIndex + 1,
        Parent = Body,
    })

    New("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = SearchBox,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = SearchBox,
        })
    )

    New("UIStroke", {
        Color = "OutlineColor",
        Transparency = 0.24,
        Parent = SearchBox,
    })

    local RefreshButton = New("TextButton", {
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 0.14,
        Position = UDim2.new(1, -72, 0, 31),
        Size = UDim2.fromOffset(62, 25),
        Text = "Refresh",
        TextSize = 12,
        TextTransparency = 0.10,
        ZIndex = Body.ZIndex + 1,
        Parent = Body,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = RefreshButton,
        })
    )

    New("UIStroke", {
        Color = "AccentColor",
        Transparency = 0.26,
        Parent = RefreshButton,
    })

    local QuickRow = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 64),
        Size = UDim2.new(1, -20, 0, 24),
        Visible = Hud.SimpleMode ~= true,
        ZIndex = Body.ZIndex + 1,
        Parent = Body,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        Padding = UDim.new(0, 6),
        Parent = QuickRow,
    })

    local function MakeSmallButton(parent, text)

        local button = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.32,
            Size = UDim2.fromScale(1, 1),
            Text = text,
            TextSize = 11,
            TextTransparency = 0.44,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = (parent and parent.ZIndex or Body.ZIndex) + 1,
            Parent = parent,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = button,
            })
        )

        New("UIStroke", {
            Color = "OutlineColor",
            Transparency = 0.42,
            Parent = button,
        })

        return button
    end

    local function SetButtonSelected(button, selected)

        button.BackgroundColor3 =
            selected and Library.Scheme.AccentColor
            or Library.Scheme.MainColor

        button.BackgroundTransparency =
            selected and 0.10
            or 0.36

        button.TextTransparency =
            selected and 0.05
            or 0.46
    end

    local AutoRefreshButton =
        MakeSmallButton(
            QuickRow,
            Hud.AutoRefresh and "Auto: ON" or "Auto: OFF"
        )

    local AutoJoinButton =
        MakeSmallButton(
            QuickRow,
            "Join: OFF"
        )

    local FilterButton =
        MakeSmallButton(
            QuickRow,
            "Filters"
        )

    local RulesButton =
        MakeSmallButton(
            QuickRow,
            "Rules"
        )

    RulesButton.BackgroundTransparency =
        0.38

    RulesButton.TextTransparency =
        0.40

    local RowsFrame = New("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        ScrollBarImageColor3 = "OutlineColor",
        ScrollBarThickness = 3,
        Position =
            Hud.SimpleMode
            and UDim2.fromOffset(10, 64)
            or UDim2.fromOffset(10, 97),

        Size =
            Hud.SimpleMode
            and UDim2.new(1, -20, 1, -74)
            or UDim2.new(1, -20, 1, -107),
        ZIndex = Body.ZIndex + 1,
        Parent = Body,
    })

    New("UIListLayout", {
        Padding = UDim.new(0, 7),
        Parent = RowsFrame,
    })

    local EmptyLabel = New("TextLabel", {
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 0.34,
        Size = UDim2.new(1, -4, 0, 58),
        Text = "No fresh servers found\nRefresh or wait for reports",
        TextSize = 12,
        TextTransparency = 0.44,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = Body.ZIndex + 2,
        Parent = RowsFrame,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = EmptyLabel,
        })
    )

    New("UIStroke", {
        Color = "OutlineColor",
        Transparency = 0.46,
        Parent = EmptyLabel,
    })

    local FilterInitialPosition =
        typeof(Info.FilterPosition) == "UDim2"
        and Info.FilterPosition
        or UDim2.fromOffset(414, 92)

    local FilterFrame = New("Frame", {
        BackgroundColor3 = "BackgroundColor",
        BackgroundTransparency = 0.12,
        ClipsDescendants = true,
        Position = FilterInitialPosition,
        Size = UDim2.fromOffset(FilterWidth, FilterHeight),
        Visible = false,
        ZIndex = 9100,
        Parent = ScreenGui,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = FilterFrame,
        })
    )

    local ServerFinderFilterScale =
        New("UIScale", {
            Scale =
                Hud.Scale,

            Parent =
                FilterFrame,
        })

    Library:AddOutline(
        FilterFrame
    )

    local FilterHeader = New("TextButton", {
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 0.30,
        Size = UDim2.new(1, 0, 0, 34),
        Text = "",
        ZIndex = FilterFrame.ZIndex + 1,
        Parent = FilterFrame,
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -48, 1, 0),
        Text = "SERVER FINDER FILTERS",
        TextSize = 14,
        TextTransparency = 0.02,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = FilterHeader.ZIndex + 1,
        Parent = FilterHeader,
    })

    local FilterCloseButton = New("TextButton", {
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 0.20,
        Position = UDim2.new(1, -29, 0, 7),
        Size = UDim2.fromOffset(20, 20),
        Text = "×",
        TextSize = 16,
        TextTransparency = 0.20,
        ZIndex = FilterHeader.ZIndex + 2,
        Parent = FilterHeader,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = FilterCloseButton,
        })
    )

    New("UIStroke", {
        Color = "OutlineColor",
        Transparency = 0.24,
        Parent = FilterCloseButton,
    })

    Library:MakeLine(
        FilterFrame,
        {
            Position = UDim2.fromOffset(0, 34),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = FilterFrame.ZIndex + 1,
        }
    )

    local FilterScroll = New("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        ScrollBarImageColor3 = "OutlineColor",
        ScrollBarThickness = 3,
        Position = UDim2.fromOffset(10, 43),
        Size = UDim2.new(1, -20, 1, -53),
        ZIndex = FilterFrame.ZIndex + 1,
        Parent = FilterFrame,
    })

    New("UIListLayout", {
        Padding = UDim.new(0, 11),
        Parent = FilterScroll,
    })

    New("UIPadding", {
        PaddingBottom = UDim.new(0, 10),
        Parent = FilterScroll,
    })

    local RowObjects =
        {}

    local FilterSections =
        {}

    local LastFilterOptionsSignature =
        ""

    local CurrentServerText =
        "---"

    local SettingsSignalLocked =
        false

    local LastHudPositionKey =
        ""

    local LastFilterPositionKey =
        ""

    local function ApplyServerFinderScale()

        Hud.Scale =
            math.clamp(
                tonumber(Hud.Scale)
                or 0.80,
                0.60,
                1.10
            )

        if ServerFinderHudScale then

            ServerFinderHudScale.Scale =
                Hud.Scale
        end

        if ServerFinderFilterScale then

            ServerFinderFilterScale.Scale =
                Hud.Scale
        end

        return true
    end

    ApplyServerFinderScale()

    function Hud:SetScale(value)

        Hud.Scale =
            math.clamp(
                tonumber(value)
                or Hud.Scale
                or 0.80,
                0.60,
                1.10
            )

        ApplyServerFinderScale()

        return true
    end

    local function NotifySettingsChanged()

        if SettingsSignalLocked == true then
            return
        end

        Library:SafeCallback(
            Hud.OnSettingsChanged,
            Hud
        )
    end

    local function UpdateInfoLabel()

        if InfoLabel == nil then
            return
        end

        Hud.FilteredRows =
            type(Hud.FilteredRows) == "table"
            and Hud.FilteredRows
            or {}

        Hud.Rows =
            type(Hud.Rows) == "table"
            and Hud.Rows
            or {}

        local function countUniqueServers(rows)

            local seen =
                {}

            local count =
                0

            for _, row in ipairs(rows or {}) do

                if type(row) == "table" then

                    local jobId =
                        Clean(
                            row.JobId
                            or row.jobId
                            or row.ServerId
                            or row.id
                            or row.Id
                            or row.Key
                        )

                    if jobId == "" then

                        jobId =
                            tostring(row)
                    end

                    if seen[jobId] ~= true then

                        seen[jobId] =
                            true

                        count =
                            count + 1
                    end
                end
            end

            return count
        end

        InfoLabel.Text =
            "Current: "
            .. tostring(CurrentServerText)
            .. " · "
            .. tostring(countUniqueServers(Hud.FilteredRows))
            .. "/"
            .. tostring(countUniqueServers(Hud.Rows))
            .. " server(s) · "
            .. tostring(#Hud.FilteredRows)
            .. " pet(s)"
    end

	    local function UpdateAutoJoinButtonText()

        Hud.AutoJoinMode =
            NormalizeAutoJoinMode(
                Hud.AutoJoinMode
            )

        if Hud.AutoJoinMode == "Notify" then

            AutoJoinButton.Text =
                "Join: NOTIFY"

            SetButtonSelected(
                AutoJoinButton,
                true
            )

        elseif Hud.AutoJoinMode == "Join Best" then

            AutoJoinButton.Text =
                "Join: BEST"

            SetButtonSelected(
                AutoJoinButton,
                true
            )

        else

            AutoJoinButton.Text =
                "Join: OFF"

            SetButtonSelected(
                AutoJoinButton,
                false
            )
        end
    end

    local function UpdateFilterButtonText()

        local count =
            CountAllFilters()

        FilterButton.Text =
            "F:"
            .. tostring(count)

        FilterButton.BackgroundColor3 =
            Library.Scheme.MainColor

        FilterButton.BackgroundTransparency =
            count > 0
            and 0.22
            or 0.38

        FilterButton.TextTransparency =
            count > 0
            and 0.14
            or 0.46

        local stroke =
            FilterButton:FindFirstChildOfClass(
                "UIStroke"
            )

        if stroke then

            stroke.Color =
                count > 0
                and Library.Scheme.AccentColor
                or Library.Scheme.OutlineColor

            stroke.Transparency =
                count > 0
                and 0.30
                or 0.46
        end
    end

    local function BuildCombinedOptions(baseList, _getter)

        return NormalizeList(
            baseList
        )
    end

    local function ListSignature(list)

        local values =
            NormalizeList(
                list
            )

        return table.concat(
            values,
            "\31"
        )
    end

    local function CurrentFilterOptionsSignature()

        return table.concat({
            ListSignature(
                Hud.FilterPets
            ),

            ListSignature(
                Hud.FilterRarities
            ),

            ListSignature(
                Hud.FilterSizes
            ),

            ListSignature(
                Hud.FilterVariants
            ),
        }, "\30")
    end

    local function DestroyFilterSections()

        for _, section in ipairs(FilterSections) do

            if section
            and section.Parent then

                section:Destroy()
            end
        end

        table.clear(
            FilterSections
        )
    end

    local function MakeSection(title, values, selectedMap)

        values =
            NormalizeList(
                values
            )

        if #values <= 0 then
            return
        end

        local Section = New("Frame", {
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, -4, 0, 0),
            ZIndex = FilterScroll.ZIndex + 1,
            Parent = FilterScroll,
        })

        table.insert(
            FilterSections,
            Section
        )

        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            Parent = Section,
        })

        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 17),
            Text = title,
            TextSize = 13,
            TextTransparency = 0.12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = Section.ZIndex + 1,
            Parent = Section,
        })

        local Grid = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            ZIndex = Section.ZIndex + 1,
            Parent = Section,
        })

        local columns =
            tostring(title):find("Pets", 1, true)
            and 2
            or 3

        local GridLayout = New("UIGridLayout", {
            CellPadding = UDim2.fromOffset(7, 7),
            CellSize = UDim2.new(1 / columns, -7, 0, 25),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Grid,
        })

        local function resizeGrid()

            Grid.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    GridLayout.AbsoluteContentSize.Y
                )
        end

        GridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
            resizeGrid
        )

        for _, value in ipairs(values) do

            local button =
                MakeSmallButton(
                    Grid,
                    value
                )

            SetButtonSelected(
                button,
                selectedMap[value] == true
            )

            button.MouseButton1Click:Connect(function()

                selectedMap[value] =
                    selectedMap[value] ~= true
                    and true
                    or nil

                SetButtonSelected(
                    button,
                    selectedMap[value] == true
                )

                UpdateFilterButtonText()

                Hud:Refresh()

                NotifySettingsChanged()
            end)
        end

        task.defer(
            resizeGrid
        )
    end

    local function RebuildFilterPopup()

        DestroyFilterSections()

        MakeSection(
            "Always Show Pets",
            BuildCombinedOptions(
                Hud.FilterPets,
                function(row)

                    return RowPetName(
                        row
                    )
                end
            ),
            Hud.SelectedPets
        )

        MakeSection(
            "Always Show Rarities",
            BuildCombinedOptions(
                Hud.FilterRarities,
                function(row)

                    return RowRarity(
                        row
                    )
                end
            ),
            Hud.SelectedRarities
        )

        MakeSection(
            "Always Show Sizes",
            BuildCombinedOptions(
                Hud.FilterSizes,
                function(row)

                    return RowSizeValues(
                        row
                    )
                end
            ),
            Hud.SelectedSizes
        )

        MakeSection(
            "Always Show Variants",
            BuildCombinedOptions(
                Hud.FilterVariants,
                function(row)

                    return RowVariantValues(
                        row
                    )
                end
            ),
            Hud.SelectedVariants
        )
        local Rules = New("Frame", {
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, -4, 0, 0),
            ZIndex = FilterScroll.ZIndex + 1,
            Parent = FilterScroll,
        })

        table.insert(
            FilterSections,
            Rules
        )

        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            Parent = Rules,
        })

        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 17),
            Text = "Rules",
            TextSize = 13,
            TextTransparency = 0.12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = Rules.ZIndex + 1,
            Parent = Rules,
        })

        local RuleRow = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 25),
            ZIndex = Rules.ZIndex + 1,
            Parent = Rules,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 7),
            Parent = RuleRow,
        })

        local HideFullButton =
            MakeSmallButton(
                RuleRow,
                Hud.HideFull and "Hide full: ON" or "Hide full: OFF"
            )

        SetButtonSelected(
            HideFullButton,
            Hud.HideFull
        )

        local ClearFiltersButton =
            MakeSmallButton(
                RuleRow,
                "Clear Filters"
            )

        SetButtonSelected(
            ClearFiltersButton,
            false
        )

        HideFullButton.MouseButton1Click:Connect(function()

            Hud.HideFull =
                Hud.HideFull ~= true

            HideFullButton.Text =
                Hud.HideFull
                and "Hide full: ON"
                or "Hide full: OFF"

            SetButtonSelected(
                HideFullButton,
                Hud.HideFull
            )

            Hud:Refresh()

            NotifySettingsChanged()
        end)

        local DelayRow = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 25),
            ZIndex = Rules.ZIndex + 1,
            Parent = Rules,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 7),
            Parent = DelayRow,
        })

        local DelayLabel = New("TextLabel", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.36,
            Size = UDim2.fromScale(1, 1),
            Text = "Refresh delay",
            TextSize = 11,
            TextTransparency = 0.46,
            ZIndex = DelayRow.ZIndex + 1,
            Parent = DelayRow,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = DelayLabel,
            })
        )

        New("UIStroke", {
            Color = "OutlineColor",
            Transparency = 0.42,
            Parent = DelayLabel,
        })

        local RefreshDelayInput = New("TextBox", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.24,
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = tostring(
                math.floor(
                    tonumber(Hud.RefreshDelay)
                    or 5
                )
            ),
            PlaceholderText = "5",
            TextSize = 11,
            TextTransparency = 0.08,
            ZIndex = DelayRow.ZIndex + 1,
            Parent = DelayRow,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = RefreshDelayInput,
            })
        )

        New("UIStroke", {
            Color = "AccentColor",
            Transparency = 0.42,
            Parent = RefreshDelayInput,
        })

        local function ApplyRefreshDelayInput()

            local raw =
                Clean(
                    RefreshDelayInput.Text
                )
                :gsub("[sS]", "")

            local value =
                math.clamp(
                    tonumber(raw)
                    or tonumber(Hud.RefreshDelay)
                    or 5,
                    1,
                    60
                )

            Hud.RefreshDelay =
                value

            if math.abs(value - math.floor(value)) < 0.001 then

                RefreshDelayInput.Text =
                    tostring(
                        math.floor(value)
                    )

            else

                RefreshDelayInput.Text =
                    tostring(
                        math.floor(value * 10 + 0.5) / 10
                    )
            end
        end

        RefreshDelayInput.FocusLost:Connect(function()

            ApplyRefreshDelayInput()

            NotifySettingsChanged()
        end)

        ClearFiltersButton.MouseButton1Click:Connect(function()

            table.clear(
                Hud.SelectedPets
            )

            table.clear(
                Hud.SelectedRarities
            )

            table.clear(
                Hud.SelectedSizes
            )

            table.clear(
                Hud.SelectedVariants
            )

            RebuildFilterPopup()

            Hud:Refresh()

            NotifySettingsChanged()
        end)

        UpdateFilterButtonText()
    end

    local function RowMatchesSearch(row)

        local search =
            Hud.SearchText:lower()

        if search == "" then
            return true
        end

        local haystack =
            RowHaystack(
                row
            )

        for part in search:gmatch("[^,%s]+") do

            if haystack:find(
                part,
                1,
                true
            ) then

                return true
            end
        end

        return false
    end

    local function RowPets(row)

        local pets =
            {}

        if type(row.Pets) == "table" then

            for _, pet in ipairs(row.Pets) do

                if type(pet) == "table" then

                    table.insert(
                        pets,
                        pet
                    )
                end
            end
        end

        if #pets <= 0
        and type(row) == "table" then

            table.insert(
                pets,
                row
            )
        end

        return pets
    end

    local function TextMatchesSelection(text, map)

        text =
            tostring(text or "")
                :lower()

        if text == "" then
            return false
        end

        for value in pairs(map or {}) do

            local needle =
                Clean(
                    value
                )
                :lower()

            if needle ~= ""
            and text:find(
                needle,
                1,
                true
            ) then

                return true
            end
        end

        return false
    end

    local function PetText(pet)

        return table.concat({
            tostring(pet.DisplayName or ""),
            tostring(pet.Name or ""),
            tostring(pet.Pet or ""),
            tostring(pet.PetName or ""),
            tostring(pet.BestPet or ""),
            tostring(pet.BestDisplayName or ""),
        }, " ")
    end

    local function PetMatchesSelectedPet(pet)

        if CountSelected(Hud.SelectedPets) <= 0 then
            return false
        end

        return TextMatchesSelection(
            PetText(
                pet
            ),
            Hud.SelectedPets
        )
    end

    local function PetMatchesSelectedRarity(pet)

        if CountSelected(Hud.SelectedRarities) <= 0 then
            return false
        end

        local rarity =
            Clean(
                pet.Rarity
                or pet.rarity
            )
            :lower()

        if rarity == "" then
            return false
        end

        for value in pairs(Hud.SelectedRarities) do

            if rarity == Clean(value):lower() then

                return true
            end
        end

        return false
    end

    local function NormalizeFinderSize(value)

        local text =
            Clean(
                value
            )
            :lower()
            :gsub("%s+", " ")

        if text == "mega" then
            return "huge"
        end

        if text == "regular" then
            return "normal"
        end

        return text
    end

    local function NormalizeFinderVariant(value)

        local text =
            Clean(
                value
            )
            :lower()
            :gsub("%s+", " ")

        if text == "normal" then
            return "regular"
        end

        return text
    end

    local function PetMatchesSize(pet, wantedSize)

        wantedSize =
            NormalizeFinderSize(
                wantedSize
            )

        if wantedSize == "" then
            return false
        end

        local size =
            NormalizeFinderSize(
                pet.Size
                or pet.size
                or ""
            )

        local text =
            table.concat({
                tostring(pet.DisplayName or ""),
                tostring(pet.Name or ""),
                tostring(pet.Pet or ""),
                tostring(pet.PetName or ""),
                tostring(pet.Size or ""),
                tostring(pet.size or ""),
            }, " ")
            :lower()

        local hasBig =
            size == "big"
            or text:find("big", 1, true) ~= nil

        local hasHuge =
            size == "huge"
            or text:find("huge", 1, true) ~= nil
            or text:find("mega", 1, true) ~= nil

        local hasNormal =
            (
                size == ""
                or size == "normal"
            )
            and hasBig ~= true
            and hasHuge ~= true

        if wantedSize == "normal" then
            return hasNormal == true
        end

        if wantedSize == "big" then
            return hasBig == true
        end

        if wantedSize == "huge" then
            return hasHuge == true
        end

        return false
    end

    local function PetMatchesVariant(pet, wantedVariant)

        wantedVariant =
            NormalizeFinderVariant(
                wantedVariant
            )

        if wantedVariant == "" then
            return false
        end

        local variant =
            NormalizeFinderVariant(
                pet.Variant
                or pet.variant
                or pet.Mutation
                or pet.mutation
                or ""
            )

        local text =
            table.concat({
                tostring(pet.DisplayName or ""),
                tostring(pet.Name or ""),
                tostring(pet.Pet or ""),
                tostring(pet.PetName or ""),
                tostring(pet.Variant or ""),
                tostring(pet.variant or ""),
                tostring(pet.Mutation or ""),
                tostring(pet.mutation or ""),
            }, " ")
            :lower()

        local hasRainbow =
            variant == "rainbow"
            or text:find("rainbow", 1, true) ~= nil

        local hasRegular =
            (
                variant == ""
                or variant == "regular"
            )
            and hasRainbow ~= true

        if wantedVariant == "regular" then
            return hasRegular == true
        end

        if wantedVariant == "rainbow" then
            return hasRainbow == true
        end

        return false
    end

    local function PetMatchesSelectedSize(pet, allowNormal)

        if CountSelected(Hud.SelectedSizes) <= 0 then
            return true
        end

        for size in pairs(Hud.SelectedSizes) do

            local normalized =
                NormalizeFinderSize(
                    size
                )

            if normalized == "normal"
            and allowNormal ~= true then
                continue
            end

            if PetMatchesSize(
                pet,
                size
            ) == true then

                return true
            end
        end

        return false
    end

    local function PetMatchesSelectedVariant(pet, allowRegular)

        if CountSelected(Hud.SelectedVariants) <= 0 then
            return true
        end

        for variant in pairs(Hud.SelectedVariants) do

            local normalized =
                NormalizeFinderVariant(
                    variant
                )

            if normalized == "regular"
            and allowRegular ~= true then
                continue
            end

            if PetMatchesVariant(
                pet,
                variant
            ) == true then

                return true
            end
        end

        return false
    end

    local function RowMatchesAlwaysFilters(row)

        if CountAllFilters() <= 0 then
            return true
        end

        local hasAnchors =
            CountSelected(
                Hud.SelectedPets
            )
            + CountSelected(
                Hud.SelectedRarities
            )
            > 0

        local hasSizeFilters =
            CountSelected(
                Hud.SelectedSizes
            )
            > 0

        local hasVariantFilters =
            CountSelected(
                Hud.SelectedVariants
            )
            > 0

        for _, pet in ipairs(RowPets(row)) do

            if hasAnchors == true then

                local anchorMatched =
                    PetMatchesSelectedPet(
                        pet
                    )
                    or PetMatchesSelectedRarity(
                        pet
                    )

                if anchorMatched == true
                and PetMatchesSelectedSize(
                    pet,
                    true
                ) == true
                and PetMatchesSelectedVariant(
                    pet,
                    true
                ) == true then

                    return true
                end

            else

                local broadSizeMatched =
                    hasSizeFilters == true
                    and PetMatchesSelectedSize(
                        pet,
                        false
                    ) == true

                local broadVariantMatched =
                    hasVariantFilters == true
                    and PetMatchesSelectedVariant(
                        pet,
                        false
                    ) == true

                if broadSizeMatched == true
                or broadVariantMatched == true then

                    return true
                end
            end
        end

        return false
    end

    local function RowIsFull(row)

        local playing =
            tonumber(row.Playing or row.playing or row.Players or row.players)
            or 0

        local maxPlayers =
            tonumber(row.MaxPlayers or row.maxPlayers)
            or 8

        return maxPlayers > 0
            and playing >= maxPlayers
    end

    local function RowIsCurrentServer(row)

        if type(row) ~= "table" then
            return false
        end

        if row.IsCurrentServer == true then
            return true
        end

        local jobId =
            Clean(
                row.JobId
                or row.jobId
                or row.ServerId
                or row.id
            )

        return jobId ~= ""
            and jobId == tostring(game.JobId)
    end

    local function RowReportAge(row)

        if type(row) ~= "table" then
            return 999999
        end

        local reportedAt =
            tonumber(row.ReportedAt or row.reportedAt)
            or 0

        if reportedAt <= 0 then
            return 0
        end

        return math.max(
            0,
            os.time() - reportedAt
        )
    end

    local function RowTimeLeft(row)

        if type(row) ~= "table" then
            return nil
        end

        local now =
            os.time()

        local expiresAt =
            tonumber(row.ExpiresAt or row.expiresAt)
            or 0

        if expiresAt > 0 then
            return expiresAt - now
        end

        local rawTimeLeft =
            tonumber(row.TimeLeft or row.timeLeft)

        if not rawTimeLeft then
            return nil
        end

        local reportedAt =
            tonumber(row.ReportedAt or row.reportedAt)
            or 0

        if reportedAt > 0 then

            return rawTimeLeft
                - math.max(
                    0,
                    now - reportedAt
                )
        end

        return rawTimeLeft
    end

    local function RowIsExpired(row)

        if type(row) ~= "table" then
            return false
        end

        if row.HideFromFinder == true
        or row.Expired == true then
            return true
        end

        local now =
            os.time()

        local reportedAt =
            tonumber(row.ReportedAt or row.reportedAt)
            or 0

        local maxReportAge =
            tonumber(row.MaxReportAge or row.maxReportAge)

        if reportedAt > 0
        and maxReportAge
        and maxReportAge > 0
        and now - reportedAt > maxReportAge then

            return true
        end

        local timeLeft =
            RowTimeLeft(
                row
            )

        if timeLeft == nil then
            return false
        end

        return timeLeft <= 0
    end

    local function RowJoinState(row)

        if type(row) ~= "table" then
            return "Stale", false
        end

        if RowIsCurrentServer(row) == true then
            return "Current", false
        end

        if RowIsFull(row) == true then
            return "Full", false
        end

        if RowIsExpired(row) == true then
            return "Gone", false
        end

        local state =
            Clean(
                row.JoinState
                or row.Freshness
                or row.freshness
            )
            :lower()

        if state == "stale"
        or state == "late"
        or state == "aging"
        or state == "fresh" then

            return "Join",
                true
        end

        local timeLeft =
            RowTimeLeft(
                row
            )

        local minLife =
            tonumber(row.ManualMinLife or row.manualMinLife)
            or 15

        if timeLeft ~= nil
        and timeLeft > 0
        and timeLeft < minLife then

            return "Join",
                true
        end

        local reportedAt =
            tonumber(row.ReportedAt or row.reportedAt)
            or 0

        local maxManualAge =
            tonumber(row.ManualJoinMaxAge or row.manualJoinMaxAge)
            or 20

        if reportedAt > 0
        and RowReportAge(row) > maxManualAge then

            return "Join",
                true
        end

        if row.JoinEnabled == false
        or row.JoinDisabled == true then

            local text =
                Clean(
                    row.JoinText
                    or row.Freshness
                    or "Stale"
                )

            if text == "" then
                text =
                    "Stale"
            end

            return text,
                false
        end

        local text =
            Clean(
                row.JoinText
                or "Join"
            )

        if text == "" then
            text =
                "Join"
        end

        return text,
            true
    end

    local function RowJoinAllowed(row)

        local _text,
            enabled =
            RowJoinState(
                row
            )

        return enabled == true
    end

    local function RowRarityColor(row)

        local rarity =
            RowRarity(
                row
            )

        local colors = {
            Common =
                Color3.fromRGB(
                    148,
                    163,
                    184
                ),

            Uncommon =
                Color3.fromRGB(
                    74,
                    222,
                    128
                ),

            Rare =
                Color3.fromRGB(
                    96,
                    165,
                    250
                ),

            Epic =
                Color3.fromRGB(
                    192,
                    132,
                    252
                ),

            Legendary =
                Color3.fromRGB(
                    250,
                    204,
                    21
                ),

            Mythic =
                Color3.fromRGB(
                    168,
                    85,
                    247
                ),

            Mythical =
                Color3.fromRGB(
                    168,
                    85,
                    247
                ),

            Super =
                Color3.fromRGB(
                    244,
                    114,
                    182
                ),

            Secret =
                Color3.fromRGB(
                    248,
                    113,
                    113
                ),
        }

        return colors[rarity]
            or Library.Scheme.AccentColor
    end

    local function RowCleanTitleText(value)

        local text =
            Clean(
                value
            )

        text =
            text:gsub(
                "%s*%([^%)]+%)%s*$",
                ""
            )

        text =
            text:gsub(
                "%s+",
                " "
            )

        return Clean(
            text
        )
    end

    local function RowNormalizeSizeText(value)

        local text =
            Clean(
                value
            )

        if text == "Mega" then
            return "Huge"
        end

        if text == "Regular" then
            return "Normal"
        end

        return text
    end

    local function RowNormalizeVariantText(value)

        local text =
            Clean(
                value
            )

        if text == "Regular" then
            return "Normal"
        end

        return text
    end

    local function RowBuildFallbackTitle(row)

        row =
            type(row) == "table"
            and row
            or {}

        local pet =
            Clean(
                row.BasePet
                or row.BestPet
                or row.PetName
                or row.Pet
                or row.Name
                or "Unknown Pet"
            )

        pet =
            RowCleanTitleText(
                pet
            )

        if pet == "" then
            pet =
                "Unknown Pet"
        end

        local size =
            RowNormalizeSizeText(
                row.Size
                or row.size
            )

        local variant =
            RowNormalizeVariantText(
                row.Variant
                or row.variant
                or row.Mutation
                or row.mutation
            )

        local parts =
            {}

        if size ~= ""
        and size ~= "Normal"
        and size ~= "Any" then

            table.insert(
                parts,
                size
            )
        end

        if variant ~= ""
        and variant ~= "Normal"
        and variant ~= "Any" then

            table.insert(
                parts,
                variant
            )
        end

        table.insert(
            parts,
            pet
        )

        local title =
            table.concat(
                parts,
                " "
            )

        local count =
            math.floor(
                tonumber(
                    row.PetCount
                    or row.Count
                    or row.Amount
                )
                or 1
            )

        if count > 1
        and not title:lower():find(" x" .. tostring(count), 1, true) then

            title =
                title
                .. " x"
                .. tostring(count)
        end

        return title
    end

    local function RowName(row)

        row =
            type(row) == "table"
            and row
            or {}

        local title =
            RowCleanTitleText(
                row.DisplayName
                or row.BestDisplayName
                or row.PetName
                or row.Pet
                or row.Name
            )

        if title ~= ""
        and title ~= "Unknown Pet" then
            return title
        end

        return RowBuildFallbackTitle(
            row
        )
    end

    local function RowFormatShortTime(seconds)

        seconds =
            math.max(
                0,
                math.floor(
                    tonumber(seconds)
                    or 0
                )
            )

        if seconds >= 60 then

            local minutes =
                math.floor(seconds / 60)

            local remaining =
                seconds % 60

            return tostring(minutes)
                .. "m"
                .. tostring(remaining)
                .. "s"
        end

        return tostring(seconds)
            .. "s"
    end

    local function RowFreshnessText(row)

        local joinText,
            joinEnabled =
            RowJoinState(
                row
            )

        if joinEnabled ~= true then

            return Clean(
                joinText
            ) ~= ""
            and Clean(joinText)
            or "Stale"
        end

        local freshness =
            Clean(
                row.Freshness
                or row.freshness
            )

        if freshness ~= "" then
            return freshness
        end

        local maxAutoAge =
            tonumber(
                row.AutoJoinMaxAge
                or row.autoJoinMaxAge
            )
            or 12

        if RowReportAge(row) > maxAutoAge then
            return "Aging"
        end

        return "Fresh"
    end

    local function RowMeta(row)

        row =
            type(row) == "table"
            and row
            or {}

        local parts =
            {}

        local rarity =
            RowRarity(
                row
            )

        if rarity ~= "" then

            table.insert(
                parts,
                rarity
            )
        end

        local playing =
            tonumber(
                row.Playing
                or row.playing
                or row.Players
                or row.players
            )
            or 0

        local maxPlayers =
            tonumber(
                row.MaxPlayers
                or row.maxPlayers
            )
            or 8

        table.insert(
            parts,
            tostring(playing)
            .. "/"
            .. tostring(maxPlayers)
        )

        local timeLeft =
            RowTimeLeft(
                row
            )

        if timeLeft ~= nil then

            table.insert(
                parts,
                RowFormatShortTime(
                    timeLeft
                )
            )

        else

            local lifeText =
                Clean(
                    row.LifeText
                    or row.TimeLeftText
                    or row.timeLeftText
                    or row.Timer
                )

            if lifeText ~= "" then

                table.insert(
                    parts,
                    lifeText
                )
            end
        end

        table.insert(
            parts,
            RowFreshnessText(
                row
            )
        )

        return table.concat(
            parts,
            " · "
        )
    end

    local function RowVisualRiskState(row)

        if type(row) ~= "table" then
            return "stale"
        end

        if RowIsCurrentServer(row) == true then
            return "current"
        end

        if RowIsFull(row) == true then
            return "full"
        end

        if RowIsExpired(row) == true then
            return "gone"
        end

        local explicit =
            Clean(
                row.JoinState
                or row.Freshness
                or row.freshness
            )
            :lower()

        if explicit == "fresh"
        or explicit == "aging"
        or explicit == "stale"
        or explicit == "late" then

            return explicit
        end

        local timeLeft =
            RowTimeLeft(
                row
            )

        local minLife =
            tonumber(row.ManualMinLife or row.manualMinLife)
            or 15

        if timeLeft ~= nil
        and timeLeft > 0
        and timeLeft < minLife then

            return "late"
        end

        local reportedAt =
            tonumber(row.ReportedAt or row.reportedAt)
            or 0

        local maxManualAge =
            tonumber(row.ManualJoinMaxAge or row.manualJoinMaxAge)
            or 20

        if reportedAt > 0
        and RowReportAge(row) > maxManualAge then

            return "stale"
        end

        local maxAutoAge =
            tonumber(row.AutoJoinMaxAge or row.autoJoinMaxAge)
            or 12

        if RowReportAge(row) > maxAutoAge then
            return "aging"
        end

        return "fresh"
    end

    local function RowJoinButtonColor(row)

        local state =
            RowVisualRiskState(
                row
            )

        if state == "late" then
            return Color3.fromRGB(185, 28, 28)
        end

        if state == "stale" then
            return Color3.fromRGB(234, 88, 12)
        end

        if state == "aging" then
            return Color3.fromRGB(202, 138, 4)
        end

        return Color3.fromRGB(39, 142, 68)
    end

    local function RowJoinStrokeColor(row)

        local state =
            RowVisualRiskState(
                row
            )

        if state == "late" then
            return Color3.fromRGB(248, 113, 113)
        end

        if state == "stale" then
            return Color3.fromRGB(251, 146, 60)
        end

        if state == "aging" then
            return Color3.fromRGB(250, 204, 21)
        end

        return Color3.fromRGB(74, 222, 128)
    end

    local function RowIsVisualDisabled(row)

        local _joinText,
            joinEnabled =
            RowJoinState(
                row
            )

        return joinEnabled ~= true
    end

    local function RowBackgroundTransparency(row)

        if RowIsVisualDisabled(row) == true then
            return 0.48
        end

        local state =
            RowVisualRiskState(
                row
            )

        if state == "late" then
            return 0.38
        end

        if state == "stale" then
            return 0.35
        end

        if state == "aging" then
            return 0.31
        end

        return 0.24
    end

    local function RowStrokeTransparency(row)

        if RowIsVisualDisabled(row) == true then
            return 0.58
        end

        return 0.30
    end


    local function ClearRows()

        for _, object in ipairs(RowObjects) do

            local holder =
                object

            if type(object) == "table" then
                holder =
                    object.Holder
            end

            if holder
            and holder.Parent then

                holder:Destroy()
            end
        end

        table.clear(
            RowObjects
        )
    end

    local function CreateRow(row)

        local joinText,
            joinEnabled =
            RowJoinState(
                row
            )

        local disabled =
            joinEnabled ~= true

        local rarityColor =
            RowRarityColor(
                row
            )

        local Holder = New("Frame", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = RowBackgroundTransparency(row),
            Size = UDim2.new(1, -4, 0, RowHeight),
            ZIndex = Body.ZIndex + 2,
            Parent = RowsFrame,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Holder,
            })
        )

        local HolderStroke = New("UIStroke", {
            Color = "OutlineColor",
            Transparency = RowStrokeTransparency(row),
            Parent = Holder,
        })

        local RarityBar = New("Frame", {
            BackgroundColor3 = rarityColor,
            BackgroundTransparency = disabled and 0.42 or 0,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(0, 3, 1, 0),
            ZIndex = Holder.ZIndex + 1,
            Parent = Holder,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = RarityBar,
            })
        )

        local Dot = New("Frame", {
            BackgroundColor3 = rarityColor,
            BackgroundTransparency = disabled and 0.45 or 0.02,
            Position = UDim2.fromOffset(10, 8),
            Size = UDim2.fromOffset(6, 6),
            ZIndex = Holder.ZIndex + 1,
            Parent = Holder,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Dot,
            })
        )

        local NameLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(21, 4),
            Size = UDim2.new(1, -91, 0, 18),
            Text = RowName(row),
            TextSize = 12,
            TextTransparency = disabled and 0.40 or 0.02,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = Holder.ZIndex + 1,
            Parent = Holder,
        })

        local MetaLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(21, 25),
            Size = UDim2.new(1, -91, 0, 18),
            Text = RowMeta(row),
            TextSize = 11,
            TextTransparency = disabled and 0.62 or 0.34,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = Holder.ZIndex + 1,
            Parent = Holder,
        })

        local JoinButton = New("TextButton", {
            Active = disabled ~= true,
            BackgroundColor3 = disabled and "BackgroundColor" or RowJoinButtonColor(row),
            BackgroundTransparency = disabled and 0.28 or 0.03,
            Position = UDim2.new(1, -65, 0, 9),
            Size = UDim2.fromOffset(56, 34),
            Text = joinText,
            TextSize = 12,
            TextTransparency = disabled and 0.62 or 0.04,
            ZIndex = Holder.ZIndex + 1,
            Parent = Holder,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = JoinButton,
            })
        )

        local JoinStroke = New("UIStroke", {
            Color = disabled and "OutlineColor" or RowJoinStrokeColor(row),
            Transparency = disabled and 0.54 or 0.18,
            Parent = JoinButton,
        })

        JoinButton.MouseButton1Click:Connect(function()

            if RowJoinAllowed(row) ~= true then
                return
            end

            Library:SafeCallback(
                Hud.OnJoin,
                row,
                Hud
            )
        end)

        table.insert(
            RowObjects,
            {
                Holder =
                    Holder,

                Stroke =
                    HolderStroke,

                RarityBar =
                    RarityBar,

                Dot =
                    Dot,

                Row =
                    row,

                NameLabel =
                    NameLabel,

                MetaLabel =
                    MetaLabel,

                JoinButton =
                    JoinButton,

                JoinStroke =
                    JoinStroke,
            }
        )
    end

    local function UpdateVisibleRowObjects()

        local needsRefresh =
            false

        for _, object in ipairs(RowObjects) do

            if type(object) == "table"
            and type(object.Row) == "table" then

                local row =
                    object.Row

                if RowIsExpired(row) == true then

                    needsRefresh =
                        true

                    if object.Holder then
                        object.Holder.Visible =
                            false
                    end

                else

                    local joinText,
                        joinEnabled =
                        RowJoinState(
                            row
                        )

                    local disabled =
                        joinEnabled ~= true

                    local rarityColor =
                        RowRarityColor(
                            row
                        )

                    if object.Holder then

                        object.Holder.BackgroundTransparency =
                            RowBackgroundTransparency(
                                row
                            )
                    end

                    if object.Stroke then

                        object.Stroke.Transparency =
                            RowStrokeTransparency(
                                row
                            )
                    end

                    if object.RarityBar then

                        object.RarityBar.BackgroundColor3 =
                            rarityColor

                        object.RarityBar.BackgroundTransparency =
                            disabled and 0.42
                            or 0
                    end

                    if object.Dot then

                        object.Dot.BackgroundColor3 =
                            rarityColor

                        object.Dot.BackgroundTransparency =
                            disabled and 0.45
                            or 0.02
                    end

                    if object.NameLabel then

                        object.NameLabel.Text =
                            RowName(
                                row
                            )

                        object.NameLabel.TextTransparency =
                            disabled and 0.40
                            or 0.02
                    end

                    if object.MetaLabel then

                        object.MetaLabel.Text =
                            RowMeta(
                                row
                            )

                        object.MetaLabel.TextTransparency =
                            disabled and 0.62
                            or 0.34
                    end

                    if object.JoinButton then

                        object.JoinButton.Active =
                            disabled ~= true

                        object.JoinButton.Text =
                            joinText

                        object.JoinButton.BackgroundColor3 =
                            disabled and Library.Scheme.BackgroundColor
                            or RowJoinButtonColor(row)

                        object.JoinButton.BackgroundTransparency =
                            disabled and 0.28
                            or 0.03

                        object.JoinButton.TextTransparency =
                            disabled and 0.62
                            or 0.04
                    end

                    if object.JoinStroke then

                        object.JoinStroke.Color =
                            disabled and Library.Scheme.OutlineColor
                            or RowJoinStrokeColor(row)

                        object.JoinStroke.Transparency =
                            disabled and 0.54
                            or 0.18
                    end
                end
            end
        end

        if needsRefresh == true then

            task.defer(function()

                if HudFrame.Parent ~= nil then

                    Hud:Refresh()
                end
            end)
        end
    end
	
    function Hud:Refresh()

        ClearRows()

        local filtered =
            {}

        for _, row in ipairs(Hud.Rows) do

            if RowIsExpired(row) == true then
                continue
            end

            if Hud.HideFull == true
            and RowIsFull(row) == true then
                continue
            end

            if RowMatchesSearch(row) ~= true then
                continue
            end

            if RowMatchesAlwaysFilters(row) ~= true then
                continue
            end

            table.insert(
                filtered,
                row
            )
        end

        Hud.FilteredRows =
            filtered

        EmptyLabel.Visible =
            #filtered <= 0

        if #Hud.Rows <= 0 then

            EmptyLabel.Text =
                "No fresh servers found\nRefresh or wait for reports"

        else

            EmptyLabel.Text =
                "No servers match filters\nChange filters or search"
        end

        for _, row in ipairs(filtered) do

            CreateRow(
                row
            )
        end

        UpdateInfoLabel()
        UpdateFilterButtonText()
        UpdateVisibleRowObjects()
    end

    function Hud:SetFilterOptions(options)

        options =
            type(options) == "table"
            and options
            or {}

        if type(options.Pets) == "table" then

            Hud.FilterPets =
                NormalizeList(
                    options.Pets
                )
        end

        if type(options.Rarities) == "table" then

            Hud.FilterRarities =
                NormalizeList(
                    options.Rarities
                )
        end

        if type(options.Sizes) == "table" then

            Hud.FilterSizes =
                NormalizeList(
                    options.Sizes
                )
        end

        if type(options.Variants) == "table" then

            Hud.FilterVariants =
                NormalizeList(
                    options.Variants
                )
        end

        local signature =
            CurrentFilterOptionsSignature()

        if signature ~= LastFilterOptionsSignature then

            LastFilterOptionsSignature =
                signature

            RebuildFilterPopup()
        end

        Hud:Refresh()
    end

	    function Hud:SetAutoJoinMode(mode)

        Hud.AutoJoinMode =
            NormalizeAutoJoinMode(
                mode
            )

        UpdateAutoJoinButtonText()

        NotifySettingsChanged()

        return Hud.AutoJoinMode
    end

    function Hud:SetRows(rows)

        Hud.Rows =
            type(rows) == "table"
            and rows
            or {}

        Hud:Refresh()
    end

    function Hud:SetCurrentServer(jobId)

        jobId =
            Clean(
                jobId
            )

        if jobId == "" then
            jobId =
                "---"
        end

        CurrentServerText =
            ShortJob(
                jobId
            )

        if type(UpdateInfoLabel) == "function" then

            UpdateInfoLabel()
        end
    end

    function Hud:GetSettings()

        return {
            Visible =
                Hud.Visible == true,

            AutoRefresh =
                Hud.AutoRefresh == true,

            RefreshDelay =
                math.clamp(
                    tonumber(Hud.RefreshDelay)
                    or 5,
                    1,
                    60
                ),

            HideFull =
                Hud.HideFull ~= false,

            HudScale =
                math.floor(
                    (
                        tonumber(Hud.Scale)
                        or 0.80
                    )
                    * 100
                    + 0.5
                ),

            Scale =
                tonumber(Hud.Scale)
                or 0.80,

            AutoJoinMode =
                NormalizeAutoJoinMode(
                    Hud.AutoJoinMode
                ),

            SelectedPets =
                SelectionListFromMap(
                    Hud.SelectedPets
                ),

            SelectedRarities =
                SelectionListFromMap(
                    Hud.SelectedRarities
                ),

            SelectedSizes =
                SelectionListFromMap(
                    Hud.SelectedSizes
                ),

            SelectedVariants =
                SelectionListFromMap(
                    Hud.SelectedVariants
                ),

            Minimized =
                Hud.Minimized == true,

            Position =
                GetFramePosition(
                    HudFrame
                ),

            FilterPosition =
                GetFramePosition(
                    FilterFrame
                ),
        }
    end

    function Hud:ApplySettings(settings)

        settings =
            type(settings) == "table"
            and settings
            or {}

        SettingsSignalLocked =
            true

        Hud.AutoRefresh =
            settings.AutoRefresh == true

        Hud.RefreshDelay =
            math.clamp(
                tonumber(settings.RefreshDelay)
                or tonumber(Hud.RefreshDelay)
                or 5,
                1,
                60
            )

        Hud.HideFull =
            settings.HideFull ~= false

        Hud:SetScale(
            settings.Scale
            or (
                tonumber(settings.HudScale)
                and tonumber(settings.HudScale) / 100
            )
            or Hud.Scale
            or 0.80
        )

        Hud.AutoJoinMode =
            NormalizeAutoJoinMode(
                settings.AutoJoinMode
                or Hud.AutoJoinMode
                or "Off"
            )

        Hud.SelectedPets =
            SelectionMapFromList(
                settings.SelectedPets
            )

        Hud.SelectedRarities =
            SelectionMapFromList(
                settings.SelectedRarities
            )

        Hud.SelectedSizes =
            SelectionMapFromList(
                settings.SelectedSizes
                or settings.SelectedTraits
            )

        Hud.SelectedVariants =
            SelectionMapFromList(
                settings.SelectedVariants
                or settings.SelectedTraits
            )

        ApplySavedPosition(
            HudFrame,
            settings.Position
        )

        ApplySavedPosition(
            FilterFrame,
            settings.FilterPosition
        )

        AutoRefreshButton.Text =
            Hud.AutoRefresh
            and "Auto: ON"
            or "Auto: OFF"

        SetButtonSelected(
            AutoRefreshButton,
            Hud.AutoRefresh
        )

	        UpdateAutoJoinButtonText()

    LastFilterOptionsSignature =
        CurrentFilterOptionsSignature()

    RebuildFilterPopup()

    Hud:Refresh()

        Hud:SetMinimized(
            settings.Minimized == true
        )

        LastHudPositionKey =
            PositionKey(
                HudFrame
            )

        LastFilterPositionKey =
            PositionKey(
                FilterFrame
            )

        SettingsSignalLocked =
            false
    end

    function Hud:OpenFilters()

        if Hud.SimpleMode == true then

            Hud:CloseFilters()

            return
        end

        if Hud.Visible ~= true then
            return
        end

        local viewport =
            workspace.CurrentCamera
            and workspace.CurrentCamera.ViewportSize
            or Vector2.new(1280, 720)

        local finderX =
            HudFrame.AbsolutePosition.X

        local finderY =
            HudFrame.AbsolutePosition.Y

        local finderW =
            HudFrame.AbsoluteSize.X

        local finderH =
            HudFrame.AbsoluteSize.Y

        local x =
            finderX
            + finderW
            + 8

        local y =
            finderY

        if x + FilterWidth > viewport.X - 8 then

            x =
                finderX
                - FilterWidth
                - 8
        end

        if x < 8 then

            x =
                math.min(
                    math.max(
                        8,
                        finderX
                    ),
                    math.max(
                        8,
                        viewport.X - FilterWidth - 8
                    )
                )

            y =
                finderY
                + finderH
                + 8
        end

        if y + FilterHeight > viewport.Y - 8 then

            y =
                finderY
                - FilterHeight
                - 8
        end

        if y < 8 then

            y =
                math.max(
                    8,
                    math.min(
                        finderY,
                        viewport.Y - FilterHeight - 8
                    )
                )
        end

        FilterFrame.Position =
            UDim2.fromOffset(
                math.floor(x),
                math.floor(y)
            )

        Hud.FiltersVisible =
            true

        FilterFrame.Visible =
            true
    end

    function Hud:CloseFilters()

        Hud.FiltersVisible =
            false

        FilterFrame.Visible =
            false
    end

    function Hud:ToggleFilters()

        if Hud.FiltersVisible == true then

            Hud:CloseFilters()

        else

            Hud:OpenFilters()
        end
    end

    function Hud:SetMinimized(minimized)

        Hud.Minimized =
            minimized == true

        Body.Visible =
            Hud.Minimized ~= true

        HudFrame.Size =
            Hud.Minimized == true
            and UDim2.fromOffset(Width, CollapsedHeight)
            or UDim2.fromOffset(Width, Height)

        MinimizeButton.Text =
            Hud.Minimized == true
            and "+"
            or "−"

        if Hud.Minimized == true then

            Hud:CloseFilters()
        end

        NotifySettingsChanged()
    end

    function Hud:SetVisible(visible)

        local newVisible =
            visible == true

        local changed =
            Hud.Visible ~= newVisible

        Hud.Visible =
            newVisible

        HudFrame.Visible =
            Hud.Visible

        if Hud.Visible ~= true then

            Hud:CloseFilters()
        end

        if changed == true then

            Library:SafeCallback(
                Hud.OnVisibleChanged,
                Hud.Visible,
                Hud
            )
        end
    end

    function Hud:Show()

        Hud:SetVisible(
            true
        )
    end

    function Hud:Hide()

        Hud:SetVisible(
            false
        )
    end

    function Hud:Toggle()

        Hud:SetVisible(
            Hud.Visible ~= true
        )
    end

    function Hud:Destroy()

        pcall(function()

            FilterFrame:Destroy()
        end)

        HudFrame:Destroy()
    end

    CloseButton.MouseButton1Click:Connect(function()

        Hud:Hide()
    end)

    MinimizeButton.MouseButton1Click:Connect(function()

        Hud:SetMinimized(
            Hud.Minimized ~= true
        )
    end)

    FilterCloseButton.MouseButton1Click:Connect(function()

        Hud:CloseFilters()
    end)

    RefreshButton.MouseButton1Click:Connect(function()

        Library:SafeCallback(
            Hud.OnRefresh,
            Hud
        )
    end)

	    AutoJoinButton.MouseButton1Click:Connect(function()

        Hud.AutoJoinMode =
            NextAutoJoinMode(
                Hud.AutoJoinMode
            )

        UpdateAutoJoinButtonText()

        NotifySettingsChanged()

        Library:SafeCallback(
            Hud.OnAutoJoinModeChanged,
            Hud.AutoJoinMode,
            Hud
        )
    end)

    RulesButton.MouseButton1Click:Connect(function()

        Library:SafeCallback(
            Hud.OnOpenAutoJoinRules,
            Hud
        )
    end)

    AutoRefreshButton.MouseButton1Click:Connect(function()

        Hud.AutoRefresh =
            Hud.AutoRefresh ~= true

        AutoRefreshButton.Text =
            Hud.AutoRefresh
            and "Auto: ON"
            or "Auto: OFF"

        SetButtonSelected(
            AutoRefreshButton,
            Hud.AutoRefresh
        )

		    UpdateAutoJoinButtonText()

        NotifySettingsChanged()
    end)

    FilterButton.MouseButton1Click:Connect(function()

        Hud:ToggleFilters()
    end)

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()

        Hud.SearchText =
            Clean(
                SearchBox.Text
            )

        Hud:Refresh()
    end)

    task.spawn(function()

        local nextRefreshAt =
            0

        while HudFrame.Parent ~= nil do

            if Hud.Visible == true then

                UpdateVisibleRowObjects()

                local hudPositionKey =
                    PositionKey(
                        HudFrame
                    )

                local filterPositionKey =
                    PositionKey(
                        FilterFrame
                    )

                if hudPositionKey ~= LastHudPositionKey
                or filterPositionKey ~= LastFilterPositionKey then

                    LastHudPositionKey =
                        hudPositionKey

                    LastFilterPositionKey =
                        filterPositionKey

                    NotifySettingsChanged()
                end

                if Hud.AutoRefresh == true
                and type(Hud.OnRefresh) == "function"
                and os.clock() >= nextRefreshAt then

                    nextRefreshAt =
                        os.clock()
                        + math.clamp(
                            tonumber(Hud.RefreshDelay)
                            or 5,
                            1,
                            60
                        )

                    Library:SafeCallback(
                        Hud.OnRefresh,
                        Hud
                    )
                end
            end

            task.wait(
                1
            )
        end
    end)

    Hud.FilterPets =
        NormalizeList(
            Info.FilterPets
        )

    Hud.FilterRarities =
        NormalizeList(
            Info.FilterRarities
        )

    Hud.FilterSizes =
        NormalizeList(
            Info.FilterSizes
        )

    Hud.FilterVariants =
        NormalizeList(
            Info.FilterVariants
        )

    Hud.SelectedPets =
        SelectionMapFromList(
            Info.SelectedPets
        )

    Hud.SelectedRarities =
        SelectionMapFromList(
            Info.SelectedRarities
        )

    Hud.SelectedSizes =
        SelectionMapFromList(
            Info.SelectedSizes
            or Info.SelectedTraits
        )

    Hud.SelectedVariants =
        SelectionMapFromList(
            Info.SelectedVariants
            or Info.SelectedTraits
        )

    ApplySavedPosition(
        HudFrame,
        Info.Position
    )

    ApplySavedPosition(
        FilterFrame,
        Info.FilterPosition
    )

    Hud:SetScale(
        Info.Scale
        or (
            tonumber(Info.HudScale)
            and tonumber(Info.HudScale) / 100
        )
        or Hud.Scale
        or 0.80
    )

    SetButtonSelected(
        AutoRefreshButton,
        Hud.AutoRefresh
    )

    Hud:SetCurrentServer(
        Info.CurrentServer
        or ""
    )

    RebuildFilterPopup()

    Hud:Refresh()

    SettingsSignalLocked =
        true

    Hud:SetMinimized(
        Info.Minimized == true
    )

    SettingsSignalLocked =
        false

    LastHudPositionKey =
        PositionKey(
            HudFrame
        )

    LastFilterPositionKey =
        PositionKey(
            FilterFrame
        )

    Library:MakeDraggable(
        HudFrame,
        Header,
        true
    )

    Library:MakeDraggable(
        FilterFrame,
        FilterHeader,
        true
    )

    return Hud
end

--// Context Menu \\--
local CurrentMenu
function Library:AddContextMenu(
    Holder: GuiObject,
    Size: UDim2 | () -> (),
    Offset: { [number]: number } | () -> {},
    List: number?,
    ActiveCallback: (Active: boolean) -> ()?,
    IgnoreCornerRadius: boolean?
)
    local Menu
    local ParentGui = Holder:FindFirstAncestorOfClass("ScreenGui")

    if ParentGui ~= ScreenGui
    and (
        Library.ActiveLoading
        and ParentGui ~= Library.ActiveLoading.ScreenGui
    ) then

        ParentGui =
            ScreenGui
    end

    local MenuZIndex =
        math.max(
            10,
            (
                tonumber(
                    Holder.ZIndex
                )
                or 1
            )
            + 10
        )

    if List then
        Menu = New("ScrollingFrame", {
            AutomaticCanvasSize = List == 2 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            AutomaticSize = List == 1 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            BackgroundColor3 = "BackgroundColor",
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarImageColor3 = "OutlineColor",
            ScrollBarThickness = List == 2 and 2 or 0,
            Size = typeof(Size) == "function" and Size() or Size,
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Visible = false,
            ZIndex = MenuZIndex,
            Parent = ParentGui,
        })
    else
        Menu = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Size = typeof(Size) == "function" and Size() or Size,
            Visible = false,
            ZIndex = MenuZIndex,
            Parent = ParentGui,
        })
    end

    Library:RegisterSurface(
        Menu,
        "Overlay",
        0.02
    )

    Menu.Active =
        true

    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Menu,
        })
    )

    New("UIStroke", {
        Color = "OutlineColor",
        Parent = Menu,
    })

    if IgnoreCornerRadius ~= true then
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            })
        )
    end

    local Table = {
        Active = false,
        Holder = Holder,
        Menu = Menu,
        List = nil,
        Signal = nil,

        Size = Size,
    }

    if List then
        Table.List = New("UIListLayout", {
            Parent = Menu,
        })
    end

    function Table:Open()
        if CurrentMenu == Table then
            return
        elseif CurrentMenu then
            CurrentMenu:Close()
        end

        CurrentMenu = Table
        Table.Active = true

        if typeof(Offset) == "function" then
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset()[2])
            )
        else
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset[2])
            )
        end
        Menu.Size = typeof(Table.Size) == "function" and Table.Size() or Table.Size
        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, true)
        end

        Menu.Visible = true

        Table.Signal = Holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            if typeof(Offset) == "function" then
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset()[2])
                )
            else
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset[2])
                )
            end
        end)
    end

    function Table:Close()
        if CurrentMenu ~= Table then
            return
        end
        Menu.Visible = false

        if Table.Signal then
            Table.Signal:Disconnect()
            Table.Signal = nil
        end
        Table.Active = false
        CurrentMenu = nil
        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, false)
        end
    end

    function Table:Toggle()
        if Table.Active then
            Table:Close()
        else
            Table:Open()
        end
    end

    function Table:SetSize(Size)
        Table.Size = Size
        Menu.Size = typeof(Size) == "function" and Size() or Size
    end

    return Table
end

function Library:CloseCurrentMenu()

    if CurrentMenu then

        CurrentMenu:Close()

        return true
    end

    return false
end

local DropdownPicker = {
    Active = false,
    Built = false,
    Config = nil,
    Draft = nil,
    Rows = {},
    SelectedOnly = false,
    AnimationToken = 0,
    RefreshToken = 0,
}

function DropdownPicker:CreateButton(Parent, Text, ZIndex)
    local Button = New("TextButton", {
        BackgroundColor3 = "AccentColor",
        BackgroundTransparency = 0.92,
        Size = UDim2.fromOffset(80, 30),
        Text = Text,
        TextSize = 12,
        TextTransparency = 0.22,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = ZIndex,
        Parent = Parent,
    })

    New("UICorner", {
        CornerRadius = UDim.new(0, 7),
        Parent = Button,
    })

    New("UIStroke", {
        Color = "AccentColor",
        Transparency = 0.78,
        Parent = Button,
    })

    Button.MouseEnter:Connect(function()
        if not Button.Active then
            return
        end

        local Selected = Button == self.AllButton and not self.SelectedOnly
            or Button == self.SelectedButton and self.SelectedOnly
            or Button == self.MasterButton
                and self.Config
                and self.Config.Info.MasterValue ~= nil
                and type(self.Draft) == "table"
                and self.Draft[self.Config.Info.MasterValue] == true

        TweenService:Create(Button, Library.TweenInfo, {
            BackgroundTransparency = Button == self.ApplyButton and 0.1 or Selected and 0.64 or 0.82,
            TextTransparency = 0.05,
        }):Play()
    end)

    Button.MouseLeave:Connect(function()
        if not Button.Active then
            return
        end

        local Selected = Button == self.AllButton and not self.SelectedOnly
            or Button == self.SelectedButton and self.SelectedOnly
            or Button == self.MasterButton
                and self.Config
                and self.Config.Info.MasterValue ~= nil
                and type(self.Draft) == "table"
                and self.Draft[self.Config.Info.MasterValue] == true

        TweenService:Create(Button, Library.TweenInfo, {
            BackgroundTransparency = Button == self.ApplyButton and 0.18 or Selected and 0.72 or 0.92,
            TextTransparency = Button == self.ApplyButton and 0 or Selected and 0 or 0.22,
        }):Play()
    end)

    return Button
end

function DropdownPicker:Create()
    if self.Built then
        return
    end

    self.Built = true

    local Z = 14000
    local SearchIcon = Library:GetIcon("search")
    local CloseIcon = Library:GetIcon("x")

    self.Overlay = New("TextButton", {
        Active = true,
        BackgroundColor3 = "DarkColor",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        Visible = false,
        ZIndex = Z,
        Parent = ScreenGui,
    })

    self.Panel = New("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "BackgroundColor",
        GroupTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 8),
        Size = UDim2.new(1, -24, 1, -24),
        Visible = false,
        ZIndex = Z + 1,
        Parent = ScreenGui,
    })

    Library:RegisterSurface(self.Panel, "Overlay", 0.01)
    Library:AddOutline(self.Panel)

    New("UICorner", {
        CornerRadius = UDim.new(0, 14),
        Parent = self.Panel,
    })

    New("UISizeConstraint", {
        MaxSize = Vector2.new(640, 560),
        Parent = self.Panel,
    })

    self.PanelScale = New("UIScale", {
        Scale = 0.96,
        Parent = self.Panel,
    })

    self.Title = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(1, -190, 0, 44),
        Text = "Select options",
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = Z + 2,
        Parent = self.Panel,
    })

    self.CountLabel = New("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -52, 0, 0),
        Size = UDim2.fromOffset(118, 44),
        Text = "0 selected",
        TextSize = 12,
        TextTransparency = 0.42,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = Z + 2,
        Parent = self.Panel,
    })

    self.CloseButton = New("ImageButton", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = "MainColor",
        BackgroundTransparency = 0.2,
        Image = CloseIcon and CloseIcon.Url or "",
        ImageColor3 = "FontColor",
        ImageRectOffset = CloseIcon and CloseIcon.ImageRectOffset or Vector2.zero,
        ImageRectSize = CloseIcon and CloseIcon.ImageRectSize or Vector2.zero,
        ImageTransparency = 0.28,
        Position = UDim2.new(1, -12, 0, 8),
        Size = UDim2.fromOffset(28, 28),
        ZIndex = Z + 3,
        Parent = self.Panel,
    })

    New("UICorner", {
        CornerRadius = UDim.new(0, 7),
        Parent = self.CloseButton,
    })

    New("UIStroke", {
        Color = "OutlineColor",
        Transparency = 0.35,
        Parent = self.CloseButton,
    })

    self.SearchHolder = New("Frame", {
        BackgroundColor3 = "MainColor",
        Position = UDim2.fromOffset(12, 46),
        Size = UDim2.new(1, -24, 0, 36),
        ZIndex = Z + 2,
        Parent = self.Panel,
    })

    New("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.SearchHolder,
    })

    self.SearchStroke = New("UIStroke", {
        Color = "OutlineColor",
        Parent = self.SearchHolder,
    })

    New("ImageLabel", {
        Image = SearchIcon and SearchIcon.Url or "",
        ImageColor3 = "FontColor",
        ImageRectOffset = SearchIcon and SearchIcon.ImageRectOffset or Vector2.zero,
        ImageRectSize = SearchIcon and SearchIcon.ImageRectSize or Vector2.zero,
        ImageTransparency = 0.45,
        Position = UDim2.fromOffset(10, 10),
        Size = UDim2.fromOffset(16, 16),
        ZIndex = Z + 3,
        Parent = self.SearchHolder,
    })

    self.SearchBox = New("TextBox", {
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        PlaceholderText = "Search options...",
        Position = UDim2.fromOffset(34, 0),
        Size = UDim2.new(1, -44, 1, 0),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = Z + 3,
        Parent = self.SearchHolder,
    })

    self.MasterButton = self:CreateButton(
        self.Panel,
        "Enable every option",
        Z + 3
    )

    self.MasterButton.Position =
        UDim2.fromOffset(
            12,
            90
        )

    self.MasterButton.Size =
        UDim2.new(
            1,
            -24,
            0,
            30
        )

    self.MasterButton.Visible =
        false

    self.Toolbar = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 90),
        Size = UDim2.new(1, -24, 0, 30),
        ZIndex = Z + 2,
        Parent = self.Panel,
    })

    New("UIGridLayout", {
        CellPadding = UDim2.fromOffset(6, 0),
        CellSize = UDim2.new(0.25, -5, 1, 0),
        FillDirectionMaxCells = 4,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Toolbar,
    })

    self.AllButton = self:CreateButton(self.Toolbar, "Browse", Z + 3)
    self.AllButton.LayoutOrder = 1

    self.SelectedButton = self:CreateButton(self.Toolbar, "Selected", Z + 3)
    self.SelectedButton.LayoutOrder = 2

    self.SelectShownButton = self:CreateButton(self.Toolbar, "Select shown", Z + 3)
    self.SelectShownButton.LayoutOrder = 3

    self.ClearButton = self:CreateButton(self.Toolbar, "Clear", Z + 3)
    self.ClearButton.LayoutOrder = 4

    self.FilterToolbar = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 170),
        Size = UDim2.new(1, -24, 0, 30),
        ZIndex = Z + 2,
        Parent = self.Panel,
    })

    New("UIGridLayout", {
        CellPadding = UDim2.fromOffset(6, 0),
        CellSize = UDim2.new(1 / 3, -4, 1, 0),
        FillDirectionMaxCells = 3,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.FilterToolbar,
    })

    self.WorldButton = self:CreateButton(
        self.FilterToolbar,
        "World: Current",
        Z + 3
    )

    self.WorldButton.LayoutOrder = 1

    self.RarityButton = self:CreateButton(
        self.FilterToolbar,
        "Rarity: All",
        Z + 3
    )

    self.RarityButton.LayoutOrder = 2

    self.SortButton = self:CreateButton(
        self.FilterToolbar,
        "Sort: Shop order",
        Z + 3
    )

    self.SortButton.LayoutOrder = 3

    self.GridHolder = New("Frame", {
        BackgroundColor3 = "MainColor",
        Position = UDim2.fromOffset(12, 208),
        Size = UDim2.new(1, -24, 1, -266),
        ZIndex = Z + 2,
        Parent = self.Panel,
    })

    New("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = self.GridHolder,
    })

    New("UIStroke", {
        Color = "OutlineColor",
        Transparency = 0.25,
        Parent = self.GridHolder,
    })

    self.Grid = New("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollBarImageColor3 = "AccentColor",
        ScrollBarImageTransparency = 0.28,
        ScrollBarThickness = 3,
        Size = UDim2.fromScale(1, 1),
        TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        ZIndex = Z + 3,
        Parent = self.GridHolder,
    })

    New("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = self.Grid,
    })

    self.GridLayout = New("UIGridLayout", {
        CellPadding = UDim2.fromOffset(6, 6),
        CellSize = UDim2.fromOffset(280, 34),
        FillDirection = Enum.FillDirection.Horizontal,
        FillDirectionMaxCells = 2,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Grid,
    })

    self.EmptyLabel = New("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, -32, 0, 40),
        Text = "No matching options",
        TextSize = 14,
        TextTransparency = 0.5,
        Visible = false,
        ZIndex = Z + 4,
        Parent = self.GridHolder,
    })

    self.Footer = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 1, -48),
        Size = UDim2.new(1, -24, 0, 36),
        ZIndex = Z + 2,
        Parent = self.Panel,
    })

    self.SummaryLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -178, 1, 0),
        Text = "0 selected",
        TextSize = 12,
        TextTransparency = 0.42,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = Z + 3,
        Parent = self.Footer,
    })

    self.ApplyButton = self:CreateButton(self.Footer, "Apply", Z + 3)
    self.ApplyButton.AnchorPoint = Vector2.new(1, 0.5)
    self.ApplyButton.BackgroundTransparency = 0.18
    self.ApplyButton.Position = UDim2.new(1, 0, 0.5, 0)
    self.ApplyButton.Size = UDim2.fromOffset(88, 32)

    self.CancelButton = self:CreateButton(self.Footer, "Cancel", Z + 3)
    self.CancelButton.AnchorPoint = Vector2.new(1, 0.5)
    self.CancelButton.Position = UDim2.new(1, -96, 0.5, 0)
    self.CancelButton.Size = UDim2.fromOffset(76, 32)

    self.Overlay.MouseButton1Click:Connect(function()
        self:Close()
    end)

    self.CloseButton.MouseButton1Click:Connect(function()
        self:Close()
    end)

    self.CancelButton.MouseButton1Click:Connect(function()
        self:Close()
    end)

    self.ApplyButton.MouseButton1Click:Connect(function()
        self:Apply()
    end)

    self.MasterButton.MouseButton1Click:Connect(function()
        if not (
            self.Config
            and self.Config.Dropdown.Multi
            and self.Config.Info.MasterValue ~= nil
        ) then
            return
        end

        local MasterValue =
            self.Config.Info.MasterValue

        if self.Draft[MasterValue] == true then
            table.clear(self.Draft)
        else
            table.clear(self.Draft)
            self.Draft[MasterValue] = true
        end

        self:RefreshRows()
    end)

    self.AllButton.MouseButton1Click:Connect(function()
        self.SelectedOnly = false
        self.Grid.CanvasPosition = Vector2.zero
        self:RefreshRows()
    end)

    self.SelectedButton.MouseButton1Click:Connect(function()
        self.SelectedOnly = true
        self.Grid.CanvasPosition = Vector2.zero
        self:RefreshRows()
    end)

    self.SelectShownButton.MouseButton1Click:Connect(function()
        if not (self.Config and self.Config.Dropdown.Multi) then
            return
        end

        local MasterValue =
            self.Config.Info.MasterValue

        if MasterValue ~= nil then
            self.Draft[MasterValue] = nil
        end

        for _, Row in self.Rows do
            if Row.Container.Visible and not Row.Disabled then
                self.Draft[Row.Value] = true
            end
        end

        self:RefreshRows()
    end)

    self.ClearButton.MouseButton1Click:Connect(function()
        if not (self.Config and self.Config.Dropdown.Multi) then
            return
        end

        local MasterValue =
            self.Config.Info.MasterValue

        if MasterValue ~= nil
        and self.Draft[MasterValue] == true then
            table.clear(self.Draft)

            for _, Row in self.Rows do
                if not Row.Container.Visible
                and not Row.Disabled then
                    self.Draft[Row.Value] = true
                end
            end
        else
            for _, Row in self.Rows do
                if Row.Container.Visible then
                    self.Draft[Row.Value] = nil
                end
            end
        end

        self:RefreshRows()
    end)

    self.WorldButton.MouseButton1Click:Connect(function()
        self:CyclePickerState(
            "World",
            self:GetWorldOptions()
        )
    end)

    self.RarityButton.MouseButton1Click:Connect(function()
        self:CyclePickerState(
            "Rarity",
            self:GetRarityOptions()
        )
    end)

    self.SortButton.MouseButton1Click:Connect(function()
        self:CyclePickerState(
            "Sort",
            self:GetSortOptions(),
            true
        )
    end)

    self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if self.Active then
            self.Grid.CanvasPosition = Vector2.zero
            self:RefreshRows()
        end
    end)

    self.SearchBox.Focused:Connect(function()
        TweenService:Create(self.SearchStroke, Library.TweenInfo, {
            Color = Library.Scheme.AccentColor,
            Thickness = 1.5,
        }):Play()
    end)

    self.SearchBox.FocusLost:Connect(function()
        TweenService:Create(self.SearchStroke, Library.TweenInfo, {
            Color = Library.Scheme.OutlineColor,
            Thickness = 1,
        }):Play()
    end)

    self.Grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        self:UpdateGrid()
    end)
end

function DropdownPicker:GetInfo()
    return self.Config
        and self.Config.Info
        or {}
end

function DropdownPicker:GetPickerState()
    local Info = self:GetInfo()

    if type(Info.PickerState) ~= "table" then
        Info.PickerState = {}
    end

    return Info.PickerState
end

function DropdownPicker:GetMetadata(Value)
    local Info = self:GetInfo()

    local Metadata =
        type(Info.ValueMetadata) == "table"
        and Info.ValueMetadata
        or self.Config
            and type(self.Config.Dropdown.ValueMetadata) == "table"
            and self.Config.Dropdown.ValueMetadata
        or {}

    return type(Metadata[Value]) == "table"
        and Metadata[Value]
        or {}
end

function DropdownPicker:GetWorldOptions()
    local Info = self:GetInfo()

    if type(Info.PickerWorlds) == "table"
    and #Info.PickerWorlds > 0 then
        return Info.PickerWorlds
    end

    return {
        "Current World",
        "Garden Valley",
        "Fall Harvest",
        "All Worlds",
    }
end

function DropdownPicker:GetRarityOptions()
    local Info = self:GetInfo()

    local Options = {
        "All Rarities",
    }

    local Seen = {
        ["All Rarities"] = true,
    }

    if type(Info.PickerRarities) == "table"
    and #Info.PickerRarities > 0 then
        for _, Rarity in Info.PickerRarities do
            Rarity = tostring(Rarity)

            if Rarity ~= ""
            and not Seen[Rarity] then
                Seen[Rarity] = true

                table.insert(
                    Options,
                    Rarity
                )
            end
        end
    elseif self.Config then
        local Rows = {}

        for _, Value in self.Config.Dropdown.Values do
            if Value ~= Info.MasterValue then
                local Meta =
                    self:GetMetadata(Value)

                local Rarity =
                    tostring(
                        Meta.Rarity
                        or ""
                    )

                if Rarity ~= ""
                and not Seen[Rarity] then
                    Seen[Rarity] = true

                    table.insert(
                        Rows,
                        {
                            Name = Rarity,
                            Rank =
                                tonumber(
                                    Meta.RarityRank
                                )
                                or 0,
                        }
                    )
                end
            end
        end

        table.sort(Rows, function(Left, Right)
            if Left.Rank ~= Right.Rank then
                return Left.Rank > Right.Rank
            end

            return Left.Name < Right.Name
        end)

        for _, Row in Rows do
            table.insert(
                Options,
                Row.Name
            )
        end
    end

    return Options
end

function DropdownPicker:GetSortOptions()
    local Info = self:GetInfo()

    if type(Info.PickerSorts) == "table"
    and #Info.PickerSorts > 0 then
        return Info.PickerSorts
    end

    return {
        "Shop Order",
        "Rarity: Highest",
        "Price: Highest",
        "Price: Lowest",
        "Name",
    }
end

function DropdownPicker:NormalizePickerState()
    local State =
        self:GetPickerState()

    local Worlds =
        self:GetWorldOptions()

    local Rarities =
        self:GetRarityOptions()

    local Sorts =
        self:GetSortOptions()

    if not table.find(
        Worlds,
        State.World
    ) then
        State.World =
            Worlds[1]
            or "Current World"
    end

    if not table.find(
        Rarities,
        State.Rarity
    ) then
        State.Rarity =
            Rarities[1]
            or "All Rarities"
    end

    if not table.find(
        Sorts,
        State.Sort
    ) then
        State.Sort =
            Sorts[1]
            or "Shop Order"
    end

    return State
end

function DropdownPicker:CyclePickerState(
    Key,
    Options,
    Rebuild
)
    if not (
        self.Config
        and self.Config.Info.RichPicker == true
        and type(Options) == "table"
        and #Options > 0
    ) then
        return
    end

    local State =
        self:NormalizePickerState()

    local CurrentIndex =
        table.find(
            Options,
            State[Key]
        )
        or 0

    local NextIndex =
        CurrentIndex % #Options + 1

    State[Key] =
        Options[NextIndex]

    self.Grid.CanvasPosition =
        Vector2.zero

    Library:SafeCallback(
        self.Config.Info.OnPickerStateChanged,
        State,
        self.Config.Dropdown
    )

    if Rebuild == true then
        self:RebuildRows()
    else
        self:RefreshRows()
    end
end

function DropdownPicker:NormalizeWorld(Value)
    local Text =
        tostring(
            Value
            or ""
        ):lower()

    if Text:find(
        "fall",
        1,
        true
    ) then
        return "Fall Harvest"
    end

    if Text == "main"
    or Text:find(
        "garden",
        1,
        true
    )
    or Text:find(
        "valley",
        1,
        true
    ) then
        return "Garden Valley"
    end

    if Text == ""
    or Text == "universal"
    or Text == "all" then
        return "Universal"
    end

    return tostring(Value)
end

function DropdownPicker:ResolveWantedWorld()
    local State =
        self:NormalizePickerState()

    local Wanted =
        State.World

    if Wanted == "Current World" then
        local CurrentWorld =
            self:GetInfo().CurrentWorld

        if type(CurrentWorld) == "function" then
            local Ok,
                Result =
                pcall(CurrentWorld)

            if Ok then
                Wanted =
                    Result
            end
        end
    end

    return self:NormalizeWorld(
        Wanted
    )
end

function DropdownPicker:WorldMatches(Row)
    local State =
        self:NormalizePickerState()

    if State.World == "All Worlds" then
        return true
    end

    local Worlds =
        Row.Metadata.Worlds

    if type(Worlds) ~= "table"
    or next(Worlds) == nil then
        return true
    end

    local Wanted =
        self:ResolveWantedWorld()

    for Key, Value in pairs(Worlds) do
        local World =
            type(Key) == "number"
            and Value
            or Value == true
                and Key
            or nil

        if World ~= nil then
            local Normalized =
                self:NormalizeWorld(
                    World
                )

            if Normalized == "Universal"
            or Normalized == Wanted then
                return true
            end
        end
    end

    return false
end

function DropdownPicker:RarityMatches(Row)
    local Wanted =
        self:NormalizePickerState()
            .Rarity

    return Wanted == "All Rarities"
        or tostring(
            Row.Metadata.Rarity
            or ""
        ) == Wanted
end

function DropdownPicker:GetSortedValues()
    if not self.Config then
        return {}
    end

    local Info =
        self.Config.Info

    local Values =
        {}

    for _, Value in self.Config.Dropdown.Values do
        if Info.RichPicker ~= true
        or Value ~= Info.MasterValue then
            table.insert(
                Values,
                Value
            )
        end
    end

    if Info.RichPicker ~= true then
        return Values
    end

    local SortMode =
        self:NormalizePickerState()
            .Sort

    table.sort(Values, function(LeftValue, RightValue)
        local Left =
            self:GetMetadata(
                LeftValue
            )

        local Right =
            self:GetMetadata(
                RightValue
            )

        if SortMode == "Rarity: Highest" then
            local LeftRank =
                tonumber(
                    Left.RarityRank
                )
                or 0

            local RightRank =
                tonumber(
                    Right.RarityRank
                )
                or 0

            if LeftRank ~= RightRank then
                return LeftRank > RightRank
            end

            local LeftPrice =
                tonumber(
                    Left.Price
                )
                or 0

            local RightPrice =
                tonumber(
                    Right.Price
                )
                or 0

            if LeftPrice ~= RightPrice then
                return LeftPrice > RightPrice
            end
        elseif SortMode == "Price: Highest"
        or SortMode == "Price: Lowest" then
            local LeftPrice =
                tonumber(
                    Left.Price
                )
                or 0

            local RightPrice =
                tonumber(
                    Right.Price
                )
                or 0

            if LeftPrice ~= RightPrice then
                return SortMode == "Price: Highest"
                    and LeftPrice > RightPrice
                    or LeftPrice < RightPrice
            end
        elseif SortMode == "Shop Order" then
            local LeftOrder =
                tonumber(
                    Left.ShopOrder
                )
                or math.huge

            local RightOrder =
                tonumber(
                    Right.ShopOrder
                )
                or math.huge

            if LeftOrder ~= RightOrder then
                return LeftOrder < RightOrder
            end
        end

        return tostring(
            LeftValue
        ):lower()
            < tostring(
                RightValue
            ):lower()
    end)

    return Values
end

function DropdownPicker:UpdateFilterButtons()
    if not (
        self.Built
        and self.Config
    ) then
        return
    end

    local Info =
        self.Config.Info

    local Rich =
        Info.RichPicker == true

    local State =
        self:NormalizePickerState()

    local MasterValue =
        Info.MasterValue

    local MasterActive =
        MasterValue ~= nil
        and type(self.Draft) == "table"
        and self.Draft[MasterValue] == true

    self.MasterButton.Visible =
        Rich
        and MasterValue ~= nil

    self.FilterToolbar.Visible =
        Rich

    self.WorldButton.Text =
        "World: "
        .. tostring(
            State.World
        )

    self.RarityButton.Text =
        State.Rarity == "All Rarities"
        and "Rarity: All"
        or "Rarity: "
            .. tostring(
                State.Rarity
            )

    self.SortButton.Text =
        "Sort: "
        .. tostring(
            State.Sort
        )

    local CatalogCount =
        #self.Rows

    local MasterText =
        tostring(
            Info.MasterText
            or "Enable every option"
        )

    self.MasterButton.Text =
        MasterActive
        and "All "
            .. tostring(
                CatalogCount
            )
            .. " enabled"
        or MasterText

    self.MasterButton.BackgroundTransparency =
        MasterActive
        and 0.64
        or 0.92

    self.MasterButton.TextTransparency =
        MasterActive
        and 0
        or 0.22

    local HasFilters =
        tostring(
            self.SearchBox.Text
            or ""
        ) ~= ""
        or self.SelectedOnly
        or State.World ~= "All Worlds"
        or State.Rarity ~= "All Rarities"

    self.ClearButton.Text =
        HasFilters
        and "Clear shown"
        or "Clear"
end

function DropdownPicker:UpdateGrid()
    if not self.Built then
        return
    end

    local Width =
        math.max(
            self.Grid.AbsoluteSize.X - 16,
            1
        )

    local Columns =
        Width >= 500
        and 2
        or 1

    local CellWidth =
        math.floor(
            (
                Width
                - (
                    Columns - 1
                ) * 6
            )
            / Columns
        )

    local Rich =
        self.Config
        and self.Config.Info.RichPicker == true

    self.GridLayout.FillDirectionMaxCells =
        Columns

    self.GridLayout.CellSize =
        UDim2.fromOffset(
            CellWidth,
            Rich
            and 58
            or 34
        )
end

function DropdownPicker:IsSelected(Value)
    if not self.Config then
        return false
    end

    if self.Config.Dropdown.Multi then
        local MasterValue =
            self.Config.Info.MasterValue

        return self.Draft[Value] == true
            or MasterValue ~= nil
                and self.Draft[MasterValue] == true
    end

    return self.Draft == Value
end

function DropdownPicker:GetSelectedCount()
    if not self.Config then
        return 0
    elseif not self.Config.Dropdown.Multi then
        return self.Draft
            and 1
            or 0
    end

    local MasterValue =
        self.Config.Info.MasterValue

    if MasterValue ~= nil
    and self.Draft[MasterValue] == true then
        local Count =
            0

        for _, Value in self.Config.Dropdown.Values do
            if Value ~= MasterValue then
                Count += 1
            end
        end

        return Count
    end

    local Count =
        0

    for _, Value in self.Config.Dropdown.Values do
        if Value ~= MasterValue
        and self.Draft[Value] then
            Count += 1
        end
    end

    return Count
end

function DropdownPicker:SetDraftFromDropdown()
    if not self.Config then
        return
    end

    local Dropdown = self.Config.Dropdown

    if Dropdown.Multi then
        self.Draft = {}

        for _, Value in Dropdown.Values do
            if Dropdown.Value[Value] then
                self.Draft[Value] = true
            end
        end
    else
        self.Draft = Dropdown.Value
    end
end

function DropdownPicker:NormalizeDraft()
    if not self.Config then
        return
    end

    local Dropdown = self.Config.Dropdown

    if Dropdown.Multi then
        local ValidDraft = {}

        for _, Value in Dropdown.Values do
            if self.Draft[Value] then
                ValidDraft[Value] = true
            end
        end

        self.Draft = ValidDraft
    elseif not table.find(Dropdown.Values, self.Draft) then
        self.Draft = nil
    end
end

function DropdownPicker:UpdateRow(Row)
    Row.Metadata =
        self:GetMetadata(
            Row.Value
        )

    local Selected =
        self:IsSelected(
            Row.Value
        )

    Row.Container.BackgroundTransparency =
        Row.Disabled
        and 1
        or Selected
            and (
                Row.Hovering
                and 0.68
                or 0.76
            )
        or Row.Hovering
            and 0.89
        or 1

    Row.Stroke.Transparency =
        Row.Disabled
        and 1
        or Selected
            and 0.42
        or Row.Hovering
            and 0.72
        or 1

    Row.Label.TextTransparency =
        Row.Disabled
        and 0.75
        or Selected
            and 0
        or Row.Hovering
            and 0.08
        or 0.3

    Row.Check.ImageTransparency =
        Selected
        and (
            Row.Disabled
            and 0.7
            or 0
        )
        or 1

    if Row.Image then
        Row.Image.ImageTransparency =
            Row.Disabled
            and 0.78
            or Selected
                and 0
            or Row.Hovering
                and 0.08
            or 0.32
    end

    if Row.MetaLabel then
        local Meta =
            Row.Metadata

        local Details =
            {}

        local Rarity =
            tostring(
                Meta.Rarity
                or ""
            )

        local WorldText =
            tostring(
                Meta.WorldText
                or ""
            )

        if Rarity ~= "" then
            table.insert(
                Details,
                Rarity:upper()
            )
        end

        if WorldText ~= "" then
            table.insert(
                Details,
                WorldText
            )
        end

        if Meta.SingleHarvest == true then
            table.insert(
                Details,
                "Single Harvest"
            )
        end

        Row.MetaLabel.Text =
            table.concat(
                Details,
                "  ·  "
            )

        Row.MetaLabel.TextTransparency =
            Row.Disabled
            and 0.82
            or Selected
                and 0.16
            or 0.46

        if typeof(
            Meta.RarityColor
        ) == "Color3" then
            Row.MetaLabel.TextColor3 =
                Meta.RarityColor

            if Row.RarityBar then
                Row.RarityBar.BackgroundColor3 =
                    Meta.RarityColor
            end
        else
            Row.MetaLabel.TextColor3 =
                Library.Scheme.FontColor

            if Row.RarityBar then
                Row.RarityBar.BackgroundColor3 =
                    Library.Scheme.AccentColor
            end
        end

        Row.PriceLabel.Text =
            tostring(
                Meta.PriceText
                or ""
            )

        local Stock =
            tonumber(
                Meta.Stock
            )

        local GetLiveStock =
            self:GetInfo()
                .GetLiveStock

        if Row.Container.Visible
        and type(GetLiveStock) == "function" then
            local Ok,
                Result =
                pcall(
                    GetLiveStock,
                    Row.Value
                )

            if Ok then
                Stock =
                    tonumber(Result)
            end
        end

        local RightParts =
            {}

        local ValueText =
            tostring(
                Meta.ValueText
                or ""
            )

        if ValueText ~= "" then
            table.insert(
                RightParts,
                ValueText
            )
        end

        if Stock ~= nil then
            table.insert(
                RightParts,
                Stock > 0
                and tostring(
                    math.floor(Stock)
                )
                    .. " stock"
                or "Out of stock"
            )
        end

        Row.StockLabel.Text =
            table.concat(
                RightParts,
                "  ·  "
            )

        Row.PriceLabel.TextTransparency =
            Row.Disabled
            and 0.82
            or Selected
                and 0.08
            or 0.34

        Row.StockLabel.TextTransparency =
            Row.Disabled
            and 0.84
            or Selected
                and 0.24
            or 0.50
    end
end

function DropdownPicker:RefreshRows()
    if not self.Config then
        return
    end

    local Query =
        tostring(
            self.SearchBox.Text
            or ""
        ):lower()

    local VisibleCount =
        0

    local SelectedInWorld =
        0

    local MasterValue =
        self.Config.Info.MasterValue

    local MasterActive =
        MasterValue ~= nil
        and self.Config.Dropdown.Multi
        and self.Draft[MasterValue] == true

    for _, Row in self.Rows do
        local MatchesSearch =
            Query == ""
            or Row.SearchText:find(
                Query,
                1,
                true
            ) ~= nil

        local MatchesWorld =
            self:WorldMatches(
                Row
            )

        local MatchesRarity =
            self:RarityMatches(
                Row
            )

        local Selected =
            self:IsSelected(
                Row.Value
            )

        local Matches =
            MatchesSearch
            and MatchesWorld
            and MatchesRarity

        Row.Container.Visible =
            Matches
            and (
                not self.SelectedOnly
                or Selected
            )

        if Row.Container.Visible then
            VisibleCount += 1
        end

        if Selected
        and MatchesWorld then
            SelectedInWorld += 1
        end

        self:UpdateRow(
            Row
        )
    end

    local SelectedCount =
        self:GetSelectedCount()

    local TotalCount =
        #self.Rows

    local HiddenWorldCount =
        math.max(
            0,
            SelectedCount
                - SelectedInWorld
        )

    self.CountLabel.Text =
        MasterActive
        and "All "
            .. tostring(
                TotalCount
            )
            .. " enabled"
        or tostring(
            SelectedCount
        )
            .. " selected"

    self.SummaryLabel.Text =
        MasterActive
        and string.format(
            "All %d enabled  •  %d shown",
            TotalCount,
            VisibleCount
        )
        or string.format(
            "%d selected  •  %d shown",
            SelectedCount,
            VisibleCount
        )

    if HiddenWorldCount > 0 then
        self.SummaryLabel.Text ..=
            "  •  "
            .. tostring(
                HiddenWorldCount
            )
            .. " selected in another world"
    end

    self.EmptyLabel.Text =
        Query ~= ""
        and "No matching options"
        or self.SelectedOnly
            and "No selected options"
        or "No options available"

    self.EmptyLabel.Visible =
        VisibleCount == 0

    self.AllButton.BackgroundTransparency =
        self.SelectedOnly
        and 0.92
        or 0.72

    self.AllButton.TextTransparency =
        self.SelectedOnly
        and 0.22
        or 0

    self.SelectedButton.BackgroundTransparency =
        self.SelectedOnly
        and 0.72
        or 0.92

    self.SelectedButton.TextTransparency =
        self.SelectedOnly
        and 0
        or 0.22

    self:UpdateFilterButtons()
end

function DropdownPicker:RebuildRows()
    if not self.Config then
        return
    end

    for _, Row in self.Rows do
        if Row.Container then
            Row.Container:Destroy()
        end
    end

    table.clear(
        self.Rows
    )

    self:NormalizeDraft()

    local Dropdown =
        self.Config.Dropdown

    local Info =
        self.Config.Info

    local PickerCheckIcon =
        Library:GetIcon(
            "check"
        )

    local Values =
        self:GetSortedValues()

    for Index, Value in Values do
        local FormattedValue =
            tostring(
                Info.FormatListValue
                and Info.FormatListValue(
                    Value
                )
                or Value
            )

        local IsDisabled =
            table.find(
                Dropdown.DisabledValues,
                Value
            ) ~= nil

        local ValueImage =
            self.Config.GetValueImage(
                Value
            )

        local Row = {
            Value = Value,
            Disabled = IsDisabled,
            Hovering = false,
            Metadata =
                self:GetMetadata(
                    Value
                ),
        }

        local MetadataSearch =
            table.concat(
                {
                    tostring(
                        Row.Metadata.Rarity
                        or ""
                    ),

                    tostring(
                        Row.Metadata.WorldText
                        or ""
                    ),

                    tostring(
                        Row.Metadata.PriceText
                        or ""
                    ),

                    tostring(
                        Row.Metadata.ValueText
                        or ""
                    ),

                    Row.Metadata.SingleHarvest == true
                    and "single harvest"
                    or "",
                },
                " "
            )

        Row.SearchText =
            (
                FormattedValue
                .. " "
                .. MetadataSearch
            ):lower()

        local Rich =
            Info.RichPicker == true

        local RowHeight =
            Rich
            and 58
            or 34

        Row.Container = New("TextButton", {
            Active = not IsDisabled,
            BackgroundColor3 = "AccentColor",
            BackgroundTransparency = 1,
            LayoutOrder = Index,
            Size = UDim2.fromOffset(
                280,
                RowHeight
            ),
            Text = "",
            ZIndex = self.Grid.ZIndex + 1,
            Parent = self.Grid,
        })

        New("UICorner", {
            CornerRadius = UDim.new(0, 7),
            Parent = Row.Container,
        })

        Row.Stroke = New("UIStroke", {
            Color = "AccentColor",
            Transparency = 1,
            Parent = Row.Container,
        })

        if Rich then
            Row.RarityBar = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(0, 7),
                Size = UDim2.new(
                    0,
                    3,
                    1,
                    -14
                ),
                ZIndex = Row.Container.ZIndex + 1,
                Parent = Row.Container,
            })

            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Row.RarityBar,
            })
        end

        if ValueImage then
            Row.Image = New("ImageLabel", {
                BackgroundTransparency = 1,
                Image = ValueImage.Url,
                ImageRectOffset =
                    ValueImage.ImageRectOffset
                    or Vector2.zero,
                ImageRectSize =
                    ValueImage.ImageRectSize
                    or Vector2.zero,
                ImageTransparency = 0.32,
                Position =
                    Rich
                    and UDim2.fromOffset(
                        10,
                        10
                    )
                    or UDim2.fromOffset(
                        9,
                        8
                    ),
                Size =
                    Rich
                    and UDim2.fromOffset(
                        38,
                        38
                    )
                    or UDim2.fromOffset(
                        18,
                        18
                    ),
                ZIndex = Row.Container.ZIndex + 1,
                Parent = Row.Container,
            })
        end

        Row.Label = New("TextLabel", {
            BackgroundTransparency = 1,

            Position =
                Rich
                and UDim2.fromOffset(
                    ValueImage
                    and 56
                    or 12,
                    5
                )
                or ValueImage
                    and UDim2.fromOffset(
                        34,
                        0
                    )
                or UDim2.fromOffset(
                    10,
                    0
                ),

            Size =
                Rich
                and UDim2.new(
                    0.58,
                    -(
                        ValueImage
                        and 56
                        or 12
                    ),
                    0,
                    23
                )
                or ValueImage
                    and UDim2.new(
                        1,
                        -70,
                        1,
                        0
                    )
                or UDim2.new(
                    1,
                    -46,
                    1,
                    0
                ),

            Text = FormattedValue,
            TextSize = 13,
            TextTransparency = 0.3,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = Row.Container.ZIndex + 1,
            Parent = Row.Container,
        })

        if Rich then
            Row.MetaLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(
                    ValueImage
                    and 56
                    or 12,
                    30
                ),
                Size = UDim2.new(
                    0.68,
                    -(
                        ValueImage
                        and 56
                        or 12
                    ),
                    0,
                    18
                ),
                Text = "",
                TextSize = 10,
                TextTransparency = 0.46,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = Row.Container.ZIndex + 1,
                Parent = Row.Container,
            })

            Row.PriceLabel = New("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(
                    1,
                    -34,
                    0,
                    5
                ),
                Size = UDim2.new(
                    0.42,
                    -8,
                    0,
                    22
                ),
                Text = "",
                TextSize = 11,
                TextTransparency = 0.34,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = Row.Container.ZIndex + 1,
                Parent = Row.Container,
            })

            Row.StockLabel = New("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(
                    1,
                    -34,
                    0,
                    30
                ),
                Size = UDim2.new(
                    0.48,
                    -8,
                    0,
                    18
                ),
                Text = "",
                TextSize = 10,
                TextTransparency = 0.50,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = Row.Container.ZIndex + 1,
                Parent = Row.Container,
            })
        end

        Row.Check = New("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Image =
                PickerCheckIcon
                and PickerCheckIcon.Url
                or "",
            ImageColor3 = "FontColor",
            ImageRectOffset =
                PickerCheckIcon
                and PickerCheckIcon.ImageRectOffset
                or Vector2.zero,
            ImageRectSize =
                PickerCheckIcon
                and PickerCheckIcon.ImageRectSize
                or Vector2.zero,
            ImageTransparency = 1,
            Position = UDim2.new(
                1,
                -10,
                0.5,
                0
            ),
            Size = UDim2.fromOffset(15, 15),
            ZIndex = Row.Container.ZIndex + 1,
            Parent = Row.Container,
        })

        Row.Container.MouseEnter:Connect(function()
            if not Row.Disabled then
                Row.Hovering = true
                self:UpdateRow(Row)
            end
        end)

        Row.Container.MouseLeave:Connect(function()
            Row.Hovering = false
            self:UpdateRow(Row)
        end)

        Row.Container.MouseButton1Click:Connect(function()
            if Row.Disabled
            or not self.Config then
                return
            end

            if Dropdown.Multi then
                local Selected =
                    self.Draft[
                        Row.Value
                    ] == true

                if Info.MasterValue ~= nil
                and self.Draft[
                    Info.MasterValue
                ] == true then
                    table.clear(
                        self.Draft
                    )

                    Selected =
                        false
                end

                if Selected
                and not Info.AllowNull
                and self:GetSelectedCount() <= 1 then
                    return
                end

                self.Draft[Row.Value] =
                    not Selected
                    and true
                    or nil

                self:RefreshRows()
            else
                self.Draft =
                    self.Draft == Row.Value
                    and Info.AllowNull
                    and nil
                    or Row.Value

                local ValueToApply =
                    self.Draft

                self:Close()

                Dropdown:SetValue(
                    ValueToApply
                )
            end
        end)

        table.insert(
            self.Rows,
            Row
        )
    end

    self:UpdateGrid()
    self:RefreshRows()
end

function DropdownPicker:Apply()
    if not (self.Config and self.Config.Dropdown.Multi) then
        return
    end

    if not self.Config.Info.AllowNull and self:GetSelectedCount() == 0 then
        for _, Row in self.Rows do
            if not Row.Disabled then
                self.Draft[Row.Value] = true
                break
            end
        end
    end

    local Dropdown = self.Config.Dropdown
    local Draft = self.Draft

    self:Close()
    Dropdown:SetValue(Draft)
end

function DropdownPicker:Open(Config)
    self:Create()

    if self.Active then
        self:Close()
    end

    Library:CloseCurrentMenu()

    self.Config = Config
    self.SelectedOnly = false
    self.Active = true
    self.AnimationToken = self.AnimationToken + 1
    self.RefreshToken = self.RefreshToken + 1

    local RefreshToken =
        self.RefreshToken

    local Rich =
        Config.Info.RichPicker == true

    self:SetDraftFromDropdown()

    self.MasterButton.Visible =
        Rich
        and Config.Info.MasterValue ~= nil

    self.FilterToolbar.Visible =
        Rich

    self.Toolbar.Position =
        Rich
        and UDim2.fromOffset(
            12,
            132
        )
        or UDim2.fromOffset(
            12,
            90
        )

    self.GridHolder.Position =
        Rich
        and UDim2.fromOffset(
            12,
            208
        )
        or UDim2.fromOffset(
            12,
            128
        )

    self.GridHolder.Size =
        Rich
        and UDim2.new(
            1,
            -24,
            1,
            -266
        )
        or UDim2.new(
            1,
            -24,
            1,
            -186
        )

    self.Title.Text = tostring(
        Config.Info.PickerTitle
        or Config.Dropdown.Text
        or (Config.Dropdown.Multi and "Select options" or "Select option")
    )

    self.SelectShownButton.Visible = Config.Dropdown.Multi
    self.ClearButton.Visible = Config.Dropdown.Multi
    self.ApplyButton.Visible = Config.Dropdown.Multi
    self.CancelButton.Text = Config.Dropdown.Multi and "Cancel" or "Close"

    self.SearchBox.Text = ""
    self.Grid.CanvasPosition = Vector2.zero

    self:RebuildRows()
    Config.Dropdown:SetOpenState(true, false)

    StopTween(self.OverlayTween)
    StopTween(self.PanelTween)
    StopTween(self.ScaleTween)

    self.Overlay.Visible = true
    self.Panel.Visible = true
    self.Overlay.BackgroundTransparency = 1
    self.Panel.GroupTransparency = 1
    self.Panel.Position = UDim2.new(0.5, 0, 0.5, 8)
    self.PanelScale.Scale = 0.96

    local OpenInfo = TweenInfo.new(
        0.14,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    self.OverlayTween = TweenService:Create(self.Overlay, OpenInfo, {
        BackgroundTransparency = 0.38,
    })

    self.PanelTween = TweenService:Create(self.Panel, OpenInfo, {
        GroupTransparency = 0,
        Position = UDim2.fromScale(0.5, 0.5),
    })

    self.ScaleTween = TweenService:Create(self.PanelScale, OpenInfo, {
        Scale = 1,
    })

    self.OverlayTween:Play()
    self.PanelTween:Play()
    self.ScaleTween:Play()

    if not Library.IsMobile then
        task.defer(function()
            if self.Active then
                self.SearchBox:CaptureFocus()
            end
        end)
    end

    if Rich then
        task.spawn(function()
            while self.Active
            and self.RefreshToken == RefreshToken
            and self.Config == Config do
                task.wait(
                    0.75
                )

                if self.Active
                and self.RefreshToken == RefreshToken
                and self.Config == Config then
                    self:RefreshRows()
                end
            end
        end)
    end
end

function DropdownPicker:Close()
    if not self.Active then
        return
    end

    local ClosingConfig = self.Config

    self.Active = false
    self.Config = nil
    self.AnimationToken = self.AnimationToken + 1
    self.RefreshToken = self.RefreshToken + 1

    local Token = self.AnimationToken

    if ClosingConfig and ClosingConfig.Dropdown then
        ClosingConfig.Dropdown:SetOpenState(false, false)
    end

    self.SearchBox:ReleaseFocus()

    StopTween(self.OverlayTween)
    StopTween(self.PanelTween)
    StopTween(self.ScaleTween)

    local CloseInfo = TweenInfo.new(
        0.11,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    self.OverlayTween = TweenService:Create(self.Overlay, CloseInfo, {
        BackgroundTransparency = 1,
    })

    self.PanelTween = TweenService:Create(self.Panel, CloseInfo, {
        GroupTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 6),
    })

    self.ScaleTween = TweenService:Create(self.PanelScale, CloseInfo, {
        Scale = 0.97,
    })

    self.OverlayTween:Play()
    self.PanelTween:Play()
    self.ScaleTween:Play()

    task.delay(0.12, function()
        if not self.Active and self.AnimationToken == Token then
            self.Overlay.Visible = false
            self.Panel.Visible = false
        end
    end)
end

function Library:OpenDropdownPicker(Config)
    DropdownPicker:Open(Config)
end

function Library:CloseDropdownPicker(Dropdown)
    if not DropdownPicker.Active then
        return false
    end

    if Dropdown and (
        not DropdownPicker.Config
        or DropdownPicker.Config.Dropdown ~= Dropdown
    ) then
        return false
    end

    DropdownPicker:Close()

    return true
end

function Library:IsDropdownPickerOpen(Dropdown)
    return DropdownPicker.Active
        and DropdownPicker.Config
        and DropdownPicker.Config.Dropdown == Dropdown
end

function Library:RefreshDropdownPicker(Dropdown, ResetDraft)
    if not Library:IsDropdownPickerOpen(Dropdown) then
        return false
    end

    if ResetDraft then
        DropdownPicker:SetDraftFromDropdown()
    end

    DropdownPicker:RebuildRows()

    return true
end

Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)

    if Library.Unloaded then
        return
    end

    if DropdownPicker.Active
    and Input.KeyCode == Enum.KeyCode.Escape then
        DropdownPicker:Close()
        return
    end

    if CurrentMenu
    and Input.KeyCode == Enum.KeyCode.Escape then

        CurrentMenu:Close()

        return
    end

    if IsClickInput(Input, true) then
        local Location = Input.Position

        if
            CurrentMenu
            and not (
                Library:MouseIsOverFrame(CurrentMenu.Menu, Location)
                or Library:MouseIsOverFrame(CurrentMenu.Holder, Location)
            )
        then
            CurrentMenu:Close()
        end
    end
end))

--// Tooltip \\--
local TooltipLabel = New("TextLabel", {
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundColor3 = "BackgroundColor",
    TextSize = 14,
    TextWrapped = true,
    Visible = false,
    ZIndex = 20,
    Parent = ScreenGui,
})
New("UIPadding", {
    PaddingBottom = UDim.new(0, 2),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
    PaddingTop = UDim.new(0, 2),
    Parent = TooltipLabel,
})
table.insert(
    Library.Scales,
    New("UIScale", {
        Parent = TooltipLabel,
    })
)
New("UIStroke", {
    Color = "OutlineColor",
    Parent = TooltipLabel,
})
table.insert(
    Library.Corners,
    New("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius / 2),
        Parent = TooltipLabel,
    })
)
TooltipLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
    if Library.Unloaded then
        return
    end

    local X, _ = Library:GetTextBounds(
        TooltipLabel.Text,
        TooltipLabel.FontFace,
        TooltipLabel.TextSize,
        (workspace.CurrentCamera.ViewportSize.X - TooltipLabel.AbsolutePosition.X - 8) / Library.DPIScale
    )

    TooltipLabel.Size = UDim2.fromOffset(X + 8)
end)

local CurrentHoverInstance
function Library:AddTooltip(InfoStr: string, DisabledInfoStr: string, HoverInstance: GuiObject)
    local TooltipTable = {
        Disabled = false,
        Hovering = false,
        Signals = {},
    }

    local function DoHover()
        if
            CurrentHoverInstance == HoverInstance
            or Library.ActiveDialog
            or (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
            or (TooltipTable.Disabled and typeof(DisabledInfoStr) ~= "string")
            or (not TooltipTable.Disabled and typeof(InfoStr) ~= "string")
        then
            return
        end
        CurrentHoverInstance = HoverInstance

        local ParentGui = HoverInstance:FindFirstAncestorOfClass("ScreenGui")
        if ParentGui ~= ScreenGui and (Library.ActiveLoading and ParentGui ~= Library.ActiveLoading.ScreenGui) then
            ParentGui = ScreenGui
        end
        TooltipLabel.Parent = ParentGui

        TooltipLabel.Text = TooltipTable.Disabled and DisabledInfoStr or InfoStr
        TooltipLabel.Visible = true

        while
            (Library.Toggled or Library.ActiveLoading)
            and not Library.ActiveDialog
            and Library:MouseIsOverFrame(HoverInstance, Mouse)
            and not (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
        do
            TooltipLabel.Position = UDim2.fromOffset(
                Mouse.X + (Library.ShowCustomCursor and 8 or 14),
                Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
            )

            RunService.RenderStepped:Wait()
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end

    local function GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
        local ConnectionType = typeof(Connection)
        if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
            table.insert(TooltipTable.Signals, Connection)
        end

        return Connection
    end

    GiveSignal(HoverInstance.MouseEnter:Connect(DoHover))
    GiveSignal(HoverInstance.MouseMoved:Connect(DoHover))
    GiveSignal(HoverInstance.MouseLeave:Connect(function()
        if CurrentHoverInstance ~= HoverInstance then
            return
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end))

    function TooltipTable:Destroy()
        for Index = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Index)
            if Connection and Connection.Connected then
                Connection:Disconnect()
            end
        end

        if CurrentHoverInstance == HoverInstance then
            if TooltipLabel then
                TooltipLabel.Visible = false
            end

            CurrentHoverInstance = nil
        end
    end

    table.insert(Tooltips, TooltipLabel)
    return TooltipTable
end

function Library:OnUnload(Callback)
    table.insert(Library.UnloadSignals, Callback)
end

function Library:Unload()
    for Index = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Index)
        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end

    for _, Callback in Library.UnloadSignals do
        Library:SafeCallback(Callback)
    end

    for _, Tooltip in Tooltips do
        Library:SafeCallback(Tooltip.Destroy, Tooltip)
    end

    Library.Unloaded = true

    if Library.ActiveLoading then
        Library.ActiveLoading:Destroy()
    end

    if ScreenGui then
        ScreenGui:Destroy()
    end

    getgenv().Library = nil
end

local CheckIcon = Library:GetIcon("check")
local ArrowIcon = Library:GetIcon("chevron-up")
local ResizeIcon = Library:GetIcon("move-diagonal-2")
local KeyIcon = Library:GetIcon("key")
local MoveIcon = Library:GetIcon("move")

function Library:SetIconModule(module: IconModule)
    FetchIcons = true
    Icons = module

    -- Top ten fixes 🚀
    CheckIcon = Library:GetIcon("check")
    ArrowIcon = Library:GetIcon("chevron-up")
    ResizeIcon = Library:GetIcon("move-diagonal-2")
    KeyIcon = Library:GetIcon("key")
    MoveIcon = Library:GetIcon("move")
end

local BaseAddons = {}
do
    local Funcs = {}

    function Funcs:AddKeyPicker(Idx, Info)
        Info = Library:Validate(Info, Templates.KeyPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        local KeyPicker = {
            Text = Info.Text,
            Value = Info.Default, -- Key
            Modifiers = Info.DefaultModifiers, -- Modifiers
            DisplayValue = Info.Default, -- Picker Text

            Blacklisted = Info.Blacklisted,
            BlacklistedModifiers = Info.BlacklistedModifiers,
            Whitelisted = Info.Whitelisted,
            WhitelistedModifiers = Info.WhitelistedModifiers,

            Toggled = false,
            Mode = Info.Mode,
            SyncToggleState = Info.SyncToggleState,

            Callback = Info.Callback,
            ChangedCallback = Info.ChangedCallback,
            Changed = Info.Changed,
            Clicked = Info.Clicked,

            Type = "KeyPicker",
        }

        if KeyPicker.Mode == "Press" then
            assert(ParentObj.Type == "Label", "KeyPicker with the mode 'Press' can be only applied on Labels.")

            KeyPicker.SyncToggleState = false
            Info.Modes = { "Press" }
            Info.Mode = "Press"
        end

        if KeyPicker.SyncToggleState then
            Info.Modes = { "Toggle", "Hold" }

            if not table.find(Info.Modes, Info.Mode) then
                Info.Mode = "Toggle"
            end
        end

        local Picking = false

        -- Special Keys
        local SpecialKeys = {
            ["MB1"] = Enum.UserInputType.MouseButton1,
            ["MB2"] = Enum.UserInputType.MouseButton2,
            ["MB3"] = Enum.UserInputType.MouseButton3,
        }

        local SpecialKeysInput = {
            [Enum.UserInputType.MouseButton1] = "MB1",
            [Enum.UserInputType.MouseButton2] = "MB2",
            [Enum.UserInputType.MouseButton3] = "MB3",
        }

        -- Modifiers
        local Modifiers = {
            ["LAlt"] = Enum.KeyCode.LeftAlt,
            ["RAlt"] = Enum.KeyCode.RightAlt,

            ["LCtrl"] = Enum.KeyCode.LeftControl,
            ["RCtrl"] = Enum.KeyCode.RightControl,

            ["LShift"] = Enum.KeyCode.LeftShift,
            ["RShift"] = Enum.KeyCode.RightShift,

            ["Tab"] = Enum.KeyCode.Tab,
            ["CapsLock"] = Enum.KeyCode.CapsLock,
        }

        local ModifiersInput = {
            [Enum.KeyCode.LeftAlt] = "LAlt",
            [Enum.KeyCode.RightAlt] = "RAlt",

            [Enum.KeyCode.LeftControl] = "LCtrl",
            [Enum.KeyCode.RightControl] = "RCtrl",

            [Enum.KeyCode.LeftShift] = "LShift",
            [Enum.KeyCode.RightShift] = "RShift",

            [Enum.KeyCode.Tab] = "Tab",
            [Enum.KeyCode.CapsLock] = "CapsLock",
        }

        local IsModifierInput = function(Input)
            return Input.UserInputType == Enum.UserInputType.Keyboard and ModifiersInput[Input.KeyCode] ~= nil
        end

        local GetActiveModifiers = function()
            local ActiveModifiers = {}

            for Name, Input in Modifiers do
                if table.find(ActiveModifiers, Name) then
                    continue
                end
                if not UserInputService:IsKeyDown(Input) then
                    continue
                end

                table.insert(ActiveModifiers, Name)
            end

            return ActiveModifiers
        end

        local AreModifiersHeld = function(Required)
            if not (typeof(Required) == "table" and GetTableSize(Required) > 0) then
                return true
            end

            local ActiveModifiers = GetActiveModifiers()
            local Holding = true

            for _, Name in Required do
                if table.find(ActiveModifiers, Name) then
                    continue
                end

                Holding = false
                break
            end

            return Holding
        end

        local IsInputDown = function(Input)
            if not Input then
                return false
            end

            if SpecialKeysInput[Input.UserInputType] ~= nil then
                return UserInputService:IsMouseButtonPressed(Input.UserInputType)
                    and not UserInputService:GetFocusedTextBox()
            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                return UserInputService:IsKeyDown(Input.KeyCode) and not UserInputService:GetFocusedTextBox()
            else
                return false
            end
        end

        local ConvertToInputModifiers = function(CurrentModifiers)
            local InputModifiers = {}

            for _, name in CurrentModifiers do
                table.insert(InputModifiers, Modifiers[name])
            end

            return InputModifiers
        end

        local VerifyModifiers = function(CurrentModifiers)
            if typeof(CurrentModifiers) ~= "table" then
                return {}
            end

            local ValidModifiers = {}

            for _, name in CurrentModifiers do
                if not Modifiers[name] then
                    continue
                end

                table.insert(ValidModifiers, name)
            end

            return ValidModifiers
        end

        KeyPicker.Modifiers = VerifyModifiers(KeyPicker.Modifiers)

        local Picker = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromOffset(18, 18),
            Text = KeyPicker.Value,
            TextSize = 14,
            Parent = ToggleLabel,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Picker,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Picker,
            })
        )

        local KeybindsToggle = { Normal = KeyPicker.Mode ~= "Toggle" }
        do
            local Holder = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Text = "",
                Visible = not Info.NoUI,
                Parent = Library.KeybindContainer,
            })

            local Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0, 1),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = Holder,
            })

            local Checkbox = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(14, 14),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = Holder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Checkbox,
                })
            )
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Checkbox,
            })

            local CheckImage = New("ImageLabel", {
                Image = CheckIcon and CheckIcon.Url or "",
                ImageColor3 = "FontColor",
                ImageRectOffset = CheckIcon and CheckIcon.ImageRectOffset or Vector2.zero,
                ImageRectSize = CheckIcon and CheckIcon.ImageRectSize or Vector2.zero,
                ImageTransparency = 1,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = Checkbox,
            })

            function KeybindsToggle:Display(State)
                Label.TextTransparency = State and 0 or 0.5
                CheckImage.ImageTransparency = State and 0 or 1
            end

            function KeybindsToggle:SetText(Text)
                Label.Text = Text
            end

            function KeybindsToggle:SetVisibility(Visibility)
                Holder.Visible = Visibility
            end

            function KeybindsToggle:SetNormal(Normal)
                KeybindsToggle.Normal = Normal

                Holder.Active = not Normal
                Label.Position = Normal and UDim2.fromOffset(0, 0) or UDim2.fromOffset(22, 0)
                Checkbox.Visible = not Normal
            end

            KeyPicker.DoClick = function(...) end --// make luau lsp shut up
            Holder.MouseButton1Click:Connect(function()
                if KeybindsToggle.Normal then
                    return
                end

                KeyPicker.Toggled = not KeyPicker.Toggled
                KeyPicker:DoClick()
            end)

            KeybindsToggle.Holder = Holder
            KeybindsToggle.Label = Label
            KeybindsToggle.Checkbox = Checkbox
            KeybindsToggle.Loaded = true
            table.insert(Library.KeybindToggles, KeybindsToggle)
        end

        local MenuTable = Library:AddContextMenu(Picker, UDim2.fromOffset(62, 0), function()
            return { Picker.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, nil, true)
        KeyPicker.Menu = MenuTable

        local ModeButtons = {}
        for _, Mode in Info.Modes do
            local ModeButton = {}

            local Button = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 21),
                Text = Mode,
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = MenuTable.Menu,
            })

            function ModeButton:Select()
                for _, Button in ModeButtons do
                    Button:Deselect()
                end

                KeyPicker.Mode = Mode

                Button.BackgroundTransparency = 0
                Button.TextTransparency = 0

                MenuTable:Close()
            end

            function ModeButton:Deselect()
                KeyPicker.Mode = nil

                Button.BackgroundTransparency = 1
                Button.TextTransparency = 0.5
            end

            Button.MouseButton1Click:Connect(function()
                ModeButton:Select()
            end)

            if KeyPicker.Mode == Mode then
                ModeButton:Select()
            end

            ModeButtons[Mode] = ModeButton
        end

        function KeyPicker:Display(PickerText)
            if Library.Unloaded then
                return
            end

            local X, Y = Library:GetTextBounds(
                PickerText or KeyPicker.DisplayValue,
                Picker.FontFace,
                Picker.TextSize,
                ToggleLabel.AbsoluteSize.X
            )
            Picker.Text = PickerText or KeyPicker.DisplayValue
            Picker.Size = UDim2.fromOffset((X + 9), (Y + 4))
        end

        function KeyPicker:Update()
            KeyPicker:Display()

            if Info.NoUI then
                return
            end

            if KeyPicker.Mode == "Toggle" and ParentObj.Type == "Toggle" and ParentObj.Disabled then
                KeybindsToggle:SetVisibility(false)
                return
            end

            local State = KeyPicker:GetState()
            local ShowToggle = Library.ShowToggleFrameInKeybinds and KeyPicker.Mode == "Toggle"

            if KeyPicker.SyncToggleState and ParentObj.Value ~= State then
                ParentObj:SetValue(State)
            end

            if KeybindsToggle.Loaded then
                if ShowToggle then
                    KeybindsToggle:SetNormal(false)
                else
                    KeybindsToggle:SetNormal(true)
                end

                KeybindsToggle:SetText(("[%s] %s (%s)"):format(KeyPicker.DisplayValue, KeyPicker.Text, KeyPicker.Mode))
                KeybindsToggle:SetVisibility(true)
                KeybindsToggle:Display(State)
            end
        end

        function KeyPicker:GetState()
            if KeyPicker.Mode == "Always" then
                return true
            elseif KeyPicker.Mode == "Hold" then
                local Key = KeyPicker.Value
                if Key == "None" then
                    return false
                end

                if not AreModifiersHeld(KeyPicker.Modifiers) then
                    return false
                end

                if SpecialKeys[Key] ~= nil then
                    return UserInputService:IsMouseButtonPressed(SpecialKeys[Key])
                        and not UserInputService:GetFocusedTextBox()
                else
                    return UserInputService:IsKeyDown(Enum.KeyCode[Key]) and not UserInputService:GetFocusedTextBox()
                end
            else
                return KeyPicker.Toggled
            end
        end

        function KeyPicker:OnChanged(Func)
            KeyPicker.Changed = Func
        end

        function KeyPicker:OnClick(Func)
            KeyPicker.Clicked = Func
        end

        function KeyPicker:DoClick()
            if KeyPicker.Mode == "Press" then
                if KeyPicker.Toggled and Info.WaitForCallback == true then
                    return
                end

                KeyPicker.Toggled = true
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)

            if KeyPicker.Mode == "Press" then
                KeyPicker.Toggled = false
            end
        end

        function KeyPicker:SetValue(Data)
            local Key, Mode, Modifiers = Data[1], Data[2], Data[3]

            local IsKeyValid, KeyCode = pcall(function()
                if Key == "None" then
                    Key = nil
                    return nil
                end

                if SpecialKeys[Key] == nil then
                    return Enum.KeyCode[Key]
                end

                return SpecialKeys[Key]
            end)

            if Key == nil then
                KeyPicker.Value = "None"
            elseif IsKeyValid then
                KeyPicker.Value = Key
            else
                KeyPicker.Value = "Unknown"
            end

            KeyPicker.Modifiers =
                VerifyModifiers(if typeof(Modifiers) == "table" then Modifiers else KeyPicker.Modifiers)
            KeyPicker.DisplayValue = if GetTableSize(KeyPicker.Modifiers) > 0
                then (table.concat(KeyPicker.Modifiers, " + ") .. " + " .. KeyPicker.Value)
                else KeyPicker.Value

            if ModeButtons[Mode] then
                ModeButtons[Mode]:Select()
            end

            local NewModifiers = ConvertToInputModifiers(KeyPicker.Modifiers)
            Library:SafeCallback(KeyPicker.ChangedCallback, KeyCode, NewModifiers)
            Library:SafeCallback(KeyPicker.Changed, KeyCode, NewModifiers)

            KeyPicker:Update()
        end

        function KeyPicker:SetText(Text)
            KeybindsToggle:SetText(Text)
            KeyPicker:Update()
        end

        Picker.MouseButton1Click:Connect(function()
            if Picking then
                return
            end

            Picking = true

            Picker.Text = "..."
            Picker.Size = UDim2.fromOffset(29, 18)

            -- Wait for an non modifier key --
            local Input
            local ActiveModifiers = {}

            local GetInput = nil; GetInput = function()
                Input = UserInputService.InputBegan:Wait()
                if UserInputService:GetFocusedTextBox() ~= nil then
                    return true
                end

                if Input.KeyCode == Enum.KeyCode.Escape then
                    return false
                end

                local IsMod = IsModifierInput(Input)
                local KeyName
                if SpecialKeysInput[Input.UserInputType] ~= nil then
                    KeyName = SpecialKeysInput[Input.UserInputType]
                elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                    if IsMod then
                        KeyName = ModifiersInput[Input.KeyCode]
                    else
                        KeyName = Input.KeyCode.Name
                    end
                end

                if KeyName then
                    if IsMod then
                        if KeyPicker.WhitelistedModifiers and #KeyPicker.WhitelistedModifiers > 0 and not table.find(KeyPicker.WhitelistedModifiers, KeyName) then
                            return GetInput()
                        end

                        if KeyPicker.BlacklistedModifiers and table.find(KeyPicker.BlacklistedModifiers, KeyName) then
                            return GetInput()
                        end
                    else
                        if KeyPicker.Whitelisted and #KeyPicker.Whitelisted > 0 and not table.find(KeyPicker.Whitelisted, KeyName) then
                            return GetInput()
                        end

                        if KeyPicker.Blacklisted and table.find(KeyPicker.Blacklisted, KeyName) then
                            return GetInput()
                        end
                    end
                end

                return false
            end

            repeat
                task.wait()

                -- Wait for any input --
                Picker.Text = "..."
                Picker.Size = UDim2.fromOffset(29, 18)

                if GetInput() then
                    Picking = false
                    KeyPicker:Update()
                    return
                end

                -- Escape --
                if Input.KeyCode == Enum.KeyCode.Escape then
                    break
                end

                -- Handle modifier keys --
                if IsModifierInput(Input) then
                    local StopLoop = false

                    repeat
                        task.wait()
                        if UserInputService:IsKeyDown(Input.KeyCode) then
                            task.wait(0.075)

                            if UserInputService:IsKeyDown(Input.KeyCode) then
                                -- Add modifier to the key list --
                                if not table.find(ActiveModifiers, ModifiersInput[Input.KeyCode]) then
                                    ActiveModifiers[#ActiveModifiers + 1] = ModifiersInput[Input.KeyCode]
                                    KeyPicker:Display(table.concat(ActiveModifiers, " + ") .. " + ...")
                                end

                                -- Wait for another input --
                                if GetInput() then
                                    StopLoop = true
                                    break -- Invalid Input
                                end

                                -- Escape --
                                if Input.KeyCode == Enum.KeyCode.Escape then
                                    break
                                end

                                -- Stop loop if its a normal key --
                                if not IsModifierInput(Input) then
                                    break
                                end
                            else
                                if not table.find(ActiveModifiers, ModifiersInput[Input.KeyCode]) then
                                    break -- Modifier is meant to be used as a normal key --
                                end
                            end
                        end
                    until false

                    if StopLoop then
                        Picking = false
                        KeyPicker:Update()
                        return
                    end
                end

                break -- Input found, end loop
            until false

            local Key = "Unknown"
            if SpecialKeysInput[Input.UserInputType] ~= nil then
                Key = SpecialKeysInput[Input.UserInputType]
            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                Key = Input.KeyCode == Enum.KeyCode.Escape and "None" or Input.KeyCode.Name
            end

            ActiveModifiers = if Input.KeyCode == Enum.KeyCode.Escape or Key == "Unknown" then {} else ActiveModifiers

            KeyPicker.Toggled = false
            KeyPicker:SetValue({ Key, KeyPicker.Mode, ActiveModifiers })

            -- RunService.RenderStepped:Wait()
            repeat
                task.wait()
            until not IsInputDown(Input) or UserInputService:GetFocusedTextBox()
            Picking = false
        end)
        Picker.MouseButton2Click:Connect(MenuTable.Toggle)

        Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
            if Library.Unloaded then
                return
            end

            if
                KeyPicker.Mode == "Always"
                or KeyPicker.Value == "Unknown"
                or KeyPicker.Value == "None"
                or Picking
                or UserInputService:GetFocusedTextBox()
            then
                return
            end

            local Key = KeyPicker.Value
            local HoldingModifiers = AreModifiersHeld(KeyPicker.Modifiers)
            local HoldingKey = false

            if
                Key
                and HoldingModifiers == true
                and (
                    SpecialKeysInput[Input.UserInputType] == Key
                    or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key)
                )
            then
                HoldingKey = true
            end

            if KeyPicker.Mode == "Toggle" then
                if HoldingKey then
                    KeyPicker.Toggled = not KeyPicker.Toggled
                    KeyPicker:DoClick()
                end
            elseif KeyPicker.Mode == "Press" then
                if HoldingKey then
                    KeyPicker:DoClick()
                end
            end

            KeyPicker:Update()
        end))

        Library:GiveSignal(UserInputService.InputEnded:Connect(function()
            if Library.Unloaded then
                return
            end

            if
                KeyPicker.Value == "Unknown"
                or KeyPicker.Value == "None"
                or Picking
                or UserInputService:GetFocusedTextBox()
            then
                return
            end

            KeyPicker:Update()
        end))

        KeyPicker:Update()

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, KeyPicker)
        end

        KeyPicker.Default = KeyPicker.Value
        KeyPicker.DefaultModifiers = table.clone(KeyPicker.Modifiers or {})

        Options[Idx] = KeyPicker

        return self
    end

    local HueSequenceTable = {}
    for Hue = 0, 1, 0.1 do
        table.insert(HueSequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
    end
    function Funcs:AddColorPicker(Idx, Info)
        Info = Library:Validate(Info, Templates.ColorPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        local ColorPicker = {
            Value = Info.Default,

            Transparency = Info.Transparency or 0,
            Title = Info.Title,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Type = "ColorPicker",
        }
        ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = ColorPicker.Value:ToHSV()

        local Holder = New("TextButton", {
            BackgroundColor3 = ColorPicker.Value,
            Size = UDim2.fromOffset(18, 18),
            Text = "",
            Parent = ToggleLabel,
        })

        local HolderStroke = New("UIStroke", {
            Color = Library:GetDarkerColor(ColorPicker.Value),
            Parent = Holder,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Holder,
            })
        )

        local HolderTransparency = New("ImageLabel", {
            Image = CustomImageManager.GetAsset("TransparencyTexture"),
            ImageTransparency = (1 - ColorPicker.Transparency),
            ScaleType = Enum.ScaleType.Tile,
            Position = UDim2.new(0, -1, 0, -1),
            Size = UDim2.new(1, 2, 1, 2),
            TileSize = UDim2.fromOffset(9, 9),
            Parent = Holder,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HolderTransparency,
            })
        )

        --// Color Menu \\--
        local ColorMenu = Library:AddContextMenu(
            Holder,
            UDim2.fromOffset(Info.Transparency and 256 or 234, 0),
            function()
                return { 0.5, Holder.AbsoluteSize.Y + 1.5 }
            end,
            1
        )
        ColorMenu.List.Padding = UDim.new(0, 8)
        ColorPicker.ColorMenu = ColorMenu

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = ColorMenu.Menu,
        })

        if typeof(ColorPicker.Title) == "string" then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 8),
                Text = ColorPicker.Title,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ColorMenu.Menu,
            })
        end

        local ColorHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 200),
            Parent = ColorMenu.Menu,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = ColorHolder,
        })

        --// Sat Map
        local SatVipMap = New("ImageButton", {
            BackgroundColor3 = ColorPicker.Value,
            Image = CustomImageManager.GetAsset("SaturationMap"),
            Size = UDim2.fromOffset(200, 200),
            Parent = ColorHolder,
        })

        local SatVibCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            Size = UDim2.fromOffset(6, 6),
            Parent = SatVipMap,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SatVibCursor,
        })
        New("UIStroke", {
            Color = "DarkColor",
            Parent = SatVibCursor,
        })

        --// Hue
        local HueSelector = New("TextButton", {
            Size = UDim2.fromOffset(16, 200),
            Text = "",
            Parent = ColorHolder,
        })
        New("UIGradient", {
            Color = ColorSequence.new(HueSequenceTable),
            Rotation = 90,
            Parent = HueSelector,
        })

        local HueCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            BorderColor3 = "DarkColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0.5, ColorPicker.Hue),
            Size = UDim2.new(1, 2, 0, 1),
            Parent = HueSelector,
        })

        --// Alpha
        local TransparencySelector, TransparencyColor, TransparencyCursor
        if Info.Transparency then
            TransparencySelector = New("ImageButton", {
                Image = CustomImageManager.GetAsset("TransparencyTexture"),
                ScaleType = Enum.ScaleType.Tile,
                Size = UDim2.fromOffset(16, 200),
                TileSize = UDim2.fromOffset(8, 8),
                Parent = ColorHolder,
            })

            TransparencyColor = New("Frame", {
                BackgroundColor3 = ColorPicker.Value,
                Size = UDim2.fromScale(1, 1),
                Parent = TransparencySelector,
            })
            New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Parent = TransparencyColor,
            })

            TransparencyCursor = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "WhiteColor",
                BorderColor3 = "DarkColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0.5, ColorPicker.Transparency),
                Size = UDim2.new(1, 2, 0, 1),
                Parent = TransparencySelector,
            })
        end

        local InfoHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ColorMenu.Menu,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = InfoHolder,
        })

        local HueBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "#??????",
            TextSize = 14,
            Parent = InfoHolder,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = HueBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HueBox,
            })
        )

        local RgbBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "?, ?, ?",
            TextSize = 14,
            Parent = InfoHolder,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = RgbBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = RgbBox,
            })
        )

        --// Context Menu \\--
        local ContextMenu = Library:AddContextMenu(Holder, UDim2.fromOffset(93, 0), function()
            return { Holder.AbsoluteSize.X + 1.5, 0.5 }
        end, 1)
        ColorPicker.ContextMenu = ContextMenu
        ContextMenu.List.Padding = UDim.new(0, 6)
        do
            local function CreateButton(Text, Func)
                local Button = New("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 21),
                    Text = Text,
                    TextSize = 14,
                    Parent = ContextMenu.Menu,
                })

                Button.MouseButton1Click:Connect(function()
                    Library:SafeCallback(Func)
                    ContextMenu:Close()
                end)
            end

            CreateButton("Copy color", function()
                Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }
            end)

            ColorPicker.SetValueRGB = function(...) end --// make luau lsp shut up
            CreateButton("Paste color", function()
                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
            end)

            if setclipboard then
                CreateButton("Copy Hex", function()
                    setclipboard(tostring(ColorPicker.Value:ToHex()))
                end)

                CreateButton("Copy RGB", function()
                    setclipboard(table.concat({
                        math.floor(ColorPicker.Value.R * 255),
                        math.floor(ColorPicker.Value.G * 255),
                        math.floor(ColorPicker.Value.B * 255),
                    }, ", "))
                end)
            end
        end

        --// End \\--
        function ColorPicker:SetHSVFromRGB(Color)
            ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
        end

        function ColorPicker:Display()
            if Library.Unloaded then
                return
            end

            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)

            Holder.BackgroundColor3 = ColorPicker.Value
            HolderStroke.Color = Library:GetDarkerColor(ColorPicker.Value)
            HolderTransparency.ImageTransparency = (1 - ColorPicker.Transparency)

            SatVipMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
            if TransparencyColor then
                TransparencyColor.BackgroundColor3 = ColorPicker.Value
            end

            SatVibCursor.Position = UDim2.fromScale(ColorPicker.Sat, 1 - ColorPicker.Vib)
            HueCursor.Position = UDim2.fromScale(0.5, ColorPicker.Hue)
            if TransparencyCursor then
                TransparencyCursor.Position = UDim2.fromScale(0.5, ColorPicker.Transparency)
            end

            HueBox.Text = "#" .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255),
            }, ", ")
        end

        function ColorPicker:Update()
            ColorPicker:Display()

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
        end

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func
        end

        function ColorPicker:SetValue(HSV, Transparency)
            if typeof(HSV) == "Color3" then
                ColorPicker:SetValueRGB(HSV, Transparency)
                return
            end

            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        Holder.MouseButton1Click:Connect(ColorMenu.Toggle)
        Holder.MouseButton2Click:Connect(ContextMenu.Toggle)

        SatVipMap.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) do
                local MinX = SatVipMap.AbsolutePosition.X
                local MaxX = MinX + SatVipMap.AbsoluteSize.X
                local LocationX = math.clamp(Mouse.X, MinX, MaxX)

                local MinY = SatVipMap.AbsolutePosition.Y
                local MaxY = MinY + SatVipMap.AbsoluteSize.Y
                local LocationY = math.clamp(Mouse.Y, MinY, MaxY)

                local OldSat = ColorPicker.Sat
                local OldVib = ColorPicker.Vib
                ColorPicker.Sat = (LocationX - MinX) / (MaxX - MinX)
                ColorPicker.Vib = 1 - ((LocationY - MinY) / (MaxY - MinY))

                if ColorPicker.Sat ~= OldSat or ColorPicker.Vib ~= OldVib then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end)
        HueSelector.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) do
                local Min = HueSelector.AbsolutePosition.Y
                local Max = Min + HueSelector.AbsoluteSize.Y
                local Location = math.clamp(Mouse.Y, Min, Max)

                local OldHue = ColorPicker.Hue
                ColorPicker.Hue = (Location - Min) / (Max - Min)

                if ColorPicker.Hue ~= OldHue then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end)
        if TransparencySelector then
            TransparencySelector.InputBegan:Connect(function(Input: InputObject)
                while IsDragInput(Input) do
                    local Min = TransparencySelector.AbsolutePosition.Y
                    local Max = TransparencySelector.AbsolutePosition.Y + TransparencySelector.AbsoluteSize.Y
                    local Location = math.clamp(Mouse.Y, Min, Max)

                    local OldTransparency = ColorPicker.Transparency
                    ColorPicker.Transparency = (Location - Min) / (Max - Min)

                    if ColorPicker.Transparency ~= OldTransparency then
                        ColorPicker:Update()
                    end

                    RunService.RenderStepped:Wait()
                end
            end)
        end

        HueBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local Success, Color = pcall(Color3.fromHex, HueBox.Text)
            if Success and typeof(Color) == "Color3" then
                ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
            end

            ColorPicker:Update()
        end)
        RgbBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local R, G, B = RgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
            if R and G and B then
                ColorPicker:SetHSVFromRGB(Color3.fromRGB(R, G, B))
            end

            ColorPicker:Update()
        end)

        ColorPicker:Display()

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, ColorPicker)
        end

        ColorPicker.Default = ColorPicker.Value

        Options[Idx] = ColorPicker

        return self
    end

    BaseAddons.__index = Funcs
    BaseAddons.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

local BaseGroupbox = {}
do
    local Funcs = {}

    function Funcs:AddDivider(...)
        local Params = select(1, ...)
        local Text
        local MarginTop = 0
        local MarginBottom = 0

        if typeof(Params) == "table" then
            Text = Params.Text
            MarginTop = Params.MarginTop or Params.Margin or 0
            MarginBottom = Params.MarginBottom or Params.Margin or 0
        elseif typeof(Params) == "string" then
            Text = Params
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 6 + MarginTop + MarginBottom),
            Parent = Container,
        })

        local InnerHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingTop = UDim.new(0, MarginTop),
            PaddingBottom = UDim.new(0, MarginBottom),
            Parent = Holder,
        })

        if Text then
            local TextLabel = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Text = Text,
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = InnerHolder,
            })

            local X, _ = Library:GetTextBounds(Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
            local SizeX = X // 2 + 10

            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
            New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(1, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
        else
            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Parent = InnerHolder,
            })
        end

        Groupbox:Resize()

        local Divider = {
            Holder = Holder,
            Text = Text,
            MarginTop = MarginTop,
            MarginBottom = MarginBottom,
            Type = "Divider",
        }

        table.insert(Groupbox.Elements, Divider)
        return Divider
    end

    function Funcs:AddLabel(...)
        local Data = {}
        local Addons = {}

        local First = select(1, ...)
        local Second = select(2, ...)

        if typeof(First) == "table" or typeof(Second) == "table" then
            local Params = typeof(First) == "table" and First or Second

            Data.Text = Params.Text or ""
            Data.DoesWrap = Params.DoesWrap or false
            Data.Size = Params.Size or 14
            Data.Visible = Params.Visible or true
            Data.Idx = typeof(Second) == "table" and First or nil
        else
            Data.Text = First or ""
            Data.DoesWrap = Second or false
            Data.Size = 14
            Data.Visible = true
            Data.Idx = select(3, ...) or nil
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Label = {
            Text = Data.Text,
            DoesWrap = Data.DoesWrap,

            Addons = Addons,

            Visible = Data.Visible,
            Type = "Label",
        }

        local TextLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = Label.Text,
            TextSize = Data.Size,
            TextWrapped = Label.DoesWrap,
            TextXAlignment = Groupbox.IsKeyTab and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
            Parent = Container,
        })

        function Label:SetVisible(Visible: boolean)
            Label.Visible = Visible

            TextLabel.Visible = Label.Visible
            Groupbox:Resize()
        end

        function Label:SetText(Text: string)
            Label.Text = Text
            TextLabel.Text = Text

            if Label.DoesWrap then
                local _, Y =
                    Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
                TextLabel.Size = UDim2.new(1, 0, 0, Y + 4)
            end

            Groupbox:Resize()
        end

        if Label.DoesWrap then
            local _, Y =
                Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
            TextLabel.Size = UDim2.new(1, 0, 0, Y + 4)

            local Last = TextLabel.AbsoluteSize
            TextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                if TextLabel.AbsoluteSize == Last then
                    return
                end

                local _, Y =
                    Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
                TextLabel.Size = UDim2.new(1, 0, 0, Y + 4)

                Last = TextLabel.AbsoluteSize
                Groupbox:Resize()
            end)
        else
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                Padding = UDim.new(0, 6),
                Parent = TextLabel,
            })
        end

        Groupbox:Resize()

        Label.TextLabel = TextLabel
        Label.Container = Container
        if not Data.DoesWrap then
            setmetatable(Label, BaseAddons)
        end

        Label.Holder = TextLabel
        table.insert(Groupbox.Elements, Label)

        if Data.Idx then
            Labels[Data.Idx] = Label
        else
            table.insert(Labels, Label)
        end

        return Label
    end

    function Funcs:AddButton(...)
        local function GetInfo(...)
            local Info = {}

            local First = select(1, ...)
            local Second = select(2, ...)

            if typeof(First) == "table" or typeof(Second) == "table" then
                local Params = typeof(First) == "table" and First or Second

                Info.Text = Params.Text or ""
                Info.Func = Params.Func or Params.Callback or function() end
                Info.DoubleClick = Params.DoubleClick

                Info.Tooltip = Params.Tooltip
                Info.DisabledTooltip = Params.DisabledTooltip

                Info.Risky = Params.Risky or false
                Info.Disabled = Params.Disabled or false
                Info.Visible = Params.Visible or true
                Info.Idx = typeof(Second) == "table" and First or nil
            else
                Info.Text = First or ""
                Info.Func = Second or function() end
                Info.DoubleClick = false

                Info.Tooltip = nil
                Info.DisabledTooltip = nil

                Info.Risky = false
                Info.Disabled = false
                Info.Visible = true
                Info.Idx = select(3, ...) or nil
            end

            return Info
        end
        local Info = GetInfo(...)

        local Groupbox = self
        local Container = Groupbox.Container

        local Button = {
            Text = Info.Text,
            Func = Info.Func,
            DoubleClick = Info.DoubleClick,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Tween = nil,
            Type = "Button",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Parent = Container,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 9),
            Parent = Holder,
        })

        local function CreateButton(Button)
            local Base = New("TextButton", {
                Active = not Button.Disabled,
                BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor",
                Size = UDim2.fromScale(1, 1),
                Text = Button.Text,
                TextSize = 14,
                TextTransparency = 0.35,
                Visible = Button.Visible,
                Parent = Holder,
            })

            local Stroke = New("UIStroke", {
                Color = "OutlineColor",
                Transparency = Button.Disabled and 0.5 or 0,
                Parent = Base,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Base,
                })
            )

            return Base, Stroke
        end

        local function InitEvents(Button)
            local Hovering = false

            local function Animate(
                BackgroundColor,
                TextTransparency,
                StrokeColor,
                StrokeTransparency
            )
                StopTween(Button.Tween)
                StopTween(Button.StrokeTween)

                Button.Tween = TweenService:Create(
                    Button.Base,
                    Library.TweenInfo,
                    {
                        BackgroundColor3 = BackgroundColor,
                        TextTransparency = TextTransparency,
                    }
                )

                Button.StrokeTween = TweenService:Create(
                    Button.Stroke,
                    Library.TweenInfo,
                    {
                        Color = StrokeColor,
                        Transparency = StrokeTransparency,
                    }
                )

                Button.Tween:Play()
                Button.StrokeTween:Play()
            end

            Button.Base.MouseEnter:Connect(function()
                if Button.Disabled then
                    return
                end

                Hovering = true

                Animate(
                    Library:GetBetterColor(
                        Library.Scheme.MainColor,
                        3
                    ),
                    0.05,
                    Library.Scheme.AccentColor,
                    0.35
                )
            end)

            Button.Base.MouseLeave:Connect(function()
                if Button.Disabled then
                    return
                end

                Hovering = false

                Animate(
                    Library.Scheme.MainColor,
                    0.35,
                    Library.Scheme.OutlineColor,
                    0
                )
            end)

            Button.Base.InputBegan:Connect(function(Input)
                if Button.Disabled
                or not IsClickInput(Input) then
                    return
                end

                Animate(
                    Library:GetBetterColor(
                        Library.Scheme.MainColor,
                        7
                    ),
                    0,
                    Library.Scheme.AccentColor,
                    0.1
                )
            end)

            Button.Base.InputEnded:Connect(function(Input)
                if Button.Disabled
                or not IsMouseInput(Input) then
                    return
                end

                Animate(
                    Hovering
                        and Library:GetBetterColor(
                            Library.Scheme.MainColor,
                            3
                        )
                        or Library.Scheme.MainColor,
                    Hovering and 0.05 or 0.35,
                    Hovering
                        and Library.Scheme.AccentColor
                        or Library.Scheme.OutlineColor,
                    Hovering and 0.35 or 0
                )
            end)

            Button.Base.MouseButton1Click:Connect(function()
                if Button.Disabled or Button.Locked then
                    return
                end

                if Button.DoubleClick then
                    Button.Locked = true

                    Button.Base.Text = "Are you sure?"
                    Button.Base.TextColor3 = Library.Scheme.AccentColor
                    Library.Registry[Button.Base].TextColor3 = "AccentColor"

                    local Clicked = WaitForEvent(Button.Base.MouseButton1Click, 3)

                    Button.Base.Text = Button.Text
                    Button.Base.TextColor3 = Button.Risky and Library.Scheme.RedColor or Library.Scheme.FontColor
                    Library.Registry[Button.Base].TextColor3 = Button.Risky and "RedColor" or "FontColor"

                    if Clicked then
                        Library:SafeCallback(Button.Func)
                    end

                    RunService.RenderStepped:Wait() --// Mouse Button fires without waiting (i hate roblox)
                    Button.Locked = false
                    return
                end

                Library:SafeCallback(Button.Func)
            end)
        end

        Button.Base, Button.Stroke = CreateButton(Button)
        InitEvents(Button)

        function Button:AddButton(...)
            local Info = GetInfo(...)

            local SubButton = {
                Text = Info.Text,
                Func = Info.Func,
                DoubleClick = Info.DoubleClick,

                Tooltip = Info.Tooltip,
                DisabledTooltip = Info.DisabledTooltip,
                TooltipTable = nil,

                Risky = Info.Risky,
                Disabled = Info.Disabled,
                Visible = Info.Visible,

                Tween = nil,
                Type = "SubButton",
            }

            Button.SubButton = SubButton
            SubButton.Base, SubButton.Stroke = CreateButton(SubButton)
            InitEvents(SubButton)

            function SubButton:UpdateColors()
                if Library.Unloaded then
                    return
                end

                StopTween(SubButton.Tween)

                SubButton.Base.BackgroundColor3 = SubButton.Disabled and Library.Scheme.BackgroundColor
                    or Library.Scheme.MainColor
                SubButton.Base.TextTransparency = SubButton.Disabled and 0.8 or 0.35
                SubButton.Stroke.Transparency = SubButton.Disabled and 0.5 or 0

                Library.Registry[SubButton.Base].BackgroundColor3 = SubButton.Disabled and "BackgroundColor"
                    or "MainColor"
            end

            function SubButton:SetDisabled(Disabled: boolean)
                SubButton.Disabled = Disabled

                if SubButton.TooltipTable then
                    SubButton.TooltipTable.Disabled = SubButton.Disabled
                end

                SubButton.Base.Active = not SubButton.Disabled
                SubButton:UpdateColors()
            end

            function SubButton:SetVisible(Visible: boolean)
                SubButton.Visible = Visible

                SubButton.Base.Visible = SubButton.Visible
                Groupbox:Resize()
            end

            function SubButton:SetText(Text: string)
                SubButton.Text = Text
                SubButton.Base.Text = Text
            end

            if typeof(SubButton.Tooltip) == "string" or typeof(SubButton.DisabledTooltip) == "string" then
                SubButton.TooltipTable =
                    Library:AddTooltip(SubButton.Tooltip, SubButton.DisabledTooltip, SubButton.Base)
                SubButton.TooltipTable.Disabled = SubButton.Disabled
            end

            if SubButton.Risky then
                SubButton.Base.TextColor3 = Library.Scheme.RedColor
                Library.Registry[SubButton.Base].TextColor3 = "RedColor"
            end

            SubButton:UpdateColors()

            if Info.Idx then
                Buttons[Info.Idx] = SubButton
            else
                table.insert(Buttons, SubButton)
            end

            return SubButton
        end

        function Button:UpdateColors()
            if Library.Unloaded then
                return
            end

            StopTween(Button.Tween)

            Button.Base.BackgroundColor3 = Button.Disabled and Library.Scheme.BackgroundColor
                or Library.Scheme.MainColor
            Button.Base.TextTransparency = Button.Disabled and 0.8 or 0.35
            Button.Stroke.Transparency = Button.Disabled and 0.5 or 0

            Library.Registry[Button.Base].BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor"
        end

        function Button:SetDisabled(Disabled: boolean)
            Button.Disabled = Disabled

            if Button.TooltipTable then
                Button.TooltipTable.Disabled = Button.Disabled
            end

            Button.Base.Active = not Button.Disabled
            Button:UpdateColors()
        end

        function Button:SetVisible(Visible: boolean)
            Button.Visible = Visible

            Holder.Visible = Button.Visible
            Groupbox:Resize()
        end

        function Button:SetText(Text: string)
            Button.Text = Text
            Button.Base.Text = Text
        end

        if typeof(Button.Tooltip) == "string" or typeof(Button.DisabledTooltip) == "string" then
            Button.TooltipTable = Library:AddTooltip(Button.Tooltip, Button.DisabledTooltip, Button.Base)
            Button.TooltipTable.Disabled = Button.Disabled
        end

        if Button.Risky then
            Button.Base.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Button.Base].TextColor3 = "RedColor"
        end

        Button:UpdateColors()
        Groupbox:Resize()

        Button.Holder = Holder
        table.insert(Groupbox.Elements, Button)

        if Info.Idx then
            Buttons[Info.Idx] = Button
        else
            table.insert(Buttons, Button)
        end

        return Button
    end

    function Funcs:AddActionRow(Idx, Info)

        Info =
            Info
            or {}

        local Groupbox =
            self

        local Container =
            Groupbox.Container

        local ButtonsInfo =
            Info.Buttons
            or {}

        local RowHeight =
            tonumber(Info.Height)
            or 21

        local Gap =
            tonumber(Info.Gap)
            or 9

        local ActionRow = {
            Buttons = {},
            ButtonMap = {},
            Visible = Info.Visible ~= false,
            Type = "ActionRow",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, RowHeight),
            Visible = ActionRow.Visible,
            Parent = Container,
        })

        local List = New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, Gap),
            Parent = Holder,
        })

        local function CreateActionButton(buttonInfo)

            buttonInfo =
                buttonInfo
                or {}

            local buttonId =
                tostring(buttonInfo.Id or buttonInfo.Text or "Button")

            local Button = {
                Id = buttonId,
                Text = tostring(buttonInfo.Text or buttonId),
                Callback = buttonInfo.Callback or buttonInfo.Func,
                Tooltip = buttonInfo.Tooltip,
                DisabledTooltip = buttonInfo.DisabledTooltip,
                Risky = buttonInfo.Risky == true,
                DoubleClick = buttonInfo.DoubleClick == true,
                Disabled = buttonInfo.Disabled == true,
                Visible = buttonInfo.Visible ~= false,
                Locked = false,
                Type = "ActionRowButton",
            }

            local Base = New("TextButton", {
                Active = not Button.Disabled,
                BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor",
                Size = UDim2.fromScale(1, 1),
                Text = Button.Text,
                TextSize = 14,
                TextTransparency = Button.Disabled and 0.8 or 0.35,
                Visible = Button.Visible,
                Parent = Holder,
            })

            local Stroke = New("UIStroke", {
                Color = "OutlineColor",
                Transparency = Button.Disabled and 0.5 or 0,
                Parent = Base,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Base,
                })
            )

            Button.Base =
                Base

            Button.Stroke =
                Stroke

            function Button:UpdateColors()

                if Library.Unloaded then
                    return
                end

                Base.Active =
                    not Button.Disabled

                Base.BackgroundColor3 =
                    Button.Disabled and Library.Scheme.BackgroundColor
                    or Library.Scheme.MainColor

                Base.TextTransparency =
                    Button.Disabled and 0.8
                    or 0.35

                Stroke.Transparency =
                    Button.Disabled and 0.5
                    or 0

                Library.Registry[Base].BackgroundColor3 =
                    Button.Disabled and "BackgroundColor"
                    or "MainColor"
            end

            function Button:SetDisabled(disabled)

                Button.Disabled =
                    disabled == true

                if Button.TooltipTable then
                    Button.TooltipTable.Disabled =
                        Button.Disabled
                end

                Button:UpdateColors()
            end

            function Button:SetVisible(visible)

                Button.Visible =
                    visible == true

                Base.Visible =
                    Button.Visible

                Groupbox:Resize()
            end

            function Button:SetText(text)

                Button.Text =
                    tostring(text or "")

                Base.Text =
                    Button.Text
            end

            Base.MouseEnter:Connect(function()

                if Button.Disabled then
                    return
                end

                TweenService:Create(Base, Library.TweenInfo, {
                    TextTransparency = 0,
                }):Play()
            end)

            Base.MouseLeave:Connect(function()

                if Button.Disabled then
                    return
                end

                TweenService:Create(Base, Library.TweenInfo, {
                    TextTransparency = 0.35,
                }):Play()
            end)

            Base.MouseButton1Click:Connect(function()

                if Button.Disabled
                or Button.Locked then
                    return
                end

                if Button.DoubleClick then

                    Button.Locked =
                        true

                    local oldText =
                        Base.Text

                    Base.Text =
                        "Are you sure?"

                    Base.TextColor3 =
                        Library.Scheme.AccentColor

                    Library.Registry[Base].TextColor3 =
                        "AccentColor"

                    local clicked =
                        WaitForEvent(
                            Base.MouseButton1Click,
                            3
                        )

                    Base.Text =
                        oldText

                    Base.TextColor3 =
                        Button.Risky and Library.Scheme.RedColor
                        or Library.Scheme.FontColor

                    Library.Registry[Base].TextColor3 =
                        Button.Risky and "RedColor"
                        or "FontColor"

                    if clicked
                    and type(Button.Callback) == "function" then
                        Library:SafeCallback(Button.Callback)
                    end

                    RunService.RenderStepped:Wait()

                    Button.Locked =
                        false

                    return
                end

                if type(Button.Callback) == "function" then
                    Library:SafeCallback(Button.Callback)
                end
            end)

            if typeof(Button.Tooltip) == "string"
            or typeof(Button.DisabledTooltip) == "string" then

                Button.TooltipTable =
                    Library:AddTooltip(
                        Button.Tooltip,
                        Button.DisabledTooltip,
                        Base
                    )

                Button.TooltipTable.Disabled =
                    Button.Disabled
            end

            if Button.Risky then
                Base.TextColor3 =
                    Library.Scheme.RedColor

                Library.Registry[Base].TextColor3 =
                    "RedColor"
            end

            Button:UpdateColors()

            table.insert(
                ActionRow.Buttons,
                Button
            )

            ActionRow.ButtonMap[buttonId] =
                Button

            return Button
        end

        for _, buttonInfo in ipairs(ButtonsInfo) do
            CreateActionButton(buttonInfo)
        end

        function ActionRow:GetButton(buttonId)

            return ActionRow.ButtonMap[
                tostring(buttonId or "")
            ]
        end

        function ActionRow:SetVisible(visible)

            ActionRow.Visible =
                visible == true

            Holder.Visible =
                ActionRow.Visible

            Groupbox:Resize()
        end

        function ActionRow:SetDisabled(buttonId, disabled)

            local button =
                ActionRow:GetButton(buttonId)

            if button
            and type(button.SetDisabled) == "function" then
                button:SetDisabled(disabled)
            end
        end

        function ActionRow:SetText(buttonId, text)

            local button =
                ActionRow:GetButton(buttonId)

            if button
            and type(button.SetText) == "function" then
                button:SetText(text)
            end
        end

        ActionRow.Holder =
            Holder

        table.insert(
            Groupbox.Elements,
            ActionRow
        )

        Options[Idx] =
            ActionRow

        Groupbox:Resize()

        return ActionRow
    end

    function Funcs:AddFilterList(Idx, Info)

        Info =
            Info
            or {}

        local Groupbox =
            self

        local Container =
            Groupbox.Container

        local RowCount =
            math.clamp(
                tonumber(Info.Rows) or 8,
                1,
                20
            )

        local RowHeight =
            tonumber(Info.RowHeight)
            or 24

        local HeaderHeight =
            tonumber(Info.HeaderHeight)
            or 20

        local Callback =
            Info.Callback

        local FilterList = {
            Rows = {},
            RowData = {},
            SelectedIndex = nil,
            Visible = Info.Visible ~= false,
            Type = "FilterList",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(
                1,
                0,
                0,
                HeaderHeight + (RowCount * RowHeight) + 4
            ),
            Visible = FilterList.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Box,
            })
        )

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Box,
        })

        local Header = New("Frame", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.25,
            Size = UDim2.new(1, 0, 0, HeaderHeight),
            Parent = Box,
        })

        New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(8, 0),
            Size = UDim2.new(0.50, -8, 1, 0),
            Text = "Pet",
            TextSize = 13,
            TextTransparency = 0.35,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Header,
        })

        New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.52, 0),
            Size = UDim2.new(0.18, 0, 1, 0),
            Text = "Max",
            TextSize = 13,
            TextTransparency = 0.35,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Header,
        })

        New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.70, 0),
            Size = UDim2.new(0.14, 0, 1, 0),
            Text = "BW",
            TextSize = 13,
            TextTransparency = 0.35,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Header,
        })

        New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.84, 0),
            Size = UDim2.new(0.16, -8, 1, 0),
            Text = "Pri",
            TextSize = 13,
            TextTransparency = 0.35,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Header,
        })

        local RowsHolder = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, HeaderHeight + 2),
            Size = UDim2.new(1, 0, 1, -HeaderHeight - 2),
            Parent = Box,
        })

        local function ApplyRowVisual(row)

            local hasData =
                row.Data ~= nil

            local selected =
                row.Index == FilterList.SelectedIndex
                and hasData == true

            row.Button.Active =
                hasData

            row.Button.BackgroundTransparency =
                selected and 0.15 or 1

            row.Marker.BackgroundTransparency =
                selected and 0 or 1

            row.Pet.TextTransparency =
                hasData and (selected and 0 or 0.18) or 0.75

            row.Max.TextTransparency =
                hasData and (selected and 0.05 or 0.30) or 0.85

            row.Weight.TextTransparency =
                hasData and (selected and 0.05 or 0.30) or 0.85

            row.Priority.TextTransparency =
                hasData and (selected and 0.05 or 0.30) or 0.85
        end

        local function SetRowText(label, value)

            label.Text =
                tostring(value or "")
        end

        for rowIndex = 1, RowCount do

            local RowButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Position = UDim2.new(
                    0,
                    0,
                    0,
                    (rowIndex - 1) * RowHeight
                ),
                Size = UDim2.new(1, 0, 0, RowHeight),
                Text = "",
                Parent = RowsHolder,
            })

            local Marker = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(3, 5),
                Size = UDim2.new(0, 3, 1, -10),
                Parent = RowButton,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = Marker,
                })
            )

            local PetLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(10, 0),
                Size = UDim2.new(0.50, -10, 1, 0),
                Text = "",
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = RowButton,
            })

            local MaxLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.52, 0),
                Size = UDim2.new(0.18, 0, 1, 0),
                Text = "",
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = RowButton,
            })

            local WeightLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.70, 0),
                Size = UDim2.new(0.14, 0, 1, 0),
                Text = "",
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = RowButton,
            })

            local PriorityLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.84, 0),
                Size = UDim2.new(0.16, -8, 1, 0),
                Text = "",
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = RowButton,
            })

            local row = {
                Index = rowIndex,
                Button = RowButton,
                Marker = Marker,
                Pet = PetLabel,
                Max = MaxLabel,
                Weight = WeightLabel,
                Priority = PriorityLabel,
                Data = nil,
            }

            RowButton.MouseEnter:Connect(function()

                if row.Data == nil then
                    return
                end

                if row.Index ~= FilterList.SelectedIndex then
                    RowButton.BackgroundTransparency = 0.72
                end
            end)

            RowButton.MouseLeave:Connect(function()

                ApplyRowVisual(row)
            end)

            RowButton.MouseButton1Click:Connect(function()

                if row.Data == nil then
                    return
                end

                FilterList:SetSelected(rowIndex)

                if typeof(Callback) == "function" then
                    Library:SafeCallback(
                        Callback,
                        rowIndex,
                        row.Data
                    )
                end
            end)

            table.insert(
                FilterList.Rows,
                row
            )

            ApplyRowVisual(row)
        end

        function FilterList:SetRows(rows)

            FilterList.RowData =
                rows
                or {}

            for index, row in ipairs(FilterList.Rows) do

                local data =
                    FilterList.RowData[index]

                row.Data =
                    data

                if type(data) == "table" then

                    SetRowText(
                        row.Pet,
                        data.Pet
                        or data.PetName
                    )

                    SetRowText(
                        row.Max,
                        data.Max
                        or data.MaxPrice
                    )

                    SetRowText(
                        row.Weight,
                        data.Weight
                        or data.BW
                        or data.MinWeight
                    )

                    SetRowText(
                        row.Priority,
                        data.Priority
                    )

                else

                    SetRowText(row.Pet, "")
                    SetRowText(row.Max, "")
                    SetRowText(row.Weight, "")
                    SetRowText(row.Priority, "")
                end

                ApplyRowVisual(row)
            end
        end

        function FilterList:SetSelected(index)

            FilterList.SelectedIndex =
                tonumber(index)

            for _, row in ipairs(FilterList.Rows) do
                ApplyRowVisual(row)
            end
        end

        function FilterList:SetVisible(visible)

            FilterList.Visible =
                visible == true

            Holder.Visible =
                FilterList.Visible

            Groupbox:Resize()
        end

        function FilterList:SetHeight(rowCount)

            rowCount =
                math.clamp(
                    tonumber(rowCount) or RowCount,
                    1,
                    20
                )

            RowCount =
                rowCount

            Holder.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    HeaderHeight + (RowCount * RowHeight) + 4
                )

            Groupbox:Resize()
        end

        FilterList.Holder =
            Holder

        table.insert(
            Groupbox.Elements,
            FilterList
        )

        Options[Idx] =
            FilterList

        Groupbox:Resize()

        return FilterList
    end

    function Funcs:AddStatusList(Idx, Info)

        Info =
            Info
            or {}

        local Groupbox =
            self

        local Container =
            Groupbox.Container

        local RowHeight =
            tonumber(Info.RowHeight)
            or 24

        local KeyWidth =
            tonumber(Info.KeyWidth)
            or 0.38

        local Rows =
            Info.Rows
            or {}

        local StatusList = {
            Rows = {},
            RowMap = {},
            Visible = Info.Visible ~= false,
            Type = "StatusList",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(
                1,
                0,
                0,
                math.max(1, #Rows) * RowHeight
            ),
            Visible = StatusList.Visible,
            Parent = Container,
        })

        local RowHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        local function ApplyRowPosition(row, index)

            row.Holder.Position =
                UDim2.new(
                    0,
                    0,
                    0,
                    (index - 1) * RowHeight
                )

            row.Holder.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    RowHeight
                )
        end

        local function CreateRow(index, keyText, valueText)

            local Row = {}

            local RowFrame = New("Frame", {
                BackgroundTransparency = 1,
                Parent = RowHolder,
            })

            local KeyLabel = New("TextLabel", {
                BackgroundTransparency = 1,

                FontFace =
                    function()

                        return Library:GetWeightedFont(
                            Enum.FontWeight.SemiBold
                        )
                    end,

                Position = UDim2.fromOffset(0, 0),
                Size = UDim2.new(KeyWidth, -4, 1, 0),
                Text = tostring(keyText or ""),
                TextSize = 13,
                TextTransparency = 0.22,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = RowFrame,
            })

            local ValueLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(KeyWidth, 4, 0, 0),
                Size = UDim2.new(1 - KeyWidth, -4, 1, 0),
                Text = tostring(valueText or ""),
                TextSize = 13,
                TextTransparency = 0.05,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = RowFrame,
            })

            Row.Index =
                index

            Row.Key =
                tostring(keyText or "")

            Row.Value =
                tostring(valueText or "")

            Row.Holder =
                RowFrame

            Row.KeyLabel =
                KeyLabel

            Row.ValueLabel =
                ValueLabel

            ApplyRowPosition(
                Row,
                index
            )

            return Row
        end

        function StatusList:Resize()

            Holder.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    math.max(1, #StatusList.Rows) * RowHeight
                )

            Groupbox:Resize()
        end

        function StatusList:SetRows(rows)

            rows =
                rows
                or {}

            for _, row in ipairs(StatusList.Rows) do

                if row.Holder then
                    row.Holder:Destroy()
                end
            end

            table.clear(StatusList.Rows)
            table.clear(StatusList.RowMap)

            for index, rowData in ipairs(rows) do

                local keyText =
                    rowData[1]
                    or rowData.Key
                    or rowData.Name
                    or ""

                local valueText =
                    rowData[2]
                    or rowData.Value
                    or ""

                local row =
                    CreateRow(
                        index,
                        keyText,
                        valueText
                    )

                table.insert(
                    StatusList.Rows,
                    row
                )

                StatusList.RowMap[tostring(keyText)] =
                    row
            end

            StatusList:Resize()
        end

        function StatusList:SetRow(keyText, valueText)

            keyText =
                tostring(keyText or "")

            local row =
                StatusList.RowMap[keyText]

            if not row then

                row =
                    CreateRow(
                        #StatusList.Rows + 1,
                        keyText,
                        valueText
                    )

                table.insert(
                    StatusList.Rows,
                    row
                )

                StatusList.RowMap[keyText] =
                    row

                StatusList:Resize()

                return
            end

            row.Value =
                tostring(valueText or "")

            row.ValueLabel.Text =
                row.Value
        end

        function StatusList:SetVisible(visible)

            StatusList.Visible =
                visible == true

            Holder.Visible =
                StatusList.Visible

            Groupbox:Resize()
        end

        function StatusList:SetKeyText(keyText, newKeyText)

            keyText =
                tostring(keyText or "")

            newKeyText =
                tostring(newKeyText or "")

            local row =
                StatusList.RowMap[keyText]

            if not row then
                return
            end

            StatusList.RowMap[keyText] =
                nil

            row.Key =
                newKeyText

            row.KeyLabel.Text =
                newKeyText

            StatusList.RowMap[newKeyText] =
                row
        end

        function StatusList:SetTextTransparency(keyText, keyTransparency, valueTransparency)

            keyText =
                tostring(keyText or "")

            local row =
                StatusList.RowMap[keyText]

            if not row then
                return
            end

            row.KeyLabel.TextTransparency =
                tonumber(keyTransparency)
                or row.KeyLabel.TextTransparency

            row.ValueLabel.TextTransparency =
                tonumber(valueTransparency)
                or row.ValueLabel.TextTransparency
        end

        function StatusList:SetRowTone(keyText, tone)

            keyText =
                tostring(keyText or "")

            local row =
                StatusList.RowMap[keyText]

            if not row
            or typeof(row.ValueLabel) ~= "Instance" then

                return false
            end

            local normalized =
                tostring(
                    tone
                    or "Normal"
                )
                    :lower()
                    :gsub(
                        "[%s_%-]",
                        ""
                    )

            local colorKeys = {
                normal =
                    "FontColor",

                accent =
                    "AccentColor",

                success =
                    "SuccessColor",

                active =
                    "SuccessColor",

                ready =
                    "SuccessColor",

                warning =
                    "WarningColor",

                waiting =
                    "WarningColor",

                paused =
                    "WarningColor",

                muted =
                    "MutedColor",

                idle =
                    "MutedColor",

                disabled =
                    "MutedColor",

                danger =
                    "RedColor",

                destructive =
                    "RedColor",

                error =
                    "RedColor",

                unavailable =
                    "RedColor",

                red =
                    "RedColor",
            }

            local colorKey =
                colorKeys[normalized]
                or "FontColor"

            Library.Registry[row.ValueLabel] =
                type(
                    Library.Registry[row.ValueLabel]
                ) == "table"
                and Library.Registry[row.ValueLabel]
                or {}

            Library.Registry[row.ValueLabel].TextColor3 =
                colorKey

            row.ValueLabel.TextColor3 =
                Library.Scheme[colorKey]
                or Library.Scheme.FontColor

            row.Tone =
                normalized

            return true
        end

        StatusList:SetRows(
            Rows
        )

        StatusList.Holder =
            Holder

        table.insert(
            Groupbox.Elements,
            StatusList
        )

        Options[Idx] =
            StatusList

        Groupbox:Resize()

        return StatusList
    end
    function Funcs:AddPetMarketList(Idx, Info)

        Info =
            Info
            or {}

        local Groupbox =
            self

        local Container =
            Groupbox.Container

        local RowCount =
            math.clamp(
                tonumber(Info.Rows) or 6,
                1,
                14
            )

        local RowHeight =
            tonumber(Info.RowHeight)
            or 42

        local SummaryHeight =
            tonumber(Info.SummaryHeight)
            or 18

        local ModeHeight =
            tonumber(Info.ModeHeight)
            or 18

        local EmptyHeight =
            tonumber(Info.EmptyHeight)
            or 28

        local Callback =
            Info.Callback

        local PetMarketList = {
            Rows = {},
            RowData = {},
            RowByKey = {},
            SelectedIndex = nil,
            SelectedKey = nil,
            Summary = tostring(Info.Summary or "Next Spawn: --:-- | Active: 0"),
            ModeText = tostring(Info.ModeText or "Mode: Walk · Instant | Click a pet to buy"),
            EmptyText = tostring(Info.EmptyText or "No active wild pets."),
            Visible = Info.Visible ~= false,
            Type = "PetMarketList",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, SummaryHeight + ModeHeight + EmptyHeight + 10),
            Visible = PetMarketList.Visible,
            Parent = Container,
        })

        local SummaryLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, SummaryHeight),
            Text = PetMarketList.Summary,
            TextSize = 13,
            TextTransparency = 0.10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = Holder,
        })

        local ModeLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, SummaryHeight),
            Size = UDim2.new(1, 0, 0, ModeHeight),
            Text = PetMarketList.ModeText,
            TextSize = 12,
            TextTransparency = 0.42,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = Holder,
        })

        local RowsHolder = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, SummaryHeight + ModeHeight + 6),
            Size = UDim2.new(1, 0, 0, EmptyHeight),
            Parent = Holder,
        })

        local EmptyLabel = New("TextLabel", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.45,
            Size = UDim2.new(1, 0, 0, EmptyHeight),
            Text = PetMarketList.EmptyText,
            TextSize = 13,
            TextTransparency = 0.55,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = RowsHolder,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = EmptyLabel,
            })
        )

        New("UIStroke", {
            Color = "OutlineColor",
            Transparency = 0.55,
            Parent = EmptyLabel,
        })

        local function ReadState(data)

            local state =
                tostring(
                    type(data) == "table"
                    and data.State
                    or "ready"
                ):lower()

            if state == "" then
                state =
                    "ready"
            end

            return state
        end

        local function ReadBadge(data)

            if type(data) ~= "table" then
                return ""
            end

            local state =
                ReadState(data)

            if state == "buying" then
                return "BUYING"
            end

            if state == "sent"
            or state == "bought" then
                return "SENT"
            end

            if state == "gone" then
                return "GONE"
            end

            if state == "blocked" then
                return tostring(data.Badge or "WAIT")
            end

            if tostring(data.Badge or "") ~= "" then
                return tostring(data.Badge)
            end

            if data.Match == true then
                return "MATCH"
            end

            return "BUY"
        end

        local function GetAccentColor(data)

            if type(data) ~= "table" then
                return Library.Scheme.OutlineColor
            end

            local state =
                ReadState(data)

            if state == "gone"
            or state == "blocked" then
                return Library.Scheme.RedColor
            end

            if state == "sent"
            or state == "bought" then
                return Library.Scheme.OutlineColor
            end

            if state == "buying"
            or data.Match == true
            or tostring(data.Badge or "") == "MATCH" then
                return Library.Scheme.AccentColor
            end

            return Library.Scheme.AccentColor
        end

        local function IsDisabledState(data)

            local state =
                ReadState(data)

            return state == "sent"
                or state == "bought"
                or state == "gone"
                or data.Clickable == false
        end

        local function ApplyRowPosition(row, index)

            row.Holder.Position =
                UDim2.new(
                    0,
                    0,
                    0,
                    (index - 1) * RowHeight
                )

            row.Holder.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    RowHeight - 5
                )
        end

        local function ApplyRowVisual(row)

            local data =
                row.Data

            local hasData =
                type(data) == "table"

            row.Holder.Visible =
                hasData

            if not hasData then
                return
            end

            local state =
                ReadState(data)

            local selected =
                row.Index == PetMarketList.SelectedIndex
                and hasData == true

            local disabled =
                IsDisabledState(data)

            local accent =
                GetAccentColor(data)

            row.Button.Active =
                disabled ~= true

            row.Button.BackgroundTransparency =
                selected and 0.10
                or state == "buying" and 0.13
                or data.Match == true and 0.20
                or 0.30

            row.Stroke.Transparency =
                selected and 0
                or data.Match == true and 0.08
                or 0.38

            row.Marker.BackgroundColor3 =
                accent

            row.Marker.BackgroundTransparency =
                disabled and 0.40
                or 0

            row.Dot.BackgroundColor3 =
                accent

            row.Dot.BackgroundTransparency =
                disabled and 0.45
                or 0

            row.Pet.TextTransparency =
                disabled and 0.45
                or 0.02

            row.Meta.TextTransparency =
                disabled and 0.62
                or 0.32

            row.Timer.TextTransparency =
                disabled and 0.58
                or 0.18

            row.Badge.TextColor3 =
                accent

            row.Badge.TextTransparency =
                disabled and 0.42
                or 0.04

            row.Badge.Text =
                ReadBadge(data)
        end

        local function SetLabelText(label, text)

            label.Text =
                tostring(text or "")
        end

        local function CreateRow(rowIndex)

            local RowButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 0.30,
                Position = UDim2.new(0, 0, 0, (rowIndex - 1) * RowHeight),
                Size = UDim2.new(1, 0, 0, RowHeight - 5),
                Text = "",
                Visible = false,
                Parent = RowsHolder,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = RowButton,
                })
            )

            local Stroke = New("UIStroke", {
                Color = "OutlineColor",
                Transparency = 0.38,
                Parent = RowButton,
            })

            local Marker = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0,
                Position = UDim2.fromOffset(0, 0),
                Size = UDim2.new(0, 3, 1, 0),
                Parent = RowButton,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Marker,
                })
            )

            local Dot = New("Frame", {
                BackgroundColor3 = "AccentColor",
                Position = UDim2.fromOffset(10, 8),
                Size = UDim2.fromOffset(6, 6),
                Parent = RowButton,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = Dot,
                })
            )

            local PetLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(22, 2),
                Size = UDim2.new(0.68, -22, 0, 17),
                Text = "",
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = RowButton,
            })

            local BadgeLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.70, 0, 0, 2),
                Size = UDim2.new(0.30, -8, 0, 17),
                Text = "BUY",
                TextSize = 12,
                TextColor3 = "AccentColor",
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = RowButton,
            })

            local MetaLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(22, 19),
                Size = UDim2.new(0.68, -22, 0, 16),
                Text = "",
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = RowButton,
            })

            local TimerLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.70, 0, 0, 19),
                Size = UDim2.new(0.30, -8, 0, 16),
                Text = "",
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = RowButton,
            })

            local row = {
                Index = rowIndex,
                Holder = RowButton,
                Button = RowButton,
                Stroke = Stroke,
                Marker = Marker,
                Dot = Dot,
                Pet = PetLabel,
                Badge = BadgeLabel,
                Meta = MetaLabel,
                Timer = TimerLabel,
                Data = nil,
            }

            RowButton.MouseEnter:Connect(function()

                if row.Data == nil then
                    return
                end

                if IsDisabledState(row.Data) == true then
                    return
                end

                if row.Index ~= PetMarketList.SelectedIndex then
                    RowButton.BackgroundTransparency =
                        0.18
                end

                Stroke.Transparency =
                    0.02
            end)

            RowButton.MouseLeave:Connect(function()

                ApplyRowVisual(
                    row
                )
            end)

            RowButton.MouseButton1Click:Connect(function()

                if row.Data == nil then
                    return
                end

                if IsDisabledState(row.Data) == true then
                    return
                end

                PetMarketList:SetSelected(
                    rowIndex
                )

                if typeof(Callback) == "function" then

                    Library:SafeCallback(
                        Callback,
                        rowIndex,
                        row.Data
                    )
                end
            end)

            ApplyRowPosition(
                row,
                rowIndex
            )

            ApplyRowVisual(
                row
            )

            return row
        end

        for rowIndex = 1, RowCount do

            table.insert(
                PetMarketList.Rows,
                CreateRow(rowIndex)
            )
        end

        function PetMarketList:Resize()

            local visibleRows =
                math.min(
                    #PetMarketList.RowData,
                    RowCount
                )

            local rowsHeight =
                visibleRows > 0
                and (visibleRows * RowHeight)
                or EmptyHeight

            Holder.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    SummaryHeight + ModeHeight + rowsHeight + 10
                )

            RowsHolder.Position =
                UDim2.fromOffset(
                    0,
                    SummaryHeight + ModeHeight + 6
                )

            RowsHolder.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    rowsHeight
                )

            EmptyLabel.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    EmptyHeight
                )

            for index, row in ipairs(PetMarketList.Rows) do

                ApplyRowPosition(
                    row,
                    index
                )
            end

            Groupbox:Resize()
        end

        function PetMarketList:SetSummary(text)

            PetMarketList.Summary =
                tostring(text or "")

            SummaryLabel.Text =
                PetMarketList.Summary
        end

        function PetMarketList:SetModeText(text)

            PetMarketList.ModeText =
                tostring(text or "")

            ModeLabel.Text =
                PetMarketList.ModeText
        end

        function PetMarketList:SetRows(rows)

            rows =
                rows
                or {}

            PetMarketList.RowData =
                rows

            table.clear(
                PetMarketList.RowByKey
            )

            EmptyLabel.Visible =
                #rows <= 0

            for index, row in ipairs(PetMarketList.Rows) do

                local data =
                    rows[index]

                row.Data =
                    data

                if type(data) == "table" then

                    local key =
                        tostring(
                            data.Key
                            or data.UUID
                            or data.Id
                            or index
                        )

                    PetMarketList.RowByKey[key] =
                        row

                    SetLabelText(
                        row.Pet,
                        data.DisplayName
                        or data.Pet
                        or data.Name
                        or data.PetName
                        or "?"
                    )

                    SetLabelText(
                        row.Meta,
                        data.Meta
                        or data.Info
                        or data.Details
                        or data.Price
                        or ""
                    )

                    SetLabelText(
                        row.Timer,
                        data.Timer
                        or data.Time
                        or data.TimeLeft
                        or ""
                    )

                else

                    SetLabelText(row.Pet, "")
                    SetLabelText(row.Meta, "")
                    SetLabelText(row.Timer, "")
                end

                ApplyRowVisual(
                    row
                )
            end

            if PetMarketList.SelectedKey then

                local selectedRow =
                    PetMarketList.RowByKey[
                        tostring(PetMarketList.SelectedKey)
                    ]

                PetMarketList.SelectedIndex =
                    selectedRow
                    and selectedRow.Index
                    or nil
            end

            PetMarketList:Resize()
        end

        function PetMarketList:SetSelected(index)

            PetMarketList.SelectedIndex =
                tonumber(index)

            local row =
                PetMarketList.SelectedIndex
                and PetMarketList.Rows[PetMarketList.SelectedIndex]
                or nil

            PetMarketList.SelectedKey =
                row
                and row.Data
                and (
                    row.Data.Key
                    or row.Data.UUID
                    or row.Data.Id
                )
                or nil

            for _, rowData in ipairs(PetMarketList.Rows) do

                ApplyRowVisual(
                    rowData
                )
            end
        end

        function PetMarketList:GetSelectedData()

            local index =
                tonumber(PetMarketList.SelectedIndex)

            if not index then
                return nil
            end

            return PetMarketList.RowData[index]
        end

        function PetMarketList:SetState(index, state)

            index =
                tonumber(index)

            local row =
                index
                and PetMarketList.Rows[index]
                or nil

            if not row
            or type(row.Data) ~= "table" then
                return
            end

            row.Data.State =
                tostring(state or "ready")

            ApplyRowVisual(
                row
            )
        end

        function PetMarketList:SetStateByKey(key, state)

            key =
                tostring(key or "")

            local row =
                PetMarketList.RowByKey[key]

            if not row
            or type(row.Data) ~= "table" then
                return
            end

            row.Data.State =
                tostring(state or "ready")

            ApplyRowVisual(
                row
            )
        end

        function PetMarketList:SetVisible(visible)

            PetMarketList.Visible =
                visible == true

            Holder.Visible =
                PetMarketList.Visible

            Groupbox:Resize()
        end

        PetMarketList.Holder =
            Holder

        table.insert(
            Groupbox.Elements,
            PetMarketList
        )

        Options[Idx] =
            PetMarketList

        PetMarketList:SetRows(
            Info.RowsData
            or {}
        )

        Groupbox:Resize()

        return PetMarketList
    end

    function Funcs:AddSniperWatchlist(Idx, Info)

        Info =
            Info
            or {}

        local Groupbox =
            self

        local Container =
            Groupbox.Container

        local RowCount =
            math.clamp(
                tonumber(Info.Rows) or 7,
                1,
                16
            )

        local RowHeight =
            tonumber(Info.RowHeight)
            or 23

        local HeaderHeight =
            tonumber(Info.HeaderHeight)
            or 20

        local Callback =
            Info.Callback

        local AutoJoinLayout =
            tostring(
                Info.Layout
                or ""
            ) == "AutoJoin"

        local Watchlist = {
            Rows = {},
            RowData = {},
            SelectedIndex = nil,
            Visible = Info.Visible ~= false,
            Type = "SniperWatchlist",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(
                1,
                0,
                0,
                HeaderHeight + (RowCount * RowHeight) + 4
            ),
            Visible = Watchlist.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Box,
            })
        )

        New("UIStroke", {
            Color = "OutlineColor",
            Transparency = 0.15,
            Parent = Box,
        })

        local Header = New("Frame", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0.22,
            Size = UDim2.new(1, 0, 0, HeaderHeight),
            Parent = Box,
        })

        local function MakeHeader(text, position, size, align)

            return New("TextLabel", {
                BackgroundTransparency = 1,
                Position = position,
                Size = size,
                Text = text,
                TextSize =
                    AutoJoinLayout
                    and 10
                    or 12,
                TextTransparency = 0.35,
                TextXAlignment = align or Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = Header,
            })
        end

        if AutoJoinLayout then

            MakeHeader(
                "PET",
                UDim2.fromOffset(10, 0),
                UDim2.new(0.32, -10, 1, 0)
            )

            MakeHeader(
                "SIZE",
                UDim2.fromScale(0.32, 0),
                UDim2.new(0.15, 0, 1, 0)
            )

            MakeHeader(
                "VARIANT",
                UDim2.fromScale(0.47, 0),
                UDim2.new(0.21, 0, 1, 0)
            )

            MakeHeader(
                "RARITY",
                UDim2.fromScale(0.68, 0),
                UDim2.new(0.16, 0, 1, 0)
            )

            MakeHeader(
                "PRIORITY",
                UDim2.fromScale(0.84, 0),
                UDim2.new(0.16, -8, 1, 0),
                Enum.TextXAlignment.Center
            )

        else

            MakeHeader(
                "Pet",
                UDim2.fromOffset(10, 0),
                UDim2.new(0.32, -10, 1, 0)
            )

            MakeHeader(
                "Value",
                UDim2.fromScale(0.32, 0),
                UDim2.new(0.16, 0, 1, 0)
            )

            MakeHeader(
                "Size",
                UDim2.fromScale(0.48, 0),
                UDim2.new(0.18, 0, 1, 0)
            )

            MakeHeader(
                "Variant",
                UDim2.fromScale(0.66, 0),
                UDim2.new(0.18, 0, 1, 0)
            )

            MakeHeader(
                "Amt",
                UDim2.fromScale(0.84, 0),
                UDim2.new(0.08, 0, 1, 0),
                Enum.TextXAlignment.Center
            )

            MakeHeader(
                "Pri",
                UDim2.fromScale(0.92, 0),
                UDim2.new(0.08, -8, 1, 0),
                Enum.TextXAlignment.Center
            )
        end

        local RowsHolder = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, HeaderHeight + 2),
            Size = UDim2.new(1, 0, 1, -HeaderHeight - 2),
            Parent = Box,
        })

        local function SetText(label, value)

            label.Text =
                tostring(value or "")
        end

        local function ApplyRowVisual(row)

            local hasData =
                type(row.Data) == "table"

            local selected =
                row.Index == Watchlist.SelectedIndex
                and hasData == true

            row.Button.Active =
                hasData

            row.Button.BackgroundTransparency =
                selected and 0.14 or 1

            row.Marker.BackgroundTransparency =
                selected and 0 or 1

            row.Pet.TextTransparency =
                hasData and (selected and 0 or 0.14) or 0.78

            row.Value.TextTransparency =
                hasData and (selected and 0 or 0.18) or 0.85

            row.Size.TextTransparency =
                hasData and (selected and 0.05 or 0.34) or 0.85

            row.Variant.TextTransparency =
                hasData and (selected and 0.05 or 0.34) or 0.85

            row.Amount.TextTransparency =
                hasData and (selected and 0.05 or 0.34) or 0.85

            row.Priority.TextTransparency =
                hasData and (selected and 0.05 or 0.34) or 0.85
        end

        local function MakeCell(parent, position, size, align)

            return New("TextLabel", {
                BackgroundTransparency = 1,
                Position = position,
                Size = size,
                Text = "",
                TextSize = 12,
                TextXAlignment = align or Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = parent,
            })
        end

        for rowIndex = 1, RowCount do

            local RowButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Position = UDim2.new(
                    0,
                    0,
                    0,
                    (rowIndex - 1) * RowHeight
                ),
                Size = UDim2.new(1, 0, 0, RowHeight),
                Text = "",
                Parent = RowsHolder,
            })

            local Marker = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(3, 5),
                Size = UDim2.new(0, 3, 1, -10),
                Parent = RowButton,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = Marker,
                })
            )

            local row = {
                Index = rowIndex,
                Button = RowButton,
                Marker = Marker,

                Pet = MakeCell(
                    RowButton,
                    UDim2.fromOffset(10, 0),
                    UDim2.new(0.32, -10, 1, 0)
                ),

                Value = MakeCell(
                    RowButton,
                    UDim2.fromScale(0.32, 0),
                    AutoJoinLayout
                    and UDim2.new(0.15, 0, 1, 0)
                    or UDim2.new(0.16, 0, 1, 0)
                ),

                Size = MakeCell(
                    RowButton,
                    AutoJoinLayout
                    and UDim2.fromScale(0.47, 0)
                    or UDim2.fromScale(0.48, 0),

                    AutoJoinLayout
                    and UDim2.new(0.21, 0, 1, 0)
                    or UDim2.new(0.18, 0, 1, 0)
                ),

                Variant = MakeCell(
                    RowButton,
                    AutoJoinLayout
                    and UDim2.fromScale(0.68, 0)
                    or UDim2.fromScale(0.66, 0),

                    AutoJoinLayout
                    and UDim2.new(0.16, 0, 1, 0)
                    or UDim2.new(0.18, 0, 1, 0)
                ),

                Amount = MakeCell(
                    RowButton,
                    UDim2.fromScale(0.84, 0),

                    AutoJoinLayout
                    and UDim2.new(0.16, -8, 1, 0)
                    or UDim2.new(0.08, 0, 1, 0),

                    Enum.TextXAlignment.Center
                ),

                Priority = MakeCell(
                    RowButton,
                    UDim2.fromScale(0.92, 0),
                    UDim2.new(0.08, -8, 1, 0),
                    Enum.TextXAlignment.Center
                ),

                Data = nil,
            }

            row.Priority.Visible =
                AutoJoinLayout ~= true

            if AutoJoinLayout ~= true then

                row.Value.TextColor3 =
                    Library.Scheme.AccentColor

                Library.Registry[row.Value].TextColor3 =
                    "AccentColor"
            end

            RowButton.MouseEnter:Connect(function()

                if row.Data == nil then
                    return
                end

                if row.Index ~= Watchlist.SelectedIndex then
                    RowButton.BackgroundTransparency = 0.72
                end
            end)

            RowButton.MouseLeave:Connect(function()

                ApplyRowVisual(
                    row
                )
            end)

            RowButton.MouseButton1Click:Connect(function()

                if row.Data == nil then
                    return
                end

                Watchlist:SetSelected(
                    rowIndex
                )

                if typeof(Callback) == "function" then

                    Library:SafeCallback(
                        Callback,
                        rowIndex,
                        row.Data
                    )
                end
            end)

            table.insert(
                Watchlist.Rows,
                row
            )

            ApplyRowVisual(
                row
            )
        end

        function Watchlist:SetRows(rows)

            Watchlist.RowData =
                rows
                or {}

            for index, row in ipairs(Watchlist.Rows) do

                local data =
                    Watchlist.RowData[index]

                row.Data =
                    data

                if type(data) == "table" then

                    if AutoJoinLayout then

                        SetText(
                            row.Pet,
                            data.Pet
                        )

                        SetText(
                            row.Value,
                            data.Size
                        )

                        SetText(
                            row.Size,
                            data.Variant
                        )

                        SetText(
                            row.Variant,
                            data.Rarity
                        )

                        SetText(
                            row.Amount,
                            data.Priority
                        )

                        SetText(
                            row.Priority,
                            ""
                        )

                    else

                        SetText(row.Pet, data.Pet)
                        SetText(row.Value, data.Value)
                        SetText(row.Size, data.Size)
                        SetText(row.Variant, data.Variant)
                        SetText(row.Amount, data.Amount)
                        SetText(row.Priority, data.Priority)
                    end

                else

                    SetText(row.Pet, "")
                    SetText(row.Value, "")
                    SetText(row.Size, "")
                    SetText(row.Variant, "")
                    SetText(row.Amount, "")
                    SetText(row.Priority, "")
                end

                ApplyRowVisual(
                    row
                )
            end

            if #Watchlist.RowData <= 0 then

                Watchlist.SelectedIndex =
                    nil
            end
        end

        function Watchlist:SetSelected(index)

            Watchlist.SelectedIndex =
                tonumber(index)

            for _, row in ipairs(Watchlist.Rows) do

                ApplyRowVisual(
                    row
                )
            end
        end

        function Watchlist:GetSelectedData()

            local index =
                tonumber(Watchlist.SelectedIndex)

            if not index then
                return nil
            end

            return Watchlist.RowData[index]
        end

        function Watchlist:SetVisible(visible)

            Watchlist.Visible =
                visible == true

            Holder.Visible =
                Watchlist.Visible

            Groupbox:Resize()
        end

        Watchlist.Holder =
            Holder

        table.insert(
            Groupbox.Elements,
            Watchlist
        )

        Options[Idx] =
            Watchlist

        Groupbox:Resize()

        return Watchlist
    end

    function Funcs:AddCheckbox(Idx, Info)
        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,
            Addons = {},

            Variant = "Checkbox",
            Type = "Toggle",
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(26, 0),
            Size = UDim2.new(1, -26, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Checkbox = New("Frame", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Button,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Checkbox,
            })
        )

        local CheckboxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Checkbox,
        })

        local CheckImage = New("ImageLabel", {
            Image = CheckIcon and CheckIcon.Url or "",
            ImageColor3 = "FontColor",
            ImageRectOffset = CheckIcon and CheckIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = CheckIcon and CheckIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 1,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = Checkbox,
        })

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            CheckboxStroke.Transparency = Toggle.Disabled and 0.5 or 0

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                CheckImage.ImageTransparency = Toggle.Value and 0.8 or 1

                Checkbox.BackgroundColor3 = Library.Scheme.BackgroundColor
                Library.Registry[Checkbox].BackgroundColor3 = "BackgroundColor"

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.10,
            }):Play()
            TweenService:Create(CheckImage, Library.TweenInfo, {
                ImageTransparency = Toggle.Value and 0 or 1,
            }):Play()

            Checkbox.BackgroundColor3 = Library.Scheme.MainColor
            Library.Registry[Checkbox].BackgroundColor3 = "MainColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:SetValue(Value)
            if Toggle.Disabled then
                return
            end

            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            Library:UpdateDependencyBoxes()
            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon:Update()
                end
            end

            Button.Active = not Toggle.Disabled
            Toggle:Display()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end)

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        return Toggle
    end

    function Funcs:AddToggle(Idx, Info)
        if Library.ForceCheckbox then
            return Funcs.AddCheckbox(self, Idx, Info)
        end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,
            Addons = {},

            Variant = "Switch",
            Type = "Toggle",
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Switch = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromOffset(32, 18),
            Parent = Button,
        })

        local SwitchScale = New("UIScale", {
            Scale = 1,
            Parent = Switch,
        })

        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Switch,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = Switch,
        })
        local SwitchStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Switch,
        })

        local Ball = New("Frame", {
            BackgroundColor3 = "FontColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Switch,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Ball,
        })

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            local Offset = Toggle.Value and 1 or 0

            Switch.BackgroundTransparency = Toggle.Disabled and 0.75 or 0
            SwitchStroke.Transparency = Toggle.Disabled and 0.75 or 0

            Switch.BackgroundColor3 = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.MainColor
            SwitchStroke.Color = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.OutlineColor

            Library.Registry[Switch].BackgroundColor3 = Toggle.Value and "AccentColor" or "MainColor"
            Library.Registry[SwitchStroke].Color = Toggle.Value and "AccentColor" or "OutlineColor"

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                Ball.AnchorPoint = Vector2.new(Offset, 0)
                Ball.Position = UDim2.fromScale(Offset, 0)

                Ball.BackgroundColor3 = Library:GetDarkerColor(Library.Scheme.FontColor)
                Library.Registry[Ball].BackgroundColor3 = function()
                    return Library:GetDarkerColor(Library.Scheme.FontColor)
                end

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.10,
            }):Play()
            TweenService:Create(Ball, Library.TweenInfo, {
                AnchorPoint = Vector2.new(Offset, 0),
                Position = UDim2.fromScale(Offset, 0),
            }):Play()

            Ball.BackgroundColor3 = Library.Scheme.FontColor
            Library.Registry[Ball].BackgroundColor3 = "FontColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:SetValue(Value)
            if Toggle.Disabled then
                return
            end

            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            Library:UpdateDependencyBoxes()
            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon:Update()
                end
            end

            Button.Active = not Toggle.Disabled
            Toggle:Display()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        Button.InputBegan:Connect(function(Input)
            if Toggle.Disabled
            or not IsClickInput(Input) then
                return
            end

            TweenService:Create(
                SwitchScale,
                Library.TweenInfo,
                {
                    Scale = 0.92,
                }
            ):Play()
        end)

        Button.InputEnded:Connect(function(Input)
            if not IsMouseInput(Input) then
                return
            end

            TweenService:Create(
                SwitchScale,
                Library.TweenInfo,
                {
                    Scale = 1,
                }
            ):Play()
        end)

        Button.MouseLeave:Connect(function()
            TweenService:Create(
                SwitchScale,
                Library.TweenInfo,
                {
                    Scale = 1,
                }
            ):Play()
        end)

        Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end)

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        return Toggle
    end

    function Funcs:AddInput(Idx, Info)
        if typeof(Info) == "table" and (typeof(Info.VerifyValue) == "function" and Info.Finished ~= true) then
            Info.Finished = true
        end

        Info = Library:Validate(Info, Templates.Input)

        local Groupbox = self
        local Container = Groupbox.Container

        local Input = {
            Text = Info.Text,
            Value = Info.Default,

            Finished = Info.Finished,
            Numeric = Info.Numeric,
            ClearTextOnFocus = Info.ClearTextOnFocus,
            ClearTextOnBlur = Info.ClearTextOnBlur,
            Placeholder = Info.Placeholder,
            AllowEmpty = Info.AllowEmpty,
            EmptyReset = Info.EmptyReset,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,
            VerifyValue = Info.VerifyValue,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Input",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 39),
            Visible = Input.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Input.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        local Box = New("TextBox", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus,
            PlaceholderText = Input.Placeholder,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = Input.Value,
            TextEditable = not Input.Disabled,
            TextScaled = false,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local BoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Box,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Box,
            })
        )

        function Input:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Input.Disabled and 0.8 or 0
            Box.TextTransparency = Input.Disabled and 0.8 or 0
        end

        function Input:OnChanged(Func)
            Input.Changed = Func
        end

        function Input:SetValue(Text)
            if not Input.AllowEmpty and Trim(Text) == "" then
                Text = Input.EmptyReset
            end

            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength)
            end

            if Input.Numeric then
                if #tostring(Text) > 0 and not tonumber(Text) then
                    Text = Input.Value
                end
            end

            if typeof(Info.VerifyValue) == "function" and (Text ~= Input.EmptyReset and Info.VerifyValue(Text) ~= true) then
                Text = Input.EmptyReset
            end

            Input.Value = Text
            Box.Text = Text

            if not Input.Disabled then
                Library:SafeCallback(Input.Callback, Input.Value)
                Library:SafeCallback(Input.Changed, Input.Value)
            end
        end

        function Input:SetDisabled(Disabled: boolean)
            Input.Disabled = Disabled

            if Input.TooltipTable then
                Input.TooltipTable.Disabled = Input.Disabled
            end

            Box.ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus
            Box.TextEditable = not Input.Disabled
            Input:UpdateColors()
        end

        function Input:SetVisible(Visible: boolean)
            Input.Visible = Visible

            Holder.Visible = Input.Visible
            Groupbox:Resize()
        end

        function Input:SetText(Text: string)
            Input.Text = Text
            Label.Text = Text
        end

        Box.Focused:Connect(function()

            if Input.Disabled then
                return
            end

            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
                Thickness = 1.5,
            }):Play()

            TweenService:Create(Box, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(
                    Library.Scheme.MainColor,
                    3
                ),
            }):Play()
        end)

        Box.FocusLost:Connect(function()

            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
                Thickness = 1,
            }):Play()

            TweenService:Create(Box, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end)
					
        if Input.Finished then
            Box.FocusLost:Connect(function(Enter)
                if not Enter then
                    if Input.ClearTextOnBlur then
                        Box.Text = Input.Value
                    end

                    return
                end

                Input:SetValue(Box.Text)
            end)
        else
            Box:GetPropertyChangedSignal("Text"):Connect(function()
                if Box.Text == Input.Value then return end
                
                Input:SetValue(Box.Text)
            end)
        end

        if typeof(Input.Tooltip) == "string" or typeof(Input.DisabledTooltip) == "string" then
            Input.TooltipTable = Library:AddTooltip(Input.Tooltip, Input.DisabledTooltip, Box)
            Input.TooltipTable.Disabled = Input.Disabled
        end

        Groupbox:Resize()

        Input.Holder = Holder
        table.insert(Groupbox.Elements, Input)

        Input.Default = Input.Value
        if typeof(Info.VerifyValue) == "function" and (Input.Default ~= Input.EmptyReset and Info.VerifyValue(Input.Default) ~= true) then
            Input:SetValue(Input.EmptyReset)
            Input.Default = Input.EmptyReset
        end
        
        Options[Idx] = Input

        return Input
    end

    function Funcs:AddSlider(Idx, Info)
        Info = Library:Validate(Info, Templates.Slider)

        local Groupbox = self
        local Container = Groupbox.Container

        local Slider = {
            Text = Info.Text,
            Value = Info.Default,

            Min = Info.Min,
            Max = Info.Max,

            Prefix = Info.Prefix,
            Suffix = Info.Suffix,
            Compact = Info.Compact,
            Rounding = Info.Rounding,
            HideMax = Info.HideMax,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Slider",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Compact and 15 or 33),
            Visible = Slider.Visible,
            Parent = Container,
        })

        local SliderLabel
        if not Info.Compact then
            SliderLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Text = Slider.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
        end

        local Bar = New("TextButton", {
            Active = not Slider.Disabled,
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 15),
            Text = "",
            Parent = Holder,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Bar,
        })

        local DisplayLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            ZIndex = 2,
            Parent = Bar,
        })
        New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = "DarkColor",
            LineJoinMode = Enum.LineJoinMode.Miter,
            Parent = DisplayLabel,
        })

        local Fill = New("Frame", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromScale(0.5, 1),
            Parent = Bar,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Bar,
            })
        )

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Fill,
            })
        )

        function Slider:UpdateColors()
            if Library.Unloaded then
                return
            end

            if SliderLabel then
                SliderLabel.TextTransparency = Slider.Disabled and 0.8 or 0
            end
            DisplayLabel.TextTransparency = Slider.Disabled and 0.8 or 0

            Fill.BackgroundColor3 = Slider.Disabled and Library.Scheme.OutlineColor or Library.Scheme.AccentColor
            Library.Registry[Fill].BackgroundColor3 = Slider.Disabled and "OutlineColor" or "AccentColor"
        end

        function Slider:Display()
            if Library.Unloaded then
                return
            end

            local CustomDisplayText = nil
            if Info.FormatDisplayValue then
                CustomDisplayText = Info.FormatDisplayValue(Slider, Slider.Value)
            end

            if CustomDisplayText then
                DisplayLabel.Text = tostring(CustomDisplayText)
            else
                if Info.Compact then
                    DisplayLabel.Text =
                        string.format("%s: %s%s%s", Slider.Text, Slider.Prefix, Slider.Value, Slider.Suffix)
                elseif Info.HideMax then
                    DisplayLabel.Text = string.format("%s%s%s", Slider.Prefix, Slider.Value, Slider.Suffix)
                else
                    DisplayLabel.Text = string.format(
                        "%s%s%s/%s%s%s",
                        Slider.Prefix,
                        Slider.Value,
                        Slider.Suffix,
                        Slider.Prefix,
                        Slider.Max,
                        Slider.Suffix
                    )
                end
            end

            local X = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
            Fill.Size = UDim2.fromScale(X, 1)
        end

        function Slider:OnChanged(Func)
            Slider.Changed = Func
        end

        function Slider:SetMax(Value)
            assert(Value > Slider.Min, "Max value cannot be less than the current min value.")

            Slider:SetValue(math.clamp(Slider.Value, Slider.Min, Value))
            Slider.Max = Value
            Slider:Display()
        end

        function Slider:SetMin(Value)
            assert(Value < Slider.Max, "Min value cannot be greater than the current max value.")

            Slider:SetValue(math.clamp(Slider.Value, Value, Slider.Max))
            Slider.Min = Value
            Slider:Display()
        end

        function Slider:SetValue(Str)
            if Slider.Disabled then
                return
            end

            local Num = tonumber(Str)
            if not Num or Num == Slider.Value then
                return
            end

            Num = math.clamp(Num, Slider.Min, Slider.Max)

            Slider.Value = Num
            Slider:Display()

            Library:SafeCallback(Slider.Callback, Slider.Value)
            Library:SafeCallback(Slider.Changed, Slider.Value)
        end

        function Slider:SetDisabled(Disabled: boolean)
            Slider.Disabled = Disabled

            if Slider.TooltipTable then
                Slider.TooltipTable.Disabled = Slider.Disabled
            end

            Bar.Active = not Slider.Disabled
            Slider:UpdateColors()
        end

        function Slider:SetVisible(Visible: boolean)
            Slider.Visible = Visible

            Holder.Visible = Slider.Visible
            Groupbox:Resize()
        end

        function Slider:SetText(Text: string)
            Slider.Text = Text
            if SliderLabel then
                SliderLabel.Text = Text
                return
            end
            Slider:Display()
        end

        function Slider:SetPrefix(Prefix: string)
            Slider.Prefix = Prefix
            Slider:Display()
        end

        function Slider:SetSuffix(Suffix: string)
            Slider.Suffix = Suffix
            Slider:Display()
        end

        Bar.InputBegan:Connect(function(Input: InputObject)
            if not IsClickInput(Input) or Slider.Disabled then
                return
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = false
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = false
            end

            while IsDragInput(Input) do
                local Location = Mouse.X
                local Scale = math.clamp((Location - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)

                local OldValue = Slider.Value
                Slider.Value = Round(Slider.Min + ((Slider.Max - Slider.Min) * Scale), Slider.Rounding)

                Slider:Display()
                if Slider.Value ~= OldValue then
                    Library:SafeCallback(Slider.Callback, Slider.Value)
                    Library:SafeCallback(Slider.Changed, Slider.Value)
                end

                RunService.RenderStepped:Wait()
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = true
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = true
            end
        end)

        if typeof(Slider.Tooltip) == "string" or typeof(Slider.DisabledTooltip) == "string" then
            Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Bar)
            Slider.TooltipTable.Disabled = Slider.Disabled
        end

        Slider:UpdateColors()
        Slider:Display()
        Groupbox:Resize()

        Slider.Holder = Holder
        table.insert(Groupbox.Elements, Slider)

        Slider.Default = Slider.Value

        Options[Idx] = Slider

        return Slider
    end

        function Funcs:AddThemePicker(Idx, Info)

        Info =
            Library:Validate(
                Info,
                {
                    Text = "Theme",
                    Values = {},
                    Default = nil,

                    Tooltip = nil,
                    DisabledTooltip = nil,

                    Callback = function()
                    end,

                    Changed = function()
                    end,

                    Disabled = false,
                    Visible = true,

                    Animate = true,
                    PopupTransparency = 0.08,
                }
            )

        local Groupbox =
            self

        local Container =
            Groupbox.Container

        local ThemePicker = {
            Text =
                tostring(
                    Info.Text
                    or "Theme"
                ),

            Values =
                Info.Values,

            Value =
                nil,

            Tooltip =
                Info.Tooltip,

            DisabledTooltip =
                Info.DisabledTooltip,

            TooltipTable =
                nil,

            Callback =
                Info.Callback,

            Changed =
                Info.Changed,

            Disabled =
                Info.Disabled == true,

            Visible =
                Info.Visible ~= false,

            Type =
                "Dropdown",

            SpecialType =
                "ThemePicker",
        }

        local requestedDefault =
            tostring(
                Info.Default
                or ""
            )

        if table.find(
            ThemePicker.Values,
            requestedDefault
        ) then

            ThemePicker.Value =
                requestedDefault

        else

            ThemePicker.Value =
                ThemePicker.Values[1]
        end

        local Holder =
            New(
                "Frame",
                {
                    BackgroundTransparency = 1,

                    Size =
                        UDim2.new(
                            1,
                            0,
                            0,
                            39
                        ),

                    Visible =
                        ThemePicker.Visible,

                    Parent =
                        Container,
                }
            )

        local ControlZIndex =
            (
                tonumber(
                    Holder.ZIndex
                )
                or 1
            )
            + 1

        local ForegroundZIndex =
            ControlZIndex
            + 1

        local Label =
            New(
                "TextLabel",
                {
                    BackgroundTransparency = 1,

                    Size =
                        UDim2.new(
                            1,
                            0,
                            0,
                            14
                        ),

                    Text =
                        ThemePicker.Text,

                    TextSize =
                        14,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    ZIndex =
                        ControlZIndex,

                    Parent =
                        Holder,
                }
            )

        local DisplayContainer =
            New(
                "TextButton",
                {
                    Active =
                        not ThemePicker.Disabled,

                    AnchorPoint =
                        Vector2.new(
                            0,
                            1
                        ),

                    BackgroundColor3 =
                        "MainColor",

                    Position =
                        UDim2.fromScale(
                            0,
                            1
                        ),

                    Size =
                        UDim2.new(
                            1,
                            0,
                            0,
                            24
                        ),

                    Text =
                        "",

                    ZIndex =
                        ControlZIndex,

                    Parent =
                        Holder,
                }
            )

        local DisplayStroke =
            New(
                "UIStroke",
                {
                    Color =
                        "OutlineColor",

                    Thickness =
                        1,

                    Parent =
                        DisplayContainer,
                }
            )

        table.insert(
            Library.Corners,
            New(
                "UICorner",
                {
                    CornerRadius =
                        UDim.new(
                            0,
                            Library.CornerRadius / 2
                        ),

                    Parent =
                        DisplayContainer,
                }
            )
        )

        local DisplaySwatch =
            New(
                "Frame",
                {
                    AnchorPoint =
                        Vector2.new(
                            0,
                            0.5
                        ),

                    BackgroundColor3 =
                        Library.Scheme.AccentColor,

                    Position =
                        UDim2.fromOffset(
                            8,
                            12
                        ),

                    Size =
                        UDim2.fromOffset(
                            11,
                            11
                        ),

                    ZIndex =
                        ForegroundZIndex,

                    Parent =
                        DisplayContainer,
                }
            )

        table.insert(
            Library.Corners,
            New(
                "UICorner",
                {
                    CornerRadius =
                        UDim.new(
                            1,
                            0
                        ),

                    Parent =
                        DisplaySwatch,
                }
            )
        )

        local DisplaySwatchStroke =
            New(
                "UIStroke",
                {
                    Color =
                        "FontColor",

                    Transparency =
                        0.72,

                    Thickness =
                        1,

                    Parent =
                        DisplaySwatch,
                }
            )

        local ValueLabel =
            New(
                "TextLabel",
                {
                    BackgroundTransparency = 1,

                    Position =
                        UDim2.fromOffset(
                            27,
                            0
                        ),

                    Size =
                        UDim2.new(
                            1,
                            -51,
                            1,
                            0
                        ),

                    Text =
                        "",

                    TextSize =
                        14,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    TextTruncate =
                        Enum.TextTruncate.AtEnd,

                    ZIndex =
                        ForegroundZIndex,

                    Parent =
                        DisplayContainer,
                }
            )

        local ArrowImage =
            New(
                "ImageLabel",
                {
                    AnchorPoint =
                        Vector2.new(
                            1,
                            0.5
                        ),

                    BackgroundTransparency = 1,

                    Image =
                        ArrowIcon
                        and ArrowIcon.Url
                        or "",

                    ImageColor3 =
                        "FontColor",

                    ImageRectOffset =
                        ArrowIcon
                        and ArrowIcon.ImageRectOffset
                        or Vector2.zero,

                    ImageRectSize =
                        ArrowIcon
                        and ArrowIcon.ImageRectSize
                        or Vector2.zero,

                    ImageTransparency =
                        0.45,

                    Position =
                        UDim2.new(
                            1,
                            -6,
                            0.5,
                            0
                        ),

                    Size =
                        UDim2.fromOffset(
                            16,
                            16
                        ),

                    ZIndex =
                        ForegroundZIndex,

                    Parent =
                        DisplayContainer,
                }
            )

        local function GetMenuHeight()

            local itemCount =
                math.max(
                    #ThemePicker.Values,
                    1
                )

            local rowCount =
                math.ceil(
                    itemCount / 2
                )

            return 16
                + rowCount * 30
                + math.max(
                    rowCount - 1,
                    0
                ) * 6
        end

        local function GetMenuOffset()

            local dpiScale =
                math.max(
                    tonumber(
                        Library.DPIScale
                    )
                    or 1,
                    0.01
                )

            local popupHeight =
                GetMenuHeight()
                * dpiScale

            local displayPosition =
                DisplayContainer.AbsolutePosition

            local displaySize =
                DisplayContainer.AbsoluteSize

            local belowPosition =
                displayPosition.Y
                + displaySize.Y
                + 4

            local camera =
                workspace.CurrentCamera

            local viewportHeight =
                camera
                and camera.ViewportSize.Y
                or 720

            local canOpenAbove =
                displayPosition.Y
                - popupHeight
                - 4
                >= 8

            local shouldOpenAbove =
                belowPosition
                + popupHeight
                > viewportHeight
                - 8

            if shouldOpenAbove
            and canOpenAbove then

                return {
                    0.5,
                    -popupHeight - 4,
                }
            end

            return {
                0.5,
                displaySize.Y + 4,
            }
        end

        local MenuContent =
            nil

        local MenuTween =
            nil

        local ContentTween =
            nil

        local PopupTransparency =
            math.clamp(
                tonumber(
                    Info.PopupTransparency
                )
                or 0.08,
                0,
                0.15
            )

        local MenuTable

        MenuTable =
            Library:AddContextMenu(
                DisplayContainer,

                function()

                    local dpiScale =
                        math.max(
                            tonumber(
                                Library.DPIScale
                            )
                            or 1,
                            0.01
                        )

                    return UDim2.fromOffset(
                        (
                            DisplayContainer.AbsoluteSize.X
                            / dpiScale
                        )
                        + 1,
                        GetMenuHeight()
                    )
                end,

                GetMenuOffset,

                nil,

                function(active)

                    if MenuTween then

                        MenuTween:Cancel()

                        MenuTween =
                            nil
                    end

                    if ContentTween then

                        ContentTween:Cancel()

                        ContentTween =
                            nil
                    end

                    ArrowImage.Rotation =
                        active
                        and 180
                        or 0

                    ArrowImage.ImageTransparency =
                        active
                        and 0
                        or 0.45

                    DisplayStroke.Color =
                        active
                        and Library.Scheme.AccentColor
                        or Library.Scheme.OutlineColor

                    Library.Registry[
                        DisplayStroke
                    ].Color =
                        active
                        and "AccentColor"
                        or "OutlineColor"

                    if not MenuContent then
                        return
                    end

                    if active then

                        if Info.Animate ~= false then

                            MenuTable.Menu.BackgroundTransparency =
                                1

                            MenuContent.GroupTransparency =
                                1

                            MenuContent.Position =
                                UDim2.fromOffset(
                                    0,
                                    6
                                )

                            MenuTween =
                                TweenService:Create(
                                    MenuTable.Menu,
                                    TweenInfo.new(
                                        0.12,
                                        Enum.EasingStyle.Quad,
                                        Enum.EasingDirection.Out
                                    ),
                                    {
                                        BackgroundTransparency =
                                            PopupTransparency,
                                    }
                                )

                            ContentTween =
                                TweenService:Create(
                                    MenuContent,
                                    TweenInfo.new(
                                        0.12,
                                        Enum.EasingStyle.Quad,
                                        Enum.EasingDirection.Out
                                    ),
                                    {
                                        GroupTransparency =
                                            0,

                                        Position =
                                            UDim2.fromOffset(
                                                0,
                                                0
                                            ),
                                    }
                                )

                            MenuTween:Play()
                            ContentTween:Play()

                        else

                            MenuTable.Menu.BackgroundTransparency =
                                PopupTransparency

                            MenuContent.GroupTransparency =
                                0

                            MenuContent.Position =
                                UDim2.fromOffset(
                                    0,
                                    0
                                )
                        end

                    else

                        MenuTable.Menu.BackgroundTransparency =
                            PopupTransparency

                        MenuContent.GroupTransparency =
                            0

                        MenuContent.Position =
                            UDim2.fromOffset(
                                0,
                                0
                            )
                    end
                end
            )

        ThemePicker.Menu =
            MenuTable

        MenuTable.Menu.Active =
            true

        MenuTable.Menu.ClipsDescendants =
            true

        Library.SurfaceRegistry[
            MenuTable.Menu
        ] =
            nil

        MenuTable.Menu.BackgroundTransparency =
            PopupTransparency

        MenuContent =
            New(
                "CanvasGroup",
                {
                    Active =
                        true,

                    BackgroundTransparency =
                        1,

                    GroupTransparency =
                        0,

                    Size =
                        UDim2.fromScale(
                            1,
                            1
                        ),

                    Parent =
                        MenuTable.Menu,
                }
            )

        New(
            "UIPadding",
            {
                PaddingBottom =
                    UDim.new(
                        0,
                        8
                    ),

                PaddingLeft =
                    UDim.new(
                        0,
                        8
                    ),

                PaddingRight =
                    UDim.new(
                        0,
                        8
                    ),

                PaddingTop =
                    UDim.new(
                        0,
                        8
                    ),

                Parent =
                    MenuContent,
            }
        )

        New(
            "UIGridLayout",
            {
                CellPadding =
                    UDim2.fromOffset(
                        6,
                        6
                    ),

                CellSize =
                    UDim2.new(
                        0.5,
                        -11,
                        0,
                        30
                    ),

                FillDirection =
                    Enum.FillDirection.Horizontal,

                FillDirectionMaxCells =
                    2,

                HorizontalAlignment =
                    Enum.HorizontalAlignment.Left,

                SortOrder =
                    Enum.SortOrder.LayoutOrder,

                VerticalAlignment =
                    Enum.VerticalAlignment.Top,

                Parent =
                    MenuContent,
            }
        )

        local Buttons = {}

        local function UpdateButton(
            value,
            data
        )

            local selected =
                ThemePicker.Value
                == value

            local selectedBackground =
                function()

                    return Library:GetBetterColor(
                        Library.Scheme.MainColor,
                        5
                    )
                end

            data.Card.BackgroundColor3 =
                selected
                and selectedBackground()
                or Library.Scheme.MainColor

            Library.Registry[
                data.Card
            ].BackgroundColor3 =
                selected
                and selectedBackground
                or "MainColor"

            data.Stroke.Color =
                selected
                and Library.Scheme.AccentColor
                or Library.Scheme.OutlineColor

            Library.Registry[
                data.Stroke
            ].Color =
                selected
                and "AccentColor"
                or "OutlineColor"

            data.NameLabel.TextTransparency =
                ThemePicker.Disabled
                and 0.75
                or selected
                and 0
                or 0.16

            data.CheckLabel.Visible =
                selected

            data.Card.Active =
                not ThemePicker.Disabled
        end

        local function UpdateButtons()

            for value, data in pairs(
                Buttons
            ) do

                UpdateButton(
                    value,
                    data
                )
            end
        end

        local function BuildButtons()

            for _, data in pairs(
                Buttons
            ) do

                pcall(function()

                    data.Card:Destroy()
                end)
            end

            table.clear(
                Buttons
            )

            for index, value in ipairs(
                ThemePicker.Values
            ) do

                value =
                    tostring(
                        value
                    )

                local theme =
                    Library.Themes[
                        value
                    ]

                local accentColor =
                    type(theme) == "table"
                    and theme.AccentColor
                    or Library.Scheme.AccentColor

                local Card =
                    New(
                        "TextButton",
                        {
                            Active =
                                not ThemePicker.Disabled,

                            BackgroundColor3 =
                                "MainColor",

                            BackgroundTransparency =
                                0.02,

                            LayoutOrder =
                                index,

                            Text =
                                "",

                            Parent =
                                MenuContent,
                        }
                    )

                table.insert(
                    Library.Corners,
                    New(
                        "UICorner",
                        {
                            CornerRadius =
                                UDim.new(
                                    0,
                                    Library.CornerRadius / 2
                                ),

                            Parent =
                                Card,
                        }
                    )
                )

                local CardStroke =
                    New(
                        "UIStroke",
                        {
                            Color =
                                "OutlineColor",

                            Thickness =
                                1,

                            Parent =
                                Card,
                        }
                    )

                local Swatch =
                    New(
                        "Frame",
                        {
                            AnchorPoint =
                                Vector2.new(
                                    0,
                                    0.5
                                ),

                            BackgroundColor3 =
                                accentColor,

                            Position =
                                UDim2.new(
                                    0,
                                    8,
                                    0.5,
                                    0
                                ),

                            Size =
                                UDim2.fromOffset(
                                    10,
                                    10
                                ),

                            Parent =
                                Card,
                        }
                    )

                table.insert(
                    Library.Corners,
                    New(
                        "UICorner",
                        {
                            CornerRadius =
                                UDim.new(
                                    1,
                                    0
                                ),

                            Parent =
                                Swatch,
                        }
                    )
                )

                New(
                    "UIStroke",
                    {
                        Color =
                            "FontColor",

                        Transparency =
                            0.72,

                        Thickness =
                            1,

                        Parent =
                            Swatch,
                    }
                )

                local NameLabel =
                    New(
                        "TextLabel",
                        {
                            BackgroundTransparency =
                                1,

                            Position =
                                UDim2.fromOffset(
                                    25,
                                    0
                                ),

                            Size =
                                UDim2.new(
                                    1,
                                    -47,
                                    1,
                                    0
                                ),

                            Text =
                                value,

                            TextSize =
                                13,

                            TextTruncate =
                                Enum.TextTruncate.AtEnd,

                            TextXAlignment =
                                Enum.TextXAlignment.Left,

                            Parent =
                                Card,
                        }
                    )

                local CheckLabel =
                    New(
                        "TextLabel",
                        {
                            AnchorPoint =
                                Vector2.new(
                                    1,
                                    0
                                ),

                            BackgroundTransparency =
                                1,

                            Position =
                                UDim2.new(
                                    1,
                                    -7,
                                    0,
                                    0
                                ),

                            Size =
                                UDim2.fromOffset(
                                    14,
                                    30
                                ),

                            Text =
                                "✓",

                            TextColor3 =
                                "AccentColor",

                            TextSize =
                                14,

                            Visible =
                                false,

                            Parent =
                                Card,
                        }
                    )

                local buttonData = {
                    Card =
                        Card,

                    Stroke =
                        CardStroke,

                    NameLabel =
                        NameLabel,

                    CheckLabel =
                        CheckLabel,
                }

                Buttons[
                    value
                ] =
                    buttonData

                Card.MouseEnter:Connect(function()

                    if ThemePicker.Disabled
                    or ThemePicker.Value == value then

                        return
                    end

                    TweenService:Create(
                        Card,
                        Library.TweenInfo,
                        {
                            BackgroundColor3 =
                                Library:GetBetterColor(
                                    Library.Scheme.MainColor,
                                    3
                                ),
                        }
                    ):Play()
                end)

                Card.MouseLeave:Connect(function()

                    UpdateButton(
                        value,
                        buttonData
                    )
                end)

                Card.MouseButton1Click:Connect(function()

                    if ThemePicker.Disabled then
                        return
                    end

                    ThemePicker:SetValue(
                        value
                    )

                    MenuTable:Close()
                end)
            end

            UpdateButtons()
        end

        function ThemePicker:RecalculateListSize()

            MenuTable:SetSize(function()

                local dpiScale =
                    math.max(
                        tonumber(
                            Library.DPIScale
                        )
                        or 1,
                        0.01
                    )

                return UDim2.fromOffset(
                    (
                        DisplayContainer.AbsoluteSize.X
                        / dpiScale
                    )
                    + 1,
                    GetMenuHeight()
                )
            end)
        end

        function ThemePicker:Display()

            local theme =
                Library.Themes[
                    ThemePicker.Value
                ]

            ValueLabel.Text =
                tostring(
                    ThemePicker.Value
                    or "Select theme"
                )

            if type(theme) == "table"
            and typeof(theme.AccentColor) == "Color3" then

                DisplaySwatch.BackgroundColor3 =
                    theme.AccentColor

                DisplaySwatch.BackgroundTransparency =
                    0

            else

                DisplaySwatch.BackgroundColor3 =
                    Library.Scheme.AccentColor

                DisplaySwatch.BackgroundTransparency =
                    1
            end

            Label.TextTransparency =
                ThemePicker.Disabled
                and 0.75
                or 0

            ValueLabel.TextTransparency =
                ThemePicker.Disabled
                and 0.75
                or 0

            DisplaySwatchStroke.Transparency =
                ThemePicker.Disabled
                and 0.9
                or 0.72

            DisplayContainer.Active =
                not ThemePicker.Disabled

            ArrowImage.ImageTransparency =
                ThemePicker.Disabled
                and 0.8
                or MenuTable.Active
                and 0
                or 0.45
        end

        function ThemePicker:UpdateColors()

            ThemePicker:Display()

            UpdateButtons()
        end

        function ThemePicker:OnChanged(callback)

            ThemePicker.Changed =
                callback
        end

        function ThemePicker:SetValue(
            value,
            silent
        )

            if ThemePicker.Disabled then
                return false
            end

            value =
                tostring(
                    value
                    or ""
                )

            if not table.find(
                ThemePicker.Values,
                value
            ) then

                return false
            end

            local changed =
                ThemePicker.Value
                ~= value

            ThemePicker.Value =
                value

            ThemePicker:Display()

            UpdateButtons()

            if changed
            and silent ~= true then

                Library:UpdateDependencyBoxes()

                Library:SafeCallback(
                    ThemePicker.Callback,
                    ThemePicker.Value
                )

                Library:SafeCallback(
                    ThemePicker.Changed,
                    ThemePicker.Value
                )

                ThemePicker:Display()

                UpdateButtons()
            end

            return true
        end

        function ThemePicker:SetValues(values)

            ThemePicker.Values =
                type(values) == "table"
                and values
                or {}

            if not table.find(
                ThemePicker.Values,
                ThemePicker.Value
            ) then

                ThemePicker.Value =
                    ThemePicker.Values[1]
            end

            BuildButtons()

            ThemePicker:RecalculateListSize()

            ThemePicker:Display()
        end

        function ThemePicker:SetDisabled(disabled)

            ThemePicker.Disabled =
                disabled == true

            if ThemePicker.TooltipTable then

                ThemePicker.TooltipTable.Disabled =
                    ThemePicker.Disabled
            end

            if ThemePicker.Disabled then

                MenuTable:Close()
            end

            ThemePicker:Display()

            UpdateButtons()
        end

        function ThemePicker:SetVisible(visible)

            ThemePicker.Visible =
                visible ~= false

            Holder.Visible =
                ThemePicker.Visible

            if not ThemePicker.Visible then

                MenuTable:Close()
            end

            Groupbox:Resize()
        end

        function ThemePicker:SetText(text)

            ThemePicker.Text =
                tostring(
                    text
                    or ""
                )

            Label.Text =
                ThemePicker.Text
        end

        DisplayContainer.MouseButton1Click:Connect(function()

            if ThemePicker.Disabled then
                return
            end

            MenuTable:Toggle()
        end)

        if typeof(
            ThemePicker.Tooltip
        ) == "string"
        or typeof(
            ThemePicker.DisabledTooltip
        ) == "string" then

            ThemePicker.TooltipTable =
                Library:AddTooltip(
                    ThemePicker.Tooltip,
                    ThemePicker.DisabledTooltip,
                    DisplayContainer
                )

            ThemePicker.TooltipTable.Disabled =
                ThemePicker.Disabled
        end

        BuildButtons()

        ThemePicker:RecalculateListSize()

        ThemePicker:Display()

        Groupbox:Resize()

        ThemePicker.Holder =
            Holder

        ThemePicker.Default =
            ThemePicker.Value

        ThemePicker.DefaultValues =
            ThemePicker.Values

        table.insert(
            Groupbox.Elements,
            ThemePicker
        )

        Options[
            Idx
        ] =
            ThemePicker

        return ThemePicker
    end


    function Funcs:AddDropdown(Idx, Info)
        Info = Library:Validate(Info, Templates.Dropdown)

        local Groupbox = self
        local Container = Groupbox.Container

        if Info.SpecialType == "Player" then
            Info.Values = GetPlayers(Info.ExcludeLocalPlayer)
            Info.AllowNull = true
        elseif Info.SpecialType == "Team" then
            Info.Values = GetTeams()
            Info.AllowNull = true
        end

        local Dropdown = {
            Text = typeof(Info.Text) == "string" and Info.Text or nil,

            Value = Info.Multi and {} or nil,
            Values = Info.Values,
            DisabledValues = Info.DisabledValues,
            ValueImages = Info.ValueImages,
            ValueMetadata = Info.ValueMetadata,

            Multi = Info.Multi,
            Popout = Info.Popout,
            PopoutThreshold = Info.PopoutThreshold,
            PickerTitle = Info.PickerTitle,
            RichPicker = Info.RichPicker,
            MasterValue = Info.MasterValue,
            MasterText = Info.MasterText,
            Open = false,

            SpecialType = Info.SpecialType,
            ExcludeLocalPlayer = Info.ExcludeLocalPlayer,
            EnablePlayerImages = Info.EnablePlayerImages,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Dropdown",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Dropdown.Text and 39 or 21),
            Visible = Dropdown.Visible,
            Parent = Container,
        })

        local DropdownControlZIndex =
            (
                tonumber(
                    Holder.ZIndex
                )
                or 1
            )
            + 1

        local DropdownForegroundZIndex =
            DropdownControlZIndex
            + 1

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Dropdown.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = not not Info.Text,
            ZIndex = DropdownControlZIndex,
            Parent = Holder,
        })

        local DisplayContainer = New("TextButton", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = "",
            TextTransparency = 1,
            ZIndex = DropdownControlZIndex,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 4),
            Parent = DisplayContainer,
        })

        local DisplayStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = DisplayContainer,
        })

        if Library.CornerRadiusDropdown == true then
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = DisplayContainer,
                })
            )
        end

        local DisplayImage = New("ImageLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(-4, 3),
            Size = UDim2.fromOffset(16, 16),
            Image = "",
            ImageTransparency = 1,
            ZIndex = DropdownForegroundZIndex,
            Parent = DisplayContainer,
        })

        local DisplayButton = New("TextButton", {
            Active = not Dropdown.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Text = "---",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = DropdownForegroundZIndex,
            Parent = DisplayContainer,
        })

        -- Dropdowns cant currently use corner radius since the button is supposed to be connected with the menu
        -- This can be done properly without some random frames and overlaying textlabel over the button after Roblox adds UICorner with specific corner radiuses

        local ArrowImage = New("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Image = ArrowIcon and ArrowIcon.Url or "",
            ImageColor3 = "FontColor",
            ImageRectOffset = ArrowIcon and ArrowIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = ArrowIcon and ArrowIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 0.5,
            Position = UDim2.fromScale(1, 0.5),
            Size = UDim2.fromOffset(16, 16),
            ZIndex = DropdownForegroundZIndex,
            Parent = DisplayContainer,
        })

        local SearchBox
        if Info.Searchable then
            SearchBox = New("TextBox", {
                BackgroundTransparency = 1,
                PlaceholderText = "Search...",
                Position = UDim2.fromOffset(-8, 0),
                Size = UDim2.new(1, -12, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = false,
                Parent = DisplayButton,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                Parent = SearchBox,
            })
        end

        local GetValueImage = function(Value)
            if not Value then
                return nil
            end

            local ValueImage = nil
            if Dropdown.SpecialType == "Player" and Dropdown.EnablePlayerImages == true then
                if typeof(Value) == "Instance" and Value:IsA("Player") then
                    ValueImage = { Url = string.format("rbxthumb://type=AvatarHeadShot&id=%s&w=48&h=48", tostring(Value.UserId)) }
                end
            else
                if Dropdown.ValueImages and Dropdown.ValueImages[Value] then
                    ValueImage = Library:GetCustomIcon(Dropdown.ValueImages[Value])
                end
            end

            return ValueImage
        end

        local MenuTable = Library:AddContextMenu(
            DisplayContainer,
            function()
                return UDim2.fromOffset((DisplayContainer.AbsoluteSize.X / Library.DPIScale) + 1, 0)
            end,
            function()
                return { 0.5, DisplayContainer.AbsoluteSize.Y + 1.5 }
            end,
            2,
            function(Active: boolean)
                if Dropdown.SetOpenState then
                    Dropdown:SetOpenState(Active, true)
                end
            end,
            false
        )
        Dropdown.Menu = MenuTable
        MenuTable.Menu.ClipsDescendants = true
        MenuTable.Menu.ScrollBarThickness = 2
        MenuTable.List.Padding = UDim.new(0, 2)

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            PaddingTop = UDim.new(0, 4),
            Parent = MenuTable.Menu,
        })

        function Dropdown:SetOpenState(Active, Compact)
            Dropdown.Open = Active == true

            DisplayButton.TextTransparency = Dropdown.Disabled and 0.8
                or Dropdown.Open and Compact and SearchBox and 1
                or 0

            TweenService:Create(ArrowImage, Library.TweenInfo, {
                ImageTransparency = Dropdown.Disabled and 0.8 or Dropdown.Open and 0 or 0.5,
                Rotation = Dropdown.Open and 180 or 0,
            }):Play()

            TweenService:Create(DisplayContainer, Library.TweenInfo, {
                BackgroundColor3 = Dropdown.Open
                    and Library:GetBetterColor(Library.Scheme.MainColor, 3)
                    or Library.Scheme.MainColor,
            }):Play()

            TweenService:Create(DisplayStroke, Library.TweenInfo, {
                Color = Dropdown.Open and Library.Scheme.AccentColor or Library.Scheme.OutlineColor,
                Thickness = Dropdown.Open and 1.5 or 1,
                Transparency = 0,
            }):Play()

            if SearchBox then
                SearchBox.Text = ""
                SearchBox.Visible = Dropdown.Open and Compact == true
            end
        end

        function Dropdown:UsesPopout()
            if Info.Popout ~= nil then
                return Info.Popout == true
            end

            return Info.Multi == true
                or Info.Searchable == true
                or #Dropdown.Values > (tonumber(Info.PopoutThreshold) or 8)
        end

        DisplayContainer.MouseEnter:Connect(function()
            if Dropdown.Disabled
            or Dropdown.Open then
                return
            end

            TweenService:Create(
                DisplayContainer,
                Library.TweenInfo,
                {
                    BackgroundColor3 =
                        Library:GetBetterColor(
                            Library.Scheme.MainColor,
                            2
                        ),
                }
            ):Play()

            TweenService:Create(
                DisplayStroke,
                Library.TweenInfo,
                {
                    Color =
                        Library.Scheme.AccentColor,

                    Transparency = 0.45,
                }
            ):Play()
        end)

        DisplayContainer.MouseLeave:Connect(function()
            if Dropdown.Open then
                return
            end

            TweenService:Create(
                DisplayContainer,
                Library.TweenInfo,
                {
                    BackgroundColor3 =
                        Library.Scheme.MainColor,
                }
            ):Play()

            TweenService:Create(
                DisplayStroke,
                Library.TweenInfo,
                {
                    Color =
                        Library.Scheme.OutlineColor,

                    Transparency = 0,
                }
            ):Play()
        end)

        function Dropdown:RecalculateListSize(Count)
            local ItemCount = Count or GetTableSize(Dropdown.Values)
            local VisibleCount = math.clamp(ItemCount, 0, Info.MaxVisibleDropdownItems)
            local Y = VisibleCount > 0 and (VisibleCount * 28) + 6 or 0

            MenuTable:SetSize(function()
                return UDim2.fromOffset(DisplayContainer.AbsoluteSize.X / Library.DPIScale, Y)
            end)
        end

        function Dropdown:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Dropdown.Disabled and 0.8 or 0
            DisplayButton.TextTransparency = Dropdown.Disabled and 0.8
                or Dropdown.Open and MenuTable.Active and SearchBox and 1
                or 0
            DisplayImage.ImageTransparency = Dropdown.Disabled and 0.8 or 0
            ArrowImage.ImageTransparency = Dropdown.Disabled and 0.8 or Dropdown.Open and 0 or 0.5
        end

        function Dropdown:Display()
            if Library.Unloaded then
                return
            end

            local Str = ""
            local ValueImage = nil

            if Info.Multi then
                local SelectedValues = {}

                for _, Value in Dropdown.Values do
                    if Dropdown.Value[Value] then
                        if not ValueImage then
                            ValueImage = GetValueImage(Value)
                        end

                        table.insert(
                            SelectedValues,
                            Info.FormatDisplayValue
                                and tostring(Info.FormatDisplayValue(Value))
                                or tostring(Value)
                        )
                    end
                end

                if #SelectedValues > 2 then
                    Str = table.concat(SelectedValues, ", ", 1, 2)
                        .. " +"
                        .. tostring(#SelectedValues - 2)
                else
                    Str = table.concat(SelectedValues, ", ")
                end
            else
                ValueImage = GetValueImage(Dropdown.Value)
                Str = Dropdown.Value and tostring(Dropdown.Value) or ""

                if Str ~= "" and Info.FormatDisplayValue then
                    Str = tostring(Info.FormatDisplayValue(Dropdown.Value))
                end
            end

            DisplayButton.Text = Str == ""
                and (Info.Multi and "Select options" or "Select option")
                or Str
            
            if ValueImage then
                DisplayImage.Image = ValueImage.Url
                DisplayImage.ImageRectOffset = ValueImage.ImageRectOffset or Vector2.zero
                DisplayImage.ImageRectSize = ValueImage.ImageRectSize or Vector2.zero
                DisplayImage.ImageTransparency = 0
            else
                DisplayImage.Image = ""
                DisplayImage.ImageTransparency = 1
            end

            DisplayButton.Size = ValueImage and UDim2.new(1, -36, 0, 21) or UDim2.new(1, -20, 0, 21)
            DisplayButton.Position = ValueImage and UDim2.fromOffset(14, 0) or UDim2.fromOffset(0, 0)
            DisplayButton.TextTruncate = Enum.TextTruncate.AtEnd
        end

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func
        end

        function Dropdown:GetActiveValues()
            if Info.Multi then
                local Table = {}

                for Value, _ in Dropdown.Value do
                    table.insert(Table, Value)
                end

                return Table
            end

            return Dropdown.Value and 1 or 0
        end

        local Buttons = {}
        function Dropdown:BuildDropdownList()
            local Values = Dropdown.Values
            local DisabledValues = Dropdown.DisabledValues

            for Button, _ in Buttons do
                Button.Parent:Destroy()
            end
            table.clear(Buttons)

            local Count = 0
            for _, Value in Values do
                local FormattedValue = tostring(Info.FormatListValue and Info.FormatListValue(Value) or Value)

                if SearchBox
                and not FormattedValue:lower():find(
                    SearchBox.Text:lower(),
                    1,
                    true
                ) then
                    continue
                end

                Count = Count + 1

                local IsDisabled = table.find(DisabledValues, Value)
                local Table = {
                    Hovering = false,
                }
                local ValueImage = GetValueImage(Value)

                local Container = New("Frame", {
                    BackgroundColor3 = "AccentColor",
                    BackgroundTransparency = 1,
                    LayoutOrder = IsDisabled and 1 or 0,
                    Size = UDim2.new(1, 0, 0, 26),
                    Parent = MenuTable.Menu,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = Container,
                })

                local RowStroke = New("UIStroke", {
                    Color = "AccentColor",
                    Transparency = 1,
                    Parent = Container,
                })

                local Image = ValueImage and New("ImageLabel", {
                    BackgroundTransparency = 1,
                    Image = ValueImage.Url,
                    ImageRectOffset = ValueImage.ImageRectOffset,
                    ImageRectSize = ValueImage.ImageRectSize,
                    ImageTransparency = 0.38,
                    Size = UDim2.fromOffset(16, 16),
                    Position = UDim2.fromOffset(6, 5),
                    Parent = Container,
                })

                local Button = New("TextButton", {
                    BackgroundTransparency = 1,
                    Size = ValueImage and UDim2.new(1, -22, 1, 0) or UDim2.fromScale(1, 1),
                    Position = ValueImage and UDim2.fromOffset(22, 0) or UDim2.fromOffset(0, 0),
                    Text = FormattedValue,
                    TextSize = 13,
                    TextTransparency = 0.38,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container,
                })

                New("UIPadding", {
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 28),
                    Parent = Button,
                })

                local CheckImage = New("ImageLabel", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Image = CheckIcon and CheckIcon.Url or "",
                    ImageColor3 = "FontColor",
                    ImageRectOffset = CheckIcon and CheckIcon.ImageRectOffset or Vector2.zero,
                    ImageRectSize = CheckIcon and CheckIcon.ImageRectSize or Vector2.zero,
                    ImageTransparency = 1,
                    Position = UDim2.new(1, -7, 0.5, 0),
                    Size = UDim2.fromOffset(14, 14),
                    Parent = Container,
                })

                local Selected

                if Info.Multi then
                    Selected = Dropdown.Value[Value]
                else
                    Selected = Dropdown.Value == Value
                end

                function Table:UpdateButton()
                    if Info.Multi then
                        Selected = Dropdown.Value[Value]
                    else
                        Selected = Dropdown.Value == Value
                    end

                    Container.BackgroundTransparency = IsDisabled and 1
                        or Selected and (Table.Hovering and 0.68 or 0.78)
                        or Table.Hovering and 0.9
                        or 1

                    RowStroke.Transparency = IsDisabled and 1
                        or Selected and 0.48
                        or Table.Hovering and 0.76
                        or 1

                    Button.TextTransparency = IsDisabled and 0.8
                        or Selected and 0
                        or Table.Hovering and 0.08
                        or 0.38

                    CheckImage.ImageTransparency = Selected and (IsDisabled and 0.7 or 0) or 1

                    if Image then
                        Image.ImageTransparency = IsDisabled and 0.8
                            or Selected and 0
                            or Table.Hovering and 0.08
                            or 0.38
                    end
                end

                Button.MouseEnter:Connect(function()
                    if not IsDisabled then
                        Table.Hovering = true
                        Table:UpdateButton()
                    end
                end)

                Button.MouseLeave:Connect(function()
                    Table.Hovering = false
                    Table:UpdateButton()
                end)

                if not IsDisabled then
                    Button.MouseButton1Click:Connect(function()
                        local Try = not Selected

                        if not (Dropdown:GetActiveValues() == 1 and not Try and not Info.AllowNull) then
                            Selected = Try

                            if Info.Multi then
                                Dropdown.Value[Value] = Selected and true or nil
                            else
                                Dropdown.Value = Selected and Value or nil
                            end

                            for _, OtherButton in Buttons do
                                OtherButton:UpdateButton()
                            end
                        end

                        Table:UpdateButton()
                        Dropdown:Display()

                        Library:UpdateDependencyBoxes()
                        Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
                        Library:SafeCallback(Dropdown.Changed, Dropdown.Value)

                        if not Info.Multi then
                            MenuTable:Close()
                        end
                    end)
                end

                Table:UpdateButton()
                Dropdown:Display()

                Buttons[Button] = Table
            end

            Dropdown:RecalculateListSize(Count)
        end

        function Dropdown:SetValue(Value)
            if Info.Multi then
                local Table = {}
				
                for Val, Active in Value or {} do
                    if typeof(Active) ~= "boolean" then
                        Table[Active] = true
                    elseif Active and table.find(Dropdown.Values, Val) then
                        Table[Val] = true
                    end
                end

                Dropdown.Value = Table
            else
                if table.find(Dropdown.Values, Value) then
                    Dropdown.Value = Value
                elseif not Value then
                    Dropdown.Value = nil
                end
            end

            Dropdown:Display()
            for _, Button in Buttons do
                Button:UpdateButton()
            end
            Library:RefreshDropdownPicker(Dropdown, true)

            if not Dropdown.Disabled then
                Library:UpdateDependencyBoxes()
                Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
                Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
            end
        end

        function Dropdown:SetValues(Values)
            Dropdown.Values = Values
            Dropdown:BuildDropdownList()
            Library:RefreshDropdownPicker(Dropdown, false)
        end

        function Dropdown:AddValues(Values)
            if typeof(Values) == "table" then
                for _, val in Values do
                    table.insert(Dropdown.Values, val)
                end
            elseif typeof(Values) == "string" then
                table.insert(Dropdown.Values, Values)
            else
                return
            end

            Dropdown:BuildDropdownList()
            Library:RefreshDropdownPicker(Dropdown, false)
        end

        function Dropdown:SetDisabledValues(DisabledValues)
            Dropdown.DisabledValues = DisabledValues
            Dropdown:BuildDropdownList()
            Library:RefreshDropdownPicker(Dropdown, false)
        end

        function Dropdown:AddDisabledValues(DisabledValues)
            if typeof(DisabledValues) == "table" then
                for _, val in DisabledValues do
                    table.insert(Dropdown.DisabledValues, val)
                end
            elseif typeof(DisabledValues) == "string" then
                table.insert(Dropdown.DisabledValues, DisabledValues)
            else
                return
            end

            Dropdown:BuildDropdownList()
            Library:RefreshDropdownPicker(Dropdown, false)
        end

        function Dropdown:SetValueImages(ValueImages)
            if typeof(ValueImages) ~= "table" then
                return
            end
            
            Dropdown.ValueImages = ValueImages
            Dropdown:BuildDropdownList()
            Library:RefreshDropdownPicker(Dropdown, false)
        end

        function Dropdown:SetValueMetadata(ValueMetadata)
            if typeof(ValueMetadata) ~= "table" then
                return
            end

            Dropdown.ValueMetadata =
                ValueMetadata

            Info.ValueMetadata =
                ValueMetadata

            Dropdown:BuildDropdownList()

            Library:RefreshDropdownPicker(
                Dropdown,
                false
            )
        end

        function Dropdown:AddValueImages(ValueImages)
            if typeof(ValueImages) ~= "table" then
                return
            end
            
            for key, val in ValueImages do
                Dropdown.ValueImages[key] = val
            end
            
            Dropdown:BuildDropdownList()
            Library:RefreshDropdownPicker(Dropdown, false)
        end

        function Dropdown:SetDisabled(Disabled: boolean)
            Dropdown.Disabled = Disabled

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable.Disabled = Dropdown.Disabled
            end

            MenuTable:Close()
            Library:CloseDropdownPicker(Dropdown)
            DisplayButton.Active = not Dropdown.Disabled
            Dropdown:UpdateColors()
        end

        function Dropdown:SetVisible(Visible: boolean)
            Dropdown.Visible = Visible

            Holder.Visible = Dropdown.Visible

            if not Dropdown.Visible then
                Library:CloseDropdownPicker(Dropdown)
            end

            Groupbox:Resize()
        end

        function Dropdown:SetText(Text: string)
            Dropdown.Text = Text
            Holder.Size = UDim2.new(1, 0, 0, Text and 39 or 21)

            Label.Text = Text and Text or ""
            Label.Visible = not not Text
        end

        local ToggleDropdown = function()
            if Dropdown.Disabled then
                return
            end

            if Dropdown:UsesPopout() then
                if Library:IsDropdownPickerOpen(Dropdown) then
                    Library:CloseDropdownPicker(Dropdown)
                else
                    Library:OpenDropdownPicker({
                        Dropdown = Dropdown,
                        Info = Info,
                        GetValueImage = GetValueImage,
                    })
                end
            else
                MenuTable:Toggle()
            end
        end

        DisplayContainer.MouseButton1Click:Connect(ToggleDropdown)
        DisplayButton.MouseButton1Click:Connect(ToggleDropdown)

        if SearchBox then
            SearchBox:GetPropertyChangedSignal("Text"):Connect(Dropdown.BuildDropdownList)
        end

        local Defaults = {}
        if typeof(Info.Default) == "string" then
            local Index = table.find(Dropdown.Values, Info.Default)
            if Index then
                table.insert(Defaults, Index)
            end
        elseif typeof(Info.Default) == "table" then
            for _, Value in next, Info.Default do
                local Index = table.find(Dropdown.Values, Value)
                if Index then
                    table.insert(Defaults, Index)
                end
            end
        elseif Dropdown.Values[Info.Default] ~= nil then
            table.insert(Defaults, Info.Default)
        end

        if next(Defaults) then
            for i = 1, #Defaults do
                local Index = Defaults[i]
                if Info.Multi then
                    Dropdown.Value[Dropdown.Values[Index]] = true
                else
                    Dropdown.Value = Dropdown.Values[Index]
                end

                if not Info.Multi then
                    break
                end
            end
        end

        if typeof(Dropdown.Tooltip) == "string" or typeof(Dropdown.DisabledTooltip) == "string" then
            Dropdown.TooltipTable = Library:AddTooltip(Dropdown.Tooltip, Dropdown.DisabledTooltip, DisplayContainer)
            Dropdown.TooltipTable.Disabled = Dropdown.Disabled
        end

        Dropdown:UpdateColors()
        Dropdown:Display()
        Dropdown:BuildDropdownList()
        Groupbox:Resize()

        Dropdown.Holder = Holder
        table.insert(Groupbox.Elements, Dropdown)

        Dropdown.Default = Defaults
        Dropdown.DefaultValues = Dropdown.Values

        Options[Idx] = Dropdown

        return Dropdown
    end

    function Funcs:AddViewport(Idx, Info)
        Info = Library:Validate(Info, Templates.Viewport)

        local Groupbox = self
        local Container = Groupbox.Container

        local Dragging, Pinching = false, false
        local LastMousePos, LastPinchDist = nil, 0

        local ViewportObject = Info.Object
        if Info.Clone and typeof(Info.Object) == "Instance" then
            if Info.Object.Archivable then
                ViewportObject = ViewportObject:Clone()
            else
                Info.Object.Archivable = true
                ViewportObject = ViewportObject:Clone()
                Info.Object.Archivable = false
            end
        end

        local Viewport = {
            Object = ViewportObject,
            Camera = if not Info.Camera then Instance.new("Camera") else Info.Camera,
            Interactive = Info.Interactive,
            AutoFocus = Info.AutoFocus,
            Visible = Info.Visible,
            Type = "Viewport",
        }

        assert(
            typeof(Viewport.Object) == "Instance" and (Viewport.Object:IsA("BasePart") or Viewport.Object:IsA("Model")),
            "Instance must be a BasePart or Model."
        )

        assert(
            typeof(Viewport.Camera) == "Instance" and Viewport.Camera:IsA("Camera"),
            "Camera must be a valid Camera instance."
        )

        local function GetModelSize(model)
            if model:IsA("BasePart") then
                return model.Size
            end

            return select(2, model:GetBoundingBox())
        end

        local function FocusCamera()
            local ModelSize = GetModelSize(Viewport.Object)
            local MaxExtent = math.max(ModelSize.X, ModelSize.Y, ModelSize.Z)
            local CameraDistance = MaxExtent * 2
            local ModelPosition = Viewport.Object:GetPivot().Position

            Viewport.Camera.CFrame =
                CFrame.new(ModelPosition + Vector3.new(0, MaxExtent / 2, CameraDistance), ModelPosition)
        end

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Viewport.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ViewportFrame = New("ViewportFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = Box,
            CurrentCamera = Viewport.Camera,
            Active = Viewport.Interactive,
        })

        ViewportFrame.MouseEnter:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = false
            end
        end)

        ViewportFrame.MouseLeave:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = true
            end
        end)

        ViewportFrame.InputBegan:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                Dragging = true
                LastMousePos = input.Position
            elseif input.UserInputType == Enum.UserInputType.Touch and not Pinching then
                Dragging = true
                LastMousePos = input.Position
            end
        end)

        Library:GiveSignal(UserInputService.InputEnded:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                Dragging = false
            elseif input.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
            end
        end))

        Library:GiveSignal(UserInputService.InputChanged:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Dragging or Pinching then
                return
            end

            if
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            then
                local MouseDelta = input.Position - LastMousePos
                LastMousePos = input.Position

                local Position = Viewport.Object:GetPivot().Position
                local Camera = Viewport.Camera

                local RotationY = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -MouseDelta.X * 0.01)
                Camera.CFrame = CFrame.new(Position) * RotationY * CFrame.new(-Position) * Camera.CFrame

                local RotationX = CFrame.fromAxisAngle(Camera.CFrame.RightVector, -MouseDelta.Y * 0.01)
                local PitchedCFrame = CFrame.new(Position) * RotationX * CFrame.new(-Position) * Camera.CFrame

                if PitchedCFrame.UpVector.Y > 0.1 then
                    Camera.CFrame = PitchedCFrame
                end
            end
        end))

        ViewportFrame.InputChanged:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseWheel then
                local ZoomAmount = input.Position.Z * 2
                Viewport.Camera.CFrame = Viewport.Camera.CFrame + Viewport.Camera.CFrame.LookVector * ZoomAmount
            end
        end)

        Library:GiveSignal(UserInputService.TouchPinch:Connect(function(touchPositions, scale, velocity, state)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Library:MouseIsOverFrame(ViewportFrame, touchPositions[1]) then
                return
            end

            if state == Enum.UserInputState.Begin then
                Pinching = true
                Dragging = false
                LastPinchDist = (touchPositions[1] - touchPositions[2]).Magnitude
            elseif state == Enum.UserInputState.Change then
                local currentDist = (touchPositions[1] - touchPositions[2]).Magnitude
                local delta = (currentDist - LastPinchDist) * 0.1
                LastPinchDist = currentDist
                Viewport.Camera.CFrame = Viewport.Camera.CFrame + Viewport.Camera.CFrame.LookVector * delta
            elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                Pinching = false
            end
        end))

        Viewport.Object.Parent = ViewportFrame
        if Viewport.AutoFocus then
            FocusCamera()
        end

        function Viewport:SetObject(Object: Instance, Clone: boolean?)
            assert(Object, "Object cannot be nil.")

            if Clone then
                Object = Object:Clone()
            end

            if Viewport.Object then
                Viewport.Object:Destroy()
            end

            Viewport.Object = Object
            Viewport.Object.Parent = ViewportFrame

            Groupbox:Resize()
        end

        function Viewport:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Viewport:Focus()
            if not Viewport.Object then
                return
            end

            FocusCamera()
        end

        function Viewport:SetCamera(Camera: Instance)
            assert(
                Camera and typeof(Camera) == "Instance" and Camera:IsA("Camera"),
                "Camera must be a valid Camera instance."
            )

            Viewport.Camera = Camera
            ViewportFrame.CurrentCamera = Camera
        end

        function Viewport:SetInteractive(Interactive: boolean)
            Viewport.Interactive = Interactive
            ViewportFrame.Active = Interactive
        end

        function Viewport:SetVisible(Visible: boolean)
            Viewport.Visible = Visible

            Holder.Visible = Viewport.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Viewport.Holder = Holder
        table.insert(Groupbox.Elements, Viewport)

        Options[Idx] = Viewport

        return Viewport
    end

    function Funcs:AddImage(Idx, Info)
        Info = Library:Validate(Info, Templates.Image)

        local Groupbox = self
        local Container = Groupbox.Container

        local Image = {
            Image = Info.Image,
            Color = Info.Color,
            RectOffset = Info.RectOffset,
            RectSize = Info.RectSize,
            Height = Info.Height,
            ScaleType = Info.ScaleType,
            Transparency = Info.Transparency,
            BackgroundTransparency = Info.BackgroundTransparency,

            Visible = Info.Visible,
            Type = "Image",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Image.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            BackgroundTransparency = Image.BackgroundTransparency,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ImageProperties = {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Image = Image.Image,
            ImageTransparency = Image.Transparency,
            ImageColor3 = Image.Color,
            ImageRectOffset = Image.RectOffset,
            ImageRectSize = Image.RectSize,
            ScaleType = Image.ScaleType,
            Parent = Box,
        }

        local Icon = Library:GetCustomIcon(ImageProperties.Image)
        assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        ImageProperties.Image = Icon.Url
        ImageProperties.ImageRectOffset = Icon.ImageRectOffset
        ImageProperties.ImageRectSize = Icon.ImageRectSize

        local ImageLabel = New("ImageLabel", ImageProperties)

        function Image:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Image.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Image:SetImage(NewImage: string)
            assert(typeof(NewImage) == "string", "Image must be a string.")

            local Icon = Library:GetCustomIcon(NewImage)
            assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            NewImage = Icon.Url
            Image.RectOffset = Icon.ImageRectOffset
            Image.RectSize = Icon.ImageRectSize

            ImageLabel.Image = NewImage
            Image.Image = NewImage
        end

        function Image:SetColor(Color: Color3)
            assert(typeof(Color) == "Color3", "Color must be a Color3 value.")

            ImageLabel.ImageColor3 = Color
            Image.Color = Color
        end

        function Image:SetRectOffset(RectOffset: Vector2)
            assert(typeof(RectOffset) == "Vector2", "RectOffset must be a Vector2 value.")

            ImageLabel.ImageRectOffset = RectOffset
            Image.RectOffset = RectOffset
        end

        function Image:SetRectSize(RectSize: Vector2)
            assert(typeof(RectSize) == "Vector2", "RectSize must be a Vector2 value.")

            ImageLabel.ImageRectSize = RectSize
            Image.RectSize = RectSize
        end

        function Image:SetScaleType(ScaleType: Enum.ScaleType)
            assert(
                typeof(ScaleType) == "EnumItem" and ScaleType:IsA("ScaleType"),
                "ScaleType must be a valid Enum.ScaleType."
            )

            ImageLabel.ScaleType = ScaleType
            Image.ScaleType = ScaleType
        end

        function Image:SetTransparency(Transparency: number)
            assert(typeof(Transparency) == "number", "Transparency must be a number between 0 and 1.")
            assert(Transparency >= 0 and Transparency <= 1, "Transparency must be between 0 and 1.")

            ImageLabel.ImageTransparency = Transparency
            Image.Transparency = Transparency
        end

        function Image:SetVisible(Visible: boolean)
            Image.Visible = Visible

            Holder.Visible = Image.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Image.Holder = Holder
        table.insert(Groupbox.Elements, Image)

        Options[Idx] = Image

        return Image
    end

    function Funcs:AddVideo(Idx, Info)
        Info = Library:Validate(Info, Templates.Video)

        local Groupbox = self
        local Container = Groupbox.Container

        local Video = {
            Video = Info.Video,
            Looped = Info.Looped,
            Playing = Info.Playing,
            Volume = Info.Volume,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "Video",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Video.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local VideoFrameInstance = New("VideoFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Video = Video.Video,
            Looped = Video.Looped,
            Volume = Video.Volume,
            Parent = Box,
        })

        VideoFrameInstance.Playing = Video.Playing

        function Video:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Video.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Video:SetVideo(NewVideo: string)
            assert(typeof(NewVideo) == "string", "Video must be a string.")

            VideoFrameInstance.Video = NewVideo
            Video.Video = NewVideo
        end

        function Video:SetLooped(Looped: boolean)
            assert(typeof(Looped) == "boolean", "Looped must be a boolean.")

            VideoFrameInstance.Looped = Looped
            Video.Looped = Looped
        end

        function Video:SetVolume(Volume: number)
            assert(typeof(Volume) == "number", "Volume must be a number between 0 and 10.")

            VideoFrameInstance.Volume = Volume
            Video.Volume = Volume
        end

        function Video:SetPlaying(Playing: boolean)
            assert(typeof(Playing) == "boolean", "Playing must be a boolean.")

            VideoFrameInstance.Playing = Playing
            Video.Playing = Playing
        end

        function Video:Play()
            VideoFrameInstance.Playing = true
            Video.Playing = true
        end

        function Video:Pause()
            VideoFrameInstance.Playing = false
            Video.Playing = false
        end

        function Video:SetVisible(Visible: boolean)
            Video.Visible = Visible

            Holder.Visible = Video.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Video.Holder = Holder
        Video.VideoFrame = VideoFrameInstance
        table.insert(Groupbox.Elements, Video)

        Options[Idx] = Video

        return Video
    end

    function Funcs:AddUIPassthrough(Idx, Info)
        Info = Library:Validate(Info, Templates.UIPassthrough)

        local Groupbox = self
        local Container = Groupbox.Container

        assert(Info.Instance, "Instance must be provided.")
        assert(
            typeof(Info.Instance) == "Instance" and Info.Instance:IsA("GuiBase2d"),
            "Instance must inherit from GuiBase2d."
        )
        assert(typeof(Info.Height) == "number" and Info.Height > 0, "Height must be a number greater than 0.")

        local Passthrough = {
            Instance = Info.Instance,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "UIPassthrough",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Passthrough.Visible,
            Parent = Container,
        })

        Passthrough.Instance.Parent = Holder

        Groupbox:Resize()

        function Passthrough:SetHeight(Height: number)
            assert(typeof(Height) == "number" and Height > 0, "Height must be a number greater than 0.")

            Passthrough.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Passthrough:SetInstance(Instance: Instance)
            assert(Instance, "Instance must be provided.")
            assert(
                typeof(Instance) == "Instance" and Instance:IsA("GuiBase2d"),
                "Instance must inherit from GuiBase2d."
            )

            if Passthrough.Instance then
                Passthrough.Instance.Parent = nil
            end

            Passthrough.Instance = Instance
            Passthrough.Instance.Parent = Holder
        end

        function Passthrough:SetVisible(Visible: boolean)
            Passthrough.Visible = Visible

            Holder.Visible = Passthrough.Visible
            Groupbox:Resize()
        end

        Passthrough.Holder = Holder
        table.insert(Groupbox.Elements, Passthrough)

        Options[Idx] = Passthrough

        return Passthrough
    end

    function Funcs:AddDependencyBox()
        local Groupbox = self
        local Container = Groupbox.Container

        local DepboxContainer
        local DepboxList

        do
            DepboxContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            DepboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepboxContainer,
            })
        end

        local Depbox = {
            Visible = false,
            Dependencies = {},

            Holder = DepboxContainer,
            Container = DepboxContainer,

            Elements = {},
            DependencyBoxes = {},
        }

        function Depbox:Resize()
            DepboxContainer.Size = UDim2.new(1, 0, 0, DepboxList.AbsoluteContentSize.Y / Library.DPIScale)
            Groupbox:Resize()
        end

        function Depbox:Update(CancelSearch)
            for _, Dependency in Depbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepboxContainer.Visible = false
                    Depbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    end
                end
            end

            Depbox.Visible = true
            DepboxContainer.Visible = true
            if not Library.Searching then
                task.defer(function()
                    Depbox:Resize()
                end)
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        DepboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if not Depbox.Visible then
                return
            end

            Depbox:Resize()
        end)

        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            Depbox.Dependencies = Dependencies
            Depbox:Update()
        end

        DepboxContainer:GetPropertyChangedSignal("Visible"):Connect(function()
            Depbox:Resize()
        end)

        setmetatable(Depbox, BaseGroupbox)

        table.insert(Groupbox.DependencyBoxes, Depbox)
        table.insert(Library.DependencyBoxes, Depbox)

        return Depbox
    end

    function Funcs:AddDependencyGroupbox()
        local Groupbox = self
        local Tab = Groupbox.Tab
        local BoxHolder = Groupbox.BoxHolder

        local DepGroupboxContainer
        local DepGroupboxList

        do
            DepGroupboxContainer = New("Frame", {
                BackgroundColor3 = "BackgroundColor",
                Size = UDim2.fromScale(1, 0),
                Visible = false,
                Parent = BoxHolder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = DepGroupboxContainer,
                })
            )
            Library:AddOutline(DepGroupboxContainer)

            DepGroupboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepGroupboxContainer,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 7),
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                PaddingTop = UDim.new(0, 7),
                Parent = DepGroupboxContainer,
            })
        end

        local DepGroupbox = {
            Visible = false,
            Dependencies = {},

            BoxHolder = BoxHolder,
            Holder = DepGroupboxContainer,
            Container = DepGroupboxContainer,

            Tab = Tab,
            Elements = {},
            DependencyBoxes = {},
        }

        function DepGroupbox:Resize()
            DepGroupboxContainer.Size = UDim2.new(1, 0, 0, (DepGroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 18)
        end

        function DepGroupbox:Update(CancelSearch)
            for _, Dependency in DepGroupbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepGroupboxContainer.Visible = false
                    DepGroupbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    end
                end
            end

            DepGroupbox.Visible = true
            if not Library.Searching then
                DepGroupboxContainer.Visible = true
                DepGroupbox:Resize()
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function DepGroupbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            DepGroupbox.Dependencies = Dependencies
            DepGroupbox:Update()
        end

        setmetatable(DepGroupbox, BaseGroupbox)

        table.insert(Tab.DependencyGroupboxes, DepGroupbox)
        table.insert(Library.DependencyBoxes, DepGroupbox)

        return DepGroupbox
    end

    BaseGroupbox.__index = Funcs
    BaseGroupbox.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

function Library:SetFont(FontFace)
    if typeof(FontFace) == "EnumItem" then
        FontFace = Font.fromEnum(FontFace)
    end

    Library.Scheme.Font = FontFace
    Library:UpdateColorsUsingRegistry()
end

function Library:GetWeightedFont(weight)

    weight =
        typeof(weight) == "EnumItem"
        and weight
        or Enum.FontWeight.Medium

    local baseFont =
        Library.Scheme.Font

    if typeof(baseFont) == "EnumItem" then

        baseFont =
            Font.fromEnum(
                baseFont
            )
    end

    if typeof(baseFont) == "Font" then

        local ok,
            weightedFont =
            pcall(function()

                return Font.new(
                    baseFont.Family,
                    weight,
                    baseFont.Style
                )
            end)

        if ok == true
        and typeof(weightedFont) == "Font" then

            return weightedFont
        end

        return baseFont
    end

    return Font.fromEnum(
        Enum.Font.GothamMedium
    )
end

function Library:SetTextWeight(textObject, weight)

    if typeof(textObject) ~= "Instance" then
        return false
    end

    local resolver =
        function()

            return Library:GetWeightedFont(
                weight
            )
        end

    Library.Registry[textObject] =
        type(Library.Registry[textObject]) == "table"
        and Library.Registry[textObject]
        or {}

    Library.Registry[textObject].FontFace =
        resolver

    textObject.FontFace =
        resolver()

    return true
end

function Library:SetNotifySide(Side: string)
    Library.NotifySide = Side

    if Side:lower() == "left" then
        NotificationArea.AnchorPoint = Vector2.new(0, 0)
        NotificationArea.Position = UDim2.fromOffset(6, 6)
        NotificationList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    else
        NotificationArea.AnchorPoint = Vector2.new(1, 0)
        NotificationArea.Position = UDim2.new(1, -6, 0, 6)
        NotificationList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    end
end

function Library:Notify(...)
    local Data = {}
    local Info = select(1, ...)

    if typeof(Info) == "table" then
        Data.Title = tostring(Info.Title)
        Data.Description = tostring(Info.Description)
        Data.Time = Info.Time or 5
        Data.SoundId = Info.SoundId
        Data.Steps = Info.Steps
        Data.Persist = Info.Persist
        Data.Icon = Info.Icon
        Data.BigIcon = Info.BigIcon
        Data.IconColor = Info.IconColor
    else
        Data.Description = tostring(Info)
        Data.Time = select(2, ...) or 5
        Data.SoundId = select(3, ...)
    end
    Data.Destroyed = false

    local DeletedInstance = false
    local DeleteConnection = nil
    if typeof(Data.Time) == "Instance" then
        DeleteConnection = Data.Time.Destroying:Connect(function()
            DeletedInstance = true

            DeleteConnection:Disconnect()
            DeleteConnection = nil
        end)
    end

    local FakeBackground = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        Visible = false,
        Parent = NotificationArea,
    })

    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = "MainColor",
        Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, -2) or UDim2.new(1, 8, 0, -2),
        Size = UDim2.fromScale(1, 1),
        ZIndex = 5,
        Parent = FakeBackground,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = Holder,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = Holder,
    })
    Library:AddOutline(Holder)

    local ContentContainer = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromScale(1, 0),
        Parent = Holder,
    })
    
    if Data.BigIcon then
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = ContentContainer,
        })
    end

    local BigIconLabel
    if Data.BigIcon then
        local ParsedIcon = Library:GetCustomIcon(Data.BigIcon)
        if ParsedIcon then
            BigIconLabel = New("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(24, 24),
                Image = ParsedIcon.Url,
                ImageColor3 = Data.IconColor or "AccentColor",
                ImageRectOffset = ParsedIcon.ImageRectOffset,
                ImageRectSize = ParsedIcon.ImageRectSize,
                Parent = ContentContainer,
            })
        end
    end

    local TextContainer = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromScale(0, 0),
        Parent = ContentContainer,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = TextContainer,
    })
    
    local TitleContainer
    if Data.Title then
        TitleContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0, 0),
            Parent = TextContainer,
        })
    end

    local IconLabel
    if Data.Icon and TitleContainer then
        local ParsedIcon = Library:GetCustomIcon(Data.Icon)
        if ParsedIcon then
            IconLabel = New("ImageLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 1),
                Size = UDim2.fromOffset(15, 15),
                Image = ParsedIcon.Url,
                ImageColor3 = Data.IconColor or "FontColor",
                ImageRectOffset = ParsedIcon.ImageRectOffset,
                ImageRectSize = ParsedIcon.ImageRectSize,
                Parent = TitleContainer,
            })
        end
    end

    local Title
    local Desc
    local TitleX = 0
    local DescX = 0

    local TimerFill

    if Data.Title then
        Title = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, (Data.Icon and 21 or 0), 0.5, 0),
            Size = UDim2.fromScale(0, 0),
            Text = Data.Title,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextWrapped = true,
            Parent = TitleContainer,
        })
    end

    if Data.Description then
        Desc = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0, 0),
            Text = Data.Description,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = TextContainer,
        })
    end

    function Data:Resize()
        local ExtraWidth = BigIconLabel and 32 or 0
        local IconWidth = IconLabel and 21 or 0

        if Title then
            local X, Y =
                Library:GetTextBounds(Title.Text, Title.FontFace, Title.TextSize, (NotificationArea.AbsoluteSize.X / Library.DPIScale) - 24 - ExtraWidth - IconWidth)
            Title.Size = UDim2.fromOffset(X, Y)
            TitleX = X + IconWidth
            TitleContainer.Size = UDim2.fromOffset(TitleX, math.max(Y, IconLabel and 16 or 0))
        end

        if Desc then
            local X, Y =
                Library:GetTextBounds(Desc.Text, Desc.FontFace, Desc.TextSize, (NotificationArea.AbsoluteSize.X / Library.DPIScale) - 24 - ExtraWidth)
            Desc.Size = UDim2.fromOffset(X, Y)
            DescX = X
        end

        FakeBackground.Size = UDim2.fromOffset(math.max(TitleX, DescX) + 24 + ExtraWidth, 0)
    end

    function Data:ChangeTitle(Text)
        if Title then
            Data.Title = tostring(Text)
            Title.Text = Data.Title
            Data:Resize()
        end
    end

    function Data:ChangeDescription(Text)
        if Desc then
            Data.Description = tostring(Text)
            Desc.Text = Data.Description
            Data:Resize()
        end
    end

    function Data:ChangeStep(NewStep)
        if TimerFill and Data.Steps then
            NewStep = math.clamp(NewStep or 0, 0, Data.Steps)
            TimerFill.Size = UDim2.fromScale(NewStep / Data.Steps, 1)
        end
    end

    function Data:Destroy()
        Data.Destroyed = true

        if typeof(Data.Time) == "Instance" then
            pcall(Data.Time.Destroy, Data.Time)
        end

        if DeleteConnection then
            DeleteConnection:Disconnect()
        end

        TweenService
            :Create(Holder, Library.NotifyTweenInfo, {
                Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, -2) or UDim2.new(1, 8, 0, -2),
            })
            :Play()

        task.delay(Library.NotifyTweenInfo.Time, function()
            Library.Notifications[FakeBackground] = nil
            FakeBackground:Destroy()
        end)
    end

    Data:Resize()

    local TimerHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 7),
        Visible = (Data.Persist ~= true and typeof(Data.Time) ~= "Instance") or typeof(Data.Steps) == "number",
        Parent = Holder,
    })
    local TimerBar = New("Frame", {
        BackgroundColor3 = "BackgroundColor",
        BorderColor3 = "OutlineColor",
        BorderSizePixel = 1,
        Position = UDim2.fromOffset(0, 3),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = TimerHolder,
    })
    TimerFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        Size = UDim2.fromScale(1, 1),
        Parent = TimerBar,
    })

    if typeof(Data.Time) == "Instance" then
        TimerFill.Size = UDim2.fromScale(0, 1)
    end
    if Data.SoundId then
        local SoundId = Data.SoundId
        if typeof(SoundId) == "number" then
            SoundId = string.format("rbxassetid://%d", SoundId)
        end

        New("Sound", {
            SoundId = SoundId,
            Volume = 3,
            PlayOnRemove = true,
            Parent = SoundService,
        }):Destroy()
    end

    Library.Notifications[FakeBackground] = Data

    FakeBackground.Visible = true
    TweenService:Create(Holder, Library.NotifyTweenInfo, {
        Position = UDim2.fromOffset(0, 0),
    }):Play()

    task.delay(Library.NotifyTweenInfo.Time, function()
        if Data.Persist then
            return
        elseif typeof(Data.Time) == "Instance" then
            repeat
                task.wait()
            until DeletedInstance or Data.Destroyed
        else
            TweenService
                :Create(TimerFill, TweenInfo.new(Data.Time, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                    Size = UDim2.fromScale(0, 1),
                })
                :Play()
            task.wait(Data.Time)
        end

        if not Data.Destroyed then
            Data:Destroy()
        end
    end)

    return Data
end

function Library:CreateWindow(WindowInfo)
    WindowInfo = Library:Validate(WindowInfo, Templates.Window)

    WindowInfo.Title =
        "HOLY"

    local ViewportSize: Vector2 = workspace.CurrentCamera.ViewportSize
    if RunService:IsStudio() and ViewportSize.X <= 5 and ViewportSize.Y <= 5 then
        repeat
            ViewportSize = workspace.CurrentCamera.ViewportSize
            task.wait()
        until ViewportSize.X > 5 and ViewportSize.Y > 5
    end

    local MaxX = ViewportSize.X - 64
    local MaxY = ViewportSize.Y - 64

    Library.OriginalMinSize =
        Vector2.new(math.min(Library.OriginalMinSize.X, MaxX), math.min(Library.OriginalMinSize.Y, MaxY))
    Library.MinSize = Library.OriginalMinSize

    WindowInfo.Size = UDim2.fromOffset(
        math.clamp(WindowInfo.Size.X.Offset, Library.MinSize.X, MaxX),
        math.clamp(WindowInfo.Size.Y.Offset, Library.MinSize.Y, MaxY)
    )
    if typeof(WindowInfo.Font) == "EnumItem" then
        WindowInfo.Font = Font.fromEnum(WindowInfo.Font)
    end
    WindowInfo.CornerRadius =
        math.clamp(
            tonumber(
                WindowInfo.CornerRadius
            )
            or 12,
            12,
            14
        )
    
    --// Old Naming \\--
    if WindowInfo.Compact ~= nil then
        WindowInfo.SidebarCompacted = WindowInfo.Compact
    end
    if WindowInfo.SidebarMinWidth ~= nil then
        WindowInfo.MinSidebarWidth = WindowInfo.SidebarMinWidth
    end
    WindowInfo.MinSidebarWidth = math.max(64, WindowInfo.MinSidebarWidth)
    WindowInfo.SidebarCompactWidth = math.max(48, WindowInfo.SidebarCompactWidth)
    WindowInfo.SidebarCollapseThreshold = math.clamp(WindowInfo.SidebarCollapseThreshold, 0.1, 0.9)
    WindowInfo.CompactWidthActivation = math.max(48, WindowInfo.CompactWidthActivation)

    Library.CornerRadius = WindowInfo.CornerRadius
    Library:SetNotifySide(WindowInfo.NotifySide)
    Library.ShowCustomCursor = WindowInfo.ShowCustomCursor
    Library.Scheme.Font = WindowInfo.Font
    Library.ToggleKeybind =
        WindowInfo.ToggleKeybind

    Library.GlobalSearch =
        WindowInfo.GlobalSearch

    Library:SetAnimations(
        WindowInfo.Animations,
        WindowInfo.TabTransitionTime,
        WindowInfo.TabSwipeOffset,
        WindowInfo.TabSwipeFrom
    )

    local IsDefaultSearchbarSize = WindowInfo.SearchbarSize == UDim2.fromScale(1, 1)
    local MainFrame
    local DividerLine
    local TitleHolder
    local WindowTitle
    local WindowIcon
    local RightWrapper
    local SearchBox
    local CurrentTabInfo
    local CurrentTabLabel
    local CurrentTabDescription
    local ResizeButton
    local Tabs
    local Container
    local BackgroundImage
    local BottomBackground
    local FooterLabel
    local SidebarSurface

    local ProfileCard
    local ProfileAvatar
    local ProfileFallback
    local ProfilePrivacyIcon
    local ProfileStatus
    local ProfileDisplayName
    local ProfileUsername

    local AccountPopoverBlocker
    local AccountPopover
    local AccountPopoverAvatar
    local AccountPopoverFallback
    local AccountPopoverPrivacyIcon
    local AccountPopoverDisplayName
    local AccountPopoverUsername
    local AccountPopoverStatus
    local AccountPopoverManageButton

    local UpdateAccountDock
    local AccountManageCallback
    local ProfileThumbnailLoaded = false
    local ProfileThumbnail = ""
    local AccountStatus = "Not connected"

    local function NormalizeAccountPrivacyMode(value)

        value =
            tostring(
                value
                or "Hidden Until Clicked"
            )

        if value ~= "Always Hidden"
        and value ~= "Always Visible" then

            value =
                "Hidden Until Clicked"
        end

        return value
    end

    local AccountPrivacyMode =
        NormalizeAccountPrivacyMode(
            WindowInfo.AccountPrivacyMode
        )

    local InitialLeftWidth = math.clamp(
        math.ceil(WindowInfo.Size.X.Offset * 0.23),
        165,
        185
    )
    local IsCompact = WindowInfo.SidebarCompacted
    local LastExpandedWidth = InitialLeftWidth

    do
        Library.KeybindFrame, Library.KeybindContainer = Library:AddDraggableMenu("Keybinds")
        Library.KeybindFrame.AnchorPoint = Vector2.new(0, 0.5)
        Library.KeybindFrame.Position = UDim2.new(0, 6, 0.5, 0)
        Library.KeybindFrame.Visible = false

        MainFrame = New("TextButton", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
            end,
            ClipsDescendants = true,
            Name = "Main",
            Text = "",
            Position = WindowInfo.Position,
            Size = WindowInfo.Size,
            Visible = false,
            Parent = ScreenGui,
        })

        Library:RegisterSurface(
            MainFrame,
            "Window",
            0.02
        )

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = MainFrame,
            })
        )
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = MainFrame,
            })
        )
        Library:AddOutline(MainFrame)
        Library:MakeLine(MainFrame, {
            Position = UDim2.fromOffset(0, 44),
            Size = UDim2.new(1, 0, 0, 1),
        })

        DividerLine = New("Frame", {
            BackgroundColor3 =
                "OutlineColor",

            BackgroundTransparency =
                0.18,

            BorderSizePixel =
                0,

            Position =
                UDim2.fromOffset(
                    InitialLeftWidth,
                    45
                ),

            Size =
                UDim2.new(
                    0,
                    1,
                    1,
                    -66
                ),

            Parent =
                MainFrame,
        })

        if WindowInfo.BackgroundImage then
            BackgroundImage = New("ImageLabel", {
                Image = WindowInfo.BackgroundImage,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                ScaleType = Enum.ScaleType.Stretch,
                ZIndex = 999,
                BackgroundTransparency = 1,
                ImageTransparency = 0.75,
                Parent = MainFrame,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = BackgroundImage,
                })
            )
        end

        if WindowInfo.Center then
            MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset / 2, 0.5, -MainFrame.Size.Y.Offset / 2)
        end

        --// Top Bar \\-
        local TopBar =
            New(
                "Frame",
                {
                    Name =
                        "WindowHeader",

                    BackgroundColor3 =
                        "BackgroundColor",

                    BackgroundTransparency =
                        0,

                    BorderSizePixel =
                        0,

                    Size =
                        UDim2.new(
                            1,
                            0,
                            0,
                            44
                        ),

                    Parent =
                        MainFrame,
                }
            )

        Library:RegisterSurface(
            TopBar,
            "Chrome",
            0
        )

        table.insert(
            Library.Corners,
            New(
                "UICorner",
                {
                    CornerRadius =
                        UDim.new(
                            0,
                            WindowInfo.CornerRadius
                        ),

                    Parent =
                        TopBar,
                }
            )
        )

        Library:MakeDraggable(
            MainFrame,
            TopBar,
            false,
            true
        )

        --// Title
        TitleHolder = New("Frame", {
            Name =
                "BrandArea",

            BackgroundTransparency =
                1,

            Size =
                UDim2.new(
                    0,
                    InitialLeftWidth,
                    1,
                    0
                ),

            Parent =
                TopBar,
        })

        New("UIListLayout", {
            FillDirection =
                Enum.FillDirection.Horizontal,

            HorizontalAlignment =
                Enum.HorizontalAlignment.Center,

            VerticalAlignment =
                Enum.VerticalAlignment.Center,

            Padding =
                UDim.new(
                    0,
                    6
                ),

            Parent =
                TitleHolder,
        })

        if WindowInfo.Icon then
            local Icon = Library:GetCustomIcon(WindowInfo.Icon)
            WindowIcon = New("ImageLabel", {
                Image = Icon.Url,
                ImageRectOffset = Icon.ImageRectOffset,
                ImageRectSize = Icon.ImageRectSize,
                Size = WindowInfo.IconSize,
                Parent = TitleHolder,
            })
        else
            WindowIcon = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = WindowInfo.IconSize,
                Text = WindowInfo.Title:sub(1, 1),
                TextScaled = true,
                Visible = false,
                Parent = TitleHolder,
            })
        end

        local WordmarkFont =
            Font.fromEnum(
                Enum.Font.GothamBlack
            )

        local X =
            Library:GetTextBounds(
                "HOLY",
                WordmarkFont,
                22,
                TitleHolder.AbsoluteSize.X
            )

        WindowTitle =
            New(
                "TextLabel",
                {
                    BackgroundTransparency =
                        1,

                    FontFace =
                        WordmarkFont,

                    Size =
                        UDim2.new(
                            0,
                            math.max(
                                82,
                                math.ceil(X + 6)
                            ),
                            1,
                            0
                        ),

                    Text =
                        "HOLY",

                    TextColor3 =
                        "WhiteColor",

                    TextSize =
                        22,

                    TextStrokeColor3 =
                        Color3.fromRGB(
                            0,
                            0,
                            0
                        ),

                    TextStrokeTransparency =
                        0.82,

                    TextXAlignment =
                        Enum.TextXAlignment.Center,

                    Parent =
                        TitleHolder,
                }
            )

        New(
            "UIGradient",
            {
                Color =
                    function()

                        return ColorSequence.new({
                            ColorSequenceKeypoint.new(
                                0,
                                Library.Scheme.WhiteColor
                            ),

                            ColorSequenceKeypoint.new(
                                0.52,
                                Library.Scheme.WhiteColor
                            ),

                            ColorSequenceKeypoint.new(
                                1,
                                Library.Scheme.AccentColor
                            ),
                        })
                    end,

                Rotation =
                    0,

                Parent =
                    WindowTitle,
            }
        )

        --// Top Right Bar
        RightWrapper = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -49, 0.5, 0),
            Size = UDim2.new(1, -InitialLeftWidth - 57 - 1, 1, -16),
            Parent = TopBar,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = RightWrapper,
        })

        CurrentTabInfo = New("Frame", {
            Size = UDim2.fromScale(WindowInfo.DisableSearch and 1 or 0.5, 1),
            Visible = false,
            BackgroundTransparency = 1,
            Parent = RightWrapper,
        })

        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Grow,
            Parent = CurrentTabInfo,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = CurrentTabInfo,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = CurrentTabInfo,
        })

        CurrentTabLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = CurrentTabInfo,
        })

        CurrentTabDescription = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextWrapped = true,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.5,
            Parent = CurrentTabInfo,
        })

        SearchBox = New("TextBox", {
            BackgroundColor3 =
                "MainColor",

            BackgroundTransparency =
                0.12,

            ClearTextOnFocus =
                false,

            PlaceholderColor3 =
                "MutedColor",

            PlaceholderText =
                "Search anything...",

            Size =
                WindowInfo.SearchbarSize,

            TextScaled =
                false,

            TextSize =
                13,

            Visible =
                not (
                    WindowInfo.DisableSearch
                    or false
                ),

            Parent =
                RightWrapper,
        })

        New("UIFlexItem", {
            FlexMode =
                Enum.UIFlexMode.Shrink,

            Parent =
                SearchBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius =
                    UDim.new(
                        0,
                        WindowInfo.CornerRadius
                            / 2
                    ),

                Parent =
                    SearchBox,
            })
        )

        New("UIPadding", {
            PaddingBottom =
                UDim.new(0, 7),

            PaddingLeft =
                UDim.new(0, 8),

            PaddingRight =
                UDim.new(0, 8),

            PaddingTop =
                UDim.new(0, 7),

            Parent =
                SearchBox,
        })

        New("UIStroke", {
            Color =
                "OutlineColor",

            Transparency =
                0.22,

            Thickness =
                1,

            Parent =
                SearchBox,
        })

        local SearchIcon = Library:GetIcon("search")
        if SearchIcon then
            New("ImageLabel", {
                Image = SearchIcon.Url,
                ImageColor3 = "FontColor",
                ImageRectOffset = SearchIcon.ImageRectOffset,
                ImageRectSize = SearchIcon.ImageRectSize,
                ImageTransparency = 0.5,
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = SearchBox,
            })
        end

        local CloseIcon =
            Library:GetIcon(
                "x"
            )

        local HideButton =
            New(
                "TextButton",
                {
                    AnchorPoint =
                        Vector2.new(
                            1,
                            0.5
                        ),

                    AutoButtonColor =
                        false,

                    BackgroundColor3 =
                        "MainColor",

                    BackgroundTransparency =
                        0.35,

                    Position =
                        UDim2.new(
                            1,
                            -10,
                            0.5,
                            0
                        ),

                    Size =
                        UDim2.fromOffset(
                            28,
                            28
                        ),

                    Text =
                        "",

                    Parent =
                        TopBar,
                }
            )

        table.insert(
            Library.Corners,
            New(
                "UICorner",
                {
                    CornerRadius =
                        UDim.new(
                            0,
                            WindowInfo.CornerRadius
                                / 2
                        ),

                    Parent =
                        HideButton,
                }
            )
        )

        New(
            "UIStroke",
            {
                Color =
                    "OutlineColor",

                Transparency =
                    0.35,

                Thickness =
                    1,

                Parent =
                    HideButton,
            }
        )

        local HideImage =
            New(
                "ImageLabel",
                {
                    AnchorPoint =
                        Vector2.new(
                            0.5,
                            0.5
                        ),

                    BackgroundTransparency =
                        1,

                    Image =
                        CloseIcon
                        and CloseIcon.Url
                        or "",

                    ImageColor3 =
                        "FontColor",

                    ImageRectOffset =
                        CloseIcon
                        and CloseIcon.ImageRectOffset
                        or Vector2.zero,

                    ImageRectSize =
                        CloseIcon
                        and CloseIcon.ImageRectSize
                        or Vector2.zero,

                    ImageTransparency =
                        0.35,

                    Position =
                        UDim2.fromScale(
                            0.5,
                            0.5
                        ),

                    Size =
                        UDim2.fromOffset(
                            14,
                            14
                        ),

                    Parent =
                        HideButton,
                }
            )

        HideButton.MouseEnter:Connect(function()

            TweenService:Create(
                HideButton,
                Library.TweenInfo,
                {
                    BackgroundTransparency =
                        0.08,
                }
            ):Play()

            TweenService:Create(
                HideImage,
                Library.TweenInfo,
                {
                    ImageTransparency =
                        0.05,
                }
            ):Play()
        end)

        HideButton.MouseLeave:Connect(function()

            TweenService:Create(
                HideButton,
                Library.TweenInfo,
                {
                    BackgroundTransparency =
                        0.35,
                }
            ):Play()

            TweenService:Create(
                HideImage,
                Library.TweenInfo,
                {
                    ImageTransparency =
                        0.35,
                }
            ):Play()
        end)

        HideButton.MouseButton1Click:Connect(function()

            if type(Library.Toggle)
                == "function" then

                Library:Toggle(
                    false
                )
            end
        end)

        --// Bottom Bar \\--
        BottomBackground = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20 + WindowInfo.CornerRadius),
            Parent = MainFrame
        })

        Library:RegisterSurface(
            BottomBackground,
            "Chrome",
            0.04
        )

        Library:MakeLine(MainFrame, {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -20),
            Size = UDim2.new(1, 0, 0, 1),
        })

        local BottomBar = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            Parent = MainFrame,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = BottomBackground,
            })
        )

        --// Footer
        FooterLabel = New("TextLabel", {
            BackgroundTransparency =
                1,

            Position =
                UDim2.fromOffset(
                    12,
                    0
                ),

            Size =
                UDim2.new(
                    0.5,
                    -12,
                    1,
                    0
                ),

            Text =
                WindowInfo.Footer,

            TextSize =
                11,

            TextTransparency =
                0.58,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            Parent =
                BottomBar,
        })

        local toggleKeyName =
            typeof(
                WindowInfo.ToggleKeybind
            ) == "EnumItem"
            and WindowInfo.ToggleKeybind.Name
            or "Toggle key"

        New("TextLabel", {
            BackgroundTransparency =
                1,

            Position =
                UDim2.fromScale(
                    0.5,
                    0
                ),

            Size =
                UDim2.new(
                    0.5,
                    -30,
                    1,
                    0
                ),

            Text =
                toggleKeyName
                .. " to hide",

            TextSize =
                11,

            TextTransparency =
                0.58,

            TextXAlignment =
                Enum.TextXAlignment.Right,

            Parent =
                BottomBar,
        })

        --// Resize Button
        if WindowInfo.Resizable then
            ResizeButton = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -WindowInfo.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = BottomBar,
            })

            Library:MakeResizable(MainFrame, ResizeButton, function()
                for _, Tab in Library.Tabs do
                    Tab:Resize(true)
                end
            end)
        end

        New("ImageLabel", {
            Image = ResizeIcon and ResizeIcon.Url or "",
            ImageColor3 = "FontColor",
            ImageRectOffset = ResizeIcon and ResizeIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = ResizeIcon and ResizeIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 0.5,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = ResizeButton,
        })

        --// Tabs \\--

        SidebarSurface = New("Frame", {
            BackgroundColor3 =
                "BackgroundColor",

            BackgroundTransparency =
                0,

            BorderSizePixel =
                0,

            Position =
                UDim2.fromOffset(
                    0,
                    45
                ),

            Size =
                UDim2.new(
                    0,
                    InitialLeftWidth,
                    1,
                    -66
                ),

            Parent =
                MainFrame,
        })

        Library:RegisterSurface(
            SidebarSurface,
            "Chrome",
            0
        )

        Tabs = New("ScrollingFrame", {
            AutomaticCanvasSize =
                Enum.AutomaticSize.Y,

            BackgroundTransparency =
                1,

            CanvasSize =
                UDim2.fromScale(
                    0,
                    0
                ),

            Position =
                UDim2.fromOffset(
                    0,
                    45
                ),

            ScrollBarImageColor3 =
                "OutlineColor",

            ScrollBarImageTransparency =
                0.72,

            ScrollBarThickness =
                2,

            ScrollingDirection =
                Enum.ScrollingDirection.Y,

            Size =
                UDim2.new(
                    0,
                    InitialLeftWidth,
                    1,
                    -132
                ),

            Parent =
                MainFrame,
        })

        New("UIListLayout", {
            Padding =
                UDim.new(
                    0,
                    2
                ),

            SortOrder =
                Enum.SortOrder.LayoutOrder,

            Parent =
                Tabs,
        })

        New("UIPadding", {
            PaddingBottom =
                UDim.new(
                    0,
                    4
                ),

            PaddingLeft =
                UDim.new(
                    0,
                    6
                ),

            PaddingRight =
                UDim.new(
                    0,
                    6
                ),

            PaddingTop =
                UDim.new(
                    0,
                    4
                ),

            Parent =
                Tabs,
        })

        ProfileCard = New("TextButton", {
            AutoButtonColor =
                false,

            BackgroundColor3 =
                "MainColor",

            BackgroundTransparency =
                0.08,

            Position =
                UDim2.new(
                    0,
                    8,
                    1,
                    -80
                ),

            Size =
                UDim2.new(
                    0,
                    InitialLeftWidth - 16,
                    0,
                    56
                ),

            Text =
                "",

            ZIndex =
                3,

            Parent =
                MainFrame,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius =
                    UDim.new(
                        0,
                        WindowInfo.CornerRadius
                    ),

                Parent =
                    ProfileCard,
            })
        )

        New("UIStroke", {
            Color =
                "OutlineColor",

            LineJoinMode =
                Enum.LineJoinMode.Round,

            Transparency =
                0.15,

            Parent =
                ProfileCard,
        })

        Library:RegisterSurface(
            ProfileCard,
            "Control",
            0.08
        )

        ProfileFallback = New("TextLabel", {
            BackgroundColor3 =
                "BackgroundColor",

            Position =
                UDim2.fromOffset(
                    9,
                    10
                ),

            Size =
                UDim2.fromOffset(
                    36,
                    36
                ),

            Text =
                string.upper(
                    string.sub(
                        LocalPlayer.DisplayName
                        or LocalPlayer.Name,
                        1,
                        1
                    )
                ),

            TextSize =
                13,

            ZIndex =
                4,

            Parent =
                ProfileCard,
        })

        New("UICorner", {
            CornerRadius =
                UDim.new(
                    1,
                    0
                ),

            Parent =
                ProfileFallback,
        })

        ProfileAvatar = New("ImageLabel", {
            BackgroundColor3 =
                "BackgroundColor",

            BackgroundTransparency =
                1,

            Position =
                UDim2.fromOffset(
                    9,
                    10
                ),

            Size =
                UDim2.fromOffset(
                    36,
                    36
                ),

            ZIndex =
                5,

            Parent =
                ProfileCard,
        })

        New("UICorner", {
            CornerRadius =
                UDim.new(
                    1,
                    0
                ),

            Parent =
                ProfileAvatar,
        })

        local PrivacyIcon =
            Library:GetIcon(
                "user-round"
            )
            or Library:GetIcon(
                "circle-user-round"
            )

        ProfilePrivacyIcon = New("ImageLabel", {
            BackgroundColor3 =
                "BackgroundColor",

            Image =
                PrivacyIcon
                and PrivacyIcon.Url
                or "",

            ImageColor3 =
                "FontColor",

            ImageRectOffset =
                PrivacyIcon
                and PrivacyIcon.ImageRectOffset
                or Vector2.zero,

            ImageRectSize =
                PrivacyIcon
                and PrivacyIcon.ImageRectSize
                or Vector2.zero,

            ImageTransparency =
                0.18,

            Position =
                UDim2.fromOffset(
                    9,
                    10
                ),

            Size =
                UDim2.fromOffset(
                    36,
                    36
                ),

            ZIndex =
                5,

            Parent =
                ProfileCard,
        })

        New("UICorner", {
            CornerRadius =
                UDim.new(
                    1,
                    0
                ),

            Parent =
                ProfilePrivacyIcon,
        })

        ProfileStatus = New("Frame", {
            AnchorPoint =
                Vector2.new(
                    0.5,
                    0.5
                ),

            BackgroundColor3 =
                Color3.fromRGB(
                    122,
                    128,
                    140
                ),

            Position =
                UDim2.fromOffset(
                    42,
                    43
                ),

            Size =
                UDim2.fromOffset(
                    10,
                    10
                ),

            ZIndex =
                6,

            Parent =
                ProfileCard,
        })

        New("UICorner", {
            CornerRadius =
                UDim.new(
                    1,
                    0
                ),

            Parent =
                ProfileStatus,
        })

        New("UIStroke", {
            Color =
                "MainColor",

            Thickness =
                2,

            Parent =
                ProfileStatus,
        })

        ProfileDisplayName = New("TextLabel", {
            BackgroundTransparency =
                1,

            Position =
                UDim2.fromOffset(
                    54,
                    9
                ),

            Size =
                UDim2.new(
                    1,
                    -62,
                    0,
                    19
                ),

            Text =
                "Account",

            TextSize =
                13,

            TextTruncate =
                Enum.TextTruncate.AtEnd,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            ZIndex =
                4,

            Parent =
                ProfileCard,
        })

        ProfileUsername = New("TextLabel", {
            BackgroundTransparency =
                1,

            Position =
                UDim2.fromOffset(
                    54,
                    28
                ),

            Size =
                UDim2.new(
                    1,
                    -62,
                    0,
                    17
                ),

            Text =
                "Identity hidden",

            TextSize =
                11,

            TextTransparency =
                0.5,

            TextTruncate =
                Enum.TextTruncate.AtEnd,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            ZIndex =
                4,

            Parent =
                ProfileCard,
        })

        AccountPopoverBlocker = New("TextButton", {
            AutoButtonColor =
                false,

            BackgroundTransparency =
                1,

            Position =
                UDim2.fromScale(
                    0,
                    0
                ),

            Size =
                UDim2.new(
                    1,
                    0,
                    1,
                    -20
                ),

            Text =
                "",

            Visible =
                false,

            ZIndex =
                95,

            Parent =
                MainFrame,
        })

        AccountPopover = New("TextButton", {
            AnchorPoint =
                Vector2.new(
                    0,
                    1
                ),

            AutoButtonColor =
                false,

            BackgroundColor3 =
                "MainColor",

            BackgroundTransparency =
                0.04,

            Position =
                UDim2.new(
                    0,
                    8,
                    1,
                    -88
                ),

            Size =
                UDim2.fromOffset(
                    math.max(
                        210,
                        InitialLeftWidth - 16
                    ),
                    132
                ),

            Text =
                "",

            Visible =
                false,

            ZIndex =
                96,

            Parent =
                MainFrame,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius =
                    UDim.new(
                        0,
                        WindowInfo.CornerRadius
                    ),

                Parent =
                    AccountPopover,
            })
        )

        New("UIStroke", {
            Color =
                "OutlineColor",

            Transparency =
                0.08,

            Parent =
                AccountPopover,
        })

        Library:RegisterSurface(
            AccountPopover,
            "Panel",
            0.04
        )

        AccountPopoverFallback = New("TextLabel", {
            BackgroundColor3 =
                "BackgroundColor",

            Position =
                UDim2.fromOffset(
                    12,
                    12
                ),

            Size =
                UDim2.fromOffset(
                    40,
                    40
                ),

            Text =
                string.upper(
                    string.sub(
                        LocalPlayer.DisplayName
                        or LocalPlayer.Name,
                        1,
                        1
                    )
                ),

            TextSize =
                14,

            ZIndex =
                97,

            Parent =
                AccountPopover,
        })

        New("UICorner", {
            CornerRadius =
                UDim.new(
                    1,
                    0
                ),

            Parent =
                AccountPopoverFallback,
        })

        AccountPopoverAvatar = New("ImageLabel", {
            BackgroundColor3 =
                "BackgroundColor",

            BackgroundTransparency =
                1,

            Position =
                UDim2.fromOffset(
                    12,
                    12
                ),

            Size =
                UDim2.fromOffset(
                    40,
                    40
                ),

            ZIndex =
                98,

            Parent =
                AccountPopover,
        })

        New("UICorner", {
            CornerRadius =
                UDim.new(
                    1,
                    0
                ),

            Parent =
                AccountPopoverAvatar,
        })

        AccountPopoverPrivacyIcon = New("ImageLabel", {
            BackgroundColor3 =
                "BackgroundColor",

            Image =
                PrivacyIcon
                and PrivacyIcon.Url
                or "",

            ImageColor3 =
                "FontColor",

            ImageRectOffset =
                PrivacyIcon
                and PrivacyIcon.ImageRectOffset
                or Vector2.zero,

            ImageRectSize =
                PrivacyIcon
                and PrivacyIcon.ImageRectSize
                or Vector2.zero,

            ImageTransparency =
                0.18,

            Position =
                UDim2.fromOffset(
                    12,
                    12
                ),

            Size =
                UDim2.fromOffset(
                    40,
                    40
                ),

            ZIndex =
                98,

            Parent =
                AccountPopover,
        })

        New("UICorner", {
            CornerRadius =
                UDim.new(
                    1,
                    0
                ),

            Parent =
                AccountPopoverPrivacyIcon,
        })

        AccountPopoverDisplayName = New("TextLabel", {
            BackgroundTransparency =
                1,

            Position =
                UDim2.fromOffset(
                    62,
                    10
                ),

            Size =
                UDim2.new(
                    1,
                    -74,
                    0,
                    20
                ),

            Text =
                "Account",

            TextSize =
                14,

            TextTruncate =
                Enum.TextTruncate.AtEnd,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            ZIndex =
                97,

            Parent =
                AccountPopover,
        })

        AccountPopoverUsername = New("TextLabel", {
            BackgroundTransparency =
                1,

            Position =
                UDim2.fromOffset(
                    62,
                    30
                ),

            Size =
                UDim2.new(
                    1,
                    -74,
                    0,
                    17
                ),

            Text =
                "Identity hidden",

            TextSize =
                11,

            TextTransparency =
                0.48,

            TextTruncate =
                Enum.TextTruncate.AtEnd,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            ZIndex =
                97,

            Parent =
                AccountPopover,
        })

        AccountPopoverStatus = New("TextLabel", {
            BackgroundTransparency =
                1,

            Position =
                UDim2.fromOffset(
                    62,
                    48
                ),

            Size =
                UDim2.new(
                    1,
                    -74,
                    0,
                    18
                ),

            Text =
                "Not connected",

            TextSize =
                11,

            TextTransparency =
                0.12,

            TextTruncate =
                Enum.TextTruncate.AtEnd,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            ZIndex =
                97,

            Parent =
                AccountPopover,
        })

        Library:MakeLine(
            AccountPopover,
            {
                Position =
                    UDim2.fromOffset(
                        10,
                        78
                    ),

                Size =
                    UDim2.new(
                        1,
                        -20,
                        0,
                        1
                    ),

                ZIndex =
                    97,
            }
        )

        AccountPopoverManageButton = New("TextButton", {
            AutoButtonColor =
                false,

            BackgroundColor3 =
                "BackgroundColor",

            BackgroundTransparency =
                0.08,

            Position =
                UDim2.fromOffset(
                    10,
                    91
                ),

            Size =
                UDim2.new(
                    1,
                    -20,
                    0,
                    30
                ),

            Text =
                "Manage Account",

            TextSize =
                12,

            ZIndex =
                98,

            Parent =
                AccountPopover,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius =
                    UDim.new(
                        0,
                        Library.CornerRadius / 2
                    ),

                Parent =
                    AccountPopoverManageButton,
            })
        )

        New("UIStroke", {
            Color =
                "OutlineColor",

            Transparency =
                0.18,

            Parent =
                AccountPopoverManageButton,
        })

        Library:RegisterSurface(
            AccountPopoverManageButton,
            "Control",
            0.08
        )

        task.spawn(function()

            local Success,
                Thumbnail =
                pcall(function()

                    return Players:GetUserThumbnailAsync(
                        LocalPlayer.UserId,
                        Enum.ThumbnailType.HeadShot,
                        Enum.ThumbnailSize.Size100x100
                    )
                end)

            if Success
            and type(Thumbnail) == "string"
            and Thumbnail ~= ""
            and ProfileAvatar
            and ProfileAvatar.Parent then

                ProfileThumbnail =
                    Thumbnail

                ProfileThumbnailLoaded =
                    true

                ProfileAvatar.Image =
                    Thumbnail

                ProfileAvatar.BackgroundTransparency =
                    0

                AccountPopoverAvatar.Image =
                    Thumbnail

                AccountPopoverAvatar.BackgroundTransparency =
                    0

                if type(UpdateAccountDock)
                    == "function" then

                    UpdateAccountDock()
                end
            end
        end)

        --// Container \\--
        Container = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 1)
            end,
            Name = "Container",
            Position = UDim2.new(1, 0, 0, 45),
            Size = UDim2.new(1, -InitialLeftWidth - 1, 1, -70),
            Parent = MainFrame,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 0),
            Parent = Container,
        })
    end

    --// Window Table \\--
    local Window = {}

    local function ResolveAccountStatusColor(status)

        local normalized =
            tostring(
                status
                or ""
            ):lower()

        if normalized == "online"
        or normalized == "connected" then

            return Library.Scheme.SuccessColor
        end

        if normalized:find(
            "checking",
            1,
            true
        )
        or normalized:find(
            "connecting",
            1,
            true
        )
        or normalized:find(
            "authenticating",
            1,
            true
        ) then

            return Library.Scheme.WarningColor
        end

        if normalized == "not connected"
        or normalized:find(
            "unsupported",
            1,
            true
        ) then

            return Color3.fromRGB(
                122,
                128,
                140
            )
        end

        return Library.Scheme.DestructiveColor
    end

    UpdateAccountDock =
        function()

            local showDockIdentity =
                AccountPrivacyMode
                    == "Always Visible"
                and IsCompact ~= true

            local showPopoverIdentity =
                AccountPrivacyMode
                    ~= "Always Hidden"

            ProfileDisplayName.Text =
                showDockIdentity
                and LocalPlayer.DisplayName
                or "Account"

            ProfileUsername.Text =
                showDockIdentity
                and (
                    "@"
                    .. LocalPlayer.Name
                )
                or "Identity hidden"

            ProfileAvatar.Visible =
                showDockIdentity
                and ProfileThumbnailLoaded

            ProfileFallback.Visible =
                showDockIdentity
                and ProfileThumbnailLoaded
                    ~= true

            ProfilePrivacyIcon.Visible =
                showDockIdentity
                    ~= true

            ProfileDisplayName.Visible =
                IsCompact ~= true

            ProfileUsername.Visible =
                IsCompact ~= true

            AccountPopoverDisplayName.Text =
                showPopoverIdentity
                and LocalPlayer.DisplayName
                or "Account"

            AccountPopoverUsername.Text =
                showPopoverIdentity
                and (
                    "@"
                    .. LocalPlayer.Name
                )
                or "Identity hidden"

            AccountPopoverAvatar.Visible =
                showPopoverIdentity
                and ProfileThumbnailLoaded

            AccountPopoverFallback.Visible =
                showPopoverIdentity
                and ProfileThumbnailLoaded
                    ~= true

            AccountPopoverPrivacyIcon.Visible =
                showPopoverIdentity
                    ~= true

            AccountPopoverStatus.Text =
                AccountStatus

            local statusColor =
                ResolveAccountStatusColor(
                    AccountStatus
                )

            ProfileStatus.BackgroundColor3 =
                statusColor

            AccountPopoverStatus.TextColor3 =
                statusColor
        end

    function Window:SetAccountPrivacyMode(value)

        AccountPrivacyMode =
            NormalizeAccountPrivacyMode(
                value
            )

        WindowInfo.AccountPrivacyMode =
            AccountPrivacyMode

        UpdateAccountDock()

        return AccountPrivacyMode
    end

    function Window:GetAccountPrivacyMode()

        return AccountPrivacyMode
    end

    function Window:SetAccountDockStatus(status)

        AccountStatus =
            tostring(
                status
                or "Not connected"
            )

        UpdateAccountDock()

        return AccountStatus
    end

    function Window:SetAccountDockManageCallback(callback)

        AccountManageCallback =
            typeof(callback) == "function"
            and callback
            or nil

        return AccountManageCallback
            ~= nil
    end

    function Window:IsAccountPopoverOpen()

        return AccountPopover.Visible
            == true
    end

    function Window:OpenAccountPopover()

        UpdateAccountDock()

        AccountPopoverBlocker.Visible =
            true

        AccountPopover.Visible =
            true

        return true
    end

    function Window:CloseAccountPopover()

        AccountPopover.Visible =
            false

        AccountPopoverBlocker.Visible =
            false

        return true
    end

    function Window:ToggleAccountPopover()

        if Window:IsAccountPopoverOpen() then

            return Window:CloseAccountPopover()
        end

        return Window:OpenAccountPopover()
    end

    Library:GiveSignal(
        ProfileCard.MouseButton1Click:Connect(function()

            Window:ToggleAccountPopover()
        end)
    )

    Library:GiveSignal(
        AccountPopoverBlocker.MouseButton1Click:Connect(function()

            Window:CloseAccountPopover()
        end)
    )

    Library:GiveSignal(
        AccountPopoverManageButton.MouseButton1Click:Connect(function()

            Window:CloseAccountPopover()

            Library:SafeCallback(
                AccountManageCallback
            )
        end)
    )

    Window:SetAccountPrivacyMode(
        AccountPrivacyMode
    )

    Window:SetAccountDockStatus(
        AccountStatus
    )

    function Window:ChangeTitle(title)
        assert(typeof(title) == "string", "Expected string for title got: " .. typeof(title))

        WindowTitle.Text = title
        WindowInfo.Title = title
    end

    if WindowInfo.BackgroundImage then
        function Window:SetBackgroundImage(Image: string)
            assert(typeof(Image) == "string", "Expected string for Image got: " .. typeof(Image))
    
            BackgroundImage.Image = Image
            WindowInfo.BackgroundImage = Image
        end
    end

    function Window:SetFooter(footer: string)
        assert(typeof(footer) == "string", "Expected string for footer got: " .. typeof(footer))

        FooterLabel.Text = footer
        WindowInfo.Footer = footer
    end

    function Window:SetCornerRadius(Radius: number)
        assert(
            typeof(Radius) == "number",
            "Expected number for Radius got: "
                .. typeof(Radius)
        )

        Radius =
            math.clamp(
                Radius,
                12,
                14
            )

        for _, UICorner in Library.Corners do
            if UICorner.CornerRadius.Offset == Library.CornerRadius / 2 then
                UICorner.CornerRadius = UDim.new(0, Radius / 2)
            else
                UICorner.CornerRadius = UDim.new(0, Radius)
            end
        end

        Library.CornerRadius = Radius
        WindowInfo.CornerRadius = Radius

        ResizeButton.Position = UDim2.new(1, -Radius / 4, 0, 0)
        BottomBackground.Size = UDim2.new(1, 0, 0, 20 + Radius)

        for _, Tab in Library.Tabs do
            if Tab.IsKeyTab then
                continue
            end

            for _, Tabbox in Tab.Tabboxes do
                Tabbox:UpdateCorners()
            end
        end
    end

    local function ApplyCompact()
        IsCompact = Window:GetSidebarWidth() == WindowInfo.SidebarCompactWidth

        if WindowInfo.DisableCompactingSnap then
            IsCompact = Window:GetSidebarWidth()
                <= WindowInfo.CompactWidthActivation
        end

        WindowTitle.Visible = not IsCompact

        if not WindowInfo.Icon then
            WindowIcon.Visible = IsCompact
        end

        for _, Button in Library.TabButtons do
            if not Button.Icon then
                continue
            end

            Button.Label.Visible = not IsCompact

            Button.Padding.PaddingBottom =
                UDim.new(0, IsCompact and 6 or 11)

            Button.Padding.PaddingLeft =
                UDim.new(0, IsCompact and 6 or 12)

            Button.Padding.PaddingRight =
                UDim.new(0, IsCompact and 6 or 12)

            Button.Padding.PaddingTop =
                UDim.new(0, IsCompact and 6 or 11)

            Button.Icon.SizeConstraint = IsCompact
                and Enum.SizeConstraint.RelativeXY
                or Enum.SizeConstraint.RelativeYY
        end

        ProfileCard.Position =
            UDim2.new(
                0,
                IsCompact
                    and 4
                    or 8,
                1,
                -80
            )

        ProfileCard.Size =
            UDim2.new(
                0,
                math.max(
                    40,
                    Tabs.Size.X.Offset
                        - (
                            IsCompact
                            and 8
                            or 16
                        )
                ),
                0,
                56
            )

        local profileIconX =
            IsCompact
            and 2
            or 9

        ProfileAvatar.Position =
            UDim2.fromOffset(
                profileIconX,
                10
            )

        ProfileFallback.Position =
            ProfileAvatar.Position

        ProfilePrivacyIcon.Position =
            ProfileAvatar.Position

        ProfileStatus.Position =
            UDim2.fromOffset(
                profileIconX + 33,
                43
            )

        AccountPopover.Position =
            UDim2.new(
                0,
                IsCompact
                    and 4
                    or 8,
                1,
                -88
            )

        AccountPopover.Size =
            UDim2.fromOffset(
                math.max(
                    210,
                    Tabs.Size.X.Offset
                        - (
                            IsCompact
                            and 8
                            or 16
                        )
                ),
                132
            )

        UpdateAccountDock()
    end

    function Window:IsSidebarCompacted()
        return IsCompact
    end

    function Window:SetCompact(State)
        Window:SetSidebarWidth(State and WindowInfo.SidebarCompactWidth or LastExpandedWidth)
    end

    function Window:GetSidebarWidth()
        return Tabs.Size.X.Offset
    end

    function Window:SetSidebarWidth(Width)
        Width = math.clamp(
            Width,
            48,
            MainFrame.Size.X.Offset
                - WindowInfo.MinContainerWidth
                - 1
        )

        DividerLine.Position =
            UDim2.fromOffset(
                Width,
                45
            )

        TitleHolder.Size =
            UDim2.new(0, Width, 1, 0)

        RightWrapper.Size =
            UDim2.new(1, -Width - 57 - 1, 1, -16)

        Tabs.Size =
            UDim2.new(0, Width, 1, -132)

        SidebarSurface.Size =
            UDim2.new(0, Width, 1, -66)

        Container.Size =
            UDim2.new(1, -Width - 1, 1, -70)

        if WindowInfo.EnableCompacting then
            ApplyCompact()
        else
            ProfileCard.Size =
                UDim2.new(
                    0,
                    math.max(
                        40,
                        Width - 16
                    ),
                    0,
                    56
                )

            AccountPopover.Size =
                UDim2.fromOffset(
                    math.max(
                        210,
                        Width - 16
                    ),
                    132
                )

            UpdateAccountDock()
        end

        if not IsCompact then
            LastExpandedWidth = Width
        end
    end

    function Window:ShowTabInfo(Name, Description)
        CurrentTabLabel.Text = Name
        CurrentTabDescription.Text = Description

        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(0.5, 1)
        end
        CurrentTabInfo.Visible = true
    end
    function Window:HideTabInfo()

        Window:CloseAccountPopover()

        CurrentTabInfo.Visible = false
        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(1, 1)
        end
    end

    function Window:AddTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
        else
            Name = select(1, ...)
            Icon = select(2, ...)
            Description = select(3, ...)
        end

        local TabButton: TextButton
        local TabLabel
        local TabIcon
        local TabActiveBar

        local TabContainer
        local TabLeft
        local TabRight
        local TabTransitionTween

        Icon = Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                Parent = Tabs,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(
                        0,
                        Library.CornerRadius / 2
                    ),
                    Parent = TabButton,
                })
            )

			
            TabActiveBar = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 7),
                Size = UDim2.new(0, 4, 1, -14),
                ZIndex = TabButton.ZIndex + 1,
                Parent = TabButton,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = TabActiveBar,
                })
            )

            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = TabButton,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,

                FontFace =
                    function()

                        return Library:GetWeightedFont(
                            Enum.FontWeight.Medium
                        )
                    end,

                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextColor3 = "MutedColor",
                TextSize = 16,
                TextTransparency = 0.04,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = TabButton,
            })

            if Icon then
                TabIcon = New("ImageLabel", {
                    Image = Icon.Url,
                    ImageColor3 = Icon.Custom and "WhiteColor" or "MutedColor",
                    ImageRectOffset = Icon.ImageRectOffset,
                    ImageRectSize = Icon.ImageRectSize,
                    ImageTransparency = Icon.Custom and 0.24 or 0.04,
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = TabButton,
                })
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("CanvasGroup", {
                BackgroundTransparency = 1,
                GroupTransparency = 0,
                Position = UDim2.fromOffset(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            TabLeft = New("ScrollingFrame", {
                AutomaticCanvasSize =
                    Enum.AutomaticSize.Y,

                BackgroundTransparency =
                    1,

                CanvasSize =
                    UDim2.fromScale(
                        0,
                        0
                    ),

                ScrollBarImageColor3 =
                    "OutlineColor",

                ScrollBarImageTransparency =
                    0.72,

                ScrollBarThickness =
                    2,

                ScrollingDirection =
                    Enum.ScrollingDirection.Y,

                Size =
                    UDim2.new(
                        0.5,
                        -5,
                        1,
                        0
                    ),

                Parent =
                    TabContainer,
            })

            New("UIListLayout", {
                Padding =
                    UDim.new(
                        0,
                        8
                    ),

                SortOrder =
                    Enum.SortOrder.LayoutOrder,

                Parent =
                    TabLeft,
            })

            New("UIPadding", {
                PaddingBottom =
                    UDim.new(0, 4),

                PaddingLeft =
                    UDim.new(0, 4),

                PaddingRight =
                    UDim.new(0, 4),

                PaddingTop =
                    UDim.new(0, 4),

                Parent =
                    TabLeft,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabLeft,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabLeft,
                })
            end

            TabRight = New("ScrollingFrame", {
                AnchorPoint =
                    Vector2.new(
                        1,
                        0
                    ),

                AutomaticCanvasSize =
                    Enum.AutomaticSize.Y,

                BackgroundTransparency =
                    1,

                CanvasSize =
                    UDim2.fromScale(
                        0,
                        0
                    ),

                Position =
                    UDim2.fromScale(
                        1,
                        0
                    ),

                ScrollBarImageColor3 =
                    "OutlineColor",

                ScrollBarImageTransparency =
                    0.72,

                ScrollBarThickness =
                    2,

                ScrollingDirection =
                    Enum.ScrollingDirection.Y,

                Size =
                    UDim2.new(
                        0.5,
                        -5,
                        1,
                        0
                    ),

                Parent =
                    TabContainer,
            })

            New("UIListLayout", {
                Padding =
                    UDim.new(
                        0,
                        8
                    ),

                SortOrder =
                    Enum.SortOrder.LayoutOrder,

                Parent =
                    TabRight,
            })

            New("UIPadding", {
                PaddingBottom =
                    UDim.new(0, 4),

                PaddingLeft =
                    UDim.new(0, 4),

                PaddingRight =
                    UDim.new(0, 4),

                PaddingTop =
                    UDim.new(0, 4),

                Parent =
                    TabRight,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabRight,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabRight,
                })
            end
        end

        --// Warning Box \\--
        local WarningBoxHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 7),
            Size = UDim2.fromScale(1, 0),
            Visible = false,
            Parent = TabContainer,
        })

        local WarningBox
        local WarningBoxOutline
        local WarningBoxShadowOutline
        local WarningBoxScrollingFrame
        local WarningTitle
        local WarningStroke
        local WarningText
        do
            WarningBox = New("Frame", {
                BackgroundColor3 = "BackgroundColor",
                Position = UDim2.fromOffset(2, 0),
                Size = UDim2.new(1, -5, 0, 0),
                Parent = WarningBoxHolder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = WarningBox,
                })
            )
            WarningBoxOutline, WarningBoxShadowOutline = Library:AddOutline(WarningBox)

            WarningBoxScrollingFrame = New("ScrollingFrame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 3,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Parent = WarningBox,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 4),
                Parent = WarningBoxScrollingFrame,
            })

            WarningTitle = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -4, 0, 14),
                Text = "",
                TextColor3 = Color3.fromRGB(255, 50, 50),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = WarningBoxScrollingFrame,
            })

            WarningStroke = New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = Color3.fromRGB(169, 0, 0),
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningTitle,
            })

            WarningText = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 16),
                Size = UDim2.new(1, -4, 0, 0),
                Text = "",
                TextSize = 14,
                TextWrapped = true,
                Parent = WarningBoxScrollingFrame,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
            })

            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningText,
            })
        end

        --// Tab Table \\--
        local Tab = {
            Name = Name,
            Groupboxes = {},
            Tabboxes = {},
            DependencyGroupboxes = {},
            GroupboxOrder = {
                Left = {},
                Right = {},
            },
            Description = Description,
            Sides = {
                TabLeft,
                TabRight,
            },
            WarningBox = {
                IsNormal = false,
                LockSize = false,
                Visible = false,
                Title = "WARNING",
                Text = "",
            },
        }

        function Tab:UpdateWarningBox(Info)
            if typeof(Info.IsNormal) == "boolean" then
                Tab.WarningBox.IsNormal = Info.IsNormal
            end
            if typeof(Info.LockSize) == "boolean" then
                Tab.WarningBox.LockSize = Info.LockSize
            end
            if typeof(Info.Visible) == "boolean" then
                Tab.WarningBox.Visible = Info.Visible
            end
            if typeof(Info.Title) == "string" then
                Tab.WarningBox.Title = Info.Title
            end
            if typeof(Info.Text) == "string" then
                Tab.WarningBox.Text = Info.Text
            end

            WarningBoxHolder.Visible = Tab.WarningBox.Visible
            WarningTitle.Text = Tab.WarningBox.Title
            WarningText.Text = Tab.WarningBox.Text
            Tab:Resize(true)

            WarningBox.BackgroundColor3 = Tab.WarningBox.IsNormal == true and Library.Scheme.BackgroundColor
                or Color3.fromRGB(127, 0, 0)

            WarningBoxShadowOutline.Color = Tab.WarningBox.IsNormal == true and Library.Scheme.DarkColor
                or Color3.fromRGB(85, 0, 0)
            WarningBoxOutline.Color = Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor
                or Color3.fromRGB(255, 50, 50)

            WarningTitle.TextColor3 = Tab.WarningBox.IsNormal == true and Library.Scheme.FontColor
                or Color3.fromRGB(255, 50, 50)
            WarningStroke.Color = Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor
                or Color3.fromRGB(169, 0, 0)

            if not Library.Registry[WarningBox] then
                Library:AddToRegistry(WarningBox, {})
            end
            if not Library.Registry[WarningBoxShadowOutline] then
                Library:AddToRegistry(WarningBoxShadowOutline, {})
            end
            if not Library.Registry[WarningBoxOutline] then
                Library:AddToRegistry(WarningBoxOutline, {})
            end
            if not Library.Registry[WarningTitle] then
                Library:AddToRegistry(WarningTitle, {})
            end
            if not Library.Registry[WarningStroke] then
                Library:AddToRegistry(WarningStroke, {})
            end

            Library.Registry[WarningBox].BackgroundColor3 = function()
                return Tab.WarningBox.IsNormal == true and Library.Scheme.BackgroundColor or Color3.fromRGB(127, 0, 0)
            end

            Library.Registry[WarningBoxShadowOutline].Color = function()
                return Tab.WarningBox.IsNormal == true and Library.Scheme.DarkColor or Color3.fromRGB(85, 0, 0)
            end

            Library.Registry[WarningBoxOutline].Color = function()
                return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(255, 50, 50)
            end

            Library.Registry[WarningTitle].TextColor3 = function()
                return Tab.WarningBox.IsNormal == true and Library.Scheme.FontColor or Color3.fromRGB(255, 50, 50)
            end

            Library.Registry[WarningStroke].Color = function()
                return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(169, 0, 0)
            end
        end

        function Tab:RefreshSides()

            local TopOffset =
                0

            if Tab.TopBarHolder
            and Tab.TopBarHolder.Visible == true then

                TopOffset =
                    tonumber(Tab.TopBarHeight)
                    or 46
            end

            WarningBoxHolder.Position =
                UDim2.fromOffset(
                    0,
                    TopOffset + 7
                )

            local WarningOffset =
                WarningBoxHolder.Visible
                and WarningBox.Size.Y.Offset + 8
                or 0

            local Offset =
                TopOffset
                + WarningOffset

            for _, Side in Tab.Sides do

                Side.Position =
                    UDim2.new(
                        Side.Position.X.Scale,
                        0,
                        0,
                        Offset
                    )

                Side.Size =
                    UDim2.new(
                        0.5,
                        -3,
                        1,
                        -Offset
                    )
            end
        end

        function Tab:Resize(ResizeWarningBox: boolean?)
            if ResizeWarningBox then
                local MaximumSize = math.floor(TabContainer.AbsoluteSize.Y / 3.25)
                local _, YText = Library:GetTextBounds(
                    WarningText.Text,
                    Library.Scheme.Font,
                    WarningText.TextSize,
                    WarningText.AbsoluteSize.X
                )

                local YBox = 24 + YText
                if Tab.WarningBox.LockSize == true and YBox >= MaximumSize then
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, YBox)
                    YBox = MaximumSize
                else
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
                end

                WarningText.Size = UDim2.new(1, -4, 0, YText)
                WarningBox.Size = UDim2.new(1, -5, 0, YBox + 4)
            end

            Tab:RefreshSides()
        end

        function Tab:AddTopSegmentedControl(Info)

            Info =
                Info
                or {}

            local Values =
                type(Info.Values) == "table"
                and Info.Values
                or {
                    "Buy",
                    "Sell",
                }

            local Default =
                tostring(
                    Info.Default
                    or Values[1]
                    or ""
                )

            local Callback =
                Info.Callback
                or Info.Func

            local Width =
                math.clamp(
                    tonumber(Info.Width)
                    or 340,
                    220,
                    460
                )

            local Height =
                math.clamp(
                    tonumber(Info.Height)
                    or 46,
                    38,
                    64
                )

            local PillHeight =
                math.clamp(
                    tonumber(Info.PillHeight)
                    or 32,
                    28,
                    42
                )

            Tab.TopBarHeight =
                Height

            if Tab.TopBarHolder
            and Tab.TopBarHolder.Parent then

                pcall(function()

                    Tab.TopBarHolder:Destroy()
                end)
            end

            local TopHolder =
                New("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(0, 0),
                    Size = UDim2.new(1, 0, 0, Height),
                    Parent = TabContainer,
                })

            local Pill =
                New(
                    "Frame",
                    {
                        AnchorPoint =
                            Vector2.new(
                                0.5,
                                0
                            ),

                        BackgroundColor3 =
                            "MainColor",

                        BackgroundTransparency =
                            0.04,

                        Position =
                            UDim2.new(
                                0.5,
                                0,
                                0,
                                6
                            ),

                        Size =
                            UDim2.fromOffset(
                                Width,
                                PillHeight
                            ),

                        Parent =
                            TopHolder,
                    }
                )

            table.insert(
                Library.Corners,
                New(
                    "UICorner",
                    {
                        CornerRadius =
                            UDim.new(
                                0,
                                4
                            ),

                        Parent =
                            Pill,
                    }
                )
            )

            Library:RegisterSurface(
                Pill,
                "Panel",
                0.04
            )

            Library:AddOutline(
                Pill
            )

            local ButtonHolder =
                New("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(3, 3),
                    Size = UDim2.new(1, -6, 1, -6),
                    Parent = Pill,
                })

            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                Padding = UDim.new(0, 2),
                Parent = ButtonHolder,
            })

            local Segmented = {
                Value = Default,
                Buttons = {},
                Holder = TopHolder,
                Pill = Pill,
                Type = "TopSegmentedControl",
            }

            local function createButton(value)

                value =
                    tostring(
                        value
                        or ""
                    )

                local Button =
                    New(
                        "TextButton",
                        {
                            BackgroundColor3 =
                                "MainColor",

                            BackgroundTransparency =
                                1,

                            Size =
                                UDim2.fromScale(
                                    1,
                                    1
                                ),

                            Text =
                                value,

                            TextSize =
                                14,

                            TextTransparency =
                                0.22,

                            Parent =
                                ButtonHolder,
                        }
                    )

                table.insert(
                    Library.Corners,
                    New(
                        "UICorner",
                        {
                            CornerRadius =
                                UDim.new(
                                    0,
                                    3
                                ),

                            Parent =
                                Button,
                        }
                    )
                )

                Library:RegisterSurface(
                    Button,
                    "Control",
                    1
                )

                local Stroke =
                    New(
                        "UIStroke",
                        {
                            Color =
                                "OutlineColor",

                            Transparency =
                                1,

                            Parent =
                                Button,
                        }
                    )

                local Underline =
                    New(
                        "Frame",
                        {
                            AnchorPoint =
                                Vector2.new(
                                    0.5,
                                    1
                                ),

                            BackgroundColor3 =
                                "AccentColor",

                            BackgroundTransparency =
                                1,

                            Position =
                                UDim2.new(
                                    0.5,
                                    0,
                                    1,
                                    0
                                ),

                            Size =
                                UDim2.new(
                                    0,
                                    0,
                                    0,
                                    2
                                ),

                            ZIndex =
                                Button.ZIndex + 2,

                            Parent =
                                Button,
                        }
                    )

                local Entry = {
                    Value =
                        value,

                    Button =
                        Button,

                    Stroke =
                        Stroke,

                    Underline =
                        Underline,

                    Hovering =
                        false,
                }

                Button.MouseEnter:Connect(function()

                    Entry.Hovering =
                        true

                    Segmented:Display()
                end)

                Button.MouseLeave:Connect(function()

                    Entry.Hovering =
                        false

                    Segmented:Display()
                end)

                Button.MouseButton1Click:Connect(function()

                    Segmented:SetValue(
                        value
                    )
                end)

                table.insert(
                    Segmented.Buttons,
                    Entry
                )

                return Entry
            end

            for _, value in ipairs(Values) do

                createButton(
                    value
                )
            end

            function Segmented:Display()

                for _, entry in ipairs(
                    Segmented.Buttons
                ) do

                    local selected =
                        entry.Value
                        == Segmented.Value

                    local hovering =
                        entry.Hovering == true
                        and selected ~= true

                    local selectedBackground =
                        function()

                            return Library:GetBetterColor(
                                Library.Scheme.MainColor,
                                5
                            )
                        end

                    local backgroundTransparency =
                        selected
                        and 0.04
                        or hovering
                        and 0.24
                        or 1

                    entry.Button.BackgroundColor3 =
                        selected
                        and selectedBackground()
                        or Library.Scheme.MainColor

                    entry.Button.TextTransparency =
                        selected
                        and 0
                        or hovering
                        and 0.08
                        or 0.22

                    entry.Stroke.Color =
                        selected
                        and Library.Scheme.InnerBorderColor
                        or Library.Scheme.OutlineColor

                    entry.Stroke.Transparency =
                        selected
                        and 0
                        or hovering
                        and 0.22
                        or 1

                    entry.Underline.BackgroundTransparency =
                        selected
                        and 0
                        or 1

                    entry.Underline.Size =
                        selected
                        and UDim2.new(
                            1,
                            -18,
                            0,
                            2
                        )
                        or UDim2.new(
                            0,
                            0,
                            0,
                            2
                        )

                    Library.Registry[
                        entry.Button
                    ].BackgroundColor3 =
                        selected
                        and selectedBackground
                        or "MainColor"

                    Library.Registry[
                        entry.Stroke
                    ].Color =
                        selected
                        and "InnerBorderColor"
                        or "OutlineColor"

                    Library.Registry[
                        entry.Underline
                    ].BackgroundColor3 =
                        "AccentColor"

                    local surface =
                        Library.SurfaceRegistry[
                            entry.Button
                        ]

                    if type(surface) == "table" then

                        surface.BaseTransparency =
                            backgroundTransparency

                        Library:ApplyTransparencyToSurface(
                            entry.Button
                        )

                    else

                        entry.Button.BackgroundTransparency =
                            backgroundTransparency
                    end
                end
            end

            function Segmented:SetValue(value, silent)

                value =
                    tostring(value or "")

                local valid =
                    false

                for _, entry in ipairs(Segmented.Buttons) do

                    if entry.Value == value then

                        valid =
                            true

                        break
                    end
                end

                if valid ~= true then
                    return
                end

                Segmented.Value =
                    value

                Segmented:Display()

                if silent ~= true
                and type(Callback) == "function" then

                    Library:SafeCallback(
                        Callback,
                        value,
                        Segmented
                    )
                end
            end

            function Segmented:SetVisible(visible)

                TopHolder.Visible =
                    visible == true

                Tab:RefreshSides()
            end

            function Segmented:Destroy()

                if TopHolder then

                    TopHolder:Destroy()
                end

                if Tab.TopBarHolder == TopHolder then

                    Tab.TopBarHolder =
                        nil

                    Tab.TopBarHeight =
                        0
                end

                Tab:RefreshSides()
            end

            Tab.TopBarHolder =
                TopHolder

            Tab.TopBar =
                Segmented

            Segmented:SetValue(
                Default,
                true
            )

            Tab:RefreshSides()

            return Segmented
        end

        function Tab:AddTopNavigation(Info)

            Info =
                Info
                or {}

            local RawItems =
                type(Info.Items) == "table"
                and Info.Items
                or {
                    {
                        Key = "Collect",
                        Text = "🎯 Collect",
                        AccentColor = Color3.fromRGB(255, 70, 88),
                    },

                    {
                        Key = "Plant",
                        Text = "🌱 Plant",
                        AccentColor = Color3.fromRGB(94, 255, 120),
                    },

                    {
                        Key = "Tools",
                        Text = "🛠️ Tools",
                        AccentColor = Color3.fromRGB(86, 160, 255),
                    },

                    {
                        Key = "Extra",
                        Text = "⭐ Extra",
                        AccentColor = Color3.fromRGB(255, 216, 74),
                    },
                }

            local Items =
                {}

            local function readItem(raw)

                if type(raw) == "table" then

                    local key =
                        tostring(
                            raw.Key
                            or raw.Value
                            or raw.Name
                            or raw.Text
                            or ""
                        )

                    local text =
                        tostring(
                            raw.Text
                            or raw.Name
                            or raw.Key
                            or raw.Value
                            or ""
                        )

                    local accent =
                        typeof(raw.AccentColor) == "Color3"
                        and raw.AccentColor
                        or typeof(raw.Color) == "Color3"
                        and raw.Color
                        or Library.Scheme.AccentColor

                    if key ~= "" then

                        table.insert(
                            Items,
                            {
                                Key =
                                    key,

                                Text =
                                    text ~= ""
                                    and text
                                    or key,

                                AccentColor =
                                    accent,
                            }
                        )
                    end

                    return
                end

                local text =
                    tostring(raw or "")

                if text ~= "" then

                    table.insert(
                        Items,
                        {
                            Key =
                                text,

                            Text =
                                text,

                            AccentColor =
                                Library.Scheme.AccentColor,
                        }
                    )
                end
            end

            for _, raw in ipairs(RawItems) do

                readItem(
                    raw
                )
            end

            if #Items <= 0 then

                table.insert(
                    Items,
                    {
                        Key =
                            "Collect",

                        Text =
                            "🎯 Collect",

                        AccentColor =
                            Library.Scheme.AccentColor,
                    }
                )
            end

            local Callback =
                Info.Callback
                or Info.Func

            local Height =
                math.clamp(
                    tonumber(Info.Height)
                    or 58,
                    46,
                    78
                )

            local BarHeight =
                math.clamp(
                    tonumber(Info.BarHeight)
                    or 42,
                    34,
                    54
                )

            local PaddingX =
                math.clamp(
                    tonumber(Info.PaddingX)
                    or 8,
                    4,
                    18
                )

            local ButtonGap =
                math.clamp(
                    tonumber(Info.ButtonGap)
                    or 7,
                    3,
                    12
                )

            local Default =
                tostring(
                    Info.Default
                    or Items[1].Key
                )

            local function isValidValue(value)

                value =
                    tostring(value or "")

                for _, item in ipairs(Items) do

                    if item.Key == value then
                        return true
                    end
                end

                return false
            end

            if isValidValue(Default) ~= true then

                Default =
                    Items[1].Key
            end

            local function blendColor(a, b, t)

                t =
                    math.clamp(
                        tonumber(t)
                        or 0,
                        0,
                        1
                    )

                return Color3.new(
                    a.R + (b.R - a.R) * t,
                    a.G + (b.G - a.G) * t,
                    a.B + (b.B - a.B) * t
                )
            end

            Tab.TopBarHeight =
                Height

            if Tab.TopBarHolder
            and Tab.TopBarHolder.Parent then

                pcall(function()

                    Tab.TopBarHolder:Destroy()
                end)
            end

            local TopHolder =
                New("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(0, 0),
                    Size = UDim2.new(1, 0, 0, Height),
                    Parent = TabContainer,
                })

            local NavBar =
                New(
                    "Frame",
                    {
                        BackgroundColor3 =
                            "MainColor",

                        BackgroundTransparency =
                            0.04,

                        Position =
                            UDim2.new(
                                0,
                                PaddingX,
                                0,
                                6
                            ),

                        Size =
                            UDim2.new(
                                1,
                                -PaddingX * 2,
                                0,
                                BarHeight
                            ),

                        Parent =
                            TopHolder,
                    }
                )

            table.insert(
                Library.Corners,
                New(
                    "UICorner",
                    {
                        CornerRadius =
                            UDim.new(
                                0,
                                6
                            ),

                        Parent =
                            NavBar,
                    }
                )
            )

            Library:RegisterSurface(
                NavBar,
                "Panel",
                0.04
            )

            Library:AddOutline(
                NavBar
            )

            local ButtonHolder =
                New("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(4, 4),
                    Size = UDim2.new(1, -8, 1, -8),
                    Parent = NavBar,
                })

            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                Padding = UDim.new(0, ButtonGap),
                Parent = ButtonHolder,
            })

            local Navigation = {
                Value = Default,
                Buttons = {},
                ButtonMap = {},
                Holder = TopHolder,
                NavBar = NavBar,
                Type = "TopNavigation",
            }

            local function applyButtonVisual(
                entry,
                selected,
                hovering
            )

                local accent =
                    Library.Scheme.AccentColor

                local baseColor =
                    Library.Scheme.MainColor

                local backgroundColor =
                    selected
                    and blendColor(
                        baseColor,
                        accent,
                        0.10
                    )
                    or hovering
                    and blendColor(
                        baseColor,
                        accent,
                        0.05
                    )
                    or baseColor

                local backgroundTransparency =
                    selected
                    and 0.06
                    or hovering
                    and 0.24
                    or 0.62

                entry.Button.BackgroundColor3 =
                    backgroundColor

                entry.Button.TextTransparency =
                    selected
                    and 0
                    or hovering
                    and 0.08
                    or 0.22

                entry.Stroke.Color =
                    selected
                    and Library.Scheme.InnerBorderColor
                    or Library.Scheme.OutlineColor

                entry.Stroke.Transparency =
                    selected
                    and 0
                    or hovering
                    and 0.20
                    or 0.62

                entry.Underline.BackgroundColor3 =
                    accent

                entry.Underline.BackgroundTransparency =
                    selected
                    and 0
                    or 1

                entry.Underline.Size =
                    selected
                    and UDim2.new(
                        1,
                        -18,
                        0,
                        2
                    )
                    or UDim2.new(
                        0,
                        0,
                        0,
                        2
                    )

                entry.Glow.BackgroundTransparency =
                    1

                Library.Registry[
                    entry.Button
                ] =
                    Library.Registry[
                        entry.Button
                    ]
                    or {}

                Library.Registry[
                    entry.Stroke
                ] =
                    Library.Registry[
                        entry.Stroke
                    ]
                    or {}

                Library.Registry[
                    entry.Underline
                ] =
                    Library.Registry[
                        entry.Underline
                    ]
                    or {}

                Library.Registry[
                    entry.Button
                ].BackgroundColor3 =
                    function()

                        local currentAccent =
                            Library.Scheme.AccentColor

                        if entry.Key
                            == Navigation.Value then

                            return blendColor(
                                Library.Scheme.MainColor,
                                currentAccent,
                                0.10
                            )
                        end

                        return Library.Scheme.MainColor
                    end

                Library.Registry[
                    entry.Button
                ].TextColor3 =
                    "FontColor"

                Library.Registry[
                    entry.Stroke
                ].Color =
                    selected
                    and "InnerBorderColor"
                    or "OutlineColor"

                Library.Registry[
                    entry.Underline
                ].BackgroundColor3 =
                    "AccentColor"

                local surface =
                    Library.SurfaceRegistry[
                        entry.Button
                    ]

                if type(surface) == "table" then

                    surface.BaseTransparency =
                        backgroundTransparency

                    Library:ApplyTransparencyToSurface(
                        entry.Button
                    )

                else

                    entry.Button.BackgroundTransparency =
                        backgroundTransparency
                end
            end

            local function createButton(item)

                local Button =
                    New("TextButton", {
                        BackgroundColor3 = "MainColor",
                        BackgroundTransparency = 0.62,
                        Size = UDim2.fromScale(1, 1),
                        Text = item.Text,
                        TextSize = 14,
                        TextTransparency = 0.22,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = ButtonHolder,
                    })

                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius =
                            UDim.new(
                                0,
                                3
                            ),
                        Parent = Button,
                    })
                )

                Library:RegisterSurface(
                    Button,
                    "Control",
                    0.62
                )

                local Stroke =
                    New("UIStroke", {
                        Color = "OutlineColor",
                        Transparency = 0.58,
                        Thickness = 1,
                        Parent = Button,
                    })

                local Glow =
                    New("Frame", {
                        BackgroundColor3 = item.AccentColor,
                        BackgroundTransparency = 1,
                        Position = UDim2.fromOffset(0, 0),
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = Button.ZIndex - 1,
                        Parent = Button,
                    })

                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius =
                            UDim.new(
                                0,
                                3
                            ),
                        Parent = Glow,
                    })
                )

                local Underline =
                    New("Frame", {
                        AnchorPoint = Vector2.new(0.5, 1),
                        BackgroundColor3 = item.AccentColor,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 1, -2),
                        Size = UDim2.new(0, 0, 0, 2),
                        ZIndex = Button.ZIndex + 2,
                        Parent = Button,
                    })

                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = Underline,
                    })
                )

                local Entry = {
                    Key = item.Key,
                    Text = item.Text,
                    AccentColor = item.AccentColor,
                    Button = Button,
                    Stroke = Stroke,
                    Underline = Underline,
                    Glow = Glow,
                    Hovering = false,
                }

                Button.MouseEnter:Connect(function()

                    Entry.Hovering =
                        true

                    Navigation:Display()
                end)

                Button.MouseLeave:Connect(function()

                    Entry.Hovering =
                        false

                    Navigation:Display()
                end)

                Button.MouseButton1Click:Connect(function()

                    Navigation:SetValue(
                        Entry.Key
                    )
                end)

                table.insert(
                    Navigation.Buttons,
                    Entry
                )

                Navigation.ButtonMap[Entry.Key] =
                    Entry

                return Entry
            end

            for _, item in ipairs(Items) do

                createButton(
                    item
                )
            end

            function Navigation:Display()

                for _, entry in ipairs(Navigation.Buttons) do

                    applyButtonVisual(
                        entry,
                        entry.Key == Navigation.Value,
                        entry.Hovering == true
                    )
                end
            end

            function Navigation:SetValue(value, silent)

                value =
                    tostring(value or "")

                if isValidValue(value) ~= true then
                    return false
                end

                Navigation.Value =
                    value

                Navigation:Display()

                if silent ~= true
                and type(Callback) == "function" then

                    Library:SafeCallback(
                        Callback,
                        value,
                        Navigation
                    )
                end

                return true
            end

            function Navigation:GetValue()

                return Navigation.Value
            end

            function Navigation:SetVisible(visible)

                TopHolder.Visible =
                    visible == true

                Tab:RefreshSides()
            end

            function Navigation:Destroy()

                if TopHolder then

                    TopHolder:Destroy()
                end

                if Tab.TopBarHolder == TopHolder then

                    Tab.TopBarHolder =
                        nil

                    Tab.TopBarHeight =
                        0
                end

                Tab:RefreshSides()
            end

            Tab.TopBarHolder =
                TopHolder

            Tab.TopBar =
                Navigation

            Navigation:SetValue(
                Default,
                true
            )

            Tab:RefreshSides()

            return Navigation
        end


        local AddTabbox

        function Tab:AddGroupbox(Info)
            local SideName =
                Info.Side == 1
                and "Left"
                or "Right"

            Tab.GroupboxOrder =
                Tab.GroupboxOrder
                or {
                    Left = {},
                    Right = {},
                }

            Tab.GroupboxOrder[SideName] =
                Tab.GroupboxOrder[SideName]
                or {}

            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = Info.Side == 1 and TabLeft or TabRight,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local GroupboxHolder
			local GroupboxLabel
			local GroupboxHeaderButton
			local GroupboxCollapseArrow

			local GroupboxContainer
			local GroupboxList

            do
                GroupboxHolder =
                    New(
                        "Frame",
                        {
                            BackgroundColor3 =
                                "MainColor",

                            BackgroundTransparency =
                                0,

                            ClipsDescendants =
                                Info.Collapsible == true,

                            Size =
                                UDim2.fromScale(
                                    1,
                                    0
                                ),

                            Parent =
                                BoxHolder,
                        }
                    )

                table.insert(
                    Library.Corners,
                    New(
                        "UICorner",
                        {
                            CornerRadius =
                                UDim.new(
                                    0,
                                    math.max(
                                        7,
                                        WindowInfo.CornerRadius + 1
                                    )
                                ),

                            Parent =
                                GroupboxHolder,
                        }
                    )
                )

                Library:RegisterSurface(
                    GroupboxHolder,
                    "Groupbox",
                    0
                )

                Library:AddOutline(
                    GroupboxHolder
                )

                local BoxIcon = Library:GetCustomIcon(Info.IconName)
                if BoxIcon then
                    New("ImageLabel", {
                        Image = BoxIcon.Url,
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        ImageRectOffset = BoxIcon.ImageRectOffset,
                        ImageRectSize = BoxIcon.ImageRectSize,
                        ImageTransparency = 0.04,
                        Position = UDim2.fromOffset(9, 6),
                        Size = UDim2.fromOffset(17, 17),
                        Parent = GroupboxHolder,
                    })
                end

                GroupboxLabel = New("TextLabel", {
                    BackgroundTransparency = 1,

                    FontFace =
                        function()

                            return Library:GetWeightedFont(
                                Enum.FontWeight.SemiBold
                            )
                        end,

                    Position = UDim2.fromOffset(BoxIcon and 27 or 0, 0),
                    Size = UDim2.new(1, 0, 0, 29),
                    Text = Info.Name,
                    TextSize = 14,
                    TextTransparency = 0.03,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = GroupboxHolder,
                })
                New("UIPadding", {
                    PaddingLeft = UDim.new(0, 11),
                    PaddingRight = UDim.new(0, 11),
                    Parent = GroupboxLabel,
                })

                GroupboxHeaderButton = New("TextButton", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(0, 0),
                    Size = UDim2.new(1, 0, 0, 29),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = GroupboxLabel.ZIndex + 1,
                    Parent = GroupboxHolder,
                })

				if Info.Collapsible == true then

                    GroupboxCollapseArrow = New("ImageLabel", {
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundTransparency = 1,

                        Image =
                            ArrowIcon
                            and ArrowIcon.Url
                            or "",

                        ImageColor3 = ArrowIcon
                            and (
                                ArrowIcon.Custom
                                and "WhiteColor"
                                or "AccentColor"
                            )
                            or "FontColor",

                        ImageRectOffset = ArrowIcon
                            and ArrowIcon.ImageRectOffset
                            or Vector2.zero,

                        ImageRectSize = ArrowIcon
                            and ArrowIcon.ImageRectSize
                            or Vector2.zero,

                        ImageTransparency = 0.32,
                        Position = UDim2.new(1, -10, 0, 14),
                        Rotation = 180,
                        Size = UDim2.fromOffset(14, 14),
                        ZIndex = GroupboxHeaderButton.ZIndex + 1,
                        Parent = GroupboxHeaderButton,
                    })
                end

                GroupboxContainer = New("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(0, 29),
                    Size = UDim2.new(1, 0, 1, -29),
                    Parent = GroupboxHolder,
                })

                GroupboxList = New("UIListLayout", {
                    Padding = UDim.new(0, 7),
                    Parent = GroupboxContainer,
                })

                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 8),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    PaddingTop = UDim.new(0, 6),
                    Parent = GroupboxContainer,
                })
            end

            local Groupbox = {
    Type = "Groupbox",
    Name = tostring(Info.Name or "Groupbox"),
    SideName = SideName,
    CreatedOrder = #Tab.GroupboxOrder[SideName] + 1,

    BoxHolder = BoxHolder,
    Holder = GroupboxHolder,
    HeaderButton = GroupboxHeaderButton,
    CollapseArrow = GroupboxCollapseArrow,
    Container = GroupboxContainer,

    Tab = Tab,
    DependencyBoxes = {},
    Elements = {},

    Collapsible = Info.Collapsible == true,
    Collapsed = Info.Collapsed == true,

    __ReorderEnabled = false,
    __DraggingMoved = false,
}

            function Groupbox:Resize()

    if Groupbox.Collapsible
    and Groupbox.Collapsed then

        GroupboxContainer.Visible = false

        GroupboxHolder.Size =
            UDim2.new(
                1,
                0,
                0,
                30
            )

        if GroupboxCollapseArrow then
            TweenService:Create(
                GroupboxCollapseArrow,
                Library.TweenInfo,
                {
                    ImageTransparency = 0.2,
                    Rotation = 90,
                }
            ):Play()
        end

        return
    end

    GroupboxContainer.Visible = true

    GroupboxHolder.Size =
        UDim2.new(
            1,
            0,
            0,
            (GroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 43
        )

    if GroupboxCollapseArrow then
        TweenService:Create(
            GroupboxCollapseArrow,
            Library.TweenInfo,
            {
                ImageTransparency = 0.32,
                Rotation = 180,
            }
        ):Play()
    end
end

function Groupbox:SetCollapsed(State)

    if not Groupbox.Collapsible then
        return
    end

    Groupbox.Collapsed =
        State == true

    Groupbox:Resize()

    if Tab
    and type(Tab.RefreshSides) == "function" then
        task.defer(function()

            if Tab
            and type(Tab.RefreshSides) == "function" then
                Tab:RefreshSides()
            end
        end)
    end
end

function Groupbox:ToggleCollapsed()

    Groupbox:SetCollapsed(
        not Groupbox.Collapsed
    )
end

if GroupboxHeaderButton then

    GroupboxHeaderButton.MouseButton1Click:Connect(function()

        if Groupbox.__DraggingMoved == true then
            Groupbox.__DraggingMoved =
                false

            return
        end

        if not Groupbox.Collapsible then
            return
        end

        Groupbox:ToggleCollapsed()
    end)
end

            Groupbox.AddTabbox = AddTabbox

            setmetatable(Groupbox, BaseGroupbox)

            Groupbox:Resize()

            Tab.Groupboxes[Info.Name] =
                Groupbox

            table.insert(
                Tab.GroupboxOrder[SideName],
                Groupbox
            )

            if type(Library.EnableGroupboxReorder) == "function" then
                Library:EnableGroupboxReorder(
                    Groupbox
                )
            end

            if type(Library.RefreshGroupboxOrder) == "function" then
                Library:RefreshGroupboxOrder(
                    Tab,
                    SideName
                )
            end

            return Groupbox
        end

        function Tab:AddLeftGroupbox(Name, IconName)
            return Tab:AddGroupbox({ Side = 1, Name = Name, IconName = IconName })
        end

        function Tab:AddRightGroupbox(Name, IconName)
            return Tab:AddGroupbox({ Side = 2, Name = Name, IconName = IconName })
        end

		function Tab:AddLeftCollapsibleGroupbox(Name, IconName, DefaultOpen)

    return Tab:AddGroupbox({
        Side = 1,
        Name = Name,
        IconName = IconName,
        Collapsible = true,
        Collapsed = DefaultOpen == false,
    })
end

function Tab:AddRightCollapsibleGroupbox(Name, IconName, DefaultOpen)

    return Tab:AddGroupbox({
        Side = 2,
        Name = Name,
        IconName = IconName,
        Collapsible = true,
        Collapsed = DefaultOpen == false,
    })
end

        AddTabbox = function(self, Info)
            Info = Info or {}

            local ParentObj = self

            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = if ParentObj.Type == "Groupbox"
                    then ParentObj.Container
                    else (Info.Side == 1 and TabLeft or TabRight),
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local TabboxHolder
            local TabboxButtons

            do
                TabboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = TabboxHolder,
                    })
                )
                Library:AddOutline(TabboxHolder)

                TabboxButtons = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    Parent = TabboxHolder,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Parent = TabboxButtons,
                })
            end

            local TotalButtons, TotalTabs = 0, 1
            local Tabbox = {
                ActiveTab = nil,

                BoxHolder = BoxHolder,
                Holder = TabboxHolder,
                Tabs = {}
            }

            function Tabbox:UpdateCorners()
                for _, Tab in Tabbox.Tabs do
                    Tab:UpdateCorners()
                end
            end

            function Tabbox:AddTab(Name, IconName)
                local TabIndex = TotalTabs

                TotalButtons = TotalButtons + 1
                TotalTabs = TotalTabs + 1

                local BoxIcon = Library:GetCustomIcon(IconName)

                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 0,
                    Size = UDim2.fromOffset(0, 34),
                    Text = "",
                    Parent = TabboxButtons,
                })

                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = Button,
                    })
                )

                local BottomCover = New("Frame", {
                    Name = "BottomCover",
                    BackgroundColor3 = "MainColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, -WindowInfo.CornerRadius),
                    Size = UDim2.new(1, 0, 0, WindowInfo.CornerRadius),
                    Parent = Button,
                })

                local LeftCover = New("Frame", {
                    Name = "LeftCover",
                    BackgroundColor3 = "MainColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0, WindowInfo.CornerRadius, 1, 0),
                    Visible = false,
                    Parent = Button,
                })

                local RightCover = New("Frame", {
                    Name = "RightCover",
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundColor3 = "MainColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0, WindowInfo.CornerRadius, 1, 0),
                    Visible = false,
                    Parent = Button,
                })

                local ButtonContent = New("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(0, 16),
                    Parent = Button,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 8),
                    Parent = ButtonContent,
                })

                local ButtonIcon
                if BoxIcon then
                    ButtonIcon = New("ImageLabel", {
                        Image = BoxIcon.Url,
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        ImageRectOffset = BoxIcon.ImageRectOffset,
                        ImageRectSize = BoxIcon.ImageRectSize,
                        ImageTransparency = 0.5,
                        Size = UDim2.fromOffset(16, 16),
                        Parent = ButtonContent,
                    })
                end

                local ButtonLabel = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(0, 16),
                    Text = Name,
                    TextSize = 15,
                    TextTransparency = 0.5,
                    Parent = ButtonContent,
                })

                local Line = Library:MakeLine(Button, {
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 1),
                    Size = UDim2.new(1, 0, 0, 1),
                })

                local Container = New("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(0, 35),
                    Size = UDim2.new(1, 0, 1, -35),
                    Visible = false,
                    Parent = TabboxHolder,
                })
                local List = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    Parent = Container,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 7),
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 7),
                    Parent = Container,
                })

                local Tab = {
                    ButtonHolder = Button,
                    Container = Container,

                    ButtonCovers = {
                        BottomCover = BottomCover,
                        LeftCover = LeftCover,
                        RightCover = RightCover
                    },

                    Tab = Tab,
                    Elements = {},
                    DependencyBoxes = {},
                }

                function Tab:Show()
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Hide()
                    end

                    Button.BackgroundTransparency = 1
                    ButtonLabel.TextTransparency = 0

                    if ButtonIcon then
                        ButtonIcon.ImageTransparency = 0
                    end

                    Line.Visible = false
                    Container.Visible = true

                    Tabbox.ActiveTab = Tab
                    Tab:Resize()
                end

                function Tab:Hide()
                    Button.BackgroundTransparency = 0
                    ButtonLabel.TextTransparency = 0.5

                    if ButtonIcon then
                        ButtonIcon.ImageTransparency = 0.5
                    end

                    Line.Visible = true
                    Container.Visible = false

                    Tabbox.ActiveTab = nil
                end

                function Tab:Resize()
                    if Tabbox.ActiveTab ~= Tab then
                        return
                    end

                    TabboxHolder.Size = UDim2.new(1, 0, 0, (List.AbsoluteContentSize.Y / Library.DPIScale) + 49)

                    if ParentObj.Type == "Groupbox" then
                        ParentObj:Resize()
                    end
                end

                function Tab:UpdateCorners()
                    LeftCover.Visible = TabIndex ~= 1
                    RightCover.Visible = TabIndex ~= TotalButtons
        
                    BottomCover.Position = UDim2.new(0, 0, 1, -WindowInfo.CornerRadius)
                    BottomCover.Size = UDim2.new(1, 0, 0, WindowInfo.CornerRadius)
        
                    LeftCover.Size = UDim2.new(0, WindowInfo.CornerRadius, 1, 0)
                    RightCover.Size = UDim2.new(0, WindowInfo.CornerRadius, 1, 0)
                end

                --// Execution \\--
                if not Tabbox.ActiveTab then
                    Tab:Show()
                end

                Button.MouseButton1Click:Connect(Tab.Show)

                setmetatable(Tab, BaseGroupbox)

                Tabbox.Tabs[Name] = Tab
                Tabbox:UpdateCorners()

                return Tab
            end

            if Info.Name then
                Tab.Tabboxes[Info.Name] = Tabbox
            else
                table.insert(Tab.Tabboxes, Tabbox)
            end

            return Tabbox
        end

        Tab.AddTabbox = AddTabbox

        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Side = 1, Name = Name })
        end

        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Side = 2, Name = Name })
        end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = Hovering and 0.68 or 1,
            }):Play()

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextColor3 = Hovering
                    and Library.Scheme.FontColor
                    or Library.Scheme.MutedColor,

                TextTransparency = Hovering and 0 or 0.04,
            }):Play()

            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageColor3 = Icon.Custom
                        and Library.Scheme.WhiteColor
                        or Hovering
                        and Library.Scheme.FontColor
                        or Library.Scheme.MutedColor,

                    ImageTransparency = Icon.Custom
                        and (Hovering and 0.08 or 0.24)
                        or 0.04,
                }):Play()
            end
        end

        function Tab:Show()
            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0.12,
            }):Play()

            TweenService:Create(TabActiveBar, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()

            Library:SetTextWeight(
                TabLabel,
                Enum.FontWeight.SemiBold
            )

            Library.Registry[TabLabel].TextColor3 =
                "FontColor"

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextColor3 = Library.Scheme.FontColor,
                TextTransparency = 0,
            }):Play()

            if TabIcon then
                local ActiveIconColor =
                    Icon.Custom
                    and Library.Scheme.WhiteColor
                    or Library.Scheme.AccentColor

                Library.Registry[TabIcon].ImageColor3 =
                    Icon.Custom
                    and "WhiteColor"
                    or "AccentColor"

                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageColor3 = ActiveIconColor,
                    ImageTransparency = 0,
                }):Play()
            end

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            TabContainer.Visible = true
            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()

            TweenService:Create(TabActiveBar, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()

            Library:SetTextWeight(
                TabLabel,
                Enum.FontWeight.Medium
            )

            Library.Registry[TabLabel].TextColor3 =
                "MutedColor"

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextColor3 = Library.Scheme.MutedColor,
                TextTransparency = 0.04,
            }):Play()

            if TabIcon then
                local InactiveIconColor =
                    Icon.Custom
                    and Library.Scheme.WhiteColor
                    or Library.Scheme.MutedColor

                Library.Registry[TabIcon].ImageColor3 =
                    Icon.Custom
                    and "WhiteColor"
                    or "MutedColor"

                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageColor3 = InactiveIconColor,
                    ImageTransparency = Icon.Custom and 0.24 or 0.04,
                }):Play()
            end

            TabContainer.Visible = false

            Window:HideTabInfo()

            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            TabButton.Visible = Visible

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        --// Execution \\--
        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(Tab.Show)

        Library.Tabs[Name] = Tab

        return Tab
    end

    function Window:AddKeyTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
        else
            Name = select(1, ...) or "Tab"
            Icon = select(2, ...)
            Description = select(3, ...)
        end

        Icon = Icon or "key"

        local TabButton: TextButton
        local TabLabel
        local TabIcon

        local TabContainer

        Icon = if Icon == "key" then KeyIcon else Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                Parent = Tabs,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(
                        0,
                        Library.CornerRadius / 2
                    ),
                    Parent = TabButton,
                })
            )
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = TabButton,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 16,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = TabButton,
            })

            if Icon then
                TabIcon = New("ImageLabel", {
                    Image = Icon.Url,
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageRectOffset = Icon.ImageRectOffset,
                    ImageRectSize = Icon.ImageRectSize,
                    ImageTransparency = 0.5,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = TabButton,
                })
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarThickness = 0,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })
            New("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = TabContainer,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 1),
                Parent = TabContainer,
            })
        end

        --// Tab Table \\--
        local Tab = {
            Elements = {},
            Description = Description,
            IsKeyTab = true,
        }

        function Tab:AddKeyBox(Callback)
            assert(typeof(Callback) == "function", "Callback must be a function")

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            Parent = Container,
        })

            local Box = New("TextBox", {
                BackgroundColor3 = "MainColor",
                PlaceholderText = "Key",
                Size = UDim2.new(1, -71, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = Box,
            })
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Box,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Box,
                })
            )

            local Button = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0, 63, 1, 0),
                Text = "Execute",
                TextSize = 14,
                Parent = Holder,
            })
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Button,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
            )

            Button.InputBegan:Connect(function(Input)
                if not IsClickInput(Input) then
                    return
                end

                if not Library:MouseIsOverFrame(Button, Input.Position) then
                    return
                end

                Callback(Box.Text)
            end)
        end

        function Tab:RefreshSides() end
        function Tab:Resize() end
        function Tab:UpdateCorners() end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = Hovering and 0.25 or 0.5,
                }):Play()
            end
        end

        function Tab:Show()
            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end
            TabContainer.Visible = true

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0.5,
                }):Play()
            end
            TabContainer.Visible = false

            Window:HideTabInfo()

            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            TabButton.Visible = Visible

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        --// Execution \\--
        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(Tab.Show)

        Tab.Container = TabContainer
        setmetatable(Tab, BaseGroupbox)

        Library.Tabs[Name] = Tab

        return Tab
    end

    function Window:AddDialog(Idx, Info)
        Info = Library:Validate(Info, Templates.Dialog)

        local DialogFrame
        local DialogOverlay
        local DialogContainer
        local ButtonsHolder
        local FooterButtonsList = {}

        DialogOverlay = New("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = "DarkColor",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Active = false,
            ZIndex = 9000,
            Visible = true,
            Parent = MainFrame,
        })
        TweenService:Create(DialogOverlay, Library.TweenInfo, {
            BackgroundTransparency = 0.5,
        }):Play()

        DialogFrame = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(300, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 9001,
            Parent = DialogOverlay,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = DialogFrame,
            })
        )
        Library:AddOutline(DialogFrame)

        local InnerContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 9002,
            Parent = DialogFrame,
        })
        local DialogScale = New("UIScale", {
            Scale = 0.95,
            Parent = DialogFrame,
        })
        TweenService:Create(DialogScale, Library.TweenInfo, {
            Scale = 1
        }):Play()
        local _InnerPadding = New("UIPadding", {
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            Parent = InnerContainer,
        })
        local _InnerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = InnerContainer,
        })

        local HeaderContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 9002,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = HeaderContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = HeaderContainer,
        })

        local TitleRow = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 9002,
            Parent = HeaderContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TitleRow,
        })

        if Info.Icon then
            local ParsedIcon = Library:GetCustomIcon(Info.Icon)
            if ParsedIcon then
                local IconImg = New("ImageLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(16, 16),
                    Image = ParsedIcon.Url,
                    ImageColor3 = "FontColor",
                    ImageRectOffset = ParsedIcon.ImageRectOffset,
                    ImageRectSize = ParsedIcon.ImageRectSize,
                    LayoutOrder = 1,
                    ZIndex = 9002,
                    Parent = TitleRow,
                })
                if Info.TitleColor then
                    IconImg.ImageColor3 = Info.TitleColor
                end
            end
        end

        local TitleLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Title,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
            ZIndex = 9002,
            Parent = TitleRow,
        })
        if Info.TitleColor then
            TitleLabel.TextColor3 = Info.TitleColor
        end

        local DescriptionLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Description,
            TextSize = 14,
            TextTransparency = Info.DescriptionColor and 0 or 0.2,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = 2,
            ZIndex = 9002,
            Parent = HeaderContainer,
        })
        if Info.DescriptionColor then
            DescriptionLabel.TextColor3 = Info.DescriptionColor
        end

        DialogContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 4,
            ZIndex = 9002,
            Parent = InnerContainer,
        })
        local _DialogContainerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = DialogContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = DialogContainer,
        })
        
        local _Sep2 = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            LayoutOrder = 5,
            ZIndex = 9002,
            Parent = InnerContainer,
        })

        ButtonsHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 6,
            ZIndex = 9002,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Wraps = true,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ButtonsHolder,
        })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            Parent = ButtonsHolder,
        })

        local Dialog = {
            Elements = {},
            Container = DialogContainer,
        }

        function Dialog:Resize()
            local MaxWidth = MainFrame.AbsoluteSize.X * 0.75
            local MinWidth = 400

            local TotalButtonWidth = 0
            local ButtonCount = 0
            local HasButtons = false

            for _, BtnWrap in FooterButtonsList do
                HasButtons = true
                ButtonCount = ButtonCount + 1
                TotalButtonWidth = TotalButtonWidth + BtnWrap.Container.Size.X.Offset
            end

            local TargetWidth = MinWidth
            if HasButtons then
                local RequiredWidth = TotalButtonWidth + ((ButtonCount - 1) * 8) + 30
                TargetWidth = math.max(MinWidth, math.min(RequiredWidth, MaxWidth))
            end

            DialogFrame.Size = UDim2.fromOffset(TargetWidth, 0)

            local _DescX, DescY = Library:GetTextBounds(DescriptionLabel.Text, Library.Scheme.Font, 14, TargetWidth - 30)
            DescriptionLabel.Size = UDim2.new(1, 0, 0, DescY)

            local HasElements = false
            for _, v in DialogContainer:GetChildren() do
                if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
                    HasElements = true
                    break
                end
            end
            DialogContainer.Visible = HasElements

            ButtonsHolder.Visible = HasButtons
            _Sep2.Visible = HasButtons
        end

        function Dialog:SetTitle(Title)
            TitleLabel.Text = Title
            Dialog:Resize()
        end

        function Dialog:SetDescription(Description)
            DescriptionLabel.Text = Description
            Dialog:Resize()
        end

        function Dialog:Dismiss()
            Library.ActiveDialog = nil
            local CloseTween = TweenService:Create(DialogScale, Library.TweenInfo, { Scale = 0.95 })
            TweenService:Create(DialogOverlay, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            CloseTween:Play()
            
            task.delay(Library.TweenInfo.Time, function()
                DialogOverlay:Destroy()
            end)
            Library.Dialogues[Idx] = nil
        end

        DialogOverlay.MouseButton1Click:Connect(function()
            if Info.OutsideClickDismiss then
                Dialog:Dismiss()
            end
        end)

        function Dialog:RemoveFooterButton(ButtonIdx)
            if FooterButtonsList[ButtonIdx] then
                FooterButtonsList[ButtonIdx].Container:Destroy()
                FooterButtonsList[ButtonIdx] = nil
            end
        end

        function Dialog:SetButtonDisabled(ButtonIdx, Disabled)
            if FooterButtonsList[ButtonIdx] and type(FooterButtonsList[ButtonIdx].SetDisabled) == "function" then
                FooterButtonsList[ButtonIdx]:SetDisabled(Disabled)
            end
        end

        function Dialog:SetButtonOrder(ButtonIdx, Order)
            if FooterButtonsList[ButtonIdx] and FooterButtonsList[ButtonIdx].Container then
                FooterButtonsList[ButtonIdx].Container.LayoutOrder = Order
            end
        end

        function Dialog:AddFooterButton(ButtonIdx, ButtonInfo)
            Dialog:RemoveFooterButton(ButtonIdx)

            local WaitTime = ButtonInfo.WaitTime or 0

            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                LayoutOrder = ButtonInfo.Order or 0,
                ZIndex = 9002,
                Parent = ButtonsHolder,
            })
            
            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"
            
            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                BackgroundTransparency = WaitTime > 0 and 0.5 or 0,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 9002,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", { 
                    CornerRadius = UDim.new(0, Library.CornerRadius), 
                    Parent = TextBtn 
                })
            )

            local _BtnPadding = New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end
            
            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or ButtonIdx,
                TextColor3 = TextColor,
                TextTransparency = WaitTime > 0 and 0.5 or 0,
                TextSize = 14,
                ZIndex = 9002,
                Parent = TextBtn,
            })
            
            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ProgressBar
            if WaitTime > 0 then
                ProgressBar = New("Frame", {
                    BackgroundColor3 = "AccentColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, -2),
                    Size = UDim2.new(0, 0, 0, 2),
                    ZIndex = 2,
                    Parent = TextBtn,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", { 
                        CornerRadius = UDim.new(0, Library.CornerRadius), 
                        Parent = ProgressBar 
                    })
                )
            end

            local IsActive = WaitTime <= 0

            local ButtonWrap = {
                Container = ButtonContainer,
                SetDisabled = function(self, Disabled)
                    IsActive = not Disabled
                    if Disabled then
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0.5 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0.5 }):Play()
                    else
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0 }):Play()
                    end
                end
            }

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            TextBtn.MouseButton1Click:Connect(function()
                if not IsActive then return end
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Dialog)
                end
                if Info.AutoDismiss then
                    Dialog:Dismiss()
                end
            end)

            if WaitTime > 0 then
                TweenService:Create(ProgressBar, TweenInfo.new(WaitTime, Enum.EasingStyle.Linear), {
                    Size = UDim2.new(1, 0, 0, 2)
                }):Play()
                
                task.delay(WaitTime, function()
                    ButtonWrap:SetDisabled(false)
                    if ProgressBar then
                        TweenService:Create(ProgressBar, Library.TweenInfo, {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                end)
            end

            FooterButtonsList[ButtonIdx] = ButtonWrap
        end

        for BIdx, BInfo in Info.FooterButtons do
            if type(BIdx) == "number" and BInfo.Id then BIdx = BInfo.Id end
            Dialog:AddFooterButton(BIdx, BInfo)
        end

        setmetatable(Dialog, BaseGroupbox)
        Library.Dialogues[Idx] = Dialog

        Dialog:Resize()
        
        Library.ActiveDialog = Dialog
        return Dialog
    end

    function Window:Toggle(Value: boolean?)
        if Library.ActiveLoading then
            if Value == true then
                return
            end

            if not Library.Toggled then
                return
            end
        end

        if typeof(Value) == "boolean" then
            Library.Toggled = Value
        else
            Library.Toggled = not Library.Toggled
        end

        MainFrame.Visible =
            Library.Toggled

        if Library.Toggled ~= true then

            Window:CloseAccountPopover()
        end

        if WindowInfo.UnlockMouseWhileOpen then
            ModalElement.Modal = Library.Toggled
        end

        if Library.Toggled
            and UserInputService.MouseEnabled
        then
            local OldMouseIconEnabled = UserInputService.MouseIconEnabled
            local ShowCursorBinding = Library.ShowCursorBinding
            pcall(function()
                RunService:UnbindFromRenderStep(ShowCursorBinding)
            end)
            RunService:BindToRenderStep(ShowCursorBinding, Enum.RenderPriority.Last.Value, function()
                UserInputService.MouseIconEnabled = not Library.ShowCustomCursor

                Cursor.Position = UDim2.fromOffset(Mouse.X, Mouse.Y)
                Cursor.Visible = Library.ShowCustomCursor

                if not (Library.Toggled and ScreenGui and ScreenGui.Parent) then
                    UserInputService.MouseIconEnabled = OldMouseIconEnabled
                    Cursor.Visible = false
                    RunService:UnbindFromRenderStep(ShowCursorBinding)
                end
            end)
        elseif not Library.Toggled then
            TooltipLabel.Visible = false

            for _, Option in Library.Options do
                if Option.Type == "ColorPicker" then
                    Option.ColorMenu:Close()
                    Option.ContextMenu:Close()
                elseif Option.Type == "Dropdown" or Option.Type == "KeyPicker" then
                    Option.Menu:Close()
                end
            end
        end
    end

    function Library:Toggle(Value: boolean?)
        return Window:Toggle(Value)
    end

    if WindowInfo.EnableSidebarResize then
        local Threshold = (WindowInfo.MinSidebarWidth + WindowInfo.SidebarCompactWidth) * WindowInfo.SidebarCollapseThreshold
        local StartPos, StartWidth
        local Dragging = false
        local Changed

        local SidebarGrabber = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(0, 8, 1, 0),
            Text = "",
            Parent = DividerLine,
        })
        SidebarGrabber.MouseEnter:Connect(function()
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library:GetLighterColor(Library.Scheme.OutlineColor),
            }):Play()
        end)
        SidebarGrabber.MouseLeave:Connect(function()
            if Dragging then
                return
            end
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.OutlineColor,
            }):Play()
        end)

        SidebarGrabber.InputBegan:Connect(function(Input: InputObject)
            if not IsClickInput(Input) then
                return
            end

            Library.CantDragForced = true

            StartPos = Input.Position
            StartWidth = Window:GetSidebarWidth()
            Dragging = true

            Changed = Input.Changed:Connect(function()
                if Input.UserInputState ~= Enum.UserInputState.End then
                    return
                end

                Library.CantDragForced = false
                TweenService:Create(DividerLine, Library.TweenInfo, {
                    BackgroundColor3 = Library.Scheme.OutlineColor,
                }):Play()

                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end
            end)
        end)

        Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
            if not Library.Toggled or not (ScreenGui and ScreenGui.Parent) then
                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end

                return
            end

            if Dragging and IsHoverInput(Input) then
                local Delta = Input.Position - StartPos
                local Width = StartWidth + Delta.X

                if WindowInfo.DisableCompactingSnap then
                    Window:SetSidebarWidth(Width)
                    return
                end

                if Width > Threshold then
                    Window:SetSidebarWidth(math.max(Width, WindowInfo.MinSidebarWidth))
                else
                    Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
                end
            end
        end))
    end
    if WindowInfo.EnableCompacting and WindowInfo.SidebarCompacted then
        Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
    end
    if WindowInfo.AutoShow and not Library.ActiveLoading then
        task.spawn(Library.Toggle)
    end

    if Library.IsMobile then

        local ToggleButton =
            Library:AddDraggableButton(
                "HOLY",
                function()

                    Library:Toggle()
                end,
                true
            )

        local ToggleHolder =
            ToggleButton.Holder
            or ToggleButton.Button

        if WindowInfo.MobileButtonsSide
            == "Right" then

            ToggleHolder.Position =
                UDim2.new(
                    1,
                    -6,
                    0,
                    6
                )

            ToggleHolder.AnchorPoint =
                Vector2.new(
                    1,
                    0
                )
        end

        if WindowInfo.ShowMobileButtons
            == false then

            ToggleHolder.Visible =
                false
        end
    end

    --// Execution \\--
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        Library:UpdateSearch(SearchBox.Text)
    end)

    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
        if Library.Unloaded then
            return
        end

        if Input.KeyCode == Enum.KeyCode.Escape
        and Window:IsAccountPopoverOpen() then

            Window:CloseAccountPopover()

            return
        end

        if UserInputService:GetFocusedTextBox() then
            return
        end

        if
            (
                typeof(Library.ToggleKeybind) == "table"
                and Library.ToggleKeybind.Type == "KeyPicker"
                and Input.KeyCode.Name == Library.ToggleKeybind.Value
            ) or Input.KeyCode == Library.ToggleKeybind
        then
            Library.Toggle()
        end
    end))

    Library:GiveSignal(UserInputService.WindowFocused:Connect(function()
        Library.IsRobloxFocused = true
    end))
    Library:GiveSignal(UserInputService.WindowFocusReleased:Connect(function()
        Library.IsRobloxFocused = false
    end))

    return Window
end

function Library:CreateLoading(LoadingInfo)
    if Library.ActiveLoading then
        warn("Loading GUI already exists, you cannot create multiple Loading GUIs.")
        return Library.ActiveLoading
    end

    LoadingInfo = Library:Validate(LoadingInfo, Templates.Loading)

    local Loading = {
        CurrentStep = LoadingInfo.CurrentStep,
        TotalSteps = LoadingInfo.TotalSteps,

        ShowSidebar = LoadingInfo.ShowSidebar,
        AutoResizeHeight = LoadingInfo.AutoResizeHeight,
        IsError = false,
        Destroyed = false,

        WindowWidth = LoadingInfo.WindowWidth,
        WindowHeight = LoadingInfo.WindowHeight,
        BaseWindowHeight = LoadingInfo.WindowHeight,
        WindowErrorHeight = LoadingInfo.WindowHeight,

        ContentWidth = LoadingInfo.ContentWidth,
        SidebarWidth = LoadingInfo.SidebarWidth,
    }

    --// ScreenGui \\--
    local ScreenGui = New("ScreenGui", {
        Name = "ObsidianLoading",
        DisplayOrder = 999,
        ResetOnSpawn = false
    })
    ParentUI(ScreenGui)
    Loading.ScreenGui = ScreenGui

    ScreenGui.DescendantRemoving:Connect(function(Instance)
        Library:RemoveFromRegistry(Instance)
    end)

    --// Main Frame \\--
    local MainFrame = New("TextButton", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = function()
            return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
        end,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(Loading.ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth, Loading.WindowHeight),
        ClipsDescendants = true,
        Text = "",
        AutoButtonColor = false,
        Parent = ScreenGui,
    })
    Library:AddOutline(MainFrame)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = MainFrame }))
    
	local MainScale = New("UIScale", {
		Scale = Library.IsMobile and 0.8 or 1,
		Parent = MainFrame
	})
	table.insert(Library.Scales, MainScale)
	Library.ScalesOffset[MainScale] = Library.IsMobile and 0.2 or 0

    --// Layout Containers \\--
    local Container = New("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, Loading.ContentWidth, 1, 0),
        Parent = MainFrame,
    })

    local SideBar = New("Frame", {
        Name = "SideBar",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(Loading.ContentWidth, 0),
        Size = UDim2.new(0, Loading.ShowSidebar and Loading.SidebarWidth or 0, 1, 0),
        ClipsDescendants = true,
        Visible = Loading.ShowSidebar,
        Parent = MainFrame,
    })
    local SidebarCorner = New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = SideBar })
    table.insert(Library.Corners, SidebarCorner)
    
    Library:AddOutline(SideBar)
    
    local SidebarDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Visible = Loading.ShowSidebar,
        Parent = SideBar,
    })

    --// Top Bar \\--
    local TopBar = New("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        ZIndex = 2,
        Parent = Container,
    })
    Library:MakeDraggable(MainFrame, TopBar, true, true)

    local TitleHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = TopBar,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = TitleHolder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = TitleHolder,
    })

    if LoadingInfo.Icon then
        local Icon = Library:GetCustomIcon(LoadingInfo.Icon)
        local _WindowIcon = New("ImageLabel", {
            Image = Icon.Url,
            ImageRectOffset = Icon.ImageRectOffset,
            ImageRectSize = Icon.ImageRectSize,
            Size = LoadingInfo.IconSize,
            Parent = TitleHolder,
        })
    else
        local _WindowIcon = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = LoadingInfo.IconSize,
            Text = LoadingInfo.Title:sub(1, 1),
            TextScaled = true,
            Visible = false,
            Parent = TitleHolder,
        })
    end

    local TitleX = Library:GetTextBounds(
        LoadingInfo.Title,
        Library.Scheme.Font,
        20,
        TitleHolder.AbsoluteSize.X - (LoadingInfo.Icon and (LoadingInfo.IconSize.X.Offset + 6) or 0) - 12
    )
    local _WindowTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, TitleX, 1, 0),
        Text = LoadingInfo.Title,
        TextSize = 20,
        Parent = TitleHolder,
    })

    Library:MakeLine(Container, {
        Position = UDim2.fromOffset(0, 48),
        Size = UDim2.new(1, 0, 0, 1),
    })

    --// Loading Content Elements \\--
    local InnerContent = New("Frame", {
        Name = "InnerContent",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        Parent = Container,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 12),
        Parent = InnerContent,
    })

    local IconHolder = New("Frame", {
        Name = "IconHolder",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(64, 64),
        Parent = InnerContent,
    })

    local LoaderIcon = Library:GetCustomIcon(LoadingInfo.LoadingIcon)
    local LoadingIcon = New("ImageLabel", {
        Name = "LoaderIcon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        Image = LoaderIcon.Url,
        ImageRectOffset = LoaderIcon.ImageRectOffset,
        ImageRectSize = LoaderIcon.ImageRectSize,
        ImageColor3 = LoadingInfo.LoadingIconColor or ((LoadingInfo.LoadingIcon == Templates.Loading.LoadingIcon) and "AccentColor" or "WhiteColor"),
        Parent = IconHolder,
    })

    local RotationTween
    if LoadingInfo.LoadingIconTweenTime > 0 then
        RotationTween = TweenService:Create(
            LoadingIcon,
            TweenInfo.new(LoadingInfo.LoadingIconTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
            { Rotation = 360 }
        )
        RotationTween:Play()
    end

    local MessageLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 18,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    local DescriptionLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 14,
        TextTransparency = 0.5,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    --// Progress Bar \\--
    local SliderBar = New("Frame", {
        BackgroundColor3 = "MainColor",
        Size = UDim2.new(0.7, 0, 0, 15),
        Parent = InnerContent,
    })
    Library:AddOutline(SliderBar)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderBar }))

    local SliderFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = SliderBar,
    })
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderFill }))

    local ProgressLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        TextSize = 14,
        ZIndex = 2,
        Parent = SliderBar,
    })
    New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        Color = "DarkColor",
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = ProgressLabel,
    })

    --// Sidebar Object \\--
    local SidebarScrolling = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Size = UDim2.fromScale(1, 1),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = "OutlineColor",
        Parent = SideBar,
    })
    local SidebarList = New("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = SidebarScrolling,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        Parent = SidebarScrolling,
    })

    local SidebarObject = {
        Elements = {},
        DependencyBoxes = {},
        Tabboxes = {},
        
        BoxHolder = SidebarScrolling,
        Container = SidebarScrolling,
        
        Resize = function(self)
            SidebarScrolling.CanvasSize = UDim2.fromOffset(0, SidebarList.AbsoluteContentSize.Y + 24)
        end,
        Tab = {
            Elements = {},
            DependencyBoxes = {},
            DependencyGroupboxes = {},
            Tabboxes = {},
        },
    }

    SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarObject:Resize()
    end)

    setmetatable(SidebarObject, BaseGroupbox)
    Loading.Sidebar = SidebarObject

    --// Error Frame \\--
    local ErrorFrame = New("Frame", {
        Name = "Error",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        ClipsDescendants = true,
        Visible = false,
        Parent = Container,
    })

    local _ErrorTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 15),
        Size = UDim2.new(1, -30, 0, 18),
        Text = "Error",
        TextColor3 = "RedColor",
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ErrorFrame,
    })

    local ErrorLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 39),
        Size = UDim2.new(1, -30, 1, -90),
        Text = "Error Message",
        TextSize = 14,
        TextTransparency = 0.2,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = ErrorFrame,
    })

    local ErrorButtonsDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, -48),
        Size = UDim2.new(1, -30, 0, 1),
        Visible = false,
        Parent = ErrorFrame,
    })

    local ErrorButtonsHolder = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 42),
        Visible = false,
        Parent = ErrorFrame,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ErrorButtonsHolder,
    })
    New("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        Parent = ErrorButtonsHolder,
    })

    function Loading:UpdateLayout()
        if Loading.IsError then
            Loading:RecalculateErrorHeight()
        end

        local ShowSidebar = Loading.ShowSidebar
        local FinalWidth = ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth
        local FinalHeight = Loading.IsError and Loading.WindowErrorHeight or Loading.WindowHeight
        
        if ShowSidebar then
            SideBar.Visible = true
            SidebarDivider.Visible = true
        end

        TweenService:Create(MainFrame, Library.TweenInfo, { Size = UDim2.fromOffset(FinalWidth, FinalHeight) }):Play()
        TweenService:Create(SideBar, Library.TweenInfo, { Position = UDim2.fromOffset(Loading.ContentWidth, 0), Size = UDim2.new(0, ShowSidebar and Loading.SidebarWidth or 0, 1, 0) }):Play()
        TweenService:Create(Container, Library.TweenInfo, { Size = UDim2.new(0, ShowSidebar and Loading.ContentWidth or Loading.WindowWidth, 1, 0) }):Play()

        if not ShowSidebar then
            task.delay(Library.TweenInfo.Time, function()
                if not Loading.ShowSidebar then
                    SideBar.Visible = false
                    SidebarDivider.Visible = false
                end
            end)
        end
    end

    --// Content Page \\--
    function Loading:RecalculateLoadingHeight()
        if not Loading.AutoResizeHeight then
            return
        end

        local RequiredHeight = 
              49 -- TopBar
            + 48 -- Padding
            + InnerContent.UIListLayout.AbsoluteContentSize.Y

        Loading.WindowHeight = math.max(Loading.BaseWindowHeight, RequiredHeight)
    end

    function Loading:SetMessage(Text)
        MessageLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetDescription(Text)
        DescriptionLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetLoadingIcon(Icon)
        local IconData = Library:GetCustomIcon(Icon)
        LoadingIcon.Image = IconData.Url
        LoadingIcon.ImageRectOffset = IconData.ImageRectOffset
        LoadingIcon.ImageRectSize = IconData.ImageRectSize
    end

    function Loading:SetLoadingIconTweenTime(TweenTime)
        if RotationTween then
            RotationTween:Cancel()
            RotationTween:Destroy()
        end

        if TweenTime > 0 then
            RotationTween = TweenService:Create(
                LoadingIcon,
                TweenInfo.new(TweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
                { Rotation = 360 }
            )
            RotationTween:Play()
        else
            LoadingIcon.Rotation = 0
        end
    end

    function Loading:SetLoadingIconColor(Color)
        LoadingIcon.ImageColor3 = Color
    end

    function Loading:SetCurrentStep(Step)
        Loading.CurrentStep = math.clamp(Step, 0, Loading.TotalSteps)

        local Progress = Loading.CurrentStep / Loading.TotalSteps
        TweenService:Create(SliderFill, Library.TweenInfo, { Size = UDim2.fromScale(Progress, 1) }):Play()

        ProgressLabel.Text = string.format("%d/%d", Loading.CurrentStep, Loading.TotalSteps)
    end

    function Loading:SetTotalSteps(Steps)
        Loading.TotalSteps = Steps
        Loading:SetCurrentStep(Loading.CurrentStep)
    end

    --// Size \\--
    function Loading:SetWindowHeight(Height)
        Loading.WindowHeight = Height
        Loading:UpdateLayout()
    end

    function Loading:SetWindowWidth(Width)
        Loading.WindowWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetContentWidth(Width)
        Loading.ContentWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetSidebarWidth(Width)
        Loading.SidebarWidth = Width
        Loading:UpdateLayout()
    end

    --// Sidebar \\--
    function Loading:ShowSidebarPage(Bool)
        Loading.ShowSidebar = Bool
        Loading:UpdateLayout()
    end

    --// Error Page \\--
    function Loading:ShowErrorPage(Enabled)
        Loading.IsError = Enabled
        InnerContent.Visible = not Enabled
        ErrorFrame.Visible = Enabled

        if Loading.ShowSidebar then
            Loading:ShowSidebarPage(not Enabled)
        else
            Loading:UpdateLayout()
        end
    end

    function Loading:RecalculateErrorHeight()
        local TargetWidth = (Loading.ShowSidebar and Loading.ContentWidth or Loading.WindowWidth) - 30
        local _, ErrorY = Library:GetTextBounds(ErrorLabel.Text, Library.Scheme.Font, 14, TargetWidth)

        ErrorLabel.Size = UDim2.new(1, -30, 0, ErrorY)

        local HasButtons = ErrorButtonsHolder.Visible
        local RequiredHeight =
              49                        -- TopBar
            + 15                        -- Padding Top
            + 18                        -- Title Height
            + 6                         -- Padding between Title and Label
            + ErrorY                    -- Label Height
            + 15                        -- Padding between Label and Buttons
            + (HasButtons and 48 or 0)  -- Buttons Area

        Loading.WindowErrorHeight = RequiredHeight -- math.max(Loading.WindowHeight, RequiredHeight)
    end

    function Loading:SetErrorMessage(Text)
        ErrorLabel.Text = Text
        Loading:UpdateLayout()
    end

    function Loading:SetErrorButtons(Buttons)
        assert(typeof(Buttons) == "table", "Buttons must be a table")

        for _, button in ErrorButtonsHolder:GetChildren() do
            if button:IsA("Frame") then 
                button:Destroy() 
            end
        end

        local HasButtons = GetTableSize(Buttons) > 0
        ErrorButtonsHolder.Visible = HasButtons
        ErrorButtonsDivider.Visible = HasButtons

        for Idx, ButtonInfo in Buttons do
            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                Parent = ErrorButtonsHolder,
            })
            
            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"
            
            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", { 
                    CornerRadius = UDim.new(0, Library.CornerRadius), 
                    Parent = TextBtn 
                })
            )

            New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or Idx,
                TextColor3 = TextColor,
                TextSize = 14,
                Parent = TextBtn,
            })
            
            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            TextBtn.MouseButton1Click:Connect(function()
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Loading)
                end
            end)
        end

        Loading:UpdateLayout()
    end

    --// Destroy/Continue \\--
    function Loading:Destroy()
        if RotationTween then
            RotationTween:Cancel()
        end

        ScreenGui:Destroy()
        Loading.Destroyed = true
        Library.ActiveLoading = nil

        if Library.Toggle and Library.Toggled == false and Library.Unloaded ~= true then
            Library:Toggle(true)
        end
    end

    Loading.Continue = Loading.Destroy;

    if Library.Toggle and Library.Toggled and Library.Unloaded ~= true then
        Library:Toggle(false)
    end

    Loading:SetCurrentStep(Loading.CurrentStep)

    Library.ActiveLoading = Loading
    return Loading
end

local function OnPlayerChange()
    if Library.Unloaded then
        return
    end

    local PlayerList, ExcludedPlayerList = GetPlayers(), GetPlayers(true)
for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Player" then
            Dropdown:SetValues(Dropdown.ExcludeLocalPlayer and ExcludedPlayerList or PlayerList)
        end
    end
end

local function OnTeamChange()
    if Library.Unloaded then
        return
    end

    local TeamList = GetTeams()
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Team" then
            Dropdown:SetValues(TeamList)
        end
    end
end

Library:GiveSignal(Players.PlayerAdded:Connect(OnPlayerChange))
Library:GiveSignal(Players.PlayerRemoving:Connect(OnPlayerChange))

Library:GiveSignal(Teams.ChildAdded:Connect(OnTeamChange))
Library:GiveSignal(Teams.ChildRemoved:Connect(OnTeamChange))

getgenv().Library = Library
return Library
