local Delver = require(game.ReplicatedStorage.Packages.delvergreatFolder.delvers.Delver)

Delver.AddRunner({
    Name = "hi",
    Sync = false,

    OnRun = function(self)
        
    end,
    _normalData = "hi",
    ClientEndpoints = {
        Test = function()
            print("yay")
            return "hi"
        end,
        Test2 = function()
            print("hehe")
            return ""
        end
    },

    Middleware = {
        function(...)
            print("middle", ...)
            return 2
        end,
    }
})

Delver.AddRunner({
    Name = "MoneyRunner",
    Sync = true,

    _money = 0,

    OnPrepare = 1,
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


Delver.Start()

local MoneyRunner = Delver.ReturnRunnerWithName("MoneyRunner")

local function cprint(...)
    print("current value:", ...)
end

cprint(MoneyRunner:GetMoney())
MoneyRunner:SetMoney(40)
cprint(MoneyRunner:GetMoney())

--Delver.Start()