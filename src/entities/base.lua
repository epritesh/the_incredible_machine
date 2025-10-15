-- src/entities/base.lua
local Base = {}
Base.__index = Base -- Instances will look for methods in this table if they don't have them.

-- This is a constructor that should be called on a 'class' table.
-- For example: Fan:new(x, y)
-- It creates a new instance and sets its metatable to the class.
function Base.new(class, data)
    local instance = {}
    setmetatable(instance, class) -- Use the explicit 'class' argument

    -- Initialize default properties for all objects
    instance.x = data.x or 0
    instance.y = data.y or 0
    instance.angle = data.angle or class.angle or 0
    instance.channel = data.channel
    instance.body = nil
    instance.shape = nil
    instance.fixture = nil
    instance.type = class.type or "object" -- The 'type' should be defined on the class table

    return instance
end

return Base