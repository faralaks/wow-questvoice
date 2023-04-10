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

    print(addonName, addonVer, "By Faralaks Started!");

    local x, y, width, height = -90, 13, 75, 23
    if IsAddOnLoaded("QuestGuru") then
        x, y, width, height = -230, 22, 75, 21
    end

    local frame = CreateFrame("Button", "PlayButton", QuestLogFrame, "UIPanelButtonTemplate")
    frame:SetText("Play")
    frame:SetWidth(width)
    frame:SetHeight(height)
    frame:SetPoint("BOTTOMRIGHT", QuestLogFrame, "BOTTOMRIGHT", x, y)
    frame:SetScript("OnClick", Main.Selected)
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
