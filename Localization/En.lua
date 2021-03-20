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

L["IngraMaloch.HitByPollen"] =  "Avoid standing in front of Oulfarran, when it casts blue cone of Bewildering Pollen or you get disoriented"