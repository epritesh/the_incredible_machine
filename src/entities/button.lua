local Base = require("src.entities.base")
local physics = require("src.core.physics")

local Button = {
    type = "button",
    width = 40,
    height = 16,
    pressed = false
}
setmetatable(Button, Base)
Button.__index = Button

function Button:new(x, y)
    local instance = Base.new(self, x, y)
    instance:resetBody()
    return instance
end

function Button:resetBody()
    self.body = love.physics.newBody(physics.world, self.x, self.y, "static")
    self.shape = love.physics.newRectangleShape(self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData(self)
end

function Button:update(dt, objects)
    -- Consider "pressed" if any dynamic body overlaps an expanded AABB
    self.pressed = false
    local px, py = self.x, self.y
    local halfW, halfH = self.width/2 + 4, self.height/2 + 4
    for _, body in ipairs(physics.world:getBodies()) do
        if body:getType() == "dynamic" then
            local bx, by = body:getPosition()
            if bx > px - halfW and bx < px + halfW and by > py - halfH and by < py + halfH then
                self.pressed = true
                break
            end
        end
    end
end

function Button:draw()
    if self.pressed then
        love.graphics.setColor(0.9, 0.2, 0.2)
    else
        love.graphics.setColor(0.7, 0.2, 0.2)
    end
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
end

function Button:isInside(mx, my)
    return mx > self.x - self.width/2 and mx < self.x + self.width/2
       and my > self.y - self.height/2 and my < self.y + self.height/2
end

return Button