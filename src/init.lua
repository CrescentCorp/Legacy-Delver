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
	assert(type(runnerDef.Name) == "string", "Runner's name should be string")
	assert(type(runnerDef.Sync) == "boolean", "Runner's Sync should be explicitly defined as a boolean")

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
		Runner.OnPrepare()
		if RunService:IsServer() then
			EndPointData[Runner.Name] = createEndPointsForRunner(Runner)
		end
		table.insert(PreparedRunners, Runner)
	end

	return EndPointData,
		function()
			for _, Runner in PreparedRunners do
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
