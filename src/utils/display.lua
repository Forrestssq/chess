-- 这个函数用来画出当前的棋盘的状况。它依赖于 board 这个记录所有位置信息的 table 。这个 table 里面的是 Piece class。
-- 依靠 Piece class 下面的函数 :name() 返回的名字来识别出来是什么棋子以及用什么 icon 。
-- 也就是从 pieces_table 这个 dict 里面取出对应的 Image 对象
-- 每当 board 被修改的时候， 重新调用 display 来重新绘制

local function display()
    for i = 1, 8 do
        for j = 1, 8 do
            if BOARD[i][j] ~= 0 then
                local name = BOARD[i][j]:name()
                local icon = PIECES_DICT[name]
                FUNC_DRAW_PIECE(icon, j, i)
            end
        end
    end
end

return display