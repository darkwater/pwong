dlc_available = {
    {
        name = "Score display",
        key = "1",
        requires = {
            points = 2,
            breaks = {"Score display"}
        },
        costs = {
            points = 2
        },
        onbuy = function (self) end,
        update = function (self) end,
        draw = function (self)
            love.graphics.printf("\\  " .. stats.points .. "  /", love.window,getWidth() / 2 - 100, 10, 200, "center")
        end
    },
    {
        name = "Resizability",
        key = "2",
        requires = {
            points = 3,
            dlcs = {"Score display"},
            breaks = {"Resizability"}
        },
        costs = {
            points = 3
        },
        onbuy = function (self)
            local width, height, flags = love.window.getMode()
            flags.resizable = true

            love.window.setMode(width, height, flags)
            love.resize(width, height)
        end,
        update = function (self) end,
        draw = function (self) end
    },
}
dlc_purchased = {}


dlc_mtt = {
    avail_msg_printed = false,
    check_available = function (self)
        for k,v in pairs(self.requires) do
            if k == "points" then

                -- Points check
                if stats.points < v then
                    return false
                end

            elseif k == "dlcs" then

                -- DLCs that should've be bought
                for _,check in pairs(v) do
                    local found = false
                    for _,target in pairs(dlc_purchased) do
                        if check == target.name then
                            found = true
                            break
                        end
                    end

                    if not found then
                        return false
                    end
                end

            elseif k == "breaks" then

                -- DLCs that shouldn't have been bought
                for _,check in pairs(v) do
                    for _,target in pairs(dlc_purchased) do
                        if check == target.name then
                            return false
                        end
                    end
                end

            end
        end

        return true
    end,
    buy = function (self)
        if self.onbuy then self:onbuy() end
        take_points(self.costs.points)
        table.insert(dlc_purchased, self)
    end
}
dlc_mtt.__index = dlc_mtt
for k,v in pairs(dlc_available) do
    setmetatable(v, dlc_mtt)
end
