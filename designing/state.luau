local Holder: any = {}

--[[ 
    returning booleans determines whether the state object should dismiss the update or not.
    In addition to that, returning new_value/current_value is disallowed as it opens the gate
    for side effects and unexpected alterations.
]]
-- Holder(og value, shouldUpdate)
local State = Holder(123, function(current_value, new_value)
	if type(new_value) == "number" then
		return true
	else
		return false
	end
end)

State:set(123)

State:set("hi") -- doesn't work and Delver would log a warning

print(State:get()) -- prints 123

