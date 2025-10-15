local Gamestate = require("src.core.gamestate")

local LevelSelect = {}

function LevelSelect:load()
    self.title = "Select a Level"
    self.levels = {
        { name = "Tutorial 1", path = "levels/tutorial1.lua" },
        { name = "Chain Reaction", path = "levels/chainreaction.lua" },
        { name = "Wind Power", path = "levels/windpower.lua" },
    }
    self.selected = 1
end

function LevelSelect:update(dt)
    -- Nothing to update
end

function LevelSelect:draw()
    love.graphics.setBackgroundColor(0.12, 0.13, 0.15)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(36))
    love.graphics.printf(self.title, 0, 100, love.graphics.getWidth(), "center")

    love.graphics.setFont(love.graphics.newFont(24))
    for i, level in ipairs(self.levels) do
        if i == self.selected then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(level.name, 0, 200 + i * 50, love.graphics.getWidth(), "center")
    end
end

function LevelSelect:keypressed(key)
    if key == "up" then
        self.selected = math.max(1, self.selected - 1)
    elseif key == "down" then
        self.selected = math.min(#self.levels, self.selected + 1)
    elseif key == "return" or key == "kpenter" then
        Gamestate.switch("playing", self.levels[self.selected].path)
    elseif key == "escape" then
        Gamestate.switch("main_menu")
    end
end

return LevelSelect
