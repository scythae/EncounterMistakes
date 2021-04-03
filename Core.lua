local AddonName, AddonTable = ...
local AT = AddonTable
local SlashCommand = "/enmi"

AT.Localizations = {}

local EncounterDescriptions = {}
AT.EncounterDescriptions = EncounterDescriptions

local Core = {}
local Encounter
local SavedSpells

Core.Run = function()
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetScript("OnEvent", Core.OnAddonLoaded)
    f:RegisterEvent("ADDON_LOADED")
end

Core.OnAddonLoaded = function(Frame, Event, Name)
    if Name ~= AddonName then return end

    _G["SLASH_"..AddonName.."1"] = SlashCommand
    SlashCmdList[AddonName] = Core.OnSlashCommand
    Core.Report(AddonName.." - "..SlashCommand)

    local s = AddonName.."Settings"
    Core.Settings = _G[s] or {}
    _G[s] = Core.Settings

    Core.Localization = AT.Localizations[GetLocale()]

    AT.SaveSpellInfo = Core.SaveSpellInfo

    Core.Settings.GUI = Core.Settings.GUI or {}
    AT.GUI.Show(Core.Settings.GUI)

    SavedSpells = Core.Settings.SavedSpells or {}
    Core.Settings.SavedSpells = SavedSpells

    Frame:UnregisterEvent("ADDON_LOADED")
    Frame:SetScript("OnEvent", Core.OnEvent)
    Frame:RegisterEvent("ENCOUNTER_START")
    Frame:RegisterEvent("ENCOUNTER_END")
end

Core.OnEvent = function(Frame, Event, ...)
    if Event == "ENCOUNTER_START" then
        Core.OnEncounterStart(Frame, ...)
    end

    Core.OnEncounterCustomEvent(Event, ...)

    if Event == "ENCOUNTER_END" then
        Core.OnEncounterEnd(Frame, ...)
    end
end

Core.OnEncounterStart = function(Frame, EncounterId, Title)
    if not Core.StartEncounter(EncounterId, Title) then return end

    for EncounterEvent, _ in pairs(Encounter.Handlers) do
        Frame:RegisterEvent(EncounterEvent)
    end
end

Core.StartEncounter = function(EncounterId, Title)
    local Description = EncounterDescriptions[EncounterId]
    if not Description then return end

    Encounter = {}
    Encounter.Title = Title
    Encounter.StartTime = GetTime()
    Encounter.Handlers = Description.Handlers or {}
    Encounter.Mistakes = {}

    Core.Report("Encounter started: "..Encounter.Title)

    AT.GUI.Clear()

    return true
end

Core.OnEncounterEnd = function(Frame, _, _, _, _, Success)
    if not Encounter then return end

    for EncounterEvent, _ in pairs(Encounter.Handlers) do
        if not (EncounterEvent == "ENCOUNTER_START" or EncounterEvent == "ENCOUNTER_START") then
            Frame:UnregisterEvent(EncounterEvent)
        end
    end

    Core.EndEncounter(Success)
end

Core.EndEncounter = function(Success)
    if not Encounter then return end

    Core.Report(((Success == 1) and "Victory" or "Wipe")..": "..Encounter.Title)

    if not Core.Settings.ShowMistakesImmediately then
        Core.ReportAllMistakes()
    end

    Encounter = nil
end

Core.OnEncounterCustomEvent = function(Event, ...)
    if not Encounter then return end

    local Handler = Encounter.Handlers[Event]
    if Handler then
        if Event == "COMBAT_LOG_EVENT_UNFILTERED" then
            Handler(Encounter, CombatLogGetCurrentEventInfo())
        else
            Handler(Encounter, ...)
        end
    end
end

Core.ReportAllMistakes = function()
    if not Encounter or not Encounter.Mistakes then return end

    for _, Mistake in pairs(Encounter.Mistakes) do
        Core.ReportMistake(Mistake)
    end
end

Core.ReportMistake = function(Mistake)
    --Core.ReportMistakeInChat(Mistake)
    AT.GUI.AddMistake(Mistake)
end

