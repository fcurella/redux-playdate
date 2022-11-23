# redux-playdate

Originally, [redux](https://redux.js.org/) is a predictable state container for JavaScript apps. From now on, all the redux features are available on your Playdate projects. Try it out! :-D

## Install 
redux-playdate can be installed using [toybox](https://github.com/jm/toybox):
```
$ toybox add fcurella/redux-playdate
```

## Usage
Here is an example of profile updating. To handle redux state changes, it is recommended to use [redux-props](https://github.com/pyericz/redux-props). To get more usages, please checkout [examples](https://github.com/fcurella/redux-playdate/tree/master/examples). 

### Define actions
```lua
--[[
    actions/profile.lua
--]]
local actions = {}

function actions.updateName(name)
    return {
        type = "PROFILE_UPDATE_NAME",
        name = name
    }
end

function actions.updateAge(age)
    return {
        type = "PROFILE_UPDATE_AGE",
        age = age
    }
end

function actions.remove()
    return {
        type = "PROFILE_REMOVE"
    }
end

function actions.thunkCall()
    return function (dispatch, state)
        return dispatch(actions.remove())
    end
end

return actions
```

### Define reducer
```lua
--[[
    reducers/profile.lua
--]]
import("toyboxes")

local assign =  redux.helpers.assign
local Null = redux.Null

local initState = {
    name = '',
    age = 0
}

local handlers = {
    ["PROFILE_UPDATE_NAME"] = function (state, action)
        return assign(initState, state, {
            name = action.name
        })
    end,
    
    ["PROFILE_UPDATE_AGE"] = function (state, action)
        return assign(initState, state, {
            age = action.age
        })
    end,
    
    ["PROFILE_REMOVE"] = function (state, action)
        return Null
    end,
}

return function (state, action)
    state = state or Null
    local handler = handlers[action.type]
    if handler then
        return handler(state, action)
    end
    return state
end
```

### Combine reducers
```lua
--[[
    reducers/index.lua
--]]
import("toyboxes")

local combineReducers = redux.combineReducers
local profile = import('profile')

return combineReducers({
    profile = profile
})
```

### Create store
```lua
--[[
    store.lua
--]]
import("toyboxes")

local createStore = redux.createStore
local reducers = import("reducers/index")

local store = createStore(reducers)

return store
```

### Create store with middlewares
Here is an example about how to define a middleware.
```lua
--[[
    middlewares/logger.lua
--]]
import("toyboxes")

local Logger = redux.utils.Logger

local function logger(store)
    return function (nextDispatch)
        return function (action)
            Logger.info('WILL DISPATCH:', action)
            local ret = nextDispatch(action)
            Logger.info('STATE AFTER DISPATCH:', store.getState())
            return ret

        end
    end
end

return logger
```

Compose all defined middlewares to `middlewares` array.
```lua
--[[
    middlewares/index.lua
--]]
local logger = import("logger")
local thunk = import("middlewares.thunk")

local middlewares = {
    thunk,
    logger,
}

return middlewares
```

Finally, pass middlewares to `applyMiddleware`, which is provided as an enhancer to `createStore`, and create our store instance.
```lua
--[[
    store.lua
--]]
import("toyboxes")

local createStore = redux.createStore
local reducers = import("reducers/index")
local applyMiddleware = redux.applyMiddleware
local middlewares = import("middlewares/index")

local store = createStore(reducers, applyMiddleware(table.unpack(middlewares)))

return store
```
### Dispatch & Subscription
```lua
--[[
    main.lua
--]]
import("CoreLibs/object")

local ProfileActions = import("actions/profile")
local store = import("store")

local function callback()
    print(printTable(store.getState()))
end

-- subscribe dispatching
local unsubscribe = store.subscribe(callback)

-- dispatch actions
store.dispatch(ProfileActions.updateName('Jack'))
store.dispatch(ProfileActions.updateAge(10))
store.dispatch(ProfileActions.thunkCall())

-- unsubscribe
unsubscribe()
```

### Debug mode
redux-lua is on `Debug` mode by default. Messages with errors and warnings will be output when `Debug` mode is on. Use following code to turn it off.
```lua
import("toyboxes")

local Env = redux.Env

Env.setDebug(false)
```

### Null vs. nil
`nil` is not allowed as a reducer result. If you want any reducer to hold no value, you can return `Null` instead of `nil`.
```lua
import("toyboxes")

local Null = redux.Null
```


## License
[MIT License](https://github.com/fcurella/redux-playdate/blob/master/LICENSE)


## Credits

This code is ported to the Playdate SDK from [redux-lua](https://github.com/pyericz/redux-lua).