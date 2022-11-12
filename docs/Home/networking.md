# Networking & Middleware
Often times you need to "expose" some functions from the server to the client.

Thankfully, Delver has a built-in solution for that, and it is ClientEndpoints! They are little special entities that are allowed to live on the server realm that allow for client-server-client communication.

You define ClientEndpoints in this way:

```Lua
-- server
Delver.addRunner({...
    ClientEndpoints = {
        func = function(plr, ...)
            return true
        end,
        func2 = function(plr, ...)
            return false
        end
    }
...})
```

Internally, Delver sets up all the networking infrastructure needed for this kind of communication, and then adds the server runner to every client's Runner table, which means that it can be used on the client by `Delver.ReturnRunnerWithName`.

Another thing cool about ClientEndpoints is that they behave like functions! Meaning on the client, if we did `Runner:func()`, it would return true - and to ensure that behavior, all of these functions yield.

!!! danger "Leaving return nil in Endpoints"
    Due to the networking library Delver uses, you must explicitly return a value in order for the client to not yield forever.


Now that you know how to create Endpoints, let's learn how to use middleware!

Just like ClientEndpoints, Middleware is a server-only entity however, the special thing is that Middleware allows for more control over how Delver handles internal requests for ClientEndpoints.

To define Middleware in a server runner:

```Lua
Delver.addRunner({...
    Middleware = {
        function(plr, NameFunc, ...) -- runs first
            return plr, NameFunc, ...
        end, 
        function(plr, NameFunc, ...) -- runs second
            return nil -- drops remote request
        end,
    }
...})
```

Internally, whenever an endpoint request comes in, Delver calls these functions in order, and will drop the reqeust if a nil was solely returned.

While argument injection can be useful, ***it is important to be aware of the dangers of mutating `NameFunc`***.