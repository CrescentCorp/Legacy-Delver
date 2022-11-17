local Holder: any = {}

--[[ 
    returning booleans determines whether the state object should dismiss the update or not.
    In addition to that, returning new_value/current_value is disallowed as it opens the gate
    for side effects and unexpected alterations.
]]
-- Holder(og value, updateManager)
local State = Holder(Instance.new("Part"), function(current_value, new_value)
	if typeof(new_value) == "Instance" then
		current_value:Destroy()
		return true
	else
		return false
	end
end)

State:set(Instance.new("Part"))

local AutoState = Calc(function(useState)
	return useState(State):Clone()
end, function(current_value, new_value)
	current_value:Destroy()
	return true
end)

print(AutoState:get())

State:set(Instance.new("Part"))
print(AutoState:get())
