SIZE = 100

local function draw_chessboard()
    
    for row = 0, 7 do
        for col = 0, 7 do
            if (row + col) % 2 == 0 then
                love.graphics.setColor(0.9, 0.9, 0.9)
            else
                love.graphics.setColor(0.8, 0.8, 0.8)
            end
            ---@diagnostic disable-next-line
            love.graphics.rectangle("fill", col * SIZE, row * SIZE, SIZE, SIZE)
        end
    end
end

return draw_chessboard