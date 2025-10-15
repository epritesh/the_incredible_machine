local Gamestate = require("src.core.gamestate")

function love.load()
    Gamestate.register("main_menu", require("src.states.main_menu"))
    Gamestate.register("level_select", require("src.states.level_select"))
    Gamestate.register("playing", require("src.states.playing"))
    Gamestate.switch("main_menu")
end

function love.update(dt)
    Gamestate.update(dt)
end

function love.draw()
    Gamestate.draw()
end

function love.keypressed(key, scancode, isrepeat)
    Gamestate.keypressed(key, scancode, isrepeat)
end

function love.mousepressed(x, y, button, istouch, presses)
    Gamestate.mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    Gamestate.mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
    Gamestate.mousemoved(x, y, dx, dy, istouch)
end