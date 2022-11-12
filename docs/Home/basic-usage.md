# Basic Usage

Assuming that you have installed Delver and put it in `ReplicatedStorage`, now we can reference it like this:
```Lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Delver = require(ReplicatedStorage.Packages.delver)
```

To register a runner to Delver, we use the `Delver.AddRunner` helper function. This function in your Delver journey would be the one that either makes you hate every second of yourself, or to be grateful to it due to how many bugs it saved you from crossing upon.

Adding a runner is as simple as:
```Lua
local MoneyRunner = Delver.AddRunner({
    Name = "MoneyRunner",
    Sync = false,

    _money = 0,

    GetMoney = function(self)
        return self._money
    end,

    SetMoney = function(self, value)
        if type(value) == "number" then
            self._money = value
            return true
        else
            return false
        end
    end
})
```

??? notice "Runner's Defining"
    This way of defining runners isn't a "strict" practice that you should always follow. I like using this way, so I use it although you are free to use whatever defining method you would like as long as it doesn't mess with anything.

Now that we have added a base runner, let's start Delver. We can do so by doing:

```Lua
Delver.Start()
```
Delver's Start function yields the current thread until it finishes its work, so directly using another function Delver provides that is `Delver.ReturnRunnerWithName` would be considered safe.

So, to use our `MoneyRunner`, we could retrieve it and then do whatever we want with it:

```Lua

local MoneyRunner = Delver.ReturnRunnerWithName("MoneyRunner")

local function cprint(...)
    print("current value:", ...)
end

cprint(MoneyRunner:GetMoney())
MoneyRunner:SetMoney(40)
cprint(MoneyRunner:GetMoney())
```

Congrats! You just used Delver for the first time! Though this example was just an introduction usage to Delver, the ~~heaviy~~ interesting stuff are coming!

For now, try playing around with our `MoneyRunner`, specifically with:

1. `_money`'s name, trying removing the `_` and observe what happens or...
2. adding `self.writeUses = (self.writeUses or 1) + 1` after writing `_money` and see what happens
3. Try adding a few other functions