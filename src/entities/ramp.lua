local Base = require("src.entities.base")
local physics = require("src.core.physics")

local Ramp = {
    type = "ramp",
    length = 128,
    thickness = 12,
}
setmetatable(Ramp, Base)
Ramp.__index = Ramp

function Ramp:new(data)
    local instance = Base.new(self, data)
    instance.length = data.length or instance.length
    instance.thickness = data.thickness or instance.thickness
    instance.angle = data.angle or instance.angle or 0
    instance:resetBody()
    return instance
end

function Ramp:resetBody()
    if self.body then self.body:destroy() end
    -- static ramp so ball can roll on it
    self.body = love.physics.newBody(physics.world, self.x, self.y, "static")
    self.body:setAngle(self.angle)
    self.shape = love.physics.newRectangleShape(self.length, self.thickness)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData(self)
end

function Ramp:draw()
    love.graphics.setColor(0.5, 0.4, 0.3)
    love.graphics.push()
    love.graphics.translate(self.body:getX(), self.body:getY())
    love.graphics.rotate(self.body:getAngle())
    love.graphics.rectangle("fill", -self.length/2, -self.thickness/2, self.length, self.thickness)
    love.graphics.pop()
    love.graphics.setColor(1,1,1)
end

function Ramp:isInside(mx, my)
    local bx, by = self.body and self.body:getPosition() or self.x, self.body and self.body:getY() or self.y
    local angle = self.body and self.body:getAngle() or self.angle
    -- transform point into ramp local space
    local dx, dy = mx - bx, my - by
    local ca, sa = math.cos(-angle), math.sin(-angle)
    local lx = dx * ca - dy * sa
    local ly = dx * sa + dy * ca
    return lx > -self.length/2 and lx < self.length/2 and ly > -self.thickness/2 and ly < self.thickness/2
end

return Ramp
