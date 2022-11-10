local Delver = require(game.ReplicatedStorage.Packages.delvergreatFolder.delvers.Delver)

Delver.AddRunner({
    Name = "hi",
    Sync = false,

    _normalData = "hi",
    ClientEndpoints = {
        Test = function()
            print("yay")
        end,
        Test2 = function()
            print("hehe")
        end
    },

    Middleware = {
        function(...)
            print("middle", ...)
            return ...
        end
    }
})


Delver.Start()

--Delver.Start()