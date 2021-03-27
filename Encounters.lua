local AddonName, AddonTable = ...
local AT = AddonTable

local E = {}
AT.Encounters = E

local CLEU = "COMBAT_LOG_EVENT_UNFILTERED"

local Id = {}
E.EncounterIdList = Id

--** Tirna Scithe **--
--** Ingra Maloch
Id[2397] = {
    Handlers = {
        [CLEU] = function(Self, ...)
            args = {...}
            if args[2] == "SPELL_AURA_APPLIED" then
                local Target = args[9]
                local SpellId = args[12]
                                
                if SpellId == 323137 then -- Bewildering Pollen
                    E.AddMistake(Self, "IngraMaloch.HitByPollen", Target)
                end
            end
        end,        
    },
}

--** Mistcaller
Id[2392] = {
    Handlers = {
        [CLEU] = function(Self, ...)
            args = {...}
            local Subevent = args[2]
            local Target = args[9]
            local SpellId = args[12]

            if Subevent == "SPELL_AURA_APPLIED" then
                if SpellId == 321893 then -- Freezing Burst
                    E.AddMistake(Self, "Mistcaller.FrozenByFreezeTag", Target)
                elseif SpellId == 321828 then -- Patty Cake
                    E.AddMistake(Self, "Mistcaller.ConfusedByCake", Target)
                end
            end
            if Subevent == "SPELL_DAMAGE" then
                if SpellId == 321834 then --"Dodge Ball"
                    E.AddMistake(Self, "Mistcaller.HitByDodgeBall", Target)
                elseif SpellId == 321837 then --"Oopsie"
                    E.AddMistake(Self, "Mistcaller.Oopsie")
                end
            end
        end
    },
}

--** Tred'ova
Id[2393] = {
 
}


--** Scraps/Handler examples
local NonExistentEncounterID = -1
Id[NonExistentEncounterID] =  {
    Handlers = {
        [CLEU] = function(Self, ...)
            args = {...}
            if args[2] == "SPELL_AURA_APPLIED" then                
                local Target = args[9]
                local SpellId = args[12]
                
                if (SpellId == 323137) and (UnitIsPlayer(Target) or UnitInParty(Target)) then
                end
            end
        end,        
    }
}

E.AddMistake = function(Encounter, MistakeName, Player)
    local M = Encounter.Mistakes[MistakeName] or {}

    if Player then
        M.CountByPlayers = M.CountByPlayers or {}
        M.CountByPlayers[Player] = (M.CountByPlayers[Player] or 0) + 1
    end

    Encounter.Mistakes[MistakeName] = M
end

function RefineEncounterIdList()
    local id, encounter
    for id, encounter in pairs(E.EncounterIdList) do
        encounter.Handlers = encounter.Handlers or {}
        encounter.Mistakes = encounter.Mistakes or {}  
        encounter.GetMistakes = function(Self) return Self.Mistakes end
    end
end
RefineEncounterIdList()
