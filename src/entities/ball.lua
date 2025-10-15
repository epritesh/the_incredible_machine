local Base = require("src.entities.base")
local physics = require("src.core.physics")

local Ball = {
    type = "ball",
    radius = 16
}
setmetatable(Ball, Base)
Ball.__index = Ball

function Ball:new(x, y)
    local instance = Base.new(self, x, y)
    instance.sprite = love.graphics.newImage("assets/sprites/ball.png")
    instance:resetBody()
    return instance
end

function Ball:resetBody()
    self.body = love.physics.newBody(physics.world, self.x, self.y, "dynamic")
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setRestitution(0.4)
    self.fixture:setUserData(self)
end

function Ball:update(dt, objects)
    -- custom per-frame logic could go here
end

function Ball:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.sprite, self.body:getX(), self.body:getY(), 0, 1, 1, self.sprite:getWidth()/2, self.sprite:getHeight()/2)
end

function Ball:isInside(mx, my)
    local bx, by = self.x, self.y
    local dx, dy = mx - bx, my - by
    return (dx*dx + dy*dy) <= (self.radius + 6)*(self.radius + 6)
end

return Ball