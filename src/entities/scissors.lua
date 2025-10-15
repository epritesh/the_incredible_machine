local Base = require("src.entities.base")
local physics = require("src.core.physics")

local Scissors = {
    type = "scissors",
    width = 48,
    height = 8,
    angle = 0,
    sharp = true,
}
setmetatable(Scissors, Base)
Scissors.__index = Scissors

function Scissors:new(data)
    local instance = Base.new(self, data)
    instance.width = data.width or instance.width
    instance.height = data.height or instance.height
    instance.angle = data.angle or 0
    -- Attempt to load a sprite if available
    if love.filesystem.getInfo("assets/sprites/scissors.png") then
        instance.sprite = love.graphics.newImage("assets/sprites/scissors.png")
        -- Override width/height from sprite if not explicitly set
        instance.width = data.width or instance.sprite:getWidth()
        instance.height = data.height or instance.sprite:getHeight()
    else
        instance.sprite = nil
    end
    instance:resetBody()
    return instance
end

function Scissors:resetBody()
    if self.body then self.body:destroy() end
    -- use kinematic so it can be moved but not affected by physics
    self.body = love.physics.newBody(physics.world, self.x, self.y, "kinematic")
    self.shape = love.physics.newRectangleShape(self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, self.shape, 0)
    self.fixture:setUserData(self)
    self.body:setAngle(self.angle)
end

function Scissors:update(dt, objects)
    -- nothing for now
end

function Scissors:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.push()
    love.graphics.translate(self.body:getX(), self.body:getY())
    love.graphics.rotate(self.body:getAngle())
    if self.sprite then
        love.graphics.draw(self.sprite, 0, 0, 0, 1, 1, self.sprite:getWidth()/2, self.sprite:getHeight()/2)
    else
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.rectangle("fill", -self.width/2, -self.height/2, self.width, self.height)
    end
    love.graphics.pop()
end

function Scissors:isInside(mx, my)
    local bx, by = self.body and self.body:getX() or self.x, self.body and self.body:getY() or self.y
    local dx, dy = mx - bx, my - by
    return math.abs(dx) <= self.width/2 + 6 and math.abs(dy) <= self.height/2 + 6
end

return Scissors
