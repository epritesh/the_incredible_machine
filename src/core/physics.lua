local physics = {}

function physics.init()
    physics.world = love.physics.newWorld(0, 9.81 * 64, true)
end

function physics.resetWorld(objects)
    physics.init()
    for _, obj in ipairs(objects) do
        if obj.resetBody then obj:resetBody() end
    end
end

return physics
