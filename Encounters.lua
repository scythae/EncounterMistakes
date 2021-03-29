local _, AddonTable = ...

local Id = AddonTable.EncounterDescriptions
local AddMistake = AddonTable.AddMistake

local CLEU = "COMBAT_LOG_EVENT_UNFILTERED"

--** Tirna Scithe **--
--** Ingra Maloch
Id[2397] = {
    Handlers = {
        [CLEU] = function(Encounter, ...)
            args = {...}
            if args[2] == "SPELL_AURA_APPLIED" then
                local Target = args[9]
                local SpellId = args[12]

                if SpellId == 323137 then -- Bewildering Pollen
                    AddMistake("IngraMaloch.HitByPollen", Target)
                end
            end
        end,
    },
}

--** Mistcaller
Id[2392] = {
    Handlers = {
        [CLEU] = function(Encounter, ...)
            args = {...}
            local Subevent = args[2]
            local Target = args[9]
            local SpellId = args[12]

            if Subevent == "SPELL_AURA_APPLIED" then
                if SpellId == 321893 then -- Freezing Burst
                    AddMistake("Mistcaller.FrozenByFreezeTag", Target)
                elseif SpellId == 321828 then -- Patty Cake
                    AddMistake("Mistcaller.ConfusedByCake", Target)
                end
            end
            if Subevent == "SPELL_DAMAGE" then
                if SpellId == 321834 then --"Dodge Ball"
                    AddMistake("Mistcaller.HitByDodgeBall", Target)
                elseif SpellId == 321837 then --"Oopsie"
                    AddMistake("Mistcaller.Oopsie")
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
        [CLEU] = function(Encounter, ...)
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