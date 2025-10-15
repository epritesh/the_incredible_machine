local Gamestate = require("src.core.gamestate")

local MainMenu = {}

function MainMenu:load()
    self.title = "The Incredible Machine"
    self.options = {
        { text = "Start Game", action = function() Gamestate.switch("playing", "levels/windpower.lua") end },
        { text = "Quit", action = function() love.event.quit() end },
    }
    self.selected = 1
end

function MainMenu:update(dt)
    -- Nothing to update in the main menu
end

function MainMenu:draw()
    love.graphics.setBackgroundColor(0.12, 0.13, 0.15)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(36))
    love.graphics.printf(self.title, 0, 100, love.graphics.getWidth(), "center")

    love.graphics.setFont(love.graphics.newFont(24))
    for i, option in ipairs(self.options) do
        if i == self.selected then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(option.text, 0, 200 + i * 50, love.graphics.getWidth(), "center")
    end
end

function MainMenu:keypressed(key)
    if key == "up" then
        self.selected = math.max(1, self.selected - 1)
    elseif key == "down" then
        self.selected = math.min(#self.options, self.selected + 1)
    elseif key == "return" or key == "kpenter" then
        self.options[self.selected].action()
    end
end

return MainMenu
