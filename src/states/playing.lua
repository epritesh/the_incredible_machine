local physics = require("src.core.physics")
local Ball = require("src.entities.ball")
local Fan = require("src.entities.fan")
local Button = require("src.entities.button")
local Balloon = require("src.entities.balloon")
local Joint = require("src.entities.joint")
local Goal = require("src.entities.goal")
local Gamestate = require("src.core.gamestate")

local Playing = {}

function Playing:load(levelPath)
    self.objects = {}
    self.selectedType = "ball"
    self.selectedObj = nil
    self.ropeStart = nil
    self.mode = "edit"
    self.levelPath = levelPath
    self.win = false

    local entityTypes = {
        ball = Ball,
        fan = Fan,
        button = Button,
        balloon = Balloon,
    }

    physics.resetWorld(self.objects)
    local levelData = love.filesystem.load(self.levelPath)()

    for _, data in ipairs(levelData.objects) do
        local entityClass = entityTypes[data.type]
        if entityClass then
            local obj = entityClass:new(data.x, data.y)
            if data.angle then
                obj.angle = data.angle
            end
            if data.active then
                obj.active = data.active
            end
            table.insert(self.objects, obj)
        end
    end

    self.goal = Goal:new(levelData.goal.x, levelData.goal.y, levelData.goal.type)
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
    love.graphics.print("Selected: " .. self.selectedType .. "  [1=Ball, 2=Fan, 3=Button, 4=Balloon, 5=Rope Mode] (Drag to move, R to rotate)", 10, 30)
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
        Gamestate.switch("level_select")
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
    elseif key == "3" then self.selectedType = "button"
    elseif key == "4" then self.selectedType = "balloon"
    elseif key == "5" then self.selectedType = "rope"

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
        if self.selectedType == "ball" then
            table.insert(self.objects, Ball:new(x, y))
        elseif self.selectedType == "fan" then
            table.insert(self.objects, Fan:new(x, y))
        elseif self.selectedType == "button" then
            table.insert(self.objects, Button:new(x, y))
        elseif self.selectedType == "balloon" then
            table.insert(self.objects, Balloon:new(x, y))
        elseif self.selectedType == "rope" then
            for _, obj in ipairs(self.objects) do
                if obj.isInside and obj:isInside(x, y) and obj.body then
                    if not self.ropeStart then
                        self.ropeStart = obj
                    else
                        local joint = Joint:new(self.ropeStart, obj, 150)
                        table.insert(self.objects, joint)
                        self.ropeStart = nil
                    end
                    return
                end
            end
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
