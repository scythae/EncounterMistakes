local AddonName, AddonTable = ...
local AT = AddonTable

local E = {}
AT.Encounters = E

local L
E.SetLocalization = function(Localization)
    L = Localization
end

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
                
                -- Bewildering Pollen
                if (SpellId == 323137) and (UnitIsPlayer(Target) or UnitInParty(Target)) then
                    Self.HitByPollen = true
                end
            end
        end,        
    },
    GetMistakes = function(Self)
        if Self.HitByPollen then
            return L["IngraMaloch.HitByPollen"]
        end
    end    
}

--** Mistcaller
Id[2392] = {
    Handlers = {
        [CLEU] = function(Self, ...)
            args = {...}
            if args[2] == "SPELL_AURA_APPLIED" then

                local Target = args[9]
                local SpellName = args[13]

                if (SpellName == "Freezing Burst") and (UnitIsPlayer(Target) or UnitInParty(Target)) then
                    Self.FrozenByFreezeTag = true
                end
                if (SpellName == "Patty Cake") and (UnitIsPlayer(Target) or UnitInParty(Target)) then
                    Self.ConfusedByCake = true
                end
            end
            if args[2] == "SPELL_DAMAGE" then

                local SpellName = [13]

                if SpellName == "Dodge Ball" then
                    Self.HitByDodgeBall = true
                elseif SpellName == "Oopsie" then
                    Self.Oopsie = true
                end
            end
        end
    },
    GetMistakes = function(Self)
        if Self.FrozenByFreezeTag then
            return L["Mistcaller.FrozenByFreezeTag"]
        end
        if Self.ConfusedByCake then
            return L["Mistcaller.ConfusedByCake"]
        end
        if Self.HitByDodgeBall then
            return L["Mistcaller.HitByDodgeBall"]
        end
        if Self.Oopsie then
            return L["Mistcaller.Oopsie"]
        end
    end
}

--** Tred'ova
Id L["Mistcaller.--**"]
 
}


function RefineEncounterIdList()
    local id, encounter
    for id, encounter in pairs(E.EncounterIdList) do
        encounter.Handlers = encounter.Handlers or {}
        encounter.GetMistakes = encounter.GetMistakes or (function(Self) end)
    end
end
RefineEncounterIdList()
