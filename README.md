# Delver
An in-house game framework for easier and scalable roblox networking & script communication.

* Documentation [still in dev]
* Roblox Marketplace [still in dev]
* Latest release [still in dev]

Delver was an internal project that was targeted to solve the issues that were introduced with Knit and other major frameworks, while also providing a few features on its own.

## Features

* **Unified Singleton** -- There is no thing such as Service or Controller - everything is wrapped in a single, unified singleton which is ***runner***
* **Run Runners asynchronously or synchronously** -- You have the full control over how runners behave. If one is syned, and it yields, the execution of other synced runners are stopped.
* **Running Server code from the Client** -- Delver gives you the ability to expose what's is known as ***endpoints*** from the server to the client. 
* **Networking aint go brr** -- Performant networking was always an concern of Delver, as such, we preciously chose a specific networking library based on our needs.
* **Lightweight** -- Delver is extremely lightweight as it only requires one essential library for networking.

## Goals

* Focus on optimizing networking
* Enable powerful control flow through sensible methods that allow for greater productivity rather than methods that give full control in unsensible/unproductive methods

## Why Networking Matters
Networking is undeniably the most important aspect to look into when designing a performant and efficient game. Due to the direct link between frame rate and networking *(packets are processed at the start of every frame, packates are sent at the end of every frame)*, unoptimized networking code can results in huge performance loses.

Despite this, other frameworks didn't focus on improving networking performance, but rather support networking as is without any optimization.

With Delver, we wanted fast networking code due to the nature of our games, as such, we wanted to use a networking library that offered optimization to this specific use case - which is BridgeNet!
