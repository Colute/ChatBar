local frame = CreateFrame("Frame", "MyFrame", UIParent)

frame:SetFrameStrata("LOW")

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
frame:RegisterEvent("CHANNEL_UI_UPDATE")

local btnWidth = 20
local btnHeight = 20
local padding = 10
local spacing = 6

ChatBarDB = ChatBarDB or { style = "SkinGlass", showText = true }

local staticButtons = {
    {"S", "/say ", {0.9, 0.9, 0.9}},
    {"P", "/party ", {0.3, 0.5, 0.9}},
    {"Y", "/yell ", {0.9, 0.2, 0.2}},
    {"G", "/guild ", {0.1, 0.8, 0.2}},
    {"O", "/o ", {0.1, 0.5, 0.2}},
    {"W", "/whisper ", {0.6, 0.2, 0.8}},
    {"E", "/emote ", {0.9, 0.5, 0.1}}
}

local activeButtons = {}
local UpdateChatBar

local dropdownFrame = CreateFrame("Frame", "ChatBarDropDownMenu", UIParent, "UIDropDownMenuTemplate")

local function DropDown_Initialize()
    local info = {}
    
    info.text = "--- Styles ---"
    info.isTitle = 1
    info.notCheckable = true
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = "Style: SkinGlass"
    info.func = function()
        ChatBarDB.style = "SkinGlass"
        UpdateChatBar()
    end
    info.checked = (ChatBarDB.style == "SkinGlass")
    UIDropDownMenu_AddButton(info)

    info.text = "Style: SkinSolid"
    info.func = function()
        ChatBarDB.style = "SkinSolid"
        UpdateChatBar()
    end
    info.checked = (ChatBarDB.style == "SkinSolid")
    UIDropDownMenu_AddButton(info)

    info.text = "Style: SkinSquares"
    info.func = function()
        ChatBarDB.style = "SkinSquares"
        UpdateChatBar()
    end
    info.checked = (ChatBarDB.style == "SkinSquares")
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = "--- Settings ---"
    info.isTitle = 1
    info.notCheckable = true
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = "Show letters"
    info.func = function()
        ChatBarDB.showText = not ChatBarDB.showText
        UpdateChatBar()
    end
    info.checked = ChatBarDB.showText
    info.keepShownOnClick = 1
    UIDropDownMenu_AddButton(info)
end

