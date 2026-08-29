---@param piece love.Image
---@param col number
---@param row number
local function draw_piece(piece, col, row)
    love.graphics.draw(piece, 
    (col - 1) * SIZE, 
    (8 - row) * SIZE,
    0,
    0.2,
    0.2
    )
end

return draw_piece