# Introduction

Delver is an efficient game framework intended for solving major issues with frameworks like Knit & Volt, while also providing on its own a few features such as performant networking.

However, why use Delver over Knit & Volt?

## Why Use Delver

* **Unified Singleton**: The singleton which you use for running code is unified for the server and the client, so no need to fear the overcomplications you get from the service-controller paradigm, just as simple as **Runner**. 
* **Running Runners in Async/Sync Execution Models**: You have the option to whether run your runners in an async thread or a sync thread *(main thread)*. If a synced runner blocks execution, the other `OnRuns` of other runners would also be blocked.
* **A Performant Networking Layer**: Delver offers you you to create "endpoints" from the server that will be executed from the client. Besides, the performant of the said endpoints would be optimal to a degree due to the networking library being used *(BridgeNet by ffrostfall)*.
* **Lightweight**: Delver's codebase is ~200 code lines, and it only requires a module to function which is BridgeNet. Beside implemenation details, Delver doesn't really come with a version that is bundled with a few packages as this doesn't line up with the vision behind Delver.
* **No Mutable Global State**: Any practices that exactly mirror `_G` storage practices are entirely disallowed in Delver. The only way for your runners to have data stored in them is to name them a name that starts with either `_` or `M_` - assuming that the datatype isn't a function or a table. *More info would be discussed later*