UpdateChatBar = function()
    for _, btn in ipairs(activeButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    activeButtons = {}

    local prefix, folder
    if ChatBarDB.style == "SkinGlass" then
        folder = "SkinGlass"
        prefix = "Glass_"
    elseif ChatBarDB.style == "SkinSolid" then
        folder = "SkinSolid"
        prefix = "Solid_"
    else
        folder = "SkinSquares"
        prefix = "Squares_"
    end

    local path = "Interface\\AddOns\\ChatBar\\styles\\" .. folder .. "\\"
    local allButtonsData = {}

    for _, data in ipairs(staticButtons) do
        table.insert(allButtonsData, {name = data[1], command = data[2], color = data[3]})
    end

    local channelList = { GetChannelList() }
    for i = 1, getn(channelList), 2 do
        local channelId = channelList[i]
        local channelName = channelList[i+1]
        
        if channelId and channelName then
            local shortName = string.upper(string.sub(channelName, 1, 1))
            local command = "/" .. channelId .. " "
            local color = {0.8, 0.8, 0.2} 
            
            table.insert(allButtonsData, {name = shortName, command = command, color = color})
        end
    end

    local numButtons = getn(allButtonsData)
    local dynamicWidth = (numButtons * btnWidth) + ((numButtons - 1) * spacing) + (padding * 2)
    frame:SetWidth(dynamicWidth)
    frame:SetHeight(btnHeight)

    for i, data in ipairs(allButtonsData) do
        local btn = CreateFrame("Button", "MyTestButton" .. i, frame)
        btn:SetWidth(btnWidth)
        btn:SetHeight(btnHeight)
        btn:SetPoint("LEFT", frame, "LEFT", padding + (i - 1) * (btnWidth + spacing), 0)
        
        local center = btn:CreateTexture(nil, "ARTWORK")
        center:SetAllPoints(btn)
        center:SetTexture(path .. prefix .. "ChanButton_Center")
        center:SetVertexColor(data.color[1], data.color[2], data.color[3])

        local shadUp = btn:CreateTexture(nil, "OVERLAY", nil, 1)
        shadUp:SetAllPoints(btn)
        shadUp:SetTexture(path .. prefix .. "ChanButton_Up_Shad")

        local specUp = btn:CreateTexture(nil, "OVERLAY", nil, 2)
        specUp:SetAllPoints(btn)
        specUp:SetTexture(path .. prefix .. "ChanButton_Up_Spec")

        local shadDown = btn:CreateTexture(nil, "OVERLAY", nil, 1)
        shadDown:SetAllPoints(btn)
        shadDown:SetTexture(path .. prefix .. "ChanButton_Down_Shad")
        shadDown:Hide()

        local specDown = btn:CreateTexture(nil, "OVERLAY", nil, 2)
        specDown:SetAllPoints(btn)
        specDown:SetTexture(path .. prefix .. "ChanButton_Down_Spec")
        specDown:Hide()

        local text = nil
        if ChatBarDB.showText then
            text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("BOTTOM", btn, "TOP", 1, 4)
            text:SetJustifyH("CENTER")
            text:SetText(data.name)
            text:SetShadowColor(0, 0, 0, 1)
            text:SetShadowOffset(1, -1)
        end

        btn:SetScript("OnMouseDown", function()
            shadUp:Hide()
            specUp:Hide()
            shadDown:Show()
            specDown:Show()
            if text then
                text:SetPoint("BOTTOM", btn, "TOP", 1, 3)
            end
        end)

        btn:SetScript("OnMouseUp", function()
            shadDown:Hide()
            specDown:Hide()
            shadUp:Show()
            specUp:Show()
            if text then
                text:SetPoint("BOTTOM", btn, "TOP", 1, 4)
            end
        end)
        
        btn:SetScript("OnClick", function()
            ChatFrame_OpenChat(data.command)
        end)

        table.insert(activeButtons, btn)
    end
end

frame:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30)

frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 10,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
frame:SetBackdropBorderColor(0.5, 0.5, 0.2, 1.0)

frame:SetMovable(true)
frame:EnableMouse(true)

frame:SetScript("OnMouseDown", function()
    if arg1 == "LeftButton" then
        frame:StartMoving()
        frame.isMoving = true
    elseif arg1 == "RightButton" then
        ToggleDropDownMenu(1, nil, dropdownFrame, "cursor", 0, 0)
    end
end)

frame:SetScript("OnMouseUp", function()
    if frame.isMoving then
        frame:StopMovingOrSizing()
        frame.isMoving = false
    end
end)

frame:SetScript("OnEvent", function()
    UpdateChatBar()
end)

SlashCmdList["CHATBAR"] = function(msg)
    msg = string.lower(msg)
    if msg == "glass" then
        ChatBarDB.style = "SkinGlass"
        UpdateChatBar()
    elseif msg == "solid"  then
        ChatBarDB.style = "SkinSolid"
        UpdateChatBar()
    elseif msg == "squares" then
        ChatBarDB.style = "SkinSquares"
        UpdateChatBar()
    elseif msg == "text" then
        ChatBarDB.showText = not ChatBarDB.showText
        UpdateChatBar()
    else
        DEFAULT_CHAT_FRAME:AddMessage("Commands: /cb glass, /cb solid, /cb squares, /cb text")
    end
end
SLASH_CHATBAR1 = "/cb"

UIDropDownMenu_Initialize(dropdownFrame, DropDown_Initialize, "MENU")

UpdateChatBar()