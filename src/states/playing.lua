local physics = require("src.core.physics")
local Ball = require("src.entities.ball")
local Fan = require("src.entities.fan")
local Balloon = require("src.entities.balloon")
local Scissors = require("src.entities.scissors")
local Goal = require("src.entities.goal")
local Gamestate = require("src.core.gamestate")

local Playing = {}

local entityTypes = {
    ball = Ball,
    fan = Fan,
    balloon = Balloon,
    scissors = Scissors,
}

function Playing:load(levelPath)
    self.objects = {}
    self.selectedType = "ball"
    self.selectedObj = nil
    self.ropeStart = nil
    self.mode = "edit"
    self.levelPath = levelPath
    self.win = false
    self.defaultFont = love.graphics.newFont(12)
    self.winFont = love.graphics.newFont(48)

    physics.resetWorld(self.objects)
    local levelData = love.filesystem.load(self.levelPath)()

    self:loadObjects(levelData.objects)

    self.goal = Goal:new(levelData.goal)
end

function Playing:loadObjects(objectsData)
    self.objects = {}
    for _, data in ipairs(objectsData) do
        local entityClass = entityTypes[data.type]
        if entityClass then
            local obj = entityClass:new(data)
            table.insert(self.objects, obj)
        end
    end
end

function Playing:update(dt)
    if self.win then return end

    if self.mode == "run" then
        physics.world:update(dt)
        for _, obj in ipairs(self.objects) do
            if obj.update then obj:update(dt, self.objects) end
            if obj.type == self.goal.targetType and self.goal:isInside(obj) then
                self.win = true
            end
        end
    end
end

function Playing:draw()
    love.graphics.setFont(self.defaultFont)
    self.goal:draw()

    for _, obj in ipairs(self.objects) do
        if obj.draw then obj:draw() end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Mode: " .. self.mode .. "  [SPACE = toggle run/edit]", 10, 10)
    love.graphics.print("Selected: " .. self.selectedType .. "  [1=Ball, 2=Fan, 3=Balloon, 4=Scissors] (Drag to move, R to rotate)", 10, 30)
    love.graphics.print("Level: " .. self.levelPath .. "  [ESC to menu]", 10, 50)

    if self.selectedObj and self.mode == "edit" then
        love.graphics.setColor(0, 1, 0, 0.5)
        local bx, by = self.selectedObj.x, self.selectedObj.y
        love.graphics.circle("line", bx, by, 24)
    end

    if self.win then
        love.graphics.setColor(0, 1, 0)
        love.graphics.setFont(self.winFont)
        love.graphics.printf("You Win!", 0, 300, love.graphics.getWidth(), "center")
        love.graphics.setFont(self.defaultFont)
        love.graphics.printf("Press Enter to continue", 0, 400, love.graphics.getWidth(), "center")
    end
end

function Playing:keypressed(key)
    if self.win and (key == "return" or key == "kpenter") then
        -- Return to main menu (single-level game)
        Gamestate.switch("main_menu")
        return
    end

    if key == "space" then
        if self.mode == "edit" then
            self.mode = "run"
        else
            self.mode = "edit"
            physics.resetWorld(self.objects)
        end
    elseif key == "1" then self.selectedType = "ball"
    elseif key == "2" then self.selectedType = "fan"
    elseif key == "3" then self.selectedType = "balloon"
    elseif key == "4" then self.selectedType = "scissors"

    elseif key == "r" and self.selectedObj then
        self.selectedObj.angle = (self.selectedObj.angle or 0) + math.pi / 4
        if self.selectedObj.resetBody then self.selectedObj:resetBody() end
    elseif key == "escape" then
        Gamestate.switch("main_menu")
    end
end

function Playing:mousepressed(x, y, button)
    if self.mode ~= "edit" then return end
    if button == 1 then
        for i = #self.objects, 1, -1 do
            local obj = self.objects[i]
            if obj.isInside and obj:isInside(x, y) then
                self.selectedObj = obj
                return
            end
        end

        local data = { x = x, y = y }
        if self.selectedType == "ball" then
            table.insert(self.objects, Ball:new(data))
        elseif self.selectedType == "fan" then
            table.insert(self.objects, Fan:new(data))
        elseif self.selectedType == "balloon" then
            table.insert(self.objects, Balloon:new(data))
        elseif self.selectedType == "scissors" then
            table.insert(self.objects, Scissors:new(data))
        end
    end
end

function Playing:mousereleased(x, y, button)
    if self.mode == "edit" and button == 1 then
        self.selectedObj = nil
    end
end

function Playing:mousemoved(x, y, dx, dy)
    if self.selectedObj and self.mode == "edit" then
        self.selectedObj.x = x
        self.selectedObj.y = y
        if self.selectedObj.resetBody then self.selectedObj:resetBody() end
    end
end

return Playing
