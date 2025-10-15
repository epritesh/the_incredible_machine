local Base = require("src.entities.base")

local Goal = {
    type = "goal",
    width = 64,
    height = 64,
}
setmetatable(Goal, Base)
Goal.__index = Goal

function Goal:new(data)
    local instance = Base.new(self, data)
    instance.targetType = data.targetType
    return instance
end

function Goal:draw()
    love.graphics.setColor(0, 1, 0, 0.5)
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
end

function Goal:isInside(obj)
    return obj.x > self.x - self.width/2 and obj.x < self.x + self.width/2 and
           obj.y > self.y - self.height/2 and obj.y < self.y + self.height/2
end

return Goal
