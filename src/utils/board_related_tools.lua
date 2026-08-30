local output = {}

--- 判断一个位置上是否有棋子了
---@param col number
---@param row number
---@return boolean
function output.has_piece(col, row)
    return BOARD[col][row] ~= 0
end

--- 往这个全局table EATABLE_PIECES_POS_TABLE 里面插入可吃的位置
--- (排除移除当前下棋方自己的棋子所在的位置）
---@param pos any
function output.insert_eatable_piece(pos)
    local piece = BOARD[pos[1]][pos[2]]
    if piece.color ~= TURN:sub(1, 1) then -- 不是自己方的棋子再插入
        table.insert(EATABLE_PIECES_POS_TABLE, pos)
    end
end

return output