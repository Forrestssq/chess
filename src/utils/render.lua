local new = require("src.utils.piece_class").new
local render = {}

SIZE = 100

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
            love.graphics.rectangle("fill", col * SIZE, row * SIZE, SIZE, SIZE)
        end
    end
end

---@param piece love.Image
---@param col integer
---@param row integer
function render.draw_piece(piece, col, row)
    love.graphics.draw(piece, 
    (col - 1) * SIZE, 
    (8 - row) * SIZE,
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
function render.highlight_piece(col, row)
    -- 存下原来的颜色。 注意哦， getColor() 返回 4 个数字
    local r, g, b, a = love.graphics.getColor()
    local w = love.graphics.getLineWidth()

    love.graphics.setColor(1, 1, 0, 0.4)
    
    love.graphics.rectangle(
        ---@diagnostic disable-next-line
        'fill',
        (col - 1) * SIZE, -- 画图的时候的坐标从左上角开始算 0 ，所以 -1
        (8 - row) * SIZE, -- 画图的时候的坐标从左上角开始算 0 ，所以用 8 - row 而不是 9 - row
        SIZE,
        SIZE
    )

    -- 重新设定回原来的颜色
    love.graphics.setColor(r, g, b, a)
    love.graphics.setLineWidth(w)
end

-- 画出灰色的提示
---@param col number
---@param row number
function draw_gray_spot(col, row)
    local r, y, b, a = love.graphics.getColor()
    love.graphics.setColor(0.6, 0.6, 0.6, 0.5)
    love.graphics.circle(
        ---@diagnostic disable-next-line
        'fill',
        SIZE / 2 + (col - 1) * SIZE,
        SIZE / 2 + (8 - row) * SIZE,
        SIZE / 3.5
    )
    love.graphics.setColor(r, y, b, a)
end

-- 给可以走的位置标出灰色点点。 
---@param piece Piece
---@param col number
---@param row number
function render.render_possible_pos(piece, col, row)
    ---@type table
    local possible_table
    
    -- 用向量法插入返回多个方向的的位置
    -- 这个函数只用在 Queen Rook Bishop 这三个可以走很远的棋子 。 
    -- 返回的 table 由 多个 table 组成 。 每个 table 里面存着的是这个延伸方向可以走的位置
    -- TODO: 监测到路上有棋子的话， 截断剩下的部分
    ---@param dirs table
    ---@param col number
    ---@param row number
    ---@return table
    local function insert_vector_pos(dirs, col, row)
        local output = {}
        for _, d in ipairs(dirs) do
            local c, r = col + d[1], row + d[2]
            local line = {}
            while c > 0 and c < 8 + 1 and r > 0 and r < 8 + 1 do
                table.insert(line, {c, r})
                c = c + d[1]
                r = r + d[2]
            end
            table.insert(output, line)
        end
        return output
    end
    
    local function Bishop()
        local dirs_bishop = {{-1, 1}, {1, 1}, {-1, -1}, {1, -1}}
        possible_table = insert_vector_pos(dirs_bishop, col, row)
        print(possible_table)
    end
    
    local function is_valid_pos(c, r)
        return c > 0 and c < 9 and r > 0 and r < 9
    end

    local function King()
        local c, r = col, row
        local dirs_king = {{-1, 1}, {1, 1}, {-1, -1}, {1, -1}, {0, 1}, {0, -1}, {-1, 0}, {1, 0}}
        local output = {}
        for _, pos in ipairs(dirs_king) do
            local new_c = c + pos[1]
            local new_r = r + pos[2]
            if is_valid_pos(new_c, new_r) then
                table.insert(output, {new_c, new_r})
            end
        end
        possible_table = { output } -- 包裹一层， 保持和其他的一样的三层 table
    end
    
    local function Knight()
        local c, r = col, row
        local dirs_king = {{-1, 2}, {-2, 1}, {1, 2}, {2, 1}, {-2, -1}, {-1, -2}, {2, -1}, {1, -2}}
        local output = {}
        for _, pos in ipairs(dirs_king) do
            local new_c = c + pos[1]
            local new_r = r + pos[2]
            if is_valid_pos(new_c, new_r) then
                table.insert(output, {new_c, new_r})
            end
        end
        possible_table = { output } -- 包裹一层， 保持和其他的一样的三层 table
    end
    
    local function Pawn()
        if not piece.has_moved then
            possible_table = {{{col, row + 2}, {col, row + 1}}}
        else
            if is_valid_pos(col, row + 1) then
                possible_table = {{{col, row + 1}}}
            end
        end

        -- BUG: 这个还没有测试的！！
        -- 插入 en passant 的位置
        if EN_PASSANT_TARGET ~= nil then
            table.insert(possible_table, {{}})
        end
    end
    
    local function Queen()
        local dirs_queen = {{-1, 1}, {1, 1}, {-1, -1}, {1, -1}, {0, 1}, {0, -1}, {-1, 0}, {1, 0}}
        possible_table = insert_vector_pos(dirs_queen, col, row)
    end
    
    local function Rook()
        local dirs_rook = {{0, 1}, {0, -1}, {-1, 0}, {1, 0}}
        possible_table = insert_vector_pos(dirs_rook, col, row)
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
    local function _draw_gray_spots(possible_pos)
        if possible_pos == nil then return end
        for _, line in ipairs(possible_pos) do
            for _, pos in ipairs(line) do
                if pos == nil then return end
                draw_gray_spot(pos[1], pos[2])
            end
        end 
    end

    _draw_gray_spots(possible_table)
end
return render