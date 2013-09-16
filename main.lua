function love.load()
    require("interface")
    require("dlc")

    bat = {
        x        = 300,
        y        = 550,
        offset   = 50,
        width    = 150,
        height   = 20,
        slowness = 0.1
    }

    balls = {}

    field = {
        x      = 0,
        y      = 0,
        width  = 800,
        height = 600
    }

    images = {}
    images["background"] = love.graphics.newImage("bg.png")

    sounds = {}
    sounds["bump_bat"]  = love.audio.newSource("bump_bat.wav",  "stream")
    sounds["bump_wall"] = love.audio.newSource("bump_wall.wav", "stream")
    sounds["message"]   = love.audio.newSource("message.wav",   "stream")

    fonts = {}
    fonts["droidsansmono"] = {}
    fonts["droidsansmono"][14] = love.graphics.newFont("DroidSansMono.ttf", 14)

    stats = {
        points = 0
    }

    add_ball()
end

function love.update(dt)
    dt = math.min(0.025, dt)

    bat.x = bat.x + (love.mouse.getX() - bat.x) / bat.slowness * dt

    for k,v in pairs(balls) do
        v.x = v.x + math.cos(v.angle) * v.speed * dt
        v.y = v.y + math.sin(v.angle) * v.speed * dt

        if v.x + v.size > field.x + field.width then
            ricochet(v, -1, 0, "bump_wall")
        end

        if v.x - v.size < field.x then
            ricochet(v, 1, 0, "bump_wall")
        end

        if v.y - v.size < field.y then
            ricochet(v, 0, 1, "bump_wall")
        end

        if v.y + v.size > bat.y then
            if math.abs(v.x - bat.x) < bat.width / 2 then
                give_points(1)
                ricochet(v, 0, -1, "bump_bat")
            else
                balls[k] = nil
            end
        end
    end


    for k,v in pairs(dlc_purchased) do
        if v.update then
            v:update()
        end
    end
end

function love.draw()
    love.graphics.draw(images["background"], 0, 0)

    love.graphics.rectangle("fill", bat.x - bat.width / 2, bat.y, bat.width, bat.height)

    for k,v in pairs(balls) do
        love.graphics.circle("fill", v.x, v.y, v.size, math.max(10, v.size))
    end

    interface.msgbox.draw()


    for k,v in pairs(dlc_purchased) do
        if v.draw then
            v:draw()
        end
    end
end

function love.keypressed(key)
    for k,v in pairs(dlc_available) do
        if v.key == key and v:check_available() then
            v:buy()
        end
    end
end

function love.resize(w, h)
    field.width = w
    field.height = h

    bat.y = h - bat.offset
end



function ricochet(ball, x, y, sound)
    local sx = math.cos(ball.angle)
    local sy = math.sin(ball.angle)
    
    if x ~= 0 then sx = math.abs(sx) * x end
    if y ~= 0 then sy = math.abs(sy) * y end

    ball.angle = math.atan2(sy, sx)

    sounds[sound]:rewind()
    sounds[sound]:play()
end

function give_points(points)
    stats.points = stats.points + points

    for k,v in pairs(dlc_available) do
        if not v.avail_msg_printed and v:check_available() then
            interface.msgbox.print("New DLC available: " .. v.name .. " - press " .. v.key .. " to buy for " .. v.costs.points .. " points.")
            v.avail_msg_printed = true
        end
    end
end

function take_points(points)
    stats.points = stats.points - points
end

function add_ball()
    table.insert(balls, {
        x     = math.random(field.x - 20, field.width - 40),
        y     = 400,
        size  = 15,
        angle = math.pi * -math.random(35, 40) / 100,
        speed = 600
    })
end
