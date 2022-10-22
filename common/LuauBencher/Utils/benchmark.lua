local function microOrMili(num)
	local MiliVersion = num * 1_000

	return if MiliVersion < 1 then tostring(num * 1_000_000).."us" else tostring(MiliVersion).."ms"
end

local function benchmark(calls: number, preRun: () -> (any), run: (any) -> (), postRun: () -> ())
	local rawBenchmark = table.create(calls)

	for _ = 1, calls do
		local preParams = preRun()
		local timeStart = os.clock()
		run(preParams)
		local timeEnd = os.clock()
		postRun()

		table.insert(rawBenchmark, timeEnd - timeStart)
	end

	table.sort(rawBenchmark)

	return function()
		local numTotal = 0
		local sizeOfRawBenchmark = #rawBenchmark

		for _, timeTaken in rawBenchmark do
			numTotal += timeTaken
		end

		return {
			_TOTAL = microOrMili(numTotal),
			_AVERAGE = microOrMili(numTotal / sizeOfRawBenchmark),
			_MIN = microOrMili(rawBenchmark[1]),
			_MAX = microOrMili(rawBenchmark[sizeOfRawBenchmark]),
			_10PERCENTILE = microOrMili(rawBenchmark[math.ceil(sizeOfRawBenchmark * 0.1)]),
			_50PERCENTILE = microOrMili(rawBenchmark[math.ceil(sizeOfRawBenchmark * 0.5)]),
			_90PERCENTILE = microOrMili(rawBenchmark[math.ceil(sizeOfRawBenchmark * 0.9)]),
		}
	end
end

return benchmark
