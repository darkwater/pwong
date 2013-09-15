dlc_available = {
    {
        name = "Score display",
        key = "1",
        requires = {
            points = 5,
            breaks = {"Score display"}
        },
        costs = {
            points = 5
        },
        onbuy = function (self) end,
        update = function (self) end,
        draw = function (self)
            love.graphics.printf("\\  " .. stats.points .. "  /", 300, 10, 200, "center")
        end
    }
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

            elseif k == "breaks" then

                -- DLCs that shouldn't be bought
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
        take_points(self.costs.points)
        table.insert(dlc_purchased, self)
    end
}
dlc_mtt.__index = dlc_mtt
for k,v in pairs(dlc_available) do
    setmetatable(v, dlc_mtt)
end
