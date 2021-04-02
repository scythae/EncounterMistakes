local _, AddonTable = ...
local AT = AddonTable
local Utils = {}
AT.utils = Utils
AT.Utils = Utils

Utils.ForEach = function(table, func)
    for i = 1, #table do
        func(table[i])
    end
end

Utils.PrintVal = function(val, indent)
    print(Utils.ToString(val))
end

Utils.ToString = function(val, indent)
    indent = indent or "  "

    local ToString
    ToString = function(val, oldIndent, newIndent)
        if type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return '"'..val..'"'
        elseif type(val) == "table" then
            local s = "{\n"
            for key, val in pairs(val)
            do
                s = s..newIndent.."["..ToString(key).."] = "..ToString(val, newIndent, newIndent..indent)..",\n"
            end
            s = s..oldIndent.."}"
            return s
        else
            error("Wrong key "..tostring(val))
        end
    end

    return ToString(val, "", "")
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
