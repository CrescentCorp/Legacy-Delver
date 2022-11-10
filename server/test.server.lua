local Delver = require(game.ReplicatedStorage.Packages.delvergreatFolder.delvers.Delver)

Delver.AddRunner({
    Name = "hi",
    Sync = false,

    MnormalData = "hi",
    OnPrepare = function()
    end,

    OnRun = function()
        while true do 
            print("hi")
            task.wait(2)
        end
    end,


})

Delver.AddRunner({
    Name = "ttt",
    Sync = true,

    OnPrepare = function()
    end,

    OnRun = function()
        while true do 
            print("ttt")
            task.wait(2)
        end
    end,

    ClientEndpoints = {
        Test = function()
            print("yay")
        end,
        Test2 = function()
            print("hehe")
        end
    },
})


Delver.Start()