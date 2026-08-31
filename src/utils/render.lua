local new = require("src.utils.piece_class").new
local render = {}
local tools = require 'src.utils.tools'
local board_tools = require 'src.utils.board_related_tools'
TILE = 100

-- 把 棋子的 png 加载成 love.Image 对象，并返回字典 dict<棋子: love.Image>
local function load_pieces()
    ---@type table<string, love.Image>
    local output = {}
    for c in string.gmatch("bw", '.') do
        for p in string.gmatch("BKNPQR", ".") do
            local file_name = 'assets/icons/' .. c .. p .. '.png'
            local name = c..p
            output[name] = love.graphics.newImage(file_name)
        end
    end
    return output
end
-- PIECES_ICON_DICT 用字典记录每个棋子对应的 Image 对象 dict<棋子: love.Image>
PIECES_ICON_DICT = load_pieces()

-- 画出棋盘格子
function render.draw_chessboard()    
    for row = 0, 7 do
        for col = 0, 7 do
            if (row + col) % 2 == 0 then
                love.graphics.setColor(0.9, 0.9, 0.9)
            else
                love.graphics.setColor(0.8, 0.8, 0.8)
            end
            ---@diagnostic disable-next-line
            love.graphics.rectangle("fill", col * TILE, row * TILE, TILE, TILE)
        end
    end
end

---@param piece love.Image
---@param col integer
---@param row integer
function render.draw_piece(piece, col, row)
    love.graphics.draw(piece, 
    (col - 1) * TILE, 
    (8 - row) * TILE,
    0,
    0.2,
    0.2
    )
end

-- display 函数用来画出当前的棋盘的状况。它依赖于 board 这个记录所有位置信息的 table 。这个 table 里面的是 Piece class。
-- 依靠 Piece class 下面的函数 :name() 返回的名字来识别出来是什么棋子以及用什么 icon 。
-- 也就是从 pieces_table 这个 dict 里面取出对应的 Image 对象
-- 每当 board 被修改的时候， 重新调用 display 来重新绘制
---@diagnostic disable: need-check-nil
function render.display()
    for col = 1, 8 do
        for row = 1, 8 do
            if BOARD[col][row] ~= 0 then
                ---@diagnostic disable-next-line
                local name = BOARD[col][row]:name()
                local icon = PIECES_ICON_DICT[name]
                render.draw_piece(icon, col, row)
            end
        end
    end
end

-- 当点击一个棋子的时候， hightlight 它所在的格子
---@param col integer
---@param row integer
function render.highlight_selected_pieces(col, row)
    -- 存下原来的颜色。 注意哦， getColor() 返回 4 个数字
    local r, g, b, a = love.graphics.getColor()
    local w = love.graphics.getLineWidth()

    love.graphics.setColor(1, 1, 0, 0.4)
    
    love.graphics.rectangle(
        ---@diagnostic disable-next-line
        'fill',
        (col - 1) * TILE, -- 画图的时候的坐标从左上角开始算 0 ，所以 -1
        (8 - row) * TILE, -- 画图的时候的坐标从左上角开始算 0 ，所以用 8 - row 而不是 9 - row
        TILE,
        TILE
    )

    -- 重新设定回原来的颜色
    love.graphics.setColor(r, g, b, a)
end

-- 画出灰色的提示
---@param col number
---@param row number
function render.draw_gray_spot(col, row)
    local r, y, b, a = love.graphics.getColor()
    love.graphics.setColor(0.6, 0.6, 0.6, 0.5)
    love.graphics.circle(
        ---@diagnostic disable-next-line
        'fill',
        TILE / 2 + (col - 1) * TILE,
        TILE / 2 + (8 - row) * TILE,
        TILE / 3.5
    )
    love.graphics.setColor(r, y, b, a)
end

--- 高亮可以吃掉的棋子
function render.highlight_eatable_pieces(col, row)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(0.7, 0.9, 0.7, 1)
    love.graphics.rectangle(
        "fill",
        TILE * (col - 1),
        TILE * (8 - row),
        TILE,
        TILE
    )
    love.graphics.setColor(0.9, 0.9, 0.9) -- 这个矩形负责给高亮加上一个和棋盘底色同色的外框
        love.graphics.rectangle(
        "line",
        TILE * (col - 1),
        TILE * (8 - row),
        TILE,
        TILE
    )
    love.graphics.setColor(r, g, b, a)
