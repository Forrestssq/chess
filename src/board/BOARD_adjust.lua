local board_tools = require "src.board.board_tools"

local BOARD_adjust = {}

-- 把 Piece 里面的 has_moved 标记改为 true
function BOARD_adjust.set_to_has_moved(col, row)
    -- 用原来的 先取出来 piece 然后再修改也可以，
    -- 因为对于 table 的值是 shallow copy
    BOARD[col][row].has_moved = true
end

-- 拆包。 只用在对 main.lua 中 love.mousepressed() 下面移动棋子判断所调用的 本函数下方的传入的参数拆包用
---@param input table
local function unpack_unified_input(input)
    return input[1], input[2], input[3], input[4]
end

--- 只移动不吃子
--- 在移动后， TURN_TURN() 反转到对方
---@param input table
function BOARD_adjust.move_piece(input)
    local old_c, old_r, new_c, new_r = unpack_unified_input(input)
    
    BOARD[new_c][new_r] = BOARD[old_c][old_r]
    BOARD[old_c][old_r] = 0

    local is_Pawn = function ()
        return board_tools.get_piece_at_pos(new_c, new_r).type:sub(2, 2) == 'P'
    end

    local move_2_steps_ahead = function ()
        return math.abs(new_r - old_r) == 2
    end

    if is_Pawn() and move_2_steps_ahead() then
        -- 移动的 Pawn 可以出发 en_passant 情况
        if TURN == START_WITH then -- 轮到自己方面下的时候
            local pos = {new_c, new_r - 1}
            EN_PASSANT_TARGET = pos
        else
            local pos = {new_c, new_r + 1}
            EN_PASSANT_TARGET = pos
        end
    end
end

--- 正常吃子
--- 在移动后， TURN_TURN() 反转到对方
function BOARD_adjust.eat_piece(input)
    local old_c, old_r, new_c, new_r = unpack_unified_input(input)
    BOARD[new_c][new_r] = BOARD[old_c][old_r]
    BOARD[old_c][old_r] = 0
end

--- 在移动后， TURN_TURN() 反转到对方
function BOARD_adjust.castle_queenside(input)
    local old_c, old_r, new_c, new_r = unpack_unified_input(input)
end

--- 在移动后， TURN_TURN() 反转到对方
function BOARD_adjust.castle_rookside(input)
    local old_c, old_r, new_c, new_r = unpack_unified_input(input)
end

--- 在移动后， TURN_TURN() 反转到对方
function BOARD_adjust.en_passant(input)
    local old_c, old_r, new_c, new_r = unpack_unified_input(input)
end

return BOARD_adjust