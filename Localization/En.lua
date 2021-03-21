local AddonName, AddonTable = ...
local AT = AddonTable
local Locale = "enUS"

local L = {}
AT.Localization[Locale] = L
AT.GetLocalizationDefault = function()
    local res = {}
    setmetatable(res, L)
    L.__index = L
    return res	    
end

-- We are using strings so we can easly default back to english of other locales are broken

--** Ingra Maloch **--
L["IngraMaloch.HitByPollen"] =  "Avoid standing in front of Oulfarran, when it casts blue cone of Bewildering Pollen or you get disoriented"

--** Mistcaller **--
L["Mistcaller.FrozenByFreezeTag"] = "When a blue fox appears, slow it down, CC it or even kill it. Make sure it doesn't reach anybody because it AoE freezes whoever it touches."
L["Mistcaller.ConfusedByCake"] = "Make sure the tank interrupts Patty Cake otherwise they'll get disoriented and lose aggro."
L["Mistcaller.HitByDodgeBall"] = "Don't stand in the way of the white arrows on the ground, they deal huge damage after a slight delay."
L["Mistcaller.Oopsie"] = "Take your time picking the correct illusion to kill. Killing the wrong one results in heavy AoE damage."
