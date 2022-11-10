local RunService = game:GetService("RunService")
local BridgeNet = require(script.Parent.Parent.Parent.BridgeNet)
local DelverBrdige = BridgeNet.CreateBridge("DelverBridge")

local Delver = {
	BridgeNet = BridgeNet,
	RunnersQueue = {},
	Runners = {},
}

export type Runner = {
	Name: string,
	Sync: boolean,

	OnPrepare: () -> (),
	OnRun: () -> (),

	ClientEndpoints: { [string]: () -> () }?,
	Middleware: { (Player, ...any) -> (any) }?,
	[any]: any,
}

local DefaultRunnerData = {
	Name = "string",
	Sync = "boolean",

	OnPrepare = "function",
	OnRun = "function",

	ClientEndpoints = "table",
	Middleware = "table",
}

local function createEndPointsForRunner(runnerDef: Runner)
	local tbl = {}
	if type(runnerDef.ClientEndpoints) ~= "table" then
		return
	end

	local bridge = BridgeNet.CreateBridge(runnerDef.Name)
	bridge:Connect(function(_, NameFunc, ...)
		local endpoint = (runnerDef.ClientEndpoints :: { [string]: () -> () })[NameFunc]

		if endpoint then
			endpoint(...)
		end
	end)

	if runnerDef.Middleware then
		bridge:SetInboundMiddleware(runnerDef.Middleware)
	end

	for Name in runnerDef.ClientEndpoints :: any do
		table.insert(tbl, Name)
	end
	return tbl
end

function Delver.AddRunner(runnerDef: Runner)
	for name, prop in runnerDef do
		local propType = type(prop)

		local shouldBeType = DefaultRunnerData[name]

		if shouldBeType ~= propType and shouldBeType ~= nil  then
				error(
					string.format(
						"Runner's %s should be %s rather than %s",
						name,
						shouldBeType,
						propType
					)
				)
		elseif shouldBeType == nil and propType ~= "function" and propType ~= "table" then
			local firstLetter = string.upper(string.sub(name, 1, 1))

			if firstLetter == "_" or firstLetter == "M" then
			else
				error(string.format("Runner's %s should not be global", name))
			end
		end
	end
	return table.insert(Delver.RunnersQueue, runnerDef)
end

function Delver.ReturnRunnerWithName(name: string)
	return Delver.Runners[name]
end

function Delver._runRunnersInQueue()
	local EndPointData = {}

	local RunnersQueue = Delver.RunnersQueue
	local PreparedRunners = table.create(#RunnersQueue)
	table.sort(RunnersQueue, function(a, b)
		local a_1 = a.Sync and 1 or 0
		local b_1 = b.Sync and 1 or 0

		return a_1 < b_1
	end)

	for _, Runner in RunnersQueue do
		if Runner.OnPrepare then
			Runner.OnPrepare()
		end
		if RunService:IsServer() then
			EndPointData[Runner.Name] = createEndPointsForRunner(Runner)
		end
		table.insert(PreparedRunners, Runner)
	end

	return EndPointData,
		function()
			for _, Runner in PreparedRunners do
				if Runner.OnRun == nil then
					continue
				end
				if Runner.Sync then
					Runner.OnRun()
				else
					task.spawn(Runner.OnRun)
				end
			end
			table.clear(Delver.RunnersQueue)
		end
end

function Delver._runDelverNetworking(constructedEndPointData)
	if RunService:IsServer() then
		DelverBrdige:Connect(function(sender)
			DelverBrdige:FireTo(sender, constructedEndPointData)
		end)
	else
		DelverBrdige:Fire()
		local finished = false
		DelverBrdige:Once(function(EndPointInfo)
			for RunnerName, EndPointData in EndPointInfo do
				Delver.Runners[RunnerName] = {}

				local bridge = BridgeNet.CreateBridge(RunnerName)

				for _, FuncName in EndPointData do
					Delver.Runners[RunnerName][FuncName] = function(...)
						bridge:Fire(FuncName, ...)
					end
				end
			end
			finished = true
		end)

		repeat
			task.wait()
		until finished
	end
end

function Delver.Start()
	local endPointData, Start = Delver._runRunnersInQueue()
	Delver._runDelverNetworking(endPointData)
	Start()
end

return Delver
