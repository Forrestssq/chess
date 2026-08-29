---@param start_w_or_b string
local function load_opening_board_status(start_w_or_b)
    local opening_board_status = {}    

    -- 先创建 8x8 的列表，用 0 填满
    for i = 1, 8 do
        opening_board_status[i] = {}
        for j = 1, 8 do
            opening_board_status[i][j] = 0
        end
    end
    io.write("----stop 1")
    -- 自己是白方
    if start_w_or_b:sub(1, 1) == 'w' then
        io.write("Start with white")
        -- 插入 Pawn
        for i = 1, 8 do
            local wP = Piece('w', 'P')
            opening_board_status[2][i] = wP
            
            local bP = Piece('b', 'P')
            opening_board_status[7][i] = bP
        end

        -- Rook
        local wR = Piece('w', 'R')
        opening_board_status[1][1] = wR
        opening_board_status[1][8] = wR
        local bR = Piece('b', 'R')
        opening_board_status[8][1] = bR
        opening_board_status[8][8] = bR

        -- Knight
        local wN = Piece('w', 'N')
        opening_board_status[1][2] = wN
        opening_board_status[1][7] = wN
        local bN = Piece('b', 'N')
        opening_board_status[8][2] = bN
        opening_board_status[8][7] = bN

        -- Biship
        local wB = Piece('w', 'B')
        opening_board_status[1][3] = wB
        opening_board_status[1][6] = wB
        local bB = Piece('b', 'B')
        opening_board_status[8][3] = bB
        opening_board_status[8][6] = bB
        io.write('-----')
        io.write(bB:name())

        -- Queen
        local wQ = Piece('w', 'Q')
        opening_board_status[1][4] = wQ
        local bQ = Piece('b', 'Q')
        opening_board_status[8][4] = bQ

        -- King
        local wK = Piece('w', 'K')
        opening_board_status[1][5] = wK
        local bK = Piece('b', 'K')
        opening_board_status[8][5] = bK
        
    -- 自己是黑方
    elseif start_w_or_b:sub(1, 1) == 'b' then
        -- 插入 Pawn
        for i = 1, 8 do
            local bP = Piece('b', 'P')
            opening_board_status[2][i] = bP
            
            local wP = Piece('w', 'P')
            opening_board_status[7][i] = wP
        end

        -- Rook
        local bR = Piece('b', 'R')
        opening_board_status[1][1] = bR
        opening_board_status[1][8] = bR
        local wR = Piece('w', 'R')
        opening_board_status[8][1] = wR
        opening_board_status[8][8] = wR

        -- Knight
        local bN = Piece('b', 'N')
        opening_board_status[1][2] = bN
        opening_board_status[1][7] = bN
        local wN = Piece('w', 'N')
        opening_board_status[8][2] = wN
        opening_board_status[8][7] = wN

        -- Biship
        local bB = Piece('b', 'B')
        opening_board_status[1][3] = bB
        opening_board_status[1][6] = bB
        local wB = Piece('w', 'B')
        opening_board_status[8][3] = wB
        opening_board_status[8][6] = wB

        -- Queen
        local bQ = Piece('b', 'Q')
        opening_board_status[1][4] = bQ
        local wQ = Piece('w', 'Q')
        opening_board_status[8][4] = wQ

        -- King
        local bK = Piece('b', 'K')
        opening_board_status[1][5] = bK
        local wK = Piece('w', 'K')
        opening_board_status[8][5] = wK
    else
        error("Piece 的 Color 只能是 white/w 或 black/b")
    end

    return opening_board_status
end

return load_opening_board_status