local AddonName, AddonTable = ...
local AT = AddonTable

local PrintVal = AT.utils.printVal

local InstantTestsHavePassed = false
local DelayedTestsHavePassed = false

local function Assert (Condition, ErrorText)
    if not Condition then
        error(AddonName.." assertion fail: "..(ErrorText or "anonymous"))
    end
end

local function PrintType(val)
    print(type(val))
end

local function TestErrorHandling () 
    local OutValues = {"OutValue1", "OutValue2"}
    local FunctionWithError = function(NeedError)
        if NeedError then
            error("CustomErrorText")
        end

        return "OutValue1", "OutValue2", "OutValue3" -- and so on
    end

    local CaseText = "When wrapped with 'pcall' function raises an error, ";
    local CallResult = {pcall(FunctionWithError, true)}    
    Assert(CallResult[1] == false, CaseText.."first value returned by pcall should be false")
    Assert(type(CallResult[2]) == "string", CaseText.."second value returned by pcall should be a string")
    local SecondValueContainsErrorText = string.find(CallResult[2], "CustomErrorText") ~= 0
    Assert(SecondValueContainsErrorText, CaseText.."second value returned by pcall should be containing an error text")

    local CaseText = "When wrapped with 'pcall' function succeeds, ";
    local CallResult = {pcall(FunctionWithError, false)}    
    Assert(#CallResult == 1 + 3, CaseText.."pcall should return one value as a result of call plus all of the values returned by the wrapped function")
    Assert(CallResult[1] == true, CaseText.."first value returned by pcall should be true")
    Assert(
        CallResult[2] == "OutValue1" and
        CallResult[3] == "OutValue2" and
        CallResult[4] == "OutValue3",
        CaseText.."all values returned by pcall after the first one should be the values returned by a wrapped function"
    )
end

local function TestPrintTable()
    local t = {
        Husband = {
            Name = "John",
            Surname = "Doe",
            Hobbies = {"Football", "Guitar"}
        },
        Wife = {
            Name = "Jane",
            Surname = "Doe"
        },
        YearsTogether = 6
    }
    PrintVal(t)    
end

local function TestDelay()
    local t = {}
    t.val = 0

    local func1 = function(t) 
        Assert(t.val == 0, "delayfunc1 "..t.val)
        t.val = 1
    end
    AT.Delay(1, func1, t)

    local func2 = function(t) 
        Assert(t.val == 1, "delayfunc2 "..t.val)
        t.val = 2

        if InstantTestsHavePassed then
            print(AddonName.." tests have passed.")
        end
    end
    AT.Delay(2, func2, t)    
    
    Assert(t.val == 0)
end    


local function RunTests()
    -- TestPrintTable()
    TestDelay()
    TestErrorHandling()

    InstantTestsHavePassed = true
end

RunTests()