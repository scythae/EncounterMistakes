local _, AddonTable = ...
local CheckInterval = 0.1

local Core = {}
Core.Tasks = {}
local ElapsedSinceLastCheck = 0

Core.Run = function()
	CreateFrame("Frame"):SetScript("OnUpdate", Core.OnUpdate)
	AddonTable.Delay = Core.Delay
	AddonTable.CreateQueue = Core.CreateQueue
end

Core.Delay = function(DelayInSeconds, Callback, ...)
	if not(
		type(DelayInSeconds) == "number"
		and type(Callback) == "function"
	) then
		local err = "Usage: %s(DelayInSeconds: number, Callback: function, [arg1: anytype, arg2: anytype, ...])"
		err = string.format(err, "Delay")
		error(err, 2)
	end

	local WhenExecute = GetTime() + tonumber(DelayInSeconds)

	local Task = {}
	Task.Time = WhenExecute
	Task.Callback = Callback
	Task.Arguments = {...}

	table.insert(Core.Tasks, Task)
end

Core.OnUpdate = function(Self, Elapsed)
	ElapsedSinceLastCheck = ElapsedSinceLastCheck + Elapsed
	if ElapsedSinceLastCheck < CheckInterval then return end
	ElapsedSinceLastCheck = ElapsedSinceLastCheck - CheckInterval

	Core.RunTasks()
end

Core.RunTasks = function()
	local Tasks = Core.Tasks
	if #Tasks == 0 then return end

	local Now = GetTime()

	for i = #Tasks, 1, -1
	do
		local Task = Tasks[i]
		if Task.Time < Now then
			table.remove(Tasks, i)
			Task.Callback(unpack(Task.Arguments))
		end
	end
end

Core.CreateQueue = function()
	local Queue = {}
	local Delay = Core.Delay

	function Queue:AddTask(Time, Func, ...)
        local ThisTask = {}
        ThisTask.Time = Time
        ThisTask.Func = Func
		ThisTask.Args = {...}

		local Self = self


        local DoThisAndDelayNext
        DoThisAndDelayNext = function(ThisTask)
            ThisTask.Func(unpack(ThisTask.Args))

			local NextTask = ThisTask.NextTask
			if NextTask then
				Delay(NextTask.Time, DoThisAndDelayNext, NextTask)
			else
				Self.LastTask = nil
            end
        end

        if self.LastTask then
            self.LastTask.NextTask = ThisTask
        else
            Delay(Time, DoThisAndDelayNext, ThisTask)
        end

        self.LastTask = ThisTask
	end

	return Queue
end

Core.Run()