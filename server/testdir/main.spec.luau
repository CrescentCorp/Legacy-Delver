local expect = require(game.ReplicatedStorage.Tester).expect
local Delver = require(game.ReplicatedStorage.Packages.delvergreatFolder.delvers.Delver)

return {
    ["Should error when storing a private mutable data"] = function()
        expect(function()
            Delver.AddRunner({
                Name = "string",
                Sync = true,

                key = 0
            })
        end).to.throw()
    end,
    ["Should not error when storing a public key with allowed data type"] = function()
        expect(function()
            Delver.AddRunner({
                Name = "string",
                Sync = true,

                pub = function()
                end
            })

            Delver.AddRunner({
                Name = "string",
                Sync = true,

                pub = {}
            })

            Delver.AddRunner({
                Name = "string",
                Sync = true,

                pub = Instance.new("Part")
            })
        end).to.never.throw()
    end
}