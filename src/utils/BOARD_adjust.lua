local BOARD_adjust = {}

-- 拆包。 只用在对 main.lua 中 love.mousepressed() 下面移动棋子判断所调用的 本函数下方的传入的参数拆包用
---@param input table
local function unpack_unified_input(input)
    return input[1], input[2], input[3], input[4]
end

-- 只移动不吃子
---@param input table
function BOARD_adjust.move_piece(input)
    local old_c, old_r, new_c, new_r = unpack_unified_input(input)
    BOARD[new_c][new_r] = BOARD[old_c][old_r]
    BOARD[old_c][old_r] = 0
end

-- 正常吃子
function BOARD_adjust.eat_piece(input)
    local old_c, old_r, new_c, new_r = unpack_unified_input(input)
    BOARD[new_c][new_r] = BOARD[old_c][old_r]
    BOARD[old_c][old_r] = 0
end

function BOARD_adjust.castle_queenside(input)
    local old_c, old_r, new_c, new_r = unpack_unified_input(input)
end

function BOARD_adjust.castle_rookside(input)
    local old_c, old_r, new_c, new_r = unpack_unified_input(input)
end

function BOARD_adjust.en_passant(input)
    local old_c, old_r, new_c, new_r = unpack_unified_input(input)
end

return BOARD_adjust