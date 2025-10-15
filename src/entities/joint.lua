local Base = require("src.entities.base")
local physics = require("src.core.physics")

local Joint = {
    type = "joint"
}
setmetatable(Joint, Base)
Joint.__index = Joint

function Joint:new(objA, objB, length)
    local instance = Base.new(self)
    instance.objA = objA
    instance.objB = objB
    instance.length = length or 64
    instance.joint = love.physics.newDistanceJoint(
        objA.body, objB.body,
        objA.body:getX(), objA.body:getY(),
        objB.body:getX(), objB.body:getY(),
        false
    )
    instance.joint:setLength(instance.length)
    return instance
end

function Joint:draw()
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.line(
        self.objA.body:getX(), self.objA.body:getY(),
        self.objB.body:getX(), self.objB.body:getY()
    )
end

return Joint