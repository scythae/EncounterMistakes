local _, AddonTable = ...
local AT = AddonTable
local Utils = {}
AT.utils = Utils
AT.Utils = Utils

Utils.foreach_ = function(table, func)
    local i
    for i = 1, #table do
        func(table[i])        
    end      
end

Utils.printVal = function(val)
    if type(val) == "table" then
        local t = {}
        t[tostring(val)] = val
        Utils.printTable(t)
    else
        print(tostring(val))
    end
end

Utils.printTable = function(table, indent)
    indent = indent or ""
	local key, val
	for key, val in pairs(table)
    do
        if type(val) == "table" then
            print(indent..key.." = {")
            Utils.printTable(val, indent.."__")
            print(indent.."}")    
        else
            print(indent..key.." = "..tostring(val))
        end
    end
end

Utils.CreateFontString = function(parentFrame, text, size, font)
    local res = parentFrame:CreateFontString(nil, "OVERLAY")
    text = text or ""
    size = size or 18
    font = font or [[Fonts\FRIZQT__.TTF]]
    res:SetFont(font, size, "OUTLINE")
    res:SetText(text)
    return res
end

Utils.Try = function(Func, ...)
    return Utils.TryCatch(print, Func, ...)
end

Utils.TryCatch = function(OnError, Func, ...)
    local function DispatchCallResult(CallSuccess, ...)
        if CallSuccess then return ... end

        if type(OnError) == "function" then
            local ErrorDetails = ({...})[1]
            OnError(ErrorDetails)
        end
    end

    return DispatchCallResult(pcall(Func, ...))
end