Core.ReportMistakeInChat = function(Mistake)
    Core.Report(Mistake.Text)
    local CountByPlayers = Mistake.CountByPlayers
    if CountByPlayers then
        local BadGuys = ""
        for Player, Count in pairs(CountByPlayers) do
            BadGuys = BadGuys..Player.." - "..Count..". "
        end
        Core.Report(BadGuys)
    end
end

Core.AddMistake = function(MistakeName, Player)
-- assuming Mistakes scheme as follows:
-- Mistakes = {
--     ["HitByFire"] = {
--         CountByPlayers = {"Player1" = 4, "Player2" = 2, "Player3" = 3} -- OptionalParam
--     },
--     ...
-- }

    local M = Encounter.Mistakes[MistakeName] or {}

    M.Name = MistakeName
    M.Text = Core.Localization[MistakeName]

    if Player then
        M.CountByPlayers = M.CountByPlayers or {}
        M.CountByPlayers[Player] = (M.CountByPlayers[Player] or 0) + 1
    end

    Encounter.Mistakes[MistakeName] = M

    Core.OnNewEncounterMistake(M)
end
AT.AddMistake = Core.AddMistake

Core.OnNewEncounterMistake = function(Mistake)
    if Core.Settings.ShowMistakesImmediately then
        Core.ReportMistake(Mistake)
    end
end

Core.SaveSpellInfo = function(SpellId, SpellName, Source, CombatLogEvent)
    if SavedSpells[SpellId] then return end

    local Spell = {}
    Spell.Name = SpellName
    Spell.Source = Source
    Spell.Encounter = Encounter and Encounter.Title
    Spell.CombatLogEvent = CombatLogEvent

    SavedSpells[SpellId] = Spell
end


Core.Report = print
Core.Trace = print


-- SlashCommand handlers --

Core.OnSlashCommand = function(Msg)
    local Dispatch = function (Command, ...)
        local Handler = Core.SlashCommands[Command]
        if Handler then
            Core.Report(SlashCommand.." "..Msg.." command is being executed...")
            Handler(...)
        else
            Core.SlashCommands["help"]()
        end
    end

    Dispatch(strsplit(" ", strlower(Msg)))
end

Core.SlashCommands = {}
Core.SlashCommands["help"] = function()
    Core.Report(AddonName..[[ slash commands:
"/enmi help" - shows this help
"/enmi test" - runs an example of failed fight against Mistcaller
"/enmi smi 1" - turns ShowMistakesImmediately option on, 0 for turning off
]]
    )
end

Core.SlashCommands["smi"] = function(Enabled)
    Core.Settings.ShowMistakesImmediately = Enabled == "1"
end

Core.SlashCommands["test"] = function()
    local OldEncounter
    local M = Core.AddMistake
    local Q = AT.CreateQueue()

    local PlayerName = UnitName("player")

    Core.Trace("Starting encounter soon...")
    Q:AddTask(1, function()
        OldEncounter = Encounter
        Core.StartEncounter(2392, "Mistcaller test")
    end)
    Q:AddTask(1, M, "Mistcaller.FrozenByFreezeTag", PlayerName)
    Q:AddTask(0, M, "Mistcaller.ConfusedByCake", PlayerName)
    Q:AddTask(0, M, "Mistcaller.ConfusedByCake", "Jack")
    Q:AddTask(1, M, "Mistcaller.HitByDodgeBall", "Jeff")
    Q:AddTask(0, M, "Mistcaller.HitByDodgeBall", "George")
    Q:AddTask(0, M, "Mistcaller.HitByDodgeBall", "Jack")
    Q:AddTask(0, M, "Mistcaller.HitByDodgeBall", "Jack")
    Q:AddTask(0, M, "Mistcaller.HitByDodgeBall", PlayerName)
    Q:AddTask(0, M, "Mistcaller.Oopsie")
    Q:AddTask(0, function()
        Core.EndEncounter(0)
        Encounter = OldEncounter
    end)
end

Core.SlashCommands["spells"] = function()
    AT.Utils.PrintVal(SavedSpells)
end

Core.Run()
