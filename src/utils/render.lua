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


return render