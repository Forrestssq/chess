local coord = {}

-- 用来将鼠标位置转换成点击的格子
---@param x number
---@param y number
---@return integer, integer
function coord.pixel_to_cell(x, y)

    local col = math.ceil(x / SIZE)
    local row = 9 - math.ceil(y / SIZE)
    return col, row
end

-- 判断是不是用左键来点击的
---@param button number
function coord.is_left_button_click(button)
    return (button == 1)
end

-- 判断点击的位置是不是点击有效的。“有效”指的是非空白的位置，即，点击的位置是棋子所在的位置
-- 如果点击的是 valid 的，那么返回这个位置上储存的 Piece（class）
---@param col integer
---@param row integer
---@diagnostic disable-next-line
---@return boolean | Piece
---@diagnostic disable: need-check-nil
function coord.is_click_valid(col, row)
    local value = BOARD[col][row]
    if value == 0 then
        return false
    end

    local piece_name =  value:name()
    print(piece_name)
    if START_WITH:sub(1, 1) ~= piece_name:sub(1, 1) then
        return false
    end
    ---@diagnostic disable
    return value
end

return coord