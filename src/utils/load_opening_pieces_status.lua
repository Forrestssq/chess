---@param start_w_or_b string
local function load_opening_board_status(start_w_or_b)
    ---@type (Piece | integer)[][]
    local opening_board_status = {}    

    ---@diagnostic disable: need-check-nil
    -- 先创建 8x8 的列表，用 0 填满
    for i = 1, 8 do
        opening_board_status[i] = {}
        for j = 1, 8 do
            opening_board_status[i][j] = 0
        end
    end

    -- 自己是白方
    if start_w_or_b:sub(1, 1) == 'w' then
        io.write("Start with white\n")
        -- 插入 Pawn
        for i = 1, 8 do
            local wP = Piece('w', 'P')
            opening_board_status[i][2] = wP
            
            local bP = Piece('b', 'P')
            opening_board_status[i][7] = bP
        end

        -- Rook
        local wR = Piece('w', 'R')
        opening_board_status[1][1] = wR
        opening_board_status[8][1] = wR
        local bR = Piece('b', 'R')
        opening_board_status[1][8] = bR
        opening_board_status[8][8] = bR

        -- Knight
        local wN = Piece('w', 'N')
        opening_board_status[2][1] = wN
        opening_board_status[7][1] = wN
        local bN = Piece('b', 'N')
        opening_board_status[2][8] = bN
        opening_board_status[7][8] = bN

        -- Bishop
        local wB = Piece('w', 'B')
        opening_board_status[3][1] = wB
        opening_board_status[6][1] = wB
        local bB = Piece('b', 'B')
        opening_board_status[3][8] = bB
        opening_board_status[6][8] = bB

        -- Queen
        local wQ = Piece('w', 'Q')
        opening_board_status[4][1] = wQ
        local bQ = Piece('b', 'Q')
        opening_board_status[4][8] = bQ

        -- King
        local wK = Piece('w', 'K')
        opening_board_status[5][1] = wK
        local bK = Piece('b', 'K')
        opening_board_status[5][8] = bK
        
    -- 自己是黑方
    elseif start_w_or_b:sub(1, 1) == 'b' then
        io.write("Start with black\n")
        -- 插入 Pawn
        for i = 1, 8 do
            local bP = Piece('b', 'P')
            opening_board_status[i][2] = bP
            
            local wP = Piece('w', 'P')
            opening_board_status[i][7] = wP
        end

        -- Rook
        local bR = Piece('b', 'R')
        opening_board_status[1][1] = bR
        opening_board_status[8][1] = bR
        local wR = Piece('w', 'R')
        opening_board_status[1][8] = wR
        opening_board_status[8][8] = wR

        -- Knight
        local bN = Piece('b', 'N')
        opening_board_status[2][1] = bN
        opening_board_status[7][1] = bN
        local wN = Piece('w', 'N')
        opening_board_status[2][8] = wN
        opening_board_status[7][8] = wN

        -- Bishop
        local bB = Piece('b', 'B')
        opening_board_status[3][1] = bB
        opening_board_status[6][1] = bB
        local wB = Piece('w', 'B')
        opening_board_status[3][8] = wB
        opening_board_status[6][8] = wB

        -- Queen
        local bQ = Piece('b', 'Q')
        opening_board_status[4][1] = bQ
        local wQ = Piece('w', 'Q')
        opening_board_status[4][8] = wQ

        -- King
        local bK = Piece('b', 'K')
        opening_board_status[5][1] = bK
        local wK = Piece('w', 'K')
        opening_board_status[5][8] = wK
    else
        -- 防止我自己手贱写错了
        error("Piece 的 Color 只能是 white/w 或 black/b")
    end

    return opening_board_status
end

return load_opening_board_status