local tools = require 'src.utils.tools'
local board_tools = {}

--- 判断一个位置上是否有棋子了
---@param col number
---@param row number | nil
---@return boolean
function board_tools.has_piece(col, row)
    return BOARD[col][row] ~= 0
end

--- 往这个全局table EATABLE_PIECES_POS_TABLE 里面插入可吃的位置
--- (排除移除当前下棋方自己的棋子所在的位置）
---@param pos table
function board_tools.insert_eatable_piece(pos)
    local piece = BOARD[pos[1]][pos[2]]
    if piece.color ~= TURN:sub(1, 1) then -- 不是自己方的棋子再插入
        table.insert(EATABLE_TABLE, pos)
    end
end

function board_tools.get_piece_at_pos(col, row)
    if type(col) == 'table' and row == nil then
        row = col[2] -- 先复制给 row ， 因为下面的 col 的赋值会覆盖掉原有的
        col = col[1]
    end
    local value = BOARD[col][row]
    return value
end

---判断一个位置是不是在 8x8 的格子里面
---接受两种方式的参数：
---1. col + row
---2. pos (是一个table， pos[1] = col, pos[2] = row)
---@param c any
---@param r any
---@return boolean
function board_tools.is_valid_pos(c, r)
    if r == nil and type(c) == "table" then
        c, r = c[1], c[2]
    end
    return c > 0 and c < 9 and r > 0 and r < 9
end

function board_tools.add_en_passant_pos_to_EATABLE_PIECES_POS_TABLE()
    
end

--- 用来查看位置是否合法
---@return boolean
function board_tools.is_pos_in_POSSIBLE_TABLE_or_EATABLE_TABLE(pos)
    for _, value_1 in ipairs(EATABLE_TABLE) do
        if (value_1[1] == pos[1]) and (value_1[2] == pos[2]) then
            return true
        end
    end

    for _, line in ipairs(POSSIBLE_TABLE) do
        for _, value_2 in ipairs(line) do
            if (value_2[1] == pos[1]) and (value_2[2] == pos[2]) then
                return true
            end
        end
    end

    return false
end

function board_tools.calculate_POSSIBLE_TABLE_and_EATABLE_TABLE(col, row)
    local piece = board_tools.get_piece_at_pos(col, row)
    
    if piece == 0 then
        return
    end
    
    local function Bishop()
        local dirs_bishop = {{-1, 1}, {1, 1}, {-1, -1}, {1, -1}}
        board_tools.insert_vector_pos_BQK(dirs_bishop, col, row)
        board_tools.truncate_after_block_BQR()
    end
    
    local function Queen()
        local dirs_queen = {{-1, 1}, {1, 1}, {-1, -1}, {1, -1}, {0, 1}, {0, -1}, {-1, 0}, {1, 0}}
        board_tools.insert_vector_pos_BQK(dirs_queen, col, row)
        board_tools.truncate_after_block_BQR()
    end
    
    local function Rook()
        local dirs_rook = {{0, 1}, {0, -1}, {-1, 0}, {1, 0}}
        board_tools.insert_vector_pos_BQK(dirs_rook, col, row)
        board_tools.truncate_after_block_BQR()
    end

    local function King()
        local dirs_king = {{-1, 1}, {1, 1}, {-1, -1}, {1, -1}, {0, 1}, {0, -1}, {-1, 0}, {1, 0}}
        board_tools.insert_vector_pos_KN(dirs_king, col, row)
        board_tools.remove_blocked_pos_NK()
    end
    
    local function Knight()
        local dirs_knight = {{-1, 2}, {-2, 1}, {1, 2}, {2, 1}, {-2, -1}, {-1, -2}, {2, -1}, {1, -2}}
        board_tools.insert_vector_pos_KN(dirs_knight, col, row)
        board_tools.remove_blocked_pos_NK()
    end
    
    local function Pawn()
        if START_WITH == TURN then
            if not piece.has_moved then
                POSSIBLE_TABLE = {{{col, row + 2}, {col, row + 1}}}
            else
                if board_tools.is_valid_pos(col, row + 1) then
                    POSSIBLE_TABLE = {{{col, row + 1}}}
                end
            end
            board_tools.remove_blocked_pos_P_your_side(col, row)
        else
            if not piece.has_moved then
                POSSIBLE_TABLE = {{{col, row - 2}, {col, row - 1}}}
            else
                if board_tools.is_valid_pos(col, row - 1) then
                    POSSIBLE_TABLE = {{{col, row - 1}}}
                end
            end
            board_tools.remove_blocked_pos_P_other_side(col, row)
        end

        if EN_PASSANT_TARGET ~= nil then
            table.insert(POSSIBLE_TABLE[1], EATABLE_TABLE) -- 插入到可以吃的表格
            EN_PASSANT_TARGET = nil -- 清空
        end   
    end
    
    local piece_type = piece:name():sub(2, 2)
    if     piece_type == 'B' then Bishop() 
    elseif piece_type == 'Q' then Queen() 
    elseif piece_type == 'R' then Rook()
    elseif piece_type == 'K' then King() 
    elseif piece_type == 'N' then Knight()
    elseif piece_type == 'P' then Pawn()
    else error("You stupid fucking bitch.")
    end
end

--- 用向量法插入返回多个方向的的位置. BQK 专用
--- 这个函数只用在 Queen Rook Bishop 这三个可以走很远的棋子 。 
--- 返回的 table 由 多个 table 组成 。 每个 table 里面存着的是这个延伸方向可以走的位置
--- 注意， 这个函数直接对 possible_table 操作 !!!!
---@param dirs table
---@param col number
---@param row number
---@return nil
function board_tools.insert_vector_pos_BQK(dirs, col, row)
    local output = {}
    for _, d in ipairs(dirs) do
        local c, r = col + d[1], row + d[2]
        local line = {}
        while board_tools.is_valid_pos(c, r) do
            table.insert(line, {c, r})
            c = c + d[1]
            r = r + d[2]
        end
        table.insert(output, line)
    end
    POSSIBLE_TABLE = output
end

-- 与上面类似， 但是专用于 KN
function board_tools.insert_vector_pos_KN(dirs, col, row)
    local output = {}
    for _, pos in ipairs(dirs) do
        local attack_c = col + pos[1]
        local attack_r = row + pos[2]
        if board_tools.is_valid_pos(attack_c, attack_r) then
            table.insert(output, {attack_c, attack_r})
        end
    end
    POSSIBLE_TABLE = { output } -- 包裹一层， 保持和其他的一样的三层 table
end

--- 从 possible_table 里面移除位置. 
--- 注意， 这个函数直接对 possible_table 操作
---@param line_index number
---@param target_index number
---@return nil
function board_tools.remove_pos_after_BQR(line_index, target_index)
    tools.remove_items_after_index(POSSIBLE_TABLE[line_index], target_index)
end

--- 注意，这个直接从 possible_table 里面移除位置
--- 是给 BQR 用的， 如果他的走向的位置上有棋子，那么移除它
--- 如果有可以吃的子， 放到 EATABLE_PIECES_POS_TABLE 中
function board_tools.truncate_after_block_BQR()
    if POSSIBLE_TABLE == nil then return end
    for index_1, line in ipairs(POSSIBLE_TABLE) do
        for index_2, pos in ipairs(line) do
            if board_tools.has_piece(pos[1], pos[2]) then
                board_tools.insert_eatable_piece(pos) -- 往这个全局table EATABLE_PIECES_POS_TABLE 里面插入可吃的位置
                board_tools.remove_pos_after_BQR(index_1, index_2)
                break
            end
        end
    end
end

--- 注意，这个直接从 possible_table 里面移除位置
--- 是给 NK 用的， 如果他的走向的位置上有棋子，那么移除它
--- 如果有可以吃的子， 放到 EATABLE_PIECES_POS_TABLE 中
---@return nil
function board_tools.remove_blocked_pos_NK()
    if POSSIBLE_TABLE == nil then return end
    local keep = {}
    for index, pos in ipairs(POSSIBLE_TABLE[1]) do -- 先剥去一层多余的 table 
        if board_tools.has_piece(pos[1], pos[2]) then
            board_tools.insert_eatable_piece(pos) --- 往这个全局table EATABLE_PIECES_POS_TABLE 里面插入可吃的位置
        else
            table.insert(keep, pos)
        end
    end
    POSSIBLE_TABLE[1] = keep
end

--- 注意，这个直接从 possible_table 里面移除位置
--- 是给 P 用的， 如果他的走向的位置上有棋子，那么移除它
--- 如果它的左右侧有可以吃的子， 放到 EATABLE_PIECES_POS_TABLE  中
--- 这个函数是用在 轮到自己方面下的时候用来调整 Pawn 的可移动位置
---@return nil
---@param col number
---@param row number
function board_tools.remove_blocked_pos_P_your_side(col, row)
    if POSSIBLE_TABLE == nil then return end
    for index, pos in ipairs(POSSIBLE_TABLE[1]) do -- 先剥去一层多余的 table 
        if board_tools.has_piece(pos[1], pos[2]) then
            table.remove(POSSIBLE_TABLE[1], index)
        end
    end

    local attack_pos = {{col + 1, row + 1}, {col - 1, row + 1}}
    for _, pos in ipairs(attack_pos) do
        if board_tools.is_valid_pos(pos) then
            if board_tools.has_piece(pos[1], pos[2]) then
                board_tools.insert_eatable_piece(pos) --- 往这个全局table EATABLE_PIECES_POS_TABLE 里面插入可吃的位置
            end
        end
    end
end

--- 注意，这个直接从 possible_table 里面移除位置
--- 是给 P 用的， 如果他的走向的位置上有棋子，那么移除它
--- 如果它的左右侧有可以吃的子， 放到 EATABLE_PIECES_POS_TABLE  中
--- 这个函数是用在 轮到对方下的时候用来调整 Pawn 的可移动位置
---@return nil
---@param col number
---@param row number
function board_tools.remove_blocked_pos_P_other_side(col, row)
    if POSSIBLE_TABLE == nil then return end
    for index, pos in ipairs(POSSIBLE_TABLE[1]) do -- 先剥去一层多余的 table 
        if board_tools.has_piece(pos[1], pos[2]) then
            table.remove(POSSIBLE_TABLE[1], index)
        end
    end

    local attack_pos = {{col - 1, row - 1}, {col + 1, row - 1}}
    for _, pos in ipairs(attack_pos) do
        if board_tools.is_valid_pos(pos) then
            if board_tools.has_piece(pos[1], pos[2]) then
                board_tools.insert_eatable_piece(pos) --- 往这个全局table EATABLE_PIECES_POS_TABLE 里面插入可吃的位置
            end
        end
    end
end

return board_tools