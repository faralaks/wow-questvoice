addonName = "QuestVoice"
addonVer = "v1.0.3"

AcceptAction = "accept"
CompleteAction = "complete"
QuestType = "quest"
GossipType = "gossip"

Main = LibStub("AceAddon-3.0"):NewAddon(addonName)
LibStub("AceEvent-3.0"):Embed(Main)
Timer = LibStub("AceTimer-3.0")

function Main:OnDisable() end
function Main:OnInitialize() end


function Main:OnEnable()
    Main:RegisterEvent("QUEST_ACCEPTED", "Started")
    Main:RegisterEvent("QUEST_COMPLETE", "Finished")
    Main:RegisterEvent("GOSSIP_SHOW", "Gossip")

    Timer.ScheduleTimer(Main, "Init", 1)
end



function Main:Init()
    local mode ="Native"

    local questMenuButton = {
        name = "PlayButton",
        x = -90,
        y = 13,
        width = 75,
        height = 23,
        parent = QuestLogFrame,
        anchor = QuestLogFrame,
        anchorBy = "BOTTOMRIGHT",
        anchorTo = "BOTTOMRIGHT",
        text = "Play",
        onClick = Main.Selected,
    }

    if IsAddOnLoaded("Carbonite") then
        questMenuButton.x, questMenuButton.y, questMenuButton.width, questMenuButton.height, questMenuButton.parent, questMenuButton.anchor = -60, -5, 55, 22, NxQuestD, NxQuestD
        questMenuButton.anchorBy, questMenuButton.anchorTo, mode = "TOPLEFT", "TOPRIGHT",  "Carbonite"

    elseif IsAddOnLoaded("QuestGuru") then
        questMenuButton.x, questMenuButton.y, questMenuButton.width, questMenuButton.height, mode = -230, 22, 75, 21, "QuestGuru"
    end

    SetupButton(questMenuButton)
    print(addonName, addonVer, "By Faralaks Started in", mode, "mode!")
end

function SetupButton(button)
    local frame = CreateFrame("Button", button.name, button.parent, "UIPanelButtonTemplate")
    frame:SetText(button.text)
    frame:SetWidth(button.width)
    frame:SetHeight(button.height)
    frame:SetPoint(button.anchorBy, button.anchor, button.anchorTo, button.x, button.y)
    frame:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
    frame:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
    frame:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
    frame:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
    frame:SetScript("OnClick", button.onClick)
end

function BuildVoiceAndDescription(type, id, name, action)
    local dir = "interface\\addons\\"..addonName.."\\voices\\"..type.."\\"
    local voice = ""
    local description = ""

    if type == "quest" then
        voice = dir..id.."-"..action..".mp3"
        description = name.." ("..id..") "..action
        return voice, description

    elseif type == "gossip" then
        voice = dir..id..".mp3"
        description = name.." ("..id..") "
        return voice, description

    end

    print(addonName, "Error: Unknown type:", type)
    return nil, nil
end

function Main:Play(voice, voiceDescription)
    if voice == nil then
        voice = self.voice
    end

    if voiceDescription == nil then
        voiceDescription = self.voiceDescription
    end

    if voice == nil then
        print(addonName, "Error: No voice is nil!")
        return nil
    end

    PlaySoundFile(voice)
    print(addonName..":", voiceDescription)
end

function Main:WaitThenPlay(type, id, name, action, wait)
    self.voice, self.voiceDescription = BuildVoiceAndDescription(type, id, name, action)
    Timer.ScheduleTimer(Main, "Play", wait)
end

function Main:Gossip()
    if not UnitExists("target") then
        return
    end

    local gossipText = GetGossipText()
    local guid = tonumber(UnitGUID("target"):sub(6, -7), 16)
    local targetName = UnitName("target")

    --print("GOSSIP_SHOW", guid, targetName, "RawID:", UnitGUID("target"):sub(6, -7));
    local voiceID = GossipToVoice(guid, gossipText)
    if voiceID == nil then
        print(addonName, "Error: No voice found for", targetName, "("..guid..")")
        return
    end

    Main.voice, Main.voiceDescription = BuildVoiceAndDescription(GossipType, voiceID, targetName)
    Main:Play()
end

function GossipToVoice(npcID, gossipText)
    local npcTexts2Voices = NPCToTextToTemplateHash[npcID]
    if not npcTexts2Voices then
        return nil
    end

    local voicesCount, searchResult = 0, ""
    local npcTexts = {}
    for text, _ in pairs(npcTexts2Voices) do
        table.insert(npcTexts, text)
        voicesCount = voicesCount + 1
        searchResult = text
    end

    if voicesCount == 1 then
        return npcTexts2Voices[searchResult]
    end

    searchResult = VOICEOVER_fuzzySearchBest(gossipText, npcTexts)
    if searchResult == nil then
        print("searchResult is nil! but Count is", voicesCount)
        return nil
    end

    searchResult = searchResult.text
    return npcTexts2Voices[searchResult]
end


function Main:Selected()
    local questIndex = GetQuestLogSelection()
    local name, _, _, _, _, _, _, _,  id = GetQuestLogTitle(questIndex)
    Main:WaitThenPlay(QuestType, id, name, AcceptAction, 0.3)
end


function Main:Started(_, questIndex)
    local name, _, _, _, _, _, _, _,  id = GetQuestLogTitle(questIndex)
    Main:WaitThenPlay(QuestType, id, name, AcceptAction, 1)
end

function Main:Finished()
    local name = GetTitleText()
    local id = Find(name)
    Main:WaitThenPlay(QuestType, id, name, CompleteAction, 0.3)
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
