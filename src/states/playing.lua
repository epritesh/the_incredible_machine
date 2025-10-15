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
    ramp = require("src.entities.ramp"),
}

function Playing:load(levelPath)
    self.objects = {}
    self.selectedType = "ball"
    self.selectedObj = nil
    self.ropeStart = nil
    self.mode = "edit"
    self.levelPath = levelPath
    self.win = false
    -- cache fonts for consistent rendering and to avoid recreating per-frame
    self.defaultFont = love.graphics.newFont(12)
    self.objectiveFont = love.graphics.newFont(18)
    self.winFont = love.graphics.newFont(48)
    -- small HUD icon cache (icons used by the selected-type display)
    self.hudIcons = {}
    local function safeLoad(path)
        if love.filesystem.getInfo(path) then
            return love.graphics.newImage(path)
        end
        return nil
    end
    self.hudIcons.ball = safeLoad("assets/sprites/ball.png")
    self.hudIcons.fan = safeLoad("assets/sprites/fan_off.png") or safeLoad("assets/sprites/fan_on.png")
    self.hudIcons.balloon = safeLoad("assets/sprites/balloon.png")
    self.hudIcons.scissors = safeLoad("assets/sprites/scissors.png")
    -- ramp doesn't have a single sprite; reuse fan_off as a neutral placeholder if available
    self.hudIcons.ramp = safeLoad("assets/sprites/fan_off.png")

    physics.resetWorld(self.objects)
    -- If no levelPath provided, start with a blank playfield and default balloon objective
    if not self.levelPath then
        self.objects = {}
        -- Populate the playfield with one of each component so playtesting starts with parts available
        local w, h = love.graphics.getWidth(), love.graphics.getHeight()
        local cx, cy = w/2, h/2

        -- Create one Energy Ball, Fan, Balloon, Scissors, and a Ramp
        table.insert(self.objects, Ball:new({ x = cx - 240, y = cy }))
        table.insert(self.objects, Fan:new({ x = cx - 120, y = cy }))
        table.insert(self.objects, Balloon:new({ x = cx, y = cy - 80 }))
        table.insert(self.objects, Scissors:new({ x = cx + 120, y = cy }))
        table.insert(self.objects, require("src.entities.ramp"):new({ x = cx + 240, y = cy + 40, angle = -0.4, length = 180 }))

        self.goal = Goal:new({ x = cx, y = 100, type = "balloon", targetType = "balloon" })
        return
    end

    -- Safely load the level file. If it's missing (was removed during simplification),
    -- fall back to the seeded blank playfield used above.
    local loader = love.filesystem.load(self.levelPath)
    if not loader then
        -- fallback: populate a seeded playfield
        local w, h = love.graphics.getWidth(), love.graphics.getHeight()
        local cx, cy = w/2, h/2
        self.objects = {}
        table.insert(self.objects, Ball:new({ x = cx - 240, y = cy }))
        table.insert(self.objects, Fan:new({ x = cx - 120, y = cy }))
        table.insert(self.objects, Balloon:new({ x = cx, y = cy - 80 }))
        table.insert(self.objects, Scissors:new({ x = cx + 120, y = cy }))
        table.insert(self.objects, require("src.entities.ramp"):new({ x = cx + 240, y = cy + 40, angle = -0.4, length = 180 }))
        self.goal = Goal:new({ x = cx, y = 100, type = "balloon", targetType = "balloon" })
        return
    end

    local levelData = loader()
    self:loadObjects(levelData.objects)
    -- Keep goal data for logic (target type) but do not draw a positional goal anymore
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
            -- If the goal is to pop a balloon, consider a popped balloon as win immediately
            if self.goal and self.goal.targetType == "balloon" then
                if obj.type == "balloon" and obj.popped then
                    self.win = true
                end
            else
                if obj.type == self.goal.targetType and self.goal:isInside(obj) then
                    self.win = true
                end
            end
        end
    end
end

