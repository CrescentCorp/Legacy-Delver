# Storing Data in Runners
Assuming you did 1 & 2 "challenges" from "Basic usage", then you would have been punished in the face with the following error:

```
RunnerName's key should not be global - add either _ or M_ as the first characters to silence 
```

However, why are we disallowed to attach data that is global? Well, it is a fix to a problem, a serious one that a lot of novice programmers run into.

## The Problem

People often used attached data to other frameworks like Knit the same way they did with `_G`. And the problem is, that using `_G` is sinister, as it allows for unmanaged global state. It is easy to run into hard-to-find bugs with using such practices. The problem can be directly divided into:

### 1. Unreliability

When you have unmanaged global state, you would never trust using it the second you put it. Why? Well, because every single code you ever write, including third-party code/libraries can mutate that state.

### 2. Encapsulation Breaks

When other code accesses that global data, they can set it to whatever they seem needed which means direct manipulation is performed on the said data which is a very bad idea. Your external code should always go through your runner methods.

### 3. Change is Hard

Let's represent this point in code:

```lua
local class = {
    users = {id, id ,id}
}

table.insert(class.users, newid)
```

This is pretty basic, it is just inserting a new id into the `users` table of `class`. However, what is gonna happen if we just decided to use a hash/dictionary for faster fetching? Well, good luck, now you need to go through every place you read/write to that table to change it.

We can solve this by doing:

```lua

local class = {
    _users = {},
    addUser = function(self, id)
        self._users[id] = userStructre
    end,
    getUser = function(self, id)
        return self._users[id]
    end
}
```

Now our external code doesn't care about how adding a new user is performed. It just tells `class` to add a new user entry. This means that we can change how we store data whenever we want, without recoding a lot of places! 


## Fix: Data-Attaching Rules
Now that you have seen how bad unmanaged global state can be, let's go through how Delver solves that issue! 

It does it by defining a few rules for how you would attach a data with a Runner.

Before we start, let's use this dictonary for example:

```lua
local dict = {}
```
We want to add a new entry to it, and obviously that will require both a `key` and a `value`.

In Delver, there are multiple rules that at least one of them need to be met for the `key` and the `value` valuables.

For the `key`, it at least has to start with, ***given that the rules for `value` aren't met***:

1. `_` -- To imply that the field is private, therefore, external code should never mess up with it.
2. `M_` -- to imply that the field is considered to be "meta" data, aka, this is the best place for attaching code that shouldn't be mutated by external code, and often times represents the parent dictionary state *(Runners' state in our case).

For the `value`, it at least has to be:

1. a `function` since functions are the preferred way of public data mutation.
2. a `table` since tables are considered self-aware entities, and such, they are allowed to be public *(although not recommended for mutation)*
3. an `instance` since instances are often represented as communicators such as bindables & remotes, although a user implementation might be better for your case.  
