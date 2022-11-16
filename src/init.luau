local RunService = game:GetService("RunService")
local BridgeNet = require(script.Parent.Parent.Parent.BridgeNet)
local DelverBrdige = BridgeNet.CreateBridge("DelverBridge")
local logging = require(script.logging)

local Delver = {
	BridgeNet = BridgeNet,
	RunnersQueue = {},
	Runners = {},
	_PlayerRecord = {},
}

export type Runner = {
	Name: string,
	Sync: boolean,

	OnPrepare: (self: Runner) -> ()?,
	OnRun: (self: Runner) -> ()?,
	OnHeartbeat: (self: Runner, deltaTime: number) -> ()?,
	OnRender: (self: Runner, deltaTime: number) -> ()?,
	OnStepped: (self: Runner, time: number, deltaTime: number) -> ()?,

	ClientEndpoints: { [string]: () -> () }?,
	Middleware: { (Player, ...any) -> (any) }?,
	[any]: any,
}

local DefaultRunnerDataTypes = {
	Name = "string",
	Sync = "boolean",

	OnPrepare = "function",
	OnRun = "function",
	OnHeartbeat = "function",
	OnRender = "function",
	OnStepped = "function",
	ClientEndpoints = "table",
	Middleware = "table",
}

local allowedTags = {
	["_"] = true,
	["M_"] = true,
}

local function createEndPointsForRunner(runnerDef: Runner)
	local endPoints = {}

	if type(runnerDef.ClientEndpoints) ~= "table" then
		return
	end

	for Name in runnerDef.ClientEndpoints :: any do
		table.insert(endPoints, Name)
	end

	local bridge = BridgeNet.CreateBridge(runnerDef.Name)
	local middleware = runnerDef.Middleware
	bridge:OnInvoke(function(plr, NameFunc, ...)
		if middleware then
			local lastParam = table.pack(plr, NameFunc, ...)
			for _, func in middleware do
				lastParam = table.pack(func(table.unpack(lastParam)))

				if #lastParam == 0 then
					return 0
				end
			end
		end
		local endpoint = (runnerDef.ClientEndpoints :: { [string]: () -> () })[NameFunc]

		if endpoint then
			return endpoint(plr, ...)
		end
		return 0
	end)
	return endPoints
end
function checkNamingRulesForNonStandard(runnerName, propType, propName)
	if propType == "function" or propType == "table" or propType == "Instance" then
		return true
	end

	local firstLetter = string.upper(string.sub(propName, 1, 1))

	if allowedTags[firstLetter] then
		return true
	else
		logging.logError("unCoveredDataFields", runnerName, propName)
		return false
	end
end

function Delver.AddRunner(runnerDef: Runner)
	for name, prop in runnerDef do
		local propType = typeof(prop)
		local shouldBeType = DefaultRunnerDataTypes[name]

		if shouldBeType ~= propType and shouldBeType ~= nil then
			logging.logError("unMatchedStandardType", runnerDef.Name, name, shouldBeType, propType)
		elseif shouldBeType == nil then
			checkNamingRulesForNonStandard(runnerDef.Name, propType, name)
		end
	end

	setmetatable(runnerDef, {
		__newindex = function(_, key, value)
			if DefaultRunnerDataTypes[key] then
				logging.logErrorNonBlocking("dynamicStandardKeys", runnerDef.Name, key)
			end
			checkNamingRulesForNonStandard(runnerDef.Name, typeof(value), key)
		end,
	})

	table.insert(Delver.RunnersQueue, runnerDef)
	Delver.Runners[runnerDef.Name] = runnerDef
	return runnerDef
end

function Delver.ReturnRunnerWithName(name: string)
	return Delver.Runners[name]
end

function Delver.Start()
	local endPointData = {}

	local RunnersQueue = Delver.RunnersQueue
	local PreparedRunners = table.create(#RunnersQueue)

	local isServer = RunService:IsServer()
	table.sort(RunnersQueue, function(runA, runB)
		local aNum = runA.Sync and 1 or 0
		local bNum = runB.Sync and 1 or 0

		return aNum < bNum
	end)

	for _, Runner in RunnersQueue do
		if Runner.OnPrepare then
			Runner:OnPrepare()
		end

		if isServer then
			local data = createEndPointsForRunner(Runner)

			if data and #data > 0 then
				endPointData[Runner.Name] = data
			end
		end

		table.insert(PreparedRunners, Runner)
	end

	table.clear(Delver.RunnersQueue)

	if isServer then
		DelverBrdige:Connect(function(sender)
			if Delver._PlayerRecord[sender] then
				return
			end
			DelverBrdige:FireTo(sender, endPointData)
			Delver._PlayerRecord[sender] = true
		end)
	else
		DelverBrdige:Fire()
		local finished = false

		DelverBrdige:Once(function(endPointData)
			for RunnerName, RunnerEndPoints in endPointData do
				Delver.Runners[RunnerName] = {}
				local Runner = Delver.Runners[RunnerName]

				local bridge = BridgeNet.CreateBridge(RunnerName)

				for _, FuncName in RunnerEndPoints do
					Runner[FuncName] = function(...)
						return bridge:InvokeServerAsync(FuncName, ...)
					end
				end
				finished = true
			end
		end)
		repeat
			task.wait()
		until finished
	end

	for _, Runner in PreparedRunners do
		if Runner.OnRender then
			if isServer then
				error("OnRender isn't usable on the server")
			end
			RunService.RenderStepped:Connect(function(...)
				Runner:OnRender(...)
			end)
		end

		if Runner.OnHeartbeat then
			RunService.Heartbeat:Connect(function(...)
				Runner:OnHeartbeat(...)
			end)
		end

		if Runner.OnStepped then
			RunService.Stepped:Connect(function(...)
				Runner:OnStepped(...)
			end)
		end

		if Runner.OnRun then
			if Runner.Sync then
				Runner:OnRun()
			else
				task.spawn(Runner.OnRun, Runner)
			end
		end
	end

	table.clear(PreparedRunners)
end

return Delver
