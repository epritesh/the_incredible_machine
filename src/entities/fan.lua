local physics = require("src.core.physics")
local Base = require("src.entities.base")

-- 1. Create the Fan 'class'
local Fan = {
    type = "fan",
    width = 64,
    height = 32,
    power = 1.0,
    active = false,
    angle = -math.pi / 2, -- Default to upward
    radius = 220, -- Area of effect
    forceMagnitude = 2000 -- Base force strength (increased for visible effect)
}
setmetatable(Fan, Base) -- Inherit from Base
Fan.__index = Fan -- For method lookups

-- 2. The constructor for creating fan INSTANCES
function Fan:new(data)
    local instance = Base.new(self, data) -- Call base constructor
    instance.sprite_on = love.graphics.newImage("assets/sprites/fan_on.png")
    instance.sprite_off = love.graphics.newImage("assets/sprites/fan_off.png")
    instance:resetBody()
    return instance
end

-- 3. All methods are now defined on the Fan class and shared by instances
function Fan:resetBody()
    if self.body then self.body:destroy() end
    self.body = love.physics.newBody(physics.world, self.x, self.y, "static")
    self.body:setAngle(self.angle)
    self.shape = love.physics.newRectangleShape(self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData(self)
end

function Fan:update(dt, objects)
    -- Activate if any Ball (dynamic body with user data type 'ball') is within the fan's radius
    -- Fan activation is now controlled by contact callbacks (energy_ball touching fan)
    -- Use the fan's active flag set by physics callbacks
    if not self.active then return end

    -- Apply forces to dynamic bodies within the fan radius
    local px, py = self.body:getPosition()
    local r = self.radius
    physics.world:queryBoundingBox(px - r, py - r, px + r, py + r, function(fixture)
        local body = fixture:getBody()
        if body:getType() == "dynamic" then
                local bx, by = body:getPosition()
            local dx, dy = bx - px, by - py
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist < r and dist > 0 then
                local ax = math.cos(self.angle)
                local ay = math.sin(self.angle)
                local force = self.forceMagnitude * self.power * (1 - dist/r)
                body:applyForce(ax * force, ay * force)
            end
        end
        return true
    end)
end

function Fan:draw()
    local sprite
    if self.active then
        sprite = self.sprite_on
    else
        sprite = self.sprite_off
    end

    love.graphics.setColor(1, 1, 1)
    -- Draw at the physics body's position so visuals match interaction
    local px, py = (self.body and self.body.getPosition) and self.body:getPosition() or (self.x or 0), (self.body and self.body.getY) and self.body:getY() or (self.y or 0)
    local ang = (self.body and self.body.getAngle) and self.body:getAngle() or self.angle
    love.graphics.push()
    love.graphics.translate(px, py)
    love.graphics.rotate(ang)
    love.graphics.draw(sprite, -self.width/2, -self.height/2)
    love.graphics.pop()

    if self.active then
        love.graphics.setColor(0.8, 0.9, 1, 0.12)
        love.graphics.circle("fill", px, py, self.radius)
    end
end

function Fan:isInside(mx, my)
    -- Simple AABB check is fine for UI interaction
    return mx > self.x - self.width/2 and mx < self.x + self.width/2
       and my > self.y - self.height/2 and my < self.y + self.height/2
end

return Fan