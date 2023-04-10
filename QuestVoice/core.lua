local Main = LibStub("AceAddon-3.0"):NewAddon("QuestVoice")
LibStub("AceEvent-3.0"):Embed(Main)
local Timer = LibStub("AceTimer-3.0")

function Main:OnDisable() end
function Main:OnInitialize() end


function Main:OnEnable()
    Main:RegisterEvent("QUEST_ACCEPTED", "Started")
    Main:RegisterEvent("QUEST_COMPLETE", "Finished")

    print("QuestVoice By Faralaks Started!");

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

function Play(id, name, action)
    local voice = id .. "-" .. action
    PlaySoundFile("interface\\addons\\QuestVoice\\voices\\"..voice..".mp3")
    print("QuestVoice:", name, "("..id..")", action)
end

function Main:WaitThenPlay(id, name, action, wait)
    Timer.ScheduleTimer(Main, Play, wait, id, name, action)
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


function Find(find)
    for i = 1, GetNumQuestLogEntries() do
        local name, _, _, _, _, _, _, _,  id = GetQuestLogTitle(i)
        if name == find then
            return id
        end
    end
end
