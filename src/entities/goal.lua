local Base = require("src.entities.base")

local Goal = {
    type = "goal",
    width = 64,
    height = 64,
    color = {0, 1, 0},
    pulseTimer = 0,
}
setmetatable(Goal, Base)
Goal.__index = Goal

function Goal:new(data)
    local instance = Base.new(self, data)
    instance.targetType = data.targetType
    return instance
end

function Goal:draw()
    -- pulsing outline to make goal obvious but not visually blocking
    self.pulseTimer = (self.pulseTimer or 0) + (love.timer.getDelta() or 0.016)
    local pulse = 0.5 + 0.5 * math.sin(self.pulseTimer * 2)
    local r, g, b = unpack(self.color)
    love.graphics.setLineWidth(3)
    love.graphics.setColor(r, g, b, 0.6 * pulse)
    love.graphics.rectangle("line", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
end

function Goal:isInside(obj)
    local ox, oy
    if obj.body and obj.body.getX then
        ox, oy = obj.body:getPosition()
    else
        ox, oy = obj.x, obj.y
    end
    return ox > self.x - self.width/2 and ox < self.x + self.width/2 and
           oy > self.y - self.height/2 and oy < self.y + self.height/2
end

return Goal
