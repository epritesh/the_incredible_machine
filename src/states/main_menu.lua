local Gamestate = require("src.core.gamestate")

local MainMenu = {}

function MainMenu:load()
    self.title = "The Incredible Machine"
    self.options = {
        { text = "Start Game", action = function() Gamestate.switch("playing") end },
        { text = "Quit", action = function() love.event.quit() end },
    }
    self.selected = 1
    -- cache fonts so we don't recreate them each frame
    self.titleFont = love.graphics.newFont(36)
    self.optionFont = love.graphics.newFont(20)
end

function MainMenu:update(dt)
    -- Nothing to update in the main menu
end

function MainMenu:draw()
    -- lighter menu background for brighter feel
    love.graphics.setBackgroundColor(0.18, 0.20, 0.22)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.titleFont)
    -- subtle shadow for the title
    love.graphics.setColor(0,0,0,0.6)
    love.graphics.printf(self.title, 2, 102, love.graphics.getWidth(), "center")
    love.graphics.setColor(1,1,1)
    love.graphics.printf(self.title, 0, 100, love.graphics.getWidth(), "center")

    love.graphics.setFont(self.optionFont)
    local baseY = 200
    for i, option in ipairs(self.options) do
        local y = baseY + i * 50
        if i == self.selected then
            -- highlight background for selected option
            local textW = self.optionFont:getWidth(option.text)
            local x = (love.graphics.getWidth() - textW) / 2 - 12
            love.graphics.setColor(0.9, 0.7, 0.1, 0.12)
            love.graphics.rectangle("fill", x, y - 6, textW + 24, self.optionFont:getHeight() + 8, 6, 6)
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(option.text, 0, y, love.graphics.getWidth(), "center")
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
