local Base = require("src.entities.base")
local physics = require("src.core.physics")

local Balloon = {
    type = "balloon",
    radius = 20,
    popped = false,
    animation_finished = false,
    animation_timer = 0,
    current_frame = 1,
    animation_speed = 15 -- frames per second
}
setmetatable(Balloon, Base)
Balloon.__index = Balloon

function Balloon:new(data)
    local instance = Base.new(self, data)

    -- Load the sprites
    instance.sprite = love.graphics.newImage("assets/sprites/balloon.png")
    instance.pop_animation = {}
    for i = 1, 10 do
        instance.pop_animation[i] = love.graphics.newImage("assets/sprites/balloon_popping/frame_" .. string.format("%02d", i) .. ".png")
    end

    instance:resetBody()
    return instance
end

function Balloon:resetBody()
    if self.body then self.body:destroy() end
    self.body = love.physics.newBody(physics.world, self.x, self.y, "dynamic")
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape, 0.2)
    self.fixture:setRestitution(0.1)
    self.fixture:setUserData(self)
    self.body:setLinearDamping(0.8)
end

function Balloon:update(dt, objects)
    if self.animation_finished then return end

    if self.popped then
        self.animation_timer = self.animation_timer + dt * self.animation_speed
        self.current_frame = math.floor(self.animation_timer) + 1
        if self.current_frame > #self.pop_animation then
            self.animation_finished = true
        end
        return -- Stop physics updates once popped
    end

    -- Light upward lift (negative gravity)
    self.body:applyForce(0, -800)

    -- Check for collisions with sharp objects (Fans when active, Scissors)
    for _, obj in ipairs(objects) do
        if (obj.type == "fan" and obj.active) or obj.type == "scissors" then
            local bx, by = self.body:getPosition()
            local ox, oy = obj.x or (obj.body and obj.body:getX()), obj.y or (obj.body and obj.body:getY())
            if ox and oy then
                local dist = ((bx - ox)^2 + (by - oy)^2) ^ 0.5
                -- use a radius threshold that combines sizes
                local threshold = 40
                if dist < threshold and not self.popped then
                    self.popped = true
                    if self.body then self.body:destroy() end
                    break
                end
            end
        end
    end
end

function Balloon:draw()
    if self.animation_finished then return end

    love.graphics.setColor(1, 1, 1) -- Reset color to white for sprites

    if self.popped then
        local frame = self.pop_animation[self.current_frame]
        if frame then
            -- Draw from the center
            love.graphics.draw(frame, self.x, self.y, 0, 1, 1, frame:getWidth()/2, frame:getHeight()/2)
        end
    else
        -- Draw from the center
        love.graphics.draw(self.sprite, self.body:getX(), self.body:getY(), self.body:getAngle(), 1, 1, self.sprite:getWidth()/2, self.sprite:getHeight()/2)
    end
end

function Balloon:isInside(mx, my)
    local bx, by = self.x, self.y
    local dx, dy = mx - bx, my - by
    return (dx*dx + dy*dy) <= (self.radius + 6)*(self.radius + 6)
end

return Balloon
