local Tester = require(game.ReplicatedStorage.Tester)

Tester.bootstrapper:start({
    directories = {script.Parent.testdir},
    options = {
        context = nil
    }
})