addonName = "QuestVoice"
addonVer = "v1.0.1"

Main = LibStub("AceAddon-3.0"):NewAddon(addonName)
LibStub("AceEvent-3.0"):Embed(Main)
Timer = LibStub("AceTimer-3.0")

function Main:OnDisable() end
function Main:OnInitialize() end


function Main:OnEnable()
    Main:RegisterEvent("QUEST_ACCEPTED", "Started")
    Main:RegisterEvent("QUEST_COMPLETE", "Finished")

    Timer.ScheduleTimer(Main, "Init", 2)
end

function Main:Init()
    local x, y = -90, 13
    local width, height = 75, 23
    local parent, anchor =   QuestLogFrame, QuestLogFrame
    local anchorBy, anchorTo = "BOTTOMRIGHT", "BOTTOMRIGHT"
    local mode ="Native"

    if IsAddOnLoaded("Carbonite") then
        x, y, width, height, parent, anchor = -60, -5, 55, 22, NxQuestD, NxQuestD
        anchorBy, anchorTo, mode = "TOPLEFT", "TOPRIGHT",  "Carbonite"

    elseif IsAddOnLoaded("QuestGuru") then
        x, y, width, height, mode = -230, 22, 75, 21, "QuestGuru"
    end

    local frame = CreateFrame("Button", "PlayButton", parent, "UIPanelButtonTemplate")
    frame:SetText("Play")
    frame:SetWidth(width)
    frame:SetHeight(height)
    frame:SetPoint(anchorBy, anchor, anchorTo, x, y)
    frame:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
    frame:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
    frame:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
    frame:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
    frame:SetScript("OnClick", Main.Selected)

    print(addonName, addonVer, "By Faralaks Started in", mode, "mode!")
end

function Main:Play()
    local voice = Main.id .. "-" .. Main.action
    PlaySoundFile("interface\\addons\\"..addonName.."\\voices\\"..voice..".mp3")
    print(addonName..":", Main.name, "("..Main.id..")", Main.action)
end

function Main:WaitThenPlay(id, name, action, wait)
    Main.id = id
    Main.name = name
    Main.action = action
    Timer.ScheduleTimer(Main, "Play", wait)
end


function Main:Selected()
    local questIndex = GetQuestLogSelection()
    local name, _, _, _, _, _, _, _,  id = GetQuestLogTitle(questIndex)
    Main:WaitThenPlay(id, name, "accept", 0.3)
end


function Main:Started(_, questIndex)
    local name, _, _, _, _, _, _, _,  id = GetQuestLogTitle(questIndex)
    Main:WaitThenPlay(id, name, "accept", 1)
end

function Main:Finished()
    local name = GetTitleText()
    local id = Find(name)
    Main:WaitThenPlay(id, name, "complete", 0.3)
end

function ClearOne(rawName)
    local _, _, cleared = string.find(rawName, "%[%d+%] (.+)")
    return cleared
end

function Clear(name)
    while string.sub(name, 1, 1) == "[" do
        name = ClearOne(name)
    end
    return name
end


function Find(find)
    for i = 1, GetNumQuestLogEntries() do
        local name, _, _, _, _, _, _, _,  id = GetQuestLogTitle(i)
        name = Clear(name)
        if name == find then
            return id
        end
    end
end
