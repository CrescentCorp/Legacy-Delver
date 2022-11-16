local Delver = require(game.ReplicatedStorage.Packages.delvergreatFolder.delvers.Delver)
Delver.AddRunner({
    Name = "ClientConsumer",
    Sync = false,

    OnPrepare = function()
        local serverHi = Delver.ReturnRunnerWithName("hi")
        print(serverHi)
    end,
    OnRun = function()
        local serverHi = Delver.ReturnRunnerWithName("hi")
        print(serverHi:Test())
        serverHi:Test2()
        print("yes")
    end,
})

Delver.Start()
