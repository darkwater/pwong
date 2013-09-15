function love.load()
    require("interface")
    require("dlc")

    bat = {
        x        = 300,
        y        = 550,
        width    = 150,
        height   = 20,
        slowness = 2
    }

    ball = {
        x     = 600,
        y     = 400,
        size  = 15,
        angle = math.pi * -0.25,
        speed = 600
    }

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
end

function love.update(dt)
    dt = math.min(0.025, dt)

    bat.x = bat.x + (love.mouse.getX() - bat.x) / bat.slowness

    ball.x = ball.x + math.cos(ball.angle) * ball.speed * dt
    ball.y = ball.y + math.sin(ball.angle) * ball.speed * dt

    if ball.x + ball.size > field.x + field.width then
        ricochet(-1, 0, "bump_wall")
    end

    if ball.x - ball.size < field.x then
        ricochet(1, 0, "bump_wall")
    end

    if ball.y - ball.size < field.y then
        ricochet(0, 1, "bump_wall")
    end

    if ball.y + ball.size > bat.y then
        if math.abs(ball.x - bat.x) < bat.width / 2 then
            give_points(1)
            ricochet(0, -1, "bump_bat")
        else
            error("u lost lol der goes ur " .. stats.points .. " pts omg n00b")
        end
    end


    for k,v in pairs(dlc_purchased) do
        if v.update then
            v:update()
        end
    end
end

function love.draw()
    love.graphics.draw(images["background"], -1920 + 800, -1080 + 600)

    love.graphics.rectangle("fill", bat.x - bat.width / 2, bat.y, bat.width, bat.height)
    love.graphics.circle("fill", ball.x, ball.y, ball.size, math.max(10, ball.size))

    interface.msgbox.draw()


    for k,v in pairs(dlc_purchased) do
        if v.draw then
            v:draw()
        end
    end
end

function love.keypressed(key)
    for k,v in pairs(dlc_available) do
        if v:check_available() then
            v:buy()
        end
    end
end


function ricochet(x, y, sound)
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
            interface.msgbox.print("New DLC available: " .. v.name .. " - press " .. v.key .. " to buy.")
            v.avail_msg_printed = true
        end
    end
end

function take_points(points)
    stats.points = stats.points - points
end