function Playing:draw()
    love.graphics.setFont(self.defaultFont)
    -- set a subtle background color for the playfield to improve contrast
    -- store it on the state so other UI elements can derive colors from it
    -- use a slightly lighter background for better visibility
    self.bgColor = self.bgColor or { 0.14, 0.18, 0.20 }
    love.graphics.setBackgroundColor(self.bgColor)
        -- No positional goal is drawn anymore. Goal only used for logic (e.g. balloon target)

    for _, obj in ipairs(self.objects) do
        if obj.draw then obj:draw() end
    end

    -- Ramp preview while dragging
    if self.rampDrag then
        local d = self.rampDrag
        love.graphics.setColor(0.6, 0.4, 0.3, 0.8)
        local cx = (d.x1 + d.x2)/2
        local cy = (d.y1 + d.y2)/2
        local angle = math.atan2(d.y2 - d.y1, d.x2 - d.x1)
        local length = math.sqrt((d.x2-d.x1)^2 + (d.y2-d.y1)^2)
        love.graphics.push()
        love.graphics.translate(cx, cy)
        love.graphics.rotate(angle)
        love.graphics.rectangle("fill", -length/2, -6, length, 12)
        love.graphics.pop()
        love.graphics.setColor(1,1,1)
    end

    love.graphics.setColor(1, 1, 1)
    -- HUD background bar for readability: derive from background color for consistent theming
    local hudX, hudY, hudW, hudH = 6, 6, 420, 48
    -- make HUD slightly lighter than background while keeping alpha for see-through
    local bg = self.bgColor
    local hudR = math.min(bg[1] + 0.06, 1)
    local hudG = math.min(bg[2] + 0.06, 1)
    local hudB = math.min(bg[3] + 0.06, 1)
    love.graphics.setColor(hudR, hudG, hudB, 0.45)
    love.graphics.rectangle("fill", hudX, hudY, hudW, hudH, 6, 6)
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(self.defaultFont)
    love.graphics.print("Mode: " .. self.mode .. "  [SPACE = toggle run/edit]", 12, 12)
    local selectionText = "Selected: " .. self.selectedType .. "  [1=Energy Ball, 2=Fan, 3=Balloon, 4=Scissors, 5=Ramp] (Drag to move, R to rotate)"
    love.graphics.print(selectionText, 12, 30)
    -- draw small icon next to the selection text if available
    local icon = self.hudIcons[self.selectedType]
    if icon then
        local iconSize = 18
        local sx = iconSize / icon:getWidth()
        local sy = iconSize / icon:getHeight()
        love.graphics.setColor(1,1,1)
        love.graphics.draw(icon, 12 + self.defaultFont:getWidth("Mode: " .. self.mode .. "  [SPACE = toggle run/edit]" ) + 12, 30 + 2, 0, sx, sy)
        love.graphics.setColor(1,1,1)
    end

    -- (Objective drawing moved later to ensure it's not occluded by game objects)

    if self.selectedObj and self.mode == "edit" then
        love.graphics.setColor(0.2, 0.9, 0.2, 0.18)
        local bx, by = self.selectedObj.x, self.selectedObj.y
        -- filled halo and outline for selection clarity
        love.graphics.circle("fill", bx, by, 28)
        love.graphics.setColor(0.2, 0.9, 0.2)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", bx, by, 30)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1,1,1)
    end

    if self.win then
        love.graphics.setColor(0, 1, 0)
        love.graphics.setFont(self.winFont)
        love.graphics.printf("You Win!", 0, 300, love.graphics.getWidth(), "center")
        love.graphics.setFont(self.defaultFont)
        love.graphics.printf("Press Enter to continue", 0, 400, love.graphics.getWidth(), "center")
    end

    -- Draw objective last so it is always visible, but place it below the HUD
    if self.goal and self.goal.targetType == "balloon" then
        local text = "POP THE BALLOON TO WIN!"
        local font = self.objectiveFont or self.defaultFont
        love.graphics.setFont(font)
        local w = font:getWidth(text)
        local h = font:getHeight()
        local x = (love.graphics.getWidth() - w) / 2
    -- compute a safe Y that sits below the HUD lines so the HUD is not occluded
    -- HUD lines are printed at y = 10 and y = 30 above, so ensure the objective is drawn below those
    local hud_bottom = 30 + (self.defaultFont:getHeight() or 12)
    -- place objective below the HUD bottom plus some padding and accounting for objective font height
    local y = hud_bottom + 8
        -- semi-opaque rounded background for better contrast and less visual harshness
        love.graphics.setColor(0, 0, 0, 0.75)
        love.graphics.rectangle("fill", x - 14, y - 8, w + 28, h + 16, 8, 8)
        love.graphics.setColor(1, 0.92, 0.92)
        love.graphics.print(text, x, y)
        love.graphics.setColor(1, 1, 1)
    end

    -- no debug overlay in submission build
    -- draw a cheap vignette overlay (edge fade) using semi-transparent rectangles
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local vignetteMaxAlpha = 0.45
    local steps = 6
    for i = 1, steps do
        local a = vignetteMaxAlpha * (i / steps) ^ 1.4
        local inset = i * 8
        love.graphics.setColor(0, 0, 0, a * 0.12)
        -- top
        love.graphics.rectangle("fill", inset, inset - inset, w - inset * 2, inset)
        -- bottom
        love.graphics.rectangle("fill", inset, h - inset, w - inset * 2, inset)
        -- left
        love.graphics.rectangle("fill", inset - inset, inset, inset, h - inset * 2)
        -- right
        love.graphics.rectangle("fill", w - inset, inset, inset, h - inset * 2)
    end
    love.graphics.setColor(1,1,1)
    -- cursor ghost (selected item preview)
    self:drawCursorGhost()
end

-- Draw a ghost icon near the cursor when in Edit mode to help placement
function Playing:drawCursorGhost()
    if self.mode ~= "edit" then return end
    -- don't draw a ghost while dragging to place a ramp (we show the ramp preview)
    if self.rampDrag then return end
    local icon = self.hudIcons[self.selectedType]
    if not icon then return end
    local mx, my = love.mouse.getPosition()
    local desiredSize = 28
    local sx = desiredSize / icon:getWidth()
    local sy = desiredSize / icon:getHeight()
    local offset = 18
    love.graphics.setColor(1,1,1,0.85)
    love.graphics.draw(icon, mx - offset - desiredSize, my - desiredSize/2, 0, sx, sy)
    love.graphics.setColor(1,1,1)
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
    elseif key == "5" then self.selectedType = "ramp"

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
        -- Start drag for ramp placement if selected
        if self.selectedType == "ramp" then
            self.rampDrag = { x1 = x, y1 = y, x2 = x, y2 = y }
            return
        end
        if self.selectedType == "ball" or self.selectedType == "energy_ball" then
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
        -- finalize ramp if in drag
        if self.rampDrag then
            local d = self.rampDrag
            d.x2 = x; d.y2 = y
            local cx = (d.x1 + d.x2)/2
            local cy = (d.y1 + d.y2)/2
            local angle = math.atan2(d.y2 - d.y1, d.x2 - d.x1)
            local length = math.sqrt((d.x2-d.x1)^2 + (d.y2-d.y1)^2)
            table.insert(self.objects, require("src.entities.ramp"):new({ x = cx, y = cy, angle = angle, length = length }))
            self.rampDrag = nil
            return
        end
        self.selectedObj = nil
    end
end

function Playing:mousemoved(x, y, dx, dy)
    if self.selectedObj and self.mode == "edit" then
        self.selectedObj.x = x
        self.selectedObj.y = y
        if self.selectedObj.resetBody then self.selectedObj:resetBody() end
    end

    if self.rampDrag then
        self.rampDrag.x2 = x
        self.rampDrag.y2 = y
    end
end

return Playing
