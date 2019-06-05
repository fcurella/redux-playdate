local assign = require 'lredux.helpers.assign'
local Null = require 'lredux.null'

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
}

return function (state, action)
    state = state or Null
    local handler = handlers[action.type]
    if handler then
        return handler(state, action)
    end
    return state
end
