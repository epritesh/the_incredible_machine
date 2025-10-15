local physics = {}

function physics.init()
    physics.world = love.physics.newWorld(0, 9.81 * 64, true)
    -- Setup contact callbacks for precise interactions (fans <> energy_ball, scissors <> balloon, etc.)
    physics.world:setCallbacks(physics.beginContact, physics.endContact, physics.preSolve, physics.postSolve)
end

function physics.beginContact(f1, f2, contact)
    local a = f1 and f1:getUserData() or nil
    local b = f2 and f2:getUserData() or nil
    if a and b then
        -- fan <-> energy_ball
        if a.type == "fan" and b.type == "energy_ball" then
            a._contactCount = (a._contactCount or 0) + 1
            a.active = true
        elseif b.type == "fan" and a.type == "energy_ball" then
            b._contactCount = (b._contactCount or 0) + 1
            b.active = true
        end
        -- scissors <-> balloon: set balloon to popped when it touches scissors (precise contact)
        if a.type == "scissors" and b.type == "balloon" then
            b.popped = true
        elseif b.type == "scissors" and a.type == "balloon" then
            a.popped = true
        end
    end
end

function physics.endContact(f1, f2, contact)
    local a = f1 and f1:getUserData() or nil
    local b = f2 and f2:getUserData() or nil
    if a and b then
        if a.type == "fan" and b.type == "energy_ball" then
            a._contactCount = math.max((a._contactCount or 1) - 1, 0)
            if a._contactCount == 0 then a.active = false end
        elseif b.type == "fan" and a.type == "energy_ball" then
            b._contactCount = math.max((b._contactCount or 1) - 1, 0)
            if b._contactCount == 0 then b.active = false end
        end
    end
end

function physics.preSolve(f1,f2,contact) end
function physics.postSolve(f1,f2,contact,normalImpulse, tangentImpulse) end

function physics.resetWorld(objects)
    physics.init()
    for _, obj in ipairs(objects) do
        -- Clear any previous contact state so fans don't remain active from earlier runs
        if obj.type == "fan" then
            obj._contactCount = 0
            obj.active = false
        end
        if obj.resetBody then obj:resetBody() end
    end
end


return physics
