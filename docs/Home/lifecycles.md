# Lifecycles and Executions

Now, you are gonna learn about one of the most fundemental concepts in Delver - Lifecycles! They are super important features that allow for robust code without hacky and lengthy methods.

## The Problem

Let's assume that we have a really simple framework that loads modulescripts that return a function and then call them. This works, until ***you need communication between those modulescripts***.

Here's a simple module that we will call `MoneyHandler`

```lua
-- MoneyHandler.lua

return function() -- this is the execution point for this handler
    local moneyRecord = {}

    game.Players.PlayerAdded:Connect(function(plr)
        moneyRecprd[plr] = 0
    end)

    game.Players.PlayerRemoving:Connect(function(plr)
        moneyRecord[plr] = nil
    end)

    local ActionEvent = <path_to_a_bindable>

    ActionEvent:Connect(function(plr)
        moneyRecord[plr] += 10
    end)
end
```

This is simple, and it works! However, how are we gonna make this work when we don't use bindable events? Maybe we have a client handler for a player that manages the melee system and sends requests to a server handler that then will ask this handler to increment the player's money?

Yup, implementing cross-communication will become a very annoying issue since we don't have guarantees that our data or our core jobs are initialized - and by the way, this simple example is no different than a normal script - communication is impossible without bindables!

## Fix: Lifecycle Functions

To solve this, we need two separated execution points, one for initializng jobs for cross-communication, and the other for startup. And Delver's `OnPrepare` and `OnRun` are exactly that!

When running `OnPrepare`, all Runners are already added to the public namespace, ***however not ready to be consumed***, so it is fine to fetch the runner, but not in any way use it. 

After all `OnPrepare`s are ran, it is guaranteed that our runners are now ready for external consuming, and therefore, ready for startup or aka, all `OnRun`s are called, either at the same caller thread if the runner's Sync is true, or in a separate thread if the said property is false. 

Now that we know `OnRun` and `OnPrepare`, let's rewrite the `MoneyHandler` into a cool Runner that is called `MoneyRunner`.

```Lua
Delver.addRunner({
    Name = "MoneyRunner",
    Sync = false,

    _moneyRecord = {},
    OnPrepare = function(self)
        self._ActionEvent = <path_to_Bindable>

        game.Players.PlayerAdded:Connect(function(plr)
            self._moneyRecord[plr] = 0
        end)

        game.Players.PlayerRemoving:Connect(function(plr)
            self._moneyRecord[plr] = nil
        end)
    end,

    OnRun = function(self)
        self._ActionEvent:Connect(function(plr, reward)
            self._moneyRecord[plr] += reward 
        end)
    end
})
```

This works and is simple, ***and we now can implement cross-runner communication***! Assuming that we have a server runner that manages the requests from other client runners to register their hits and that runner needs to notify `MoneyRunner`, we can implement it easily! Just `Delver.ReturnRunnerWithName("ServerRunner")` in `MoneyRunner`'s OnPrepare and then connect to the appropriate  signal in the `OnRun`.

`OnRun` and `OnPrepare` are powerful tools for scalable communication, however, there are other ***three*** lifecycle functions to make your life a little bit easier, and they are `OnRender`, `OnStepped` and `OnHeartbeat`. 

It's obvious that these functions are just a shortcut for `RunService`'s event, and so, they inherit the same behavior *(same paramters)* and limitations *(OnRender doesn't work in the server)*.

OnRender:

```lua
{...
    OnRender = function(self, deltaTime)

    end,
...}
```

OnHeartbeat:
```lua
{...
    OnHeartbeat = function(self, deltaTime)

    end,
...}
```

OnStepped:
```lua
{...
    OnStepped = function(self, time, deltaTime)

    end,
...}
```

Now that you learnt the wonders of Delver's lifecycles, you are ready for the lands of Delver's built-in networking!