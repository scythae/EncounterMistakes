local _, AddonTable = ...
local AT = AddonTable
local Locale = "enUS"

local L = {}
AT.Localizations[Locale] = L
AT.GetLocalizationDefault = function()
    local res = {}
    setmetatable(res, L)
    L.__index = L
    return res
end

-- We are using strings so we can use english as a default if other locales are broken

L["IngraMaloch.HitByPollen"] = "Avoid standing in front of Oulfarran, when it casts blue cone of Bewildering Pollen or you get disoriented"
L["IngraMaloch.LowDps"] = "Dps feels low. Try to increase it by saving big dps cooldowns for the moment Ingra Maloch is overhelmed by Droman's Wrath. For this bring Oulfarran to 20% hp first."

L["Mistcaller.FrozenByFreezeTag"] = "When a blue fox appears, slow it down, CC it or even kill it. Make sure it doesn't reach anybody because it AoE freezes whoever it touches."
L["Mistcaller.ConfusedByCake"] = "Make sure the tank interrupts Patty Cake otherwise they'll get disoriented and lose aggro."
L["Mistcaller.HitByDodgeBall"] = "Don't stand in the way of the white arrows on the ground, they deal huge damage after a slight delay."
L["Mistcaller.Oopsie"] = "Take your time picking the correct illusion to kill. Killing the wrong one results in heavy AoE damage."

L["GrandProctorBeryllia.RiteOfSupremacy.NonMythic"] = "To survive Beryllia's Rite of Supremacy (non-mythic difficulty), cover under yellow barrier in the center of the arena."
L["GrandProctorBeryllia.RiteOfSupremacy.Mythic"] = "To survive Beryllia's Rite of Supremacy (mythic difficulty), gather little yellow spheres on the ground, 3 spheres is enough. If you got less than 3, use personal defensive abilities."