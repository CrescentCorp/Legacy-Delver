local messages = require(script.messages)

local function log(loggerFunc, id, ...)
	local chosenMsg = messages[id]

	if chosenMsg == nil then
		error(string.format("\n[Delver | Internal] internal log didn't find the message assoicated with %s", id))
	end

	local formatedLog = string.format(chosenMsg, ...)
	loggerFunc("\n[Delver] " .. formatedLog .. ("\n id: %s"):format(id))
end

local logger = {}

function logger.logError(id, ...)
	log(error, id, ...)
end

function logger.logErrorNonBlocking(id, ...)
	task.spawn(function(id, ...)
		log(error, id, ...)
	end, id, ...)
end

function logger.logWarning(id, ...)
	log(warn, id, ...)
end

return logger