end

-- 给可以走的位置标出灰色点点。 
---@param piece Piece
---@param col number
---@param row number
function render.render_possible_pos(piece, col, row)
    ---@type table
    local possible_table

    ---判断一个位置是不是在 8x8 的格子里面
    ---接受两种方式的参数：
    ---1. col + row
    ---2. pos (是一个table， pos[1] = col, pos[2] = row)
    ---@param c any
    ---@param r any
    ---@return boolean
    local function is_valid_pos(c, r)
        if r == nil and type(c) == "table" then
            c, r = c[1], c[2]
        end
        return c > 0 and c < 9 and r > 0 and r < 9
    end

    --- 用向量法插入返回多个方向的的位置. BQK 专用
    --- 这个函数只用在 Queen Rook Bishop 这三个可以走很远的棋子 。 
    --- 返回的 table 由 多个 table 组成 。 每个 table 里面存着的是这个延伸方向可以走的位置
    --- 注意， 这个函数直接对 possible_table 操作 !!!!
    --- TODO: 监测到路上有棋子的话， 截断剩下的部分
    ---@param dirs table
    ---@param col number
    ---@param row number
    ---@return nil
    local function insert_vector_pos_BQK(dirs, col, row)
        local output = {}
        for _, d in ipairs(dirs) do
            local c, r = col + d[1], row + d[2]
            local line = {}
            while is_valid_pos(c, r) do
                table.insert(line, {c, r})
                c = c + d[1]
                r = r + d[2]
            end
            table.insert(output, line)
        end
        possible_table = output
    end
    
    -- 与上面类似， 但是专用于 KN
    local function insert_vector_pos_KN(dirs, col, row)
        local output = {}
        for _, pos in ipairs(dirs) do
            local new_c = col + pos[1]
            local new_r = row + pos[2]
            if is_valid_pos(new_c, new_r) then
                table.insert(output, {new_c, new_r})
            end
        end
        possible_table = { output } -- 包裹一层， 保持和其他的一样的三层 table
    end

    --- 从 possible_table 里面移除位置. 
    --- 注意， 这个函数直接对 possible_table 操作
    ---@param line_index number
    ---@param target_index number
    ---@return nil
    local function remove_pos_after_BQR(line_index, target_index)
        possible_table[line_index] = tools.remove_items_after_index(possible_table[line_index], target_index)
    end

    --- 注意，这个直接从 possible_table 里面移除位置
    --- 是给 BQR 用的， 如果他的走向的位置上有棋子，那么移除它
    --- 如果有可以吃的子， 放到 EATABLE_PIECES_POS_TABLE 中
    local function truncate_after_block_BQR()
        if possible_table == nil then return end
        for index_1, line in ipairs(possible_table) do
            for index_2, pos in ipairs(line) do
                if board_tools.has_piece(pos[1], pos[2]) then
                    board_tools.insert_eatable_piece(pos) --- 往这个全局table EATABLE_PIECES_POS_TABLE 里面插入可吃的位置
                    remove_pos_after_BQR(index_1, index_2)
                    break
                end
            end
        end
    end

    --- 注意，这个直接从 possible_table 里面移除位置
    --- 是给 RK 用的， 如果他的走向的位置上有棋子，那么移除它
    --- 如果有可以吃的子， 放到 EATABLE_PIECES_POS_TABLE 中
    ---@return nil
    local function remove_blocked_pos_RK()
        if possible_table == nil then return end
        for index, pos in ipairs(possible_table[1]) do -- 先剥去一层多余的 table 
            if board_tools.has_piece(pos[1], pos[2]) then
                board_tools.insert_eatable_piece(pos) --- 往这个全局table EATABLE_PIECES_POS_TABLE 里面插入可吃的位置
                table.remove(possible_table[1], index)
            end
        end
    end 
    
    --- 注意，这个直接从 possible_table 里面移除位置
    --- 是给 P 用的， 如果他的走向的位置上有棋子，那么移除它
    --- 如果它的左右侧有可以吃的子， 放到 EATABLE_PIECES_POS_TABLE  中
    ---@return nil
    local function remove_blocked_pos_P_your_side()
        if possible_table == nil then return end
        for index, pos in ipairs(possible_table[1]) do -- 先剥去一层多余的 table 
            if board_tools.has_piece(pos[1], pos[2]) then
                table.remove(possible_table[1], index)
            end
        end

        local attack_pos = {{col + 1, row + 1}, {col - 1, row + 1}}
        for _, pos in ipairs(attack_pos) do
            if is_valid_pos(pos) then
                if board_tools.has_piece(pos[1], pos[2]) then
                    board_tools.insert_eatable_piece(pos) --- 往这个全局table EATABLE_PIECES_POS_TABLE 里面插入可吃的位置
                end
            end
        end
    end

    --- 注意，这个直接从 possible_table 里面移除位置
    --- 是给 P 用的， 如果他的走向的位置上有棋子，那么移除它
    --- 如果它的左右侧有可以吃的子， 放到 EATABLE_PIECES_POS_TABLE  中
    ---@return nil
    local function remove_blocked_pos_P_other_side()
        if possible_table == nil then return end
        for index, pos in ipairs(possible_table[1]) do -- 先剥去一层多余的 table 
            if board_tools.has_piece(pos[1], pos[2]) then
                table.remove(possible_table[1], index)
            end
        end

        local attack_pos = {{col - 1, row - 1}, {col + 1, row - 1}}
        for _, pos in ipairs(attack_pos) do
            if is_valid_pos(pos) then
                if board_tools.has_piece(pos[1], pos[2]) then
                    board_tools.insert_eatable_piece(pos) --- 往这个全局table EATABLE_PIECES_POS_TABLE 里面插入可吃的位置
                end
            end
        end
    end

    local function Bishop()
        local dirs_bishop = {{-1, 1}, {1, 1}, {-1, -1}, {1, -1}}
        insert_vector_pos_BQK(dirs_bishop, col, row)
        truncate_after_block_BQR()
    end
    
    local function Queen()
        local dirs_queen = {{-1, 1}, {1, 1}, {-1, -1}, {1, -1}, {0, 1}, {0, -1}, {-1, 0}, {1, 0}}
        insert_vector_pos_BQK(dirs_queen, col, row)
        truncate_after_block_BQR()
    end
    
    local function Rook()
        local dirs_rook = {{0, 1}, {0, -1}, {-1, 0}, {1, 0}}
        insert_vector_pos_BQK(dirs_rook, col, row)
        truncate_after_block_BQR()
    end

    local function King()
        local dirs_king = {{-1, 1}, {1, 1}, {-1, -1}, {1, -1}, {0, 1}, {0, -1}, {-1, 0}, {1, 0}}
        insert_vector_pos_KN(dirs_king, col, row)
        remove_blocked_pos_RK()
    end
    
    local function Knight()
        local dirs_king = {{-1, 2}, {-2, 1}, {1, 2}, {2, 1}, {-2, -1}, {-1, -2}, {2, -1}, {1, -2}}
        insert_vector_pos_KN(dirs_king, col, row)
        remove_blocked_pos_RK()
    end
    
    local function Pawn()
        if START_WITH == TURN then
            if not piece.has_moved then
                possible_table = {{{col, row + 2}, {col, row + 1}}}
            else
                if is_valid_pos(col, row + 1) then
                    possible_table = {{{col, row + 1}}}
                end
            end
            remove_blocked_pos_P_your_side()            
        else
            if not piece.has_moved then
                possible_table = {{{col, row - 2}, {col, row - 1}}}
            else
                if is_valid_pos(col, row - 1) then
                    possible_table = {{{col, row - 1}}}
                end
            end
            remove_blocked_pos_P_other_side()
        end

        -- BUG: 这个还没有测试的！！
        -- 插入 en passant 的位置
        if EN_PASSANT_TARGET ~= nil then
            table.insert(possible_table, {{ EN_PASSANT_TARGET }})
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

    -- 画出灰色点点来。 这个函数是在原来 draw_gray_spot 函数的基础上加了拆包
    -- 注意，有三层拆包
    local function _draw_gray_spots(possible_pos)
        if possible_pos == nil then return end
        for _, line in ipairs(possible_pos) do
            for _, pos in ipairs(line) do
                if pos == nil then return end
                render.draw_gray_spot(pos[1], pos[2])
            end
        end 
    end

    _draw_gray_spots(possible_table)
end

return render