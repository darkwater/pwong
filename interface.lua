interface = {}
interface.msgbox = {}
interface.msgbox.messages = {}
interface.msgbox.print = function (msg)
    table.insert(interface.msgbox.messages, 1, {
        text = msg
    })
end
interface.msgbox.draw = function ()
    love.graphics.setFont(fonts["droidsansmono"][14])

    local y = 500
    for k,v in pairs(interface.msgbox.messages) do
        love.graphics.print(v.text or "", 20, y)

        y = y - 20
    end
end
