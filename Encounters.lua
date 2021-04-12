local _, AddonTable = ...

local Id = AddonTable.EncounterDescriptions
local AddMistake = AddonTable.AddMistake
local Delay = AddonTable.Delay

local F = {}
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
        ["ENCOUNTER_START"] = function(Encounter, ...)
            Encounter.InProgress = true

            local CheckBossHP = function()
                if not Encounter.InProgress then return end

                if F.GetBossHealthPercentage() > 0.5 then
                    AddMistake("IngraMaloch.LowDps")
                end
            end

            Delay(90, CheckBossHP)
        end,
        ["ENCOUNTER_END"] = function(Encounter, ...)
            Encounter.InProgress = false
        end
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

local Stub_SpellsRegistrationHandlers = {
    [CLEU] = function(Encounter, ...)
        args = {...}
        local Source = args[5]
        if UnitPlayerControlled(Source) or UnitPlayerOrPetInParty(Source) then return end

        local Subevent = args[2]
        if string.sub(Subevent, 1, 5) ~= "SPELL" then return end

        local SpellId, SpellName
        if Subevent == "SPELL_ABSORBED" then
            SpellId = args[16]
            SpellName = args[17]
        else
            SpellId = args[12]
            SpellName = args[13]
        end

        if SpellId then
            AddonTable.SaveSpellInfo(SpellId, SpellName, Source, Subevent)
        end
    end
}

--** Tred'ova
Id[2393] = {
    Handlers = Stub_SpellsRegistrationHandlers
}


--** Spires of Ascension **--
--** Kin-Tara
Id[2357] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Ventunax
Id[2356] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Oryphrion
Id[2358] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Devos, Paragon of Loyalty
Id[2359] = {
    Handlers = Stub_SpellsRegistrationHandlers
}


--** Sanguine Depths **--
--** Kryxis the Voracious
Id[2360] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Executor Tarvold
Id[2361] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Grand Proctor Beryllia
Id[2362] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** General Kaal
Id[2363] = {
    Handlers = Stub_SpellsRegistrationHandlers
}


--** Theater of Pain **--
--** An Affront of Challengers
Id[2391] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Kul'tharok
Id[2364] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Gorechop
Id[2365] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Xav the Unfallen
Id[2366] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Mordretha
Id[2404] = {
    Handlers = Stub_SpellsRegistrationHandlers
}


--** Halls of Atonement **--
--** Halkias, the Sin-Stained Goliath
Id[2401] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Echelon
Id[2380] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** High Adjudicator Aleez
Id[2403] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Lord Chamberlain
Id[2381] = {
    Handlers = Stub_SpellsRegistrationHandlers
}


--** Plaguefall **--
--** Globgrog
Id[2382] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Doctor Ickus
Id[2384] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Domina Venomblade
Id[2385] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Stradama Margrave
Id[2386] = {
    Handlers = Stub_SpellsRegistrationHandlers
}


--** The Necrotic Wake **--
--** Blightbone
Id[2387] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Amarth, The Harvester
Id[2388] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Stichflesh
Id[2389] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Nalthor the Rimebinder
Id[2390] = {
    Handlers = Stub_SpellsRegistrationHandlers
}


--** De Other Side **--
--** Hakkar, the Soulflayer
Id[2395] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** The Manastorms
Id[2394] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Dealer Xy'exa
Id[2400] = {
    Handlers = Stub_SpellsRegistrationHandlers
}

--** Mueh'zala
Id[2396] = {
    Handlers = Stub_SpellsRegistrationHandlers
}



F.GetBossHealthPercentage = function(BossIndex)
    BossIndex = BossIndex or "1"

    local UnitId = "boss"..BossIndex
    local CurrentHP = UnitHealth(UnitId)
    local MaxHP = UnitHealthMax(UnitId)
    if MaxHP == 0 then
        F.Log("Cannot find boss with index "..BossIndex)
    end

    local RelativeHP = CurrentHP / MaxHP
    return RelativeHP
end

F.Log = function(Text)
    print(Text)
end
