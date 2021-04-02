local AddonName, AddonTable = ...
local AT = AddonTable

local ReportOnSuccess = false

local function Assert (Condition, ErrorText)
    if not Condition then
        error(AddonName.." assertion fail: "..(ErrorText or "anonymous"))
    end
end

local Cases = {}
local function CheckIfAllCasesPassed()
    if not ReportOnSuccess then return end

    for _, Case in ipairs(Cases) do
        if not Case.Passed then
            return
        end
    end

    local Report = AddonName.." tests passed:"
    for _, Case in ipairs(Cases) do
        Report = Report.."\n"..(Case.Title or "Unnamed").." : "..Case.Time
    end

    print(Report)
end

local function NewCase(Title, Func)
    local Case = {}
    Case.Title = Title
    Case.Passed = false

    local StartTime

    function Case:Run()
        StartTime = GetTime()
        Func(self)
    end

    function Case:Pass()
        self.Passed = true
        self.Time = GetTime() - StartTime
        CheckIfAllCasesPassed()
    end

    table.insert(Cases, Case)
    return Case
end

NewCase("TestErrorHandling", function(Case)
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

    Case:Pass()
end)

NewCase("TestToString", function(Case)
    local t = {
        Husband = {
            Name = "John",
            Surname = "Doe",
            Hobbies = {"Football", "Guitar", Additional = "Fishing", "Radio"}
        },
        Wife = {
            Name = "Jane",
            Surname = "Doe"
        },
        YearsTogether = 6
    }

    local s = AT.utils.ToString(t)

    local LoadTable = loadstring("return "..s)
    local t2 = LoadTable()

    Assert(type(t2) == "table", "t2 not a table")
    Assert(
        type(t2) == "table" and
        t2.Husband.Hobbies[1] == "Football" and
        t2.Wife.Name == "Jane" and
        t2.YearsTogether == 6,
        "TestToString"
    )

    Case:Pass()
end)

NewCase("TestDelay", function(Case)
    local t = {}
    t.val = 0

    local func2 = function(t)
        Assert(t.val == 1, "delayfunc2 "..t.val)
        Case:Pass()
    end

    local func1 = function(t)
        Assert(t.val == 0, "delayfunc1 "..t.val)
        t.val = 1
        AT.Delay(2, func2, t)
    end

    AT.Delay(1, func1, t)

    Assert(t.val == 0)
end)

NewCase("TestQueue", function(Case)
    local t = {}
    t.val = 0

    local Q = AT.CreateQueue()

    Q:AddTask(
        2,
        function(t)
            Assert(t.val == 0, "delayfunc1 "..t.val)
            t.val = 1
        end,
        t
    )

    Q:AddTask(
        1,
        function(t)
            Assert(t.val == 1, "delayfunc2 "..t.val)
            t.val = 2
        end,
        t
    )

    Q:AddTask(
        1,
        function(t)
            Assert(t.val == 2, "delayfunc3 "..t.val)
            Case:Pass()
        end,
        t
    )
end)

NewCase("TestStringSplit", function(Case)
    local str = "enabled 1"
    local t = {strsplit(" ", str)}
    Assert(t[1] == "enabled")
    Assert(t[2] == "1")

    local str = "enabled  1"
    local t = {strsplit(" ", str)}
    Assert(t[1] == "enabled")
    Assert(t[2] == "")
    Assert(t[3] == "1")

    Case:Pass()
end)

do
    for _, Case in ipairs(Cases) do
        Case:Run()
    end
end
