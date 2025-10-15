local Gamestate = {}
Gamestate.states = {}
Gamestate.current = nil

function Gamestate.switch(state, ...)
    Gamestate.current = Gamestate.states[state]
    if Gamestate.current and Gamestate.current.load then
        Gamestate.current:load(...)
    end
end

function Gamestate.register(name, state)
    Gamestate.states[name] = state
end

function Gamestate.update(dt)
    if Gamestate.current and Gamestate.current.update then
        Gamestate.current:update(dt)
    end
end

function Gamestate.draw()
    if Gamestate.current and Gamestate.current.draw then
        Gamestate.current:draw()
    end
end

function Gamestate.keypressed(key, scancode, isrepeat)
    if Gamestate.current and Gamestate.current.keypressed then
        Gamestate.current:keypressed(key, scancode, isrepeat)
    end
end

function Gamestate.mousepressed(x, y, button, istouch, presses)
    if Gamestate.current and Gamestate.current.mousepressed then
        Gamestate.current:mousepressed(x, y, button, istouch, presses)
    end
end

function Gamestate.mousereleased(x, y, button, istouch, presses)
    if Gamestate.current and Gamestate.current.mousereleased then
        Gamestate.current:mousereleased(x, y, button, istouch, presses)
    end
end

function Gamestate.mousemoved(x, y, dx, dy, istouch)
    if Gamestate.current and Gamestate.current.mousemoved then
        Gamestate.current:mousemoved(x, y, dx, dy, istouch)
    end
end

return Gamestate