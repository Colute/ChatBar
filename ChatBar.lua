local frame = CreateFrame("Frame", "MyFrame", UIParent)

frame:SetFrameStrata("LOW")
frame:RegisterEvent("PLAYER_LOGIN")

local buttonNames = {
    {"S", "/say "},
    {"P", "/party "},
    {"Y", "/yell "},
    {"G", "/guild "},
    {"O", "/o "},
    {"W", "/whisper "},
    {"E", "/emote "}
}

local buttonColors = {
    {0.9, 0.9, 0.9},
    {0.3, 0.5, 0.9},
    {0.9, 0.2, 0.2},
    {0.1, 0.8, 0.2},
    {0.1, 0.5, 0.2},
    {0.6, 0.2, 0.8},
    {0.9, 0.5, 0.1} 
}

local btnWidth = 16
local btnHeight = 16
local padding = 10
local spacing = 6
local dynamicWidth = (#buttonNames * btnWidth) + ((#buttonNames - 1) * spacing) + (padding * 2)

frame:SetWidth(dynamicWidth)
frame:SetHeight(btnHeight)
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
    end
end)
frame:SetScript("OnMouseUp", function()
    if frame.isMoving then
        frame:StopMovingOrSizing()
        frame.isMoving = false
    end
end)

for i, data in ipairs(buttonNames) do
    local name = data[1]
    local command = data[2]
    
    local btn = CreateFrame("Button", "MyTestButton" .. i, frame)
    
    btn:SetWidth(btnWidth)
    btn:SetHeight(btnHeight)
    btn:SetPoint("LEFT", frame, "LEFT", padding + (i - 1) * (btnWidth + spacing), 0)
    
    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints(btn)
    icon:SetTexture("Interface\\AddOns\\ChatBar\\icons\\circle")
    local color = buttonColors[i]
    icon:SetVertexColor(color[1], color[2], color[3])
    
    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("BOTTOM", icon, "TOP", -1, 4)
    text:SetJustifyH("CENTER")
    text:SetText(name)
    
    btn:SetScript("OnClick", function()
        ChatFrame_OpenChat(command)
    end)
    
end