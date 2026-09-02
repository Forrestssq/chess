local render = {}
local tools = require 'src.utils.tools'
local board_tools = require 'src.board.board_tools'
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
function render.render_possible_pos()
    -- 画出灰色点点来。 这个函数是在原来 draw_gray_spot 函数的基础上加了拆包
    -- 注意，有三层拆包
    local function _draw_gray_spots()
        if POSSIBLE_TABLE == nil then return end
        for _, line in ipairs(POSSIBLE_TABLE) do
            for _, pos in ipairs(line) do
                if pos == nil then goto continue end
                render.draw_gray_spot(pos[1], pos[2])
                ::continue::
            end
        end 
    end

    _draw_gray_spots()
end

return render