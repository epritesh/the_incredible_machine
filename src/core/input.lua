local Input = {}

Input.bindings = {}

function Input.bind(key, action)
    Input.bindings[key] = action
end

function Input.update(dt)
    -- This function can be used to handle continuous input,
    -- such as holding down a key.
end

function Input.keypressed(key, scancode, isrepeat)
    if Input.bindings[key] then
        Input.bindings[key]()
    end
end

return Input
