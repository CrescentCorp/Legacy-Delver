local RunService = game:GetService("RunService")
local BridgeNet = require(script.Parent.Parent.Parent.BridgeNet)
local DelverBrdige = BridgeNet.CreateBridge("DelverBridge")

local Delver = {
	BridgeNet = BridgeNet,
	RunnersQueue = {},
	Runners = {},
	_PlayerRecord = {},
}

export type Runner = {
	Name: string,
	Sync: boolean,

	OnPrepare: () -> ()?,
	OnRun: () -> ()?,
	OnUpdate: (deltaTime: number) -> ()?,

	ClientEndpoints: { [string]: () -> () }?,
	Middleware: { (Player, ...any) -> (any) }?,
	[any]: any,
}

local DefaultRunnerData = {
	Name = "string",
	Sync = "boolean",

	OnPrepare = "function",
	OnRun = "function",
	OnUpdate = "function",

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
		table.insert(runnerDef.Middleware, 1, function(funcName, ...)
			if not (runnerDef.ClientEndpoints :: { [string]: () -> () })[funcName] or type(funcName) ~= "string" then
				return nil
			end
			return funcName, ...
		end)
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

		if shouldBeType ~= propType and shouldBeType ~= nil then
			error(string.format("%s's %s should be %s rather than %s", runnerDef.Name, name, shouldBeType, propType))
		elseif shouldBeType == nil and propType ~= "function" and propType ~= "table" then
			local firstLetter = string.upper(string.sub(name, 1, 1))

			if firstLetter == "_" or firstLetter == "M" then
			else
				error(
					string.format(
						"%s's %s should not be global - add either _ or M as the first characters to silence ",
						runnerDef.Name,
						name
					)
				)
			end
		end
	end
	return table.insert(Delver.RunnersQueue, runnerDef)
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
			Runner.OnPrepare()
		end

		if isServer then
			local data = createEndPointsForRunner(Runner)

			if data and #data > 0 then
				endPointData[Runner.Name] = data
			end
		end
		Delver.Runners[Runner.Name] = Runner

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
						bridge:Fire(FuncName, ...)
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
		if Runner.OnRun == nil then
			continue
		end

		if Runner.OnUpdate then
			RunService.Heartbeat:Connect(Runner.OnUpdate)
		end

		if Runner.Sync then
			Runner.OnRun()
		else
			task.spawn(Runner.OnRun)
		end
	end

	table.clear(PreparedRunners)
end

return Delver
