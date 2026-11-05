-- Built-in channels, in the order Tab cycles through them. Edit freely.
-- Numbered channels (General, Trade, LocalDefense, ...) are added after these.
local ORDER = { "SAY", "PARTY", "RAID", "INSTANCE_CHAT", "GUILD", "YELL" }

local INSTANCE = (Enum and Enum.PartyCategory and Enum.PartyCategory.Instance)
    or LE_PARTY_CATEGORY_INSTANCE

local function IsAvailable(chatType)
    if chatType == "PARTY" then
        return IsInGroup() and not IsInRaid()
    elseif chatType == "RAID" then
        return IsInRaid()
    elseif chatType == "INSTANCE_CHAT" then
        return INSTANCE ~= nil and IsInGroup(INSTANCE)
    elseif chatType == "GUILD" then
        return IsInGuild()
    end
    return true -- SAY, YELL
end

-- Channels you have joined: General, Trade, LocalDefense, etc.
-- GetChannelList returns id, name, disabled repeated for each channel.
local function GetJoinedChannels()
    local info = { GetChannelList() }
    local channels = {}
    local i = 1
    while info[i] do
        local step = (type(info[i + 2]) == "boolean") and 3 or 2
        channels[#channels + 1] = {
            id = info[i],
            name = info[i + 1],
            disabled = (step == 3) and info[i + 2] or false,
        }
        i = i + step
    end
    table.sort(channels, function(a, b) return a.id < b.id end)
    return channels
end

-- Is this channel ticked in the chat window's settings?
-- Channel names carry a zone suffix ("Trade - City"), so compare the start.
local function IsChannelShown(chatFrame, name)
    local shown = chatFrame and chatFrame.channelList
    if not shown then return true end -- can't tell, so assume yes
    local upperName = name:upper()
    for _, value in pairs(shown) do
        if upperName:sub(1, #value) == value:upper() then
            return true
        end
    end
    return false
end

-- Everything Tab can land on right now, in order.
local function BuildList(chatFrame)
    local list = {}
    for _, chatType in ipairs(ORDER) do
        if IsAvailable(chatType) then
            list[#list + 1] = { chatType = chatType }
        end
    end
    for _, channel in ipairs(GetJoinedChannels()) do
        if not channel.disabled and IsChannelShown(chatFrame, channel.name) then
            list[#list + 1] = { chatType = "CHANNEL", target = channel.id }
        end
    end
    return list
end

local function IndexOf(list, chatType, target)
    for i, entry in ipairs(list) do
        if entry.chatType == chatType then
            if chatType ~= "CHANNEL" or entry.target == target then
                return i
            end
        end
    end
    return 0
end

-- Blizzard calls this from the edit box's Tab handler; returning true
-- tells it we handled the keypress.
function ChatEdit_CustomTabPressed(editBox)
    local chatType = editBox:GetAttribute("chatType")
    local text = editBox:GetText()

    -- Leave whisper-target cycling and slash-command autocomplete alone.
    if chatType == "WHISPER" or chatType == "BN_WHISPER" or text:sub(1, 1) == "/" then
        return false
    end

    local chatFrame = editBox.chatFrame or DEFAULT_CHAT_FRAME
    local list = BuildList(chatFrame)
    local n = #list
    if n < 2 then return true end

    local target = tonumber(editBox:GetAttribute("channelTarget"))
    local step = IsShiftKeyDown() and -1 or 1
    local index = IndexOf(list, chatType, target)
    if index == 0 then
        index = (step > 0) and 0 or (n + 1) -- not in the list: start from an end
    end
    local nextEntry = list[((index - 1 + step) % n) + 1]

    local cursor = editBox:GetCursorPosition()

    editBox:SetAttribute("chatType", nextEntry.chatType)
    if nextEntry.chatType == "CHANNEL" then
        editBox:SetAttribute("channelTarget", nextEntry.target)
    end
    ChatEdit_UpdateHeader(editBox)

    -- Safety net: make sure whatever was typed is still there.
    if editBox:GetText() ~= text then
        editBox:SetText(text)
        editBox:SetCursorPosition(cursor)
    end
    return true
end
